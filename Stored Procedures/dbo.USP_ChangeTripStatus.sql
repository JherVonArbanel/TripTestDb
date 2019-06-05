SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author:Richa Shah>
-- Create date: <Create Date,17/8/2011>
-- Description:	<Description,Stored procedure to change the status of held trips to cancelled if it has been created for more then 24hrs and its current status is "Held">
-- =============================================
CREATE PROCEDURE [dbo].[USP_ChangeTripStatus] 

	
AS
BEGIN
	update Trip set tripStatusKey=5 where DATEDIFF(HH,CreatedDate,getdate())>24 and tripStatusKey=7
	--select * from Trip
	--select tripName,tripStatusKey,CreatedDate from Trip where DATEDIFF(HH,CreatedDate,getdate())>24 and tripStatusKey=7
	
END
GO
