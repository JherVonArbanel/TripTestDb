SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*Exec USP_GetWatchTripDetailsByResponseID1 'BA5AD8E5-DA7D-4B7A-83AE-486A419D29E2','62AE286D-F0E5-4660-AB13-F32091AE94B4','3307CAED-FAA7-487B-B6AA-0630FA8F6B40'*/        
CREATE PROCEDURE [dbo].[USP_GetWatchTripDetailsByResponseID1]                
(            
 @airResponsekey VARCHAR(2000) ,              
 @HotelResponsekey VARCHAR(2000) ,              
 @CarResponsekey VARCHAR(2000) 
)            
AS                
BEGIN              
	DECLARE @Air AS TABLE(airResponsekey VARCHAR(200))
	DECLARE @Hotel AS TABLE(hotelResponsekey VARCHAR(200))
	DECLARE @Car AS TABLE(carResponsekey VARCHAR(200))

	IF (@airResponsekey IS NOT NULL)
	BEGIN
	INSERT INTO @Air  select * From ufn_CSVSplitString(@airResponsekey) 
	END
	  
	IF (@hotelResponsekey IS NOT NULL)
	BEGIN
	INSERT INTO @Hotel  select * From ufn_CSVSplitString(@hotelResponsekey) 
	END

	IF (@carResponsekey IS NOT NULL)
	BEGIN
	INSERT INTO @Car  select * From ufn_CSVSplitString(@carResponsekey) 
	END

    /* Air */          
	SELECT                  
		segments.tripAirSegmentKey,        
		segments.airSegmentKey,        
		segments.tripAirLegsKey,        
		segments.airResponseKey,        
		segments.airLegNumber,        
		segments.airSegmentMarketingAirlineCode,        
		segments.airSegmentOperatingAirlineCode,        
		segments.airSegmentFlightNumber,        
		segments.airSegmentDuration,        
		segments.airSegmentEquipment,        
		segments.airSegmentMiles,        
		segments.airSegmentDepartureDate,        
		segments.airSegmentArrivalDate,        
		segments.airSegmentDepartureAirport,        
		segments.airSegmentArrivalAirport,        
		segments.airSegmentResBookDesigCode,        
		segments.airSegmentDepartureOffset,        
		segments.airSegmentArrivalOffset,        
		segments.airSegmentSeatRemaining,        
		segments.airSegmentMarriageGrp,        
		segments.airFareBasisCode,        
		segments.airFareReferenceKey,        
		segments.airSelectedSeatNumber,        
		segments.ticketNumber,        
		segments.airsegmentcabin,        
		segments.recordLocator as SegRecordLocator,           
		legs.gdsSourceKey ,                
		departureAirport.AirportName  as departureAirportName ,                
		departureAirport.CityCode as departureAirportCityCode,
		departureAirport.CityName as departureAirportCityName,
		departureAirport.StateCode   as departureAirportStateCode,                 
		departureAirport.CountryCode as departureAirportCountryCode,                
		arrivalAirport.AirportName  as arrivalAirportName ,
		arrivalAirport.CityCode as arrivalAirportCityCode,
		arrivalAirport.CityName as arrivalAirportCityName,                
		arrivalAirport.StateCode  as arrivalAirportStateCode ,
		arrivalAirport.CountryCode as arrivalAirportCountryCode,                
		legs.recordLocator , AirResp.actualAirPrice ,
		AirResp.actualAirTax ,
		AirResp.airResponseKey ,
		ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode) AS MarketingAirLine,airSegmentOperatingAirlineCode,
		AirResp.CurrencyCodeKey AS CurrencyCode,              
		ISNULL (airOperatingven.ShortName,
		segments.airSegmentOperatingAirlineCode ) AS OperatingAirLine,                
		ISNULL(airSelectedSeatNumber,0) AS SeatNumber,
		segments.ticketNumber AS TicketNumber ,
		segments.airsegmentcabin AS airsegmentcabin,
		AirResp.isExpenseAdded,            
		segments.airSegmentOperatingFlightNumber ,
		airresp.bookingcharges,        
		ISNULL(seatMapStatus,'') AS seatMapStatus, 
		legs.ValidatingCarrier,
		legs.isrefundable,legs.contractcode  
	FROM TripAirSegments  segments                 
	INNER JOIN TripAirLegs legs                 
	ON ( segments .tripAirLegsKey = legs .tripAirLegsKey AND segments .airLegNumber = legs .airLegNumber )                
	INNER JOIN TripAirResponse   AirResp                 
	ON segments .airResponseKey = AirResp .airResponseKey
	INNER JOIN @Air tempAir ON AirResp.airResponsekey = tempAir.airresponsekey                  
	LEFT OUTER JOIN AirVendorLookup airVen                 
	ON segments.airSegmentMarketingAirlineCode = airVen .AirlineCode                 
	LEFT OUTER JOIN AirVendorLookup airOperatingVen                 
	ON segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                 
	LEFT OUTER JOIN AirportLookup departureAirport                 
	ON departureAirport .AirportCode = segments .airSegmentdepartureAirport                 
	LEFT OUTER JOIN AirportLookup arrivalAirport                 
	ON arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                 
	WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0               
	ORDER BY segments.tripAirSegmentKey , segments .airSegmentDepartureDate                 
    /*END*/
    
    /*Hotel*/
    SELECT hotel.*
    FROM vw_TripHotelResponse hotel                  
    INNER JOIN @Hotel tempHotel ON hotel.HotelResponseKey = tempHotel.HotelResponseKey
    /*END*/

	/*Car*/
	SELECT car.* 
	FROM vw_TripCarResponse car 
    INNER JOIN @Car tempCar ON car.carResponseKey = tempCar.carResponseKey
 	/*END*/


END
GO
