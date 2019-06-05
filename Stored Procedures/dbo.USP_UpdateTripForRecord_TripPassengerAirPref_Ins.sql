SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerAirPref_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@ID INT, 
	@OriginAirportCode NVARCHAR(60), 
	@TicketDelivery NVARCHAR(100), 
	@AirSeatingType INT, 
	@AirRowType INT, 
	@AirMealType INT, 
	@AirSpecialSevicesType INT
)AS  
  
BEGIN  

	INSERT INTO TripPassengerAirPreference(TripKey, PassengerKey, ID, OriginAirportCode, TicketDelivery, AirSeatingType, 
				AirRowType, AirMealType, AirSpecialSevicesType)
	VALUES(@TripKey, @PassengerKey, @ID, @OriginAirportCode, @TicketDelivery, @AirSeatingType, 
				@AirRowType, @AirMealType, @AirSpecialSevicesType) 
   
END  

GO
