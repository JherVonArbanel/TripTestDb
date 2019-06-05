SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[usp_AuctionGetAirResponse]
(
	@tripID   int         
)
AS
BEGIN

	DECLARE @tblTrip as table        
	(        
	 tripKey int,        
	 RequestKey int        
	) 

	INSERT Into @tblTrip        
	 Select  @tripID  ,   tripRequestKey  from Trip where tripKey  = @tripID     
	        
	select            
		distinct T.tripKey ,        
	         
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
		segments.recordLocator as SegRecordLocator     	      
		,legs.gdsSourceKey ,          
		departureAirport.AirportName  as departureAirportName ,          
		departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode           
		,departureAirport.CountryCode as departureAirportCountryCode,          
		arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,          
		arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,          
		legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax ,AirResp.airResponseKey ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )          
		as MarketingAirLine,airSegmentOperatingAirlineCode  ,  AirResp.CurrencyCodeKey as CurrencyCode,        
		ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirLine,          
		isnull(airSelectedSeatNumber,0)  as SeatNumber  , segments.ticketNumber as TicketNumber ,segments.airsegmentcabin as airsegmentcabin    ,AirResp.isExpenseAdded,      
		ISNULL(t.deniedReason,'') as deniedReason, t.CreatedDate       , segments.airSegmentOperatingFlightNumber ,airresp.bookingcharges  
		,ISNULL(seatMapStatus,'') AS seatMapStatus, AirResp.ValidatingCarrier  
	           	          	           
	 from TripAirSegments  segments           
	  inner join TripAirLegs legs           
	   on ( segments .tripAirLegsKey = legs .tripAirLegsKey 
	and segments .airLegNumber = legs .airLegNumber  )          
	  inner join TripAirResponse   AirResp           
	   on segments .airResponseKey = AirResp .airResponseKey            
	  inner join Trip t on AirResp.tripKey = t.tripKey         
	Inner join @tblTrip tt on tt.tripKey = t.tripKey         
	  left outer join AirVendorLookup airVen           
	   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode           
	  left outer join AirVendorLookup airOperatingVen           
	   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode           
	  left outer join AirportLookup departureAirport           
	   on departureAirport .AirportCode = segments .airSegmentdepartureAirport           
	 left outer join AirportLookup arrivalAirport           
	   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport           	  
	 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0         	        
	 order by T.tripKey ,segments.tripAirSegmentKey , segments .airSegmentDepartureDate   
END	 
GO
