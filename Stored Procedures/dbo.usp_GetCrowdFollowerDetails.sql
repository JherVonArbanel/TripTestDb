SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- EXEC usp_GetCrowdFollowerDetails 33401      
-- 12223      
CREATE PROC [dbo].[usp_GetCrowdFollowerDetails]      
(      
 @tripKey INT,      
 @loggedInUserKey INT = 0      
)      
AS       
BEGIN      
      
SET NOCOUNT ON       
      
 DECLARE @tripSavedKey UNIQUEIDENTIFIER      
 DECLARE @crowdId BIGINT       
 DECLARE @TripFollowersDetails AS TABLE      
 (      
  tripSavedKey UNIQUEIDENTIFIER,        
  userKey INT,      
  userName VARCHAR(200) DEFAULT NULL,      
  userImageURL VARCHAR(500)DEFAULT NULL,      
  privacyType INT,      
  homeAirportCode VARCHAR(100) DEFAULT NULL,
  firstName VARCHAR(200) DEFAULT NULL,
  lastName VARCHAR(200) DEFAULT NULL,
  tripKey INT,
  isShowMyPic INT,
  imageData Image
 )      
       
      
 SELECT @tripSavedKey = tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey      
 SELECT @crowdId = crowdId FROM TripSaved WITH (NOLOCK) WHERE tripSavedKey = @tripSavedKey      
       
      
  INSERT INTO @TripFollowersDetails      
  (      
   tripSavedKey,        
   userKey ,      
   userName ,      
   userImageURL,      
   privacyType,      
   homeAirportCode ,
   tripKey,
   isShowMyPic,
   imageData        
  )      
  SELECT       
   T.tripSavedKey,          
   ISNULL(T.userKey,0),      
   NULL,      
   NULL,      
   ISNULL(T.privacyType,1),--Changed from TS.privacyType to T.privacyType for TFS#16414  
   NULL,
   tripKey,
   T.IsShowMyPic,
   NULL          
  FROM       
   Trip T WITH (NOLOCK)      
   INNER JOIN TripSaved TS WITH(NOLOCK) ON T.tripSavedKey =TS. tripSavedKey      
  WHERE CrowdId = @crowdId       
  AND IsWatching = 1 order by t.tripKey asc        
        
      
/*      
      
  INSERT INTO @TripFollowersDetails      
  (      
   tripSavedKey,        
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
  WHERE       
   TS.tripSavedKey = @tripSavedKey      
   AND      
   parentSaveTripKey IS NOT NULL      
      
*/           
  UPDATE TFD      
  SET       
   userName = ISNULL(U.userFirstName,'') + ' ' + LEFT(ISNULL(U.userLastName,''),1) + '.',
   firstName = U.userFirstName, lastName = U.userLastName
  FROM       
   @TripFollowersDetails TFD      
  INNER JOIN       
   vault..[User] U ON TFD.userKey = U.userKey      
        
        
  UPDATE TFD      
  SET       
   --userImageURL = ISNULL(UM.ImageURL,'')      
   userImageURL = case when TFD.privacyType=2 then  ISNULL(UM.BadgeUrl,'')   when TFD.privacyType=1 then ISNULL(UM.ImageURL,'') else ISNULL(UM.ImageURL,'') end,
   imageData=UM.UserImageData 
  FROM       
   @TripFollowersDetails TFD      
  LEFT JOIN       
   Loyalty..UserMap UM ON TFD.userKey = UM.UserId      
         
  UPDATE TFD      
  SET       
   homeAirportCode = ISNULL(AR.originAirportCode,'')       
  FROM       
   @TripFollowersDetails TFD      
  INNER JOIN       
   vault..AirPreference AR ON TFD.userKey = AR.userKey      
        
   --commented for TFS#16414      
  
   UPDATE TFD 
   SET 
		userImageURL = case when TFD.isShowMyPic=2 then  ISNULL(UM.BadgeUrl,'')   when TFD.isShowMyPic=1 then ISNULL(UM.ImageURL,'') else ISNULL(UM.ImageURL,'') end        
   FROM @TripFollowersDetails TFD
   LEFT JOIN       
		Loyalty..UserMap UM ON TFD.userKey = UM.UserId   
   WHERE TFD.userKey <> @loggedInUserKey     
   
  SELECT * FROM @TripFollowersDetails       
 
SET NOCOUNT OFF      
      
END 
GO
