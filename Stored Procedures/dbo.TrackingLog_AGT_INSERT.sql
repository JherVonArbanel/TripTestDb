SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TrackingLog_AGT_INSERT] 
(  		
		
		@trackingID int,
		@activityDone nvarchar(500),
		@logDescription nvarchar(1000),
		@timeStamp datetime,
		@activityDoneBy int,
		@fixed nchar(100),
		@callerId int,
		@callerLastName nchar(100),
		@callerEmailId nchar(200),
		@callerPNR nchar(200),
		@new_identity    INT    OUTPUT	
		
) 
AS 
BEGIN 

	INSERT INTO [Agent].[dbo].[TrackingLog]
           ([TrackingID]
           ,[ActivityDone]
           ,[LogDescription]
           ,[TimeStamp]
           ,[ActivityDoneBy]
           ,[Fixed]
           ,[CallerId]
           ,[CallerLastName]
           ,[CallerEmailId]
           ,[CallerPNR])
     VALUES
           (@trackingID
           ,@activityDone
           ,@logDescription
           ,@timeStamp
           ,@activityDoneBy
           ,@fixed
           ,@callerId
           ,@callerLastName
           ,@callerEmailId
           ,@callerPNR)
          
         SET @new_identity = @@IDENTITY 

END
GO
