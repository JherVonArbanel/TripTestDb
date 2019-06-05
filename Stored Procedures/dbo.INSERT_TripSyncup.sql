SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Rohita Patel>
-- Create date: <Create Date,,27-05-13>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_TripSyncup]
	@siteKey	int,
	@userId		int,
	@tripId		int,
	@refrenceId	nvarchar(250),
	@tstatus	int,
	@remarks	nvarchar(1000)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [Trip].[dbo].[TripSyncup] ([SiteKey],[UserId],[TripId],[RefrenceId],[Status],[Remarks],[CreatedDate])
	VALUES (@siteKey,@userId,@tripId,@refrenceId,@tstatus,@remarks,getdate()) 					
   
END
GO
