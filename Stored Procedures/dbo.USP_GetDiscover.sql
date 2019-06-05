SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Rajkumar
-- Create date: 11-Jun-2015
-- Description:	This will get trending crowds and biggest crowd savings to show on discover page
-- =============================================

-- [dbo].[USP_GetDiscover] 810, 1, 1
CREATE PROCEDURE [dbo].[USP_GetDiscover]
	@UserKey int ,
	--@tripKey int ,
	@SiteKey int,
	@IsSideMenu bit = 0
AS
BEGIN
	
	SET NOCOUNT ON;

	--******************** Create temp table to contain tripdetails of the user
    IF OBJECT_ID('tempdb..#Tripdetails') IS NOT NULL
		DROP TABLE #Tripdetails	
		
	CREATE TABLE #Tripdetails               
	(                    
		tripKey int NULL, 
		tripsavedKey uniqueidentifier NULL ,                    
		triprequestkey int NULL , 
		userKey INT,                   
		tripstartdate datetime NULL ,                    
		tripenddate datetime NULL ,                    
		tripfrom varchar(64) NULL ,                    
		tripTo varchar(64) NULL ,                    
		tripComponentType int NULL ,    
		tripComponents varchar(100) NULL ,                                      
		rankRating float NULL ,                    
		currentTotalPrice FLOAT NULL,  
		originalTotalPrice FLOAT NULL,  
		UserName VARCHAR(200),
		LikeCount INT ,
		WatchersCount INT,
		TripPurchaseKey uniqueidentifier NULL,
		FastestTrending FLOAT NULL,
		TotalSavings FLOAT,
		RowNumber INT,
		Rating FLOAT,
		TripScoring FLOAT DEFAULT(0),
		SavingsRanking FLOAT DEFAULT(0),
		Recency FLOAT DEFAULT(0),
		RecencyRanking FLOAT DEFAULT(0),
		Proximity INT DEFAULT(0),
		ProximityRanking FLOAT DEFAULT(0),
		FromCity	VARCHAR(100),
		ToCity	VARCHAR(100),
		tripPurchasedKey uniqueidentifier NULL,
		tripStatusKey INT DEFAULT(0),
		IsMyTrip BIT DEFAULT(0),
		CrowdId BIGINT,
		HashTag nvarchar(400),
		FromCityName varchar(64),
		ToCityName varchar(64),
		CreatedDate datetime,
		IsEvent BIT DEFAULT(0)
		
		
	)   

	INSERT INTO #Tripdetails
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
		WatchersCount, 
		TripPurchaseKey,
		FastestTrending,
		TotalSavings,
		RowNumber,
		tripPurchasedKey,
		tripStatusKey,
		IsMyTrip,
		CrowdId,
		FromCityName,
		ToCityName,
		CreatedDate
		
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
			WHEN TD.userKey = @UserKey  THEN  
				ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)
			ELSE
				ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)
			END	as CurrentTotalPrice,  
		CASE 
			WHEN TD.userKey = @UserKey  THEN  
				ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)
			ELSE
				ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)
			END	as OriginalTotalPrice,  				
		UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
		ISNULL(T1.CrowdCount,0) as WatchersCount,
		T1.tripPurchasedKey,
		0 as FastestTrending,
		CASE 
			WHEN TD.userKey = @UserKey  THEN  
				--ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)
				(isnull(originalTotalPriceAir,0) + isnull(originalPerPersonPriceCar,0) + isnull(originalPerPersonPriceHotel,0)) - 
				(isnull(td.latestDealAirPriceTotal,0) + isnull(td.latestDealCarPriceTotal,0) + isnull(td.latestDealHotelPriceTotal,0))
			ELSE			
				ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)				
			END	as TotalSavings,
		0,
		T1.tripPurchasedKey,
		T1.tripStatusKey,
		CASE WHEN TD.userKey = @UserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ... 
		TD.crowdId,
		TD.fromCityName,
		TD.toCityName,
		T1.CreatedDate
		 
	FROM 
		TripDetails TD WITH (NOLOCK)         
		INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey 
		INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                             		  		    		
		LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId	  
		
		where  T1.tripStatusKey <> 17  		  		  
		--AND t1.tripKey <> @tripKey 
		AND T1.IsWatching = 1
		AND TD.userKey = Case When @IsSideMenu = 1 Then @UserKey Else TD.userKey End
		AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....	
		
	--select *, tripTo, ToCityName from #TripDetails where isnull(ToCityName,'') = ''  --where HashTag in ('#SanFrancisco', '#Miami')	
		
		--****************** FASTEST TRENDING ******************

		IF OBJECT_ID('tempdb..#FastestTrending') IS NOT NULL
		DROP TABLE #FastestTrending
	
		CREATE TABLE #FastestTrending 
		(
			tripSavedKey UNIQUEIDENTIFIER,
			FastestTrending FLOAT
		)	
		
		INSERT INTO #FastestTrending
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
		FROM #Tripdetails TD
		INNER JOIN Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey
		WHERE T.siteKey =@siteKey 
		AND T.tripStatusKey <> 17
		AND T.IsWatching = 1        		
		GROUP BY TD.tripSavedKey
			
		--******** Update Fastest Trending in TripDetails			
		UPDATE TD
		SET TD.FastestTrending = FT.FastestTrending
		FROM #Tripdetails TD 
		INNER JOIN #FastestTrending FT ON TD.tripsavedKey = FT.tripSavedKey			
				
				


--********************** Recency
	IF OBJECT_ID('tempdb..#CalculateTripScoring') IS NOT NULL
		DROP TABLE #CalculateTripScoring

	CREATE TABLE #CalculateTripScoring 
	(
		tripSavedKey UNIQUEIDENTIFIER,		
		Recency FLOAT,
		Proximity FLOAT
	)
	INSERT INTO #CalculateTripScoring
	(
		tripSavedKey ,			
		Recency ,
		Proximity 
		 
	)
	SELECT 
		TD.tripsavedKey,			
		DATEDIFF(day,MAX(T.CreatedDate),GETDATE()) as Recency,
		ABS(DATEDIFF(day,MIN(TD.tripstartdate), GETDATE())) as Proximity
	FROM #Tripdetails TD
	INNER JOIN Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey
	where T.siteKey =@siteKey 
	AND T.tripStatusKey <> 17
	AND T.IsWatching = 1        		
	GROUP BY TD.tripSavedKey
			
	--*********** UPDATING (RECENY AND PROXIMITY)			
	UPDATE TD
	SET TD.Recency = CTS.Recency,
		TD.Proximity = CTS.Proximity
	FROM #Tripdetails TD 
	INNER JOIN #CalculateTripScoring CTS ON TD.tripsavedKey = CTS.tripSavedKey		
		
	UPDATE #Tripdetails
	SET RecencyRanking =
	CASE
		WHEN Recency = 0 THEN 5
		WHEN Recency between  1 and 6 THEN 4.5
		WHEN Recency = 7 THEN 4
		WHEN Recency BETWEEN 8 AND 14 THEN 3
		WHEN Recency BETWEEN 13 AND 21 THEN 2
		WHEN Recency BETWEEN 20 AND 45 THEN 1.5    
		ELSE 0
	END
	
	UPDATE #Tripdetails
		SET ProximityRanking = 
		CASE 
			WHEN Proximity BETWEEN 22 AND 42 THEN 5
			WHEN Proximity  BETWEEN 14 AND 21 THEN 4
			WHEN Proximity  BETWEEN 43 AND 90 THEN 3
			WHEN Proximity  BETWEEN 90 AND 180 THEN 2
			WHEN Proximity > 180   THEN 1
			WHEN Proximity < 14   THEN 0
		END 	
	
	
	--*************** Like Count ******************************	
	IF OBJECT_ID('tempdb..#MostLikeCount') IS NOT NULL
		DROP TABLE #MostLikeCount	
	
	CREATE TABLE #MostLikeCount 
	(
		tripKey INT,
		LikeCount INT
	)
	
	INSERT INTO #MostLikeCount 
	SELECT 
		TL.tripKey, 
		SUM(tripLike) as LikeCount 
	FROM 
		TripLike TL WITH (NOLOCK)
	INNER JOIN 
		#Tripdetails TD ON TL.tripKey = TD.tripKey 		 
	GROUP BY 
		TL.tripKey		

	-- UPDATING LIKE COUNT IN TEMP TABLE ....

	UPDATE TD
	SET 
		TD.LikeCount = MLC.LikeCount
	FROM 
		#Tripdetails TD 
	INNER JOIN 
		#MostLikeCount MLC ON TD.tripKey = MLC.tripKey	
		
	--****************
	UPDATE #TripDetails 
		SET TripScoring =	ISNULL(RecencyRanking,0) + ISNULL(ProximityRanking,0) + ISNULL(WatchersCount,0)+ Isnull(LikeCount,0)

	
	--*********** Is Event Available
	UPdate #Tripdetails Set IsEvent = 1
	From #Tripdetails TD
    INNER JOIN AttendeeTravelDetails ATD ON TD.tripKey = ATD.attendeeTripKey
    INNER JOIN  EventAttendees ON  EventAttendees.eventAttendeeKey = ATD.eventAttendeekey
    Where EventAttendees.userKey = @UserKey 
    
          
				
	IF @IsSideMenu = 0
	BEGIN							
		--************ Get Most Trending Crowds HashTag	
		SELECT 	
		td.tripto,	
		
		HT.HashTag as hashTag,
		isnull((Select Top 1 Sum(c.CrowdCount)
			from #Tripdetails a 
			inner join tripSaved b on a.tripSavedKey = b.tripSavedKey
			inner join Trip c on a.tripKey = c.tripKey
			inner join TripHashTagMapping d on a.tripKey = d.TripKey  
			where d.HashTag = ht.HashTag
			and b.parentSaveTripKey is  null
			Group by  datediff(d,(c.CreatedDate),GETDATE()),MONTH(c.CreatedDate),YEAR(c.CreatedDate)
			Order by datediff(d,(c.CreatedDate),GETDATE()),MONTH(c.CreatedDate),YEAR(c.CreatedDate)
		 ),0) as NewCrowds,
		 ISNULL(Sum(TD.WatchersCount),0) as Followers,
		 ISNULL((Select Top 1 Sum(c.CrowdCount)
			from TripDetails a 
			inner join tripSaved b on a.tripSavedKey = b.tripSavedKey
			inner join Trip c on a.tripKey = c.tripKey
			inner join TripHashTagMapping d on a.tripKey = d.TripKey  
			where d.HashTag = ht.HashTag
			and c.createdDate = getdate()
			and b.parentSaveTripKey is not null
		 ),0) as crowddeal
		,Sum(TripScoring) as TripScore
		,IsEvent
		into #tempdata
		FROM #Tripdetails TD	
		INNER JOIN TripHashTagMapping HT on TD.tripKey = HT.TripKey
		Where td.tripTo is not null and HT.HashTag is not null 
		And HT.HashTag not like '#___[0-9]%' --do not include hashtag like '#May2015',We are required to show only Friendly city name hashtag in trending crowds 
		Group by TD.tripTo, HT.HashTag,IsEvent
		Order by Sum(TripScoring) Desc --Recency,Proximity,Followers and Likecount

		select TripTo, HashTag, dbo.getImageURLFromCityCode(tripto) as ImageURL
		,(Select COUNT(1) From #Tripdetails Where DATEDIFF(DD,CreatedDate,getdate()) <=1) as newtrips
		from #tempdata 
		group by tripto, hashTag
		Order by Sum(TripScore) Desc
		
		--drop table #tempdata
			
		--************ Get Trending People ***************************
		SELECT UserKey,UserName, dbo.getImageURLFromUserKey(userKey) as ImageURL
		FROM #Tripdetails TD	
		GROUP BY userKey,UserName
		ORDER BY SUM(TripScoring) DESC
		
		
		--************ Get Crowds Events ***************************
		select TripTo, HashTag, dbo.getImageURLFromCityCode(tripto) as ImageURL
		,(Select COUNT(1) From #Tripdetails Where DATEDIFF(DD,CreatedDate,getdate()) <=1) as newtrips
		from #tempdata 
		WHERE IsEvent = 1
		group by tripto, hashTag
		Order by Sum(TripScore) Desc
		
		drop table #tempdata
	
	END --IsSideMenu = 0
	
	ELSE
	BEGIN
	--************ Get Biggest Crowds Savings HashTag	
		-- SELECT * FROM  #Tripdetails TD;
		SELECT  TD.TotalSavings,TD.tripKey,TD.tripComponents,
		STUFF((Select  ',' + HashTag  From TripHashTagMapping  a 
				Where a.TripKey = TD.tripKey 
				And a.HashTag IS NOT NULL 
				FOR XML PATH ('')),1,1,'') as HashTag -- This subquery concantenates the hashtag of same trip with comma separated value
				,TD.tripTo as ToCityCode
				,TD.ToCityName as  City
				-- ,ISNULL(Sum(TD.WatchersCount),0) as Followers
				 ,TD.WatchersCount as Followers
				,tripstartdate
		FROM #Tripdetails TD	
		-- LEFT JOIN TripHashTagMapping HT on TD.tripKey = HT.TripKey
		WHERE TD.TotalSavings > 1 AND TD.tripStatusKey <> 5
		-- And HT.HashTag is not null
		-- GROUP BY TD.tripKey,TD.TotalSavings,TD.tripComponents,TD.tripto,TD.ToCityName,TD.tripstartdate
		ORDER BY tripstartdate asc --Highest TotalSaving indicates biggest crowd savings
	END
		

	
END
GO
