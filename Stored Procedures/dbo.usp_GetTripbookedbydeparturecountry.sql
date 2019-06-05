SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_GetTripbookedbydeparturecountry]

AS

BEGIN
/****** Booking by departure country******/
  select DISTINCT TYPE='Booking by departure country' ,CountryLookup.CountryName from TripAirSegments inner join AirportLookup on TripAirSegments.airSegmentDepartureAirport =AirportLookup.AirportCode 
  inner join TripAirlegs on TripAirlegs.tripAirLegsKey  =TripAirSegments.tripAirLegsKey 
  inner join Trip on trip.tripKey  =TripAirlegs.tripKey  inner join vault.[dbo].CountryLookup on AirportLookup.CountryCode  =CountryLookup.CountryCode     where trip.tripStatusKey =4
	        
 END

GO
