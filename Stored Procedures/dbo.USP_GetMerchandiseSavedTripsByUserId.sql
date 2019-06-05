SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

        
/*        
 AUTHER  : Gopal N        
 CREATED Dt : 8-Aug-2012        
 DESCRIPTION : Stored procedure to retrieve all saved trips (Air/Car/Hotel) of particular user        
 EXECUTION :   [USP_GetMerchandiseSavedTripsByUserId] @userId = 559865, @Limit = 5        
     EXEC [USP_GetMerchandiseSavedTripsByUserId] @userId = 560419, @Limit = 0        
*/        
        
CREATE PROCEDURE [dbo].[USP_GetMerchandiseSavedTripsByUserId] (                  
-- Declare        
 @userId INT,        
 @Limit INT        
) AS         
-- Select @userId= 767, @Limit=5        
BEGIN         
        
 DECLARE @Tripdetails AS TABLE         
 (        
  tripKey    INT,        
  siteKey    INT,        
  tripSavedKey  UNIQUEIDENTIFIER,        
  StartDate   DATETIME,        
  EndDate    DATETIME,        
  Origin    VARCHAR(200),        
  Destination   VARCHAR(200),        
  CreatedOn   DATETIME,        
  tripComponentType SMALLINT,        
  tripComponents  VARCHAR(50),      
  tripFrom VARCHAR(5),      
  tripTo VARCHAR(5),        
  CityName VARCHAR(100),      
  StateCode VARCHAR(5),      
  CountryCode VARCHAR(5),      
  TripRequestKey INT,     
  FromCity VARCHAR(50),    
  ToCity VARCHAR(50),
  ToCountryName VARCHAR(100)       
          
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
      
        
 IF isnull(@Limit,0) > 0         
 BEGIN        
  INSERT INTO @Tripdetails        
  (        
   tripKey,         
   siteKey,         
   tripSavedKey,         
   StartDate,         
   EndDate,         
   Origin,         
   Destination,         
   CreatedOn,         
   tripComponentType,         
   tripComponents,      
 tripFrom ,      
 tripTo,         
   CityName ,      
   StateCode ,      
   CountryCode ,      
   TripRequestKey,    
   FromCity,    
   ToCity,
   ToCountryName             
  )        
  SELECT top (@Limit) *         
  FROM        
  (        
   SELECT DISTINCT T.tripKey, T.siteKey, T.tripSavedKey, TR.tripFromDate1 AS StartDate, TR.tripToDate1 AS EndDate        
    , DepCity.CityName AS Origin        
    , ArrCity.CityName AS Destination, T.CreatedDate AS CreatedOn, T.tripComponentType        
    , CASE         
      WHEN T.tripComponentType = 1 THEN 'Air'        
      WHEN T.tripComponentType = 2 THEN 'Car'        
      WHEN T.tripComponentType = 3 THEN 'Air,Car'        
      WHEN T.tripComponentType = 4 THEN 'Hotel'        
      WHEN T.tripComponentType = 5 THEN 'Air,Hotel'        
      WHEN T.tripComponentType = 6 THEN 'Car,Hotel'        
      WHEN T.tripComponentType = 7 THEN 'Air,Car,Hotel'        
     END AS tripComponents,      
     TR.tripFrom1,      
     TR.tripTo1 ,           
     ArrCity.CityName,      
     ArrCity.StateCode,      
     ArrCity.CountryCode,      
     TR.tripRequestKey,    
     DepCity.CityName as FromCity,    
     ArrCity.CityName as ToCity,
     CASE WHEN ArrCity.CountryCode = 'US' THEN '' ELSE CL.CountryName END as ToCountryName        
   FROM Trip T        
    INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND T.userKey =  CONVERT(VARCHAR, @userId)         
      AND T.tripSavedKey IS NOT NULL AND T.tripStatusKey IN (14, 15) AND IsWatching = 1 AND T.startdate > DATEAdd(DAY,1 ,getdate())  -- AND T.tripPurchasedKey IS NULL        
    LEFT OUTER JOIN TripAirResponse TA ON T.tripsavedKey = TA.tripGUIDKey AND ISNULL(TA.isDeleted, 0) = 0         
    LEFT OUTER JOIN AirportLookup DepCity ON TR.tripFrom1 = DepCity.AirportCode        
    LEFT OUTER JOIN AirportLookup ArrCity ON TR.tripTo1 = ArrCity.AirportCode        
    LEFT OUTER JOIN vault..CountryLookup CL ON ArrCity.CountryCode = CL.CountryCode
  ) A ORDER BY tripKey DESC        
        
 END        
 ELSE        
 BEGIN        
  
  INSERT INTO @Tripdetails        
  (        
   tripKey,         
   siteKey,         
   tripSavedKey,         
   StartDate,         
   EndDate,         
   Origin,         
   Destination,         
   CreatedOn,         
   tripComponentType,         
   tripComponents ,      
   tripFrom,      
   tripTo,         
   CityName ,      
   StateCode ,      
   CountryCode ,      
   TripRequestKey,    
   FromCity,    
   ToCity,
   ToCountryName              
  )        
  SELECT *        
  FROM        
  (        
   SELECT DISTINCT T.tripKey, T.siteKey, T.tripSavedKey, TR.tripFromDate1 AS StartDate, TR.tripToDate1 AS EndDate        
    , DepCity.CityName AS Origin        
    , ArrCity.CityName AS Destination, T.CreatedDate AS CreatedOn, T.tripComponentType        
    , CASE         
      WHEN T.tripComponentType = 1 THEN 'Air'        
      WHEN T.tripComponentType = 2 THEN 'Car'        
      WHEN T.tripComponentType = 3 THEN 'Air,Car'        
      WHEN T.tripComponentType = 4 THEN 'Hotel'        
      WHEN T.tripComponentType = 5 THEN 'Air,Hotel'        
      WHEN T.tripComponentType = 6 THEN 'Car,Hotel'        
      WHEN T.tripComponentType = 7 THEN 'Air,Car,Hotel'        
     END AS tripComponents,      
     TR.tripFrom1,      
     TR.tripTo1 ,           
     ArrCity.CityName,      
     ArrCity.StateCode,      
     ArrCity.CountryCode,      
     TR.tripRequestKey,    
     DepCity.CityName as FromCity,    
     ArrCity.CityName as ToCity,
	 CASE WHEN ArrCity.CountryCode = 'US' THEN '' ELSE CL.CountryName END as ToCountryName        
   FROM Trip T        
    INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND T.userKey =  CONVERT(VARCHAR, @userId)         
      AND T.tripSavedKey IS NOT NULL AND T.tripStatusKey IN (14, 15) AND IsWatching = 1 AND T.startdate > DATEAdd(DAY,1 ,getdate()) --AND T.tripPurchasedKey IS NULL        
    LEFT OUTER JOIN TripAirResponse TA ON T.tripsavedKey = TA.tripGUIDKey AND ISNULL(TA.isDeleted, 0) = 0         
    LEFT OUTER JOIN AirportLookup DepCity ON TR.tripFrom1 = DepCity.AirportCode        
    LEFT OUTER JOIN AirportLookup ArrCity ON TR.tripTo1 = ArrCity.AirportCode        
    LEFT OUTER JOIN vault..CountryLookup CL ON ArrCity.CountryCode = CL.CountryCode
  ) A ORDER BY tripKey DESC        
 END         
         
 DECLARE @deal table        
 (        
  TripSavedDealKey INT,        
  tripKey    INT,        
  componentType  INT        
 )        
        
 INSERT INTO @deal        
 SELECT MAX(TSD.TripSavedDealKey) TripSavedDealKey, TSD.tripKey, TSD.componentType        
 FROM TripSavedDeals TSD         
  LEFT OUTER JOIN @Tripdetails T ON TSD.tripKey = T.tripKey        
 GROUP BY TSD.TripKey, TSD.componentType        
 ORDER BY TSD.TripKey, TSD.componentType        
        
 SELECT T.tripKey, T.tripSavedKey, T.StartDate, T.EndDate, T.Origin, T.Destination, T.CreatedOn, T.tripComponentType, T.tripComponents,         
  SUM(ISNULL(TSD.currentTotalPrice,0)) currentTotalPrice, SUM(ISNULL(TSD.originalTotalPrice,0)) originalTotalPrice,        
  '' AS DestinationImageURL,        
  CASE WHEN T.tripKey IS NULL THEN '' ELSE SC.siteName + '/travel/cart/savetrip?id=' + CONVERT(VARCHAR, T.tripKey) END AS SavedTripURL,        
  (SUM(ISNULL(TSD.originalTotalPrice,0)) - SUM(ISNULL(TSD.currentTotalPrice,0))) AS TotalSaving,        
  T.CreatedOn watchedTripDate, T.tripTo, CityName, StateCode, CountryCode, FromCity, ToCity, ToCountryName      
 FROM @Tripdetails T        
  INNER JOIN Vault..SiteConfiguration SC ON T.siteKey = SC.siteKey        
  LEFT OUTER JOIN @deal D ON T.tripKey = D.tripKey        
  LEFT OUTER JOIN TripSavedDeals TSD ON D.TripSavedDealKey = TSD.TripSavedDealKey        
 GROUP BY T.tripKey, T.siteKey, T.tripSavedKey, T.StartDate, T.EndDate, T.Origin, T.Destination, T.CreatedOn, T.tripComponentType,         
  T.tripComponents, SC.siteName, TSD.tripKey , T.tripTo, CityName, StateCode, CountryCode, FromCity, ToCity, ToCountryName       
        
        
---------------------------- DESTINATION IMAGES STARTS ----------------------------            
/*            
 SELECT DISTINCT TD.tripTo      
 INTO #tmpTripTo            
 FROM @Tripdetails TD            
*/      
      
      
INSERT INTO @TripHotelGroup      
SELECT  TR.tripToHotelGroupId, TR.tripTo1  , '' as URL      
FROM TripRequest TR      
INNER JOIN @Tripdetails TD ON TR.tripRequestKey = TD.TripRequestKey      
       
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
        
  PRINT 'HI' + @Url      
        
  /* IF PICKING RANDOM IMAGE FROM DESTINATION PAGE FAILS THEN TAKE TOP 1 IMAGE ORDER BY ORDERID ASC FROM DESTINATION PAGE*/      
  IF @Url IS NULL OR @Url = ''      
  BEGIN       
      
    SELECT TOP 1 @Url = ImageURL FROM CMS..Destination D           
    INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId               
    WHERE DI.IsEnabled = 1        
    AND D.AptCode = @AptCode       
    ORDER BY OrderId ASC        
          
    PRINT 'BYE' + @Url      
         
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
 SELECT OrderId, AptCode, ImageURL FROM CMS..Destination            
 INNER JOIN CMS..DestinationImages ON CMS..Destination.DestinationId = CMS..DestinationImages.DestinationId            
 INNER JOIN #tmpTripTo ON CMS..Destination.AptCode = #tmpTripTo.tripTo            
 ORDER BY AptCode, OrderId            
 */      
            
 ---------------------------- DESTINATION IMAGES ENDS ----------------------------              
        
END
GO
