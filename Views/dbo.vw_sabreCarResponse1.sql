SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_sabreCarResponse1]
AS
SELECT     dbo.CarResponse.carResponseKey, dbo.CarResponse.carRequestKey, dbo.CarResponse.carVendorKey, dbo.CarResponse.supplierId, 
                      dbo.CarResponse.carCategoryCode, dbo.CarResponse.carLocationCode, dbo.CarResponse.carLocationCategoryCode, dbo.CarResponse.minRate AS PerDayRate, 
                      CarContent.dbo.SabreVehicles.VehicleName, SabreLocations_1.LocationName AS pickupLocationName, 
                      SabreLocations_1.LocationAddress1 AS pickupLocationAddress, SabreLocations_1.Latitude AS pickupLatitude, SabreLocations_1.Longitude AS pickupLongitude, 
                      SabreLocations_1.ZipCode AS pickupZipCode, CarContent.dbo.SabreLocations.Latitude AS dropoffLatitude, 
                      CarContent.dbo.SabreLocations.Longitude AS dropoffLongitude, CarContent.dbo.SabreLocations.ZipCode AS dropoffZipCode, 
                      CarContent.dbo.SabreLocations.LocationAddress1 AS dropoffLocationAddress, CarContent.dbo.SabreLocations.LocationName AS dropoffLocationName, 
                      dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate, CarContent.dbo.SippCodes.SippCodeDescription, CarContent.dbo.SippCodes.SippCodeTransmission, 
                      CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, CarContent.dbo.SippCodes.SippCodeClass, 
                      CarContent.dbo.SabreLocations.LocationCity AS dropoffCity, CarContent.dbo.SabreLocations.Locationstate AS dropoffState, 
                      CarContent.dbo.SabreLocations.LocationCountry AS dropoffCountry, SabreLocations_1.LocationCity AS pickupCity, SabreLocations_1.Locationstate AS pickupState, 
                      SabreLocations_1.LocationCountry AS pickupCountry, dbo.CarResponse.minRateTax, dbo.CarResponse.TotalChargeAmt, dbo.CarResponse.minRate, 
                      CarContent.dbo.SabreVehicles.PsgrCapacity AS passenger, CarContent.dbo.SabreVehicles.Baggage, dbo.CarResponse.MileageAllowance, 
                      dbo.CarResponse.RatePlan, dbo.CarResponse.contractCode
FROM         CarContent.dbo.CarCompanies INNER JOIN
                      dbo.CarResponse ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey INNER JOIN
                      CarContent.dbo.SippCodes ON dbo.CarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType INNER JOIN
                      CarContent.dbo.SabreVehicles ON dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
                      dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode AND 
                      dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode AND 
                      dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode INNER JOIN
                      CarContent.dbo.SabreLocations ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode INNER JOIN
                      CarContent.dbo.SabreLocations AS SabreLocations_1 ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode AND 
                      SabreLocations_1.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
                      SabreLocations_1.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode INNER JOIN
                      dbo.CarRequest ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey AND 
                      dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationAirportCode AND 
                      dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationCategoryCode AND 
                      dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationAirportCode AND dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationCategoryCode
GO
