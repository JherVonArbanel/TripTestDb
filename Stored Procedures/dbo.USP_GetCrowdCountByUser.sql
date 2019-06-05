SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Rajkumar
-- Create date: 07-Dec-2015
-- Description:	Get Crowd Count of the User
-- =============================================

CREATE PROCEDURE [dbo].[USP_GetCrowdCountByUser]
	@UserId int,
	@SiteKey int
AS
BEGIN
	
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 --SELECT COUNT(DISTINCT CrowdId) as CrowdCount FROM TripDetails TD WITH(NOLOCK) 
	 --INNER JOIN Trip T WITH(NOLOCK) On (TD.tripKey=T.tripKey AND T.siteKey=@siteKey	AND TD.userKey =@UserId 
	 --AND T.isUserCreatedSavedTrip =1 AND T.tripSavedKey is not null AND T.IsWatching = 1)      
	 -- SELECT COUNT(DISTINCT CrowdId) as CrowdCount FROM TripSaved TS WITH(NOLOCK) 
	 --INNER JOIN Trip T WITH(NOLOCK) On (TS.tripSavedKey = T.tripSavedKey AND T.siteKey=@SiteKey AND TS.userKey = @UserId
	 --AND T.isUserCreatedSavedTrip =1 AND T.tripSavedKey is not null AND T.IsWatching = 1) 
	 
	 SELECT COUNT(DISTINCT T.tripKey) as CrowdCount 
	 FROM Trip T WITH(NOLOCK) 
	 WHERE T.userKey = @UserId AND T.isUserCreatedSavedTrip =1 AND T.tripSavedKey is not null 
		AND T.IsWatching = 1 AND T.siteKey = @SiteKey 
END
GO
