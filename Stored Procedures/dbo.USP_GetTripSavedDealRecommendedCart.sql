SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
/*Exec [USP_GetTripSavedDealCart]  6289 ,getdate(),0*/        
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealRecommendedCart]                
(            
 @tripKey int,  
 @tripDate date,  
 @userId int = 0   
)            
as                
BEGIN  
SET NOCOUNT ON;      
---for yesterday search start here---  
Declare @deals as Table (dealKey int , componentType int)  
  
insert @deals values ( (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK)  where [tripKey]= @tripKey   and [componentType]= 1) ,1)     
insert @deals values ( (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK)    where [tripKey]= @tripKey   and [componentType]= 4) ,4)  
insert @deals values ( (select max(TripSavedDealKey) from [dbo].[TripSavedDeals] WITH(NOLOCK)    where [tripKey]= @tripKey    and [componentType]= 2) ,2)  
declare @dealKey as bigint   
--declare @tripID AS INT  = ( Select top 1 tripkey from TripSavedDeals where TripSavedDealKey in  (select top 1 * from ufn_CSVSplitString(@NightlyDealKey)))  
declare @airnewPrice float =0  
declare @hotelnewPrice float =0  
declare @carnewPrice float =0  
SELECT * FROM Trip WITH ( NOLOCK) where tripKey  = @tripKey    
declare @saveTripKey as uniqueidentifier   
set @saveTripKey  = (select TripSavedkey from trip WITH ( NOLOCK)  where tripKey = @tripKey)  
  
select @airnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals]  WITH(NOLOCK)   where [tripKey]= @tripKey and [componentType]= 1 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)  
 declare @purchasekey as uniqueidentifier = ( select TripPurchasedkey from trip WITH(NOLOCK)   where tripStatusKey <> 17 and tripKey = @tripKey and userKey  =  @userId )   
declare @date as datetime  = ( select CreatedDate  from trip WITH(NOLOCK) where tripKey = @tripKey and tripStatusKey <> 17)   
  
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
segments.recordLocator as SegRecordLocator,  
segments.airSegmentOperatingAirlineCompanyShortName       
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
  ,  @date as dealDate,Ab.airlineBaggageLink  
                     
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
   LEFT OUTER JOIN  
   AirlineBaggageLink AB WITH(NOLOCK)  on   
  (CASE WHEN (segments.airSegmentOperatingAirlineCode <> '' AND segments.airSegmentOperatingAirlineCode <>  segments.airSegmentMarketingAirlineCode )   THEN segments.airSegmentOperatingAirlineCode ELSE segments.airSegmentMarketingAirlineCode END) = Ab.airlineCode  
 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0           AND      
    tripGUIDKey = @purchasekey                 
 order by    segments.tripAirSegmentKey , segments .airSegmentDepartureDate        
   
END  
ELSE   
BEGIN  
select @dealKey =d.dealKey  FROM @deals D WHERE  [componentType]= 1   
declare @originalAirPrice as decimal ( 18,2)   
 declare @searchAirPrice as decimal ( 18,2)   
 declare @searchAirTax as decimal ( 18,2)    
 DECLARE @airresponsekey AS UNIQUEIDENTIFIER   
 DECLARE @airDealDate AS DateTime   
 SELECT @airresponsekey = responsekey ,@airDealDate =creationDate from TripSavedDeals WITH (NOLOCK) WHERE TripSavedDealKey =@dealKey   
   
SELECT    
@searchAirPrice =(( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) +   
( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  + (isnull(tripInfantwithSeatBase,0)*isnull(t.tripInfantwithSeatCount,0) )  )  
,@searchAirTax =(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) +   
( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) ) + (isnull(tripInfantwithSeattax,0)*isnull(t.tripInfantWithSeatCount,0) )  )  
 from TripAirPrices TAP WITH(NOLOCK)     
inner join TripAirResponse TR WITH(NOLOCK)    on TAP.tripAirPriceKey = TR.searchAirPriceBreakupKey   
inner join Trip T WITH(NOLOCK)    on TR.tripGUIDKey = T.tripSavedKey  where t.tripKey = @tripKey and T.tripStatusKey <> 17  
   
  
SET @originalAirPrice = ( select top 1 convert(decimal ( 18,2) ,(@searchAirPrice + @searchAirTax))    
  
 from TripAirResponse WITH(NOLOCK)  
    
  where tripGUIDKey =@saveTripKey )   
   
 DECLARE @adultCount AS INT   
 DECLARE @childCount AS INT   
 DECLARE @youthCount AS INT   
 DECLARE @infantCount AS INT   
 DECLARE @seniorCount AS INT   
 DECLARE @infantWithSeatCount AS INT  
 SELECT @adultCount =tripAdultsCount ,@seniorCount =tripSeniorsCount ,@youthCount =tripYouthCount,@infantCount =tripInfantCount ,@childCount=tripChildCount,@infantWithSeatCount =tripInfantWithSeatCount FROM Trip T WITH(NOLOCK) Where tripKey =@tripKey   
   
select                    
distinct AirResp.airResponseKey  , legs.recordLocator     ,  
        (( isnull(tripAdultBase,0) * isnull(@adultCount,0) ) + (isnull(tripChildBase,0)*isnull(@childCount,0) ) +   
( isnull(tripSeniorBase,0) * isnull(@seniorCount,0) ) + (isnull(tripYouthBase,0)*isnull(@youthCount,0) ) + (isnull(tripInfantBase,0)*isnull(@infantCount,0) )+ (isnull(tripInfantwithSeatBase,0)*isnull(@infantWithSeatCount,0) )  )   searchAirPrice,  
(( isnull(tripAdulttax,0) * isnull(@adultCount,0) ) + (isnull(tripChildtax,0)*isnull(@childCount,0) ) +   
( isnull(tripSeniortax,0) * isnull(@seniorCount,0) ) + (isnull(tripYouthtax,0)*isnull(@youthCount,0) ) + (isnull(tripInfanttax,0)*isnull(@infantCount,0) )+ (isnull(tripInfantwithSeattax,0)*isnull(@infantWithSeatCount,0) )  ) searchAirTax ,      
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
airSegmentOperatingAirlineCompanyShortName  
              
     ,legs.gdsSourceKey ,            legs. contractCode   ,  
   departureAirport.AirportName  as departureAirportName ,                  
   departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode                   
   ,departureAirport.CountryCode as departureAirportCountryCode,                  
  arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,                  
  arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,                  
  legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax ,AirResp.airResponseKey ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )                  
  as MarketingAirlineName,airSegmentOperatingAirlineCode  ,  AirResp.CurrencyCodeKey as CurrencyCode,                
  ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirlineName , convert(decimal ( 18,2) ,(((( isnull(tripAdultBase,0) * isnull(@adultCount,0) ) + (isnull(tripChildBase,0)*isnull(@childCount,0) ) +   
( isnull(tripSeniorBase,0) * isnull(@seniorCount,0) ) + (isnull(tripYouthBase,0)*isnull(@youthCount,0) ) + (isnull(tripInfantBase,0)*isnull(@infantCount,0) )+ (isnull(tripInfantwithSeatBase,0)*isnull(@infantWithSeatCount,0) )  )+(( isnull(tripAdulttax,0) 
* isnull(@adultCount,0) ) + (isnull(tripChildtax,0)*isnull(@childCount,0) ) +   
( isnull(tripSeniortax,0) * isnull(@seniorCount,0) ) + (isnull(tripYouthtax,0)*isnull(@youthCount,0) ) + (isnull(tripInfanttax,0)*isnull(@infantCount,0) )+ (isnull(tripInfantwithSeattax,0)*isnull(@infantWithSeatCount,0) )  ) )- isnull(@originalAirPrice ,0
))) as Savings,TAP.*,@airDealDate as dealDate,  
       AB.airlineBaggageLink               
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
  -- inner join     TripSavedDeals TND WITH(NOLOCK)    on airresp.airResponseKey = tnd.responseKey   
   --inner join Trip T WITH(NOLOCK)    on TND.tripKey = T.tripKey     
   LEFT OUTER JOIN  
   AirlineBaggageLink AB WITH(NOLOCK)  on   
  (CASE WHEN (segments.airSegmentOperatingAirlineCode <> '' AND segments.airSegmentOperatingAirlineCode <>  segments.airSegmentMarketingAirlineCode )   THEN segments.airSegmentOperatingAirlineCode ELSE segments.airSegmentMarketingAirlineCode END) = Ab.airlineCode  
   WHERE AirResp.airResponseKey =@airresponsekey AND  
   ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0         --  AND      
    --  T.tripStatusKey <> 17  
             ---AND  TND.TripSavedDealKey  =@dealKey  
 order by    segments.tripAirSegmentKey , segments .airSegmentDepartureDate                   
           
END  
  
--select @hotelnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals] WITH(NOLOCK)    where [tripKey]= @tripKey and [componentType]= 4 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)  
if ( select COUNT(*) from TripHotelResponse WITH(NOLOCK)    where tripGUIDKey = @purchasekey )> 0   
BEGIN   
  
select DISTINCT top 1   vw.*,  0 as Savings,    @date as dealDate, 1 AS TripCreationPath  
  
 from    vw_tripHotelResponseDetails vw INNER JOIN Trip T WITH(NOLOCK)    on vw.tripGUIDKey  = T.tripPurchasedKey   
--LEFT OUTER JOIN   
--HotelResponseDetail HD on TND.responseDetailKey =HD.hotelResponseDetailKey   
Where T.tripPurchasedKey = @purchasekey  and T.tripStatusKey <> 17  
  
END  
ELSE   
BEGIN  
  
 --Edited and Formated By Jayant Guru on 20 Feb 2015  
   
 DECLARE @originalHotelPrice AS DECIMAL ( 18,2)   
   ,@hotelResponseKey AS UNIQUEIDENTIFIER   
   ,@hotelDealDate AS DateTime  
   ,@strikeThroughPrice FLOAT  
   ,@isCrowd BIT  
  
 SET @originalHotelPrice = (SELECT TOP 1 CONVERT(DECIMAL ( 18,2) ,(hotelTotalPrice))   
 FROM TripHotelResponse WITH(NOLOCK)  
 WHERE tripGUIDKey =@saveTripKey )   
  
 SELECT @dealKey = d.dealKey    
 FROM @deals D   
 WHERE  [componentType]= 4  
  
 SELECT @hotelResponseKey =responseKey   
 ,@hotelDealDate = creationDate    
 ,@strikeThroughPrice = currentListPagePrice  
 ,@isCrowd = isCrowd  
 FROM TripSavedDeals WITH(NOLOCK)   
 WHERE TripSavedDealKey = @dealKey   
   
 SELECT TOP 1 @tripKey AS tripKey, vw.*  
 ,CONVERT(DECIMAL ( 18,2) , (hotelTotalPrice  )) -  (@originalHotelPrice ) AS Savings   
 ,@hotelDealDate AS dealDate , 1 AS TripCreationPath  
 ,currentListPagePrice = ISNULL(@strikeThroughPrice, 0)  
 ,isCrowd = ISNULL(@isCrowd, 0)  
 FROM vw_tripHotelResponseDetails vw  
 WHERE hotelResponseKey = @hotelResponseKey  
END  
  
  
---select @carnewPrice =max([currentPerPersonPrice]) from [dbo].[TripSavedDeals]  WITH(NOLOCK)   where [tripKey]= @tripKey and [componentType]= 2 and  Convert(Date,[creationDate])= @tripDate group by TripSavedDealKey having TripSavedDealKey= max(TripSavedDealKey)  
if ( select COUNT(*) from TripCarResponse  WITH(NOLOCK)  where tripGUIDKey = @purchasekey )> 0   
BEGIN   
select distinct top 1 T.tripKey, vw.*  , 0 as Savings , @date as dealDate from vw_tripCarResponseDetails vw INNER JOIN Trip T WITH (NOLOCK) on vw.tripGUIDKey = T.tripPurchasedKey Where T.tripPurchasedKey = @purchasekey   and T.tripStatusKey <> 17  
END   
ELSE   
BEGIN   
SET @dealKey =  (SELECT d.dealKey  FROM @deals D WHERE  [componentType]= 2)  
declare @originalCarPrice as decimal ( 18,2)   
PRINT  CONVERT(VARCHAR(30),GETDATE(),113)   
  
SET @originalCarPrice = ( select top 1 convert(decimal ( 18,2),(  SearchCarPrice + searchCarTax))     
from TripcarResponse  WITH(NOLOCK)  where tripGUIDKey =@saveTripKey )   
  
PRINT  CONVERT(VARCHAR(30),GETDATE(),113)   
  
DECLARE @carResponsekey As uniqueidentifier   
DECLARE @dealDate AS DateTime   
  
SELECT @carResponsekey = responsekey,@dealDate = creationDate FROM TripSavedDeals WITH(NOLOCK) WHERE TripSavedDealKey =@dealKey  
select TOP 1   @tripKey AS tripkey, vw.*  ,  convert(decimal ( 18,2) ,(isnull((minRate * NoOfDays ) + searchCarTax   ,0)- isnull((@originalCarPrice) ,0))) as Savings ,@dealDate as dealDate    
  from  --TripSavedDeals TND  WITH(NOLOCK) INNER JOIN   
 vw_tripCarResponseDetails vw  -- on ( TND.TripSavedDealKey =@dealKey AND vw.carResponseKey =TND.responseKey )  
-- Where TND.TripSavedDealKey =@dealKey  
WHERE vw.carResponseKey =@carResponsekey   
--AND vw.tripGUIDKey=@saveTripKey --commented it for TFS #19499  
  
 PRINT CONVERT(VARCHAR(30),GETDATE(),113)   
 END   
  
 select  P.* from TripHotelResponsePassengerInfo P WITH(NOLOCK)  inner join TripHotelResponse HR WITH(NOLOCK)  on p.hotelResponsekey =HR.hotelResponseKey where tripGUIDKey = @purchasekey  
PRINT CONVERT(VARCHAR(30),GETDATE(),113)   
 select SUM ( componentType  ) componentTypes from @deals  where dealkey is not null    
PRINT  CONVERT(VARCHAR(30),GETDATE(),113)   
 END
GO
