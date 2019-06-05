SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_SilverPop_Trip]
AS

	SELECT T.TripKey TripID, T.tripSavedKey TripSavedId, T.userKey, U.userFirstName, U.userMiddleName, U.userLastName, U.userLogin,
		T.TripStatusKey, TSL.tripStatusName [Status], T.recordLocator PNR, 'To Be Discuss' TotalBaseTripCost, 'To Be Discuss' TotalTripCost,
		T.createdDate WatchDate, S.IsSubscribe IsSubscribed, S.SilverpopModifiedDate
	FROM Trip T
		LEFT OUTER JOIN vault..[user] U ON T.userKey = U.userKey
		INNER JOIN TripStatusLookup TSL ON T.tripStatusKey = TSL.tripStatusKey
		INNER JOIN Loyalty..Subscription S ON T.tripKey = S.tripId AND S.IsSubscribe = 1
GO
