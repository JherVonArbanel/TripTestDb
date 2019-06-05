SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec usp_GetFollowersCount 12273    
CREATE Procedure [dbo].[usp_GetFollowersCount]     
(    
@tripKey INT    
)    
AS     
BEGIN     
DECLARE @tripSavedKey AS UNIQUEIDENTIFIER  
DECLARE @FollowersCount INT  
      
SELECT @tripSavedKey = tripSavedKey FROM TRIP WITH(NOLOCK) WHERE Tripkey =  @tripKey   
  
set @FollowersCount = dbo.udf_GetFollowersCount(@tripSavedKey)      
  
Select @FollowersCount AS FollowerCount  
    
--SELECT COUNT(*) AS FollowerCount FROM Trip WHERE tripSavedKey= @tripSavedKey AND IsWatching = 1     
  
  
  
  
END
GO
