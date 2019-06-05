SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripPassengerAirPreference table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_PasAirPre]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @ID As int,
	 @OriginAirportCode As nvarchar(60),
	 @TicketDelivery As nvarchar(100),
	 @AirSeatingType As int,
	 @AirRowType As int ,
	 @AirMealType As int ,
	 @AirSpecialSevicesType As int 
	 
AS
BEGIN
 
INSERT INTO  TripPassengerAirPreference 
			( TripKey , PassengerKey , ID , OriginAirportCode , TicketDelivery 
			, AirSeatingType , AirRowType  , AirMealType , AirSpecialSevicesType )
		Values
			(@TripKey ,@PassengerKey , @ID ,@OriginAirportCode ,@TicketDelivery 
			,@AirSeatingType ,@AirRowType ,@AirMealType ,@AirSpecialSevicesType )
END
GO
