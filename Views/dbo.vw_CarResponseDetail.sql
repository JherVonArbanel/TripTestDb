SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_CarResponseDetail]
AS
SELECT     dbo.CarResponse.carRequestKey, dbo.CarResponse.carVendorKey, dbo.CarVendorLookup.carVendorName, dbo.CarResponse.supplierId, 
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
                      dbo.CarResponse.RatePlan
FROM         CarContent.dbo.CarCompanies INNER JOIN
                      dbo.CarResponse LEFT OUTER JOIN
                      dbo.CarVendorLookup ON dbo.CarResponse.carVendorKey = dbo.CarVendorLookup.carVendorCode INNER JOIN
                      CarContent.dbo.SippCodes ON dbo.CarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType ON 
                      CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey LEFT OUTER JOIN
                      CarContent.dbo.SabreLocations LEFT OUTER JOIN
                      CarContent.dbo.SabreVehicles ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode AND 
                      CarContent.dbo.SabreLocations.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
                      CarContent.dbo.SabreLocations.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode INNER JOIN
                      CarContent.dbo.SabreLocations AS SabreLocations_1 ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode AND 
                      CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode AND 
                      CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode ON 
                      dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode AND
                       dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
                      dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode LEFT OUTER JOIN
                      dbo.CarRequest ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey

GO
