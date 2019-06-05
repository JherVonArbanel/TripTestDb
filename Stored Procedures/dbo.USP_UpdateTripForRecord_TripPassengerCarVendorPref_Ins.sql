SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerCarVendorPref_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@ID INT,
	@CarVendorCode NVARCHAR(60), 
	@CarVendorName NVARCHAR(1000), 
	@PreferenceNo NVARCHAR(100), 
	@ProgramNumber NVARCHAR(100)
)AS  
  
BEGIN  

	INSERT INTO TripPassengerCarVendorPreference(TripKey, PassengerKey, ID, CarVendorCode, CarVendorName, PreferenceNo, ProgramNumber) 
	VALUES(@TripKey, @PassengerKey, @ID, @CarVendorCode, @CarVendorName, @PreferenceNo, @ProgramNumber) 
   
END  
GO
