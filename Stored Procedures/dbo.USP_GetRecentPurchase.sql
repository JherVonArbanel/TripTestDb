SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


            
/* Created By Anupam (24/Aug/2012) */      
/* Updated by Anupam (28/Apr/2014 Added follower count*/      
/* Exec USP_GetRecentPurchase 0,5 */            
-- EXEC USP_GetRecentPurchase 561393, 5            
CREATE PROCEDURE [dbo].[USP_GetRecentPurchase]            
(            
@UserKey INT,            
@SiteKey INT            
)            
            
AS            
            
BEGIN            
            
/* Get Top 5 Trip Request From Trip Request */            
DECLARE @tblPurchase TABLE             
(            
tripKey INT,            
tripPurchasedKey uniqueidentifier             
)        
        
        
 DECLARE @TripHotelGroup  as TABLE        
 (        
 Id INT IDENTITY(1,1),        
 HotelGroupId INT,        
 TripTo1 VARCHAR(10),        
 URL VARCHAR(200)        
         
 )        
        
 DECLARE @FINAL as TABLE        
 (        
  OrderId INT,         
  AptCode VARCHAR(10),         
  ImageURL VARCHAR(200)         
 )        
        
            
            
INSERT @tblPurchase(tripKey,tripPurchasedKey)            
 SELECT [tripKey],tripPurchasedKey            
 FROM [Trip] WITH(NOLOCK)            
 WHERE 
 UserKey = @UserKey AND 
 SiteKey = @SiteKey            
 AND recordLocator IS NOT NULL AND recordLocator <> ''            
 AND tripPurchasedKey IS NOT NULL            
 AND (tripStatusKey = 2 OR tripStatusKey = 1 OR tripStatusKey = 15) -- 1 = Pending | 2 = Purchased | 15 = Partial Purchase --      
 ORDER BY 1 DESC            
            
/* ------------ TRIP DETAILS -------------------------------*/             
SELECT T.[tripKey],[tripName],T.[userKey],[recordLocator],[tripStatusKey],[tripSavedKey],T.[tripPurchasedKey]            
      ,T.[tripComponentType],T.[siteKey],[isOnlineBooking],T.[tripAdultsCount],T.[tripSeniorsCount],[tripChildCount]            
      ,T.[tripInfantCount],T.[tripYouthCount],[noOfTotalTraveler],[noOfRooms],[noOfCars], startDate, endDate          
      , TR.tripFrom1, TR.tripTo1, TR.tripToHotelGroupId, TR.tripRequestKey, DEP.CityName as FromCity,     
      ARR.CityName as ToCity, 
      CASE WHEN ARR.CountryCode = 'US' THEN ARR.StateCode ELSE '' END as ToState, 
      CASE WHEN ARR.CountryCode = 'US' THEN '' ELSE CL.CountryName END as ToCountry, 
   CASE           
      WHEN T.[tripComponentType] = 1 THEN 'Air'          
      WHEN T.[tripComponentType] = 2 THEN 'Car'          
      WHEN T.[tripComponentType] = 3 THEN 'Air,Car'          
      WHEN T.[tripComponentType] = 4 THEN 'Hotel'          
      WHEN T.[tripComponentType] = 5 THEN 'Air,Hotel'          
      WHEN T.[tripComponentType] = 6 THEN 'Car,Hotel'          
      WHEN T.[tripComponentType] = 7 THEN 'Air,Car,Hotel'          
     END AS tripComponents,
     dbo.udf_GetFollowersCount(tripSavedKey) as followercount,
     tripCreationPath,P.userPendingPoints PendingPoints, PP.BonusPoints,
     tripTotalBaseCost,tripTotalTaxCost ,PP.userPendingPoints TravelPoints                        
 INTO #tmpTrip                 
 FROM [Trip] T WITH(NOLOCK)            
 INNER JOIN  @tblPurchase R ON R.TripKey = T.[tripKey]            
 INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey            
 LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode      
 LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode
 LEFT JOIN vault..CountryLookup CL WITH(NOLOCK) ON ARR.CountryCode = CL.CountryCode       
 LEFT JOIN loyalty.dbo.pendingpoints P WITH(NOLOCK) on T.tripKey = P.tripId   
 LEFT JOIN [Loyalty].[dbo].[PendingPointsHistory] PP ON T.tripKey = PP.tripId AND PP.IsConverted = 1        
 SELECT * FROM #tmpTrip           
/* ------------ TRIP AIR -------------------------------*/              
SELECT [tripAirResponseKey],TAR.[airResponseKey],TAR.[tripKey],[tripGUIDKey],searchAirPrice,            
   searchAirTax,[actualAirPrice],[actualAirTax],[actualAirPriceBreakupKey]            
      ,[CurrencyCodeKey],[repricedAirPrice],[repricedAirTax],[repricedAirPriceBreakupKey],[bookingCharges]            
      ,[appliedDiscount],TAL.[ValidatingCarrier],[status],[gdsSourceKey]            
      ,TASK.[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber]            
      ,[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate],[airSegmentArrivalDate]            
      ,[airSegmentDepartureAirport],[airSegmentArrivalAirport],[airSegmentResBookDesigCode],TASK.[RecordLocator]            
     ,departureAirport.AirportName  as departureAirportName ,                              
   departureAirport.CityCode as departureAirportCityCode,              
   departureAirport.CityName as departureAirportCityName,              
   departureAirport.StateCode   as departureAirportStateCode,                               
   departureAirport.CountryCode as departureAirportCountryCode,                              
   arrivalAirport.AirportName  as arrivalAirportName ,              
   arrivalAirport.CityCode as arrivalAirportCityCode,              
   arrivalAirport.CityName as arrivalAirportCityName,                              
   arrivalAirport.StateCode  as arrivalAirportStateCode ,              
   arrivalAirport.CountryCode as arrivalAirportCountryCode,            
   ISNULL (airven.ShortName,TASK.airSegmentMarketingAirlineCode) AS MarketingAirLine,            
   ISNULL (airOperatingven.ShortName,              
   TASK.airSegmentOperatingAirlineCode ) AS OperatingAirLine,                              
   TASK.ticketNumber AS TicketNumber ,              
   TASK.airsegmentcabin AS airsegmentcabin,
   TASK.airSegmentOperatingAirlineCompanyShortName
              
FROM [TripAirResponse] TAR WITH(NOLOCK)           
INNER JOIN @tblPurchase TP ON TAR.[tripGUIDKey] = TP.tripPurchasedKey            
INNER JOIN [TripAirLegs] TAL WITH(NOLOCK) ON TAL.[airResponseKey] = TAR.[airResponseKey]            
INNER JOIN [tripAirSegments] TASK WITH(NOLOCK) ON TASK.[airResponseKey] = TAR.[airResponseKey]            
AND TASK.tripAirLegsKey = TAL.tripAirLegsKey            
LEFT OUTER JOIN AirVendorLookup airVen WITH(NOLOCK)                               
 ON TASK.airSegmentMarketingAirlineCode = airVen .AirlineCode                               
 LEFT OUTER JOIN AirVendorLookup airOperatingVen WITH(NOLOCK)                              
 ON TASK .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                               
 LEFT OUTER JOIN AirportLookup departureAirport WITH(NOLOCK)                              
 ON departureAirport .AirportCode = TASK .airSegmentdepartureAirport                               
 LEFT OUTER JOIN AirportLookup arrivalAirport WITH(NOLOCK)                 
 ON arrivalAirport.AirportCode = TASK .airSegmentarrivalAirport                   
WHERE ISNULL(TAL.ISDELETED,0) = 0 AND ISNULL (TASK.ISDELETED ,0) = 0             
ORDER BY 1 ASC            
/* ------------ AIR END  -------------------------------*/              
            
/* ------------ CAR -------------------------------*/              
/****** Script for SelectTopNRows command from SSMS  ******/            
SELECT  *             
FROM vw_TripCarResponseDetails TCR WITH(NOLOCK)           
INNER JOIN @tblPurchase TP ON TCR.[tripGUIDKey] = TP.tripPurchasedKey            
/* ------------ CAR END -------------------------------*/            
            
/* ------------ HOTEL  -------------------------------*/               
SELECT *            
  FROM [vw_TripHotelResponseDetails] THR WITH(NOLOCK)         
  INNER JOIN @tblPurchase TP ON THR.[tripGUIDKey] = TP.tripPurchasedKey            
/* ------------ END HOTEL  -------------------------------*/               
            
            
/* ------------ CRUES  -------------------------------*/               
SELECT TCSR.[tripKey],[tripGUIDKey],[confirmationNumber],[recordLocator],[tripCruiseTotalPrice]            
      ,[CruiseLineCode],[ShipCode],[SailingDepartureDate],[SailingDuration],[ArrivalPort]            
      ,[DeparturePort],[RegionCode],[berthedCategory],[shipLocation],[cabinNbr],[deckId],[status]            
FROM [TripCruiseResponse] TCSR  WITH(NOLOCK)          
INNER JOIN @tblPurchase TP ON TCSR.[tripGUIDKey] = TP.tripPurchasedKey            
/* ------------ END CRUES  -------------------------------*/             
            
        
INSERT INTO @TripHotelGroup        
SELECT  TR.tripToHotelGroupId, TR.tripTo1  , '' as URL        
FROM TripRequest TR  WITH(NOLOCK)      
INNER JOIN #tmpTrip TD ON TR.tripRequestKey = TD.tripRequestKey        
        
--SELECT * FROM @TripHotelGroup        
        
DECLARE @FromIndex INT,        
  @ToIndex INT         
        
        
SET @FromIndex = 1        
SELECT @ToIndex = COUNT(*) FROM @TripHotelGroup        
        
WHILE(@FromIndex <= @ToIndex)        
BEGIN        
        
 DECLARE @Url   VARCHAR(200),        
   @HotelGroupId INT ,         
   @AptCode  VARCHAR(5),        
   @DestinationId INT        
           
         
 SELECT         
   @HotelGroupId = ISNULL(HotelGroupId,0),        
   @AptCode = TripTo1         
 FROM         
   @TripHotelGroup        
 WHERE         
   Id = @FromIndex        
         
         
 IF @HotelGroupId = 0 /* IF HOTEL GROUP ID IS NULL OR 0 THEN FETCH RECORDS STRAIGHT FROM DESTINATION TABLE .. */        
 BEGIN         
          
  /* PICKING RANDOM IMAGE FROM DESTINATION PAGE */        
        
  SELECT @Url = ISNULL(ImageURL,'') FROM CMS..Destination D             
  INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                 
  WHERE DI.IsEnabled = 1          
  AND D.AptCode = @AptCode         
  AND OrderId = @FromIndex        
        
  /* IF PICKING RANDOM IMAGE FROM DESTINATION PAGE FAILS THEN TAKE TOP 1 IMAGE ORDER BY ORDERID ASC FROM DESTINATION PAGE*/        
  IF @Url IS NULL OR @Url = ''        
  BEGIN         
        
    SELECT TOP 1 @Url = ImageURL FROM CMS..Destination D             
    INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                 
    WHERE DI.IsEnabled = 1          
    AND D.AptCode = @AptCode         
    ORDER BY OrderId ASC          
           
  END             
          
          
 END        
 ELSE /* IF HOTEL GROUP ID IS NOT 0 OR NULL */        
 BEGIN         
          
  SELECT @DestinationId =  ISNULL(DestinationId,0) FROM CMS..CustomHotelGroup        
  WHERE HotelGroupId = @HotelGroupId         
          
  IF @DestinationId <> 0 /* IF DESTINATION ID IS PRESENT THEN TAKE STRAIGHT FROM DESTINATION TABLE FOR THT DESTINATION ID */        
  BEGIN        
   --        
            
    SELECT TOP 1 @Url = ImageUrl FROM CMS..Destination D        
    INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                 
    WHERE DI.IsEnabled = 1          
    AND D.DestinationId = @DestinationId        
    ORDER BY OrderId ASC                 
          
  END        
  ELSE /* IF DESTINATION ID IS 0 OR NULL THEN REPEAT THE SAME QUERY WHICH IS UED TO GET RECORDS WHEN HOTEL GROUP ID IS NULL OR 0. CHECK ABOVE QUERY ... */        
  BEGIN         
        
            
    SELECT @Url = ISNULL(ImageURL,'') FROM CMS..Destination D             
    INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                 
    WHERE DI.IsEnabled = 1          
    AND D.AptCode = @AptCode         
    AND OrderId = @FromIndex        
        
    IF @Url IS NULL OR @Url = ''        
    BEGIN         
        
      SELECT TOP 1 @Url = ImageURL FROM CMS..Destination D             
      INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                 
      WHERE DI.IsEnabled = 1          
      AND D.AptCode = @AptCode         
      ORDER BY OrderId ASC          
             
    END             
        
          
  END         
          
          
         
 END         
         
 INSERT INTO @FINAL        
 (        
  OrderId ,         
  AptCode ,         
  ImageURL            
 )         
 VALUES        
 (        
  @FromIndex,        
  @AptCode,        
  @Url        
 )        
         
 SET @Url = ''        
 SET @AptCode  = ''        
 SET @HotelGroupId = 0        
 SET @DestinationId = 0         
        
 SET @FromIndex = @FromIndex + 1        
        
END         
        
           
SELECT * FROM @FINAL        
        
        
            
/*          
SELECT DISTINCT #tmpTrip.tripTo1          
INTO #tmpTripTo          
FROM #tmpTrip           
          
          
SELECT OrderId, AptCode, ImageURL FROM CMS..Destination          
INNER JOIN CMS..DestinationImages ON CMS..Destination.DestinationId = CMS..DestinationImages.DestinationId          
INNER JOIN #tmpTripTo ON CMS..Destination.AptCode = #tmpTripTo.tripTo1          
ORDER BY AptCode, OrderId          
*/          
          
DROP TABLE #tmpTrip          
--DROP TABLE #tmpTripTo          
            
END
GO
