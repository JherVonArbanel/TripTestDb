SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

    
-- =============================================          
-- Author:  Jitendra Verma           
-- Create date: 28/Jan/2016          
-- Description: It is used to get following users data for passed UserId         
/*  
Exec [USP_GetFollowingDetailsByUserId] 561138 , 'followers',560799    
 Exec [USP_GetFollowingDetailsByUserId_NEW] 561138 , 'following',560799  
 */  
-- =============================================          
    
CREATE PROCEDURE [dbo].[USP_GetFollowingDetailsByUserId_New]          
 @UserId INT,     
 @Type VARCHAR(50),        
 @LoggedInUserKey INT = 0  
AS          
BEGIN          
    
  SET NOCOUNT ON -- added to prevent extra result sets from          
  
     
	DECLARE @UsersFollowingDetails AS TABLE    
	(    
		--userFollowingDetailKey UNIQUEIDENTIFIER,      
		userKey INT,    
		userFirstName VARCHAR(200) DEFAULT NULL,    
		userLastName VARCHAR(200) DEFAULT NULL,    
		userName VARCHAR(200) DEFAULT NULL,    
		BadgeName VARCHAR(300) DEFAULT NULL,    
		BadgeUrl VARCHAR(500) DEFAULT NULL,    
		homeAirportCode VARCHAR(100) DEFAULT NULL,    
		homeCityName VARCHAR(200) DEFAULT NULL,    
		desinationImageUrl VARCHAR(500) DEFAULT NULL,    
		totalEvent INT,    
		crowds INT,    
		followers INT,    
		followings INT,    
		isFollowing BIT  
	)    
 
	if(@Type = 'following')    
	Begin     
		INSERT INTO @UsersFollowingDetails    
		(    
		userKey,    
		userFirstName,    
		userLastName,    
		BadgeName,    
		BadgeUrl,    
		homeAirportCode,    
		homeCityName    
		)    

		  --SELECT UF.UserId, U.userFirstName, U.userLastName, UM.BadgeName, UM.ImageURL, AP.originAirportCode, D.CityName    
		  --FROM Loyalty..UserFollowers UF     
		  --  INNER JOIN [Vault]..[User] U ON U.userKey = UF.UserId     
		  --  LEFT OUTER JOIN [Loyalty]..[UserMap] UM ON UF.UserId = UM.UserId    
		  --  LEFT OUTER JOIN [Vault].[dbo].[AirPreference] AP ON UF.UserId = AP.userKey    
		  --  LEFT OUTER JOIN [CMS].[dbo].[Destination] D ON D.AptCode= AP.originAirportCode    
		  --WHERE  UF.UserId = @userID AND U.IsDeleted = 0  
		     
		  --SELECT UF.UserId , U.userFirstName, U.userLastName, UM.BadgeName, UM.ImageURL, AP.originAirportCode, D.CityName    
		  --FROM Loyalty..UserFollowers UF     
		  --  INNER JOIN [Vault]..[User] U ON U.userKey = UF.UserId     
		  --  LEFT OUTER JOIN [Loyalty]..[UserMap] UM ON UF.UserId = UM.UserId    
		  --  LEFT OUTER JOIN [Vault].[dbo].[AirPreference] AP ON UF.UserId = AP.userKey    
		  --  LEFT OUTER JOIN [CMS].[dbo].[Destination] D ON D.AptCode= AP.originAirportCode    
		  --WHERE  UF.FollowerId = @userID AND U.IsDeleted = 0     
		  SELECT --DISTINCT 
			UF.UserId , U.userFirstName, U.userLastName, UM.BadgeName, UM.ImageURL
			, ISNULL(AP.originAirportCode,'') originAirportCode, ISNULL(D.CityName, '') CityName  
		  FROM Loyalty..UserFollowers UF     
			INNER JOIN [Vault]..[User] U ON U.userKey = UF.UserId     
			LEFT OUTER JOIN [Loyalty]..[UserMap] UM ON UF.UserId = UM.UserId    
			LEFT OUTER JOIN [Vault].[dbo].[AirPreference] AP ON UF.UserId = AP.userKey    
			LEFT OUTER JOIN Trip.dbo.AirportLookup D ON D.AirportCode = AP.originAirportCode    
		  WHERE  UF.FollowerId = @userID AND U.IsDeleted = 0 
			--AND (AP.originAirportCode IS NOT NULL OR AP.originAirportCode <> '') AND D.AptCode <> ''   
    
		IF (@LoggedInUserKey = 0)  
		BEGIN  
			SET @LoggedInUserKey = @UserId  
		END  
    
		IF (@UserId = @LoggedInUserKey)   
		BEGIN  
			UPDATE UFD SET isFollowing = 1 
			FROM @UsersFollowingDetails UFD      
				INNER JOIN Loyalty..UserFollowers UF ON UF.UserId = UFD.userKey AND UF.FollowerId = @LoggedInUserKey    
		END  
		ELSE  
		BEGIN  
			UPDATE UFD SET isFollowing = 1 
			FROM @UsersFollowingDetails UFD 
				INNER JOIN Loyalty..UserFollowers UF ON UF.UserId = UFD.userKey  AND UF.FollowerId = @LoggedInUserKey 
		END 
	End    
     
	if(@Type = 'followers')    
	Begin 
	
		INSERT INTO @UsersFollowingDetails    
		(    
			userKey,    
			userFirstName,    
			userLastName,    
			BadgeName,    
			BadgeUrl,    
			homeAirportCode,    
			homeCityName    
		)    

		SELECT UF.FollowerId, U.userFirstName, U.userLastName, UM.BadgeName, UM.ImageURL, AP.originAirportCode, D.CityName    
		FROM Loyalty..UserFollowers UF     
			INNER JOIN [Vault]..[User] U ON U.userKey = UF.FollowerId     
			LEFT OUTER JOIN [Loyalty]..[UserMap] UM ON UF.FollowerId = UM.UserId    
			LEFT OUTER JOIN [Vault].[dbo].[AirPreference] AP ON UF.FollowerId = AP.userKey    
			LEFT OUTER JOIN Trip.dbo.AirportLookup D ON D.AirportCode = AP.originAirportCode    
		WHERE  UF.UserId = @userID AND U.IsDeleted = 0     

		IF (@LoggedInUserKey = 0)  
		BEGIN  
			SET @LoggedInUserKey = @UserId  
		END  

		IF (@UserId = @LoggedInUserKey)   
		BEGIN  
			UPDATE UFD SET isFollowing = 1 
			FROM @UsersFollowingDetails UFD      
			INNER JOIN Loyalty..UserFollowers UF ON UF.UserId = UFD.userKey AND UF.FollowerId = @LoggedInUserKey    
		END  
		ELSE  
		BEGIN  
			UPDATE UFD    
			SET isFollowing = 1    
			FROM @UsersFollowingDetails UFD 
			INNER JOIN Loyalty..UserFollowers UF ON UF.UserId =  UFD.userKey  AND UF.FollowerId =  @LoggedInUserKey 
		END  
	End    
    
     
	UPDATE UF     
	SET totalEvent = ISNULL(CNT, 0)    
	FROM @UsersFollowingDetails UF     
		LEFT OUTER JOIN     
		(    
			SELECT UF1.userKey, COUNT(EA.EventKey) CNT    
			FROM @UsersFollowingDetails UF1    
			INNER JOIN [Trip]..[EventAttendees] EA ON UF1.userKey = EA.userKey    
			GROUP BY UF1.userKey    
		) EA ON UF.userKey = EA.userKey    
    
    
if(@Type = 'followers')    
 Begin    
 UPDATE UF     
 SET desinationImageUrl = ISNULL(B.ImageURL, '')    
 FROM @UsersFollowingDetails UF     
  LEFT OUTER JOIN     
  (    
   SELECT DISTINCT UserKey, ImageURL, originAirportCode FROM    
   (    
    SELECT DISTINCT AP.userKey, DI.ImageURL, AP.originAirportCode, D.DestinationId, D.CreatedDate    
     , ROW_NUMBER() OVER(PARTITION BY AP.UserKey ORDER BY D.CreatedDate DESC) RN    
    FROM [CMS].[dbo].[DestinationImages] DI     
     INNER JOIN [CMS].[dbo].[Destination] D ON DI.DestinationId = D.DestinationId    
     INNER JOIN [Vault].[dbo].[AirPreference] AP ON D.AptCode= AP.originAirportCode    
    WHERE DI.OrderId = 1 AND AP.userKey IN (SELECT FollowerId FROM Loyalty..UserFollowers WHERE UserId = @userID)    
   )A WHERE RN = 1    
  )B ON UF.userKey = B.userKey    
 End      
      
 if(@Type = 'following')    
 Begin    
 UPDATE UF     
 SET desinationImageUrl = ISNULL(B.ImageURL,'')    
 FROM @UsersFollowingDetails UF     
  LEFT OUTER JOIN     
  (    
   SELECT DISTINCT UserKey, ImageURL, originAirportCode FROM    
   (    
    SELECT DISTINCT AP.userKey, DI.ImageURL, AP.originAirportCode, D.DestinationId, D.CreatedDate    
     , ROW_NUMBER() OVER(PARTITION BY AP.UserKey ORDER BY D.CreatedDate DESC) RN    
    FROM [CMS].[dbo].[DestinationImages] DI     
     INNER JOIN [CMS].[dbo].[Destination] D ON DI.DestinationId = D.DestinationId    
     INNER JOIN [Vault].[dbo].[AirPreference] AP ON D.AptCode= AP.originAirportCode    
    WHERE DI.OrderId = 1 AND AP.userKey IN (SELECT UserId FROM Loyalty..UserFollowers WHERE FollowerId = @userID)    
   )A WHERE RN = 1    
  )B ON UF.userKey = B.userKey    
   
  UPDATE UF
 SET desinationImageUrl = ISNULL(C.ImageURL,'')    
 FROM @UsersFollowingDetails UF     
  LEFT OUTER JOIN
  (
	select NEWID() NID, * FROM [CMS].[dbo].[DestinationImages] where DestinationId in 
	(
		select DestinationId  from [CMS].[dbo].[Destination] where DestinationId= 62 
	) 
  )C ON NewID() = C.NID --  C.ImageURL = C.ImageURL 
  WHERE UF.desinationImageUrl = '' 
  

      
      
 End       
    
 UPDATE UF     
 SET crowds = ISNULL(C.Crowd, 0)    
 FROM @UsersFollowingDetails UF     
  LEFT OUTER JOIN     
  (    
   SELECT UF.userKey, COUNT(UF.userKey) AS Crowd    
   FROM @UsersFollowingDetails UF    
    LEFT OUTER Join [Trip].[dbo].[TripDetails] TD ON UF.userKey = TD.userKey AND CONVERT(Date,TD.lastUpdatedDate)= Convert(Date,GETDATE())          
    INNER JOIN [Trip].[dbo].[Trip] T ON TD.tripKey = T.tripKey AND T.tripStatusKey <> 17          
    INNER JOIN [Trip].[dbo].TripSaved TS WITH (NOLOCK) ON T.tripSavedKey = TS.tripSavedKey        
   --WHERE UF.FollowerId = @userID -- 560551    
   GROUP BY UF.userKey    
  )C ON UF.userKey = C.UserKey    
    
 UPDATE UF     
 SET followers = ISNULL(D.Followers, 0)    
 FROM @UsersFollowingDetails UF     
  LEFT OUTER JOIN     
  (    
   SELECT UF.userKey, COUNT(UF1.UserId) Followers     
   FROM @UsersFollowingDetails UF    
    INNER JOIN Loyalty..UserFollowers UF1 ON UF.userKey = UF1.FollowerId    
   --WHERE UF.FollowerId = @userID     
   GROUP BY UF.userKey    
  )D ON UF.userKey = D.UserKey    
    
 UPDATE UF     
 SET followings = ISNULL(E.Followings, 0)    
 FROM @UsersFollowingDetails UF     
  LEFT OUTER JOIN     
  (     
   SELECT U.userKey, COUNT(1) Followings    
   FROM @usersFollowingDetails U     
    LEFT OUTER JOIN Loyalty..userFollowers UF1 ON U.userKey = UF1.UserId     
   GROUP BY U.userKey    
  )E ON UF.UserKey = E.userKey    
    
    
    
 SELECT    
  distinct(userKey),    
  userFirstName,    
  userLastName,    
  userName    
  BadgeName,    
  BadgeUrl,    
  homeAirportCode,    
  homeCityName,    
  followers,    
  followings,    
  totalEvent,    
  crowds,    
  desinationImageUrl,    
  isFollowing  
      
  FROM @UsersFollowingDetails    
     
END
GO
