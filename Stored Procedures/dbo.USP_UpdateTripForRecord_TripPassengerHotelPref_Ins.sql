SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerHotelPref_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@ID INT, 
	@SmokingType INT, 
	@BedType INT
)AS  
  
BEGIN  

	INSERT INTO TripPassengerHotelPreference(TripKey, PassengerKey, ID, SmokingType, BedType) 
	VALUES(@TripKey, @PassengerKey, @ID, @SmokingType, @BedType) 
   
END  
GO
