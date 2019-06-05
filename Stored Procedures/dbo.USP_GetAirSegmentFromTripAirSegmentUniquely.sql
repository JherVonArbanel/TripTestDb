SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--EXEC [USP_GetAirSegmentFromTripAirSegmentUniquely] 'BAB0B1E6-28DB-4C62-9051-D02368A17DDA',27464
-- =============================================
-- Author:		Ashima Gupta
-- Create date: 22 Dec 2016
-- Description:	This stored procedure gets air segment data from tripAirSegment table
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAirSegmentFromTripAirSegmentUniquely]
	-- Add the parameters for the stored procedure here
	@AirSegmentKey UNIQUEIDENTIFIER,
	@tripkey INT
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @tripairSegmentkey INT
	SET @tripairSegmentkey = (SELECT tripairsegmentkey FROM TripAirSegments where airResponseKey IN (SELECT airResponsekey FROM TripAirResponse where tripGUIDkey IN (SELECT tripPurchasedKey FROM Trip where tripKey = @tripkey)) AND airSegmentKey = @airsegmentKey)
	SELECT 
		airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentResBookDesigCode,
		airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,
		airSegmentDepartureAirport,DepartureAirport.AirportName AS DepartureAirportName,DepartureAirport.CityName AS DepartureAirportCityName,
		DepartureAirport.StateCode AS DepartureAirportStateCode,DepartureAirport.CountryCode AS DepartureAirportCountryCode,airSegmentArrivalAirport,
		ArrivalAirport.AirportName AS ArrivalAirportName,ArrivalAirport.CityName AS ArrivalAirportCityName,ArrivalAirport.StateCode AS ArrivalAirportStateCode,
		ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentOperatingFlightNumber ,
		MVL.ShortName as airSegmentMarketingAirlineName , airSegmentOperatingAirlineCompanyShortName , OVL.ShortName AS airSegmentOperatingAirlineName
	FROM TripAirSegments WITH(NOLOCK)
		LEFT OUTER JOIN AirportLookup DepartureAirport WITH(NOLOCK) ON airSegmentDepartureAirport = DepartureAirport.AirportCode  
		LEFT OUTER JOIN AirportLookup ArrivalAirport WITH(NOLOCK) ON airSegmentArrivalAirport =ArrivalAirport.AirportCode  
		LEFT OUTER JOIN AirVendorLookup MVL WITH(NOLOCK) ON airSegmentMarketingAirlineCode = MVL.AirlineCode
		LEFT OUTER JOIN AirVendorLookup OVL WITH(NOLOCK) ON airSegmentOperatingAirlineCode = OVL.AirlineCode
		
	WHERE tripAirSegmentKey = @tripairSegmentkey 
	ORDER BY airSegmentDepartureDate
	
	SELECT TP.TravelReferenceNo, TAS.*
	FROM TripAirSegmentPassengerInfo TAS WITH(NOLOCK)
		INNER JOIN TripAirSegments TA WITH(NOLOCK) ON TA.tripAirSegmentkey = TAS.tripAirSegmentkey
		INNER JOIN TripPassengerInfo TP WITH(NOLOCK) ON TP.tripPassengerInfoKey = TAS.tripPassengerInfoKey
		AND TA.tripAirSegmentKey = @tripairSegmentkey
	
	
END
GO
