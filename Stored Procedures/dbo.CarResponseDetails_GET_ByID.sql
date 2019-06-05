SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CarResponseDetails_GET_ByID]
(
	@CarResponseDetailKey	UNIQUEIDENTIFIER = NULL
)
AS
BEGIN

	SELECT 
		vw_sabreCarResponse.carResponseKey,
		vw_sabreCarResponse.carRequestKey,
		CarResponseDetail.minRate,
		CarResponseDetail.minRateTax,
		vw_sabreCarResponse.VehicleName,
		vw_sabreCarResponse.pickupDate,
		vw_sabreCarResponse.dropoffDate,
		vw_sabreCarResponse.pickupLatitude,
		vw_sabreCarResponse.pickupLongitude,
		vw_sabreCarResponse.pickupLocationAddress,
		vw_sabreCarResponse.pickupCity,
		vw_sabreCarResponse.pickupState,
		vw_sabreCarResponse.pickupCountry,
		vw_sabreCarResponse.pickupZipCode,
		vw_sabreCarResponse.dropoffLatitude,
		vw_sabreCarResponse.dropoffLongitude,
		vw_sabreCarResponse.dropoffLocationAddress,
		vw_sabreCarResponse.dropoffCity,
		vw_sabreCarResponse.dropoffState,
		vw_sabreCarResponse.dropoffCountry,
		vw_sabreCarResponse.dropoffZipCode,
		vw_sabreCarResponse.carLocationCode,
		vw_sabreCarResponse.carVendorKey,
		vw_sabreCarResponse.CarCompanyName,
		vw_sabreCarResponse.carCategoryCode,
		vw_sabreCarResponse.SippCodeDescription,
		vw_sabreCarResponse.SippCodeClass,
		vw_sabreCarResponse.SippCodeTransmission,
		vw_sabreCarResponse.SippCodeAC 
	FROM vw_sabreCarResponse 
		LEFT OUTER JOIN CarResponseDetail ON vw_sabreCarResponse.carResponseKey = CarResponseDetail.carResponseKey 
	WHERE carResponseDetailKey = @CarResponseDetailKey

END
GO
