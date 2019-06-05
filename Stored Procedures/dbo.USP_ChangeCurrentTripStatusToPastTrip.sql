SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author:Richa Shah>
-- Create date: <Create Date,17/8/2011>
-- Description:	<Description,Stored procedure to change current trip status to past trips if end date is less than today's date >
-- =============================================
CREATE PROCEDURE [dbo].[USP_ChangeCurrentTripStatusToPastTrip] 

	
AS
BEGIN
	update Trip set tripStatusKey=4 where endDate<GETDATE() and tripStatusKey=2
	--select * from Trip
	--select tripName,tripStatusKey,CreatedDate,endDate from Trip where endDate<GETDATE() and tripStatusKey=2
	
END
GO
