SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
	AUTHER		:	Gopal N
	CREATED Dt	:	8-Aug-2012
	DESCRIPTION :	Stored procedure to retrieve all recent trips (Air/Car/Hotel) of particular user
	EXECUTION	:   USP_getRecentTripsByUserId @USERKEY = 559865
*/
CREATE PROCEDURE [dbo].[USP_getRecentTripsByUserId]
(          
	@USERKEY INT
) 
AS 
BEGIN 

	SELECT DISTINCT TOP 10 TR.tripRequestKey, DepCity.CityName AS Origin, ArrCity.CityName AS Destination, 
		TR.tripFromDate1 AS [DepartureDate], TR.tripToDate1 AS [ArrivalDate], TR.tripRequestCreated, TR.tripComponentType
		,	CASE 
				WHEN TR.tripComponentType = 1 THEN 'Air'
				WHEN TR.tripComponentType = 2 THEN 'Car'
				WHEN TR.tripComponentType = 3 THEN 'Air,Car'
				WHEN TR.tripComponentType = 4 THEN 'Hotel'
				WHEN TR.tripComponentType = 5 THEN 'Air,Hotel'
				WHEN TR.tripComponentType = 6 THEN 'Car,Hotel'
				WHEN TR.tripComponentType = 7 THEN 'Air,Car,Hotel'
			END AS tripComponents
	FROM TRIPREQUEST TR 
		LEFT OUTER JOIN AirportLookup DepCity ON TR.tripFrom1 = DepCity.AirportCode
		LEFT OUTER JOIN AirportLookup ArrCity ON TR.tripTo1 = ArrCity.AirportCode
	WHERE TR.userKey = @USERKEY
	ORDER BY TR.tripRequestCreated DESC

END
GO
