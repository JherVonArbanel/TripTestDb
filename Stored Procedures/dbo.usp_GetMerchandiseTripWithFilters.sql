SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


    
                    
--usp_GetMerchandiseTripWithFilters 'DFW','From' ,5,6,0,1  
--exec usp_GetMerchandiseTripWithFilters NULL,'To' ,5,1000,7,1,0,NULL,2,'','',560551
--560551
 CREATE Procedure [dbo].[usp_GetMerchandiseTripWithFilters]                     
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
@loggedInUserKey BIGINT = 0     
)                    
AS                     
BEGIN                     

DECLARE @endDate DATETIME 
declare @otherTrips as bit = 0               

 IF @cityCode = ''                    
 BEGIN                    
  SET @cityCode = NULL                    
 END                     
      
      IF @startDate IS NULL 
      BEGIN 
		  SET @startDate = CONVERT(DATETIME, '1753-01-01 00:00:00', 20)
		  SET @endDate = '9999-12-31' -- THIS IS MAX DATE 
      END
      ELSE 
      BEGIN 
			SELECT @endDate = DATEADD(month, ((YEAR(@startDate) - 1900) * 12) + MONTH(@startDate), -1)								  		  
			SET @endDate = DATEADD(day,1,@endDate)
			PRINT @endDate
      END               
            
	  IF @startDate < GETDATE()
	  BEGIN 
		SET @startDate = CONVERT(DATETIME, GETDATE(), 20)
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
  rankRating int NULL ,                    
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
  FastestTrending FLOAT NULL 
 )                    
                     
 DECLARE @OfferDetails AS TABLE                     
 (                    
  OfferdetailsKey int  ,                    
  tripKey int NULL,                    
  tripsavedKey uniqueidentifier NULL ,                    
  triprequestkey int NULL ,                    
  tripstartdate datetime NULL ,                    
  tripenddate datetime NULL ,                    
  tripfrom varchar(20) NULL ,                    
  tripTo varchar(20) NULL ,                    
  tripComponentType int NULL ,        
  tripComponents varchar(100) NULL ,                     
  rankRating int NULL ,                    
  tripAirsavings float NULL ,                      
  tripcarsavings float NULL ,                    
  triphotelsavings float NULL,                    
  isOffer bit  NULL ,                    
  OfferImageURL varchar(500) NULL,    
  LinktoPage varchar(500) NULL,  
  currentTotalPrice FLOAT NULL,  
  UserName VARCHAR(200),
  FacebookUserUrl VARCHAR(500),
  WatchersCount INT,
  LikeCount INT,
  ThemeType INT DEFAULT(0),
  IsWatcher BIT DEFAULT(0),
  BookersCount INT DEFAULT(0),
  TripPurchaseKey uniqueidentifier NULL,
  FastestTrending FLOAT NULL 
 )                    
                  
 DECLARE @DestinationImages AS TABLE                  
 (                  
  DestinationImageId int identity(1,1),                  
  ImageURL varchar(500)                  
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
	INSERT INTO @ConnectionsUserInfo (UserId)
	SELECT UserId FROM Loyalty..UserMap
	WHERE ParentId = @loggedInUserKey
	AND @loggedInUserKey <> 0

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
	
	INSERT INTO @ConnectionsUserInfo (UserId)
	SELECT UserId FROM Loyalty..UserMap
	WHERE ParentId = @loggedInUserKey	
	AND @loggedInUserKey <> 0
END


INSERT INTO @ConnectionsUserSaveTripInfo
(
	tripSavedKey,
	tripKey,
	userKey
)
SELECT DISTINCT tripSavedKey, tripKey, userKey FROM Trip
INNER JOIN @ConnectionsUserInfo CUI ON Trip.userKey = CUI.UserId   
   
  
INSERT INTO @Tbl_RecommendedTripsSavings   
SELECT   
VWREC.tripKey  
,VWREC.tripSavedKey  
,VWREC.TripComponentType  
,VWREC.currentPrice  
,VWREC.originalPrice  
,VWREC.originalTotalPrice  
,VWREC.currentTotalPrice  
,VWREC.OriginAirportCode  
,VWREC.DestinationAirportCode  
,VWREC.AdultCount  
,VWREC.ChildCount  
,VWREC.savings FROM vw_RecommendedTripsSavings VWREC  
INNER JOIN Trip T ON VWREC.tripKey = T.tripKey  
WHERE VWREC.savings <= -10 AND T.tripComponentType = VWREC.TripComponentType AND T.tripStatusKey <> 17   
  
   
--INSERT INTO @Tbl_RecommendedTripsSavings   
--EXEC USP_GetRecommendedDeals  
  
--INSERT INTO @Tbl_RecommendedTripsSavingsFinal  
--SELECT RTS.tripKey  
--,RTS.tripSavedKey  
--,RTS.TripComponentType  
--,RTS.currentPrice  
--,RTS.originalPrice  
--,RTS.originalTotalPrice  
--,RTS.currentTotalPrice  
--,RTS.OriginAirportCode  
--,RTS.DestinationAirportCode  
--,RTS.AdultCount  
--,RTS.ChildCount  
--,RTS.savings FROM @Tbl_RecommendedTripsSavings RTS INNER JOIN Trip T ON RTS.tripKey = T.tripKey  
--WHERE RTS.TripComponentType = T.tripComponentType  
  
--SELECT * FROM @Tbl_RecommendedTripsSavingsFinal  
--SELECT * FROM @Tbl_RecommendedTripsSavings  

	IF(@friendOption = '')
	BEGIN  
			PRINT 'Inside 1'
		 INSERT INTO @Tripdetails ( tripKey,tripsavedKey,triprequestkey,tripstartdate   ,tripenddate   ,tripfrom  ,tripTo , tripComponentType ,tripComponents, rankRating, currentTotalPrice, UserName, FacebookUserUrl, WatchersCount, LikeCount, ThemeType, TripPurchaseKey,BookersCount, FastestTrending)                    
		  SELECT  t1.tripKey  , t1.tripsavedKey,t1.triprequestkey,TR.tripFromDate1, TR.tripToDate1,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType     
			, CASE           
			  WHEN t1.tripComponentType = 1 THEN 'Air'          
			  WHEN t1.tripComponentType = 2 THEN 'Car'          
			  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
			  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
			  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
			  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
			  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
			 END AS tripComponents,                     
		  [Rank],  
		  recommended.currentTotalPrice as CurrentTotalPrice,  
		  UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
		  ISNULL(UM.ImageURL,'') as FacebookUserUrl,
		  watchersCount as WatchersCount,
		  ISNULL(TLK.LikeCount,0) as LikeCount,
		  ISNULL(D.PrimaryTripType,0)	as  ThemeType,
		  T1.tripPurchasedKey,
		  ISNULL(TL.BookersCount,0) as BookersCount,
		  FastestTrending  
		  FROM Trip T1          
		  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
		  INNER JOIN Vault..[User] UI ON T1.userKey = UI.userKey                             
		  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId
		  INNER JOIN                     
			  (SELECT MIN(tripKey) tripkey  , TS.tripSavedKey ,COUNT(tripKEY) as  watchersCount,
			  (CASE WHEN COUNT(tripKey) = 1 THEN 2                     
			  WHEN  COUNT(tripKey) between 2 and 4    THEN  5                     
			  WHEN COUNT(tripKey) > 4 THEN 7 END ) as [Rank],
			  CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) as FastestTrending   
			  FROM trip T inner join TripSaved TS on T.tripSavedKey = TS.tripSavedKey 
			  where siteKey =@siteKey and T.tripStatusKey <> 17
			  AND T.IsWatching = 1        
			  Group by TS.tripSavedKey                      
			  )  AS DERIED on t1.tripKey =DERIED.tripkey                     
		  Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey             
		  LEFT JOIN CMS..CustomHotelGroup CHG ON TR.tripToHotelGroupId = CHG.HotelGroupId
		  LEFT JOIN CMS..Destination D ON CHG.DestinationId = D.DestinationId
		  LEFT JOIN (SELECT tripSavedKey, COUNT(tripPurchasedKey) as BookersCount FROM Trip GROUP BY tripSavedKey) as TL
		  ON T1.tripSavedKey = TL.tripSavedKey
		  LEFT JOIN (SELECT tripSavedKey, SUM(tripLike) as LikeCount FROM TripLike GROUP BY tripSavedKey) as TLK
		  ON T1.tripsavedKey = TLK.tripSavedKey 
		  
		  where  T1.tripStatusKey <> 17
		  AND T1.startDate BETWEEN @startDate AND @endDate  
		  /*
		  and  t1.startdate >   
		  (CASE WHEN @startDate < DATEADD(DAY,1 ,getdate()) THEN  DATEADD(DAY,1 ,getdate()) ELSE @startDate END ) 
		  AND T1.endDate <= @endDate */
		  and  (case when  @cityType = 'From' then   TR.tripFrom1                       
		  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = isnull(@cityCode ,(case when  @cityType = 'From' then   TR.tripFrom1                     when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end))                   
		  AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
		  AND t1.tripKey <> @tripKey 
		  AND ISNULL(D.PrimaryTripType,0) = (CASE WHEN @theme = 0 THEN ISNULL(D.PrimaryTripType,0) ELSE @theme END)
			ORDER BY 		
			CASE WHEN (@sortfield ='Rank' or @sortfield ='')THEN [RANK] END DESC,    
			--CASE WHEN (@sortfield ='Savings') THEN savings END ASC , 
			CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
			CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
			CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
			CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
			tripkey DESC             
			
		IF (SELECT COUNT(*)  from @Tripdetails) < 6 AND @cityCode IS NOT NULL  AND @cityType = 'From'               
		BEGIN
				PRINT 'Inside 1 City'
				 INSERT INTO @Tripdetails ( tripKey,tripsavedKey,triprequestkey,tripstartdate   ,tripenddate   ,tripfrom  ,tripTo , tripComponentType ,tripComponents, rankRating, currentTotalPrice, UserName, FacebookUserUrl, WatchersCount, LikeCount, ThemeType, TripPurchaseKey,BookersCount, FastestTrending)                    
				  SELECT  t1.tripKey  , t1.tripsavedKey,t1.triprequestkey,TR.tripFromDate1, TR.tripToDate1,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType     
					, CASE           
					  WHEN t1.tripComponentType = 1 THEN 'Air'          
					  WHEN t1.tripComponentType = 2 THEN 'Car'          
					  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
					  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
					  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
					  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
					  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
					 END AS tripComponents,                     
				  [Rank],  
				  recommended.currentTotalPrice as CurrentTotalPrice,  
				  UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
				  ISNULL(UM.ImageURL,'') as FacebookUserUrl,
				  watchersCount as WatchersCount,
				  ISNULL(TLK.LikeCount,0) as LikeCount,
				  ISNULL(D.PrimaryTripType,0)	as  ThemeType,
				  T1.tripPurchasedKey,
				  ISNULL(TL.BookersCount,0) as BookersCount,
				  FastestTrending  
				  FROM Trip T1          
				  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
				  INNER JOIN Vault..[User] UI ON T1.userKey = UI.userKey                             
				  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId
				  INNER JOIN                     
					  (SELECT MIN(tripKey) tripkey  , TS.tripSavedKey ,COUNT(tripKEY) as  watchersCount,
					  (CASE WHEN COUNT(tripKey) = 1 THEN 2                     
					  WHEN  COUNT(tripKey) between 2 and 4    THEN  5                     
					  WHEN COUNT(tripKey) > 4 THEN 7 END ) as [Rank],
					  CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) as FastestTrending   
					  FROM trip T inner join TripSaved TS on T.tripSavedKey = TS.tripSavedKey 
					  where siteKey =@siteKey and T.tripStatusKey <> 17
					  AND T.IsWatching = 1        
					  Group by TS.tripSavedKey                      
					  )  AS DERIED on t1.tripKey =DERIED.tripkey                     
				  Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey             
				  LEFT JOIN CMS..CustomHotelGroup CHG ON TR.tripToHotelGroupId = CHG.HotelGroupId
				  LEFT JOIN CMS..Destination D ON CHG.DestinationId = D.DestinationId
				  LEFT JOIN (SELECT tripSavedKey, COUNT(tripPurchasedKey) as BookersCount FROM Trip GROUP BY tripSavedKey) as TL
				  ON T1.tripSavedKey = TL.tripSavedKey
				  LEFT JOIN (SELECT tripSavedKey, SUM(tripLike) as LikeCount FROM TripLike GROUP BY tripSavedKey) as TLK
				  ON T1.tripsavedKey = TLK.tripSavedKey 
				  
				  where  T1.tripStatusKey <> 17
				  AND T1.startDate BETWEEN @startDate AND @endDate  
				  /*
				  and  (case when  @cityType = 'From' then   TR.tripFrom1                       
				  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = isnull(@cityCode ,(case when  @cityType = 'From' then   TR.tripFrom1                     
				  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end)) */                   
				  AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
				  AND t1.tripKey <> @tripKey 
				  AND ISNULL(D.PrimaryTripType,0) = (CASE WHEN @theme = 0 THEN ISNULL(D.PrimaryTripType,0) ELSE @theme END)
					ORDER BY 		
					CASE WHEN (@sortfield ='Rank' or @sortfield ='')THEN [RANK] END DESC,    
					--CASE WHEN (@sortfield ='Savings') THEN savings END ASC , 
					CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
					CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
					CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
					CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
					tripkey DESC             
		END
			
			
		IF @loggedInUserKey > 0 
		 BEGIN		 
			 UPDATE TD 
			 SET IsWatcher = 1 
			 FROM @Tripdetails TD 
			 INNER JOIN Trip T on TD.tripsavedKey =T.tripSavedKey 
			 AND T.userKey = @loggedInUserKey 
			 AND T.IsWatching = 1
			 
			 DECLARE @imageUrl AS  VARCHAR(100)
			 DECLARE @name AS  VARCHAR(100)
			 
			 SELECT @imageUrl = UM.ImageURL,@name = UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'  FROM  Vault..[User] UI                       
				LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId WHERE userKey = @loggedInUserKey 
				
			 UPDATE @Tripdetails SET FacebookUserUrl  = @imageUrl , UserName = @name WHERE IsWatcher =1    
		 END 
			        
	END	
	ELSE
	BEGIN 
		
		PRINT 'Inside 2'
		
		 INSERT INTO @Tripdetails ( tripKey,tripsavedKey,triprequestkey,tripstartdate   ,tripenddate   ,tripfrom  ,tripTo , tripComponentType ,tripComponents, rankRating, currentTotalPrice, UserName, FacebookUserUrl, WatchersCount, LikeCount, ThemeType, TripPurchaseKey,BookersCount, FastestTrending)                    
		  SELECT  t1.tripKey  , t1.tripsavedKey,t1.triprequestkey,TR.tripFromDate1, TR.tripToDate1,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType     
			, CASE           
			  WHEN t1.tripComponentType = 1 THEN 'Air'          
			  WHEN t1.tripComponentType = 2 THEN 'Car'          
			  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
			  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
			  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
			  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
			  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
			 END AS tripComponents,                     
		  [Rank],  
		  recommended.currentTotalPrice as CurrentTotalPrice,  
		  UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
		  ISNULL(UM.ImageURL,'') as FacebookUserUrl,
		  watchersCount as WatchersCount,
		  ISNULL(TLK.LikeCount,0) as LikeCount,
		  ISNULL(D.PrimaryTripType,0)	as  ThemeType,
		  T1.tripPurchasedKey,
		  ISNULL(TL.BookersCount,0) as BookersCount,
		  FastestTrending  
		  FROM Trip T1          
		  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
		  INNER JOIN Vault..[User] UI ON T1.userKey = UI.userKey                             
		  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId
		  INNER JOIN @ConnectionsUserSaveTripInfo CUS ON T1.tripKey = CUS.tripKey
		  INNER JOIN                     
			  (SELECT MIN(tripKey) tripkey  , T.tripSavedKey ,COUNT(tripKEY) as  watchersCount,
			  (CASE WHEN COUNT(tripKey) = 1 THEN 2                     
			  WHEN  COUNT(tripKey) between 2 and 4    THEN  5                     
			  WHEN COUNT(tripKey) > 4 THEN 7 END ) as [Rank],
			  CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) as FastestTrending   
			  FROM trip T 
			  where siteKey =@siteKey and T.tripStatusKey <> 17
			  AND T.IsWatching = 1        
			  Group by T.tripSavedKey                      
			  )  AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
		  Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey             
		  LEFT JOIN CMS..CustomHotelGroup CHG ON TR.tripToHotelGroupId = CHG.HotelGroupId
		  LEFT JOIN CMS..Destination D ON CHG.DestinationId = D.DestinationId
		  LEFT JOIN (SELECT tripSavedKey, COUNT(tripPurchasedKey) as BookersCount FROM Trip GROUP BY tripSavedKey) as TL
		  ON T1.tripSavedKey = TL.tripSavedKey
		  LEFT JOIN (SELECT tripSavedKey, SUM(tripLike) as LikeCount FROM TripLike GROUP BY tripSavedKey) as TLK
		  ON T1.tripsavedKey = TLK.tripSavedKey 
		  
		  where  T1.tripStatusKey <> 17  
		  AND T1.startDate BETWEEN @startDate AND @endDate
		  /*
		  and  t1.startdate >   
		  (CASE WHEN @startDate < DATEADD(DAY,1 ,getdate()) THEN  DATEADD(DAY,1 ,getdate()) ELSE @startDate END ) 
		  */
		  and  (case when  @cityType = 'From' then   TR.tripFrom1                       
		  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = isnull(@cityCode ,(case when  @cityType = 'From' then   TR.tripFrom1                     when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end))                   
		  AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
		  AND t1.tripKey <> @tripKey 
		  AND ISNULL(D.PrimaryTripType,0) = (CASE WHEN @theme = 0 THEN ISNULL(D.PrimaryTripType,0) ELSE @theme END)
			ORDER BY 		
			CASE WHEN (@sortfield ='Rank' or @sortfield ='')THEN [RANK] END DESC,    
			--CASE WHEN (@sortfield ='Savings') THEN savings END ASC , 
			CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
			CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
			CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
			CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
			tripkey DESC 	
 
		IF (SELECT COUNT(*)  from @Tripdetails) < 6 AND @cityCode IS NOT  NULL  AND @cityType = 'From'              
		BEGIN
				PRINT 'Inside 2 City'
				 INSERT INTO @Tripdetails ( tripKey,tripsavedKey,triprequestkey,tripstartdate   ,tripenddate   ,tripfrom  ,tripTo , tripComponentType ,tripComponents, rankRating, currentTotalPrice, UserName, FacebookUserUrl, WatchersCount, LikeCount, ThemeType, TripPurchaseKey,BookersCount, FastestTrending)                    
				  SELECT  t1.tripKey  , t1.tripsavedKey,t1.triprequestkey,TR.tripFromDate1, TR.tripToDate1,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType     
					, CASE           
					  WHEN t1.tripComponentType = 1 THEN 'Air'          
					  WHEN t1.tripComponentType = 2 THEN 'Car'          
					  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
					  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
					  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
					  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
					  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
					 END AS tripComponents,                     
				  [Rank],  
				  recommended.currentTotalPrice as CurrentTotalPrice,  
				  UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.' as UserName,
				  ISNULL(UM.ImageURL,'') as FacebookUserUrl,
				  watchersCount as WatchersCount,
				  ISNULL(TLK.LikeCount,0) as LikeCount,
				  ISNULL(D.PrimaryTripType,0)	as  ThemeType,
				  T1.tripPurchasedKey,
				  ISNULL(TL.BookersCount,0) as BookersCount,
				  FastestTrending  
				  FROM Trip T1          
				  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
				  INNER JOIN Vault..[User] UI ON T1.userKey = UI.userKey                             
				  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId
				  INNER JOIN @ConnectionsUserSaveTripInfo CUS ON T1.tripKey = CUS.tripKey
				  INNER JOIN                     
					  (SELECT MIN(tripKey) tripkey  , T.tripSavedKey ,COUNT(tripKEY) as  watchersCount,
					  (CASE WHEN COUNT(tripKey) = 1 THEN 2                     
					  WHEN  COUNT(tripKey) between 2 and 4    THEN  5                     
					  WHEN COUNT(tripKey) > 4 THEN 7 END ) as [Rank],
					  CAST(COUNT(tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) as FastestTrending   
					  FROM trip T 
					  where siteKey =@siteKey and T.tripStatusKey <> 17
					  AND T.IsWatching = 1        
					  Group by T.tripSavedKey                      
					  )  AS DERIED on t1.tripSavedKey =DERIED.tripSavedKey
				  Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey             
				  LEFT JOIN CMS..CustomHotelGroup CHG ON TR.tripToHotelGroupId = CHG.HotelGroupId
				  LEFT JOIN CMS..Destination D ON CHG.DestinationId = D.DestinationId
				  LEFT JOIN (SELECT tripSavedKey, COUNT(tripPurchasedKey) as BookersCount FROM Trip GROUP BY tripSavedKey) as TL
				  ON T1.tripSavedKey = TL.tripSavedKey
				  LEFT JOIN (SELECT tripSavedKey, SUM(tripLike) as LikeCount FROM TripLike GROUP BY tripSavedKey) as TLK
				  ON T1.tripsavedKey = TLK.tripSavedKey 
				  
				  where  T1.tripStatusKey <> 17  
				  AND T1.startDate BETWEEN @startDate AND @endDate
				  /*
				  and  (case when  @cityType = 'From' then   TR.tripFrom1                       
				  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = isnull(@cityCode ,(case when  @cityType = 'From' then   TR.tripFrom1                     
				  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end)) */                  
				  AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
				  AND t1.tripKey <> @tripKey 
				  AND ISNULL(D.PrimaryTripType,0) = (CASE WHEN @theme = 0 THEN ISNULL(D.PrimaryTripType,0) ELSE @theme END)
					ORDER BY 		
					CASE WHEN (@sortfield ='Rank' or @sortfield ='')THEN [RANK] END DESC,    
					--CASE WHEN (@sortfield ='Savings') THEN savings END ASC , 
					CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,    
					CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,    
					CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,			
					CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,
					tripkey DESC 	
			END 

			
			IF ( @loggedInUserKey > 0 )
			BEGIN
	         UPDATE TD 
			 SET IsWatcher = 1 
			 FROM @Tripdetails TD 			 
			 INNER JOIN @ConnectionsUserSaveTripInfo CUS ON TD.tripsavedKey = CUS.tripSavedKey WHERE CUS.userKey = @loggedInUserKey
		    END	 
	
	END
		       
  
                     
    
                   
  IF ( @otherTrips = 1)                     
  BEGIN                     
   declare @lastCount as int = 9                     
   IF ( SELECT COUNT(*) from @Tripdetails)  > 9                    
   BEGIN                     
    SET @lastCount = 9                     
   END                     
  END                    
  
 --delete from @Tripdetails where TripdetailsKey > @lastCount  
        
 UPDATE @Tripdetails SET rankRating = 1 where           ( case when  @cityType = 'From' then    tripFrom                        
   WHEN @cityType = 'To' then tripTo  else tripFrom     end )<>   @cityCode         
                     
 DECLARE @deal table                    
 (                    
  dealId int ,                     
  tripkey int ,                    
 componentType int                     
 )                    
 Insert @deal                     
 SELECT MAX(TripSavedDealKey),TSD.tripKey ,componentType  FROM TripSavedDeals TSD inner join @Tripdetails TD on tsd.tripKey =TD.tripKey                     
 --where Convert(Date,TSD.creationDate )=  Convert(Date,getdate())                     
 group by tsd.tripKey ,componentType                     
  
  
 update @Tripdetails SET tripAirsavings =  
   (ISNULL(DTAP.tripAdultBase,Dtap.tripSeniorBase) + ISNULL(DTAP.tripAdultTax,DTAP.tripSeniorTax))   
   - (ISNULL(OTAP.tripAdultBase,otap.tripSeniorBase) + ISNULL(OTAP.tripAdultTax,otap.tripSeniorTax))  
 FROM TripAirResponse OTR inner join TripAirPrices OTAP                      
 ON OTR.searchAirPriceBreakupKey = OTAP.tripAirPriceKey                    
 inner join @Tripdetails T ON t.tripsavedKey = OTR.tripguidkey                     
 inner join @deal  D on t.tripKey = d.tripkey                     
 inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId                     
 inner join TripAirResponse DTR                     
 ON DTR.airResponseKey = tsd.responseKey                     
 inner join TripAirPrices DTAP                      
 ON DTR.searchAirPriceBreakupKey = DTAP.tripAirPriceKey                    
                     
                     
 --   update  @Tripdetails SET triphotelsavings = (( DTR.hotelTotalPrice - THR.hotelTotalPrice ) / 2) FROM TripHotelResponse THR inner join @Tripdetails TD on thr.tripGUIDKey =td.tripsavedKey                     
 --inner join @deal  D on tD.tripKey = d.tripkey                     
 --inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId                     
 --inner join TripHotelResponse DTR                     
 --ON DTR.hotelResponseKey = tsd.responseKey       
                   
 update  @Tripdetails SET triphotelsavings = (( DTR.hotelTotalPrice - THR.hotelTotalPrice )  ) FROM TripHotelResponse THR inner join @Tripdetails TD on thr.tripGUIDKey =td.tripsavedKey                     
 inner join @deal  D on tD.tripKey = d.tripkey                     
 inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId                     
 inner join TripHotelResponse DTR                      
 ON DTR.hotelResponseKey = tsd.responseKey                     
                     
                     
 update  @Tripdetails SET tripcarsavings =   ( DTR.SearchCarPrice+ DTR.searchCarTax)   - ( THR.SearchCarPrice+ THR.searchCarTax)                     
 FROM TripCarResponse THR inner join @Tripdetails TD on thr.tripGUIDKey =td.tripsavedKey                     
 inner join @deal  D on td.tripKey = d.tripkey                     
 inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId           
 inner join TripCarResponse DTR                     
 ON DTR.carResponseKey = tsd.responseKey       
 
 
 IF @loggedInUserKey > 0 
 BEGIN
 
 UPDATE TD 
 SET IsWatcher = 1 
 FROM @Tripdetails TD 
 INNER JOIN Trip T on TD.tripsavedKey =T.tripSavedKey 
 AND T.userKey = @loggedInUserKey 
 AND T.IsWatching = 1
 END 



   
--DELETE FROM @Tripdetails WHERE tripComponentType = 1 AND tripAirsavings IS NULL  
--DELETE FROM @Tripdetails WHERE tripComponentType = 2 AND tripcarsavings IS NULL  
--DELETE FROM @Tripdetails WHERE tripComponentType = 4 AND triphotelsavings IS NULL  
--DELETE FROM @Tripdetails WHERE tripComponentType = 3 AND (tripAirsavings IS NULL OR tripcarsavings IS NULL)  
--DELETE FROM @Tripdetails WHERE tripComponentType = 5 AND (tripAirsavings IS NULL OR triphotelsavings IS NULL)  
--DELETE FROM @Tripdetails WHERE tripComponentType = 6 AND (tripcarsavings IS NULL OR triphotelsavings IS NULL)  
--DELETE FROM @Tripdetails WHERE tripComponentType = 7 AND (tripAirsavings IS NULL OR triphotelsavings IS NULL OR tripcarsavings IS NULL)  

 DELETE FROM @Tripdetails WHERE (tripComponentType  & 1 ) > 0 AND tripAirsavings IS NULL  
 DELETE FROM @Tripdetails WHERE (tripComponentType  & 2 ) > 0 AND tripcarsavings IS NULL  
 DELETE FROM @Tripdetails WHERE (tripComponentType  & 4 ) > 0 AND triphotelsavings IS NULL  
 
 
   
delete from @Tripdetails where TripdetailsKey > @lastCount  
      
DECLARE @IsAllowAds300by250 BIT      
      
SET @IsAllowAds300by250 = 1      
      
IF @page = 1 -- HOME PAGE       
BEGIN       
 -- GET ALLOW DISPLAY OF ADS 300by250 FROM HOME PAGE      
 SELECT @IsAllowAds300by250 = AllowDisplayOf300By250Ads FROM CMS..CMS_HomePage      
       
END            
ELSE IF @page = 10 -- CRUISE SECTION LANDING PAGE     
BEGIN     
 SELECT @IsAllowAds300by250 = AllowMerch FROM CMS..SectionLanding WHERE SectionLandingId = 2 -- 2=CRUISE            
END    
ELSE IF @page = 11 -- FLIGHTS SECTION LANDING PAGE     
BEGIN     
 SELECT @IsAllowAds300by250 = AllowMerch FROM CMS..SectionLanding WHERE SectionLandingId = 3 -- 3=FLIGHTS            
END    
ELSE IF @page = 12 -- CARS SECTION LANDING PAGE     
BEGIN     
 SELECT @IsAllowAds300by250 = AllowMerch FROM CMS..SectionLanding WHERE SectionLandingId = 4 -- 4=CARS            
END      
          
IF @IsAllowAds300by250 = 1 -- IF IN ABOVE PAGES IT IS ALLOWED THEN DISPLAY IT      
BEGIN      
                  
  IF @page = 0      
  BEGIN       
      
   INSERT INTO @Offerdetails                    
   SELECT TOP 3                    
     M.MerchandiseId as OfferdetailsKey ,                    
     NULL as tripKey ,                    
     NULL as tripsavedKey ,                    
     NULL as triprequestkey ,                    
     NULL as tripstartdate ,                    
     NULL as tripenddate ,                    
     NULL as tripfrom ,                    
     NULL as tripTo ,                    
     NULL as tripComponentType ,    
     NULL as tripComponents,                     
     PriorityRank as rankRating,                    
     NULL as tripAirsavings ,                      
     NULL as tripcarsavings ,                    
     NULL as triphotelsavings,                    
     1 as isOffer,                    
     OfferImage as OfferImageURL,    
     ISNULL(LinktoPage, '') as LinktoPage,  
     NULL as CurrentTotalPrice,  
     '' as UserName,
     '' as FacebookUserUrl,
     0 as WatchersCount,
     0 as LikeCount,
     0 as ThemeType,
     0 as IsWatcher,
     0 as BookersCount,       
     NULL as TripPurchaseKey,
     0 as FastestTrending
   FROM  CMS..Merchandise M                       
   WHERE MerchandiseType = 'MerchandisingOffer300by250FormatDisplay'                    
   and IsEnabled = 1                      
   --and CitySpecificMatch = (select TOP 1 CityId from CMS..CMS_CityDetails where CityCode = ISNULL(@cityCode,CityCode))                      
   and  (AptCodeSpecificMatch = ISNULL(@cityCode,AptCodeSpecificMatch) OR  AptCodeSpecificMatch = '')    
   and GETDATE() between ISNULL(OfferDisplayStartDate,GETDATE()) and ISNULL(OfferDisplayEndDate,GETDATE())                      
         
   ORDER BY rankRating DESC                    
        
        
  END       
  ELSE      
  BEGIN       
                      
   INSERT INTO @Offerdetails                    
   SELECT TOP 3                    
     M.MerchandiseId as OfferdetailsKey ,                    
     NULL as tripKey ,                    
     NULL as tripsavedKey ,                    
     NULL as triprequestkey ,                    
     NULL as tripstartdate ,                    
     NULL as tripenddate ,                    
     NULL as tripfrom ,                    
     NULL as tripTo ,                    
     NULL as tripComponentType ,      
     NULL as tripComponents,                   
     PriorityRank as rankRating,                    
     NULL as tripAirsavings ,                      
     NULL as tripcarsavings ,                    
     NULL as triphotelsavings,                    
     1 as isOffer,                    
     OfferImage as OfferImageURL,    
     ISNULL(LinktoPage, '') as LinktoPage,  
     NULL as CurrentTotalPrice,  
     '' as UserName,
     '' as FacebookUserUrl,
     0 as WatchersCount,
     0 as LikeCount,
     0 as ThemeType,
     0 as IsWatcher,
     0 as BookersCount,
     NULL as TripPurchaseKey,
     0 as FastestTrending     
   FROM  CMS..Merchandise M                       
   INNER JOIN CMS..SitePlacement S ON M.MerchandiseId = S.CMSTableKey         
   AND S.CMSTable = 'MerchandisingOffer300by250FormatDisplay'      
   WHERE MerchandiseType = 'MerchandisingOffer300by250FormatDisplay'                    
   and IsEnabled = 1                      
   --and CitySpecificMatch = (select TOP 1 CityId from CMS..CMS_CityDetails where CityCode = ISNULL(@cityCode,CityCode))                      
   and (AptCodeSpecificMatch = ISNULL(@cityCode,AptCodeSpecificMatch)  OR  AptCodeSpecificMatch = '')                    
   --and HomePage = 1                            
   and S.Page = @page      
   and S.Visible = 1      
   and GETDATE() between ISNULL(OfferDisplayStartDate,GETDATE()) and ISNULL(OfferDisplayEndDate,GETDATE())                      
   ORDER BY rankRating DESC                    
  END                      
      
END      
                     
 SELECT  t.* , FA.CityName as FromCity, TA.CityName as ToCity ,    
  CASE WHEN TA.CountryCode = 'US' THEN TA.StateCode  ELSE '' END AS ToState ,    
  CASE WHEN TA.CountryCode = 'US' THEN '' ELSE CL.CountryName END AS ToCountry    
      
 FROM @Tripdetails  T                    
 left outer join                     
 AirportLookup FA on                     
 T.tripfrom = FA.AirportCode                     
 left outer join                   
 AirportLookup TA on                     
 T.tripto = TA.AirportCode    
 LEFT outer JOIN                   
 vault..CountryLookUp CL ON     
 TA.CountryCode = CL.CountryCode    
 where TripdetailsKey between 1 and @resultCount
 --AND ThemeType = (CASE WHEN @theme = 0 THEN ThemeType ELSE @theme END)
                     
 UNION                     
                     
 SELECT F.*, NULL as FromCity, NULL as  ToCity , NULL as ToState , NULL as ToCountry FROM @Offerdetails F                    
                     
 --ORDER BY rankRating DESC   ,TripdetailsKey ASC         
 ORDER BY TripdetailsKey ASC
   
   
             
                     
 ---------------------------- DESTINATION IMAGES STARTS ----------------------------                  
/*                  
 SELECT DISTINCT TD.tripTo            
 INTO #tmpTripTo                  
 FROM @Tripdetails TD                  
*/            
            
            
INSERT INTO @TripHotelGroup            
SELECT  TR.tripToHotelGroupId, TR.tripTo1  , '' as URL            
FROM TripRequest TR            
INNER JOIN @Tripdetails TD ON TR.tripRequestKey = TD.triprequestkey            
             
            
            
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
 SELECT OrderId, AptCode, ImageURL FROM CMS..Destination                  
 INNER JOIN CMS..DestinationImages ON CMS..Destination.DestinationId = CMS..DestinationImages.DestinationId                  
 INNER JOIN #tmpTripTo ON CMS..Destination.AptCode = #tmpTripTo.tripTo                  
 ORDER BY AptCode, OrderId                  
 */            
                  
 ---------------------------- DESTINATION IMAGES ENDS ----------------------------                    
         
                     
  --DROP TABLE #tmpTripTo                  
            
   
                    
END
GO
