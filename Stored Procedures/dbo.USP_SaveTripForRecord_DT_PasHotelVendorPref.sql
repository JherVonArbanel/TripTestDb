SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripPassengerHotelVendorPreference table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_PasHotelVendorPref]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @ID As int,
	 @HotelChainCode As nvarchar(60),
	 @HotelChainName As nvarchar(1000),
	 @PreferenceNo As nvarchar(100),
	 @ProgramNumber As nvarchar(100)
	 
AS
BEGIN
 
INSERT INTO TripPassengerHotelVendorPreference
			( TripKey, PassengerKey, ID, HotelChainCode, HotelChainName, PreferenceNo, ProgramNumber)
		Values
			( @TripKey,@PassengerKey,@ID,@HotelChainCode, @HotelChainName, @PreferenceNo, @ProgramNumber)
                    
END


		
GO
