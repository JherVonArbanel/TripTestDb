SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Rajkumar Tatipaka  
-- Create date: 29-Dec-2015  
-- Description: Get Account Details for mobile  
-- =============================================  
--Exec dbo.USP_GetMeIntegrated 560799,5, 1, 1000 ,0,1 ,562576,'',''
CREATE PROCEDURE [dbo].[USP_GetMeIntegrated]  
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
  (RowNumber int,id int,startDate datetime,enddate datetime null,tripfrom varchar(10) null,tripto varchar(10) null,fromcity varchar(200) null,tocity varchar(200) null,tripcomponents varchar(20) null,  
  followercount int null,imageurl varchar(500) null,replies int default(0),ishost bit default(0),type varchar(50),isexpired int default(0),Savings int default(0), CrowdId int default(0), tripStatusKey int default(0), tripFilterType varchar(200) DEFAULT 'saved' NOT NULL)  
  
  Declare @finalme table  
  (RowNumber int identity(1,1),id int,startDate datetime,enddate datetime null,tripfrom varchar(10) null,tripto varchar(10) null,fromcity varchar(200) null,tocity varchar(200) null,tripcomponents varchar(20) null,  
  followercount int null,imageurl varchar(500) null,replies int default(0),ishost bit default(0),type varchar(50),isexpired int default(0),Savings int default(0), CrowdId int default(0), tripFilterType varchar(200) null)  
  
  Declare @crowdType table 
  (crowdtype varchar(200)) 
  
  Declare @userWithSimilarTrips table 
  (userKey varchar(200), peopleWithSimilarTrip int default 0 ) 

  DECLARE @FollowerCount TABLE(CrowdId BIGINT, FollowerCount BIGINT)
  
  DECLARE @FollowedTripKey TABLE(CrowdId BIGINT, TripKey BIGINT)
 --***************** Get purchased trips **********************  
 --DECLARE @tblPurchase TABLE               
 --(              
 -- tripKey INT,              
 -- tripPurchasedKey uniqueidentifier               
 --)
 Declare @tripDestinations table 
(destination varchar(200))

Declare @DestinationsForFilter table 
(destination varchar(200), code varchar(200))

INSERT INTO @tripDestinations
(destination)
SELECT * From dbo.ufn_DelimiterToTable(@toCities,',')

 DECLARE @loggedinUserKey int
 
 SET @loggedinUserKey = @UserKey  
 
 IF @thirdPartyUser > 0
 BEGIN
	SET @UserKey = @thirdPartyUser
	IF @ShowExpired = 0 
	 BEGIN
		INSERT INTO @crowdType(crowdtype) VALUES ('following crowd')
	 END 
 ELSE 
	 BEGIN
		INSERT INTO @crowdType(crowdtype) VALUES ('following crowd'),('following crowd expired')
	 END 
 END
 Else 
 BEGIN
 IF @ShowExpired = 0 
	 BEGIN
		INSERT INTO @crowdType(crowdtype) VALUES ('purchased'),('following crowd'),('cancelled')
	 END 
 ELSE 
	 BEGIN
		INSERT INTO @crowdType(crowdtype) VALUES ('purchased'),('cancelled'),('following crowd'),('event'),('purchased expired'),('following crowd expired'),('event expired'),('cancelled expired')
	 END 
 END   
--PRINT ('1: '+CONVERT( VARCHAR(24), GETDATE(), 121))

       
 Insert into @me  
 (id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,type ,CrowdId, tripStatusKey)  
    SELECT DISTINCT T.[tripKey],startDate, endDate            
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
     ,TS.CrowdId , T.tripStatusKey
 FROM [Trip] T WITH(NOLOCK)              
  INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey              
  LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode        
  LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode  
  LEFT JOIN vault..CountryLookup CL WITH(NOLOCK) ON ARR.CountryCode = CL.CountryCode   
  LEFT JOIN TripSaved TS WITH (NOLOCK) ON T.tripSavedKey = TS.tripSavedKey  
  WHERE T.siteKey = @SiteKey AND T.userKey = @UserKey --AND T.isUserCreatedSavedTrip = 1 AND T.IsWatching = 1
 
 IF(@UserKey = @thirdPartyUser OR @thirdPartyUser = 0)
 BEGIN
  Insert into @me  
 (id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,type ,CrowdId, tripStatusKey)
SELECT DISTINCT T.[tripKey],startDate, endDate            
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
     ,TS.CrowdId , T.tripStatusKey
 FROM [Trip] T WITH(NOLOCK)              
  INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey             
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.TripKey AND TPI.PassengerKey = @UserKey
  LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode        
  LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode  
  LEFT JOIN vault..CountryLookup CL WITH(NOLOCK) ON ARR.CountryCode = CL.CountryCode   
  LEFT JOIN TripSaved TS WITH (NOLOCK) ON T.tripSavedKey = TS.tripSavedKey  
  WHERE T.siteKey = @SiteKey AND T.tripKey not in (SELECT id FROM @me)  AND T.isUserCreatedSavedTrip = 1 AND T.IsWatching = 1
	-- update type of trip
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
    -- WHERE (TD.tripStatusKey = 2 OR TD.tripStatusKey = 1 OR TD.tripStatusKey = 15 OR TD.tripStatusKey = 5) 
   
   UPDATE TD SET 
	TD.tripFilterType = 'purchased'
   FROM @me TD WHERE (TD.tripStatusKey = 2 OR TD.tripStatusKey = 1 OR TD.tripStatusKey = 15 OR TD.tripStatusKey = 5)
   
   UPDATE TD 
    SET TD.isexpired = (CASE WHEN 
    (CASE WHEN (TD.tripStatusKey = 2 OR TD.tripStatusKey = 1 OR TD.tripStatusKey = 15 OR TD.tripStatusKey = 5) THEN dateadd(HOUR, 18, enddate)
    ELSE startDate END) < GETDATE() THEN 1 ELSE 0 END)
   FROM @me TD  
	
   IF(@siteKey = 5 OR @siteKey= 7 OR @siteKey =1)
   BEGIN
	DELETE M FROM @me M INNER JOIN Trip..Trip TP ON M.id = TP.tripKey AND (TP.isUserCreatedSavedTrip = 0 OR TP.IsWatching = 0)
   END 
   ELSE
   BEGIN
	 UPDATE TD SET 
	 TD.tripFilterType = 'traveled'
    FROM @me TD WHERE tripFilterType = 'purchased' and isexpired = 1
   END 
 
 INSERT INTO @DestinationsForFilter (destination, code)
 SELECT tocity, tripto from @me;
 
--Exec dbo.USP_GetMeIntegrated_backup_010816 1257,1, 1, 1000 ,0,0 ,0
------- Added by Gopal
INSERT INTO @FollowerCount(crowdId,  FollowerCount)
SELECT DISTINCT Me.CrowdId, COUNT(DISTINCT t.userKey) 
FROM @me Me
	INNER JOIN TripSaved TS WITH(NOLOCK) ON Me.CrowdId = TS.crowdId 
	INNER JOIN Trip T ON  T.tripSavedKey = TS.tripSavedKey 
WHERE T.IsWatching = 1 --AND TS.crowdId = Me.CrowdId
GROUP BY Me.CrowdId 

INSERT INTO @FollowedTripKey (CrowdId , TripKey )
SELECT Me.CrowdId, T.tripKey
FROM (Select CrowdId, id FROM @me) Me
	INNER JOIN TripSaved TS WITH(NOLOCK) ON Me.CrowdId = TS.crowdId 
	INNER JOIN Trip T ON  T.tripSavedKey = TS.tripSavedKey AND  T.tripKey < Me.id 
WHERE T.IsWatching = 1 AND T.userKey != @UserKey  --AND TS.crowdId = Me.CrowdId


UPDATE TD SET TD.tripFilterType = 'following'
FROM @me TD INNER JOIN @FollowedTripKey FT on TD.CrowdId = FT.CrowdId AND TD.tripFilterType = 'saved';


-- SELECT * FROM @FollowedTripKey;

--PRINT ('5_1: '+CONVERT( VARCHAR(24), GETDATE(), 121)) 
    UPDATE TD 
    SET TD.followercount = fl.FollowerCount
    FROM @me TD
		INNER JOIN @FollowerCount fl ON TD.CrowdId = fl.CrowdId  
--PRINT ('5_2: '+CONVERT( VARCHAR(24), GETDATE(), 121)) 
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
		IF(@toCities = '')
			BEGIN 
				Insert into @finalme ( id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,replies,ishost,type,isexpired,CrowdId, tripFilterType )  
				SELECT id ,startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,  
				  followercount  ,imageurl ,replies ,ishost , RTRIM(replace(type,'expired','')) as type ,
				  isexpired  ,CrowdId , tripFilterType 
				FROM @me WHERE type in (SELECT crowdtype FROM @crowdType) AND tripFilterType = (CASE WHEN @tripType ='' THEN tripFilterType ELSE @tripType END )
				ORDER BY 
				CASE 
					WHEN type = 'purchased' Then 5 
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
				END desc, --startDate asc  
				CASE When CHARINDEX('expired',type) > 0 Then startDate end desc ,  
				CASE When CHARINDEX('expired',type) <= 0 Then startDate end asc   
			END
		ELSE
		BEGIN
			IF(@siteKey = 5 OR @siteKey= 7 OR @siteKey =1)
			BEGIN
			
			Insert into @finalme ( id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,replies,ishost,type,isexpired,CrowdId ,tripFilterType)  
			SELECT id ,startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,  
			  followercount  ,imageurl ,replies ,ishost , replace(type,'expired','') as type ,
			  isexpired  ,CrowdId , tripFilterType
			FROM @me M INNER JOIN @tripDestinations TD ON M.tripto = TD.destination WHERE type in (SELECT crowdtype FROM @crowdType)
			ORDER BY 
			CASE 
				WHEN type = 'purchased' Then 5 
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
			END desc, --startDate asc  
			CASE When CHARINDEX('expired',type) > 0 Then startDate end desc ,  
			CASE When CHARINDEX('expired',type) <= 0 Then startDate end asc
			END
			ELSE
			BEGIN
				Insert into @finalme ( id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,replies,ishost,type,isexpired,CrowdId, tripFilterType )  
				SELECT id ,startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,  
				  followercount  ,imageurl ,replies ,ishost , RTRIM(replace(type,'expired','')) as type ,
				  isexpired  ,CrowdId , tripFilterType 
				FROM @me M INNER JOIN @tripDestinations TD ON M.tripto = TD.destination WHERE type in (SELECT crowdtype FROM @crowdType)
				 AND tripFilterType = 
				(CASE WHEN @tripType ='' THEN tripFilterType ELSE @tripType END )
				ORDER BY 
				CASE 
					WHEN type = 'purchased' Then 5 
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
				END desc, --startDate asc  
				CASE When CHARINDEX('expired',type) > 0 Then startDate end desc ,  
				CASE When CHARINDEX('expired',type) <= 0 Then startDate end asc 
			END
		END	
		
   	
		Select DISTINCT * FROM @finalme WHERE RowNumber BETWEEN @FromIndex AND @ToIndex 
	  
IF @FromIndex = 1
BEGIN 	
	--***** Added these conditions as per userstory 19887 ****---		
	--**************** people with similar trips ***************
	Declare @HomeAirportCode varchar(10)
	Declare @HomeCountryCode varchar(10)
	DECLARE @peoplesCount INT = 0

	SELECT @HomeAirportCode = originAirportCode, @HomeCountryCode = AL.CountryCode
	FROM vault.dbo.AirPreference AP JOIN AirportLookup AL ON AP.originAirportCode = AL.AirportCode
	Where Userkey = @loggedinUserKey

	insert into @userWithSimilarTrips(userKey, peopleWithSimilarTrip)
	--*************** following same or different crowds to the same destination
	SELECT DISTINCT u.userkey, 1
	FROM TripSaved TS  WITH(NOLOCK)   
	INNER join Trip T WITH(NOLOCK) on T.tripSavedKey = TS.tripSavedKey  and t.userKey=ts.userKey    
	INNER JOIN TripDetails TD WITH(NOLOCK) on T.tripKey = TD.tripKey  
	INNER JOIN vault.dbo.[User] u on T.userKey = u.userkey
	INNER JOIN loyalty.dbo.usermap um on u.userKey = um.UserId
	INNER JOIN @me me ON TD.tripTo = me.tripTo AND me.isexpired =0 
	WHERE TS.userKey in (select AP.userkey from vault.dbo.AirPreference AP JOIN AirportLookup AL ON AP.originAirportCode = AL.AirportCode WHERE (AP.originAirportCode = @HomeAirportCode OR AL.CountryCode =@HomeCountryCode ))
		  AND TS.userKey <> @loggedinUserKey AND TS.userKey <> @UserKey
		  AND TS.userKey  not in ( SELECT UserID FROM loyalty.dbo.userfollowers WHERE FollowerId = @loggedinUserKey) 
		  AND u.siteKey = @SiteKey AND T.siteKey = @SiteKey AND dateadd(HOUR, 18, T.endDate) < GETDATE()

	Select @peoplesCount = COUNT(userkey) from @userWithSimilarTrips;
	DECLARE @tbl TABLE (userKey INT , crowdCount INT DEFAULT 0 )
	IF(@peoplesCount = 0)
	BEGIN
	
		
		insert into @tbl(userKey, crowdCount)
		Select temp.userkey, (SELECT COUNT(T.tripKey) as CrowdCount FROM Trip T WITH(NOLOCK) 
	WHERE T.userKey = temp.Userkey AND (T.isUserCreatedSavedTrip = 1 AND T.IsWatching = 1) 
	AND T.siteKey = @SiteKey) as CrowdCount from (select AP.userkey from vault.dbo.AirPreference AP WHERE AP.originAirportCode = @HomeAirportCode
		UNION
		select AP.userkey from vault.dbo.AirPreference AP JOIN AirportLookup AL ON AP.originAirportCode = AL.AirportCode
		AND AL.CountryCode = @HomeCountryCode) as temp JOIN vault.dbo.[User] U on U.userkey = temp.userKey  WHERE U.siteKey = @SiteKey AND temp.userkey != @loggedinUserKey AND temp.userKey != @thirdPartyUser AND temp.userkey not in (
								SELECT UserID FROM loyalty.dbo.userfollowers --Followings
								WHERE FollowerId = @loggedinUserKey)
								
		insert into @userWithSimilarTrips(userKey)
		SELECT userKey from @tbl WHERE 
		crowdCount > 0 AND 
		userKey != @loggedinUserKey 
		ORDER BY  crowdCount DESC
		
	END
	Select @peoplesCount = COUNT(userkey) from @userWithSimilarTrips;

	IF(@peoplesCount = 0)
	BEGIN
		
		
		Insert into @tbl(userKey ,crowdCount)
		SELECT U.userKey, (SELECT COUNT(T.tripKey) as CrowdCount FROM Trip T WITH(NOLOCK) 
	WHERE T.userKey = U.Userkey AND (T.isUserCreatedSavedTrip = 1 AND T.IsWatching = 1) 
	AND T.siteKey = @SiteKey) as CrowdCount FROM vault.dbo.[User] U WHERE U.userKey not in(
			SELECT UserID FROM loyalty.dbo.userfollowers  WHERE FollowerId = @loggedinUserKey
		) AND U.siteKey = @SiteKey AND U.userkey != @loggedinUserKey AND U.userKey != @thirdPartyUser  AND U.userkey not in (
								SELECT UserID FROM loyalty.dbo.userfollowers --Followings
								WHERE FollowerId = @loggedinUserKey)
		
		insert into @userWithSimilarTrips (userKey)
		SELECT top 6 userKey from @tbl WHERE 
		crowdCount > 0 AND 
		userKey != @loggedinUserKey 
		ORDER BY  crowdCount DESC
	END

	SELECT top 6 * from (
	SELECT DISTINCT u.userkey,u.userFirstName + ' ' + u.userLastName as username,um.ImageURL, uwst.peopleWithSimilarTrip,
	(SELECT COUNT(T.tripKey) as CrowdCount FROM Trip T WITH(NOLOCK) 
	WHERE T.userKey =u.Userkey AND (T.isUserCreatedSavedTrip = 1 AND T.IsWatching = 1) 
	AND T.siteKey = @SiteKey) as CrowdCount
	,(Select Count(*) as EventCount
		FROM [dbo].[Events] E 
		WHERE  E.IsDeleted = 0 and E.userKey = U.userkey	 ) as EventCount
	FROM vault.dbo.[User] u 
	INNER JOIN loyalty.dbo.usermap um on u.userKey = um.UserId
	INNER JOIN @userWithSimilarTrips uwst ON u.userKey = uwst.userkey AND u.siteKey = @siteKey

	) as SimilarTrips
	--PRINT ('8: '+CONVERT( VARCHAR(24), GETDATE(), 121))
	SELECT @HomeAirportCode = originAirportCode 
	FROM vault.dbo.AirPreference AP 
	Where Userkey = @UserKey

	SELECT @BadgeName = UM.BadgeName, @ImageUrl = CASE WHEN UM.UserImageData IS NOT NULL THEN 'user/image/'+CAST(UM.userId as VARCHAR) ELSE UM.ImageURL END
	FROM Loyalty..UserMap UM
	Where UM.UserId = @UserKey

	SELECT @IsThirdParty AS IsThirdParty, @HomeAirportCode AS HomeAirport, @BadgeName as BadgeName, userFirstName , userLastName,@ImageUrl as ImageUrl  FROM vault..[User] WHERE userKey = @UserKey ;

	SELECT DISTINCT * FROM @DestinationsForFilter

END

END
GO
