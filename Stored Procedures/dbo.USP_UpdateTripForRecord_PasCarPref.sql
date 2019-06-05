SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripPassengerCarPreference table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdateTripForRecord_PasCarPref]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @ID As int
	 
AS
BEGIN
 
INSERT INTO TripPassengerCarPreference
			(TripKey ,PassengerKey , ID)
		VALUES
			(@TripKey,@PassengerKey ,@ID)
                    
END


GO
