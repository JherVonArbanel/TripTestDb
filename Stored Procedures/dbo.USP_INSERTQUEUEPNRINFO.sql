SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_INSERTQUEUEPNRINFO]
@FirstRecordLocator VARCHAR(10),
@FirstRecordLocatorPosition INT,
@LastRecordLocator VARCHAR(10),
@LastRecordLocatorPosition INT,
@QueueKey INT
AS
	INSERT INTO [QueuePNRHistory]
           ([LastAccessDatetime]
           ,[FirstRecordLocator]
           ,[FirstRecordLocatorPosition]
           ,[LastRecordLocator]
           ,[LastRecordLocatorPosition]
           ,[QueueKey]
           ,[Active])
     VALUES
           (GETDATE()
           ,@FirstRecordLocator
           ,@FirstRecordLocatorPosition
           ,@LastRecordLocator
           ,@LastRecordLocatorPosition
           ,@QueueKey
           ,1)
GO
