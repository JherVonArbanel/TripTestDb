SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Samir Dedhia>
-- Create date: <03-Dec-2013>
-- Description:	<Function used to get Follower's count on basis of SaveTripKey>
-- =============================================
CREATE FUNCTION [dbo].[udf_GetFollowersCount]
(
	-- Add the parameters for the function here
	@tripSavedKey UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @FollowersCount INT,
			@SplitFollowersCount INT


	
	SELECT @SplitFollowersCount = ISNULL(SplitFollowersCount,0) FROM TripSaved
	WHERE tripSavedKey = @tripSavedKey			

	

	-- Add the T-SQL statements to compute the return value here
	SELECT 
		@FollowersCount = COUNT(1) 
	FROM 
		Trip
	WHERE 
		IsWatching = 1
	AND 
		tripSavedKey = @tripSavedKey     



	-- Return the result of the function
	RETURN @SplitFollowersCount + @FollowersCount

END
GO
