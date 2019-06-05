SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--declare @LastDATETIme datetime = getdate()
--select GETDATE(),  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
 --Set @LastDATETIme = GetDate()
--exec usp_GetMerchandiseTripWithFilters_New_Org_20131028 @cityCode=N'BOM',@siteKey=1,@cityType=N'From',@resultCount=12,@tripComponentType=0,@page=1,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@typeFilter=N'',@loggedInUserKey=0,@FromIndex=1,@ToIndex=12
--select GETDATE(),  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
 --Set @LastDATETIme = GetDate()
--exec usp_GetMerchandiseTripWithFilters_New_Org_20131029 @cityCode=N'BOM',@siteKey=1,@cityType=N'From',@resultCount=12,@tripComponentType=0,@page=1,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@typeFilter=N'',@loggedInUserKey=0,@FromIndex=1,@ToIndex=12
--select GETDATE(),  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
 --Set @LastDATETIme = GetDate()
	-- exec usp_GetMerchandiseTripWithFilters_New @cityCode=N'DAL',@siteKey=1,@cityType=N'From',@resultCount=12,@tripComponentType=0,@page=1,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@loggedInUserKey=0,@FromIndex=1,@ToIndex=12,@typeFilter=''
	-- exec usp_GetMerchandiseTripWithFilters_New 'SFO','From' ,5,12,0,1,0,NULL,0,'','','HotelOnly',0, 1, 10
	-- 560551
	-- 560800
	CREATE PROC [dbo].[usp_GetMerchandiseTripWithFilters_New] (
	--declare --Modified
	@cityCode varchar(20) = NULL ,                    
	@cityType varchar ( 20) = 'From' ,                    
	@siteKey int ,                     
	@resultCount int = 6 ,                    
	@tripComponentType INT = 0,      
	@page INT   ,    
	@tripKey INT=0,
	@startDate datetime=null ,
	@theme int = 0,
	@sortfield varchar(50) = '',
	@friendOption VARCHAR(50) = '',
	@typeFilter VARCHAR(50) = '',
	@loggedInUserKey BIGINT = 0,
	@FromIndex INT = 1,
	@ToIndex INT = 1     
	) AS BEGIN 
	--select @cityCode=N'DAL',@siteKey=1,@cityType=N'From',@resultCount=12,@tripComponentType=0,@page=1,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@loggedInUserKey=0,@FromIndex=1,@ToIndex=12
	--Select @cityCode=N'BOM',@siteKey=1,@cityType=N'From',@resultCount=12,@tripComponentType=0,@page=1,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@typeFilter=N'',@loggedInUserKey=0,@FromIndex=1,@ToIndex=12

	DECLARE @endDate DATETIME 
	DECLARE @otherTrips as bit = 0               
	DECLARE @RowNumber INT = 0
	DECLARE @HotelRating1 FLOAT = -1
	DECLARE @HotelRating2 FLOAT = -1
	DECLARE @IsTypeFilterSelected BIT = 0
	
	DECLARE @PreferredCityList AS TABLE
	(
		CityCode VARCHAR(3),
		CityName VARCHAR(100)	
	)
	DECLARE @NeighboringAirportLookup AS TABLE
	(
		neighborAirportCode VARCHAR(3)
	)
	
	 
		
	 
		IF @typeFilter <> '' 
		  BEGIN 
				PRINT '@IsTypeFilterSelected = TRUE' 				
				SET @IsTypeFilterSelected = 1
		  END

		 IF @cityCode = ''                    
		 BEGIN                    
				SET @cityCode = NULL                    
				
				INSERT INTO @NeighboringAirportLookup
				SELECT neighborAirportCode FROM NeighboringAirportLookup
				WHERE distanceInMiles <= 100
				
		 END
		 ELSE
		 BEGIN
				INSERT INTO @NeighboringAirportLookup
				SELECT neighborAirportCode FROM NeighboringAirportLookup
				WHERE airportCode = @cityCode
				AND distanceInMiles <= 100
		 END			                      
	      
		  IF @startDate IS NULL 
		  BEGIN 
				  SET @startDate = CONVERT(DATETIME, '1753-01-01 00:00:00', 20)
				  SET @endDate = '9999-12-31' -- THIS IS MAX DATE 
		  END
		  ELSE 
		  BEGIN 
				SELECT @endDate = DATEADD(month, ((YEAR(@startDate) - 1900) * 12) + MONTH(@startDate), -1)								  		  
				--SET @endDate = DATEADD(day,1,@endDate)
				SET @endDate = DATEADD(SECOND, 86399,@endDate) -- THIS WILL MAKE TIME UPTO 23:59:59
				PRINT @endDate
		  END               
					 
				
					            
		  IF @startDate < GETDATE()
		  BEGIN 
				SET @startDate = CONVERT(DATETIME, GETDATE(), 20)
		  END		  
		 
		INSERT INTO @PreferredCityList   
		SELECT * FROM 
		(
		SELECT 'AMS' as CityCode , 'Amsterdam' as CityName
		UNION
		SELECT 'ANA' as CityCode , 'Anaheim' as CityName
		UNION	
		SELECT 'BCN' as CityCode , 'Barcelona' as CityName
		UNION	
		SELECT 'CSL' as CityCode , 'Cabo San Lucas' as CityName
		UNION	
		SELECT 'CUN' as CityCode , 'Cancun, Mexico' as CityName
		UNION	
		SELECT 'ORD' as CityCode , 'Chicago' as CityName
		UNION	
		SELECT 'FLL' as CityCode , 'Fort Lauderdale' as CityName
		UNION	
		SELECT 'HKG' as CityCode , 'Hong Kong' as CityName
		UNION	
		SELECT 'HNL' as CityCode , 'Honolulu' as CityName
		UNION
		SELECT 'LAS' as CityCode , 'Las Vegas' as CityName
		UNION	
		SELECT 'LON' as CityCode , 'London' as CityName
		UNION	
		SELECT 'LAX' as CityCode , 'Los Angeles' as CityName
		UNION	
		SELECT 'OGG' as CityCode , 'Maui' as CityName
		UNION	
		SELECT 'MIA' as CityCode , 'Miami' as CityName
		UNION	
		SELECT 'MBJ' as CityCode , 'Montego Bay, Jamaica' as CityName
		UNION		
		SELECT 'NYC' as CityCode , 'New York City' as CityName
		UNION		
		SELECT 'ORL' as CityCode , 'Orlando' as CityName
		UNION		
		SELECT 'PAR' as CityCode , 'Paris' as CityName
		UNION		
		SELECT 'PHX' as CityCode , 'Phoenix' as CityName
		UNION			
		SELECT 'PUJ' as CityCode , 'Punta Cana, Dominican Republic' as CityName
		UNION			
		SELECT 'ROM' as CityCode , 'Rome' as CityName
		UNION			
		SELECT 'SFO' as CityCode , 'San Francisco' as CityName
		UNION			
		SELECT 'SYD' as CityCode , 'Sydney, Australia' as CityName
		UNION				
		SELECT 'TPA' as CityCode , 'Tampa' as CityName
		UNION					
		SELECT 'WAS' as CityCode , 'Washington D.C.' as CityName

		) as City ORDER BY City.CityName ASC 	
		  
		  
		  
		  
		  IF (UPPER(@typeFilter) = 'PACKAGE5STAR' OR UPPER(@typeFilter) = 'HOTELONLY5STAR')
		  BEGIN 		
				SET @HotelRating1 = 5
				SET @HotelRating2 = 5
		  END 
		  ELSE IF (UPPER(@typeFilter) = 'PACKAGE4STAR' OR UPPER(@typeFilter) = 'HOTELONLY4STAR')
		  BEGIN 
				SET @HotelRating1 = 4
				SET @HotelRating2 = 4.5
		  END  
		  ELSE IF (UPPER(@typeFilter) = 'PACKAGE3STAR' OR UPPER(@typeFilter) = 'HOTELONLY3STAR')
		  BEGIN 
				SET @HotelRating1 = 3
				SET @HotelRating2 = 3.5
		  END  
		  
		  
	                     
		 DECLARE @Tripdetails AS TABLE                     
		 (                    
		  TripdetailsKey int identity (1,1) ,                    
		  tripKey int NULL,                    
		  tripsavedKey uniqueidentifier NULL ,                    
		  triprequestkey int NULL ,                    
		  tripstartdate datetime NULL ,                    
		  tripenddate datetime NULL ,                    
		  tripfrom varchar(20) NULL ,                    
		  tripTo varchar(20) NULL ,                    
		  tripComponentType int NULL ,    
		  tripComponents varchar(100) NULL ,                                      
		  rankRating float NULL ,                    
		  tripAirsavings float NULL ,                      
		  tripcarsavings float NULL ,                    
		  triphotelsavings float NULL,                    
		  isOffer bit  NULL,                    
		  OfferImageURL varchar(500) NULL,    
		  LinktoPage varchar(500) NULL,  
		  currentTotalPrice FLOAT NULL,  
		  UserName VARCHAR(200),
		  FacebookUserUrl VARCHAR(500),
		  WatchersCount INT,
		  LikeCount INT ,
		  ThemeType INT DEFAULT(0),
		  IsWatcher BIT DEFAULT(0),
		  BookersCount INT DEFAULT(0),
		  TripPurchaseKey uniqueidentifier NULL,
		  FastestTrending FLOAT NULL,
		  TotalSavings FLOAT,
		  RowNumber INT,
		  Rating FLOAT,
		  AirSegmentCabinAbbrevation VARCHAR(50),
		  AirSegmentCabin VARCHAR(50),
		  CarClassAbbrevation VARCHAR(100),
		  CarClass VARCHAR(100),
		  AirRequestTypeName VARCHAR(50),
		  NoOfStops VARCHAR(20),
		  HotelRegionName VARCHAR(100),
		  TripScoring FLOAT,
		  DestinationImageURL VARCHAR(200)	   
		  
		 )
		
		
		DECLARE @TripdetailsFinal AS TABLE                     
		 (                    
		  TripdetailsKey int ,                    
		  tripKey int NULL,                    
		  tripsavedKey uniqueidentifier NULL ,                    
		  triprequestkey int NULL ,                    
		  tripstartdate datetime NULL ,                    
		  tripenddate datetime NULL ,                    
		  tripfrom varchar(20) NULL ,                    
		  tripTo varchar(20) NULL ,                    
		  tripComponentType int NULL ,    
		  tripComponents varchar(100) NULL ,                                      
		  rankRating float NULL ,                    
		  tripAirsavings float NULL ,                      
		  tripcarsavings float NULL ,                    
		  triphotelsavings float NULL,                    
		  isOffer bit  NULL,                    
		  OfferImageURL varchar(500) NULL,    
		  LinktoPage varchar(500) NULL,  
		  currentTotalPrice FLOAT NULL,  
		  UserName VARCHAR(200),
		  FacebookUserUrl VARCHAR(500),
		  WatchersCount INT,
		  LikeCount INT ,
		  ThemeType INT DEFAULT(0),
		  IsWatcher BIT DEFAULT(0),
		  BookersCount INT DEFAULT(0),
		  TripPurchaseKey uniqueidentifier NULL,
		  FastestTrending FLOAT NULL,
		  TotalSavings FLOAT,
		  RowNumber INT,
		  Rating FLOAT,
		  AirSegmentCabinAbbrevation VARCHAR(50),
		  AirSegmentCabin VARCHAR(50),
		  CarClassAbbrevation VARCHAR(100),
		  CarClass VARCHAR(100),
		  AirRequestTypeName VARCHAR(50),
		  NoOfStops VARCHAR(20),
		  HotelRegionName VARCHAR(100),
		  TripScoring FLOAT,
		  DestinationImageURL VARCHAR(200) 	   
		  
		 )
		 
		DECLARE @Tbl_RecommendedTripsSavings As Table  
		 (   
		 tripKey INT  
		 ,tripSavedKey UNIQUEIDENTIFIER  
		 ,TripComponentType INT  
		 ,currentPrice FLOAT  
		 ,originalPrice FLOAT  
		 ,originalTotalPrice FLOAT  
		 ,currentTotalPrice FLOAT  
		 ,OriginAirportCode VARCHAR(50)  
		 ,DestinationAirportCode VARCHAR(50)  
		 ,AdultCount INT  
		 ,ChildCount INT  
		 ,savings FLOAT
		 ,userKey BIGINT	 
		 ,SavingsRanking FLOAT
		 ,Recency FLOAT
		 ,RecencyRanking FLOAT
		 ,Proximity INT
		 ,ProximityRanking FLOAT
		 ,SocialRanking FLOAT 
		 ,TripScoring FLOAT   ,
		  Rating FLOAT,
		  HotelRegionName VARCHAR(100)
		 ) 
		 
		 DECLARE @ConnectionsUserInfo AS TABLE 
		 (
			UserId BIGINT
		 )
		 DECLARE @ConnectionsUserSaveTripInfo AS TABLE 
		 (
			 tripKey INT,
			 tripSavedKey UNIQUEIDENTIFIER,
			 userKey BIGINT
			 
		 )
		 
		IF (@friendOption = 'OnlyMe')
		BEGIN 
			
			PRINT 'Inside OnlyMe'
			INSERT INTO @ConnectionsUserInfo
			(UserId)
			VALUES
			(
				@loggedInUserKey
			)

		END    
		ELSE IF (@friendOption = 'Connections')
		BEGIN 
			
			PRINT 'Inside Connections'
-- SELECT GetDate() [1]			
			INSERT INTO @ConnectionsUserInfo (UserId)
			SELECT UserId FROM Loyalty..UserMap
			WHERE ParentId = @loggedInUserKey
			AND @loggedInUserKey <> 0
-- SELECT GetDate() [2]

		END 
		ELSE IF (@friendOption = 'ConnectionAndFollow')
		BEGIN 

			PRINT 'Inside ConnectionAndFollow'
			
			INSERT INTO @ConnectionsUserInfo
			(UserId)
			VALUES
			(
				@loggedInUserKey
			)
-- SELECT GetDate() [2]
			
			INSERT INTO @ConnectionsUserInfo (UserId)
			SELECT UserId FROM Loyalty..UserMap
			WHERE ParentId = @loggedInUserKey	
			AND @loggedInUserKey <> 0
-- SELECT GetDate() [3]
		END

-- SELECT GetDate() [4]
		INSERT INTO @ConnectionsUserSaveTripInfo
		(
			tripSavedKey,
			tripKey,
			userKey
		)	
		SELECT DISTINCT tripSavedKey, tripKey, userKey FROM Trip WITH (NOLOCK)
		INNER JOIN @ConnectionsUserInfo CUI ON Trip.userKey = CUI.UserId   
-- SELECT GetDate() [5]

	 DECLARE @tblDerived AS TABLE 
		 (
			 tripSavedKey UNIQUEIDENTIFIER,
			 Recency int
		 )
-- SELECT GetDate() [6]		 
	INsert into @tblDerived	 (tripSavedKey,Recency)
	SELECT TS.tripSavedKey, DATEDIFF(day,MAX(T.CreatedDate),GETDATE()) as Recency	
				  FROM trip T WITH (NOLOCK) inner join TripSaved TS WITH (NOLOCK) on T.tripSavedKey = TS.tripSavedKey 
				  where siteKey =@siteKey and T.tripStatusKey <> 17
				  AND T.IsWatching = 1        
				  Group by TS.tripSavedKey  
				  
-- SELECT GetDate() [7]		 
----- Code Start here 
DECLARE @VW_TSD1 AS TABLE
(
	 TripSavedDealKey int
	,tripKey int
	,componentType int
)
-- SELECT GetDate() [7_A]
Insert Into @VW_TSD1 (TripSavedDealKey, tripKey, componentType)
SELECT  MAX(TSD1.TripSavedDealKey) TripSavedDealKey
							,TSD1.tripKey
							,TSD1.componentType
					FROM	 TripSavedDeals TSD1 
					GROUP BY TSD1.TripKey, TSD1.componentType
					

--ALTER VIEW [dbo].[vw_RecommendedTripsSavings] as

--SELECT	tripKey
--		,tripSavedKey
--		,SUM(TripComponentType) TripComponentType
--		,SUM(currentPrice) currentPrice
--		,SUM(originalPrice) originalPrice
--		,SUM(originalTotalPrice) originalTotalPrice
--		,SUM(currentTotalPrice) currentTotalPrice
--		,OriginAirportCode
--		,DestinationAirportCode
--		,AdultCount
--		,ChildCount
--		,(SUM(currentPrice) - SUM(originalPrice)) As savings
--FROM  
--(

DECLARE @VW_T AS TABLE
(
	 tripKey int 
	,tripSavedKey uniqueidentifier
	,TripComponentType int
	,currentPrice float
	,originalPrice float
	,originalTotalPrice float
	,currentTotalPrice float
	,OriginAirportCode varchar(50)
	,DestinationAirportCode varchar(50)
	,AdultCount int
	,ChildCount int
)


DECLARE @VW_T_Sum AS TABLE
(
	 tripKey int 
	,tripSavedKey uniqueidentifier
	,TripComponentType int
	,currentPrice float
	,originalPrice float
	,originalTotalPrice float
	,currentTotalPrice float
	,OriginAirportCode varchar(50)
	,DestinationAirportCode varchar(50)
	,AdultCount int
	,ChildCount int
	,savings float
)
-- SELECT GetDate() [7_b]
---- SELECT GetDate() [2]
Insert Into @VW_T (tripKey, tripSavedKey,TripComponentType,currentPrice,originalPrice,originalTotalPrice,currentTotalPrice,OriginAirportCode,DestinationAirportCode,AdultCount,ChildCount)
SELECT	 T.tripKey
		,T.tripSavedKey
		,TSD.componenttype TripComponentType
        ,(Case when  TSD.componentType = 1 then  TSD.currentPerPersonPrice ELSE TSD.currentTotalPrice END )  As currentPrice
		,(Case when  TSD.componentType = 1 then  TSD.originalPerPersonPrice ELSE TSD.originalTotalPrice END) As originalPrice
		,(Case when TSD.componentType = 4 then (TSD.originalTotalPrice * t.noOfRooms )ELSE TSD.originalTotalPrice END) originalTotalPrice
		,(Case when TSD.componentType = 4 then (TSD.currentTotalPrice *t.noOfRooms )ELSE TSD.currentTotalPrice END )currentTotalPrice
		,TR.tripFrom1 OriginAirportCode
		,TR.tripTo1 DestinationAirportCode
		,T.tripAdultsCount AdultCount
        ,T.tripChildCount ChildCount
FROM	 Trip T
         LEFT OUTER JOIN TripRequest  TR ON T.tripRequestKey = TR.tripRequestKey  
         LEFT OUTER JOIN Tripsaveddeals TSD ON (t.tripKey = tsd.tripKey)
         INNER JOIN @VW_TSD1 TSD2 ON (TSD.TripSavedDealKey = TSD2.TripSavedDealKey)
WHERE	 T.tripSavedKey IS NOT NULL
		 AND T.Startdate >  DATEADD(D,2, GetDate())
		 AND T.tripStatusKey <> 17 
		 
-- SELECT GetDate() [7_C]         
---- SELECT GetDate() [3]
Insert Into @VW_T_Sum (tripKey, tripSavedKey,TripComponentType,currentPrice,originalPrice,originalTotalPrice,currentTotalPrice,OriginAirportCode,DestinationAirportCode,AdultCount,ChildCount,savings)
SELECT	tripKey
		,tripSavedKey
		,SUM(TripComponentType) TripComponentType
		,SUM(currentPrice) currentPrice
		,SUM(originalPrice) originalPrice
		,SUM(originalTotalPrice) originalTotalPrice
		,SUM(currentTotalPrice) currentTotalPrice
		,OriginAirportCode
		,DestinationAirportCode
		,AdultCount
		,ChildCount
		,(SUM(currentPrice) - SUM(originalPrice)) As savings
FROM  @VW_T 
GROUP BY tripKey
		,tripSavedKey
		,OriginAirportCode
		,DestinationAirportCode
		,AdultCount
		,ChildCount


-- /* Orignal Code below Start Here
-- SELECT GetDate() [7_D]
		INSERT INTO @Tbl_RecommendedTripsSavings   
		SELECT   
			VWREC.tripKey  
			,VWREC.tripSavedKey  
			,VWREC.TripComponentType  
			,VWREC.currentPrice  
			,VWREC.originalPrice  
			,CASE WHEN T.userKey = @loggedInUserKey THEN  VWREC.originalTotalPrice  ELSE VWREC.originalPrice END as originalTotalPrice
			,CASE WHEN T.userKey = @loggedInUserKey THEN  VWREC.currentTotalPrice  ELSE VWREC.currentPrice END as currentTotalPrice 
			,VWREC.OriginAirportCode  
			,VWREC.DestinationAirportCode  
			,VWREC.AdultCount  
			,VWREC.ChildCount  
			,CASE WHEN T.userKey = @loggedInUserKey  -- THIS IS DONE BCOZ 
			 THEN VWREC.currentTotalPrice - VWREC.originalTotalPrice  
			 ELSE VWREC.savings		 
			 END as Savings
			 ,T.userKey
			,0
			,Recency
			,0 -- RECENCY RANKING
			,ABS(DATEDIFF(day,TR.tripFromDate1, GETDATE())) -- PROXIMITY
			,0 -- -- PROXIMITY RANKING
			,0 -- SOCIAL RANKING
			,0 -- TRIP SCORING
			,-1
			,''
		FROM 
			@VW_T_Sum VWREC  --vw_RecommendedTripsSavings VWREC  
		INNER JOIN Trip T WITH (NOLOCK) ON VWREC.tripKey = T.tripKey  ---and T.userKey = @loggedInUserKey
		inner join @tblDerived Derived ON T.tripSavedKey = Derived.tripSavedKey
		--INNER JOIN 
		--(
		--		SELECT TS.tripSavedKey, DATEDIFF(day,MAX(T.CreatedDate),GETDATE()) as Recency	
		--		  FROM trip T inner join TripSaved TS on T.tripSavedKey = TS.tripSavedKey 
		--		  where siteKey =@siteKey and T.tripStatusKey <> 17
		--		  AND T.IsWatching = 1        
		--		  Group by TS.tripSavedKey                      
		--) Derived ON T.tripSavedKey = Derived.tripSavedKey
		INNER JOIN TripRequest TR WITH (NOLOCK) ON T.tripRequestKey = TR.tripRequestKey	 
		WHERE 
			VWREC.savings <= -10
		AND 
			T.tripComponentType = VWREC.TripComponentType 
		AND 
			T.tripStatusKey <> 17   
  		AND 
  			((T.PrivacyType = 1) OR (T.userKey = @loggedInUserKey AND T.PrivacyType = 2)) 
-- */ Orignal Code below ends Here
----- Code ENds here 
--IF OBJECT_ID('tempdb..#Tbl_RecommendedTripsSavings') IS NOT NULL
--    DROP TABLE #Tbl_RecommendedTripsSavings
    
--Select * into #Tbl_RecommendedTripsSavings from @Tbl_RecommendedTripsSavings
	--Select getdate() as [3]  
		DECLARE @tblDeals AS TABLE 
		(
		currentDealKey int ,
		componentType int,
		tripKey int
		) 
		
-- SELECT GetDate() [8]		 		
		INSERT @tblDeals (currentDealKey ,componentType ,tripKey)
		SELECT MAX(tripsaveddealkey) currentDealKey ,componentType,TSD.tripKey  FROM TripSavedDeals TSD WITH (NOLOCK)
		INNER JOIN  @Tbl_RecommendedTripsSavings RTS ON TSD.tripKey =RTS.tripKey  group by componentType ,TSD.tripKey  
		
--IF OBJECT_ID('tempdb..#tblDeals') IS NOT NULL
--    DROP TABLE #tblDeals
    
--Select * into #tblDeals from @tblDeals
		
		
-- SELECT GetDate() [9]		 				
		
		UPDATE @Tbl_RecommendedTripsSavings
		SET SavingsRanking = 
		CASE 
			WHEN  userKey = @loggedInUserKey 
			THEN
				CASE 
					WHEN ABS((savings / originalTotalPrice) * 100) >= 25 THEN 10			
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 20 AND 24.99 THEN 8	
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 17 AND 19.99 THEN 7	
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 15 AND 16.99 THEN 6	
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 12 AND 14.99 THEN 5	
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 9 AND 11.99 THEN 4	
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 6 AND 8.99 THEN 3	
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 3 AND 5.99 THEN 2	
					WHEN ABS((savings / originalTotalPrice) * 100) BETWEEN 1 AND 2.99 THEN 1	
					WHEN ABS((savings / originalTotalPrice) * 100)  BETWEEN 0 AND 0.99 THEN -5	
					WHEN ABS((savings / originalTotalPrice) * 100) < 0 THEN -10	
				END
			ELSE
				CASE 
					WHEN ABS((savings / originalPrice) * 100) >= 25 THEN 10			
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 20 AND 24.99 THEN 8	
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 17 AND 19.99 THEN 7
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 15 AND 16.99 THEN 6
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 12 AND 14.99 THEN 5
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 9 AND 11.99 THEN 4
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 6 AND 8.99 THEN 3
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 3 AND 5.99 THEN 2
					WHEN ABS((savings / originalPrice) * 100) BETWEEN 1 AND 2.99 THEN 1
					WHEN ABS((savings / originalPrice) * 100)  BETWEEN 0 AND 0.99 THEN -5	
					WHEN ABS((savings / originalPrice) * 100) < 0 THEN -10
				END					   
		END
		
-- SELECT GetDate() [10]		 				
	
		UPDATE @Tbl_RecommendedTripsSavings
		SET RecencyRanking =
		CASE
			WHEN Recency = 0 THEN 5
			WHEN Recency = 1 THEN 4.5
			WHEN Recency = 7 THEN 4
			WHEN Recency BETWEEN 8 AND 14 THEN 3
			WHEN Recency BETWEEN 13 AND 21 THEN 2
			WHEN Recency BETWEEN 20 AND 45 THEN 1.5    
			ELSE 0
		END 
		
-- SELECT GetDate() [11]		 				 
		
		UPDATE @Tbl_RecommendedTripsSavings
		SET ProximityRanking = 
		CASE 
			WHEN Proximity BETWEEN 22 AND 42 THEN 5
			WHEN Proximity  BETWEEN 14 AND 21 THEN 4
			WHEN Proximity  BETWEEN 43 AND 90 THEN 3
			WHEN Proximity  BETWEEN 90 AND 180 THEN 2
			WHEN Proximity > 180   THEN 1
			WHEN Proximity < 14   THEN 0
		END
		
-- SELECT GetDate() [12]		 				 		
		
		--UPDATE TD 
		--SET 
		--	Rating=ISNULL( VW.Rating,-1),
		--	HotelRegionName = ISNULL(PR.RegionName,'')
		--FROM @Tbl_RecommendedTripsSavings TD 
		--INNER JOIN @tblDeals TS ON (TD.tripKey = TS.tripKey AND TS.componentType = 4)
		--INNER JOIN TripSavedDeals TSD  WITH (NOLOCK) ON TSD.TripSavedDealKey = TS.currentDealKey 
		--INNER JOIN [vw_TripHotelResponseDetails] VW WITH (NOLOCK) on TSD.responseKey = VW.hotelResponseKey  
		--LEFT JOIN HotelContent..RegionHotelIDMapping RHIM WITH (NOLOCK) ON VW.HotelId = RHIM.HotelId
		--LEFT JOIN HotelContent..ParentRegionList PR WITH (NOLOCK) ON RHIM.RegionId = PR.RegionID
		--AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'  	                   
		
		/* To optimize 2.5 sec
		DECLARE @H_PR TABLE (
			tripKey int
		   ,Rating FLOAT
		  ,RegionName VARCHAR(100)
		)
		Insert Into @H_PR (tripKey, Rating, RegionName)
		
		Select
			 TD.tripKey
			,ISNULL( H.Rating,-1)
			,ISNULL(PR.RegionName,'') 
		FROM @Tbl_RecommendedTripsSavings TD 
		INNER JOIN @tblDeals TS ON (TD.tripKey = TS.tripKey AND TS.componentType = 4)
		INNER JOIN TripSavedDeals TSD  WITH (NOLOCK) ON TSD.TripSavedDealKey = TS.currentDealKey 
		INNER JOIN TripHotelResponse THR WITH (NOLOCK) on TSD.responseKey = THR.hotelResponseKey 
		inner join HotelContent..SupplierHotels1 SH WITH (NOLOCK) ON THR.supplierId = SH.SupplierFamily AND THR.supplierHotelKey = SH.SupplierHotelId
		INNER JOIN HotelContent..Hotels H WITH (NOLOCK) ON SH.HotelId = H.HotelId 
		LEFT JOIN HotelContent..RegionHotelIDMapping RHIM WITH (NOLOCK) ON H.HotelId = RHIM.HotelId
		LEFT JOIN HotelContent..ParentRegionList PR WITH (NOLOCK) ON RHIM.RegionId = PR.RegionID
		AND PR.RegionType='Neighborhood' and PR.subclass <> 'city' 
-  		*/
		-- SELECT GetDate() [12_A]		 				 		
		Declare @M_TS table (currentDealKey int, tripKey int)
		insert into @M_TS
		--Select TS.currentDealKey, ts.tripKey From #tblDeals TS where TS.tripKey in (Select TD.tripKey from #Tbl_RecommendedTripsSavings TD) AND TS.componentType = 4
		Select TS.currentDealKey, ts.tripKey From @tblDeals TS inner join @Tbl_RecommendedTripsSavings TD on  TS.tripKey = TD.tripKey AND TS.componentType = 4
--Select COUNT(*) from #Tbl_RecommendedTripsSavings
--Select Count(*) from #tblDeals
-- SELECT GetDate() [12_A_2],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()			

		Declare @M_TripSavedDeals table (responseKey uniqueidentifier, tripKey int)
		insert into @M_TripSavedDeals
		Select TSD.responseKey, TS.tripKey from TripSavedDeals TSD inner join @M_TS TS on TS.currentDealKey = TSD.TripSavedDealKey 

-- SELECT GetDate() [12_A_3],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()			
	
		
		Declare @M_TripHotelResponse table (supplierId varchar(50), supplierHotelKey varchar(50), tripKey int)
		Insert Into @M_TripHotelResponse
		Select THR.supplierId, THR.supplierHotelKey, TSD.tripKey from TripHotelResponse THR 
		inner join @M_TripSavedDeals TSD on TSD.responseKey = THR.hotelResponseKey
		--where THR.hotelResponseKey in (Select TSD.responseKey from @M_TripSavedDeals TSD)

-- SELECT GetDate() [12_A_4],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()			
		
		Declare @M_SupplierHotels1 table (HotelId int, tripKey int)
		INsert Into @M_SupplierHotels1 
		Select SH.HotelId, THR.tripKey from HotelContent..SupplierHotels1 SH inner join  @M_TripHotelResponse THR ON THR.supplierId = SH.SupplierFamily AND THR.supplierHotelKey = SH.SupplierHotelId

-- SELECT GetDate() [12_A_5],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()			
		
		Declare @Hotels table (HotelId int, tripKey int, Rating float)
		Insert into @Hotels (HotelId , tripKey, Rating)
		Select H.HotelId ,SH.tripKey, H.Rating From HotelContent..Hotels H inner join @M_SupplierHotels1 SH  ON SH.HotelId = H.HotelId 

-- SELECT GetDate() [12_A_6],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()			
		
		Declare @RegionHotelIDMapping table (RegionId int, HotelId int, tripKey int, Rating float)
		Insert into @RegionHotelIDMapping (RegionId, HotelId , tripKey, Rating)
		Select RHIM.RegionId,H.HotelId, H.tripKey, H.Rating from HotelContent..RegionHotelIDMapping RHIM inner join @Hotels H ON H.HotelId = RHIM.HotelId 
		

-- SELECT GetDate() [12_A_7],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()			
		
Declare @ParentRegionList table (RegionName varchar(200), HotelId int, tripKey int, Rating float)
Insert Into @ParentRegionList (RegionName,HotelId,tripKey,Rating)
Select PR.RegionName,RHIM.HotelId,RHIM.tripKey,RHIM.Rating From  HotelContent..ParentRegionList PR 
Inner join @RegionHotelIDMapping RHIM ON RHIM.RegionId = PR.RegionID
		AND PR.RegionType='Neighborhood' and PR.subclass <> 'city' 

-- SELECT GetDate() [12_A_8],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()			
-- */		
		--Select 
		--TD.tripKey
		----	,ISNULL( H.Rating,-1)
		--	--,ISNULL(PR.RegionName,'')
		--FROM #Tbl_RecommendedTripsSavings TD 
		--INNER JOIN #tblDeals TS ON (TD.tripKey = TS.tripKey AND TS.componentType = 4)
		--INNER JOIN TripSavedDeals TSD ON TSD.TripSavedDealKey = TS.currentDealKey 
		--INNER JOIN TripHotelResponse THR on TSD.responseKey = THR.hotelResponseKey 
		--inner join HotelContent..SupplierHotels1 SH ON THR.supplierId = SH.SupplierFamily AND THR.supplierHotelKey = SH.SupplierHotelId
		--INNER JOIN HotelContent..Hotels H ON SH.HotelId = H.HotelId 
		--LEFT JOIN HotelContent..RegionHotelIDMapping RHIM ON H.HotelId = RHIM.HotelId
		--LEFT JOIN HotelContent..ParentRegionList PR ON RHIM.RegionId = PR.RegionID
		--AND PR.RegionType='Neighborhood' and PR.subclass <> 'city' 
		
		
-- SELECT GetDate() [12_A1],  Diff_mm = DATEDIFF(millisecond,@LastDATETIme,  GetDate())
-- Set @LastDATETIme = GetDate()
		 				 		
		UPDATE TD 
		SET 
			Rating=H.Rating,
			HotelRegionName = H.RegionName 
		FROM @Tbl_RecommendedTripsSavings TD 
		Inner Join @ParentRegionList H on H.tripKey = TD.tripKey 
		-- optimized 1.0
		--Inner Join @H_PR H on H.tripKey = TD.tripKey 
		--Orignal below one
		--INNER JOIN @tblDeals TS ON (TD.tripKey = TS.tripKey AND TS.componentType = 4)
		--INNER JOIN TripSavedDeals TSD  WITH (NOLOCK) ON TSD.TripSavedDealKey = TS.currentDealKey 
		--INNER JOIN TripHotelResponse THR WITH (NOLOCK) on TSD.responseKey = THR.hotelResponseKey 
		--inner join HotelContent..SupplierHotels1 SH WITH (NOLOCK) ON THR.supplierId = SH.SupplierFamily AND THR.supplierHotelKey = SH.SupplierHotelId
		--INNER JOIN HotelContent..Hotels H WITH (NOLOCK) ON SH.HotelId = H.HotelId 
		--LEFT JOIN HotelContent..RegionHotelIDMapping RHIM WITH (NOLOCK) ON H.HotelId = RHIM.HotelId
		--LEFT JOIN HotelContent..ParentRegionList PR WITH (NOLOCK) ON RHIM.RegionId = PR.RegionID
		--AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'  
		
-- SELECT GetDate() [13]		 				 		 
		
		SELECT UserId INTO #tmpConnectionUserInfo FROM Loyalty..UserMap 		
		WHERE ParentId = @loggedInUserKey
		AND @loggedInUserKey <> 0
				--Select getdate() as [7]  
		IF (@loggedInUserKey <> 0)
		BEGIN 
			INSERT INTO  #tmpConnectionUserInfo
			(
				UserId
			)
			VALUES
			(
				@loggedInUserKey
			)
		END

-- SELECT GetDate() [14]		 				 		 

		UPDATE RTS 
			SET SocialRanking = 
			CASE 
				WHEN RTS.userKey = @loggedInUserKey THEN 10
				WHEN RTS.userKey = CUI.UserId THEN 8 				
				ELSE 0
			END			
		FROM  @Tbl_RecommendedTripsSavings AS RTS
		INNER JOIN #tmpConnectionUserInfo CUI ON RTS.userKey = CUI.UserId 
		
		
		UPDATE RTS
			SET SocialRanking = 11
		FROM @Tbl_RecommendedTripsSavings AS RTS
		INNER JOIN TripSaved TS ON RTS.userKey = TS.userKey
		AND RTS.tripSavedKey = TS.tripSavedKey
		WHERE TS.userKey <> 0		
		
		
		
-- SELECT GetDate() [15]		 				 		 

		UPDATE @Tbl_RecommendedTripsSavings
		SET TripScoring = SavingsRanking + RecencyRanking + ProximityRanking + SocialRanking
		
	 			--Select getdate() as [10]  
		--SELECT * FROM @Tbl_RecommendedTripsSavings 


	 DECLARE @tblDERIED AS TABLE 
		 (
			 tripKey int,
			 tripSavedKey uniqueidentifier,
			 watchersCount int,
			 FastestTrending FLOAT
		 )
		 
-- SELECT GetDate() [16]		 				 		 
		 
	INSERT INTO @tblDERIED	 (tripKey,tripSavedKey,watchersCount,FastestTrending)
	SELECT	MIN(tripKey) tripkey
			,T.tripSavedKey
			,COUNT(tripKEY) as  watchersCount
			,CASE 
						WHEN CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) = 0 
						THEN CAST(COUNT(tripKey) AS FLOAT) /  1
						ELSE CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) 
					END as FastestTrending   				
			  FROM  trip T WITH (NOLOCK)
			  WHERE siteKey =@siteKey 
					and T.tripStatusKey <> 17
					AND T.IsWatching = 1
			  GROUP BY T.tripSavedKey    
		
-- SELECT GetDate() [17]		
		 				 		 		
	UPDATE DR
	SET watchersCount = watchersCount + ISNULL(SplitFollowersCount,0)
	FROM @tblDERIED DR
	INNER JOIN TripSaved TS ON DR.tripSavedKey = TS.tripSavedKey
	WHERE TS.parentSaveTripKey IS NOT NULL

	--PRINT 'HotelRating :- ' + CAST(@HotelRating1 as Varchar)
		
		 INSERT INTO @Tripdetails
		 ( 
			tripKey,
			tripsavedKey,
			triprequestkey,
			tripstartdate,
			tripenddate,
			tripfrom,
			tripTo, 
			tripComponentType,
			tripComponents, 
			rankRating, 
			currentTotalPrice, 
			UserName, 
			FacebookUserUrl, 
			WatchersCount, 
			LikeCount, 
			ThemeType, 
			TripPurchaseKey,
			BookersCount, 
			FastestTrending,
			TotalSavings,
			RowNumber,
			Rating,
			AirSegmentCabinAbbrevation,
			AirSegmentCabin,
			CarClassAbbrevation,
			CarClass,
			AirRequestTypeName,
			NoOfStops,
			HotelRegionName,
			DestinationImageURL
		)                    
		SELECT  
			t1.tripKey, 
			t1.tripsavedKey,
			t1.triprequestkey,
			TR.tripFromDate1, 
			TR.tripToDate1,
			tr.tripFrom1, 
			tr.tripTo1, 
			t1.tripComponentType, 
			CASE           
			  WHEN t1.tripComponentType = 1 THEN 'Air'          
			  WHEN t1.tripComponentType = 2 THEN 'Car'          
			  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
			  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
			  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
			  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
			  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
			 END AS tripComponents,                     
			 recommended.TripScoring as [Rank],  
			recommended.currentTotalPrice as CurrentTotalPrice,  
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
			ISNULL(UM.ImageURL,'') as FacebookUserUrl,
			watchersCount as WatchersCount,
			ISNULL(TLK.LikeCount,0) as LikeCount,
			ISNULL(D.PrimaryTripType,0)	as  ThemeType,
			T1.tripPurchasedKey,
			ISNULL(TL.BookersCount,0) as BookersCount,
			FastestTrending,
			recommended.savings,
			0,
			Rating		
			,'' -- AirSegmentCabinAbbrevation
			,'' -- AirSegmentCabin
			,'' -- CarClassAbbrevation
			,'' -- CarClass
			,'' -- AirRequestTypeName
			,'' -- NoOfStops
			,HotelRegionName,
			T1.DestinationSmallImageURL
			
		  FROM 
				Trip T1 WITH (NOLOCK)         
		  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
		  INNER JOIN Vault..[User] UI WITH (NOLOCK) ON T1.userKey = UI.userKey                             
		  inner join @tblDERIED AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
		 -- INNER JOIN                     
			--  (
			--	SELECT 
			--		MIN(tripKey) tripkey  , 
			--		T.tripSavedKey ,COUNT(tripKEY) as  watchersCount,
			--		/*
			--		(
			--			CASE WHEN COUNT(tripKey) = 1 THEN 2                     
			--			WHEN  COUNT(tripKey) between 2 and 4    THEN  5                     
			--			WHEN COUNT(tripKey) > 4 THEN 7 END 
			--		) as [Rank],
			--		*/
			--		CASE 
			--			WHEN CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) = 0 
			--			THEN CAST(COUNT(tripKey) AS FLOAT) /  1
			--			ELSE CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) 
			--		END as FastestTrending   				
			--  FROM 
			--	trip T 
			--  WHERE 
			--		siteKey =@siteKey and T.tripStatusKey <> 17
			--  AND 
			--		T.IsWatching = 1
			--/*				
			--  AND 
			--		T.CreatedDate <= DATEADD(D,0, DATEDIFF(D,0,GETDATE()))
			--*/		
			--  GROUP BY T.tripSavedKey                      
			--  )  AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
		  INNER JOIN TripRequest TR WITH (NOLOCK) on T1.tripRequestKey = Tr.tripRequestKey             
		  INNER JOIN dbo.udf_GetTripComponentType(@page,@typeFilter) FN_TRIPCOMPONENT ON T1.tripComponentType = FN_TRIPCOMPONENT.TripComponentType -- THIS IS DONE TO ADD SOME COMPONENT TYPE INTO TABLE. 
		  INNER JOIN @NeighboringAirportLookup NAL ON (CASE WHEN @cityType = 'From' THEN TR.tripFrom1 ELSE TR.tripTo1 END) = NAL.neighborAirportCode    
		  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId	  
		  LEFT JOIN CMS..CustomHotelGroup CHG WITH (NOLOCK)ON TR.tripToHotelGroupId = CHG.HotelGroupId
		  LEFT JOIN CMS..Destination D WITH (NOLOCK) ON CHG.DestinationId = D.DestinationId
		  LEFT JOIN (SELECT tripSavedKey, COUNT(tripPurchasedKey) as BookersCount FROM Trip GROUP BY tripSavedKey) as TL
		  ON T1.tripSavedKey = TL.tripSavedKey
		  LEFT JOIN (SELECT tripKey, SUM(tripLike) as LikeCount FROM TripLike WITH (NOLOCK) GROUP BY tripKey) as TLK
		  ON T1.tripKey = TLK.tripKey
		  --LEFT JOIN [vw_TripHotelResponseDetails] VW on T1.tripSavedKey = VW.tripGuidKey	  	   		  
		  where  T1.tripStatusKey <> 17  
		  AND T1.startDate BETWEEN @startDate AND @endDate
		  /* COMMENTED BCOZ CLIENT NOW WANTS NEIGHBOUR CITY IMPLEMENTATION .....
		  and  (case when  @cityType = 'From' then   TR.tripFrom1                       
		  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = isnull(@cityCode ,(case when  @cityType = 'From' then   TR.tripFrom1                     
		  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end))                   
		  */
		  AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
		  AND t1.tripKey <> @tripKey 
		  AND T1.IsWatching = 1
		  AND ISNULL(D.PrimaryTripType,0) = (CASE WHEN @theme = 0 THEN ISNULL(D.PrimaryTripType,0) ELSE @theme END)	  	  	  
		  AND 
		  (
				Rating = 
				CASE
				/* 
					WHEN @typeFilter = '' OR UPPER(@typeFilter) = 'HOTELONLY' THEN Rating
					ELSE @HotelRating1  						  
				*/
					WHEN @HotelRating1 = -1 THEN Rating
					ELSE @HotelRating1		
				END				
			OR 
				Rating = 
				CASE 
/*					
					WHEN @typeFilter = '' OR UPPER(@typeFilter) = 'HOTELONLY' THEN Rating
					ELSE @HotelRating2  						  
*/
					WHEN @HotelRating2 = -1 THEN Rating
					ELSE @HotelRating2					
				END 	  			
				
		  )	  
			ORDER BY 		
			CASE WHEN (@sortfield ='Rank' or @sortfield ='')THEN TripScoring END DESC,    			
			CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
			CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
			CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
			CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
			tripkey DESC	

		

	--Select getdate() as [11]  
	
		 -- ON HOME PAGE LOAD ...	 		
		 -- IF @cityType = 'From' AND @page = 1  (COMMENTED BCOZ WHATEVER IS THE SITUATION SHOW HOTEL ONLY TMU's TOO... )  
		 -- BEGIN
		 --------- TO GET OTHER TRIPS WHICH ARE HOTEL ONLY AND APTCODE MATCHING FROM CMS_CITY_DETAILS .....  
				
				 DECLARE @tblDERIED1 AS TABLE 
					 (
						 tripKey int,
						 tripSavedKey uniqueidentifier,
						 watchersCount int,
						 FastestTrending FLOAT
					 )
					 
-- SELECT GetDate() [18]		 				 		 							 
				INsert into @tblDERIED1	 (tripKey,tripSavedKey,watchersCount,FastestTrending)
				SELECT	MIN(tripKey) tripkey
						,T.tripSavedKey
						,COUNT(tripKEY) as  watchersCount
						,CASE 
									WHEN CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) = 0 
									THEN CAST(COUNT(tripKey) AS FLOAT) /  1
									ELSE CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) 
								END as FastestTrending   				
						  FROM  trip T WITH (NOLOCK)
						  WHERE siteKey =@siteKey 
								and T.tripStatusKey <> 17
								AND T.IsWatching = 1
						  GROUP BY T.tripSavedKey 
		  
		 
				UPDATE DR
				SET watchersCount = watchersCount + ISNULL(SplitFollowersCount,0)
				FROM @tblDERIED1 DR
				INNER JOIN TripSaved TS ON DR.tripSavedKey = TS.tripSavedKey
				WHERE TS.parentSaveTripKey IS NOT NULL
		 
/*************** THIS IS 2ND LAYER ***************/ 		 				 		 							 		 

			IF @cityCode IS NOT NULL AND @IsTypeFilterSelected = 0
			BEGIN
			
				PRINT 'INSIDE 2ND LAYER'
			 				
				 INSERT INTO @Tripdetails
				 ( 
					tripKey,
					tripsavedKey,
					triprequestkey,
					tripstartdate,
					tripenddate,
					tripfrom,
					tripTo, 
					tripComponentType,
					tripComponents, 
					rankRating, 
					currentTotalPrice, 
					UserName, 
					FacebookUserUrl, 
					WatchersCount, 
					LikeCount, 
					ThemeType, 
					TripPurchaseKey,
					BookersCount, 
					FastestTrending,
					TotalSavings,
					RowNumber,
					Rating,
					AirSegmentCabinAbbrevation,
					AirSegmentCabin,
					CarClassAbbrevation,
					CarClass,
					AirRequestTypeName,
					NoOfStops,
					HotelRegionName,
					DestinationImageURL
					
				)                    	 
				SELECT  
					t1.tripKey, 
					t1.tripsavedKey,
					t1.triprequestkey,
					TR.tripFromDate1, 
					TR.tripToDate1,
					tr.tripFrom1, 
					tr.tripTo1, 
					t1.tripComponentType, 
					CASE           
					  WHEN t1.tripComponentType = 1 THEN 'Air'          
					  WHEN t1.tripComponentType = 2 THEN 'Car'          
					  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
					  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
					  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
					  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
					  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
					 END AS tripComponents,                     
					recommended.TripScoring as [Rank],  
					recommended.currentTotalPrice as CurrentTotalPrice,  
					UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
					ISNULL(UM.ImageURL,'') as FacebookUserUrl,
					watchersCount as WatchersCount,
					ISNULL(TLK.LikeCount,0) as LikeCount,
					ISNULL(D.PrimaryTripType,0)	as  ThemeType,
					T1.tripPurchasedKey,
					ISNULL(TL.BookersCount,0) as BookersCount,
					FastestTrending ,
					recommended.savings,
					0,
					Rating
					,'' -- AirSegmentCabinAbbrevation
					,'' -- AirSegmentCabin
					,'' -- CarClassAbbrevation
					,'' -- CarClass
					,'' -- AirRequestTypeName
					,'' -- NoOfStops
					,HotelRegionName
					,T1.DestinationSmallImageURL
				  FROM 
						Trip T1  WITH (NOLOCK)        
				  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
				  INNER JOIN Vault..[User] UI WITH (NOLOCK) ON T1.userKey = UI.userKey                             
				  inner join @tblDERIED1  AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
				 -- INNER JOIN                     
					--  (
					--	SELECT 
					--		MIN(tripKey) tripkey  , 
					--		T.tripSavedKey ,COUNT(tripKEY) as  watchersCount,
					--		/*
					--		(
					--			CASE WHEN COUNT(tripKey) = 1 THEN 2                     
					--			WHEN  COUNT(tripKey) between 2 and 4    THEN  5                     
					--			WHEN COUNT(tripKey) > 4 THEN 7 END 
					--		) as [Rank],
					--		*/
					--		CASE 
					--			WHEN CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) = 0 
					--			THEN CAST(COUNT(tripKey) AS FLOAT) /  1
					--			ELSE CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) 
					--		END as FastestTrending   							  
					--	FROM 
					--	trip T 
					--  WHERE 
					--		siteKey =@siteKey and T.tripStatusKey <> 17
					--  AND 
					--		T.IsWatching = 1   
					--/*					
					--  AND 
					--		T.CreatedDate <= DATEADD(D,0, DATEDIFF(D,0,GETDATE()))				     
					--*/					
					--  GROUP BY T.tripSavedKey                      
					--  )  AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
				  INNER JOIN TripRequest TR WITH (NOLOCK) on T1.tripRequestKey = Tr.tripRequestKey             	  
				  INNER JOIN @NeighboringAirportLookup NAL ON (CASE WHEN @cityType = 'From' THEN TR.tripFrom1 ELSE TR.tripTo1 END) = NAL.neighborAirportCode    
				  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId	  
				  LEFT JOIN CMS..CustomHotelGroup CHG WITH (NOLOCK)ON TR.tripToHotelGroupId = CHG.HotelGroupId
				  LEFT JOIN CMS..Destination D WITH (NOLOCK) ON CHG.DestinationId = D.DestinationId
				  LEFT JOIN (SELECT tripSavedKey, COUNT(tripPurchasedKey) as BookersCount FROM Trip WITH (NOLOCK) GROUP BY tripSavedKey) as TL
				  ON T1.tripSavedKey = TL.tripSavedKey
				  LEFT JOIN (SELECT tripKey, SUM(tripLike) as LikeCount FROM TripLike WITH (NOLOCK) GROUP BY tripKey) as TLK
				  ON T1.tripKey = TLK.tripKey
				  --LEFT JOIN [vw_TripHotelResponseDetails] VW on T1.tripSavedKey = VW.tripGuidKey
				  where  T1.tripStatusKey <> 17  
				  AND T1.startDate BETWEEN @startDate AND @endDate	  
				  --AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
				  AND t1.tripKey <> @tripKey 
				  AND T1.IsWatching = 1
				  AND ISNULL(D.PrimaryTripType,0) = (CASE WHEN @theme = 0 THEN ISNULL(D.PrimaryTripType,0) ELSE @theme END)	  	  
				  AND T1.tripComponentType = 4 ------------- HOTEL ONLY, BCOZ OTHER TMU's SHOULD BE FETCHED WHICH ARE HOTEL ONLY ...
				/* COMMENTED BCOZ CLIENT NOW WANTS NEIGHBOUR CITY IMPLEMENTATION .....				  
				  AND  (case when  @cityType = 'From' then   TR.tripFrom1                       
					when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = isnull(@cityCode ,(case when  @cityType = 'From' then   TR.tripFrom1                     
					when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end))                   
				*/
				  AND T1.tripKey NOT IN (SELECT tripkey FROM @Tripdetails)  
				  --AND T1.HomeAirport = @cityCode /*########### THIS IS 2ND LAYER OF DISPLAY RULE WHERE WE NEED TO SHOW ONLY HIGHLY RATED HOTEL TMU's WHICH ARE AT HOME AIPORT  ###########*/
				  /*
				  (
					CASE 
						WHEN  @cityType = 'From' THEN   TR.tripFrom1                       
						WHEN @cityType = 'To' THEN Tr.tripTo1 
						ELSE TR.tripFrom1    END
				   ) = @cityCode  /*########### THIS IS 2ND LAYER OF DISPLAY RULE WHERE WE NEED TO SHOW ONLY HIGHLY RATED HOTEL TMU's WHICH ARE AT HOME AIPORT  ###########*/
				   */
				  ORDER BY 		
					CASE WHEN (@sortfield ='Rank' or @sortfield ='')THEN TripScoring END DESC,    			
					CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
					CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
					CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
					CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
					tripkey DESC		 	
			
			
			END
			
/******** THIS IS 3RD LAYER OF DISPLAY RULE WHERE WE NEED TO SHOW REST OF ALL TMU's FROM DIFFERENT DESTINATION WHICH ARE HIGHLY RATED HOTEL ONLY *********/	
			IF @cityType = 'From' AND @IsTypeFilterSelected = 0 /*********** THIS CONDITION IS DONE BCOZ WHEN USER SELECTS ANY DESTINATION FROM DESTINATION FILTER THEN 3RD LAYER SHOULD NOT BE DISPLAYED  ***********/
			BEGIN
			
				PRINT 'INSIDE 3RD LAYER'
			
				 INSERT INTO @Tripdetails
				 ( 
					tripKey,
					tripsavedKey,
					triprequestkey,
					tripstartdate,
					tripenddate,
					tripfrom,
					tripTo, 
					tripComponentType,
					tripComponents, 
					rankRating, 
					currentTotalPrice, 
					UserName, 
					FacebookUserUrl, 
					WatchersCount, 
					LikeCount, 
					ThemeType, 
					TripPurchaseKey,
					BookersCount, 
					FastestTrending,
					TotalSavings,
					RowNumber,
					Rating,
					AirSegmentCabinAbbrevation,
					AirSegmentCabin,
					CarClassAbbrevation,
					CarClass,
					AirRequestTypeName,
					NoOfStops,
					HotelRegionName,
					DestinationImageURL
					
				)                    	 
				SELECT  
					t1.tripKey, 
					t1.tripsavedKey,
					t1.triprequestkey,
					TR.tripFromDate1, 
					TR.tripToDate1,
					tr.tripFrom1, 
					tr.tripTo1, 
					t1.tripComponentType, 
					CASE           
					  WHEN t1.tripComponentType = 1 THEN 'Air'          
					  WHEN t1.tripComponentType = 2 THEN 'Car'          
					  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
					  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
					  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
					  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
					  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
					 END AS tripComponents,                     
					recommended.TripScoring as [Rank],  
					recommended.currentTotalPrice as CurrentTotalPrice,  
					UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
					ISNULL(UM.ImageURL,'') as FacebookUserUrl,
					watchersCount as WatchersCount,
					ISNULL(TLK.LikeCount,0) as LikeCount,
					ISNULL(D.PrimaryTripType,0)	as  ThemeType,
					T1.tripPurchasedKey,
					ISNULL(TL.BookersCount,0) as BookersCount,
					FastestTrending ,
					recommended.savings,
					0,
					Rating
					,'' -- AirSegmentCabinAbbrevation
					,'' -- AirSegmentCabin
					,'' -- CarClassAbbrevation
					,'' -- CarClass
					,'' -- AirRequestTypeName
					,'' -- NoOfStops
					,HotelRegionName
					,T1.DestinationSmallImageURL
				  FROM 
						Trip T1  WITH (NOLOCK)        
				  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
				  INNER JOIN Vault..[User] UI WITH (NOLOCK) ON T1.userKey = UI.userKey                             
				  inner join @tblDERIED1  AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
				 -- INNER JOIN                     
					--  (
					--	SELECT 
					--		MIN(tripKey) tripkey  , 
					--		T.tripSavedKey ,COUNT(tripKEY) as  watchersCount,
					--		/*
					--		(
					--			CASE WHEN COUNT(tripKey) = 1 THEN 2                     
					--			WHEN  COUNT(tripKey) between 2 and 4    THEN  5                     
					--			WHEN COUNT(tripKey) > 4 THEN 7 END 
					--		) as [Rank],
					--		*/
					--		CASE 
					--			WHEN CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) = 0 
					--			THEN CAST(COUNT(tripKey) AS FLOAT) /  1
					--			ELSE CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) 
					--		END as FastestTrending   							  
					--	FROM 
					--	trip T 
					--  WHERE 
					--		siteKey =@siteKey and T.tripStatusKey <> 17
					--  AND 
					--		T.IsWatching = 1   
					--/*					
					--  AND 
					--		T.CreatedDate <= DATEADD(D,0, DATEDIFF(D,0,GETDATE()))				     
					--*/					
					--  GROUP BY T.tripSavedKey                      
					--  )  AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
				  INNER JOIN TripRequest TR WITH (NOLOCK) on T1.tripRequestKey = Tr.tripRequestKey             	  
				  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId	  
				  LEFT JOIN CMS..CustomHotelGroup CHG WITH (NOLOCK)ON TR.tripToHotelGroupId = CHG.HotelGroupId
				  LEFT JOIN CMS..Destination D WITH (NOLOCK) ON CHG.DestinationId = D.DestinationId
				  LEFT JOIN (SELECT tripSavedKey, COUNT(tripPurchasedKey) as BookersCount FROM Trip WITH (NOLOCK) GROUP BY tripSavedKey) as TL
				  ON T1.tripSavedKey = TL.tripSavedKey
				  LEFT JOIN (SELECT tripKey, SUM(tripLike) as LikeCount FROM TripLike WITH (NOLOCK) GROUP BY tripKey) as TLK
				  ON T1.tripKey = TLK.tripKey
				  --LEFT JOIN [vw_TripHotelResponseDetails] VW on T1.tripSavedKey = VW.tripGuidKey
				  where  T1.tripStatusKey <> 17  
				  AND T1.startDate BETWEEN @startDate AND @endDate	  
				  --AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
				  AND t1.tripKey <> @tripKey 
				  AND T1.IsWatching = 1
				  AND ISNULL(D.PrimaryTripType,0) = (CASE WHEN @theme = 0 THEN ISNULL(D.PrimaryTripType,0) ELSE @theme END)	  	  
				  AND T1.tripComponentType = 4 ------------- HOTEL ONLY, BCOZ OTHER TMU's SHOULD BE FETCHED WHICH ARE HOTEL ONLY ...
				  AND TR.tripTo1 IN (SELECT CityCode FROM @PreferredCityList) --- HARD CODE CITY LIST GIVEN BY CLIENT ... 
				  AND T1.tripKey NOT IN (SELECT tripkey FROM @Tripdetails)  
 					ORDER BY 		
					CASE WHEN (@sortfield ='Rank' or @sortfield ='')THEN TripScoring END DESC,    			
					CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
					CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
					CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
					CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
					tripkey DESC		 	
			END
	
		--  END
	--	Select getdate() as [12]  
		 IF (@friendOption <> '')
		 BEGIN 
-- SELECT GetDate() [20]		 				 		 							 		 		 
				 -- THIS DELETE STATEMENT IS USED TO DELETE RECORDS OF TRIPS WHERE USER KEY ARE NOT IN CONNECTIONS    
				 DELETE FROM @Tripdetails 
				 WHERE tripKey NOT IN (SELECT tripKey FROM @ConnectionsUserSaveTripInfo WHERE tripKey <> 0)
			


				IF ( @loggedInUserKey > 0 )
				BEGIN
-- SELECT GetDate() [21]
					 UPDATE TD 
					 SET IsWatcher = 1 
					 FROM @Tripdetails TD 			 
					 INNER JOIN @ConnectionsUserSaveTripInfo CUS ON TD.tripsavedKey = CUS.tripSavedKey WHERE CUS.userKey = @loggedInUserKey
				END	 

				 --Select getdate() as [13]  
				 
		 END
		 ELSE
		 BEGIN
		 
				IF @loggedInUserKey > 0 
				BEGIN
				
-- SELECT GetDate() [22]						 
			 
					 UPDATE TD 
					 SET IsWatcher = 1 
					 FROM @Tripdetails TD 
					 INNER JOIN Trip T WITH (NOLOCK) on TD.tripsavedKey =T.tripSavedKey 
					 AND T.userKey = @loggedInUserKey 
					 AND T.IsWatching = 1
					 /*
					 DECLARE @imageUrl AS  VARCHAR(100)
					 DECLARE @name AS  VARCHAR(100)
					 
					 SELECT 
							@imageUrl = UM.ImageURL,
							@name = UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'  
					 FROM  
						Vault..[User] UI                       
					LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId WHERE userKey = @loggedInUserKey 
						
					UPDATE @Tripdetails SET FacebookUserUrl  = @imageUrl , UserName = @name WHERE IsWatcher =1    	 
					
	--				Select getdate() as [14]  
					*/
				
				END	 
		 END 
		       	 		
			UPDATE @Tripdetails
			SET @RowNumber = RowNumber = @RowNumber + 1


-- SELECT GetDate() [23]						 								
			
			INSERT INTO @TripdetailsFinal
			SELECT * FROM @Tripdetails
			WHERE RowNumber BETWEEN @FromIndex AND @ToIndex
			
			UPDATE TD
			SET AirRequestTypeName = ISNULL(L.airRequestTypeName,'')
			FROM @TripdetailsFinal TD
			INNER JOIN TripRequest_air TRA WITH (NOLOCK) ON TD.triprequestkey = TRA.tripRequestKey
			INNER JOIN airRequest A WITH (NOLOCK) on TRA.airRequestKey = A.airRequestKey
			INNER JOIN AirRequestTypeLookup L WITH (NOLOCK) on A.airRequestTypeKey = L.airRequestTypeKey
						
/*  SAMIR :- NoOfStops BLOCK STARTS ######## NoOfStops column not needed by Rick (05-Sept-2013). Hence commenting the code block for fetching NoOfStops. This will increase TMU's performance too ..   						
			Declare @tblTemp AS TABLE
			(
				airResponseKey UNIQUEIDENTIFIER,
				NoOfStops INT ,
				airLegNumber INT ,
				tripKey INT
			
			)
			
---- SELECT GetDate() [24]						 			
			INSERT INTO @tblTemp
			SELECT TAS.airResponseKey ,(COUNT(TAS.airSegmentKey)-1 ) NoOfStops ,airLegNumber ,TD.tripKey  FROM @tblDeals TD 
			INNER JOIN TripSavedDeals TSD WITH (NOLOCK) on (TD.currentDealKey = TSD.TripSavedDealKey )
			INNER JOIN TripAirResponse TAR WITH (NOLOCK) ON (TSD.responseKey = TAR.airresponseKey AND TD.componentType = 1)		 
			INNER JOIN TripAirSegments TAS WITH (NOLOCK) ON (TAR.airResponseKey = TAS.airResponseKey ) 
			WHERE TAS.isDeleted = 0 
			GROUP BY TAS.airResponseKey , TAS.airLegNumber ,TD.tripKey
			
			DECLARE @tblAir AS TABLE
			(
			airResponseKey uniqueidentifier ,
			noOfStops int,
			tripKey int
			)
			
---- SELECT GetDate() [25]						 						
			INSERT @tblAir (airResponseKey,noOfStops,tripKey)
			SELECT airResponseKey ,MAX(NoOFStops)NoOfStops,tripKey 
			FROM @tblTemp
			GRoup by airResponseKey ,tripKey 
			
---- SELECT GetDate() [26]						 									
			
			UPDATE TD 
			SET NoOfStops = CASE  WHEN TA.noOfStops = 0 THEN 'Non-Stop' 
								  WHEN TA.noOfStops = 1 THEN '1 Stop'	
								  ELSE Cast(TA.noOfStops  AS VARCHAR) + ' Stops' END 		
			FROM @TripdetailsFinal TD 
			INNER JOIN @tblAir TA on TD.tripKey = TA.tripKey 
			
		######## NoOfStops BLOCK ENDS ########			
*/			

			/*** Need to change cabin logix , it is taking last segment cabin right now . We need to find lowest cabin in itinerary****/
-- SELECT GetDate() [27]						 												
			UPDATE TD 
			SET AirSegmentCabinAbbrevation =  
			CASE 
				WHEN UPPER(TAS.airsegmentcabin) = 'ECONOMY' THEN 'econ'
				WHEN UPPER(TAS.airsegmentcabin) = 'BUSINESS' THEN 'buss'  
				ELSE
				ISNULL(TAS.airsegmentcabin,'')
			END,
			AirSegmentCabin = ISNULL(TAS.airsegmentcabin,'')						
			FROM @TripdetailsFinal TD 
			INNER JOIN @tblDeals TS ON TD.tripKey = TS.tripKey 
			INNER JOIN TripSavedDeals TSD WITH (NOLOCK) on (TS.currentDealKey = TSD.TripSavedDealKey AND TS.componentType = 1)
			INNER JOIN TripAirResponse TAR WITH (NOLOCK) ON TSD.responseKey = TAR.airResponseKey 
			INNER JOIN TripAirSegments TAS WITH (NOLOCK) ON TAR.airResponseKey = TAS.airResponseKey 
			
			
-- SELECT GetDate() [28]						 												
			
			UPDATE TD 
			SET CarClassAbbrevation = 
			CASE 
				WHEN UPPER(TCRD.SippCodeClass) = 'STANDARD' THEN 'std'
				WHEN UPPER(TCRD.SippCodeClass) = 'ECONOMY' THEN 'eco'
				WHEN UPPER(TCRD.SippCodeClass) = 'COMPACT' THEN 'cmp'
				WHEN UPPER(TCRD.SippCodeClass) = 'INTERMEDIATE' THEN 'itd'
				ELSE ISNULL(TCRD.SippCodeClass,'')	
			END,
			CarClass = ISNULL(TCRD.SippCodeClass,'')					
			FROM @TripdetailsFinal TD 
			INNER JOIN @tblDeals TS ON TD.tripKey = TS.tripKey 
			INNER JOIN TripSavedDeals TSD WITH (NOLOCK) on (TS.currentDealKey = TSD.TripSavedDealKey AND TS.componentType = 2)
			INNER JOIN vw_TripCarResponseDetails  TCRD ON TSD.responseKey = TCRD.carResponseKey 
						
		
-- SELECT GetDate() [29]						 														

		--UPDATE @Tripdetails
		--SET @RowNumber = RowNumber = @RowNumber + 1

	--	 Select getdate() as [15]  
---- SELECT GetDate() [30]
	
		SELECT 
			  TripdetailsKey ,                    
			  tripKey ,                    
			  tripsavedKey ,                    
			  triprequestkey ,                    
			  tripstartdate ,                    
			  tripenddate ,                    
			  tripfrom ,                    
			  tripTo ,                    
			  tripComponentType ,    
			  tripComponents ,                                      
			  rankRating ,                    
			  tripAirsavings ,                      
			  tripcarsavings ,                    
			  triphotelsavings ,                    
			  isOffer ,                    
			  OfferImageURL ,    
			  LinktoPage ,  
			  currentTotalPrice ,  
			  UserName ,
			  FacebookUserUrl ,
			  WatchersCount ,
			  LikeCount ,
			  ThemeType ,
			  IsWatcher ,
			  BookersCount ,
			  TripPurchaseKey ,
			  FastestTrending ,
			  TotalSavings ,
			  RowNumber ,
			  Rating ,
			  AirSegmentCabinAbbrevation ,
			  AirSegmentCabin ,
			  CarClassAbbrevation ,
			  CarClass ,
			  AirRequestTypeName ,
			  NoOfStops ,
			  HotelRegionName,  	   
			  DestinationImageUrl,	
			FA.CityName as FromCity, 
			CASE 
				WHEN FA.CountryCode = 'US' 
				THEN FA.StateCode  
				ELSE '' 
			END AS FromState ,    
			CASE 
				WHEN FA.CountryCode = 'US' 
				THEN '' 
				ELSE FCL.CountryName 
			END AS FromCountry,
			    		  		
			TA.CityName as ToCity ,    
			CASE 
				WHEN TA.CountryCode = 'US' 
				THEN TA.StateCode  
				ELSE '' 
			END AS ToState ,    
			CASE 
				WHEN TA.CountryCode = 'US' 
				THEN '' 
				ELSE CL.CountryName 
			END AS ToCountry    		  
		FROM 
			@TripdetailsFinal T
		 LEFT OUTER JOIN AirportLookup FA WITH (NOLOCK)on T.tripfrom = FA.AirportCode                     
		 LEFT OUTER JOIN AirportLookup TA WITH (NOLOCK)on T.tripto = TA.AirportCode    
		 LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)ON TA.CountryCode = CL.CountryCode    
		 LEFT OUTER JOIN vault..CountryLookUp FCL WITH (NOLOCK)ON FA.CountryCode = FCL.CountryCode    	
		--WHERE 
		--	RowNumber BETWEEN @FromIndex AND @ToIndex
	--	Select getdate() as [16]  





		DROP TABLE 	#tmpConnectionUserInfo
		
		

		
		
--SELECT * FROM @Tbl_RecommendedTripsSavings

END
GO
