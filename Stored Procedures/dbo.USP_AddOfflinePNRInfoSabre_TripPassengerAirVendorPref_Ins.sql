SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoSabre_TripPassengerAirVendorPref_Ins]  
(    
	@TripKey INT,  
	@PassengerKey INT,  
	@ID INT, 
	@AirLineCode NVARCHAR(30), 
	@AirLineName NVARCHAR(50), 
	@PreferenceNo NVARCHAR(50), 
	@ProgramNumber NVARCHAR(50)
)
AS 
    
BEGIN    
  
	INSERT INTO TripPassengerAirVendorPreference(TripKey, PassengerKey, ID, AirLineCode, AirLineName, PreferenceNo, ProgramNumber)
	Values( @TripKey, @PassengerKey, @ID, @AirLineCode, @AirLineName, @PreferenceNo, @ProgramNumber)
	
	SELECT Scope_Identity()  
   
END    
  
GO
