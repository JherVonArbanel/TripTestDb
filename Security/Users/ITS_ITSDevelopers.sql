IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ITS\ITSDevelopers')
CREATE LOGIN [ITS\ITSDevelopers] FROM WINDOWS
GO
CREATE USER [ITS\ITSDevelopers] FOR LOGIN [ITS\ITSDevelopers]
GO
