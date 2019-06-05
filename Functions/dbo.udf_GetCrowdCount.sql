SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 19th May 2013
-- Description:	<Function used to get Follower's count on basis of SaveTripKey>
-- =============================================
CREATE FUNCTION [dbo].[udf_GetCrowdCount]
(
	-- Add the parameters for the function here
	@tripSavedKey UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
 --Commented as followercount calculation is based on crowd id now onwards------
	-- Declare the return variable here
	
	--- Implementation for crowd based follower counts
	DECLARE @crowdId AS BIGINT 
	DECLARE @FollowersCount INT
	DECLARE @SplitFollowersCount INT
	
	SELECT @crowdId = crowdId FROM TripSaved WITH(NOLOCK) 
	WHERE tripSavedKey = @tripSavedKey
	
	--SELECT @FollowersCount = COUNT(tripKey) 
	--FROM Trip T WITH(NOLOCK) 
	--INNER JOIN TripSaved TS WITH(NOLOCK) 
	--ON T.tripSavedKey = TS.tripSavedKey 
	--WHERE T.IsWatching = 1 
	--AND Ts.crowdId = @crowdId GROUP BY crowdId 
	
	--select  @FollowersCount = SplitFollowersCount from TripSaved  WHERE tripSavedKey = @tripSavedKey
	
SELECT  @FollowersCount=  COUNT(distinct(t.userKey))
	FROM Trip T WITH(NOLOCK) 
	INNER  JOIN TripSaved TS WITH(NOLOCK) 
	ON T.tripSavedKey = TS.tripSavedKey 
	WHERE T.IsWatching = 1 
	AND Ts.crowdId = @crowdId 
	
	
	
	
	
	RETURN  @FollowersCount 
	
	--- End implementation

END

GO
