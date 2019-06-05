SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <17th Aug 17>
-- Description:	<To Insert Rail Travelcomponent>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TravelComponent_Rail_Insert]
	-- Add the parameters for the stored procedure here
	@xmldata XML, @TripPurchaseKey uniqueidentifier, @tripId int, @TripPassenger SavePurchaseTrip_TripPassenger Readonly
AS
BEGIN
	DECLARE @railResponseKey uniqueidentifier = NEWID()
	
	INSERT INTO TripRailResponse(RailResponseKey, tripGUIDKey, tripKey, TripPassengerInfoKey, VendorCode, supplierId, [Type], OriginLocationCode, 
									DestinationLocationCode, TrainNumber, BaseFare, Taxes, Commission, TotalPrice, DepartureDate, ArrivalDate, DepartureTime,
									ArrivalTime, ConfirmationNumber, InvoiceNumber, RecordLocator, [status], LinkCode, [Text], NoOfAdult,  RPH, creationDate)
    
	SELECT @railResponseKey, @TripPurchaseKey, @tripId, P.TripPassengerInfoKey,
	  TripRailResponse.value('(VendorCode/text())[1]','VARCHAR(10)') AS VendorCode,
	  TripRailResponse.value('(supplierId/text())[1]','VARCHAR(50)') AS supplierId,
	  TripRailResponse.value('(Type/text())[1]','VARCHAR(20)') AS [Type],
	  TripRailResponse.value('(OriginLocationCode/text())[1]','VARCHAR(50)') AS OriginLocationCode,
	  TripRailResponse.value('(DestinationLocationCode/text())[1]','VARCHAR(50)') AS DestinationLocationCode,
	  TripRailResponse.value('(TrainNumber/text())[1]','VARCHAR(100)') AS TrainNumber,
	  TripRailResponse.value('(BaseFare/text())[1]','float') AS BaseFare,
	  TripRailResponse.value('(Taxes/text())[1]','float') AS Taxes,
	  TripRailResponse.value('(Commission/text())[1]','float') AS Commission,
	  TripRailResponse.value('(TotalPrice/text())[1]','float') AS TotalPrice,
	  (case when (charindex('-', TripRailResponse.value('(DepartureDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripRailResponse.value('(DepartureDate/text())[1]','VARCHAR(30)'), 103) 
			else TripRailResponse.value('(DepartureDate/text())[1]','datetime') end) AS DepartureDate,
	  (case when (charindex('-', TripRailResponse.value('(ArrivalDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripRailResponse.value('(ArrivalDate/text())[1]','VARCHAR(30)'), 103) 
			else TripRailResponse.value('(ArrivalDate/text())[1]','datetime') end) AS ArrivalDate,
	  (case when (charindex('-', TripRailResponse.value('(DepartureTime/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripRailResponse.value('(DepartureTime/text())[1]','VARCHAR(30)'), 103) 
			else TripRailResponse.value('(DepartureTime/text())[1]','datetime') end) AS DepartureTime,
	  (case when (charindex('-', TripRailResponse.value('(ArrivalTime/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripRailResponse.value('(ArrivalTime/text())[1]','VARCHAR(30)'), 103) 
			else TripRailResponse.value('(ArrivalTime/text())[1]','datetime') end) AS ArrivalTime,
	  TripRailResponse.value('(confirmationNumber/text())[1]','VARCHAR(100)') AS confirmationNumber,
	  TripRailResponse.value('(InvoiceNumber/text())[1]','VARCHAR(20)') AS InvoiceNumber,
	  TripRailResponse.value('(recordLocator/text())[1]','VARCHAR(100)') AS recordLocator,
	  TripRailResponse.value('(status/text())[1]','VARCHAR(10)') AS [status],
	  TripRailResponse.value('(LinkCode/text())[1]','VARCHAR(10)') AS LinkCode,
	  TripRailResponse.value('(Text/text())[1]','VARCHAR(5000)') AS [Text],
	  TripRailResponse.value('(NoOfAdult/text())[1]','int') AS NoOfAdult,	  
	  TripRailResponse.value('(RPH/text())[1]','VARCHAR(2)') AS RPH,
	  GETDATE()
	FROM @xmldata.nodes('/Rail/TripRailResponse')AS TEMPTABLE(TripRailResponse)
		left outer join (select top 1 * from @TripPassenger) P on TripRailResponse.value('(TripPassengerInfoKey/text())[1]','int') = P.PassengerKey
					
END
GO
