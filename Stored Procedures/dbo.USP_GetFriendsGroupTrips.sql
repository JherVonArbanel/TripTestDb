SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Shrikant Sonawane
-- Create date: 8th Dec 2016
-- Description:	fetch all trips created for particular friends group
-- exec USP_GetFriendsGroupTrips 38, 0, 10 ,0 
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetFriendsGroupTrips] 
	(
		@groupKey INT,
		@FromIndex INT,
		@ToIndex INT,
		@LuserKey INT = 0,
		@toCities	VARCHAR(1000) = ''
	)
AS
BEGIN

	DECLARE @groupHostUserKey INT = 0
    DECLARE @crowdCount INT =0 
	SELECT @groupHostUserKey = UserKey From [vault].[dbo].[FriendsGroups] WHERE groupKey = @groupKey;

	
	Declare @tripKeys table 
	(tripKey varchar(200))
	
	Declare @tripDestinations table 
	(destination varchar(200))
	
	Declare @DestinationsForFilter table 
	(destination varchar(200), code varchar(200))
	
	INSERT INTO @tripDestinations
	(destination)
	SELECT * From dbo.ufn_DelimiterToTable(@toCities,',')
	
	
	DECLARE @FollowerCount TABLE(CrowdId BIGINT, FollowerCount BIGINT)
  
  
	Declare @tripDetail table  
	 (RowNumber int,id int,startDate datetime,enddate datetime null,tripfrom varchar(10) null,tripto varchar(10) null,fromcity varchar(200) null,tocity varchar(200) null,tripcomponents varchar(20) null,  
	followercount int null,imageurl varchar(500) null,replies int default(0),ishost bit default(0),type varchar(50),isexpired int default(0),Savings int default(0), CrowdId int default(0), tripStatusKey int default(0), isTripHost int default(0) )  
	
	Declare @finalTripDetail table  
	  (RowNumber int identity(1,1),id int,startDate datetime,enddate datetime null,tripfrom varchar(10) null,tripto varchar(10) null,fromcity varchar(200) null,tocity varchar(200) null,tripcomponents varchar(20) null,  
	  followercount int null,imageurl varchar(500) null,replies int default(0),ishost bit default(0),type varchar(50),isexpired int default(0),Savings int default(0), CrowdId int default(0), isTripHost int default(0) )  
  
	-- insert group keys
	INSERT INTO @tripKeys(tripKey)
	SELECT DISTINCT ATD.attendeeTripKey from Trip..Events E 
	INNER JOIN Trip..EventAttendees EAD 
	ON E.eventKey = EAD.eventKey AND EAD.userKey = @groupHostUserKey
	INNER JOIN Trip..AttendeeTravelDetails ATD ON EAD.eventAttendeeKey = ATD.eventAttendeekey
	INNER JOIN Trip..Trip TP ON TP.tripKey = ATD.attendeeTripKey AND TP.IsWatching = 1
	where E.groupKey = @groupKey;
	
	IF(@toCities = '') 
	BEGIN 
	Insert into @tripDetail  
	 (id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,type ,CrowdId, tripStatusKey, isTripHost)  
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
		 ,TS.CrowdId , T.tripStatusKey, (CASE WHEN T.userKey = @LuserKey THEN 1 ELSE 0 END)
	 FROM [Trip] T WITH(NOLOCK) INNER JOIN @tripKeys TK ON T.tripKey = TK.tripKey              
	  INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey              
	  LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode        
	  LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode  
	  LEFT JOIN vault..CountryLookup CL WITH(NOLOCK) ON ARR.CountryCode = CL.CountryCode   
	  LEFT JOIN TripSaved TS WITH (NOLOCK) ON T.tripSavedKey = TS.tripSavedKey  
	  WHERE T.isUserCreatedSavedTrip = 1 AND T.IsWatching = 1
	  END 
	 ELSE
		BEGIN
		Insert into @tripDetail  
		 (id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,type ,CrowdId, tripStatusKey, isTripHost)  
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
			 ,TS.CrowdId , T.tripStatusKey, (CASE WHEN T.userKey = @LuserKey THEN 1 ELSE 0 END)
		 FROM [Trip] T WITH(NOLOCK) INNER JOIN @tripKeys TK ON T.tripKey = TK.tripKey              
		  INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey 
		  INNER JOIN @tripDestinations TDT ON TR.tripTo1 = TDT.destination 
		  LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode        
		  LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode  
		  LEFT JOIN vault..CountryLookup CL WITH(NOLOCK) ON ARR.CountryCode = CL.CountryCode   
		  LEFT JOIN TripSaved TS WITH (NOLOCK) ON T.tripSavedKey = TS.tripSavedKey  
		  WHERE T.isUserCreatedSavedTrip = 1 AND T.IsWatching = 1
	 END
  
	INSERT INTO @DestinationsForFilter (destination, code)
	SELECT tocity, tripto from @tripDetail
	
	-- update type of trip
	UPDATE TD 
    SET TD.type = 
    (
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
			 (CASE WHEN dateadd(HOUR, 18, enddate) < GETDATE() THEN 'following crowd expired' ELSE 'following crowd' END) 
		END)
    )
    FROM @tripDetail TD
    
    UPDATE TD 
		SET TD.isexpired = (CASE WHEN dateadd(HOUR, 18, enddate) < GETDATE() THEN 1 ELSE 0 END)
	FROM @tripDetail TD  
	
	INSERT INTO @FollowerCount(crowdId,  FollowerCount)
	SELECT DISTINCT TD.CrowdId, COUNT(DISTINCT t.userKey) 
	FROM @tripDetail TD
		INNER JOIN TripSaved TS WITH(NOLOCK) ON TD.CrowdId = TS.crowdId 
		INNER JOIN Trip T ON  T.tripSavedKey = TS.tripSavedKey 
	WHERE T.IsWatching = 1 --AND TS.crowdId = Me.CrowdId
	GROUP BY TD.CrowdId 

    UPDATE TD 
		SET TD.followercount = fl.FollowerCount
    FROM @tripDetail TD
		INNER JOIN @FollowerCount fl ON TD.CrowdId = fl.CrowdId  

	IF(@toCities = '')
		BEGIN 
			SELECT  @crowdCount = COUNT(*) FROM @tripDetail 
		END 
	ELSE
		BEGIN
			SELECT  @crowdCount = COUNT(*) FROM @tripDetail M INNER JOIN @tripDestinations TD ON M.tripto = TD.destination
		END
		
	Insert into @finalTripDetail ( id ,startDate ,enddate ,tripfrom,tripto,fromcity ,tocity ,tripcomponents ,followercount ,imageurl,replies,ishost,type,isexpired,CrowdId, isTripHost )  
	SELECT id ,startDate ,enddate  ,tripfrom ,tripto ,fromcity ,tocity ,tripcomponents ,  
	  followercount  ,imageurl ,replies ,ishost , RTRIM(replace(type,'expired','')) as type ,
	  isexpired  ,CrowdId, isTripHost
	FROM @tripDetail 
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
	
	Select DISTINCT * FROM @finalTripDetail WHERE RowNumber BETWEEN @FromIndex AND @ToIndex 
	
	SELECT DISTINCT * FROM @DestinationsForFilter
	
	SELECT @crowdCount as crowdCount
END
GO
