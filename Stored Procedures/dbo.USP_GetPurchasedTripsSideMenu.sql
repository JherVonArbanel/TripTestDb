SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Rajkumar
-- Create date: 26-Oct-2015
-- Description:	Get purchase trip with in 2 weeks
-- =============================================

CREATE PROCEDURE [dbo].[USP_GetPurchasedTripsSideMenu] 
	@UserKey int,
	@SiteKey int
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT Top 1 T.[tripKey]          
		 ,startDate           
		, TR.tripFrom1, TR.tripTo1 
		,DEP.CityName as FromCity
		,ARR.CityName as ToCity 
		,CASE           
		WHEN T.[tripComponentType] = 1 THEN 'Air'          
		WHEN T.[tripComponentType] = 2 THEN 'Car'          
		WHEN T.[tripComponentType] = 3 THEN 'Air,Car'          
		WHEN T.[tripComponentType] = 4 THEN 'Hotel'          
		WHEN T.[tripComponentType] = 5 THEN 'Air,Hotel'          
		WHEN T.[tripComponentType] = 6 THEN 'Car,Hotel'          
		WHEN T.[tripComponentType] = 7 THEN 'Air,Car,Hotel'          
		END AS tripComponents,
		dbo.udf_GetCrowdCount(tripSavedKey) as followercount
		
		
	FROM [Trip] T WITH(NOLOCK)            
	--INNER JOIN  @tblPurchase R ON R.TripKey = T.[tripKey]            
	INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey            
	LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode      
	LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode
	--LEFT JOIN vault..CountryLookup CL WITH(NOLOCK) ON ARR.CountryCode = CL.CountryCode       
	--LEFT JOIN loyalty.dbo.pendingpoints P WITH(NOLOCK) on T.tripKey = P.tripId  AND P.UserId = T.userKey  
	--LEFT JOIN [Loyalty].[dbo].[PendingPointsHistory] PP ON T.tripKey = PP.tripId AND PP.IsConverted = 1 AND PP.UserID = T.userKey 
	WHERE 
	T.UserKey = @UserKey AND 
	T.SiteKey = @SiteKey            
	AND recordLocator IS NOT NULL AND recordLocator <> ''            
	AND tripPurchasedKey IS NOT NULL            
	-- AND (tripStatusKey = 2 OR tripStatusKey = 1 OR tripStatusKey = 15 OR tripStatusKey =5) commented to remove cancelled trip from side menu as per discussed with zarir (user story 14811, 18535)
	AND (tripStatusKey = 2 OR tripStatusKey = 1 OR tripStatusKey = 15) -- 1 = Pending | 2 = Purchased | 15 = Partial 
	And T.startDate >= GETDATE()
	And DATEDIFF(wk,GETDATE(),t.startdate) <=2
	Order by T.startDate ASC
END
GO
