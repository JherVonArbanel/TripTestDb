SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- EXEC usp_GetTMU_CrowdCount 'LAS','FROM' ,5,12,3,1,0,NULL,0,'','',0,0, 1, 12, '', '', ''
-- 560812

CREATE PROC [dbo].[usp_GetTMU_CrowdCount]
(
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
	@hotelClass INT = 0,
	@loggedInUserKey BIGINT = 0,
	@FromIndex INT = 1,
	@ToIndex INT = 1,
	@CarClass VARCHAR(50) = '',
	@AirClass VARCHAR(50) = '',
	@AirType VARCHAR(50) = ''

)
AS 
BEGIN
	SET NOCOUNT ON;
	
	-- ##### VARIABLE DELCARATION ##### --
	DECLARE @RowNumber INT = 0
	DECLARE @HotelRating1 FLOAT = -1
	DECLARE @HotelRating2 FLOAT = -1
	DECLARE @HotelRating3 FLOAT = -1
	DECLARE @IsTypeFilterSelected BIT = 0
	DECLARE @fromDate DATETIME
	DECLARE @endDate DATETIME 			
	DECLARE @TripCount INT = 0
	
	
	-- ##### TABLE DELCARATION ##### --	
	DECLARE @PreferredCityList AS TABLE
	(
		CityCode VARCHAR(3),
		CityName VARCHAR(100)	
	)
	DECLARE @NeighboringAirportLookup AS TABLE
	(
		neighborAirportCode VARCHAR(3)
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

	DECLARE @CalculateTripScoring AS TABLE
	(
		tripSavedKey UNIQUEIDENTIFIER,		
		Recency FLOAT,
		Proximity FLOAT
	)

	DECLARE @BookersCount AS TABLE 
	(
		tripSavedKey UNIQUEIDENTIFIER,
		BookersCount INT
	)
	
	DECLARE @MostLikeCount AS TABLE 
	(
		tripKey INT,
		LikeCount INT
	)

	DECLARE @WatchersCount AS TABLE 
	(
		tripSavedKey UNIQUEIDENTIFIER,
		WatchersCount INT,
		CrowdId BIGINT 
	)
	
	DECLARE @FastestTrending AS TABLE 
	(
		tripSavedKey UNIQUEIDENTIFIER,
		FastestTrending FLOAT
	)	

	DECLARE @TripFollowersDetails AS TABLE
	(
		tripSavedKey UNIQUEIDENTIFIER,		
		userKey INT,
		userName VARCHAR(200) DEFAULT NULL,
		userImageURL VARCHAR(500)DEFAULT NULL,
		tripKey INT DEFAULT(0)
	)
	

	DECLARE @Tripdetails AS TABLE                     
	(                    
		-- TripdetailsKey int identity (1,1) ,                    
		tripKey int NULL,                    
		tripsavedKey uniqueidentifier NULL ,                    
		triprequestkey int NULL , 
		userKey INT,                   
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
		originalTotalPrice FLOAT NULL,  
		UserName VARCHAR(200),
		FacebookUserUrl VARCHAR(500),
		WatchersCount INT,
		LikeCount INT ,
		--ThemeType INT DEFAULT(0),
		IsWatcher BIT DEFAULT(0),
		BookersCount INT DEFAULT(0),
		TripPurchaseKey uniqueidentifier NULL,
		FastestTrending FLOAT NULL,
		TotalSavings FLOAT,
		RowNumber INT,
		Rating FLOAT,
		--AirSegmentCabinAbbrevation VARCHAR(50),
		AirSegmentCabin VARCHAR(50),
		--CarClassAbbrevation VARCHAR(100),
		CarClass VARCHAR(100),
		AirRequestTypeName VARCHAR(50),
		--NoOfStops VARCHAR(20),
		HotelRegionName VARCHAR(100),
		TripScoring FLOAT,
		DestinationImageURL VARCHAR(500),
		SavingsRanking FLOAT DEFAULT(0),
		Recency FLOAT DEFAULT(0),
		RecencyRanking FLOAT DEFAULT(0),
		Proximity INT DEFAULT(0),
		ProximityRanking FLOAT DEFAULT(0),
		SocialRanking FLOAT DEFAULT(0),
		ComponentRanking FLOAT DEFAULT(0),
		FromCity	VARCHAR(100),
		FromState VARCHAR(100),
		FromCountry VARCHAR(100),
		ToCity	VARCHAR(100),
		ToState VARCHAR(100),
		ToCountry VARCHAR(100),
		tripPurchasedKey uniqueidentifier NULL,
		tripStatusKey INT DEFAULT(0),
		IsMyTrip BIT DEFAULT(0),
		LatestDealAirPriceTotal FLOAT DEFAULT(0),
		LatestDealHotelPriceTotal FLOAT DEFAULT(0),
		LatestDealCarPriceTotal FLOAT DEFAULT(0),
		LatestDealAirPricePerPerson FLOAT DEFAULT(0),
		LatestDealHotelPricePerPerson FLOAT DEFAULT(0),
		LatestDealCarPricePerPerson FLOAT DEFAULT(0),		
		IsBackFillData BIT DEFAULT(0),
		IsZeroPriceAvailable BIT DEFAULT(0),
		LatestAirLineCode VARCHAR(30),
		LatestAirlineName VARCHAR(64),		
		LatestHotelChainCode VARCHAR(20),		
		HotelName VARCHAR(100),
		CarVendorCode VARCHAR(50),
		LatestCarVendorName VARCHAR(30),
		CurrentHotelsComId VARCHAR(10),
		LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),
		DateRanking FLOAT DEFAULT(0),
		NumberOfCurrentAirStops INT DEFAULT(0),
		ExactCityMatchRanking FLOAT DEFAULT(0),
		LatestHotelRegionId INT DEFAULT(0),
		CrowdId BIGINT

	)

	DECLARE @TripdetailsBackFill AS TABLE                     
	(                    
		-- TripdetailsKey int identity (1,1) ,                    
		tripKey int NULL,                    
		tripsavedKey uniqueidentifier NULL ,                    
		triprequestkey int NULL , 
		userKey INT,                   
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
		originalTotalPrice FLOAT NULL,  
		UserName VARCHAR(200),
		FacebookUserUrl VARCHAR(500),
		WatchersCount INT,
		LikeCount INT ,
		--ThemeType INT DEFAULT(0),
		IsWatcher BIT DEFAULT(0),
		BookersCount INT DEFAULT(0),
		TripPurchaseKey uniqueidentifier NULL,
		FastestTrending FLOAT NULL,
		TotalSavings FLOAT,
		RowNumber INT,
		Rating FLOAT,
		--AirSegmentCabinAbbrevation VARCHAR(50),
		AirSegmentCabin VARCHAR(50),
		--CarClassAbbrevation VARCHAR(100),
		CarClass VARCHAR(100),
		AirRequestTypeName VARCHAR(50),
		--NoOfStops VARCHAR(20),
		HotelRegionName VARCHAR(100),
		TripScoring FLOAT,
		DestinationImageURL VARCHAR(500),
		SavingsRanking FLOAT DEFAULT(0),
		Recency FLOAT DEFAULT(0),
		RecencyRanking FLOAT DEFAULT(0),
		Proximity INT DEFAULT(0),
		ProximityRanking FLOAT DEFAULT(0),
		SocialRanking FLOAT DEFAULT(0),
		ComponentRanking FLOAT DEFAULT(0),
		FromCity	VARCHAR(100),
		FromState VARCHAR(100),
		FromCountry VARCHAR(100),
		ToCity	VARCHAR(100),
		ToState VARCHAR(100),
		ToCountry VARCHAR(100),
		tripPurchasedKey uniqueidentifier NULL,
		tripStatusKey INT DEFAULT(0),
		IsMyTrip BIT DEFAULT(0),
		LatestDealAirPriceTotal FLOAT DEFAULT(0),
		LatestDealHotelPriceTotal FLOAT DEFAULT(0),
		LatestDealCarPriceTotal FLOAT DEFAULT(0),
		LatestDealAirPricePerPerson FLOAT DEFAULT(0),
		LatestDealHotelPricePerPerson FLOAT DEFAULT(0),
		LatestDealCarPricePerPerson FLOAT DEFAULT(0),		
		IsBackFillData BIT DEFAULT(0),
		IsZeroPriceAvailable BIT DEFAULT(0),
		LatestAirLineCode VARCHAR(30),
		LatestAirlineName VARCHAR(64),		
		LatestHotelChainCode VARCHAR(20),		
		HotelName VARCHAR(100),
		CarVendorCode VARCHAR(50),
		LatestCarVendorName VARCHAR(30),
		CurrentHotelsComId VARCHAR(10),
		LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),
		DateRanking FLOAT DEFAULT(0),
		NumberOfCurrentAirStops INT DEFAULT(0),
		ExactCityMatchRanking FLOAT DEFAULT(0),
		LatestHotelRegionId INT DEFAULT(0),
		CrowdId BIGINT	

	)
	
	DECLARE @TripdetailsTemp AS TABLE                     
	(                    
		-- TripdetailsKey int identity (1,1) ,                    
		tripKey int NULL,                    
		tripsavedKey uniqueidentifier NULL ,                    
		triprequestkey int NULL , 
		userKey INT,                   
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
		originalTotalPrice FLOAT NULL,  
		UserName VARCHAR(200),
		FacebookUserUrl VARCHAR(500),
		WatchersCount INT,
		LikeCount INT ,
		--ThemeType INT DEFAULT(0),
		IsWatcher BIT DEFAULT(0),
		BookersCount INT DEFAULT(0),
		TripPurchaseKey uniqueidentifier NULL,
		FastestTrending FLOAT NULL,
		TotalSavings FLOAT,
		RowNumber INT,
		Rating FLOAT,
		--AirSegmentCabinAbbrevation VARCHAR(50),
		AirSegmentCabin VARCHAR(50),
		--CarClassAbbrevation VARCHAR(100),
		CarClass VARCHAR(100),
		AirRequestTypeName VARCHAR(50),
		--NoOfStops VARCHAR(20),
		HotelRegionName VARCHAR(100),
		TripScoring FLOAT,
		DestinationImageURL VARCHAR(500),
		SavingsRanking FLOAT DEFAULT(0),
		Recency FLOAT DEFAULT(0),
		RecencyRanking FLOAT DEFAULT(0),
		Proximity INT DEFAULT(0),
		ProximityRanking FLOAT DEFAULT(0),
		SocialRanking FLOAT DEFAULT(0),
		ComponentRanking FLOAT DEFAULT(0),
		FromCity	VARCHAR(100),
		FromState VARCHAR(100),
		FromCountry VARCHAR(100),
		ToCity	VARCHAR(100),
		ToState VARCHAR(100),
		ToCountry VARCHAR(100),		 		 			   
		tripPurchasedKey uniqueidentifier NULL,
		tripStatusKey INT DEFAULT(0),
		IsMyTrip BIT DEFAULT(0),
		LatestDealAirPriceTotal FLOAT DEFAULT(0),
		LatestDealHotelPriceTotal FLOAT DEFAULT(0),
		LatestDealCarPriceTotal FLOAT DEFAULT(0),
		LatestDealAirPricePerPerson FLOAT DEFAULT(0),
		LatestDealHotelPricePerPerson FLOAT DEFAULT(0),
		LatestDealCarPricePerPerson FLOAT DEFAULT(0),		
		IsBackFillData BIT DEFAULT(0),
		IsZeroPriceAvailable BIT DEFAULT(0),
		LatestAirLineCode VARCHAR(30),
		LatestAirlineName VARCHAR(64),		
		LatestHotelChainCode VARCHAR(20),		
		HotelName VARCHAR(100),
		CarVendorCode VARCHAR(50),
		LatestCarVendorName VARCHAR(30),
		CurrentHotelsComId VARCHAR(10),
		LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),
		DateRanking FLOAT DEFAULT(0),
		NumberOfCurrentAirStops INT DEFAULT(0),
		ExactCityMatchRanking FLOAT DEFAULT(0),
		LatestHotelRegionId INT DEFAULT(0),
		CrowdId BIGINT
	)



	DECLARE @TripdetailsFinal AS TABLE                     
	(                    
		-- TripdetailsKey int identity (1,1) ,                    
		tripKey int NULL,                    
		tripsavedKey uniqueidentifier NULL ,                    
		triprequestkey int NULL , 
		userKey INT,                   
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
		originalTotalPrice FLOAT NULL,  
		UserName VARCHAR(200),
		FacebookUserUrl VARCHAR(500),
		WatchersCount INT,
		LikeCount INT ,
		--ThemeType INT DEFAULT(0),
		IsWatcher BIT DEFAULT(0),
		BookersCount INT DEFAULT(0),
		TripPurchaseKey uniqueidentifier NULL,
		FastestTrending FLOAT NULL,
		TotalSavings FLOAT,
		RowNumber INT,
		Rating FLOAT,
		--AirSegmentCabinAbbrevation VARCHAR(50),
		AirSegmentCabin VARCHAR(50),
		--CarClassAbbrevation VARCHAR(100),
		CarClass VARCHAR(100),
		AirRequestTypeName VARCHAR(50),
		--NoOfStops VARCHAR(20),
		HotelRegionName VARCHAR(100),
		TripScoring FLOAT,
		DestinationImageURL VARCHAR(500),
		SavingsRanking FLOAT DEFAULT(0),
		Recency FLOAT DEFAULT(0),
		RecencyRanking FLOAT DEFAULT(0),
		Proximity INT DEFAULT(0),
		ProximityRanking FLOAT DEFAULT(0),
		SocialRanking FLOAT DEFAULT(0),
		ComponentRanking FLOAT DEFAULT(0),
		FromCity	VARCHAR(100),
		FromState VARCHAR(100),
		FromCountry VARCHAR(100),
		ToCity	VARCHAR(100),
		ToState VARCHAR(100),
		ToCountry VARCHAR(100),
		tripPurchasedKey uniqueidentifier NULL,
		tripStatusKey INT DEFAULT(0),
		IsMyTrip BIT DEFAULT(0),
		LatestDealAirPriceTotal FLOAT DEFAULT(0),
		LatestDealHotelPriceTotal FLOAT DEFAULT(0),
		LatestDealCarPriceTotal FLOAT DEFAULT(0),
		LatestDealAirPricePerPerson FLOAT DEFAULT(0),
		LatestDealHotelPricePerPerson FLOAT DEFAULT(0),
		LatestDealCarPricePerPerson FLOAT DEFAULT(0),		
		IsBackFillData BIT DEFAULT(0),
		IsZeroPriceAvailable BIT DEFAULT(0),
		LatestAirLineCode VARCHAR(30),
		LatestAirlineName VARCHAR(64),		
		LatestHotelChainCode VARCHAR(20),		
		HotelName VARCHAR(100),
		CarVendorCode VARCHAR(50),
		LatestCarVendorName VARCHAR(30),
		CurrentHotelsComId VARCHAR(10),
		LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),
		DateRanking FLOAT DEFAULT(0),
		NumberOfCurrentAirStops INT DEFAULT(0),
		ExactCityMatchRanking FLOAT DEFAULT(0),
		LatestHotelRegionId INT DEFAULT(0),
		CrowdId BIGINT	

	)

-- ###################### COMMON CODE ######################## ---

	IF @startDate IS NULL 
	BEGIN 
		  SET @fromDate = CONVERT(DATETIME, '1753-01-01 00:00:00', 20)
		  SET @endDate = '9999-12-31' -- THIS IS MAX DATE 
	END
	ELSE 
	BEGIN 
	
	/* CODE COMMENTED BECOZ CLIENT NOW WANTS 3 MONTHS WINDOW I.E.(+3 and -3) FROM DATE SELECTED BY USER FROM UI ..
	 
		SELECT @endDate = DATEADD(month, ((YEAR(@startDate) - 1900) * 12) + MONTH(@startDate), -1)								  		  		
		SET @endDate = DATEADD(SECOND, 86399,@endDate) -- THIS WILL MAKE TIME UPTO 23:59:59
	*/
		SET @fromDate = DATEADD(month,-2, DATEADD(dd,-(DAY(@startDate)-1),@startDate))
		SET @endDate  = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@startDate)+3,0))
			
	END               
	
	PRINT '@fromDate :- ' + CAST(@fromDate AS VARCHAR)			 
	PRINT '@endDate :- ' + CAST(@endDate AS VARCHAR)



	IF @CarClass = 'C'
	BEGIN 
		SET @CarClass = 'COMPACT'
	END
	ELSE IF @CarClass = 'E'
	BEGIN 
		SET @CarClass = 'ECONOMY'
	END
	ELSE IF @CarClass = 'S'
	BEGIN 
		SET @CarClass = 'STANDARD'
	END
	ELSE IF @CarClass = 'F'
	BEGIN 
		SET @CarClass = 'FULL SIZE'
	END
	ELSE IF @CarClass = 'P'
	BEGIN 
		SET @CarClass = 'PREMIUM'
	END
	ELSE IF @CarClass = 'X'
	BEGIN 
		SET @CarClass = 'SPECIAL'
	END
	ELSE IF @CarClass = 'M'
	BEGIN 
		SET @CarClass = 'MINI VAN'
	END
	ELSE IF @CarClass = 'I'
	BEGIN 
		SET @CarClass = 'INTERMEDIATE'
	END
	ELSE IF @CarClass = 'L'
	BEGIN 
		SET @CarClass = 'LUXURY'
	END
	
	
	IF @AirType = 'OneWayTrip'
	BEGIN
		SET @AirType = 'ONEWAY'
	END
	
	-- RIGHT NOW IT IS SET TO BLANK BECAUSE THERE IS PROBLEM OF DATA COMING FROM UI WHERE STEVE NEEDS TO WORK ON IT...TILL THAT
	-- KEEP BELOW CODE SET TO BLANK. 
	SET	@CarClass = ''
	SET @AirClass = ''
	SET @AirType = ''

	
	
/*	CODE COMMENTED BECOZ CLIENT NOW WANTS 3 MONTHS WINDOW I.E.(+3 and -3) FROM DATE SELECTED BY USER FROM UI ..
	HENCE BELOW CODE IS OF NO USE AS ITS CONDITION WILL BRING TODAY's DATE IF START DATE IS LESS THAN TODAY's DATE.. 
	
	IF @startDate < GETDATE()
	BEGIN 
		SET @startDate = CONVERT(DATETIME, GETDATE(), 20)
	END		  
*/
	

	
/* #################################################################################### 
		STEP 1 STARTS :- FILTER DATA AND PREPARE RESULT SET  
#################################################################################### */
	
	IF @sortfield <> ''
	BEGIN 	
	
		--PRINT 'SORT FIELD'
		
		-- THIS IS DONE TO AVOID FURTHER PROBLEM IN BELOW "IF" STATEMENTS IN SP ...
		SET @friendOption = ''
		
		INSERT INTO @Tripdetails
		( 
			tripKey,
			tripsavedKey,
			triprequestkey,
			userKey,
			tripstartdate,
			tripenddate,
			tripfrom,
			tripTo, 
			tripComponentType,
			tripComponents, 
			rankRating, 
			currentTotalPrice, 
			originalTotalPrice,
			UserName, 
			FacebookUserUrl, 
			WatchersCount, 
			LikeCount, 
			--ThemeType, 
			TripPurchaseKey,
			BookersCount, 
			FastestTrending,
			TotalSavings,
			RowNumber,
			Rating,
			--AirSegmentCabinAbbrevation,
			AirSegmentCabin,
			--CarClassAbbrevation,
			CarClass,
			AirRequestTypeName,
			--NoOfStops,
			HotelRegionName,
			DestinationImageURL,
			FromCity	,
			FromState ,
			FromCountry ,
			ToCity	,
			ToState ,
			ToCountry,
			tripPurchasedKey,
			tripStatusKey,
			IsMyTrip,
			LatestDealAirPriceTotal,
			LatestDealHotelPriceTotal,
			LatestDealCarPriceTotal,
			LatestDealAirPricePerPerson,
			LatestDealHotelPricePerPerson,
			LatestDealCarPricePerPerson,
			IsZeroPriceAvailable,
			LatestAirLineCode ,
			LatestAirlineName ,		
			LatestHotelChainCode ,		
			HotelName ,
			CarVendorCode ,
			LatestCarVendorName,
			CurrentHotelsComId,
			LatestDealHotelPricePerPersonPerDay,
			NumberOfCurrentAirStops,
			LatestHotelRegionId	,
			CrowdId
			
		)                    
		SELECT  
			t1.tripKey, 
			t1.tripsavedKey,
			t1.triprequestkey,
			TD.userKey,
			TD.tripStartDate, 
			TD.tripEndDate,
			TD.tripFrom, 
			TD.tripTo, 
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
			 0 as [Rank],  
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)
				ELSE
					ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)
				END	as CurrentTotalPrice,  
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)
				ELSE
					ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)
				END	as OriginalTotalPrice,  				
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
			ISNULL(UM.ImageURL,'') as FacebookUserUrl,
			0 as WatchersCount,
			0 as LikeCount,
			--ISNULL(D.PrimaryTripType,0)	as  ThemeType,
			T1.tripPurchasedKey,
			0 as BookersCount,
			0 as FastestTrending,
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)
				ELSE			
					ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)				
				END	as TotalSavings,
			0,
			HotelRating, 
			--'' -- AirSegmentCabinAbbrevation
			TD.AirCabin,  -- AirSegmentCabin
			--,'' -- CarClassAbbrevation
			TD.CarClass, -- CarClass
			TD.AirRequestTypeName, -- AirRequestTypeName
			--TD., -- NoOfStops
			TD.HotelRegionName,
			T1.DestinationSmallImageURL,
			TD.fromCityName,
			CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,			
			CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,
			TD.toCityName,
			CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,
			CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,
			T1.tripPurchasedKey,
			T1.tripStatusKey,
			CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ... 
			CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,
			CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,				 
			ISNULL(TD.latestDealCarPriceTotal,0) ,
			ISNULL(TD.latestDealAirPricePerPerson,0) ,
			ISNULL(TD.latestDealHotelPricePerPerson,0) ,			 						
			ISNULL(TD.latestDealCarPricePerPerson,0) ,
			CASE 
				WHEN T1.tripComponentType = 1 AND ISNULL(TD.latestDealAirPriceTotal,0) = 0 THEN 1 -- 'Air'
				WHEN T1.tripComponentType = 2 AND ISNULL(TD.latestDealCarPriceTotal,0) = 0 THEN 1 -- 'Car'
				WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0) THEN 1 --  'Air,Car'
				WHEN T1.tripComponentType = 4 AND ISNULL(TD.latestDealHotelPriceTotal,0) = 0 THEN 1 -- 'Hotel'
				WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Hotel'          
				WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Car,Hotel'          
				WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Car,Hotel'    
				ELSE 0									      
			END,
			ISNULL(LatestAirLineCode,''),
			ISNULL(LatestAirlineName,''),
			ISNULL(LatestHotelChainCode,''),
			ISNULL(HotelName,''),
			ISNULL(CarVendorCode,''),
			ISNULL(LatestCarVendorName,''),
			ISNULL(CurrentHotelsComId, ''),
			ISNULL(TD.LatestDealHotelPricePerPersonPerDay,0),
			ISNULL(TD.NumberOfCurrentAirStops,0),
			ISNULL(TD.LatestHotelRegionId,0),
			TD.crowdId
							 				
		FROM 
			TripDetails TD WITH (NOLOCK)         
		INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey 
		INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                             		  		    		
		LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId	  
		where  T1.tripStatusKey <> 17  		  		  
		AND t1.tripKey <> @tripKey 
		AND T1.IsWatching = 1
		AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....		
		AND 
		((T1.privacyType = 1) OR (T1.userKey = @loggedInUserKey AND T1.privacyType = 2))  -- FOR PUBLIC AND PRIVATE PROFILE 
		
		
		
	END		
	ELSE IF @page = 1 OR @page= 9 OR  @page = 11 OR @page = 12 OR @page = 15
	/*
		1	= HOME PAGE 
		9	= HOTEL SECTION LANDING PAGE 
		11	= FLIGHT SECTION LANDING PAGE
		12	= CAR SECTION LANDING PAGE   
		15  = TRIP SUMMARY
	*/
	          
	BEGIN 
	
-- GET NEIGHBOURHOOD AIRPORT DATA WHICH ARE WITHIN 100 MILES AND STORE IT IN TEMP TABLE ...  
		INSERT INTO @NeighboringAirportLookup
		SELECT 
			neighborAirportCode 
		FROM 
			NeighboringAirportLookup WITH (NOLOCK)
		WHERE 
			airportCode = @cityCode
		AND 
			distanceInMiles <= 50
			
-- SETTING HOTEL RATING WHICH IS THEN USED TO FILTER DATA AS PER HOTEL RATING SELECTED BY USER ....   		
		IF (@hotelClass = 5)
		BEGIN 		
			SET @HotelRating1 = 5
			SET @HotelRating2 = 5
			SET @HotelRating3 = 4.5
		END 
		ELSE IF (@hotelClass = 4)
		BEGIN 
			SET @HotelRating1 = 4
			SET @HotelRating2 = 4.5
			SET @HotelRating3 = 3.5
		END  
		ELSE IF (@hotelClass = 3)
		BEGIN 
			SET @HotelRating1 = 3
			SET @HotelRating2 = 3.5
			SET @HotelRating3 = 2.5
		END  

/* GET DATA AS PER OPTION SELECTED
 ONLY ME = ONLY MY TRIPS 
 CONNECTIONS = PEOPLE WHICH ARE IN MY CONNECTIONS 
 CONNECTIONS AND FOLLOW = ME + PEOPLE WHICH ARE IN MY CONNECTIONS  
*/ 
		IF (@friendOption = 'OnlyMe')
		BEGIN 
			
			--PRINT 'Inside OnlyMe'
			
			INSERT INTO @ConnectionsUserInfo
			(UserId)
			VALUES
			(
				@loggedInUserKey
			)

		END    
		ELSE IF (@friendOption = 'Connections')
		BEGIN 
			
			--PRINT 'Inside Connections'

			INSERT INTO @ConnectionsUserInfo 
			(
				UserId
			)
			SELECT 
				UserId 
			FROM 
				Loyalty..UserMap WITH (NOLOCK)
			WHERE 
				ParentId = @loggedInUserKey
			AND 
				@loggedInUserKey <> 0


		END 
		ELSE IF (@friendOption = 'ConnectionAndFollow')
		BEGIN 

			--PRINT 'Inside ConnectionAndFollow'
			
			INSERT INTO @ConnectionsUserInfo
			(UserId)
			VALUES
			(
				@loggedInUserKey
			)

			
			INSERT INTO @ConnectionsUserInfo (UserId)
			SELECT UserId FROM Loyalty..UserMap WITH (NOLOCK)
			WHERE ParentId = @loggedInUserKey	
			AND @loggedInUserKey <> 0

		END

-- GET TRIPS AS PER OPTION SELECTED AND SAVE IT IN TEMP TABLE ....
		INSERT INTO @ConnectionsUserSaveTripInfo
		(
			tripSavedKey,
			tripKey,
			userKey
		)	
		SELECT DISTINCT 
			tripSavedKey, 
			tripKey, 
			userKey 
		FROM 
			Trip WITH (NOLOCK)
		INNER JOIN 
			@ConnectionsUserInfo CUI ON Trip.userKey = CUI.UserId   
				
		--PRINT 'FILTERED TMU '
		INSERT INTO @Tripdetails
		( 
			tripKey,
			tripsavedKey,
			triprequestkey,
			userKey,
			tripstartdate,
			tripenddate,
			tripfrom,
			tripTo, 
			tripComponentType,
			tripComponents, 
			rankRating, 
			currentTotalPrice, 
			originalTotalPrice,
			UserName, 
			FacebookUserUrl, 
			WatchersCount, 
			LikeCount, 
			--ThemeType, 
			TripPurchaseKey,
			BookersCount, 
			FastestTrending,
			TotalSavings,
			RowNumber,
			Rating,
			--AirSegmentCabinAbbrevation,
			AirSegmentCabin,
			--CarClassAbbrevation,
			CarClass,
			AirRequestTypeName,
			--NoOfStops,
			HotelRegionName,
			DestinationImageURL,
			FromCity	,
			FromState ,
			FromCountry ,
			ToCity	,
			ToState ,
			ToCountry,
			tripPurchasedKey,
			tripStatusKey,
			IsMyTrip,
			LatestDealAirPriceTotal,
			LatestDealHotelPriceTotal,
			LatestDealCarPriceTotal,
			LatestDealAirPricePerPerson,
			LatestDealHotelPricePerPerson,
			LatestDealCarPricePerPerson,
			IsZeroPriceAvailable,
			LatestAirLineCode ,
			LatestAirlineName ,		
			LatestHotelChainCode ,		
			HotelName ,
			CarVendorCode ,
			LatestCarVendorName, 
			CurrentHotelsComId,
			LatestDealHotelPricePerPersonPerDay,
			NumberOfCurrentAirStops,
			LatestHotelRegionId,
			CrowdId
			
		)                    
		SELECT  
			t1.tripKey, 
			t1.tripsavedKey,
			t1.triprequestkey,
			TD.userKey,
			TD.tripStartDate, 
			TD.tripEndDate,
			TD.tripFrom, 
			TD.tripTo, 
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
			 0 as [Rank],  
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)
				ELSE
					ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)
				END	as CurrentTotalPrice,  
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)
				ELSE
					ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)
				END	as OriginalTotalPrice,  				
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
			ISNULL(UM.ImageURL,'') as FacebookUserUrl,
			0 as WatchersCount,
			0 as LikeCount,
			--ISNULL(D.PrimaryTripType,0)	as  ThemeType,
			T1.tripPurchasedKey,
			0 as BookersCount,
			0 as FastestTrending,
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)
				ELSE			
					ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)				
				END	as TotalSavings,
			0,
			HotelRating, 
			--'' -- AirSegmentCabinAbbrevation
			TD.AirCabin,  -- AirSegmentCabin
			--,'' -- CarClassAbbrevation
			TD.CarClass, -- CarClass
			TD.AirRequestTypeName, -- AirRequestTypeName
			--TD., -- NoOfStops
			TD.HotelRegionName,
			T1.DestinationSmallImageURL,
			TD.fromCityName,
			CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,			
			CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,
			TD.toCityName,
			CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,
			CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,
			T1.tripPurchasedKey,
			T1.tripStatusKey,
			CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ... 
			CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,
			CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,				 				 
			ISNULL(TD.latestDealCarPriceTotal,0) ,
			ISNULL(TD.latestDealAirPricePerPerson,0) ,
			ISNULL(TD.LatestDealHotelPricePerPerson,0) ,			 						
			ISNULL(TD.latestDealCarPricePerPerson,0) ,
			CASE 
				WHEN T1.tripComponentType = 1 AND ISNULL(TD.latestDealAirPriceTotal,0) = 0 THEN 1 -- 'Air'
				WHEN T1.tripComponentType = 2 AND ISNULL(TD.latestDealCarPriceTotal,0) = 0 THEN 1 -- 'Car'
				WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0) THEN 1 --  'Air,Car'
				WHEN T1.tripComponentType = 4 AND ISNULL(TD.latestDealHotelPriceTotal,0) = 0 THEN 1 -- 'Hotel'
				WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Hotel'          
				WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Car,Hotel'          
				WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Car,Hotel'          
				ELSE 0
			END,
			ISNULL(LatestAirLineCode,''),
			ISNULL(LatestAirlineName,''),
			ISNULL(LatestHotelChainCode,''),
			ISNULL(HotelName,''),
			ISNULL(CarVendorCode,''),
			ISNULL(LatestCarVendorName,''),							 				
			ISNULL(CurrentHotelsComId, ''),
			ISNULL(TD.LatestDealHotelPricePerPersonPerDay,0),
			ISNULL(TD.NumberOfCurrentAirStops,0),
			ISNULL(TD.LatestHotelRegionId,0),
			Td.CrowdId
		FROM 
			TripDetails TD WITH (NOLOCK)         
		INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey 
		INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                             		  		    
		/*		  
		REMOVED BELOW CONDITION SINCE NOW 1st LAYER WILL BRING ALL MIX RESULTS (AIR, CAR, HOTEL) ...
		INNER JOIN dbo.udf_GetTripComponentType(@page,@typeFilter) FN_TRIPCOMPONENT ON T1.tripComponentType = FN_TRIPCOMPONENT.TripComponentType -- THIS IS DONE TO ADD SOME COMPONENT TYPE INTO TABLE. 
		*/		  
		INNER JOIN @NeighboringAirportLookup NAL ON (CASE WHEN @cityType = 'From' THEN TD.tripFrom ELSE TD.tripTo END) = NAL.neighborAirportCode    
		LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId	  
		where  T1.tripStatusKey <> 17  		  		  
		AND t1.tripKey <> @tripKey 
		AND T1.IsWatching = 1
		AND TD.tripStartDate BETWEEN @fromDate AND @endDate		  		  
		AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....		
		AND 
		((T1.privacyType = 1) OR (T1.userKey = @loggedInUserKey AND T1.privacyType = 2))  -- FOR PUBLIC AND PRIVATE PROFILE 
		
		AND 		
		(
				TD.HotelRating = 
					CASE WHEN @HotelRating1 = -1 THEN HotelRating
					ELSE @HotelRating1
					END
				OR
				TD.HotelRating = 
					CASE WHEN @HotelRating2 = -1 THEN HotelRating
					ELSE @HotelRating2
					END
				OR
				TD.HotelRating = 
					CASE WHEN @HotelRating3 = -1 THEN HotelRating
					ELSE @HotelRating3
					END
					
		)
		
		AND 
			UPPER(ISNULL(TD.CarClass,'')) = 
				CASE
					WHEN @CarClass = '' THEN UPPER(ISNULL(TD.CarClass,''))
					WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @CarClass
				ELSE UPPER(ISNULL(TD.CarClass,''))
				END
						
		AND
			UPPER(ISNULL(TD.AirCabin,'')) = 				
				CASE 
					WHEN @AirClass = '' THEN UPPER(ISNULL(TD.AirCabin,''))
					WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @AirClass
				ELSE UPPER(ISNULL(TD.AirCabin,''))
				END 
		AND
			UPPER(ISNULL(TD.AirRequestTypeName,'')) = 
				CASE 
					WHEN @AirType = '' THEN UPPER(ISNULL(TD.AirRequestTypeName,''))
					WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @AirType
				ELSE UPPER(ISNULL(TD.AirRequestTypeName,''))
				END																
		

		IF (@cityType = 'From') 
		BEGIN 
			
			IF (@page = 9)  -- /* 9 = HOTEL SECTION LANDING PAGE */
			BEGIN
				--PRINT 'Delete Hotel Only TMUs with same airport'
				DELETE FROM @Tripdetails
				WHERE tripComponentType = 4	
				AND tripfrom = @cityCode 	
			END
			ELSE IF (@page = 1 AND @tripComponentType = 4) -- /* Page = 1(HOME PAGE) | TripComponentType = 4 (HOTEL ONLY) */ 
			BEGIN
				PRINT 'Dont Delete anything'
			END
			ELSE
			BEGIN 
				--PRINT 'Delete Hotel Only TMUs'
				DELETE FROM @Tripdetails
				WHERE tripComponentType = 4				
			END
		END

		IF (@friendOption <> '')
		BEGIN 

			 -- THIS DELETE STATEMENT IS USED TO DELETE RECORDS OF TRIPS WHERE USER KEY ARE NOT IN CONNECTIONS    
			 DELETE FROM @Tripdetails 
			 WHERE tripKey NOT IN (SELECT tripKey FROM @ConnectionsUserSaveTripInfo WHERE tripKey <> 0)
			 
				
			IF ( @loggedInUserKey > 0 )
			BEGIN

				 UPDATE TD 
				 SET IsWatcher = 1 
				 FROM @Tripdetails TD 			 
				 INNER JOIN @ConnectionsUserSaveTripInfo CUS ON TD.tripsavedKey = CUS.tripSavedKey WHERE CUS.userKey = @loggedInUserKey
			END	 
			 			 
		END
		


	END
	ELSE IF (@page = 2) -- MY TRIPS 
	BEGIN 
		--PRINT 'TRIP BOARD'
		
		SET @friendOption = ''
	
		INSERT INTO @Tripdetails
		( 
			tripKey,
			tripsavedKey,
			triprequestkey,
			userKey,
			tripstartdate,
			tripenddate,
			tripfrom,
			tripTo, 
			tripComponentType,
			tripComponents, 
			rankRating, 
			currentTotalPrice, 
			originalTotalPrice,
			UserName, 
			FacebookUserUrl, 
			WatchersCount, 
			LikeCount, 
			--ThemeType, 
			TripPurchaseKey,
			BookersCount, 
			FastestTrending,
			TotalSavings,
			RowNumber,
			Rating,
			--AirSegmentCabinAbbrevation,
			AirSegmentCabin,
			--CarClassAbbrevation,
			CarClass,
			AirRequestTypeName,
			--NoOfStops,
			HotelRegionName,
			DestinationImageURL,
			FromCity	,
			FromState ,
			FromCountry ,
			ToCity	,
			ToState ,
			ToCountry,
			tripPurchasedKey,
			tripStatusKey,
			IsMyTrip,
			LatestDealAirPriceTotal,
			LatestDealHotelPriceTotal,
			LatestDealCarPriceTotal,
			LatestDealAirPricePerPerson,
			LatestDealHotelPricePerPerson,
			LatestDealCarPricePerPerson,
			IsZeroPriceAvailable,
			LatestAirLineCode ,
			LatestAirlineName ,		
			LatestHotelChainCode ,		
			HotelName ,
			CarVendorCode ,
			LatestCarVendorName, 
			CurrentHotelsComId,
			LatestDealHotelPricePerPersonPerDay,
			NumberOfCurrentAirStops,
			LatestHotelRegionId,
			CrowdId
			
		)                    
		SELECT  
			t1.tripKey, 
			t1.tripsavedKey,
			t1.triprequestkey,
			TD.userKey,
			TD.tripStartDate, 
			TD.tripEndDate,
			TD.tripFrom, 
			TD.tripTo, 
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
			 0 as [Rank],  
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)
				ELSE
					ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)
				END	as CurrentTotalPrice,  
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)
				ELSE
					ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)
				END	as OriginalTotalPrice,  				
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
			ISNULL(UM.ImageURL,'') as FacebookUserUrl,
			0 as WatchersCount,
			0 as LikeCount,
			--ISNULL(D.PrimaryTripType,0)	as  ThemeType,
			T1.tripPurchasedKey,
			0 as BookersCount,
			0 as FastestTrending,
			CASE 
				WHEN TD.userKey = @loggedInUserKey  THEN  
					ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)
				ELSE			
					ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)				
				END	as TotalSavings,
			0,
			HotelRating, 
			--'' -- AirSegmentCabinAbbrevation
			TD.AirCabin,  -- AirSegmentCabin
			--,'' -- CarClassAbbrevation
			TD.CarClass, -- CarClass
			TD.AirRequestTypeName, -- AirRequestTypeName
			--TD., -- NoOfStops
			TD.HotelRegionName,
			T1.DestinationSmallImageURL,
			TD.fromCityName,
			CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,			
			CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,
			TD.toCityName,
			CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,
			CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,
			T1.tripPurchasedKey,
			T1.tripStatusKey,
			CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ... 
			CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,
			CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,				 				 
			ISNULL(TD.latestDealCarPriceTotal,0) ,
			ISNULL(TD.latestDealAirPricePerPerson,0) ,
			ISNULL(TD.LatestDealHotelPricePerPerson,0) ,			 						
			ISNULL(TD.latestDealCarPricePerPerson,0) ,
			CASE 
				WHEN T1.tripComponentType = 1 AND ISNULL(TD.latestDealAirPriceTotal,0) = 0 THEN 1 -- 'Air'
				WHEN T1.tripComponentType = 2 AND ISNULL(TD.latestDealCarPriceTotal,0) = 0 THEN 1 -- 'Car'
				WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0) THEN 1 --  'Air,Car'
				WHEN T1.tripComponentType = 4 AND ISNULL(TD.latestDealHotelPriceTotal,0) = 0 THEN 1 -- 'Hotel'
				WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Hotel'          
				WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Car,Hotel'          
				WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Car,Hotel'          
				ELSE 0				
			END,
			ISNULL(LatestAirLineCode,''),
			ISNULL(LatestAirlineName,''),
			ISNULL(LatestHotelChainCode,''),
			ISNULL(HotelName,''),
			ISNULL(CarVendorCode,''),
			ISNULL(LatestCarVendorName,''),						 				
			ISNULL(CurrentHotelsComId, ''),
			ISNULL(TD.LatestDealHotelPricePerPersonPerDay,0),
			ISNULL(TD.NumberOfCurrentAirStops,0),
			ISNULL(TD.LatestHotelRegionId,0),
			TD.crowdId 									
		FROM 
			TripDetails TD WITH (NOLOCK)         
		INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey 
		INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                             		  		    		
		LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId	  
		where  T1.tripStatusKey <> 17  		  		  
		AND t1.tripKey <> @tripKey 
		AND T1.IsWatching = 1
		AND TD.userKey = @loggedInUserKey
		AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....		
	
	
	END 

-- ################ COMMON DELETE STATEMENTS AFTER RESULT SET PREPARATION ################ --
	
	/* BELOW DELETE STATEMENT IS COMMENTED BCOZ :- CLIENT WANTS THAT ALL TMU's SHOULD APPEAR IRRESPECTIVE 
	   OF THEIR SAVINGS IN -VE ....    
	DELETE FROM @Tripdetails
	WHERE TotalSavings <= 10
	*/
	-- THIS DELETE STATEMENT IS IMPLEMENTED BCOZ :- TMU OF THOSE USER WHICH ARE LOGGED IN + HE IS WATCHER + HIS TMU IS PURCHAED i.e.(PURCHASED KEY IS NOT NULL) SHOULD BE DELETED FROM PROD MIX ...
	--PRINT 'DELETE PURCHASED TMU 1'
	DELETE 
	FROM @Tripdetails 
	WHERE userKey = @loggedInUserKey
	AND tripPurchasedKey IS NOT NULL

	-- THIS DELETE STATEMENT IS IMPLEMENTED BCOZ :- ZERO PRICE TMU's WILL NOT COME .... 
	DELETE 
	FROM @Tripdetails
	WHERE IsZeroPriceAvailable = 1

	
/* ************************************************************************************ 
		STEP 1 ENDS :- FILTER DATA AND PREPARE RESULT SET  
************************************************************************************ */
		
---- ################# BACK FILL DATA STARTS ################# ------		
	IF @page = 1 OR @page= 9 OR  @page = 11 OR @page = 12 
	/*
		1	= HOME PAGE 
		9	= HOTEL SECTION LANDING PAGE 
		11	= FLIGHT SECTION LANDING PAGE
		12	= CAR SECTION LANDING PAGE   
	*/
	          
	BEGIN 
	
		SELECT @TripCount = COUNT(1) FROM @Tripdetails
		--PRINT '@TripCount :- ' + CAST(@TripCount AS VARCHAR) 
	
		IF (@TripCount < @ToIndex) -- THIS IS DONE FOR BACK FILL LOGIC ...
		BEGIN
		
			--PRINT 'BACK FILL DATA'

		-- ######### INSERT PREFERRED CITY DATA ######### --	
		
/*		BACKFILL LOGIC REMOVED AS DISCUSSED WITH CLIENT ........

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
				SELECT 'TPA' as CityCode , 'Ta@mpa' as CityName
				UNION					
				SELECT 'WAS' as CityCode , 'Washington D.C.' as CityName

			) as City ORDER BY City.CityName ASC 	

			
			INSERT INTO @TripdetailsBackFill
			( 
				tripKey,
				tripsavedKey,
				triprequestkey,
				userKey,
				tripstartdate,
				tripenddate,
				tripfrom,
				tripTo, 
				tripComponentType,
				tripComponents, 
				rankRating, 
				currentTotalPrice, 
				originalTotalPrice,
				UserName, 
				FacebookUserUrl, 
				WatchersCount, 
				LikeCount, 
				--ThemeType, 
				TripPurchaseKey,
				BookersCount, 
				FastestTrending,
				TotalSavings,
				RowNumber,
				Rating,
				--AirSegmentCabinAbbrevation,
				AirSegmentCabin,
				--CarClassAbbrevation,
				CarClass,
				AirRequestTypeName,
				--NoOfStops,
				HotelRegionName,
				DestinationImageURL,
				FromCity	,
				FromState ,
				FromCountry ,
				ToCity	,
				ToState ,
				ToCountry,
				tripPurchasedKey,
				tripStatusKey ,
				IsMyTrip,
				LatestDealAirPriceTotal,
				LatestDealHotelPriceTotal,
				LatestDealCarPriceTotal,
				LatestDealAirPricePerPerson,
				LatestDealHotelPricePerPerson,
				LatestDealCarPricePerPerson,
				IsZeroPriceAvailable,
				IsBackFillData,
				LatestAirLineCode ,
				LatestAirlineName ,		
				LatestHotelChainCode ,		
				HotelName ,
				CarVendorCode ,
				LatestCarVendorName,
				CurrentHotelsComId,
				LatestDealHotelPricePerPersonPerDay,
				NumberOfCurrentAirStops,
				LatestHotelRegionId
			)                    
			SELECT  
				t1.tripKey, 
				t1.tripsavedKey,
				t1.triprequestkey,
				TD.userKey,
				TD.tripStartDate, 
				TD.tripEndDate,
				TD.tripFrom, 
				TD.tripTo, 
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
				 0 as [Rank],  
				CASE 
					WHEN TD.userKey = @loggedInUserKey  THEN  
						ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)
					ELSE
						ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)
					END	as CurrentTotalPrice,  
				CASE 
					WHEN TD.userKey = @loggedInUserKey  THEN  
						ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)
					ELSE
						ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)
					END	as OriginalTotalPrice,  				
				UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
				ISNULL(UM.ImageURL,'') as FacebookUserUrl,
				0 as WatchersCount,
				0 as LikeCount,
				--ISNULL(D.PrimaryTripType,0)	as  ThemeType,
				T1.tripPurchasedKey,
				0 as BookersCount,
				0 as FastestTrending,
				CASE 
					WHEN TD.userKey = @loggedInUserKey  THEN  
						ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)
					ELSE			
						ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)				
					END	as TotalSavings,
				0,
				HotelRating, 
				--'' -- AirSegmentCabinAbbrevation
				TD.AirCabin,  -- AirSegmentCabin
				--,'' -- CarClassAbbrevation
				TD.CarClass, -- CarClass
				TD.AirRequestTypeName, -- AirRequestTypeName
				--TD., -- NoOfStops
				TD.HotelRegionName,
				T1.DestinationSmallImageURL,
				TD.fromCityName,
				CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,			
				CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,
				TD.toCityName,
				CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,
				CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,			
				T1.tripPurchasedKey,
				T1.tripStatusKey,
				CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ... 
				CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,
			CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,				 		 
				ISNULL(TD.latestDealCarPriceTotal,0) ,
				ISNULL(TD.latestDealAirPricePerPerson,0) ,
				ISNULL(TD.LatestDealHotelPricePerPerson,0) ,
				ISNULL(TD.latestDealCarPricePerPerson,0) ,
				CASE 
					WHEN T1.tripComponentType = 1 AND ISNULL(TD.latestDealAirPriceTotal,0) = 0 THEN 1 -- 'Air'
					WHEN T1.tripComponentType = 2 AND ISNULL(TD.latestDealCarPriceTotal,0) = 0 THEN 1 -- 'Car'
					WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0) THEN 1 --  'Air,Car'
					WHEN T1.tripComponentType = 4 AND ISNULL(TD.latestDealHotelPriceTotal,0) = 0 THEN 1 -- 'Hotel'
					WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Hotel'          
					WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Car,Hotel'          
					WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0) THEN 1 -- 'Air,Car,Hotel'          
					ELSE 0				
				END,
				1,
				ISNULL(LatestAirLineCode,''),
				ISNULL(LatestAirlineName,''),
				ISNULL(LatestHotelChainCode,''),
				ISNULL(HotelName,''),
				ISNULL(CarVendorCode,''),
				ISNULL(LatestCarVendorName,''),
				ISNULL(CurrentHotelsComId, ''),
				ISNULL(TD.LatestDealHotelPricePerPersonPerDay,0),
				ISNULL(TD.NumberOfCurrentAirStops,0),
				ISNULL(TD.LatestHotelRegionId,0)
			FROM 
				TripDetails TD WITH (NOLOCK)         
				INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey 
				INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                             		  		    				
				INNER JOIN @PreferredCityList PCL ON (CASE WHEN @cityType = 'From' THEN TD.tripFrom ELSE TD.tripTo END) = PCL.CityCode    				
				LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId	  
				where  T1.tripStatusKey <> 17  		  
				-- TODO AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
				AND T1.tripComponentType = 4 ------------- HOTEL ONLY, BCOZ OTHER TMU's SHOULD BE FETCHED WHICH ARE HOTEL ONLY ...					
				AND t1.tripKey <> @tripKey 
				AND T1.IsWatching = 1
				AND TD.tripStartDate BETWEEN @fromDate AND @endDate		  		  
				AND TD.tripKey NOT IN (SELECT tripKey FROM @Tripdetails)				
				AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....		
				AND 
					((T1.privacyType = 1) OR (T1.userKey = @loggedInUserKey AND T1.privacyType = 2)) 				
				AND  		
				(												
						TD.HotelRating = 
							CASE WHEN @HotelRating1 = -1 THEN HotelRating
							ELSE @HotelRating1
							END
						OR
						TD.HotelRating = 
							CASE WHEN @HotelRating2 = -1 THEN HotelRating
							ELSE @HotelRating2
							END
						OR
						TD.HotelRating = 
							CASE WHEN @HotelRating3 = -1 THEN HotelRating
							ELSE @HotelRating3
							END
						
				)						
*/		
		
-- ################ DELETE STATEMENTS AFTER BACK FILL RESULT SET PREPARATION ################ --
				
				/* BELOW DELETE STATEMENT IS COMMENTED BCOZ :- CLIENT WANTS THAT ALL TMU's SHOULD APPEAR IRRESPECTIVE 
				   OF THEIR SAVINGS IN -VE ....    
				DELETE FROM @TripdetailsBackFill
				WHERE TotalSavings <= 10
				*/
				-- THIS DELETE STATEMENT IS IMPLEMENTED BCOZ :- TMU OF THOSE USER WHICH ARE LOGGED IN + HE IS WATCHER + HIS TMU IS PURCHAED i.e.(PURCHASED KEY IS NOT NULL) SHOULD BE DELETED FROM PROD MIX ...
				--PRINT 'DELETE PURCHASED TMU BACKFILL'
				DELETE 
				FROM @TripdetailsBackFill 
				WHERE userKey = @loggedInUserKey
				AND tripPurchasedKey IS NOT NULL
		
		
				DELETE FROM @TripdetailsBackFill
				WHERE IsZeroPriceAvailable = 1
		
				IF (@cityType = 'From') 
				BEGIN 
					
					IF (@page = 9)  -- /* 9 = HOTEL SECTION LANDING PAGE */
					BEGIN
						--PRINT 'Delete Hotel Only TMUs with same airport'
						DELETE FROM @TripdetailsBackFill
						WHERE tripComponentType = 4	
						AND tripfrom = @cityCode 	
					END
				END
		
				
				INSERT INTO @Tripdetails
				SELECT * FROM @TripdetailsBackFill
				
		END	 
	
	END
	---- ################# BACK FILL DATA ENDS ################# ------ 
	
-- ################ COMMON UPDATE STATEMENTS AFTER ALL RESULT SET PREPARATION (GLOBAL, FILTERED, MY TRIPS, BACKFILL) ################ --

-- REASON :- TO UPDATE ISWATCHING = TRUE OF TMU'S FOR LOGGED IN USER'S ...  
	IF (@friendOption = '')
	BEGIN
		IF (@loggedInUserKey > 0)
		BEGIN
				 
			 UPDATE TD 
			 SET IsWatcher = 1 
			 FROM @Tripdetails TD 
			 INNER JOIN Trip T WITH (NOLOCK) on TD.tripsavedKey =T.tripSavedKey
			 AND T.userKey = @loggedInUserKey 
			 AND T.IsWatching = 1
		
		END	 
	END	
	
---- 15 = TRIP SUMMARY PAGE ....		
	IF (@page = 15)
	BEGIN
		
		--- BELOW DELETE STATEMENT IS WRITTEN SO THAT NO TMU's HAVING SHARE OR CROWD BUTTON SHOULD COME ON TRIP SUMMARY PAGE...
		--- ONLY TMU's HAVING FOLLOW BUTTON SHOULD COME ON TRIP SUMMARY PAGE .... (AS DISCUSSED WITH ASHA AND CLIENT)  	
		
		DELETE FROM @Tripdetails 
		WHERE 
		(
		IsWatcher = 1
		OR IsMyTrip = 1
		)
	
	END
	
	
/* #################################################################################### 
		STEP 2 STARTS :- CALCULATION AND RANKING OF PREPARED RESULT SET  
#################################################################################### */
	
-- ################## COMMON CODE FOR CALCULATION STARTS ################## 
	
-- CALCULATING LIKE COUNT ....
 	
	INSERT INTO @MostLikeCount 
	SELECT 
		TL.tripKey, 
		SUM(tripLike) as LikeCount 
	FROM 
		TripLike TL WITH (NOLOCK)
	INNER JOIN 
		@Tripdetails TD ON TL.tripKey = TD.tripKey 		 
	GROUP BY 
		TL.tripKey		

-- UPDATING LIKE COUNT IN TEMP TABLE ....

	UPDATE TD
	SET 
		TD.LikeCount = MLC.LikeCount
	FROM 
		@Tripdetails TD 
	INNER JOIN 
		@MostLikeCount MLC ON TD.tripKey = MLC.tripKey

-- INSERTING WATCHER'S COUNT ....

	--INSERT INTO @WatchersCount
	--(
	--	tripSavedKey,
	--	WatchersCount
	--)
	--SELECT 
	--	TD.tripsavedKey,			
	--	COUNT(TD.tripKey) as  watchersCount		
	--FROM @Tripdetails TD
	--INNER JOIN Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey
	--where 
	--	T.siteKey =@siteKey 
	--and 
	--	T.tripStatusKey <> 17
	--AND 
	--	T.IsWatching = 1        		
	--Group by 
	--	TD.tripSavedKey		
	
	DECLARE @SelectedCrowd AS TABLE 
	(
	CrowdId BIGINT
	)
		
	INSERT @SelectedCrowd 
	SELECT DISTINCT CrowdId FROM @Tripdetails
		
		INSERT INTO @WatchersCount
	(
		CrowdId,
		WatchersCount
	)
	SELECT 
		TD.CrowdId,			
		COUNT(TD.CrowdId) as  watchersCount		
	FROM @SelectedCrowd SC 
	INNER JOIN  
	TripSaved TD WITH(NOLOCK) ON TD.CrowdId = SC.CrowdId
	INNER JOIN Trip T WITH (NOLOCK) ON TD.tripSavedKey = T.tripSavedKey 	
	where 
		T.siteKey =@siteKey 
	and 
		T.tripStatusKey <> 17
	AND 
		T.IsWatching = 1 	 
	Group by 
		TD.CrowdId
	
    
-- UPDATING WATCHER'S COUNT IN TEMP TABLE ....       
	
	--COMMENTED BELOW QUERY AS WATCHERS COUNT WILL BE BASED ON CROWD ID 
	
	--UPDATE TD
	--SET 
	--	TD.WatchersCount = WC.WatchersCount 
	--FROM @Tripdetails TD 
	--INNER JOIN @WatchersCount WC ON TD.tripsavedKey = WC.tripSavedKey 

	UPDATE TD
	SET 
		TD.WatchersCount = WC.WatchersCount 
	FROM @Tripdetails TD 
	INNER JOIN @WatchersCount WC ON TD.CrowdId = WC.CrowdId 


--- COMMENTED BELOW QUERY AS IT IS NOT NEEDED FOR CROWD ID BASE CALCULATION.

	--UPDATE TD
	--SET WatchersCount = WatchersCount + ISNULL(SplitFollowersCount,0)
	--FROM @Tripdetails TD
	--INNER JOIN TripSaved TS WITH (NOLOCK) ON TD.tripsavedKey = TS.tripSavedKey
	--WHERE TS.parentSaveTripKey IS NOT NULL


-- ************************* COMMON CODE FOR CALCULATION ENDS ************************* -- 

	IF (@page <> 2 AND @page <> 15) -- 2 = MY TRIPS || 15 = TRIP SUMMARY PAGE ...
	BEGIN 
	
		--PRINT 'NOT MY TRIPS AND TRIP SUMMARY PAGE'		
-- INSERTING BOOKER'S COUNT ......		
		INSERT INTO @BookersCount
		SELECT 
			TD.tripsavedKey,
			COUNT(T.tripPurchasedKey)
		FROM 
			@Tripdetails TD
		INNER JOIN 
			Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey
		GROUP BY 
			TD.tripSavedKey
				
		
-- UPDATING BOOKER'S COUNT ......		
		UPDATE TD
		SET 
			TD.BookersCount = BC.BookersCount
		FROM 
			@Tripdetails TD 
		INNER JOIN 
			@BookersCount BC ON TD.tripsavedKey = BC.tripSavedKey
		
		
-- CALCULATING AND INSERTING FASTEST TRENDING  ......				
				INSERT INTO @FastestTrending
				(
					tripSavedKey,
					FastestTrending
				)
				SELECT 
					TD.tripsavedKey,			
					CASE 
						WHEN CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) = 0 
						THEN CAST(COUNT(T.tripKey) AS FLOAT) /  1
						ELSE CAST(COUNT(T.tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) 
					END as FastestTrending			
 				FROM @Tripdetails TD
 				INNER JOIN Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey
				where 
					T.siteKey =@siteKey 
				and 
					T.tripStatusKey <> 17
				AND 
					T.IsWatching = 1        		
				Group by 
					TD.tripSavedKey


				
-- UPDATING FASTEST TRENDING  ......				

				UPDATE TD
				SET 
					TD.FastestTrending = FT.FastestTrending
				FROM @Tripdetails TD 
				INNER JOIN @FastestTrending FT ON TD.tripsavedKey = FT.tripSavedKey
				
							
	END 
	
	IF (@page = 1 OR @page= 9 OR  @page = 11 OR @page = 12)
	/*
		1	= HOME PAGE 
		9	= HOTEL SECTION LANDING PAGE 
		11	= FLIGHT SECTION LANDING PAGE
		12	= CAR SECTION LANDING PAGE   
	*/
	BEGIN
			
-- CALCULATING AND INSERTING (RECENY AND PROXIMITY)			
		INSERT INTO @CalculateTripScoring
		(
			tripSavedKey ,			
			Recency ,
			Proximity 
			 
		)
		SELECT 
			TD.tripsavedKey,			
			DATEDIFF(day,MAX(T.CreatedDate),GETDATE()) as Recency,
			ABS(DATEDIFF(day,MIN(TD.tripstartdate), GETDATE())) as Proximity
 		FROM @Tripdetails TD
 		INNER JOIN Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey
		where 
			T.siteKey =@siteKey 
		and 
			T.tripStatusKey <> 17
		AND 
			T.IsWatching = 1        		
		Group by 
			TD.tripSavedKey
			
-- UPDATING (RECENY AND PROXIMITY)			
		UPDATE TD
		SET TD.Recency = CTS.Recency,
			TD.Proximity = CTS.Proximity
		FROM @Tripdetails TD 
		INNER JOIN @CalculateTripScoring CTS ON TD.tripsavedKey = CTS.tripSavedKey
	
/*
	
		UPDATE @Tripdetails
		SET SavingsRanking = 
			CASE 
				WHEN ABS(( TotalSavings / originalTotalPrice) * 100) >= 25 THEN 10			
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 20 AND 24.99 THEN 8	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 17 AND 19.99 THEN 7	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 15 AND 16.99 THEN 6	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 12 AND 14.99 THEN 5	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 9 AND 11.99 THEN 4	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 6 AND 8.99 THEN 3	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 3 AND 5.99 THEN 2	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 1 AND 2.99 THEN 1	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100)  BETWEEN 0 AND 0.99 THEN -5	
				WHEN ABS((TotalSavings / originalTotalPrice) * 100) < 0 THEN -10	
			END

*/

		UPDATE @Tripdetails
		SET SavingsRanking = 
		CASE 
			WHEN originalTotalPrice = 0 THEN -5
			WHEN (( TotalSavings / originalTotalPrice) * 100) >= 25 THEN 10			
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 20 AND 24.99 THEN 8	
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 17 AND 19.99 THEN 7	
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 15 AND 16.99 THEN 6	
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 12 AND 14.99 THEN 5	
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 9 AND 11.99 THEN 4	
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 6 AND 8.99 THEN 3	
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 3 AND 5.99 THEN 2	
			WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 1 AND 2.99 THEN 1	
			WHEN ((TotalSavings / originalTotalPrice) * 100)  BETWEEN 0 AND 0.99 THEN -5	
			WHEN ((TotalSavings / originalTotalPrice) * 100) < 0 THEN -10				
		END			
		 
		UPDATE @Tripdetails
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
		
		 				 
		
		UPDATE @Tripdetails
		SET ProximityRanking = 
		CASE 
			WHEN Proximity BETWEEN 22 AND 42 THEN 5
			WHEN Proximity  BETWEEN 14 AND 21 THEN 4
			WHEN Proximity  BETWEEN 43 AND 90 THEN 3
			WHEN Proximity  BETWEEN 90 AND 180 THEN 2
			WHEN Proximity > 180   THEN 1
			WHEN Proximity < 14   THEN 0
		END

					
		
		
		/*
			BELOW COMPONENT RANKING IS CALCULATED WHEN COMPONENT TYPE MATCHES THE EXACT COMPONENT FROM TRIP DETAILS ...
			REASON :- CLIENT WANTS THAT EXACT TRIP COMPONENT DATA COMING FROM TMU FILTER SHOULD COME ON TOP ...
			EXAMPLE :- ON FLIGHT LANDING PAGE, TRIP COMPONENT TPYE = 1 (AIR). NOW AIR ONLY TRIP SHOULD COME ON TOP.
						AIR + HOTEL OR ANY OTHER MIX COMPONENT SHOULD COME AFTER AIR ONLY TMU'S . HENCE BELOW CODE IS WRITTEN 
						TO GIVE RANKING OF "20" FOR MATCHING COMPONENT (AIR ONLY) AND "10" (AIR + ANY COMPONENT) ....						
		*/
		UPDATE TD 
			SET ComponentRanking = 20
		FROM @Tripdetails AS TD
			WHERE tripComponentType = @tripComponentType	
			/* BELOW LINE COMMENTED BCOZ CLIENT WANTS HOTEL RATING IN FILTER CRITERIA AND NOT IN SCORING ... 
		  AND 
		  (
				TD.Rating = 
					CASE WHEN @HotelRating1 = -1 THEN Rating
					ELSE @HotelRating1
					END
				OR
				Rating = 
					CASE WHEN @HotelRating2 = -1 THEN Rating
					ELSE @HotelRating2
					END
		  )	  
			*/			
		
		
		UPDATE TD
			SET ComponentRanking = 10
		FROM @Tripdetails AS TD
		WHERE 
			tripComponentType  & @tripComponentType = @tripComponentType
		AND tripComponentType <> @tripComponentType	-- THIS LINE IS WRITTEN SO THAT RANKING DOES NOT GET OVERWRITES FOR SAME COMPONENT TYPE...
													-- EG :- AIR ONLY TMU'S IS GIVEN RANKING AS "20". NOW THIS UPDATE STATEMENT SHOULD NOT REPLACE 
													--		 RANKING TO 10 FOR THOSE TMU'S WHO'S RANKING IS ALREADY GIVEN AS "20" IN ABOVE UPDATE STATEMENT. 
													--		 HENCE DO NOT INCLUDE THOSE TRIP COMPONENT RESULTS HAVING (AIR ONLY) TMU'S 
													--		 IN THIS UPDATE STATEMENT..			
			
		
		UPDATE TD
		SET DateRanking = 15
		FROM @Tripdetails AS TD
		WHERE MONTH (tripstartdate) = MONTH(@startDate)
		AND YEAR(tripstartdate) = YEAR(@startDate)
		
		UPDATE TD 
		SET ExactCityMatchRanking = 10 
		FROM @Tripdetails TD
		WHERE (CASE WHEN @cityType = 'From' THEN TD.tripFrom ELSE TD.tripTo END) = @cityCode
		
		
			
	END 
/*
	THIS IS SPECIFICALLY DONE FOR CALULATING SOCIAL RANKING FOR BELOW PAGES .... 
*/	
	IF (@page = 1 OR @page= 9 OR  @page = 11 OR @page = 12 OR @page = 15)			
	/*
		1	= HOME PAGE 
		9	= HOTEL SECTION LANDING PAGE 
		11	= FLIGHT SECTION LANDING PAGE
		12	= CAR SECTION LANDING PAGE   
		15	= TRIP SUMMARY PAGE		
	*/
	
	BEGIN
	
	
-- ######### FOR CALCUATING SOCIAL RANKING STARTS ####### --	
	
		SELECT 
			UserId 
		INTO 
			#tmpConnectionUserInfo 
		FROM 
			Loyalty..UserMap WITH (NOLOCK) 		
		WHERE 
			ParentId = @loggedInUserKey
		AND 
			@loggedInUserKey <> 0

	
				
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
	
-- ****************** FOR CALCUATING SOCIAL RANKING ENDS ****************** --	
	
	--PRINT 'CALCULATE SOCIAL RANKING '
	
		UPDATE TD
			SET SocialRanking = 
			CASE 
				WHEN TD.userKey = @loggedInUserKey THEN 10
				WHEN TD.userKey = CUI.UserId THEN 8 				
				ELSE 0
			END			
		FROM  @Tripdetails AS TD
		INNER JOIN #tmpConnectionUserInfo CUI ON TD.userKey = CUI.UserId 
		
		
		UPDATE TD
			SET SocialRanking = ISNULL(SocialRanking,0) +  3
		FROM @Tripdetails AS TD
		INNER JOIN TripSaved TS WITH(NOLOCK) ON TD.userKey = TS.userKey
		AND TD.tripsavedKey = TS.tripSavedKey
		WHERE TS.userKey <> 0		
	
		
		
		
		UPDATE @TripDetails 
		SET TripScoring =	ISNULL(SavingsRanking,0) + ISNULL(RecencyRanking,0) + ISNULL(ProximityRanking,0) + 
							ISNULL(SocialRanking,0) + ISNULL(ComponentRanking,0) + ISNULL(DateRanking, 0) + 
							ISNULL(ExactCityMatchRanking,0)
		
		
	
		
	
	END

/* ************************************************************************************ 
		STEP 2 ENDS :- CALCULATION AND RANKING OF PREPARED RESULT SET    
************************************************************************************ */
		
	
/* #################################################################################### 
		STEP 3 STARTS :- SORTING AND ORDERING OF FINAL RESULT SET   
#################################################################################### */
	
	IF (@page = 15) -- 15 = TRIP SUMMARY PAGE
	BEGIN
	
		INSERT INTO @TripdetailsTemp
		SELECT TOP 2 * FROM @Tripdetails
		ORDER BY TripScoring DESC, WatchersCount DESC        
	
			
	END
	ELSE	
	BEGIN
	
		INSERT INTO @TripdetailsTemp
		SELECT * FROM @Tripdetails
		WHERE IsBackFillData = 0		  
		ORDER BY 		
		CASE WHEN (@page = 2) THEN tripstartdate END DESC,
		CASE WHEN (@sortfield ='')THEN TripScoring END DESC,    			
		CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
		CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
		CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
		CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
		tripKey DESC	
		
		INSERT INTO @TripdetailsTemp
		SELECT * FROM @Tripdetails
		WHERE IsBackFillData = 1
		ORDER BY 		
		CASE WHEN (@page = 2) THEN tripstartdate END DESC,
		CASE WHEN (@sortfield ='')THEN TripScoring END DESC,    			
		CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
		CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
		CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
		CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
		tripKey DESC	
	
	END
	
	UPDATE @TripdetailsTemp
	SET @RowNumber = RowNumber = @RowNumber + 1					

	INSERT INTO @TripdetailsFinal
	SELECT * FROM @TripdetailsTemp
	WHERE RowNumber BETWEEN @FromIndex AND @ToIndex 	
	
	SELECT * FROM @TripdetailsFinal
	
/* ************************************************************************************ 
		STEP 3 ENDS :- SORTING AND ORDERING OF FINAL RESULT SET       
************************************************************************************ */

/*

-- ######################################################################################################## --
									/* TMU FOLLOWER DETAILS STARTS  */
-- ######################################################################################################## --


		
		INSERT INTO @TripFollowersDetails				
		(
			tripSavedKey ,		
			userKey ,
			userName ,
			userImageURL
		)
		SELECT 
			T.tripSavedKey, 			
			T.userKey,
			NULL,
			NULL				 
		FROM 
			Trip T WITH (NOLOCK)
		INNER JOIN 
			@TripdetailsFinal TD ON T.tripSavedKey = TD.tripSavedKey     
		GROUP BY 
			T.tripSavedKey, T.userKey 
				
		
		INSERT INTO @TripFollowersDetails
		(
			tripSavedKey ,		
			userKey ,
			userName ,
			userImageURL		
		)
		SELECT 
			TS.tripSavedKey,			
			TS.userKey,
			NULL,
			NULL				
		FROM 
			TripSaved TS WITH (NOLOCK)
		INNER JOIN 
			@TripdetailsFinal TD ON TS.tripSavedKey = TD.tripsavedKey
		WHERE 
			parentSaveTripKey IS NOT NULL

		
		UPDATE TFD
		SET 
			userName = U.userFirstName + ' ' + LEFT(U.userLastName, 1)
		FROM 
			@TripFollowersDetails TFD
		INNER JOIN 
			vault..[User] U WITH(NOLOCK) ON TFD.userKey = U.userKey
		
		
		UPDATE TFD
		SET 
			userImageURL = UM.ImageURL 
		FROM 
			@TripFollowersDetails TFD
		LEFT JOIN 
			Loyalty..UserMap UM WITH(NOLOCK) ON TFD.userKey = UM.UserId
							 		
		
		
		
		SELECT * FROM @TripFollowersDetails
		

-- ******************************************************************************************************** --
									/* TMU FOLLOWER DETAILS ENDS */
-- ******************************************************************************************************** --
*/
	

END
GO
