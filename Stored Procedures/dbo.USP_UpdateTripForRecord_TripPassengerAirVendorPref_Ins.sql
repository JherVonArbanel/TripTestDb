SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerAirVendorPref_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@ID INT, 
	@AirLineCode NVARCHAR(60), 
	@AirLineName NVARCHAR(100), 
	@PreferenceNo NVARCHAR(100), 
	@ProgramNumber NVARCHAR(100)
)AS  
  
BEGIN  

	INSERT INTO TripPassengerAirVendorPreference(TripKey, PassengerKey, ID, AirLineCode, AirLineName, PreferenceNo, ProgramNumber) 
	VALUES(@TripKey, @PassengerKey, @ID, @AirLineCode, @AirLineName, @PreferenceNo, @ProgramNumber) 
   
END  

GO
