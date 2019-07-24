TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`%` TRIGGER Events_Hour_update_trigger AFTER UPDATE ON Events_Hour\nFOR EACH ROW\n  BEGIN\n    declare diff BIGINT default 0;\n\n    set diff = COALESCE(NEW.DiskSpace,0) - COALESCE(OLD.DiskSpace,0);\n    IF ( diff ) THEN\n      IF ( NEW.MonitorID != OLD.MonitorID ) THEN\n        UPDATE Monitors SET HourEventDiskSpace=COALESCE(HourEventDiskSpace,0)-COALESCE(OLD.DiskSpace,0) WHERE Monitors.Id=OLD.MonitorId;\n        UPDATE Monitors SET HourEventDiskSpace=COALESCE(HourEventDiskSpace,0)-COALESCE(NEW.DiskSpace,0) WHERE Monitors.Id=NEW.MonitorId;\n      ELSE\n        UPDATE Monitors SET HourEventDiskSpace=COALESCE(HourEventDiskSpace,0)+diff WHERE Monitors.Id=NEW.MonitorId;\n      END IF;\n    END IF;\n  END' 'CREATE DEFINER=`root`@`%` TRIGGER Events_Hour_delete_trigger BEFORE DELETE ON Events_Hour\nFOR EACH ROW BEGIN\n  UPDATE Monitors SET\n  HourEvents = COALESCE(HourEvents,1)-1,\n  HourEventDiskSpace=COALESCE(HourEventDiskSpace,0)-COALESCE(OLD.DiskSpace,0)\n  WHERE Id=OLD.MonitorId;\nEND'
sql_modes=1073741824 1073741824
definers='root@%' 'root@%'
client_cs_names='latin1' 'latin1'
connection_cl_names='latin1_swedish_ci' 'latin1_swedish_ci'
db_cl_names='latin1_swedish_ci' 'latin1_swedish_ci'
created=156400589951 156400589950
