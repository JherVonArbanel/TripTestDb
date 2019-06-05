SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Jayant Guru
-- Create date: 31st July 2013
-- Description:	This stored procedure gets air segment data from tripAirSegment table
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAirSegmentFromTripAirSegment]
	-- Add the parameters for the stored procedure here
	@AirSegmentKey UNIQUEIDENTIFIER
AS
BEGIN
	
	SET NOCOUNT ON;
	
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
		
	WHERE airsegmentKey = @airSegmentKey 
	ORDER BY airSegmentDepartureDate
	
	SELECT TP.TravelReferenceNo, TAS.*
	FROM TripAirSegmentPassengerInfo TAS WITH(NOLOCK)
		INNER JOIN TripAirSegments TA WITH(NOLOCK) ON TA.tripAirSegmentkey = TAS.tripAirSegmentkey
		INNER JOIN TripPassengerInfo TP WITH(NOLOCK) ON TP.tripPassengerInfoKey = TAS.tripPassengerInfoKey
		AND TA.airsegmentKey = @airSegmentKey
	
	
END


GO
