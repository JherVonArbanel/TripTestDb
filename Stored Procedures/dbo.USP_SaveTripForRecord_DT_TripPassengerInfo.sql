SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripPassengerInfo table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_TripPassengerInfo]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @PassengerTypeKey As int,
	 @IsPrimaryPassenger As bit,
	 @TripRequestKey As int ,
	 @AdditionalRequest As nvarchar(3000)
	 
AS
BEGIN
 
INSERT INTO TripPassengerInfo 
			(TripKey, PassengerKey, PassengerTypeKey, IsPrimaryPassenger, TripRequestKey, AdditionalRequest)
		VALUES 
			(@TripKey,@PassengerKey,@PassengerTypeKey,@IsPrimaryPassenger,@TripRequestKey,@AdditionalRequest)
END


		
GO
