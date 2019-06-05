SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerCarPref_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@ID INT
)AS  
  
BEGIN  

	INSERT INTO TripPassengerCarPreference(TripKey, PassengerKey, ID) 
	VALUES(@TripKey, @PassengerKey, @ID) 
   
END  
GO
