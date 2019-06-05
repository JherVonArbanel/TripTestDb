SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_TripCarResponseDetails]
AS
		  SELECT      TR.recordLocator,		TR.carResponseKey,			TR.confirmationNumber,		TR.carVendorKey,		TR.supplierId,		TR.carCategoryCode, 
TR.carLocationCode,	TR.carLocationCategoryCode, TR.minRate AS PerDayRate,	TR.searchCarTax,		TR.actualCarPrice,	TR.actualCarTax, 
TR.SearchCarPrice,    SV.VehicleName,				SL.LocationName AS pickupLocationName,              SL.LocationAddress1 AS pickupLocationAddress, 
SL.Latitude AS pickupLatitude,					SL.Longitude AS pickupLongitude,                    SL.ZipCode AS pickupZipCode, 
DO.Latitude AS dropoffLatitude,                   DO.Longitude AS dropoffLongitude,					DO.ZipCode AS dropoffZipCode, 
DO.LocationAddress1 AS dropoffLocationAddress,	DO.LocationName AS dropoffLocationName,             TR.PickUpdate, TR.dropOutDate, 
S.SippCodeDescription,                            S.SippCodeTransmission,								CASE WHEN S.SippCodeAC = 'Air Conditioning' THEN 1 ELSE 0 END AS SippCodeAC, 
CC.CarCompanyName,	S.SippCodeClass,			DO.LocationCity AS dropoffCity,                     DO.Locationstate AS dropoffState, 
DO.LocationCountry AS dropoffCountry,             SL.LocationCity AS pickupCity,						SL.Locationstate AS pickupState, 
SL.LocationCountry AS pickupCountry,              TR.minRateTax,				TR.TotalChargeAmt,		TR.minRate, 
SV.PsgrCapacity AS passenger,                     SV.Baggage AS baggage,		TR.isExpenseAdded,		TR.NoOfDays,TR.tripGUIDKey, 
TR.contractCode,		TR.carRules ,				TR.tripKey,					TR.rateTypeCode,
TR.OperationTimeStart,		            		TR.OperationTimeEnd,		TR.PickupLocationInfo,	TR.InvoiceNumber,		TR.MileageAllowance,
TR.RPH, TR.CurrencyCodeKey,sv.imageName, TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
, TR.IsChangeTripCar,TR.PickupAddress,TR.DropAddress,TR.RequestType	
		  FROM		 CarContent.dbo.CarCompanies CC WITH (NOLOCK) 
					 INNER JOIN dbo.TripCarResponse TR WITH (NOLOCK) ON  CC.CarCompanyCode = TR.carVendorKey 
					 --inner join dbo.Trip on TR.tripGUIDKey = trip.tripSavedKey
				     INNER JOIN CarContent.dbo.SippCodes S WITH (NOLOCK) ON TR.carCategoryCode = S.SippCodeCarType 
					 LEFT OUTER JOIN  CarContent.dbo.SabreVehicles SV WITH (NOLOCK) ON TR.carVendorKey = SV.VendorCode 
					             AND   TR.carCategoryCode = SV.SippCode 
					             AND   TR.carLocationCode = SV.LocationAirportCode 
					             AND   TR.carLocationCategoryCode = SV.LocationCategoryCode 
				   --LEFT OUTER JOIN CarContent.dbo.SabreLocations S1 WITH (NOLOCK) ON SV.VendorCode = S1.VendorCode 
				   --            AND SV.LocationAirportCode = S1.LocationAirportCode 
				   --            AND SV.LocationCategoryCode = S1.LocationCategoryCode 
					LEFT OUTER JOIN  CarContent.dbo.SabreLocations SL WITH (NOLOCK) ON SL.VendorCode = SV.VendorCode 
							    AND SL.LocationAirportCode = SV.LocationAirportCode 
							    AND SL.LocationCategoryCode = SV.LocationCategoryCode
					LEFT OUTER JOIN CarContent.dbo.SabreLocations DO WITH (NOLOCK) ON DO.VendorCode = SV.VendorCode 
							    AND DO.LocationAirportCode = ISNULL(TR.carDropOffLocationCode, SV.LocationAirportCode)
							    AND DO.LocationCategoryCode = ISNULL(TR.carDropOffLocationCode,SV.LocationAirportCode)
		 WHERE     TR.SupplierId = 'Sabre' AND ISNULL (TR.ISDELETED ,0) = 0 
UNION ALL
		  SELECT      TR.recordLocator,TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, AV.ALVehicleName, AL_1.ALLocationName AS pickupLocationName, AL_1.ALLocationAddress1 AS pickupLocationAddress, 
                      AL_1.ALLatitude AS pickupLatitude, AL_1.ALLongitude AS pickupLongitude, AL_1.ALZipCode AS pickupZipCode, AL.ALLatitude AS dropoffLatitude, 
                      AL.ALLongitude AS dropoffLongitude, AL.ALZipCode AS dropoffZipCode, AL.ALLocationAddress1 AS dropoffLocationAddress, 
                      AL.ALLocationName AS dropoffLocationName, TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, 
                      AV.ALTRANSMISSIONTYPE AS SippCodeTransmission, AV.ALAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, 
                      S.VehicleClass AS SippCodeClass, AL.ALLocationCityName AS dropoffCity, AL.ALLocationStateCode AS dropoffState, AL.ALLocationCountryCode AS dropoffCountry, 
                      AL_1.ALLocationCityName AS pickupCity, AL_1.ALLocationStateCode AS pickupState, AL_1.ALLocationCountryCode AS pickupCountry, TR.minRateTax, 
                      TR.TotalChargeAmt, TR.minRate, AV.ALPASSENGERQUANTITY AS passenger, AV.ALBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH, TR.CurrencyCodeKey,'' as ImageName, TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
					  , TR.IsChangeTripCar,TR.PickupAddress,TR.DropAddress,TR.RequestType	
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
                      --inner join dbo.Trip on TR.tripGUIDKey = trip.tripSavedKey
                      LEFT OUTER JOIN
                      CarContent.dbo.AlamoLocations AL WITH (NOLOCK) ON TR.carLocationCode = LEFT(AL.ALLocationCode, 3) AND AL.ALAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.ALAMOVEHICLES AV WITH (NOLOCK) ON AL.ALLocationCode = AV.ALLOCATIONCODE AND AV.ALVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.AlamoLocations AL_1 ON AL.ALLocationCode = AL_1.ALLocationCode AND AL_1.ALAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON AV.ALVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'AL'
UNION ALL
SELECT     TR.recordLocator,TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, NV.ZLVehicleName, NL_1.ZLLocationName AS pickupLocationName, NL_1.ZLLocationAddress1 AS pickupLocationAddress, 
                      NL_1.ZLLatitude AS pickupLatitude, NL_1.ZLLongitude AS pickupLongitude, NL_1.ZLZipCode AS pickupZipCode, NL.ZLLatitude AS dropoffLatitude, 
                      NL.ZLLongitude AS dropoffLongitude, NL.ZLZipCode AS dropoffZipCode, NL.ZLLocationAddress1 AS dropoffLocationAddress, 
                      NL.ZLLocationName AS dropoffLocationName, TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, 
                      NV.ZLTRANSMISSIONTYPE AS SippCodeTransmission, NV.ZLAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, 
                      S.VehicleClass AS SippCodeClass, NL.ZLLocationCityName AS dropoffCity, NL.ZLLocationStateCode AS dropoffState, NL.ZLLocationCountryCode AS dropoffCountry, 
                      NL_1.ZLLocationCityName AS pickupCity, NL_1.ZLLocationStateCode AS pickupState, NL_1.ZLLocationCountryCode AS pickupCountry, TR.minRateTax, 
                      TR.TotalChargeAmt, TR.minRate, NV.ZLPASSENGERQUANTITY AS passenger, NV.ZLBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH, TR.CurrencyCodeKey,'' as ImageName,  TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
					  , TR.IsChangeTripCar,TR.PickupAddress,TR.DropAddress,TR.RequestType	
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
                      --inner join dbo.Trip on TR.tripGUIDKey = trip.tripSavedKey
                      LEFT OUTER JOIN
                      CarContent.dbo.NationalLocations NL WITH (NOLOCK) ON TR.carLocationCode = LEFT(NL.ZLLocationCode, 3) AND NL.ZLAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.NationalVehicles NV WITH (NOLOCK) ON NL.ZLLocationCode = NV.ZLLOCATIONCODE AND NV.ZLVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.NationalLocations NL_1 ON NL.ZLLocationCode = NL_1.ZLLocationCode AND NL_1.ZLAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON NV.ZLVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZL'
UNION ALL
SELECT      TR.recordLocator,TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, ZV.ZRVehicleName, ZL_1.ZRLocationName AS pickupLocationName, ZL_1.ZRAddress1 AS pickupLocationAddress, 
                      ZL_1.ZRLatitude AS pickupLatitude, ZL_1.ZRLongitude AS pickupLongitude, ZL_1.ZRZipCode AS pickupZipCode, ZL.ZRLatitude AS dropoffLatitude, 
                      ZL.ZRLongitude AS dropoffLongitude, ZL.ZRZipCode AS dropoffZipCode, ZL.ZRAddress1 AS dropoffLocationAddress, ZL.ZRLocationName AS dropoffLocationName, 
                      TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, ZV.ZRTRANSMISSIONTYPE AS SippCodeTransmission, 
                      ZV.ZRAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, S.VehicleClass AS SippCodeClass, ZL.ZRCityName AS dropoffCity, 
                      ZL.ZRStateCode AS dropoffState, ZL.ZRCountryCode AS dropoffCountry, ZL_1.ZRCityName AS pickupCity, ZL_1.ZRStateCode AS pickupState, 
                      ZL_1.ZRCountryCode AS pickupCountry, TR.minRateTax, TR.TotalChargeAmt, TR.minRate, ZV.ZRPASSENGERQUANTITY AS passenger, 
                      ZV.ZRBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH,TR.CurrencyCodeKey,'' as ImageName ,  TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
					  , TR.IsChangeTripCar,TR.PickupAddress,TR.DropAddress,TR.RequestType	
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
                      --inner join dbo.Trip on TR.tripGUIDKey = trip.tripSavedKey
                      LEFT OUTER JOIN
                      CarContent.dbo.DollarLocations ZL WITH (NOLOCK) ON TR.carLocationCode = LEFT(ZL.ZRLocationCode, 3) AND ZL.ZRAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.DollarVehicles ZV WITH (NOLOCK) ON ZL.ZRLocationCode = ZV.ZRLOCATIONCODE AND ZV.ZRVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.DollarLocations ZL_1 ON ZL.ZRLocationCode = ZL_1.ZRLocationCode AND ZL_1.ZRAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON ZV.ZRVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZR'
UNION ALL
SELECT     TR.recordLocator, TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, TV.ZTVEHICLENAME, TL_1.ZTLocationName AS pickupLocationName, TL_1.ZTAddress1 AS pickupLocationAddress, 
                      TL_1.ZTLatitude AS pickupLatitude, TL_1.ZTLongitude AS pickupLongitude, TL_1.ZTZipCode AS pickupZipCode, TL.ZTLatitude AS dropoffLatitude, 
                      TL.ZTLongitude AS dropoffLongitude, TL.ZTZipCode AS dropoffZipCode, TL.ZTAddress1 AS dropoffLocationAddress, TL.ZTLocationName AS dropoffLocationName, 
                      TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, TV.ZTTRANSMISSIONTYPE AS SippCodeTransmission, 
                      TV.ZTAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, S.VehicleClass AS SippCodeClass, TL.ZTCityName AS dropoffCity, 
                      TL.ZTStateCode AS dropoffState, TL.ZTCountryCode AS dropoffCountry, TL_1.ZTCityName AS pickupCity, TL_1.ZTStateCode AS pickupState, 
                      TL_1.ZTCountryCode AS pickupCountry, TR.minRateTax, TR.TotalChargeAmt, TR.minRate, TV.ZTPASSENGERQUANTITY AS passenger, 
                      TV.ZTBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH, TR.CurrencyCodeKey,'' as Imagename , TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
					  , TR.IsChangeTripCar,TR.PickupAddress,TR.DropAddress,TR.RequestType	
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey
                      --inner join dbo.Trip on TR.tripGUIDKey = trip.tripSavedKey
                      LEFT OUTER JOIN
                      CarContent.dbo.ThriftyLocations TL WITH (NOLOCK) ON TR.carLocationCode = LEFT(TL.ZTLocationCode, 3) AND TL.ZTAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.ThriftyVehicles TV WITH (NOLOCK) ON TL.ZTLocationCode = TV.ZTLOCATIONCODE AND TV.ZTVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.ThriftyLocations TL_1 ON TL.ZTLocationCode = TL_1.ZTLocationCode AND TL_1.ZTAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON TV.ZTVEHICLECLASSSIZE = S.VehicleClassSize
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZT'

GO
