SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripPassengerAirVendorPreference table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdateTripForRecord_PasAirVendorPref]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @ID As int,
	 @AirLineCode As nvarchar(60),
	 @AirLineName As nvarchar(100),
	 @PreferenceNo As nvarchar(100),
	 @ProgramNumber As nvarchar(100) 
	 
AS
BEGIN
 
INSERT INTO TripPassengerAirVendorPreference 
			( TripKey, PassengerKey ,ID , AirLineCode,AirLineName ,PreferenceNo , ProgramNumber )
		Values
			( @TripKey, @PassengerKey ,@ID , @AirLineCode,@AirLineName ,@PreferenceNo,@ProgramNumber )
END
GO
