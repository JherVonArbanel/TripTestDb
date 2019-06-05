SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CarRequests_GET]
(
	@tripRequestKey INT = NULL,
	@carRequestKey	INT = NULL
)
AS
BEGIN
	
	IF @tripRequestKey IS NOT NULL 
	BEGIN
		SELECT 
			CarRequest.carRequestKey,
			CarRequest.pickupCityCode,
			CarRequest.dropoffCityCode,
			CarRequest.pickupDate,
			CarRequest.dropoffDate 
		FROM TripRequest_car 
			LEFT OUTER JOIN CarRequest ON TripRequest_car.carRequestKey = CarRequest.carRequestKey 
		WHERE tripRequestKey = @tripRequestKey
	END
	ELSE
	BEGIN
		SELECT 
			CarRequest.carRequestKey,
			CarRequest.pickupCityCode,
			CarRequest.dropoffCityCode,
			CarRequest.pickupDate,
			CarRequest.dropoffDate 
		FROM TripRequest_car 
			LEFT OUTER JOIN CarRequest ON TripRequest_car.carRequestKey = CarRequest.carRequestKey 
		WHERE CarRequest.carRequestKey = @carRequestKey
	END
END
GO
