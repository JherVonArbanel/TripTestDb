SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoSabre_TripPassengerAirPref_Ins]
(  
	@TripKey INT,
	@AirMealType INT, 
	@airsegmentKey UNIQUEIDENTIFIER
	
)
AS  
  
BEGIN  

	INSERT INTO TripPassengerAirPreference(TripKey, AirMealType, airsegmentKey) 
	VALUES (@TripKey, @AirMealType, @airsegmentKey)
 
END  

GO
