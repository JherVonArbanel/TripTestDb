SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Rohita Patel>
-- Create date: <Create Date,,27-05-13>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_TripSyncup_UPDATE]
	@tripSyncId int,
	@siteKey	int,
	@tstatus	int,	
	@remarks	nvarchar(1000)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [Trip].[dbo].[TripSyncup] 
	SET [Status]=@tstatus,[Remarks]=@remarks
	WHERE SyncId=@tripSyncId AND SiteKey=@siteKey
   
END
GO
