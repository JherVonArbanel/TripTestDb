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
CREATE PROCEDURE [dbo].[USP_getRecentTripsByUserId_bak]
(          
	@USERKEY INT
) 
AS 
BEGIN 

	DECLARE @RecentSearch TABLE 
	(
		[ServiceType] [varchar] (10),
		tripRequestKey INT,
		RequestKey INT,
		[airRequestKey] INT,
		hotelRequestKey INT,
		CarRequestKey INT,
		[Origin] [varchar](50),
		[Destination] [varchar](50),
		[DepartureDate] [datetime],
		[ArrivalDate] [datetime],
		tripRequestCreated [datetime] NOT NULL
	)

	DECLARE @TRIPREQUEST TABLE
	(
		tripRequestKey	INT,
		userKey	INT,
		tripRequestCreated	DATETIME
	)

	INSERT INTO @TRIPREQUEST (tripRequestKey, userKey, tripRequestCreated)
	SELECT TOP 10 tripRequestKey, userKey, tripRequestCreated FROM TRIPREQUEST WHERE USERKEY = @USERKEY ORDER BY tripRequestCreated DESC

	DECLARE @AirSubRequest TABLE 
	(
		tripRequestKey INT,
		[airSubRequestKey] [int],
		[airRequestKey] [int],
		[airRequestDepartureAirport] [varchar](50) NOT NULL,
		[airRequestArrivalAirport] [varchar](50) NOT NULL,
		[airRequestDepartureDate] [datetime] NOT NULL,
		[airRequestArrivalDate] [datetime],
		[airSubRequestLegIndex] [int] NULL,
		tripRequestCreated [datetime] NOT NULL
	)

	--Round Trip
	INSERT INTO @AirSubRequest (tripRequestKey, airSubRequestKey, airRequestKey, airRequestDepartureAirport, airRequestArrivalAirport, 
		airRequestDepartureDate, airRequestArrivalDate, airSubRequestLegIndex,tripRequestCreated)
	SELECT TR.tripRequestKey, ASR.airSubRequestKey, ASR.airRequestKey, airRequestDepartureAirport, airRequestArrivalAirport, 
		airRequestDepartureDate, airRequestArrivalDate, airSubRequestLegIndex,TR.tripRequestCreated
	FROM AirSubRequest ASR
			INNER JOIN TripRequest_Air TRA ON TRA.airRequestKey = ASR.airRequestKey
			INNER JOIN @TRIPREQUEST TR ON TR.tripRequestKey = TRA.tripRequestKey AND airSubRequestLegIndex = -1 --AND USERKEY = @USERKEY 

	--One Way
	INSERT INTO @AirSubRequest (tripRequestKey,airSubRequestKey, airRequestKey, airRequestDepartureAirport, airRequestArrivalAirport, 
		airRequestDepartureDate, airRequestArrivalDate, airSubRequestLegIndex, tripRequestCreated)
	SELECT TR.tripRequestKey, ASR.airSubRequestKey, ASR.airRequestKey, airRequestDepartureAirport, airRequestArrivalAirport, 
		airRequestDepartureDate, airRequestArrivalDate, airSubRequestLegIndex, TR.tripRequestCreated
	FROM AirSubRequest ASR
			INNER JOIN TripRequest_Air TRA ON TRA.airRequestKey = ASR.airRequestKey
			INNER JOIN @TRIPREQUEST TR ON TR.tripRequestKey = TRA.tripRequestKey --AND USERKEY = @USERKEY
	WHERE  airSubRequestLegIndex = 1 AND ASR.airRequestKey NOT IN (SELECT airRequestKey FROM @AirSubRequest)

	INSERT INTO @RecentSearch ([ServiceType], tripRequestKey, RequestKey, airRequestKey, [Origin], [Destination], [DepartureDate], 
		[ArrivalDate], tripRequestCreated)
	SELECT  'AIR', tripRequestKey, airRequestKey, airRequestKey, DepCity.CityName, ArrCity.CityName, [airRequestDepartureDate], 
		[airRequestArrivalDate], tripRequestCreated 
	FROM @AirSubRequest A
		LEFT OUTER JOIN AirportLookup DepCity ON A.[airRequestDepartureAirport] = DepCity.AirportCode
		LEFT OUTER JOIN AirportLookup ArrCity ON A.[airRequestArrivalAirport] = ArrCity.AirportCode
	ORDER BY 2 desc

	INSERT INTO @RecentSearch ([ServiceType], tripRequestKey, RequestKey, hotelRequestKey, [Origin], [Destination], [DepartureDate], 
		[ArrivalDate], tripRequestCreated)
	SELECT 'HOTEL',TR.tripRequestKey, HR.hotelRequestKey, HR.hotelRequestKey, '' Origin, DepCity.CityName, checkInDate, checkOutDate, 
		TR.tripRequestCreated
	FROM HotelRequest  HR
		INNER JOIN TripRequest_Hotel TRH ON TRH.hotelRequestKey = HR.hotelRequestKey
		INNER JOIN @TRIPREQUEST TR ON TR.tripRequestKey = TRH.tripRequestKey --AND USERKEY = @USERKEY
		LEFT OUTER JOIN AirportLookup DepCity ON HR.hotelCityCode = DepCity.AirportCode
	
	INSERT INTO @RecentSearch ([ServiceType], tripRequestKey, RequestKey, CarRequestKey, [Origin], [Destination], [DepartureDate], 
		[ArrivalDate], tripRequestCreated)
	SELECT 'CAR', TR.tripRequestKey, CR.carRequestKey, CR.carRequestKey, DepCity.CityName, ArrCity.CityName, pickupDate, dropoffDate, 
		TR.tripRequestCreated
	FROM CarRequest  CR
		INNER JOIN TripRequest_car TRC ON TRC.carRequestKey = CR.carRequestKey
		INNER JOIN @TRIPREQUEST TR ON TR.tripRequestKey = TRC.tripRequestKey --AND USERKEY = @USERKEY
		LEFT OUTER JOIN AirportLookup DepCity ON CR.pickupCityCode = DepCity.AirportCode
		LEFT OUTER JOIN AirportLookup ArrCity ON CR.dropoffCityCode = ArrCity.AirportCode

	SELECT * FROM @RecentSearch ORDER BY tripRequestCreated DESC

END
GO
