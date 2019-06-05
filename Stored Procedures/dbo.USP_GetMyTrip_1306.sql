SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*

exec USP_GetMyTrip  570498,70 ,1,1000,0,1,0,'','purchased'

exec USP_GetMyTrip  570499,70 ,1,1000,0,1,0,'','held, purchased, traveled'

exec USP_GetMyTrip  570499,70 ,1,1000,0,1,0,'SFO','held'

exec USP_GetMyTrip  570499,70 ,1,1000,0,1,0,'',''
*/
CREATE PROCEDURE [dbo].[USP_GetMyTrip_1306]                
 @UserKey int,                
 @SiteKey int,              
 @FromIndex INT = 1,                          
 @ToIndex INT = 10 ,              
 @CrowdCount INT = 0 OUTPUT,              
 @ShowExpired bit = 0,              
 @thirdPartyUser int = 0 ,              
 @toCities varchar(1000)= '',              
 @tripType varchar(1000)= ''              
AS                
BEGIN                
               
 SET NOCOUNT ON;                
 
 DECLARE @IsThirdParty bit;              
 DECLARE @HomeAirport varchar(50);              
 DECLARE @BadgeName varchar(50);              
 DECLARE @ImageUrl varchar(100);              
               
 SET @IsThirdParty = 1               
 IF(@UserKey = @thirdPartyUser )               
  BEGIN              
   SET @IsThirdParty = 0 ;              
   SET @thirdPartyUser = 0 ;              
  END              
  ELSE IF @thirdPartyUser = 0              
   BEGIN              
   SET @IsThirdParty = 0 ;              
 END              
            
               
 --PRINT ('0: '+CONVERT( VARCHAR(24), GETDATE(), 121))              
 --************** Temp table creation****************                
  Declare @me table                
  (RowNumber int,id int,startDate datetime,createddate datetime , enddate datetime null,tripfrom varchar(10) null,tripto varchar(10) null,fromcity varchar(200) null,tocity varchar(200) null,tripcomponents varchar(20) null,                
  followercount int null,imageurl varchar(500) null,replies int default(0),ishost bit default(0),type varchar(50),isexpired int default(0),Savings int default(0), CrowdId int default(0), tripStatusKey int default(0), tripFilterType varchar(200) DEFAULT   
  'saved' NOT NULL, totalBaseCost float default(0.0), totalTaxCost float default(0.0),TripRequestKey int ,TripRouteType varchar(50))                
                
  Declare @finalme table                
  (RowNumber int identity(1,1),id int,startDate datetime,createddate datetime ,enddate datetime null,tripfrom varchar(10) null,tripto varchar(10) null,fromcity varchar(200) null,tocity varchar(200) null,tripcomponents varchar(20) null,                
  followercount int null,locationImage varchar(500) null,replies int default(0),ishost bit default(0),type varchar(50),isexpired int default(0),Savings int default(0), CrowdId int default(0), tripFilterType varchar(200) null, totalBaseCost float default(0.0), totalTaxCost float default(0.0), IsMultipleAirline int default(0), AirlineCode varchar(200), NoOfStops int default(0), IsAvailableForBooking int default(0),TripRouteType varchar(50))                

  Declare @DestinationImage table(AptCode VARChar(10), DestinationId INT, ImageURL VARCHAR(MAX), OrderID INT)
		
		  
  Declare @crowdType table  (crowdtype varchar(200))               
                
  Declare @userWithSimilarTrips table  (userKey varchar(200), peopleWithSimilarTrip int default 0 )               
                
  Declare @tripDestinations table (destination varchar(200))              
    
  Declare @tripTypes table (triptypes varchar(200))     
                
  Declare @DestinationsForFilter table (destination varchar(200), code varchar(200),DestCount int)
  
  Declare @AirSegmentDetails table (airlineCode varchar(200), tripkey int,  NoOfStops int default(0), IsMultipleAirline int default(0))


INSERT INTO @tripDestinations (destination)              
SELECT * From dbo.ufn_DelimiterToTable(@toCities,',')              
            
  INSERT INTO @tripTypes (triptypes)              
SELECT * From dbo.ufn_DelimiterToTable(@tripType,',')  
            
 DECLARE @loggedinUserKey int              
               
 SET @loggedinUserKey = @UserKey                
      

             
IF @ShowExpired = 0               
BEGIN       
	INSERT INTO @crowdType(crowdtype) VALUES ('purchased'),('cancelled')           
END               
ELSE               
BEGIN              
	INSERT INTO @crowdType(crowdtype) VALUES ('purchased'),('cancelled'),('purchased expired'),('cancelled expired'),('held')
END               

                     
 Insert into @me                
 (id ,startDate ,enddate ,createddate, tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,type ,CrowdId, tripStatusKey, totalBaseCost, totalTaxCost,TripRequestKey,TripRouteType)                
    SELECT DISTINCT T.[tripKey],startDate, endDate, T.CreatedDate                    
   ,TR.tripFrom1, TR.tripTo1, DEP.CityName as FromCity,                     
   ARR.CityName as ToCity,                 
 CASE                           
    WHEN T.[tripComponentType] = 1 THEN 'Air'                          
    WHEN T.[tripComponentType] = 2 THEN 'Car'                          
    WHEN T.[tripComponentType] = 3 THEN 'Air,Car'                          
    WHEN T.[tripComponentType] = 4 THEN 'Hotel'                          
    WHEN T.[tripComponentType] = 5 THEN 'Air,Hotel'                          
    WHEN T.[tripComponentType] = 6 THEN 'Car,Hotel'                          
    WHEN T.[tripComponentType] = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents,                
     ISNULL(TS.SplitFollowersCount,0) as followercount,                
     T.DestinationSmallImageURL as [ImageUrl],                
    ''              
     ,TS.CrowdId , T.tripStatusKey, T.tripTotalBaseCost, T.tripTotalTaxCost ,T.tripRequestKey,'' as TripRouteType     
 FROM [Trip] T WITH(NOLOCK)                            
  INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey                            
  LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode                      
  LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode                
  LEFT JOIN vault..CountryLookup CL WITH(NOLOCK) ON ARR.CountryCode = CL.CountryCode                 
  LEFT JOIN TripSaved TS WITH (NOLOCK) ON T.tripSavedKey = TS.tripSavedKey                
  WHERE T.siteKey = @SiteKey AND T.userKey = @UserKey AND T.tripTotalBaseCost > 0 AND T.tripTotalTaxCost >0 
               

	--SELECT DATEADD(hour, -24, GETDATE()) ;
	IF(@tripType ='held')
	BEGIN
		DELETE FROM @me WHERE (createddate < DATEADD(hour, -24, GETDATE()))
	END

 UPDATE TD               
    SET TD.type =               
    (              
    CASE WHEN @thirdPartyUser = 0          
    THEN               
  (CASE               
  WHEN               
   (TD.tripStatusKey = 2 OR TD.tripStatusKey = 1 OR TD.tripStatusKey = 15 OR TD.tripStatusKey = 5)               
  THEN               
   CASE WHEN              
    TD.tripStatusKey = 5 THEN (CASE WHEN dateadd(HOUR, 18, enddate) < GETDATE() THEN 'cancelled expired' ELSE 'cancelled' END)                
   ELSE                
   (CASE WHEN dateadd(HOUR, 18, enddate) < GETDATE() THEN 'purchased expired' ELSE 'purchased' END)               
   END              
  ELSE              
    (CASE WHEN startDate < GETDATE() THEN 'following crowd expired' ELSE 'following crowd' END)               
  END)              
    ELSE               
  (CASE WHEN startDate < GETDATE() THEN 'following crowd expired' ELSE 'following crowd' END)               
    END              
    )              
    FROM @me TD              
         
   UPDATE TD SET               
 TD.tripFilterType = 'purchased'              
   FROM @me TD WHERE (TD.tripStatusKey = 2 OR TD.tripStatusKey = 1 OR TD.tripStatusKey = 15 OR TD.tripStatusKey = 5)              
   
   select *  from @me;

   UPDATE TD SET               
   TD.tripFilterType = 'held' ,  TD.type = 'held'               
   FROM @me TD WHERE (TD.tripStatusKey = 7)              
                 
   UPDATE TD               
    SET TD.isexpired = (CASE WHEN               
    (CASE WHEN (TD.tripStatusKey = 2 OR TD.tripStatusKey = 1 OR TD.tripStatusKey = 15 OR TD.tripStatusKey = 5) THEN dateadd(HOUR, 18, enddate)              
    ELSE startDate END) < GETDATE() THEN 1 ELSE 0 END)              
   FROM @me TD                
                       
           
  UPDATE TD SET               
  TD.tripFilterType = 'traveled'              
    FROM @me TD WHERE tripFilterType = 'purchased' and isexpired = 1              

  UPDATE TD SET   
  TripRouteType= CASE WHEN AR.AirRequestTypekey=1 THEN 'One Way'
								WHEN AR.AirRequestTypekey=2 THEN 'Round Trip'
								WHEN AR.AirRequestTypekey=3 THEN 'Multi City' 
							END
	FROM	@me TD
			INNER JOIN Trip..TripRequest_air TRA ON TRA.tripRequestKey=TD.TripRequestKey
			INNER JOIN Trip..AirRequest AR ON AR.airRequestkey=TRA.airRequestkey 

-----------------------------------------------------------------------------------              
 IF(@toCities = '')              
	BEGIN               
	   SELECT  @CrowdCount = COUNT(*) FROM @me               
	  END               
 ELSE              
	  BEGIN              
	   SELECT  @CrowdCount = COUNT(*) FROM @me M INNER JOIN @tripDestinations TD ON M.tripto = TD.destination              
	  END              
       
                  
   --PRINT ('6: '+CONVERT( VARCHAR(24), GETDATE(), 121))              
  IF(@toCities = '' AND  @tripType = '' )              
    BEGIN               
		Insert into @finalme ( id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,locationImage,replies,ishost,type,isexpired,CrowdId, tripFilterType, totalBaseCost, totalTaxCost, createddate,TripRouteType)                
		SELECT id ,startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,                
		followercount  ,imageurl ,replies ,ishost , RTRIM(replace(type,'expired','')) as type ,              
		isexpired  ,CrowdId , tripFilterType , totalBaseCost, totalTaxCost, createddate,TripRouteType
		FROM @me M
		left  join @tripTypes TT on ISNULL(M.tripFilterType,'a') = isnull(TT.triptypes,'a')
		WHERE type in (SELECT crowdtype FROM @crowdType) 
		ORDER BY               
		CASE  WHEN type = 'purchased' Then 6               
		ELSE         
		CASE               
		WHEN type = 'held' Then 6               
		ELSE          
		CASE               
		WHEN (type = 'cancelled' AND isexpired = 0) Then 5               
		ELSE               
		CASE               
		When type = 'following crowd'  THEN 4               
		ELSE                 
		CASE               
		When type = 'event' THEN 3               
		ELSE                
		CASE               
		When (type = 'purchased expired' OR type = 'cancelled expired') THEN 2                
		ELSe                
		CASE               
		When type = 'following crowd expired' THEN 1               
		END                
		END               
		END               
		END               
		END 
		END             
		END desc, --startDate asc                
		CASE When CHARINDEX('expired',type) > 0 Then startDate end desc ,                
		CASE When CHARINDEX('expired',type) <= 0 Then startDate end asc                 
    END              
  ELSE  IF (@toCities ='' AND @tripType !='')
	BEGIN
		Insert into @finalme ( id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,locationImage,replies,ishost,type,isexpired,CrowdId, tripFilterType, totalBaseCost, totalTaxCost, createddate,TripRouteType)                
		SELECT id ,startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,                
		followercount  ,imageurl ,replies ,ishost , RTRIM(replace(type,'expired','')) as type ,              
		isexpired  ,CrowdId , tripFilterType , totalBaseCost, totalTaxCost, createddate ,TripRouteType
		FROM @me M
		left  join @tripTypes TT on ISNULL(M.tripFilterType,'a') = isnull(TT.triptypes,'a')
		WHERE type in (SELECT crowdtype FROM @crowdType) 
		--and tripFilterType in ( select triptypes  from @tripTypes )
		and tripFilterType in (select triptypes from  @tripTypes) --('purchased','traveled')
		--AND tripFilterType = (CASE WHEN @tripType ='' THEN tripFilterType ELSE @tripType END )              
		ORDER BY               
		CASE  WHEN type = 'purchased' Then 6               
		ELSE         
		CASE               
		WHEN type = 'held' Then 6               
		ELSE          
		CASE               
		WHEN (type = 'cancelled' AND isexpired = 0) Then 5               
		ELSE               
		CASE               
		When type = 'following crowd'  THEN 4               
		ELSE                 
		CASE               
		When type = 'event' THEN 3               
		ELSE                
		CASE               
		When (type = 'purchased expired' OR type = 'cancelled expired') THEN 2                
		ELSe                
		CASE               
		When type = 'following crowd expired' THEN 1               
		END                
		END               
		END               
		END               
		END 
		END             
		END desc, --startDate asc                
		CASE When CHARINDEX('expired',type) > 0 Then startDate end desc ,                
		CASE When CHARINDEX('expired',type) <= 0 Then startDate end asc 
	END
  ELSE  IF (@toCities !='' AND @tripType ='')
	BEGIN
		Insert into @finalme ( id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,locationImage,replies,ishost,type,isexpired,CrowdId, tripFilterType, totalBaseCost, totalTaxCost, createddate,TripRouteType)                
		SELECT id ,startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,                
		followercount  ,imageurl ,replies ,ishost , RTRIM(replace(type,'expired','')) as type ,              
		isexpired  ,CrowdId , tripFilterType , totalBaseCost, totalTaxCost, createddate ,TripRouteType
		FROM @me M
		INNER JOIN @tripDestinations TD ON M.tripto = TD.destination 
		WHERE type in (SELECT crowdtype FROM @crowdType) 
		ORDER BY               
		CASE  WHEN type = 'purchased' Then 6               
		ELSE         
		CASE               
		WHEN type = 'held' Then 6               
		ELSE          
		CASE               
		WHEN (type = 'cancelled' AND isexpired = 0) Then 5               
		ELSE               
		CASE               
		When type = 'following crowd'  THEN 4               
		ELSE                 
		CASE               
		When type = 'event' THEN 3               
		ELSE                
		CASE               
		When (type = 'purchased expired' OR type = 'cancelled expired') THEN 2                
		ELSe                
		CASE               
		When type = 'following crowd expired' THEN 1               
		END                
		END               
		END               
		END               
		END 
		END             
		END desc, --startDate asc                
		CASE When CHARINDEX('expired',type) > 0 Then startDate end desc ,                
		CASE When CHARINDEX('expired',type) <= 0 Then startDate end asc 
	END
  ELSE          
    BEGIN           
        -- select 'test - Dest Added'
		Insert into @finalme ( id ,createddate, startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,locationImage,replies,ishost,type,isexpired,CrowdId, tripFilterType, totalBaseCost, totalTaxCost,TripRouteType )                
		SELECT id ,createddate, startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,                
		followercount  ,imageurl ,replies ,ishost , RTRIM(replace(type,'expired','')) as type ,              
		isexpired  ,CrowdId , tripFilterType , totalBaseCost, totalTaxCost ,TripRouteType              
		FROM @me M 
		INNER JOIN @tripDestinations TD ON M.tripto = TD.destination 
		WHERE type in (SELECT crowdtype FROM @crowdType)  
		and tripFilterType in ( select triptypes  from @tripTypes )
		ORDER BY               
		CASE               
			WHEN type = 'purchased' Then 5               
		ELSE 
			CASE               
				WHEN type = 'held' Then 5               
			ELSE             
			CASE               
				WHEN (type = 'cancelled' AND isexpired = 0) Then 5               
			ELSE               
				CASE               
					When type = 'following crowd'  THEN 4               
				ELSE                 
					CASE               
						When type = 'event' THEN 3               
					ELSE                
						CASE               
							When (type = 'purchased expired' OR type = 'cancelled expired') THEN 2                
						ELSe                
							CASE               
								When type = 'following crowd expired' THEN 1               
							END                
						END               
					END               
			END               
		END          
		END    
		END desc, --startDate asc                
		CASE When CHARINDEX('expired',type) > 0 Then startDate end desc ,                
		CASE When CHARINDEX('expired',type) <= 0 Then startDate end asc               
	END              
            
	 

 -- add air details to trip 
 INSERT INTO @AirSegmentDetails (airlineCode, tripkey)
  Select vendor.AirlineCode, trip.tripKey from Trip 
	INNER JOIN @finalme fm ON Trip.tripKey = fm.id
	INNER JOIN TripAirResponse resp 
	WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
	INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey AND leg.airLegNumber = 1
	INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
	LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 


	Update ad SET ad.NoOfStops = tmpDetails.cnt FROM 
	@AirSegmentDetails ad JOIN 
	(SELECT count(airlineCode) as cnt, tripkey from @AirSegmentDetails group by tripkey) tmpDetails 
	ON ad.tripkey = tmpDetails.tripkey


	Update ad SET ad.IsMultipleAirline = CASE WHEN tmpDetails.cnt > 1 THEN 1 ELSE 0 END   FROM 
	@AirSegmentDetails ad JOIN 
	(SELECT count(airlineCode) as cnt, tripkey from @AirSegmentDetails group by tripkey, airlineCode) tmpDetails 
	ON ad.tripkey = tmpDetails.tripkey

	Update fm SET fm.AirlineCode = ad.airlineCode, fm.IsMultipleAirline = ad.IsMultipleAirline, fm.NoOfStops = ad.NoOfStops FROM @finalme fm JOIN @AirSegmentDetails ad ON fm.id = ad.tripkey


	INSERT INTO @DestinationImage(AptCode, DestinationId, ImageURL, OrderId)
	SELECT D.AptCode, DI.DestinationID, DI.ImageURL, DI.OrderId 
	FROM CMS.dbo.DestinationImages DI
		INNER JOIN CMS.dbo.[Destination] D ON DI.DestinationId = D.DestinationId
	WHERE DI.DestinationID IN 
		(
			SELECT [DestinationId]  FROM [CMS].[dbo].[Destination] 
			WHERE AptCode IN (SELECT DISTINCT TripTo FROM @finalme ) 
		) ORDER BY DestinationID, OrderId

		;WITH CTE AS
        (
            select T.tripto, T.locationImage, DI.ImageURL, NTILE(25) OVER(partition by T.tripTo Order By DI.ImageURL) AS [Rank]
            from @finalme T
                INNER JOIN @DestinationImage DI ON T.tripTo = DI.AptCode 
        )
        UPDATE T  
        SET T.locationImage=DI.ImageURL  
        FROM CTE T
        INNER JOIN @DestinationImage DI ON T.TripTo = DI.AptCode AND T.[Rank]=DI.OrderId


  Select DISTINCT *, locationImage as ImageURL FROM @finalme WHERE RowNumber BETWEEN @FromIndex AND @ToIndex               

  
  INSERT INTO @DestinationsForFilter (destination, code , DestCount)              
 SELECT tocity, tripto , COUNT(tripto) from @finalme group by tripto,tocity;              
                
IF @FromIndex = 1              
BEGIN                


 SELECT @BadgeName = UM.BadgeName, @ImageUrl = CASE WHEN UM.UserImageData IS NOT NULL THEN 'user/image/'+CAST(UM.userId as VARCHAR) ELSE UM.ImageURL END              
 FROM Loyalty..UserMap UM              
 Where UM.UserId = @UserKey              
      
              
SELECT  distinct  * FROM @DestinationsForFilter              


END              
              
END 

GO
