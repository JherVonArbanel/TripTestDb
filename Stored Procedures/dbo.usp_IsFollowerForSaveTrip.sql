SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[usp_IsFollowerForSaveTrip]   
(  
@userKey   INT,  
@tripKey   INT  
)  
AS  
BEGIN   
  
DECLARE @tripSavedKey AS UNIQUEIDENTIFIER     
DECLARE @crowdId AS BIGINT 
DECLARE @isFollower AS BIT = 0     
SELECT @tripSavedKey = tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey     
SELECT @crowdId=CrowdId FROM TripSaved WITH(NOLOCK) WHERE tripSavedKey=@tripSavedKey

IF (SELECT COUNT(*) FROM Trip  T WITH(NOLOCK) INNER JOIN TripSaved TS WITH(NOLOCK) ON 
T.tripSavedKey= TS.tripSavedKey 
 WHERE  CrowdId = @crowdId and IsWatching =1 AND t.userKey = @userKey ) > 0     
BEGIN     
SET @isFollower = 1    
END    

SELECT @isFollower       
END  
  
   
GO
