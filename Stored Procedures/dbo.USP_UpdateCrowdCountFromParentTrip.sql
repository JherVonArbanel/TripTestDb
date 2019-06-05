SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  <Pradeep Gupta>    
-- Create date: <05-apr-16>    
-- Description: <this sp is used, when you  follow a crowd from tripsummary page, reason for adding this is becuase of TFS#16414, you need to update tripsavedkey, parenttripsaved key and crowdId for addding people to the crowd>  
/*you need to update parentSaveTripKey, CrowdId in tripsaved, tripdetails table. after that you need to update followercount and crowdcount.*/    
-- =============================================    
  
--exec USP_UpdateCrowdCountFromParentTrip 28877,28873,560799  
CREATE PROCEDURE [dbo].[USP_UpdateCrowdCountFromParentTrip]    
    
@NewTripKey INT = 0,    
@ParentTripKey INT = 0,    
@UserKey bigint = 0    
     
AS    
BEGIN    
  
DECLARE @NewTripSavedKey AS  UNIQUEIDENTIFIER   
DECLARE @ParentTripSavedKey AS  UNIQUEIDENTIFIER   
DECLARE @ParentCrowdId BIGINT  
DECLARE @ParentCrowdCount INT  
DECLARE @ParentFollowerCount INT  
     
SELECT @NewTripSavedKey = tripSavedKey FROM Trip..Trip WHERE tripKey=@NewTripKey    
SELECT @ParentTripSavedKey = tripSavedKey FROM Trip..Trip WHERE tripKey=@ParentTripKey    
SELECT @ParentCrowdId = CrowdId FROM Trip..TripDetails WHERE tripKey=@ParentTripKey    

IF((SELECT userkey FROM Trip WHERE tripkey = @NewTripKey ) = 0)
BEGIN

	UPDATE Trip..Trip set userkey = @UserKey  WHERE tripkey=@NewTripKey

	UPDATE Trip..TripDetails set userkey  = @UserKey  WHERE tripkey=@NewTripKey

	UPDATE Trip..TripSaved set userkey = @UserKey , crowdid = @ParentCrowdId  WHERE tripSavedKey = @NewTripSavedKey

END

    
--print  @NewTripSavedKey  
UPDATE trip..TripSaved  SET parentSaveTripKey=@ParentTripSavedKey, CrowdId=@ParentCrowdId    
WHERE tripSavedKey =@NewTripSavedKey AND userKey=@UserKey    
  --print '1st time'+ convert(varchar(50), @@ROWCOUNT)  
    
    
UPDATE trip..TripDetails SET CrowdId=@ParentCrowdId WHERE tripKey=@NewTripKey    
--print '2nd time'+ convert(varchar(50), @@ROWCOUNT)  
    
SET @ParentFollowerCount = dbo.udf_GetCrowdCount(@ParentTripSavedKey)  
  
  
UPDATE trip..Trip SET FollowersCount=@ParentFollowerCount , CrowdCount= @ParentFollowerCount    
WHERE tripkey =@NewTripKey     
  --print '3rd time'+ convert(varchar(50), @@ROWCOUNT)  
    
UPDATE trip..TripSaved  SET SplitFollowersCount= @ParentFollowerCount    
WHERE tripSavedKey =@NewTripSavedKey AND userKey=@UserKey    
  --print '4th time'+ convert(varchar(50), @@ROWCOUNT)  
    
    
EXEC USP_UpdateTripCrowdCount @ParentTripKey    
--print '5th time'+ convert(varchar(50), @@ROWCOUNT)  
  
IF @@ROWCOUNT > 0  
BEGIN  
select @NewTripKey as [Tripkey]  
END  
ELSE  
BEGIN  
select 0 as [Tripkey]  
END  
  
  
END
GO
