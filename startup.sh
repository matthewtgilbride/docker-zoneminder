#!/bin/bash


set -e

#trays to fix problem with https://github.com/QuantumObject/docker-zoneminder/issues/22
chown www-data /dev/shm
mkdir -p /var/run/zm
chown www-data:www-data /var/run/zm

# set the memory limit of php
sed  -i "s|memory_limit = .*|memory_limit = ${PHP_MEMORY_LIMIT:-512M}|" /etc/php/7.2/apache2/php.ini
#to fix problem with data.timezone that appear at 1.28.108 for some reason
sed  -i "s|\;date.timezone =|date.timezone = \"${TZ:-America/New_York}\"|" /etc/php/7.2/apache2/php.ini
#if ZM_DB_HOST variable is provided in container use it as is, if not left as localhost
ZM_DB_HOST=${ZM_DB_HOST:-localhost}
sed  -i "s|ZM_DB_HOST=localhost|ZM_DB_HOST=$ZM_DB_HOST|" /etc/zm/zm.conf
#if MYSQL_ROOT_PASSWORD variable is provided in container use it as is, if not left as mysqlpsswd
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-mysqlpsswd}
MYSQL_ROOT=${MYSQL_ROOT:-root}
sed  -i "s|MYSQL_ROOT_PASSWORD=mysqlpsswd|MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD|" /etc/zm/zm.conf
#if ZM_SERVER_HOST variable is provided in container use it as is, if not left 02-multiserver.conf unchanged
if [ -v ZM_SERVER_HOST ]; then sed -i "s|#ZM_SERVER_HOST=|ZM_SERVER_HOST=${ZM_SERVER_HOST}|" /etc/zm/conf.d/02-multiserver.conf; fi

# Returns true once mysql can connect.
mysql_ready() {
  mysqladmin ping --host=$ZM_DB_HOST --user=$MYSQL_ROOT --password=$MYSQL_ROOT_PASSWORD > /dev/null 2>&1
}

# Handle the zmeventnotification.ini file
if [ -f /config/zmeventnotification.ini ]; then
   echo "Moving zmeventnotification.ini"
   if [ ! -d /var/cache/zoneminder/events ]; then
      mkdir -p /etc/zm/
   fi
   ln -sf /config/zmeventnotification.ini /etc/zm/zmeventnotification.ini
fi

if [ -f /var/cache/zoneminder/configured ]; then
        echo 'already configured.'
        while !(mysql_ready)
        do
          sleep 3
          echo "waiting for mysql ..."
        done
        rm -rf /var/run/zm/*
	/sbin/zm.sh&
else
        #check if Directory inside of /var/cache/zoneminder are present.
        if [ ! -d /var/cache/zoneminder/events ]; then
           mkdir -p /var/cache/zoneminder/{events,images,temp,cache}
        fi

        chown -R root:www-data /var/cache/zoneminder /etc/zm/zm.conf
        chmod -R 770 /var/cache/zoneminder /etc/zm/zm.conf
        while !(mysql_ready)
        do
          sleep 3
          echo "waiting for mysql ..."
        done
        # comment out because we need SUPER permission maybe? NO_ENGINE_SUBSTITUTION is already on in RDS
        # echo "SET GLOBAL sql_mode = 'NO_ENGINE_SUBSTITUTION';" | mysql -u $MYSQL_ROOT -p$MYSQL_ROOT_PASSWORD -h $ZM_DB_HOST
        mysql -u $MYSQL_ROOT -p$MYSQL_ROOT_PASSWORD -h $ZM_DB_HOST < /usr/share/zoneminder/db/zm_create.sql
        date > /var/cache/zoneminder/dbcreated
        #needed to fix problem with ubuntu ... and cron
        update-locale
        date > /var/cache/zoneminder/configured
        zmupdate.pl
        rm -rf /var/run/zm/*
        /sbin/zm.sh&
fi
