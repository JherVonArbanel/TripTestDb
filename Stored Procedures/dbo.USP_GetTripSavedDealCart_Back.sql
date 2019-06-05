SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*Exec [USP_GetTripSavedDealCart1]  6289 ,getdate(),0*/      
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealCart_Back]              
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
Declare @deals as Table (dealKey int , componentType int)

select @airnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals]  WITH(NOLOCK)   where [tripKey]= @tripKey and [componentType]= 1 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)
 declare @purchasekey as uniqueidentifier = ( select TripPurchasedkey from trip WITH(NOLOCK)   where tripKey = @tripKey and userKey  =  @userId ) 
declare @date as datetime  = ( select CreatedDate  from trip WITH(NOLOCK) where tripKey = @tripKey ) 

if ( select COUNT(*) from TripAirResponse WITH(NOLOCK)  where tripGUIDKey = @purchasekey )> 0 
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
                   
 from TripAirSegments  segments    WITH(NOLOCK)                
  inner join TripAirLegs legs   WITH(NOLOCK)                 
   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                 
   and segments .airLegNumber = legs .airLegNumber )                
  inner join TripAirResponse   AirResp  WITH(NOLOCK)                  
   on segments .airResponseKey = AirResp .airResponseKey   
   left outer join TripAirPrices TAP WITH(NOLOCK)   on AirResp.actualAirPriceBreakupKey = TAP.tripAirPriceKey               
   left outer join AirVendorLookup airVen    WITH(NOLOCK)                
   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                 
  left outer join AirVendorLookup airOperatingVen  WITH(NOLOCK)                  
   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                 
  left outer join AirportLookup departureAirport   WITH(NOLOCK)                 
   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                 
 left outer join AirportLookup arrivalAirport   WITH(NOLOCK)                 
   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                 
   
 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0           AND    
    tripGUIDKey = @purchasekey 
              
 order by    segments.tripAirSegmentKey , segments .airSegmentDepartureDate      
END
ELSE 
BEGIN
declare @dealKey as bigint = (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK) where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate and [componentType]= 1)
declare @originalAirPrice as decimal ( 18,2) 
 declare @searchAirPrice as decimal ( 18,2) 
 declare @searchAirTax as decimal ( 18,2)  
 
SELECT  
@searchAirPrice =(( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  )
,@searchAirTax =(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )  )
 from TripAirPrices TAP WITH(NOLOCK)   
inner join TripAirResponse TR WITH(NOLOCK)    on TAP.tripAirPriceKey = TR.searchAirPriceBreakupKey 
inner join Trip T WITH(NOLOCK)    on TR.tripGUIDKey = T.tripSavedKey  where t.tripKey = @tripKey 
 

SET @originalAirPrice = ( select top 1 convert(decimal ( 18,2) ,(@searchAirPrice + @searchAirTax))  

 from TripAirResponse 
  
  where tripGUIDKey =@saveTripKey ) 
 
 
select                  
distinct AirResp.airResponseKey  , legs.recordLocator     ,
        (( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  )   searchAirPrice,
(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )  ) searchAirTax ,    
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
  ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirlineName , convert(decimal ( 18,2) ,(((( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  )+(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) + 
( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )  ) )- isnull(@originalAirPrice ,0))) as Savings,TAP.*, TND.creationDate as dealDate
  
                   
 from TripAirSegments  segments       WITH(NOLOCK)             
  inner join TripAirLegs legs     WITH(NOLOCK)               
   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                 
   and segments .airLegNumber = legs .airLegNumber )                
  inner join TripAirResponse   AirResp  WITH(NOLOCK)                  
   on segments .airResponseKey = AirResp .airResponseKey   
    left outer join TripAirPrices TAP WITH(NOLOCK)    on AirResp.searchAirPriceBreakupKey = TAP.tripAirPriceKey                     
   left outer join AirVendorLookup airVen    WITH(NOLOCK)                
   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                 
  left outer join AirVendorLookup airOperatingVen  WITH(NOLOCK)                  
   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                 
  left outer join AirportLookup departureAirport  WITH(NOLOCK)                  
   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                 
 left outer join AirportLookup arrivalAirport   WITH(NOLOCK)                 
   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                 
   inner join     TripSavedDeals TND WITH(NOLOCK)    on airresp.airResponseKey = tnd.responseKey 
   inner join Trip T WITH(NOLOCK)    on TND.tripKey = T.tripKey   

 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0           AND    
      TND.TripSavedDealKey  =@dealKey
              
 order by    segments.tripAirSegmentKey , segments .airSegmentDepartureDate                 
         
END

select @hotelnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals] WITH(NOLOCK)    where [tripKey]= @tripKey and [componentType]= 4 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)
if ( select COUNT(*) from TripHotelResponse WITH(NOLOCK)    where tripGUIDKey = @purchasekey )> 0 
BEGIN 
select DISTINCT top 1   vw.*,  0 as Savings,    @date as dealDate

 from    vw_tripHotelResponseDetails vw INNER JOIN Trip T WITH(NOLOCK)    on vw.tripGUIDKey  = T.tripPurchasedKey 
--LEFT OUTER JOIN 
--HotelResponseDetail HD on TND.responseDetailKey =HD.hotelResponseDetailKey 
Where T.tripPurchasedKey = @purchasekey 

END
ELSE 
BEGIN 
declare @originalHotelPrice as decimal ( 18,2) 
SET @originalHotelPrice = ( select  top 1 convert(decimal ( 18,2) ,(hotelTotalPrice  )) from TripHotelResponse WITH(NOLOCK)    where tripGUIDKey =@saveTripKey ) 
print ( @originalHotelPrice)
select DISTINCT top 1 TND.tripKey, vw.*,  Convert(decimal ( 18,2) , (hotelTotalPrice  )) -  (@originalHotelPrice )  as Savings ,TND.creationDate as dealDate 
 from TripSavedDeals   TND   WITH(NOLOCK) 
INNER JOIN  vw_tripHotelResponseDetails vw on TND.ResponseKey = vw.hotelResponseKey 
--LEFT OUTER JOIN 
--HotelResponseDetail HD on TND.responseDetailKey =HD.hotelResponseDetailKey 
Where TND.TripSavedDealKey  in (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK)    where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate  and [componentType]= 4)
END


select @carnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals]  WITH(NOLOCK)   where [tripKey]= @tripKey and [componentType]= 2 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)
if ( select COUNT(*) from TripCarResponse  WITH(NOLOCK)  where tripGUIDKey = @purchasekey )> 0 
BEGIN 
select distinct T.tripKey, vw.*  , 0 as Savings , @date as dealDate from vw_tripCarResponseDetails vw INNER JOIN Trip T  on vw.tripGUIDKey = T.tripPurchasedKey Where T.tripPurchasedKey = @purchasekey  
END 
ELSE 
BEGIN 

declare @originalCarPrice as decimal ( 18,2) 
SET @originalCarPrice = ( select top 1 convert(decimal ( 18,2),(  SearchCarPrice + searchCarTax))   from TripcarResponse  WITH(NOLOCK)  where tripGUIDKey =@saveTripKey ) 
select distinct top 1 TND.tripKey, vw.*  ,  convert(decimal ( 18,2) ,(isnull((minRate * NoOfDays ) + searchCarTax   ,0)- isnull((@originalCarPrice) ,0))) as Savings ,TND.creationDate as dealDate  from TripSavedDeals TND  WITH(NOLOCK) 
INNER JOIN  vw_tripCarResponseDetails vw on TND.responseKey  = vw.carResponseKey 
Where TND.TripSavedDealKey  in (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate  and [componentType]= 2)
 END 

 select  P.* from TripHotelResponsePassengerInfo P WITH(NOLOCK)  inner join TripHotelResponse HR WITH(NOLOCK)  on p.hotelResponsekey =HR.hotelResponseKey where tripGUIDKey = @purchasekey
insert @deals values ( (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK)  where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate and [componentType]= 1) ,1)   
insert @deals values ( (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK)    where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate  and [componentType]= 4) ,4)
insert @deals values ( (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK)    where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate  and [componentType]= 2) ,2)

 select SUM ( componentType  ) componentTypes from @deals  where dealkey is not null  
 
 END
GO
