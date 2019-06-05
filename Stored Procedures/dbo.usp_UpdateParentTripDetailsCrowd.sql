SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[usp_UpdateParentTripDetailsCrowd]
(
	@parentTripKey INT,
	@tripsavedKey UNIQUEIDENTIFIER
)
AS
BEGIN

DECLARE @parentTripSavedKey  UNIQUEIDENTIFIER,
		@SplitFollowersCount INT

SELECT @parentTripSavedKey = tripSavedKey FROM Trip WHERE tripKey = @parentTripKey 

--SELECT @SplitFollowersCount = COUNT(1) FROM Trip where tripSavedKey = @parentTripSavedKey AND IsWatching = 1

SELECT @SplitFollowersCount =  dbo.udf_GetCrowdCount(@parentTripSavedKey)

Update TripSaved 
SET  
	parentSaveTripKey = @parentTripSavedKey,
	SplitFollowersCount =  @SplitFollowersCount
where 
tripSavedKey = @tripsavedKey 


UPDATE T
SET FollowersCount = @SplitFollowersCount + 1
FROM Trip T
WHERE tripSavedKey = @tripsavedKey

END

GO
