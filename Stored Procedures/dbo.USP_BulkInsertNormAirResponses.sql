SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_BulkInsertNormAirResponses]
	@normAirReponses TVP_NormAirResponse READONLY
AS
BEGIN
	INSERT INTO NormalizedAirResponses (airResponseKey, flightNumber, airlines, airsubrequestkey,
		airLegNumber, airLegBookingClasses, operatingAirlines, airLegConnections, cabinclass,
		Originalcabinclass, airLegBrandName, isReturnFare)
	SELECT airResponseKey, flightNumber, airlines, airsubrequestkey,
		airLegNumber, airLegBookingClasses, operatingAirlines, airLegConnections, cabinclass,
		Originalcabinclass, airLegBrandName, isReturnFare
	FROM @normAirReponses 
END
GO
