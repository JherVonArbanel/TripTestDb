SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerHotelVendorPref_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@ID INT, 
	@HotelChainCode NVARCHAR(60), 
	@HotelChainName NVARCHAR(1000), 
	@PreferenceNo NVARCHAR(100), 
	@ProgramNumber NVARCHAR(100)
)AS  
  
BEGIN  

	INSERT INTO TripPassengerHotelVendorPreference(TripKey, PassengerKey, ID, HotelChainCode, HotelChainName, PreferenceNo, ProgramNumber)
    VALUES(@TripKey, @PassengerKey, @ID, @HotelChainCode, @HotelChainName, @PreferenceNo, @ProgramNumber) 
   
END  
GO
