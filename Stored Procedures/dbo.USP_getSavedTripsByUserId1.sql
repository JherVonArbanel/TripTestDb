SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
	AUTHER		:	Gopal N
	CREATED Dt	:	8-Aug-2012
	DESCRIPTION :	Stored procedure to retrieve all saved trips (Air/Car/Hotel) of particular user
	EXECUTION	:   [USP_getSavedTripsByUserId] @userId = 559865, @Limit = 5
*/
CREATE PROCEDURE [dbo].[USP_getSavedTripsByUserId1] 
(          
	@userId INT,
	@Limit	INT
)          
AS 
BEGIN 

	DECLARE @sql VARCHAR(8000)

	DECLARE @Tripdetails AS TABLE 
	(
		tripKey				INT,
		siteKey				INT,
		tripSavedKey		UNIQUEIDENTIFIER,
		StartDate			DATETIME,
		EndDate				DATETIME,
		Origin				VARCHAR(200),
		Destination			VARCHAR(200),
		CreatedOn			DATETIME,
		tripComponentType	SMALLINT,
		tripComponents		VARCHAR(50)
	)	
	
	IF isnull(@Limit,0) > 0
	begin
		SET @sql = '
			SELECT TOP '+ CONVERT(VARCHAR, @Limit) +' * 
			FROM
			(
				SELECT DISTINCT T.tripKey, T.siteKey, T.tripSavedKey, TR.tripFromDate1 AS StartDate, TR.tripToDate1 AS EndDate
					, DepCity.CityName AS Origin
					, ArrCity.CityName AS Destination, T.CreatedDate AS CreatedOn, T.tripComponentType
					,	CASE 
							WHEN T.tripComponentType = 1 THEN ''Air''
							WHEN T.tripComponentType = 2 THEN ''Car''
							WHEN T.tripComponentType = 3 THEN ''Air,Car''
							WHEN T.tripComponentType = 4 THEN ''Hotel''
							WHEN T.tripComponentType = 5 THEN ''Air,Hotel''
							WHEN T.tripComponentType = 6 THEN ''Car,Hotel''
							WHEN T.tripComponentType = 7 THEN ''Air,Car,Hotel''
						END AS tripComponents
				FROM Trip T
					INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND T.userKey = '+ CONVERT(VARCHAR, @userId) +'
						 AND T.tripSavedKey IS NOT NULL AND T.tripPurchasedKey IS NULL
					INNER JOIN TripAirResponse TA ON T.tripsavedKey = TA.tripGUIDKey AND ISNULL(TA.isDeleted, 0) = 0 
					LEFT OUTER JOIN AirportLookup DepCity ON TR.tripFrom1 = DepCity.AirportCode
					LEFT OUTER JOIN AirportLookup ArrCity ON TR.tripTo1 = ArrCity.AirportCode
			) A ORDER BY tripKey DESC'
		 
		PRINT @sql
	
	end
	else
	begin
	SET @sql = '
		SELECT * 
		FROM
		(
			SELECT DISTINCT T.tripKey, T.siteKey, T.tripSavedKey, TR.tripFromDate1 AS StartDate, TR.tripToDate1 AS EndDate
				, DepCity.CityName AS Origin
				, ArrCity.CityName AS Destination, T.CreatedDate AS CreatedOn, T.tripComponentType
				,	CASE 
						WHEN T.tripComponentType = 1 THEN ''Air''
						WHEN T.tripComponentType = 2 THEN ''Car''
						WHEN T.tripComponentType = 3 THEN ''Air,Car''
						WHEN T.tripComponentType = 4 THEN ''Hotel''
						WHEN T.tripComponentType = 5 THEN ''Air,Hotel''
						WHEN T.tripComponentType = 6 THEN ''Car,Hotel''
						WHEN T.tripComponentType = 7 THEN ''Air,Car,Hotel''
					END AS tripComponents
			FROM Trip T
				INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND T.userKey = '+ CONVERT(VARCHAR, @userId) +'
					 AND T.tripSavedKey IS NOT NULL AND T.tripPurchasedKey IS NULL
				INNER JOIN TripAirResponse TA ON T.tripsavedKey = TA.tripGUIDKey AND ISNULL(TA.isDeleted, 0) = 0 
				LEFT OUTER JOIN AirportLookup DepCity ON TR.tripFrom1 = DepCity.AirportCode
				LEFT OUTER JOIN AirportLookup ArrCity ON TR.tripTo1 = ArrCity.AirportCode
		) A ORDER BY tripKey DESC'
	 
	PRINT @sql
	
	end

	INSERT INTO @Tripdetails(tripKey, siteKey, tripSavedKey, StartDate, EndDate, Origin, Destination, CreatedOn, tripComponentType, tripComponents)
	EXEC(@sql)
	 
	DECLARE @deal table
	(
		TripSavedDealKey	INT,
		tripKey				INT,
		componentType		INT
	)

	INSERT INTO @deal
	SELECT MAX(TSD.TripSavedDealKey) TripSavedDealKey, TSD.tripKey, TSD.componentType
	FROM TripSavedDeals TSD 
		INNER JOIN @Tripdetails T ON TSD.tripKey = T.tripKey
	GROUP BY TSD.TripKey, TSD.componentType
	ORDER BY TSD.TripKey, TSD.componentType
	

	SELECT T.tripKey, T.tripSavedKey, T.StartDate, T.EndDate, T.Origin, T.Destination, T.CreatedOn, T.tripComponentType, T.tripComponents, 
		SUM(TSD.currentTotalPrice) currentTotalPrice, SUM(TSD.originalTotalPrice) originalTotalPrice,
		'http://auction.its-qa.com/Content/Images/Destination/1/280px-SF_From_Marin_Highlands3.png' DestinationImageURL,
		SC.siteName + '/travel/cart/savetrip?id=' + CONVERT(VARCHAR, T.tripKey)  SavedTripURL,
		(SUM(TSD.originalTotalPrice) - SUM(TSD.currentTotalPrice)) AS TotalSaving,
		T.CreatedOn watchedTripDate
	FROM @Tripdetails T
		INNER JOIN Vault..SiteConfiguration SC ON T.siteKey = SC.siteKey
		INNER JOIN @deal D ON T.tripKey = D.tripKey
		INNER JOIN TripSavedDeals TSD ON D.TripSavedDealKey = TSD.TripSavedDealKey
	GROUP BY T.tripKey, T.siteKey, T.tripSavedKey, T.StartDate, T.EndDate, T.Origin, T.Destination, T.CreatedOn, T.tripComponentType, 
		T.tripComponents, SC.siteName
	
END
GO
