SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripPassengerHotelPreference table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_PasHotelPref]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @ID As int,
	 @SmokingType As int,
	 @BedType As int
	 
AS
BEGIN
 
INSERT INTO  TripPassengerHotelPreference
			( TripKey, PassengerKey, ID, SmokingType, BedType)
		VALUES
			(@TripKey, @PassengerKey,@ID,@SmokingType,@BedType)
                    
END


GO
