IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ITS\nhawkins')
CREATE LOGIN [ITS\nhawkins] FROM WINDOWS
GO
CREATE USER [ITS\nhawkins] FOR LOGIN [ITS\nhawkins]
GO
