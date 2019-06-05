SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
      
-- =============================================      
-- Author:  Anupam Patel       
-- Create date: 29/May/2015      
-- Description: It is used to get trip likes for timeline       
-- Exec USP_GetTripDealsForTimeline null
    
--Updated by manoj on 12th jan 2016: Include crowd userId and other trip information.     
--Updated by vivek on 07th apr 2017: Change of query for the calculation of TripSavings. 
-- Updated by vivek on 01st jun 2017: Change of query for totalAmount calculation of deals. 
-- =============================================      
CREATE PROCEDURE [dbo].[USP_GetTripDealsForTimeline]    
(
 -- Add the parameters for the stored procedure here      
  @StartDate Datetime = NULL
)
	AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
       
 CREATE TABLE #TimeLineTripDeal            
 (                                
  -- TripdetailsKey int identity (1,1) ,                                
  userKey bigint NULL,                                                              
  tripKey bigint NULL,                                            
  tripstartdate datetime NULL ,                                
  tripenddate datetime NULL ,                                
  toCountryName varchar(1000) NULL ,                                
  toStateCode varchar(20) NULL ,                                
  toCityName varchar(20) NULL ,                                
  LatestAirLineCode varchar(100) NULL ,                                                  
  LatestHotelChainCode varchar(100) NULL ,                                                  
  CarVendorCode varchar(10) NULL,
  LatestCarVendorName varchar(100) NULL,
  DestinationSmallImageURL varchar(2000) NULL,
  TotalSavings float NULL,
  lastUpdatedDate  datetime NULL , 
  originAirportCode nvarchar(100) NULL,
  TotalAmount float NULL,    
  privacyType int NULL,
  UserName varchar(100) NULL,
  ImageURL nvarchar(2000) NULL,
  EventKey bigint DEFAULT(0),
  NoOfComments nvarchar(1000) NULL,
  fromCityName varchar(100) NULL,
  DestinationAirportCode varchar(10) NULL,
  tripComponents varchar(100) NULL,
  FromAirportCode varchar(100) NULL,
  ToAirportCode varchar(100) NULL,
  LatestAirlineName varchar(100) NULL,
  AirRequestTypeName varchar(50) NULL,
  AirCabin varchar(50) NULL,
  HotelRating float(8) NULL,
  HotelName varchar(100) NULL,
  CarClass varchar(50) NULL,
  HotelChainName varchar(max) NULL,
  NumberOfCurrentAirStops int default(0),
  HotelRegionName varchar(100) null
 )        
 
 CREATE TABLE #TripDealsData
 (
 TripKey BIGINT, 
 ComponentType INT, 
 CreationDate DATETIME
 )

INSERT INTO #TripDealsData
SELECT TripKey, ComponentType, MAX(CreationDate) 
FROM TripSavedDeals
GROUP BY TripKey, ComponentType

DELETE FROM #TripDealsData WHERE TripKey IS NULL OR TripKey = 0

--SELECT * FROM #TripDealsData ORDER BY TripKey

CREATE TABLE #TripDealAir 
(
TripKey BIGINT, 
CreationDate DATETIME, 
currentTotalPrice FLOAT
)

INSERT INTO #TripDealAir 
SELECT t.TripKey, t.CreationDate, TSD.currentTotalPrice
From #TripDealsData t
INNER JOIN TripSavedDeals TSD ON t.TripKey = TSD.tripKey AND t.CreationDate = TSD.CreationDate 
WHERE TSD.ComponentType = 1


CREATE TABLE #TripDealCar 
(
TripKey BIGINT, 
CreationDate DATETIME, 
currentTotalPrice FLOAT
)

INSERT INTO #TripDealCar 
SELECT t.TripKey, t.CreationDate, TSD.currentTotalPrice
From #TripDealsData t
INNER JOIN TripSavedDeals TSD ON t.TripKey = TSD.tripKey AND t.CreationDate = TSD.CreationDate 
WHERE TSD.ComponentType = 2

CREATE TABLE #TripDealHotel 
(
TripKey BIGINT, 
CreationDate DATETIME, 
currentTotalPrice FLOAT
)

INSERT INTO #TripDealHotel 
SELECT t.TripKey, t.CreationDate, TSD.currentTotalPrice
From #TripDealsData t
INNER JOIN TripSavedDeals TSD ON t.TripKey = TSD.tripKey AND t.CreationDate = TSD.CreationDate 
WHERE TSD.ComponentType = 4
 
 
 INSERT INTO #TripDealsData(tripKey,CreationDate)
 SELECT tripKey,MAX(creationDate) creationDate FROM TripSavedDeals WHERE tripKey IS NOT NULL AND tripKey NOT IN(0)
 GROUP BY tripKey
 
 
      DECLARE @airDeal FLOAT = 0
      DECLARE @carDeal FLOAT = 0
      DECLARE @hotelDeal FLOAT = 0
     INSERT INTO  #TimeLineTripDeal(
      userKey ,                                                              
	  tripKey,                                            
	  tripstartdate  ,                                
	  tripenddate  ,                                
	  toCountryName ,                                
	  toStateCode ,                                
	  toCityName ,                                
	  LatestAirLineCode  ,                                                  
	  LatestHotelChainCode,                                                  
	  CarVendorCode ,
	  LatestCarVendorName ,
	  DestinationSmallImageURL ,
	  TotalSavings ,
	  lastUpdatedDate  , 
	  originAirportCode ,
	  TotalAmount ,    
	  privacyType ,
	  UserName ,
	  ImageURL ,
	  EventKey ,
	  NoOfComments ,
	  fromCityName ,
	  DestinationAirportCode ,
	  tripComponents,
	  FromAirportCode,
	  ToAirportCode,
	  LatestAirlineName ,
	  AirRequestTypeName ,
	  AirCabin,
	  HotelRating ,
	  HotelName ,
	  CarClass,
	  HotelChainName,
	  NumberOfCurrentAirStops,
	  HotelRegionName 
     )
     SELECT U.userKey, 
     TD.tripKey,      
     TD.tripStartDate,
     TD.tripEndDate,
     [toCountryName],
     [toStateCode],
     [toCityName],
     [LatestAirLineCode],
     COALESCE(NULLIF(LatestHotelChainCode,''), 'DefaultHotel'),
     [CarVendorCode],
     [LatestCarVendorName],
      T.DestinationSmallImageURL,
	(CASE WHEN ISNULL(latestDealAirPriceTotal,0) > 0 AND latestDealAirPriceTotal < originalTotalPriceAir THEN (originalTotalPriceAir - latestDealAirPriceTotal) else 0 end)
	+
	( case WHEN ISNULL(latestDealHotelPriceTotal,0) > 0 AND latestDealHotelPriceTotal < originalTotalPriceHotel THEN (originalTotalPriceHotel - latestDealHotelPriceTotal) else 0 end)
	+
	(case WHEN ISNULL(latestDealCarPriceTotal,0) > 0 AND latestDealCarPriceTotal < originalTotalPriceCar THEN (originalTotalPriceCar - latestDealCarPriceTotal) else 0 end)  as TotalSavings
      --(ISNULL(originalTotalPriceAir,0) + ISNULL(originalTotalPriceHotel,0) + ISNULL(originalTotalPriceCar,0)) - (ISNULL(latestDealAirPriceTotal,0) + ISNULL(latestDealHotelPriceTotal,0) + ISNULL(latestDealCarPriceTotal,0)) TotalSavings,
  --    CASE 
		--WHEN (ISNULL(latestDealAirPriceTotal,0)) = 0 and (ISNULL(latestDealHotelPriceTotal,0))=0 and (ISNULL(latestDealCarPriceTotal,0)) = 0 
		--THEN 0
		--ELSE (ISNULL(originalTotalPriceAir,0) + ISNULL(originalTotalPriceHotel,0) + ISNULL(originalTotalPriceCar,0)) - (ISNULL(latestDealAirPriceTotal,0) + ISNULL(latestDealHotelPriceTotal,0) + ISNULL(latestDealCarPriceTotal,0)) END TotalSavings
      --(ISNULL(latestDealAirSavingsTotal,0) + ISNULL(latestDealHotelSavingsTotal,0) + ISNULL(latestDealCarSavingsTotal,0)) TotalSavings    
     , lastUpdatedDate, 
     A.originAirportCode      
     ,--(ISNULL(latestDealHotelPriceTotal,0) + ISNULL(latestDealCarPriceTotal,0) + ISNULL(latestDealAirPriceTotal,0)) TotalAmount,    
     CASE 
		WHEN (ISNULL(latestDealHotelPriceTotal,0)) = 0 and (ISNULL(latestDealCarPriceTotal,0))=0 and (ISNULL(latestDealAirPriceTotal,0)) = 0 
		THEN (ISNULL(originalPerPersonPriceHotel,0) + ISNULL(originalPerPersonPriceCar,0) + ISNULL(originalPerPersonPriceAir,0)) 
		ELSE (CASE WHEN (ISNULL(latestDealHotelPriceTotal,0)) = 0 THEN ISNULL(TDH.currentTotalPrice,0) ELSE  latestDealHotelPriceTotal END)
		+ (CASE WHEN (ISNULL(latestDealCarPriceTotal,0)) = 0 THEN ISNULL(TDC.currentTotalPrice,0) ELSE latestDealCarPriceTotal END)
		+ (CASE WHEN (ISNULL(latestDealAirPriceTotal,0)) = 0 THEN ISNULL(TDA.currentTotalPrice,0) ELSE latestDealAirPriceTotal END) END TotalAmount,
      T.privacyType,
     (U.userFirstName + ' ' + SUBSTRING(U.userLastName,1,1) + '.') As UserName, 
     UM.ImageURL,0 As EventKey, 
     NoOfComments, 
     fromCityName,
     TD.TripTo As DestinationAirportCode,   
     CASE                           
      WHEN t.tripComponentType = 1 THEN 'Air'                          
      WHEN t.tripComponentType = 2 THEN 'Car'                          
      WHEN t.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN t.tripComponentType = 4 THEN 'Hotel'                          
      WHEN t.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN t.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN t.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents  ,
      COALESCE([fromCityName],'') + ', ' + COALESCE([fromStateCode],'') + ' [' + TD.tripFrom + ']' AS FromAirportCode,
      COALESCE([toCityName],'') + ', ' + COALESCE([toStateCode],'') + ' [' + TD.TripTo +']' AS ToAirportCode,
      TD.LatestAirlineName, TD.AirRequestTypeName, TD.AirCabin, TD.HotelRating, TD.HotelName, TD.CarClass,COALESCE(HC.ChainName,TD.HotelName),TD.NumberOfCurrentAirStops,TD.HotelRegionName
           
  FROM Vault..[User] U       
  INNER JOIN Loyalty..UserMap UM ON U.userKey = UM.UserId AND U.IsDeleted = 0      
  LEFT OUTER JOIN  (SELECT Distinct UserKey,originAirportCode      
       From [Vault].[dbo].[AirPreference]      
       Where UserKey > 0      
       Group By UserKey,originAirportCode) A ON A.userKey = U.userKey      
  LEFT OUTER Join [Trip].[dbo].[TripDetails] TD ON U.userKey = TD.userKey       
  INNER JOIN [Trip].[dbo].[Trip] T ON TD.tripKey = T.tripKey AND T.tripStatusKey <> 17 AND T.isUserCreatedSavedTrip = 1     
  INNER JOIN TripSaved TS WITH(NOLOCK) ON T.tripSavedKey =TS. tripSavedKey    
  --LEFT OUTER JOIN AttendeeTravelDetails AD ON AD.attendeeTripKey = T.tripKey  
  --LEFT OUTER JOIN EventAttendees EA ON EA.eventAttendeeKey = AD.eventAttendeekey  
  --LEFT OUTER JOIN [Events] EV ON EV.eventKey = EA.eventkey 
  LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode
  LEFT OUTER JOIN (
		 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
  ) CM ON CM.tripKey = T.tripKey  
  LEFT OUTER JOIN #TripDealAir TDA ON TDA.TripKey = T.tripKey
  LEFT OUTER JOIN #TripDealCar TDC ON TDC.TripKey = T.tripKey
  LEFT OUTER JOIN #TripDealHotel TDH ON TDH.TripKey = T.tripKey
    
  WHERE (@StartDate is Null OR TD.lastUpdatedDate > @StartDate) 
  AND Convert(Date,TD.lastUpdatedDate)= Convert(Date,GETDATE()) 
        
  UNION      
        SELECT U.userKey, 
        TD.tripKey,      
        TD.tripStartDate,
        TD.tripEndDate,
        [toCountryName],
        [toStateCode],
        [toCityName],
        [LatestAirLineCode],
        COALESCE(NULLIF(LatestHotelChainCode,''), 'DefaultHotel'),
        [CarVendorCode],
        [LatestCarVendorName]      
     , '',
     (CASE WHEN ISNULL(latestDealAirPriceTotal,0) > 0 AND latestDealAirPriceTotal < originalTotalPriceAir THEN (originalTotalPriceAir - latestDealAirPriceTotal) else 0 end)
	+
	( case WHEN ISNULL(latestDealHotelPriceTotal,0) > 0 AND latestDealHotelPriceTotal < originalTotalPriceHotel THEN (originalTotalPriceHotel - latestDealHotelPriceTotal) else 0 end)
	+
	(case WHEN ISNULL(latestDealCarPriceTotal,0) > 0 AND latestDealCarPriceTotal < originalTotalPriceCar THEN (originalTotalPriceCar - latestDealCarPriceTotal) else 0 end)  as TotalSavings
     --(ISNULL(originalTotalPriceAir,0) + ISNULL(originalTotalPriceHotel,0) + ISNULL(originalTotalPriceCar,0)) - (ISNULL(latestDealAirPriceTotal,0) + ISNULL(latestDealHotelPriceTotal,0) + ISNULL(latestDealCarPriceTotal,0)) TotalSavings
  --   CASE 
		--WHEN (ISNULL(latestDealAirPriceTotal,0)) = 0 and (ISNULL(latestDealHotelPriceTotal,0))=0 and (ISNULL(latestDealCarPriceTotal,0)) = 0 
		--THEN 0
		--ELSE (ISNULL(originalTotalPriceAir,0) + ISNULL(originalTotalPriceHotel,0) + ISNULL(originalTotalPriceCar,0)) - (ISNULL(latestDealAirPriceTotal,0) + ISNULL(latestDealHotelPriceTotal,0) + ISNULL(latestDealCarPriceTotal,0)) END TotalSavings
     --(ISNULL(latestDealAirSavingsTotal,0) + ISNULL(latestDealHotelSavingsTotal,0) + ISNULL(latestDealCarSavingsTotal,0)) TotalSavings      
     , lastUpdatedDate,
      A.originAirportCode      
     ,--(ISNULL(latestDealHotelPriceTotal,0) + ISNULL(latestDealCarPriceTotal,0) + ISNULL(latestDealAirPriceTotal,0)) TotalAmount, 
     CASE 
		WHEN (ISNULL(latestDealHotelPriceTotal,0)) = 0 and (ISNULL(latestDealCarPriceTotal,0))=0 and (ISNULL(latestDealAirPriceTotal,0)) = 0 
		THEN (ISNULL(originalPerPersonPriceHotel,0) + ISNULL(originalPerPersonPriceCar,0) + ISNULL(originalPerPersonPriceAir,0)) 
		--ELSE (ISNULL(latestDealHotelPriceTotal,0) + ISNULL(latestDealCarPriceTotal,0) + ISNULL(latestDealAirPriceTotal,0)) END TotalAmount, 
		ELSE (CASE WHEN (ISNULL(latestDealHotelPriceTotal,0)) = 0 THEN ISNULL(TDH.currentTotalPrice,0) ELSE  latestDealHotelPriceTotal END)
		+ (CASE WHEN (ISNULL(latestDealCarPriceTotal,0)) = 0 THEN ISNULL(TDC.currentTotalPrice,0) ELSE latestDealCarPriceTotal END)
		+ (CASE WHEN (ISNULL(latestDealAirPriceTotal,0)) = 0 THEN ISNULL(TDA.currentTotalPrice,0) ELSE latestDealAirPriceTotal END) END TotalAmount,    
     T.privacyType,
     (U.userFirstName + ' ' + SUBSTRING(U.userLastName,1,1) + '.') As UserName, 
     UM.ImageURL,
     0 As EventKey, 
     NoOfComments, fromCityName, 
     TD.TripTo As DestinationAirportCode,       
     CASE                           
      WHEN t.tripComponentType = 1 THEN 'Air'                          
      WHEN t.tripComponentType = 2 THEN 'Car'                          
      WHEN t.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN t.tripComponentType = 4 THEN 'Hotel'                          
      WHEN t.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN t.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN t.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents ,
     COALESCE([fromCityName],'') + ', ' + COALESCE([fromStateCode],'') + ' [' + TD.tripFrom + ']' AS FromAirportCode,
      COALESCE([toCityName],'') + ', ' + COALESCE([toStateCode],'') + ' [' + TD.TripTo +']' AS ToAirportCode ,
      TD.LatestAirlineName, TD.AirRequestTypeName, TD.AirCabin, TD.HotelRating, TD.HotelName, TD.CarClass ,COALESCE(HC.ChainName,TD.HotelName),TD.NumberOfCurrentAirStops,TD.HotelRegionName
           
  FROM Vault..[User] U       
  INNER JOIN Loyalty..UserMap UM ON U.userKey = UM.UserId AND U.IsDeleted = 0       
  LEFT OUTER JOIN  (SELECT Distinct UserKey,originAirportCode      
       From [Vault].[dbo].[AirPreference]      
       Where UserKey > 0      
       Group By UserKey,originAirportCode) A ON A.userKey = U.userKey      
  LEFT OUTER Join [Trip].[dbo].[TripDetails] TD ON U.userKey = TD.userKey AND Convert(Date,TD.lastUpdatedDate)= Convert(Date,GETDATE())  
  LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode    
  INNER JOIN [Trip].[dbo].[Trip] T ON TD.tripKey = T.tripKey AND T.tripStatusKey <> 17   AND T.isUserCreatedSavedTrip = 1      
  INNER JOIN TripSaved TS WITH(NOLOCK) ON T.tripSavedKey =TS. tripSavedKey    
  --LEFT OUTER JOIN AttendeeTravelDetails AD ON AD.attendeeTripKey = T.tripKey 
  --LEFT OUTER JOIN EventAttendees EA ON EA.eventAttendeeKey = AD.eventAttendeekey 
  --LEFT OUTER JOIN [Events] EV ON EV.eventKey = EA.eventkey   
  LEFT OUTER JOIN (
		 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
  ) CM ON CM.tripKey = T.tripKey  
  LEFT OUTER JOIN #TripDealAir TDA ON TDA.TripKey = T.tripKey
  LEFT OUTER JOIN #TripDealCar TDC ON TDC.TripKey = T.tripKey
  LEFT OUTER JOIN #TripDealHotel TDH ON TDH.TripKey = T.tripKey
       
  Where TD.tripKey is null 
 Order by TD.lastUpdatedDate desc        
          
          
  SELECT * FROM 
  (
    SELECT ROW_NUMBER() OVER (PARTITION BY tripKey ORDER BY tripkey,userkey DESC) AS ID, TD.* FROM #TimeLineTripDeal TD  
  )TD WHERE TD.ID = 1
DROP TABLE #TimeLineTripDeal          
END
GO
