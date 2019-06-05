SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_BulkInsertNormAirResponsesMultiBrand]
	@normAirReponsesMultiBrand [TVP_NormAirResponseMultiBrand] READONLY
AS
BEGIN
	INSERT INTO NormalizedAirResponsesMultiBrand(airresponseMultiBrandkey,
	airresponsekey,
	flightNumber,
	airlines,
	airsubrequestkey,
	airLegNumber,
	airLegBookingClasses,
	operatingAirlines,
	airLegConnections,
	cabinclass,
	Originalcabinclass,
	airLegBrandName,
	isReturnFare)
	SELECT airresponseMultiBrandkey,
	airresponsekey,
	flightNumber,
	airlines,
	airsubrequestkey,
	airLegNumber,
	airLegBookingClasses,
	operatingAirlines,
	airLegConnections,
	cabinclass,
	Originalcabinclass,
	airLegBrandName,
	isReturnFare
	FROM @normAirReponsesMultiBrand 
END
GO
