SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 6th Jan 2014
-- Description:	Get trip details to reprice Original Price
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripSavedForOriginalReprice]
	@componentType INT
	,@siteKey INT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	IF(@componentType = 1) --FOR AIR
	BEGIN
		SELECT 
		AR.TripSavedKey
		,AR.UserKey
		,AR.TripKey
		FROM AirRequestTripSavedDeal AR 
		INNER JOIN Trip T 
		ON AR.TripKey = T.tripKey 
		INNER JOIN TripSaved TS 
		ON (T.tripSavedKey = TS.tripSavedKey AND T.userKey = TS.userKey)
		AND (T.tripStatusKey <> 1 
			AND T.tripStatusKey <> 2 
			AND T.tripStatusKey <> 3
			AND T.tripStatusKey <> 4
			AND T.tripStatusKey <> 17)
		AND T.siteKey = @siteKey
	END
	ELSE IF(@componentType = 4) --FOR HOTEL
	BEGIN
		SELECT 
		HR.TripSavedKey
		,HR.UserKey
		,HR.TripKey
		FROM HotelRequestTripSavedDeal HR 
		INNER JOIN Trip T
		ON HR.TripKey = T.tripKey 
		INNER JOIN TripSaved TS 
		ON (T.tripSavedKey = TS.tripSavedKey AND T.userKey = TS.userKey)
		AND (T.tripStatusKey <> 1 
			AND T.tripStatusKey <> 2 
			AND T.tripStatusKey <> 3
			AND T.tripStatusKey <> 4
			AND T.tripStatusKey <> 17)
		AND T.siteKey = @siteKey	
	END
		
END
GO
