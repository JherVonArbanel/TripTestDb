SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Rohita Patel>
-- Create date: <Create Date,,27/May/13>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripSyncupByUserId] 	
	@userId int	
AS
BEGIN	
	
	SET NOCOUNT ON;   
	
	SELECT [SyncId]
      ,[SiteKey]
      ,[UserId]
      ,[TripId]
      ,[TripName]
      ,[RefrenceId]
      ,[Status]
      ,[Origin]
      ,[Destination]
      ,[StartDate]
      ,[EndDate]
      ,[Remarks]
      ,[CreatedDate]
      ,[TripCreatedDate]
      ,[TripStatus]      
  FROM [Trip].[dbo].[TripSyncup]
  WHERE userId=@userId --and [status]=1
END
GO
