SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Update Trip table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdateTripForRecord_UpdateTrip]
	 @TripStatusKey As int ,
	 @TripKey As int ,
	 @TripRequestKey As int
	 
AS
BEGIN
 
Update Trip 
		Set 
			tripStatusKey	= @TripStatusKey 
		where 
			tripKey			= @TripKey and 
			tripRequestKey	= @TripRequestKey

END


GO
