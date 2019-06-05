SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <17th Aug 17>
-- Description:	<To Insert Cruise Travelcomponent>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TravelComponent_Cruise_Insert]
	-- Add the parameters for the stored procedure here
	@xmldata XML, @TripPurchaseKey uniqueidentifier, @tripId int
AS
BEGIN
	DECLARE @cruiseResponseKey uniqueidentifier = NEWID()
	
	INSERT INTO TripCruiseResponse(CruiseResponseKey, tripGUIDKey, tripKey, confirmationNumber, recordLocator, tripCruiseTotalPrice, CruiseLineCode,
					ShipCode, SailingDepartureDate, SailingDuration, ArrivalPort, DeparturePort, RegionCode, berthedCategory, shipLocation,
					cabinNbr,deckId)
	SELECT @cruiseResponseKey, @TripPurchaseKey, @tripId,
	  TripCruiseResponse.value('(confirmationNumber/text())[1]','VARCHAR(50)') AS confirmationNumber,
	  TripCruiseResponse.value('(recordLocator/text())[1]','VARCHAR(50)') AS recordLocator,
	  TripCruiseResponse.value('(tripCruiseTotalPrice/text())[1]','float') AS tripCruiseTotalPrice,
	  TripCruiseResponse.value('(CruiseLineCode/text())[1]','VARCHAR(50)') AS CruiseLineCode,
	  TripCruiseResponse.value('(ShipCode/text())[1]','VARCHAR(10)') AS ShipCode,
	  (case when (charindex('-', TripCruiseResponse.value('(SailingDepartureDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripCruiseResponse.value('(SailingDepartureDate/text())[1]','VARCHAR(30)'), 103) 
			else TripCruiseResponse.value('(SailingDepartureDate/text())[1]','datetime') end) AS SailingDepartureDate,
	  TripCruiseResponse.value('(SailingDuration/text())[1]','int') AS SailingDuration,	  
	  TripCruiseResponse.value('(ArrivalPort/text())[1]','VARCHAR(10)') AS ArrivalPort,
	  TripCruiseResponse.value('(DeparturePort/text())[1]','VARCHAR(10)') AS DeparturePort,	  
	  TripCruiseResponse.value('(RegionCode/text())[1]','VARCHAR(10)') AS RegionCode,
	  TripCruiseResponse.value('(berthedCategory/text())[1]','VARCHAR(10)') AS berthedCategory,
	  TripCruiseResponse.value('(shipLocation/text())[1]','VARCHAR(1)') AS shipLocation,
	  TripCruiseResponse.value('(cabinNbr/text())[1]','VARCHAR(10)') AS cabinNbr,
	  TripCruiseResponse.value('(deckId/text())[1]','VARCHAR(50)') AS deckId
	FROM @xmldata.nodes('/Cruise/TripCruiseResponse')AS TEMPTABLE(TripCruiseResponse)
					
END
GO
