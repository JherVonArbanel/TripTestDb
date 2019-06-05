SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Rohita Patel>
-- Create date: <Create Date,,27/May/13>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetTripSyncupByRefrenceId] 	
	@refrenceId NVARCHAR(250)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT [SyncId]
      ,[SiteKey]
      ,[UserId]
      ,[TripId]
      ,[RefrenceId]
      ,[Status]
      ,[Remarks]
  FROM [Trip].[dbo].[TripSyncup]
  WHERE RefrenceId=@refrenceId
END
GO
