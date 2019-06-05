SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AirResponse_GET_TripID]
(
	@tripKey		INT,
	@airResponseKey	UNIQUEIDENTIFIER = NULL,
	@LegIndex		INT = NULL,
	@OrderOfExec	INT
)
AS
BEGIN

	IF @OrderOfExec = -1
	BEGIN
		SELECT * 
		FROM AirResponse 
			LEFT OUTER JOIN Trip_airResponse ON Trip_airResponse.airResponseKey = AirResponse.airResponseKey 
		WHERE tripKey = @tripKey 
		ORDER BY airlegnumber ASC
	END
	ELSE IF @OrderOfExec = 0
	BEGIN
		SELECT 
			AirSegments.airSegmentKey, airResponseKey, airLegNumber, airSegmentMarketingAirlineCode, airSegmentOperatingAirlineCode, 
			airSegmentResBookDesigCode, airSegmentFlightNumber, airSegmentDuration, airSegmentEquipment, airSegmentMiles, 
			airSegmentDepartureDate, airSegmentArrivalDate, airSegmentDepartureAirport, DepartureAirport.AirportName AS DepartureAirportName, 
			DepartureAirport.CityCode AS DepartureAirportCityCode, DepartureAirport.StateCode AS DepartureAirportStateCode, 
			DepartureAirport.CountryCode AS DepartureAirportCountryCode, airSegmentArrivalAirport,
			ArrivalAirport.AirportName AS ArrivalAirportName, ArrivalAirport.CityCode AS ArrivalAirportCityCode, 
			ArrivalAirport.StateCode AS ArrivalAirportStateCode, ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,
			airSegmentDepartureOffset, airSegmentArrivalOffset, airSegmentMarriageGrp, 
			(DATEADD(HH, (airSegmentDepartureOffset * -1), airSegmentDepartureDate)) AS EquiairSegmentDepartureDate, seatNumber 
		FROM AirSegments 
			LEFT OUTER JOIN AirportLookup DepartureAirport ON airSegmentDepartureAirport = DepartureAirport.AirportCode  
			LEFT OUTER JOIN AirportLookup ArrivalAirport ON airSegmentArrivalAirport = ArrivalAirport.AirportCode 
			LEFT OUTER JOIN Trip_AirSegmentOptionalServices TAS ON AirSegments.airSegmentKey = TAS.airSegmentKey  
		WHERE airResponseKey = @airResponseKey
		ORDER BY airresponsekey, EquiairSegmentDepartureDate
	END
	ELSE
	BEGIN
		SELECT 
			AirSegments.airSegmentKey, airResponseKey, airLegNumber, airSegmentMarketingAirlineCode, airSegmentOperatingAirlineCode,
			airSegmentResBookDesigCode, airSegmentFlightNumber, airSegmentDuration, airSegmentEquipment, airSegmentMiles,
			airSegmentDepartureDate, airSegmentArrivalDate, airSegmentDepartureAirport, DepartureAirport.AirportName AS DepartureAirportName, 
			DepartureAirport.CityCode AS DepartureAirportCityCode, DepartureAirport.StateCode AS DepartureAirportStateCode, 
			DepartureAirport.CountryCode AS DepartureAirportCountryCode, airSegmentArrivalAirport,
			ArrivalAirport.AirportName AS ArrivalAirportName, ArrivalAirport.CityCode AS ArrivalAirportCityCode, 
			ArrivalAirport.StateCode AS ArrivalAirportStateCode, ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,
			airSegmentDepartureOffset, airSegmentArrivalOffset, airSegmentMarriageGrp,
			(DATEADD(HH, (airSegmentDepartureOffset * -1), airSegmentDepartureDate)) AS EquiairSegmentDepartureDate, seatNumber 
		FROM AirSegments 
			LEFT OUTER JOIN AirportLookup DepartureAirport ON airSegmentDepartureAirport = DepartureAirport.AirportCode  
			LEFT OUTER JOIN AirportLookup ArrivalAirport ON airSegmentArrivalAirport = ArrivalAirport.AirportCode 
			LEFT OUTER JOIN Trip_AirSegmentOptionalServices TAS ON AirSegments.airSegmentKey = TAS.airSegmentKey 
		WHERE airResponseKey = @airResponseKey AND airLegnumber = @LegIndex 
		ORDER BY airresponsekey, EquiairSegmentDepartureDate
	END		
END
GO
