SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[vw_TripCarResponseForSavedTrip]
AS
SELECT     trip.tripKey, tripName, trip.userKey, TripCarResponse.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, dbo.TripCarResponse.carResponseKey, 
                      dbo.TripCarResponse.confirmationNumber, dbo.TripCarResponse.carVendorKey, dbo.TripCarResponse.supplierId, dbo.TripCarResponse.carCategoryCode, 
                      dbo.TripCarResponse.carLocationCode, dbo.TripCarResponse.carLocationCategoryCode, dbo.TripCarResponse.minRate AS PerDayRate, 
                      dbo.TripCarResponse.searchCarTax, dbo.TripCarResponse.actualCarPrice, dbo.TripCarResponse.actualCarTax, dbo.TripCarResponse.SearchCarPrice, 
                      CarContent.dbo.SabreVehicles.VehicleName, SabreLocations_1.LocationName AS pickupLocationName, 
                      SabreLocations_1.LocationAddress1 AS pickupLocationAddress, SabreLocations_1.Latitude AS pickupLatitude, SabreLocations_1.Longitude AS pickupLongitude, 
                      SabreLocations_1.ZipCode AS pickupZipCode, CarContent.dbo.SabreLocations.Latitude AS dropoffLatitude, 
                      CarContent.dbo.SabreLocations.Longitude AS dropoffLongitude, CarContent.dbo.SabreLocations.ZipCode AS dropoffZipCode, 
                      CarContent.dbo.SabreLocations.LocationAddress1 AS dropoffLocationAddress, CarContent.dbo.SabreLocations.LocationName AS dropoffLocationName, 
                      dbo.TripCarResponse.PickUpdate, dbo.TripCarResponse.dropOutDate, CarContent.dbo.SippCodes.SippCodeDescription, 
                      CarContent.dbo.SippCodes.SippCodeTransmission, CASE WHEN CarContent.dbo.SippCodes.SippCodeAC = 'Air Conditioning' THEN 1 ELSE 0 END AS SippCodeAC, 
                      CarContent.dbo.CarCompanies.CarCompanyName, CarContent.dbo.SippCodes.SippCodeClass, CarContent.dbo.SabreLocations.LocationCity AS dropoffCity, 
                      CarContent.dbo.SabreLocations.Locationstate AS dropoffState, CarContent.dbo.SabreLocations.LocationCountry AS dropoffCountry, 
                      SabreLocations_1.LocationCity AS pickupCity, SabreLocations_1.Locationstate AS pickupState, SabreLocations_1.LocationCountry AS pickupCountry, 
                      dbo.TripCarResponse.minRateTax, dbo.TripCarResponse.TotalChargeAmt, dbo.TripCarResponse.minRate, CarContent.dbo.SabreVehicles.PsgrCapacity AS passenger, 
                      CarContent.dbo.SabreVehicles.Baggage AS baggage, TripCarResponse.isExpenseAdded,  Trip.siteKey, trip.createdDate, trip.tripRequestKey, 
                      TripCarResponse.NoOfDays,TripCarResponse.tripGUIDKey
FROM         CarContent.dbo.CarCompanies WITH (NOLOCK) INNER JOIN
                      dbo.TripCarResponse WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.SippCodes WITH (NOLOCK) ON dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType ON 
                      CarContent.dbo.CarCompanies.CarCompanyCode = dbo.TripCarResponse.carVendorKey LEFT OUTER JOIN
                      CarContent.dbo.SabreLocations LEFT OUTER JOIN
                      CarContent.dbo.SabreVehicles WITH (NOLOCK) ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode AND 
                      CarContent.dbo.SabreLocations.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
                      CarContent.dbo.SabreLocations.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode INNER JOIN
                      CarContent.dbo.SabreLocations AS SabreLocations_1 ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode AND 
                      CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode AND 
                      CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode ON 
                      dbo.TripCarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode AND 
                      dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode AND 
                      dbo.TripCarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
                      dbo.TripCarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode INNER JOIN
                      dbo.Trip WITH (NOLOCK) ON  dbo.TripCarResponse.tripguidkey = dbo.trip.tripsavedKey 
WHERE     TripCarResponse.SupplierId = 'Sabre' AND ISNULL (dbo.TripCarResponse.ISDELETED ,0) = 0
UNION ALL
SELECT     trip.tripKey, tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, AV.ALVehicleName, AL_1.ALLocationName AS pickupLocationName, AL_1.ALLocationAddress1 AS pickupLocationAddress, 
                      AL_1.ALLatitude AS pickupLatitude, AL_1.ALLongitude AS pickupLongitude, AL_1.ALZipCode AS pickupZipCode, AL.ALLatitude AS dropoffLatitude, 
                      AL.ALLongitude AS dropoffLongitude, AL.ALZipCode AS dropoffZipCode, AL.ALLocationAddress1 AS dropoffLocationAddress, 
                      AL.ALLocationName AS dropoffLocationName, TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, 
                      AV.ALTRANSMISSIONTYPE AS SippCodeTransmission, AV.ALAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, 
                      S.VehicleClass AS SippCodeClass, AL.ALLocationCityName AS dropoffCity, AL.ALLocationStateCode AS dropoffState, AL.ALLocationCountryCode AS dropoffCountry, 
                      AL_1.ALLocationCityName AS pickupCity, AL_1.ALLocationStateCode AS pickupState, AL_1.ALLocationCountryCode AS pickupCountry, TR.minRateTax, 
                      TR.TotalChargeAmt, TR.minRate, AV.ALPASSENGERQUANTITY AS passenger, AV.ALBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded,  Trip.siteKey, 
                      trip.createdDate, trip.tripRequestKey, TR.NoOfDays,TR.tripGUIDKey
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey INNER JOIN
                      Trip WITH (NOLOCK) ON   TR.tripguidkey = dbo.trip.tripsavedKey    
                      LEFT OUTER JOIN
                      CarContent.dbo.AlamoLocations AL WITH (NOLOCK) ON TR.carLocationCode = LEFT(AL.ALLocationCode, 3) AND AL.ALAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.ALAMOVEHICLES AV WITH (NOLOCK) ON AL.ALLocationCode = AV.ALLOCATIONCODE AND AV.ALVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.AlamoLocations AL_1 ON AL.ALLocationCode = AL_1.ALLocationCode AND AL_1.ALAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON AV.ALVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'AL'
UNION ALL
SELECT     trip.tripKey, tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, NV.ZLVehicleName, NL_1.ZLLocationName AS pickupLocationName, NL_1.ZLLocationAddress1 AS pickupLocationAddress, 
                      NL_1.ZLLatitude AS pickupLatitude, NL_1.ZLLongitude AS pickupLongitude, NL_1.ZLZipCode AS pickupZipCode, NL.ZLLatitude AS dropoffLatitude, 
                      NL.ZLLongitude AS dropoffLongitude, NL.ZLZipCode AS dropoffZipCode, NL.ZLLocationAddress1 AS dropoffLocationAddress, 
                      NL.ZLLocationName AS dropoffLocationName, TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, 
                      NV.ZLTRANSMISSIONTYPE AS SippCodeTransmission, NV.ZLAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, 
                      S.VehicleClass AS SippCodeClass, NL.ZLLocationCityName AS dropoffCity, NL.ZLLocationStateCode AS dropoffState, NL.ZLLocationCountryCode AS dropoffCountry, 
                      NL_1.ZLLocationCityName AS pickupCity, NL_1.ZLLocationStateCode AS pickupState, NL_1.ZLLocationCountryCode AS pickupCountry, TR.minRateTax, 
                      TR.TotalChargeAmt, TR.minRate, NV.ZLPASSENGERQUANTITY AS passenger, NV.ZLBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded,  Trip.siteKey, 
                      trip.createdDate, trip.tripRequestKey, TR.NoOfDays,TR.tripGUIDKey
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey INNER JOIN
                      Trip WITH (NOLOCK) ON   TR.tripguidkey = dbo.trip.tripsavedKey     LEFT OUTER JOIN
                      CarContent.dbo.NationalLocations NL WITH (NOLOCK) ON TR.carLocationCode = LEFT(NL.ZLLocationCode, 3) AND NL.ZLAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.NationalVehicles NV WITH (NOLOCK) ON NL.ZLLocationCode = NV.ZLLOCATIONCODE AND NV.ZLVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.NationalLocations NL_1 ON NL.ZLLocationCode = NL_1.ZLLocationCode AND NL_1.ZLAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON NV.ZLVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZL'
UNION ALL
SELECT     trip.tripKey, tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, ZV.ZRVehicleName, ZL_1.ZRLocationName AS pickupLocationName, ZL_1.ZRAddress1 AS pickupLocationAddress, 
                      ZL_1.ZRLatitude AS pickupLatitude, ZL_1.ZRLongitude AS pickupLongitude, ZL_1.ZRZipCode AS pickupZipCode, ZL.ZRLatitude AS dropoffLatitude, 
                      ZL.ZRLongitude AS dropoffLongitude, ZL.ZRZipCode AS dropoffZipCode, ZL.ZRAddress1 AS dropoffLocationAddress, ZL.ZRLocationName AS dropoffLocationName, 
                      TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, ZV.ZRTRANSMISSIONTYPE AS SippCodeTransmission, 
                      ZV.ZRAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, S.VehicleClass AS SippCodeClass, ZL.ZRCityName AS dropoffCity, 
                      ZL.ZRStateCode AS dropoffState, ZL.ZRCountryCode AS dropoffCountry, ZL_1.ZRCityName AS pickupCity, ZL_1.ZRStateCode AS pickupState, 
                      ZL_1.ZRCountryCode AS pickupCountry, TR.minRateTax, TR.TotalChargeAmt, TR.minRate, ZV.ZRPASSENGERQUANTITY AS passenger, 
                      ZV.ZRBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded,  Trip.siteKey, trip.createdDate, trip.tripRequestKey, TR.NoOfDays,TR.tripGUIDKey
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey INNER JOIN
                      Trip WITH (NOLOCK) ON  TR.tripguidkey = dbo.trip.tripsavedKey    LEFT OUTER JOIN
                      CarContent.dbo.DollarLocations ZL WITH (NOLOCK) ON TR.carLocationCode = LEFT(ZL.ZRLocationCode, 3) AND ZL.ZRAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.DollarVehicles ZV WITH (NOLOCK) ON ZL.ZRLocationCode = ZV.ZRLOCATIONCODE AND ZV.ZRVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.DollarLocations ZL_1 ON ZL.ZRLocationCode = ZL_1.ZRLocationCode AND ZL_1.ZRAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON ZV.ZRVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZR'
UNION ALL
SELECT     trip.tripKey, tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, TV.ZTVEHICLENAME, TL_1.ZTLocationName AS pickupLocationName, TL_1.ZTAddress1 AS pickupLocationAddress, 
                      TL_1.ZTLatitude AS pickupLatitude, TL_1.ZTLongitude AS pickupLongitude, TL_1.ZTZipCode AS pickupZipCode, TL.ZTLatitude AS dropoffLatitude, 
                      TL.ZTLongitude AS dropoffLongitude, TL.ZTZipCode AS dropoffZipCode, TL.ZTAddress1 AS dropoffLocationAddress, TL.ZTLocationName AS dropoffLocationName, 
                      TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, TV.ZTTRANSMISSIONTYPE AS SippCodeTransmission, 
                      TV.ZTAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, S.VehicleClass AS SippCodeClass, TL.ZTCityName AS dropoffCity, 
                      TL.ZTStateCode AS dropoffState, TL.ZTCountryCode AS dropoffCountry, TL_1.ZTCityName AS pickupCity, TL_1.ZTStateCode AS pickupState, 
                      TL_1.ZTCountryCode AS pickupCountry, TR.minRateTax, TR.TotalChargeAmt, TR.minRate, TV.ZTPASSENGERQUANTITY AS passenger, 
                      TV.ZTBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded,   Trip.siteKey, trip.createdDate, trip.tripRequestKey, TR.NoOfDays,TR.tripGUIDKey
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey INNER JOIN
                      Trip WITH (NOLOCK) ON   TR.tripguidkey = dbo.trip.tripsavedKey     LEFT OUTER JOIN
                      CarContent.dbo.ThriftyLocations TL WITH (NOLOCK) ON TR.carLocationCode = LEFT(TL.ZTLocationCode, 3) AND TL.ZTAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.ThriftyVehicles TV WITH (NOLOCK) ON TL.ZTLocationCode = TV.ZTLOCATIONCODE AND TV.ZTVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.ThriftyLocations TL_1 ON TL.ZTLocationCode = TL_1.ZTLocationCode AND TL_1.ZTAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON TV.ZTVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZT'
GO
