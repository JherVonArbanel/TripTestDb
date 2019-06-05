SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 01-02-2016 19:30 PM
-- Description:	Get all trip followers by userID
-- =============================================
-- EXEC usp_GetAllTripsFollowersByUserId 560799,27819 
CREATE PROCEDURE [dbo].[usp_GetAllTripsFollowersByUserId]
	-- Add the parameters for the stored procedure here
	@userKey bigint,
	@tripKey bigint = 0
AS
BEGIN
    
    
  DECLARE @TripFollowersDetails AS TABLE  (  
	  userKey INT,  
	  userName VARCHAR(200) DEFAULT NULL,  
	  userImageURL VARCHAR(500)DEFAULT NULL,  
	  homeAirportCode VARCHAR(100) DEFAULT NULL,
	  isFollowing BIT DEFAULT 0,
	  privacyType INT  
 )    
 
  IF @tripKey = 0
  BEGIN
	  INSERT INTO @TripFollowersDetails (userKey) 
	  SELECT t.UserKey 
	   FROM Trip T WITH (NOLOCK)  
	   INNER JOIN TripSaved TS WITH(NOLOCK) ON T.tripSavedKey =TS. tripSavedKey  and T.userKey<>@userKey and t.userKey > 0 and T.privacyType=1
		WHERE IsWatching = 1 AND   CrowdId in
		( 
		  SELECT crowdId FROM TripSaved WITH (NOLOCK) WHERE tripSavedKey in 
		  (
			 SELECT tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey in 
			 ( 
				 SELECT TL.tripKey FROM TimeLine TL 
				 INNER JOIN trip..trip TP ON TL.TripKey = TP.tripKey AND TP.userKey = @userKey
				 WHERE TL.userKey=@userKey and TL.tripKey > 0
				 GROUP BY TL.tripKey 
			  )
		   )
		 ) GROUP BY T.UserKey
	 
	 
		  UPDATE TFD  
		  SET   
		   userName = ISNULL(U.userFirstName,'') + ' ' + LEFT(ISNULL(U.userLastName,''),1) + '.' ,userImageURL = ISNULL(UM.ImageURL,''),
		   homeAirportCode = ISNULL(AL.CityName,'')  
		  FROM   
		   @TripFollowersDetails TFD  
		  INNER JOIN   
		   vault..[User] U ON TFD.userKey = U.userKey  
		  LEFT OUTER JOIN   
		   Loyalty..UserMap UM ON TFD.userKey = UM.UserId  
		  LEFT OUTER JOIN   
		   vault..AirPreference AR ON TFD.userKey = AR.userKey
		  LEFT OUTER JOIN   
		   Trip..AirportLookup AL ON AL.AirportCode = AR.originAirportCode	
	     
	     
		 UPDATE TFD
		 SET
		   isFollowing = 1
		 FROM 
		  @TripFollowersDetails TFD  
		 INNER JOIN   
		   Loyalty..UserFollowers UF ON UF.UserId =TFD.userKey AND UF.FollowerId =@userKey
	    
	 
	  SELECT * FROM @TripFollowersDetails
  END
  ELSE
  BEGIN
	  INSERT INTO @TripFollowersDetails (userKey, privacyType) 
	  SELECT t.UserKey,t.privacyType 
	   FROM Trip T WITH (NOLOCK)  
	   INNER JOIN TripSaved TS WITH(NOLOCK) ON T.tripSavedKey =TS. tripSavedKey  and T.userKey<>@userKey and t.userKey > 0
		WHERE IsWatching = 1 AND CrowdId in
		( 
		  SELECT crowdId FROM TripSaved WITH (NOLOCK) WHERE tripSavedKey in 
		  (
			 SELECT tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey
		   )
		 ) 
	 
	 
		  UPDATE TFD  
		  SET   
		   userName = ISNULL(U.userFirstName,'') + ' ' + LEFT(ISNULL(U.userLastName,''),1) + '.' ,userImageURL = ISNULL(UM.ImageURL,''),
		   homeAirportCode = ISNULL(AL.CityName,'')  
		  FROM   
		   @TripFollowersDetails TFD  
		  INNER JOIN   
		   vault..[User] U ON TFD.userKey = U.userKey  
		  LEFT OUTER JOIN   
		   Loyalty..UserMap UM ON TFD.userKey = UM.UserId  
		  LEFT OUTER JOIN   
		   vault..AirPreference AR ON TFD.userKey = AR.userKey
		  LEFT OUTER JOIN   
		   Trip..AirportLookup AL ON AL.AirportCode = AR.originAirportCode		   
	     
	     
		 UPDATE TFD
		 SET
		   isFollowing = 1
		 FROM 
		  @TripFollowersDetails TFD  
		 INNER JOIN   
		  Loyalty..UserFollowers UF ON UF.UserId = TFD.userKey AND UF.FollowerId = @userKey
		  
		  
		 UPDATE  TFD
		  SET userImageURL = UM.BadgeUrl , userName = UM.BadgeName 
		 FROM 
		   @TripFollowersDetails TFD  
		 INNER JOIN   
		  Loyalty..UserMap UM ON UM.UserId = TFD.userKey 
		 WHERE privacyType = 2 
	    
	 
	  SELECT DISTINCT * FROM @TripFollowersDetails  
  END
END

GO
