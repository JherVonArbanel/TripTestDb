SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


  
/*Exec usp_GetSaveTripDetails  35610, 561452*/        
CREATE PROCEDURE [dbo].[usp_GetSaveTripDetails]                
(            
@Tripid INT,  
@userID int = 0   
)            
as                
BEGIN      
	SET NOCOUNT ON;
	
	declare @bookedAir as bit = 0   
			,@bookedCar as bit = 0  
			,@bookedHotel as bit = 0
			,@completeTripOriginalTotalPrice FLOAT = 0
			,@crowdID AS BIGINT
			,@isHotelCrowdSavings BIT 

	IF(@userID = 0) --FOR GUEST USER
	BEGIN
		SET @completeTripOriginalTotalPrice = (SELECT ISNULL(originalPerPersonPriceAir, 0)
		+ ISNULL(originalPerPersonPriceCar, 0)
		+ ISNULL(originalPerPersonPriceHotel, 0)
		FROM TripDetails WITH (NOLOCK)
		WHERE tripKey = @Tripid)
	END
	ELSE --FOR LOGGED IN USER
	BEGIN
		SET @completeTripOriginalTotalPrice = (SELECT ISNULL(originalTotalPriceAir, 0)
		+ ISNULL(originalTotalPriceCar, 0)
		+ ISNULL(originalTotalPriceHotel, 0)
		FROM TripDetails WITH (NOLOCK)
		WHERE tripKey = @Tripid)
	END
	
	SELECT @crowdID = crowdID
	,@isHotelCrowdSavings = ISNULL(IsHotelCrowdSavings, 0)
	FROM Trip T WITH(NOLOCK) INNER JOIN TripSaved 
	TS ON T.tripSavedKey =TS.tripSavedKey WHERE tripKey =@Tripid
	
	SELECT T.*
	,completeTripOriginalTotalPrice = CONVERT(DECIMAL (18,2), @completeTripOriginalTotalPrice)
	,crowdID=@crowdID,UM.ImageURL,UM.UserImageData, TD.fromCountryName, TD.toCountryName 
	FROM trip T WITH(NOLOCK) 
	left JOIN TripDetails TD ON T.tripKey = Td.tripKey
	LEFT OUTER JOIN Loyalty..[UserMap] UM ON T.userKey=UM.UserId
	WHERE T.tripkey = @tripID  
	AND tripStatusKey <> 17
	
declare @purchasekey as uniqueidentifier = ( select TripPurchasedkey from trip WITH(NOLOCK)    where tripKey = @Tripid  and userKey =@userID  and tripStatusKey <> 17 )   
 if ( @purchasekey is not null )   
BEGIN  
if ( SELECT COUNT (*) FROM TripAirResponse WITH(NOLOCK)    where tripGUIDKey = @purchasekey ) > 0   
BEGIN  
SET @bookedAir = 1   
 END   
 if ( SELECT COUNT (*) FROM TripCarResponse WITH(NOLOCK)    where tripGUIDKey = @purchasekey ) > 0   
BEGIN  
SET @bookedCar = 1   
 END   
 if ( SELECT COUNT (*) FROM TripHotelResponse WITH(NOLOCK)    where tripGUIDKey = @purchasekey ) > 0   
BEGIN  
SET @bookedHotel  = 1   
 END   
END   
 declare @searchAirPrice as decimal ( 18,2)   
 declare @searchAirTax as decimal ( 18,2)    
  DECLARE @airResponsekey AS UNIQUEIDENTIFIER 
 SELECT    
@searchAirPrice =(( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) +   
( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  + (isnull(tripInfantwithSeatBase,0)*isnull(t.tripInfantwithSeatCount,0) )  )  
,@searchAirTax =(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) +   
( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )+ (isnull(tripInfantwithSeattax,0)*isnull(t.tripInfantwithSeatCount,0) )  )  ,
@airResponsekey = Tr.airResponseKey
 from TripAirPrices TAP WITH(NOLOCK)     
inner join TripAirResponse TR WITH(NOLOCK) on TAP.tripAirPriceKey =   TR.searchAirPriceBreakupKey    
inner join Trip T WITH(NOLOCK) on TR.tripGUIDKey =(case when @bookedAir =1 then t.tripPurchasedKey else T.tripSavedKey end)    
where t.tripKey = @Tripid  and T.tripStatusKey <> 17    
  
select                    
distinct @Tripid AS TripKey, legs.recordLocator, 
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
  segments.airSegmentOperatingAirlineCompanyShortName,  
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
  legs.ValidatingCarrier  
  ,legs.isrefundable,legs.contractcode  ,  
  @searchAirPrice searchAirPrice, @searchAirTax searchAirTax , TAP.*,  
  AB.airlineBaggageLink   
                     
 from TripAirSegments  segments    WITH(NOLOCK)                  
  inner join TripAirLegs legs    WITH(NOLOCK)                  
   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                   
   and segments .airLegNumber = legs .airLegNumber )                  
  inner join TripAirResponse   AirResp    WITH(NOLOCK)                  
   on segments .airResponseKey = AirResp .airResponseKey          
   LEFT OUTER JOIN TripAirPrices TAP WITH(NOLOCK)    on airresp.searchAirPriceBreakupKey = TAP.tripAirPriceKey                      
 -- inner join Trip t WITH(NOLOCK)    on AirResp.tripGUIDKey  = (case when @bookedAir =1 then t.tripPurchasedKey else  t.tripSavedKey end   )              
   left outer join AirVendorLookup airVen                   
   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                   
  left outer join AirVendorLookup airOperatingVen WITH(NOLOCK)                      
   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                   
  left outer join AirportLookup departureAirport WITH(NOLOCK)                     
   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                   
 left outer join AirportLookup arrivalAirport  WITH(NOLOCK)                    
   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                   
  inner join Vault.dbo.GDSSourceLookup G WITH(NOLOCK)   on G.gdsSourceKey = legs.gdsSourceKey     
   LEFT OUTER JOIN  
   AirlineBaggageLink AB WITH(NOLOCK)  on   
  (CASE WHEN (segments.airSegmentOperatingAirlineCode <> '' AND segments.airSegmentOperatingAirlineCode <>  segments.airSegmentMarketingAirlineCode )   THEN segments.airSegmentOperatingAirlineCode ELSE segments.airSegmentMarketingAirlineCode END) = Ab.airlineCode  
 WHERE AirResp.airResponseKey = @airResponsekey AND  ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0  -- and T.tripStatusKey <> 17          
           -- AND T.tripKey =@Tripid    
 order by  segments.tripAirSegmentKey , segments .airSegmentDepartureDate                   
         
DECLARE @hotelResponseKey AS uniqueidentifier 
		,@HotelRequestKey INT
		,@TripCreationPath INT

SET @HotelRequestKey = (SELECT TOP 1 hotelRequestKey FROM TripRequest_hotel WHERE tripRequestKey = 
(SELECT tripRequestKey FROM Trip WHERE tripKey = @Tripid))

SET @TripCreationPath = (SELECT tripCreationPath FROM HotelRequest WHERE hotelRequestKey = @HotelRequestKey)

  IF ( @bookedHotel = 1) 
  BEGIN 
   SELECT @hotelResponseKey = HotelResponsekey from TripHotelResponse WITH(NOLOCK) 
   WHERE tripGUIDKey = (SELECT t.tripPurchasedKey  FROM Trip T WITH(NOLOCK) where tripKey =@Tripid )
	SELECT DISTINCT  top 1   @tripid tripKey 
	,vw.*
	,TripCreationPath = @TripCreationPath   
	,IsHotelCrowdSavings = @isHotelCrowdSavings
	From vw_tripHotelResponseDetails VW 
	where hotelResponseKey =@hotelResponseKey
  END ELSE 
  BEGIN 
  
  SELECT @hotelResponseKey = HotelResponsekey from TripHotelResponse WITH(NOLOCK) 
  WHERE tripGUIDKey = (SELECT t.tripSavedKey  FROM Trip T WITH(NOLOCK) where tripKey =@Tripid )
  
  SELECT DISTINCT  top 1   @tripid tripKey 
  ,vw.*
  ,TripCreationPath = @TripCreationPath   
  ,IsHotelCrowdSavings = @isHotelCrowdSavings
  From 
  vw_tripHotelResponseDetails VW 
  where hotelResponseKey = @hotelResponseKey 	 
  END

    
--IF (@bookedHotel =1)  
--BEGIN  
-- SELECT DISTINCT  top 1 T.tripKey ,vw.*   From Trip T WITH(NOLOCK)     
-- INNER JOIN vw_tripHotelResponseDetails VW ON  t.tripPurchasedKey =  vw.tripGUIDKey    
--  where t.tripKey = @Tripid   
--END  
--ELSE  
--BEGIN  
-- SELECT DISTINCT  top 1 T.tripKey ,vw.*   From Trip T WITH(NOLOCK)     
-- INNER JOIN vw_tripHotelResponseDetails VW ON  t.tripSavedKey =  vw.tripGUIDKey    
--  where t.tripKey = @Tripid   
--END  
   DECLARE @carResponseKEy AS UNIQUEIDENTIFIER 
   DECLARE @tripPurchaseKey AS VARCHAR(500)
   IF @bookedCar = 1 
   BEGIN 
   SELECT @tripPurchaseKey = (SELECT tripPurchasedKey FROM Trip WITH(NOLOCK) WHERE tripKey =@Tripid);
   SELECT @carResponseKEy = CarResponsekey from TripCarResponse WITH(NOLOCK) WHERE tripGUIDKey = @tripPurchaseKey;
	--select t.tripKey , vw.*   from Trip T WITH(NOLOCK)      
	--Inner join  vw_tripCarResponseDetails VW on   t.tripPurchasedKey  =  vw.tripGUIDKey     
	-- where T.tripKey =@Tripid  and T.tripStatusKey <> 17   
	 select @Tripid  tripKey , vw.*   from --Trip T WITH(NOLOCK)  Inner join 
	  vw_tripCarResponseDetails VW -- ON tripSavedKey  = vw.tripGUIDKey     
	 where carResponseKey =@carResponseKEy AND tripGUIDKey=@tripPurchaseKey  -- T.tripKey =@Tripid  and T.tripStatusKey <> 17  
  END
  ELSE 
  BEGIN   
  SELECT @carResponseKEy = CarResponsekey from TripCarResponse WITH(NOLOCK) WHERE tripGUIDKey = (SELECT TripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey =@Tripid )
	 select @Tripid  tripKey , vw.*   from --Trip T WITH(NOLOCK)  Inner join 
	  vw_tripCarResponseDetails VW -- ON tripSavedKey  = vw.tripGUIDKey     
	 where carResponseKey =@carResponseKEy AND tripGUIDKey = (SELECT TripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey =@Tripid) -- T.tripKey =@Tripid  and T.tripStatusKey <> 17   
	 
	--  select  tripKey , vw.*   from Trip T WITH(NOLOCK)      
	--Inner join  vw_tripCarResponseDetails VW  ON tripSavedKey  = vw.tripGUIDKey     
	-- where T.tripKey =@Tripid  and T.tripStatusKey <> 17   
  END
  
  
--IF (@bookedcar =1)  
--BEGIN  
-- SELECT t.tripKey , vw.*   from Trip T WITH(NOLOCK)      
-- INNER JOIN  vw_tripCarResponseDetails VW on   t.tripPurchasedKey =  vw.tripGUIDKey     
-- WHERE T.tripKey =@Tripid   
--END  
--ELSE  
--BEGIN  
-- SELECT t.tripKey , vw.*   from Trip T WITH(NOLOCK)      
-- INNER JOIN  vw_tripCarResponseDetails VW on   t.tripSavedKey =  vw.tripGUIDKey     
-- WHERE T.tripKey =@Tripid   
--END  
  
   
select  P.* from TripHotelResponsePassengerInfo P WITH(NOLOCK)    
inner join TripHotelResponse HR WITH(NOLOCK)  on p.hotelResponsekey =HR.hotelResponseKey where tripGUIDKey = @purchasekey  

SELECT TPI.PassengerKey, TPI.PassengerFirstName, TPI.PassengerLastName, AP.originAirportCode, 
(CASE WHEN TPI.PassengerKey != 0 THEN (CASE WHEN U.UserImageData IS Not NULL THEN 'user/image/' + CAST(U.UserId AS Varchar) ELSE U.ImageUrl END) ELSE NULL END) as imageUrl
  FROM TripPassengerInfo TPI LEFT JOIN Loyalty..[UserMap] U ON TPI.PassengerKey = U.UserId
  LEFT JOIN vault.dbo.AirPreference AP ON AP.userKey = U.UserId
 Where TPI.TripKey = @Tripid

END  
  
  
  
  
GO
