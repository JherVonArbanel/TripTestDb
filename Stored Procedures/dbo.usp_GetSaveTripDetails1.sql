SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*Exec usp_GetSaveTripDetails1 6388,0*/      
CREATE PROCEDURE [dbo].[usp_GetSaveTripDetails1]              
(          
@Tripid INT

)          
as              
BEGIN    

SELECT * FROM trip where tripkey = @tripID 
declare @bookedAir as bit = 0 
declare @bookedCar as bit = 0
declare @bookedHotel as bit = 0  

--select t.tripKey,TA.searchAirPrice,TA.searchAirTax ,TS.airSegmentMarketingAirlineCode,TS.airSegmentOperatingAirlineCode,TS.airSegmentFlightNumber ,TS.airSegmentDepartureDate,
--TS.airSegmentArrivalDate ,TS.airSegmentDepartureAirport,TS.airSegmentArrivalAirport 


--,AVL.shortname as MarketingAirlineName,AVL1.shortname as OperatingAirlineName
--  from Trip T inner join TripAirResponse TA  on T.tripsavedKey=TA.tripGUIDKey
--inner join  TripAirSegments TS ON TA.airresponsekey =TS.airresponsekey 
--LEFT OUTER join AirVendorLookup AVL ON TS.airSegmentMarketingAirlineCode=AVl.airlineCode 
--LEFT OUTER JOIN AirVendorLookup AVL1 On ts.airSegmentOperatingAirlineCode =avl1.AirlineCode 
--where T.tripKey =@Tripid 
 
declare @purchasekey as uniqueidentifier = ( select TripPurchasedkey from trip where tripKey = @Tripid ) 
if ( @purchasekey is not null ) 
BEGIN
if ( SELECT COUNT (*) FROM TripAirResponse where tripGUIDKey = @purchasekey ) > 0 
BEGIN
SET @bookedAir = 1 
 END 
 
 if ( SELECT COUNT (*) FROM TripCarResponse where tripGUIDKey = @purchasekey ) > 0 
BEGIN
SET @bookedCar = 1 
 END 
 
 if ( SELECT COUNT (*) FROM TripHotelResponse where tripGUIDKey = @purchasekey ) > 0 
BEGIN
SET @bookedHotel  = 1 
 END 
END 

select                  
distinct T.tripKey ,    legs.recordLocator   ,        
           searchAirPrice,searchAirTax ,    
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
  as MarketingAirlineName,airSegmentOperatingAirlineCode  ,  AirResp.CurrencyCodeKey as CurrencyCode,              
  ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirlineName 
  
                   
 from TripAirSegments  segments                 
  inner join TripAirLegs legs                 
   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                 
   and segments .airLegNumber = legs .airLegNumber )                
  inner join TripAirResponse   AirResp                 
   on segments .airResponseKey = AirResp .airResponseKey                  
  inner join Trip t on AirResp.tripGUIDKey  = t.tripSavedKey               
   left outer join AirVendorLookup airVen                 
   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                 
  left outer join AirVendorLookup airOperatingVen                 
   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                 
  left outer join AirportLookup departureAirport                 
   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                 
 left outer join AirportLookup arrivalAirport                 
   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                 
  inner join Vault.dbo.GDSSourceLookup G on G.gdsSourceKey = legs.gdsSourceKey  
   
 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0           AND    
              T.tripKey =@Tripid 
              
              
 order by T.tripKey ,segments.tripAirSegmentKey , segments .airSegmentDepartureDate                 
         

SELECT DISTINCT   T.tripKey ,vw.*   From Trip T inner join   
vw_tripHotelResponseDetails VW on  (case when @bookedHotel =1 then t.tripPurchasedKey else tripSavedKey end )=  vw.tripGUIDKey  where t.tripKey = @Tripid 


 
select t.tripKey , vw.*   from Trip T Inner join  vw_tripCarResponseDetails VW on  (case when @bookedHotel =1 then t.tripPurchasedKey else tripSavedKey end )=  vw.tripGUIDKey   
where T.tripKey =@Tripid 


 


 

END
GO
