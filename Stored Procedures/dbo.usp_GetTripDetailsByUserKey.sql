SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--[usp_GetTripDetails_New] 1666,0

CREATE PROCEDURE [dbo].[usp_GetTripDetailsByUserKey]  
 @userKey AS INT
AS 

	DECLARE @tripID   INT 
	DECLARE  @tripRequestID INT = 0
	DECLARE @tblTrip AS TABLE
	(
		tripKey INT,
		RequestKey INT
	)

	SET @tripID = ( SELECT tripKey FROM Trip WHERE userKey = @userKey )

	IF(@tripRequestID IS NULL OR @tripRequestID = 0) 
	BEGIN
		INSERT INTO @tblTrip
		SELECT  @tripID, tripRequestKey FROM Trip WHERE tripKey  = @tripID
	END
	ELSE 
	BEGIN
		INSERT INTO @tblTrip
		SELECT tripKey, tripRequestKey FROM Trip WHERE tripRequestKey = @tripRequestID
	END

	DECLARE @tblUser AS TABLE
	(
		UserKey INT,
		UserFirst_Name NVARCHAR(200),
		UserLast_Name NVARCHAR(200),
		User_Login NVARCHAR(50) ,
		companyKey INT 
	)

	INSERT INTO @tblUser 
	SELECT DISTINCT U.userKey, U.userFirstName, U.userLastName, U.userLogin, U.companyKey 
	FROM Vault.dbo.[User] U 
		INNER JOIN Trip T ON U.userKey = T.userKey 
		INNER JOIN @tblTrip tt ON tt.tripKey = T.tripKey 

	SELECT Trip.*, vault.dbo.Agency.agencyKey AS Agency_ID, U.* 
	FROM Trip 
		INNER JOIN vault.dbo.Agency ON trip.agencyKey = Agency.agencyKey 
		INNER JOIN @tblUser U ON Trip.userKey = U.UserKey 
		INNER JOIN @tblTrip tt ON tt.tripKey = Trip.tripKey 
	ORDER BY tripKey 

	SELECT DISTINCT T.tripKey, segments.* , legs.gdsSourceKey, departureAirport.AirportName AS departureAirportName, 
		departureAirport.CityCode AS departureAirportCityCode, departureAirport.StateCode AS departureAirportStateCode, 
		departureAirport.CountryCode AS departureAirportCountryCode, arrivalAirport.AirportName AS arrivalAirportName, 
		arrivalAirport.CityCode AS arrivalAirportCityCode, arrivalAirport.StateCode AS arrivalAirportStateCode, 
		arrivalAirport.CountryCode AS arrivalAirportCountryCode, legs.recordLocator, AirResp.actualAirPrice,  
		AirResp.actualAirTax, AirResp.airResponseKey, 
		ISNULL(airven.ShortName, segments.airSegmentMarketingAirlineCode) AS MarketingAirLine,airSegmentOperatingAirlineCode, 
		ISNULL (airOperatingven.ShortName, segments.airSegmentOperatingAirlineCode) AS OperatingAirLine,
		ISNULL(airSelectedSeatNumber, 0) AS SeatNumber, segments.ticketNumber AS TicketNumber, 
		segments.airsegmentcabin AS airsegmentcabin, AirResp.isExpenseAdded 
	FROM TripAirSegments segments 
		INNER JOIN TripAirLegs legs ON (segments.tripAirLegsKey = segments.tripAirLegsKey AND segments.airResponseKey = legs.airResponseKey 
			AND segments.airLegNumber = legs.airLegNumber)
		INNER JOIN TripAirResponse AirResp ON segments.airResponseKey = AirResp.airResponseKey 
		INNER JOIN Trip t ON AirResp.tripKey = t.tripKey 
		INNER JOIN @tblTrip tt ON tt.tripKey = t.tripKey 
		LEFT OUTER JOIN AirVendorLookup airVen ON segments.airSegmentMarketingAirlineCode = airVen.AirlineCode 
		LEFT OUTER JOIN AirVendorLookup airOperatingVen ON segments.airSegmentOperatingAirlineCode = airOperatingVen.AirlineCode 
		LEFT OUTER JOIN AirportLookup departureAirport ON departureAirport.AirportCode = segments.airSegmentdepartureAirport 
		LEFT OUTER JOIN AirportLookup arrivalAirport ON arrivalAirport.AirportCode = segments.airSegmentarrivalAirport 
	ORDER BY T.tripKey, segments.airSegmentDepartureDate   

	SELECT hotel.* 
	FROM vw_TripHotelResponse hotel    
		INNER JOIN trip t ON hotel.tripKey = t.tripKey  
		INNER JOIN @tblTrip tt ON tt.tripKey = t.tripKey 
		INNER JOIN vault.dbo.[User] U ON t.userKey = U.userKey 
	ORDER BY t.tripKey
  
	SELECT * 
	FROM vw_TripCarResponse car 
		INNER JOIN trip t ON car.tripKey = t.tripKey 
		INNER JOIN @tblTrip tt ON tt.tripKey = t.tripKey 
		INNER JOIN vault.dbo.[User] U ON t.userKey = U.userKey 
	ORDER BY t.tripKey


	SELECT TAVP.* 
	FROM TripPassengerInfo TPI 
		INNER JOIN  TripPassengerAirVendorPreference TAVP ON TPI.TripKey = TAVP.TripKey 
	WHERE TPI.TripKey = @tripID AND TPI.Active = 1 AND TAVP.Active = 1 
	ORDER BY TPI.TripKey

	SELECT COUNT(GeneratedType) AS NoOfRemarks, GeneratedType, TPR.TripKey  
	FROM TripPNRRemarks TPR 
		INNER JOIN @tblTrip tt ON TPR.tripKey = tt.tripKey 
		INNER JOIN Trip T ON tt.tripKey  = T.TripKey
	WHERE TPR.Active= 1 AND T.tripStatusKey = 2 AND  DATEDIFF(DAY, CreatedOn, GETDATE()) <= 1 
	GROUP BY GeneratedType, TPR.TripKey
GO
