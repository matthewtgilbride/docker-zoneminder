TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`%` TRIGGER Zone_Insert_Trigger AFTER INSERT ON Zones\nFOR EACH ROW\n  BEGIN\n    UPDATE Monitors SET ZoneCount=(SELECT COUNT(*) FROM Zones WHERE MonitorId=NEW.MonitorId) WHERE Id=NEW.MonitorID;\n  END' 'CREATE DEFINER=`root`@`%` TRIGGER Zone_Delete_Trigger AFTER DELETE ON Zones\nFOR EACH ROW\n  BEGIN\n    UPDATE Monitors SET ZoneCount=(SELECT COUNT(*) FROM Zones WHERE MonitorId=OLD.MonitorId) WHERE Id=OLD.MonitorID;\n  END'
sql_modes=1073741824 1073741824
definers='root@%' 'root@%'
client_cs_names='latin1' 'latin1'
connection_cl_names='latin1_swedish_ci' 'latin1_swedish_ci'
db_cl_names='latin1_swedish_ci' 'latin1_swedish_ci'
created=156400589968 156400589969
