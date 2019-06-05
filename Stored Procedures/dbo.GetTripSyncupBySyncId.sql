SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Rohita Patel>
-- Create date: <Create Date,,27/May/13>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetTripSyncupBySyncId] 	
	@syncId int	
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
  FROM [Trip].[dbo].[TripSyncup]
  WHERE SyncId=@syncId
END
GO
