SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripPassengerCarVendorPreference table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_PasCarVendorPref]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @ID As int,
	 @CarVendorCode As nvarchar(60) ,
	 @CarVendorName As nvarchar(1000) ,
	 @PreferenceNo As nvarchar(100),
	 @ProgramNumber AS nvarchar(100)
	 
AS
BEGIN
 
INSERT INTO TripPassengerCarVendorPreference
			(TripKey, PassengerKey, ID, CarVendorCode, CarVendorName , PreferenceNo, ProgramNumber)
		Values 
			(@TripKey,@PassengerKey,@ID,@CarVendorCode,@CarVendorName ,@PreferenceNo,@ProgramNumber)
                    
END

GO
