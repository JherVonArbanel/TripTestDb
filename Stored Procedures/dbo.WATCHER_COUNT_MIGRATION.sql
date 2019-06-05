SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WATCHER_COUNT_MIGRATION]
(
	@siteKey  INT 
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @SelectedCrowd AS TABLE 
	(
	CrowdId BIGINT
	)

	DECLARE @WatchersCount AS TABLE 
	(
		tripSavedKey UNIQUEIDENTIFIER,
		WatchersCount INT,
		CrowdId BIGINT		
	)
	DECLARE @TripDetails AS TABLE
	(
		tripKey INT,
		CrowdId BIGINT
	)

		
	INSERT @SelectedCrowd 
	SELECT DISTINCT CrowdId FROM TripDetails WITH (NOLOCK)
	WHERE CrowdId IS NOT NULL	
	
	
	INSERT INTO @TripDetails
	SELECT tripKey, CrowdId FROM TripDetails WITH (NOLOCK)


	INSERT INTO @WatchersCount
	(
		CrowdId,
		WatchersCount
	)
	SELECT 
		TD.CrowdId,			
		COUNT(TD.CrowdId) as  watchersCount		
	FROM @SelectedCrowd SC 
	INNER JOIN  
	TripSaved TD WITH(NOLOCK) ON TD.CrowdId = SC.CrowdId
	INNER JOIN Trip T WITH (NOLOCK) ON TD.tripSavedKey = T.tripSavedKey 	
	where 
		T.siteKey = @siteKey
	and 
		T.tripStatusKey <> 17
	AND 
		T.IsWatching = 1 	 
	Group by 
		TD.CrowdId

	
	SELECT * FROM @WatchersCount


	UPDATE T
		SET CrowdCount = WC.WatchersCount
	FROM Trip T WITH(NOLOCK)
		INNER JOIN @TripDetails TD   ON T.tripKey = TD.tripKey				
		INNER JOIN @WatchersCount WC  ON TD.CrowdId = WC.CrowdId

	SET NOCOUNT OFF

END
GO
