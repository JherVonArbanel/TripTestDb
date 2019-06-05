SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*Exec [USP_GetTripSavedDealCart1]  6289 ,getdate(),0*/      
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealCart1]              
(          
 @tripKey int,
 @tripDate date,
 @userId int = 0 
)          
as              
BEGIN    
---for yesterday search start here---

--declare @tripID AS INT  = ( Select top 1 tripkey from TripSavedDeals where TripSavedDealKey in  (select top 1 * from ufn_CSVSplitString(@NightlyDealKey)))
declare @airnewPrice float =0
declare @hotelnewPrice float =0
declare @carnewPrice float =0
SELECT * FROM Trip where tripKey  = @tripKey  
declare @saveTripKey as uniqueidentifier 
set @saveTripKey  = (select TripSavedkey from trip where tripKey = @tripKey)


select @airnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals]  where [tripKey]= @tripKey and [componentType]= 1 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)
--select TND.tripKey, TND.ResponseKey, ar.airPriceBase, ar.airPriceTax, airSeg.airSegmentMarketingAirlineCode, airSeg.airSegmentOperatingAirlineCode, airSeg.airSegmentFlightNumber, airSeg.airSegmentDepartureDate, airSeg.airSegmentArrivalDate, airseg.airSegmentDepartureAirport, airSeg.airSegmentArrivalAirport, avl.shortname as MarketingAirlineName,avl2.shortname as OperatingAirlineName
--from TripSavedDeals TND INNER Join AirResponse AR on AR.airResponseKey = TND.ResponseKey INNER JOIN AirSegments airSeg on airSeg.airResponseKey = AR.airResponseKey Left outer JOIN AirVendorLookup avl on avl.AirLineCode = airSeg.airSegmentMarketingAirlineCode   Left outer JOIN AirVendorLookup avl2 on avl2.AirLineCode = airSeg.airSegmentOperatingAirlineCode  
----Where TND.TripSavedDealKey  in (select * from ufn_CSVSplitString(@NightlyDealKey))
--Where TND.TripSavedDealKey  in (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate and [componentType]= 1 )
declare @purchasekey as uniqueidentifier = ( select TripPurchasedkey from trip where tripKey = @tripKey and userKey  =  @userId ) 
declare @date as datetime  = ( select CreatedDate  from trip where tripKey = @tripKey ) 

if ( select COUNT(*) from TripAirResponse where tripGUIDKey = @purchasekey )> 0 
BEGIN
  

select                  
distinct AirResp.airResponseKey  , legs.recordLocator       ,     
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
            
     ,legs.gdsSourceKey ,     legs.contractCode,           
   departureAirport.AirportName  as departureAirportName ,                
   departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode                 
   ,departureAirport.CountryCode as departureAirportCountryCode,                
  arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,                
  arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,                
  legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax ,AirResp.airResponseKey ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )                
  as MarketingAirlineName,airSegmentOperatingAirlineCode  ,  AirResp.CurrencyCodeKey as CurrencyCode,              
  ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirlineName , 0 Savings,
  TAP.*
  ,  @date as dealDate
                   
 from TripAirSegments  segments WITH(NOLOCK)                  
  inner join TripAirLegs legs          WITH(NOLOCK)        
   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                 
   and segments .airLegNumber = legs .airLegNumber )                
  inner join TripAirResponse   AirResp                 
   on segments .airResponseKey = AirResp .airResponseKey   
   left outer join TripAirPrices TAP on AirResp.actualAirPriceBreakupKey = TAP.tripAirPriceKey               
   left outer join AirVendorLookup airVen                 
   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                 
  left outer join AirVendorLookup airOperatingVen                 
   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                 
  left outer join AirportLookup departureAirport                 
   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                 
 left outer join AirportLookup arrivalAirport                 
   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                 
   
 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0           AND    
    tripGUIDKey = @purchasekey 
              
 order by    segments.tripAirSegmentKey , segments .airSegmentDepartureDate      
END
ELSE 
BEGIN
declare @dealKey as bigint = (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate and [componentType]= 1)
declare @originalAirPrice as decimal ( 18,2) 
 declare @searchAirPrice as decimal ( 18,2) 
 declare @searchAirTax as decimal ( 18,2)  
 

SELECT  
@searchAirPrice =(( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  )
,@searchAirTax =(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )  )
 from TripAirPrices TAP
inner join TripAirResponse TR on TAP.tripAirPriceKey = TR.searchAirPriceBreakupKey 
inner join Trip T on TR.tripGUIDKey = T.tripSavedKey  where t.tripKey = @tripKey 
 

SET @originalAirPrice = ( select top 1 convert(decimal ( 18,2) ,(@searchAirPrice + @searchAirTax))  

 from TripAirResponse 
  
  where tripGUIDKey =@saveTripKey ) 

select                  
distinct AirResp.airResponseKey  , legs.recordLocator     ,
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
            
     ,legs.gdsSourceKey ,            legs. contractCode   ,
   departureAirport.AirportName  as departureAirportName ,                
   departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode                 
   ,departureAirport.CountryCode as departureAirportCountryCode,                
  arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,                
  arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,                
  legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax ,AirResp.airResponseKey ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )                
  as MarketingAirlineName,airSegmentOperatingAirlineCode  ,  AirResp.CurrencyCodeKey as CurrencyCode,              
  ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirlineName , convert(decimal ( 18,2) ,((searchAirPrice+ searchAirTax )- isnull(@originalAirPrice ,0))) as Savings,TAP.*, TND.creationDate as dealDate
  
                   
 from TripAirSegments  segments                 
  inner join TripAirLegs legs                 
   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                 
   and segments .airLegNumber = legs .airLegNumber )                
  inner join TripAirResponse   AirResp                 
   on segments .airResponseKey = AirResp .airResponseKey   
    left outer join TripAirPrices TAP on AirResp.searchAirPriceBreakupKey = TAP.tripAirPriceKey                     
   left outer join AirVendorLookup airVen                 
   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                 
  left outer join AirVendorLookup airOperatingVen                 
   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                 
  left outer join AirportLookup departureAirport                 
   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                 
 left outer join AirportLookup arrivalAirport                 
   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                 
   inner join     TripSavedDeals TND  on airresp.airResponseKey = tnd.responseKey 
 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0           AND    
      TND.TripSavedDealKey  =@dealKey
              
 order by    segments.tripAirSegmentKey , segments .airSegmentDepartureDate                 
         
END

select @hotelnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals]  where [tripKey]= @tripKey and [componentType]= 4 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)
if ( select COUNT(*) from TripHotelResponse where tripGUIDKey = @purchasekey )> 0 
BEGIN 
select DISTINCT top 1   vw.*,  0 as Savings,    @date as dealDate

 from    vw_tripHotelResponseDetails vw INNER JOIN Trip T on vw.tripGUIDKey  = T.tripPurchasedKey 
--LEFT OUTER JOIN 
--HotelResponseDetail HD on TND.responseDetailKey =HD.hotelResponseDetailKey 
Where T.tripPurchasedKey = @purchasekey 

END
ELSE 
BEGIN 
declare @originalHotelPrice as decimal ( 18,2) 
SET @originalHotelPrice = ( select  top 1 convert(decimal ( 18,2) ,(hotelTotalPrice + hotelTaxRate)) from TripHotelResponse  where tripGUIDKey =@saveTripKey ) 
print ( @originalHotelPrice)
select DISTINCT top 1 TND.tripKey, vw.*,  Convert(decimal ( 18,2) , (hotelTotalPrice + hotelTaxRate)) -  (@originalHotelPrice )  as Savings ,TND.creationDate as dealDate 
 from TripSavedDeals TND  
INNER JOIN  vw_tripHotelResponseDetails vw on TND.ResponseKey = vw.hotelResponseKey 
--LEFT OUTER JOIN 
--HotelResponseDetail HD on TND.responseDetailKey =HD.hotelResponseDetailKey 
Where TND.TripSavedDealKey  in (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate  and [componentType]= 4)
END


select @carnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals]  where [tripKey]= @tripKey and [componentType]= 2 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)
if ( select COUNT(*) from TripCarResponse where tripGUIDKey = @purchasekey )> 0 
BEGIN 
select distinct T.tripKey, vw.*  , 0 as Savings , @date as dealDate from vw_tripCarResponseDetails vw INNER JOIN Trip T  on vw.tripGUIDKey = T.tripPurchasedKey Where T.tripPurchasedKey = @purchasekey  
END 
ELSE 
BEGIN 

declare @originalCarPrice as decimal ( 18,2) 
SET @originalCarPrice = ( select top 1 convert(decimal ( 18,2),(  SearchCarPrice + searchCarTax))   from TripcarResponse  where tripGUIDKey =@saveTripKey ) 

select distinct TND.tripKey, vw.*  ,  convert(decimal ( 18,2) ,(isnull((minRate * NoOfDays ) + searchCarTax   ,0)- isnull((@originalCarPrice) ,0))) as Savings ,TND.creationDate as dealDate  from TripSavedDeals TND 
INNER JOIN  vw_tripCarResponseDetails vw on TND.responseKey  = vw.carResponseKey 
Where TND.TripSavedDealKey  in (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate  and [componentType]= 2)
 END 

 

 
END
GO
