SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_DirectCarResponse]
AS
SELECT 
	  C.CarCompanyName 
	, R.carResponseKey
	, R.carRequestKey 
	, R.carVendorKey
	, R.supplierId
	, R.carCategoryCode
	, R.carLocationCode
	, R.carLocationCategoryCode
	, R.minRate AS PerDayRate
	, R.minRateTax
	, R.TotalChargeAmt
	, R.minRate
	, R.RateQualifier
    , R.ReferenceType
    , R.ReferenceDateTime
    , R.ReferenceId
    , CarRequest.pickupDate
	, CarRequest.dropoffDate
	, 'AL' as VENDORCODE
	, AV.ALLOCATIONCODE as LocationCode
	, AV.ALTRANSMISSIONTYPE as VechileTransmission
	, AV.ALAIRCONDITIONIND as VechileAirConditioning
	, AV.ALBAGGAGEQUANTITY
	, AV.ALPASSENGERQUANTITY
	, AV.ALVEHICLECATEGORY as VehicleCategory
	, AV.ALDOORCOUNT as VehicleDoorCount
	, AV.ALVEHICLECLASSSIZE as VehicleClassSize
	, AV.ALVEHICLENAME as VehicleName
	, AV.ALVEHICLECODE as VehicleCode
	, AV.ALVEHICLEIMAGE as VehicleImage
	, AL.ALAtAirport
	, AL.ALLocationName as pickupLocationName
	, AL.ALLocationAddress1 as pickupLocationAddress
	, AL.ALLocationAddress2
	, AL.ALLocationCityName as pickupCity
	, AL.ALLocationStateCode
	, AL.ALLocationStateName as pickupState
	, AL.ALLocationCountryCode as pickupCountry
	, AL.ALLocationName as dropoffLocationName
	, AL.ALLocationAddress1 as dropoffLocationAddress
	, AL.ALLocationCityName as dropoffCity
	, AL.ALLocationStateName as dropoffState
	, AL.ALLocationCountryCode as dropoffCountry
	, AL.ALPhoneNumbers
	, AV.ALPASSENGERQUANTITY as Passenger
	, AV.ALBAGGAGEQUANTITY as Baggage
    , S.VehicleClass as SippCodeDescription
    , S.VehicleClass as SippCodeClass
    , V.CompanyNameCode as CompanyNameCode
    , V.CompanyShortName as CompanyShortName
    , V.RequestorId as RequestorId
    , V.RequestorIdType as RequestorIdType
    , V.IATANo as IATANo
    ,R.contractCode as contractCode
    
FROM  
	CarContent.dbo.ALAMOVEHICLES AV					  WITH(NOLOCK)
	INNER JOIN CarContent.dbo.ALAMOLOCATIONS AL		  WITH(NOLOCK) ON AV.ALLOCATIONCODE = AL.ALLocationCode 
	INNER JOIN dbo.CarResponse R					  WITH(NOLOCK) ON R.carLocationCode = left(AV.ALLOCATIONCODE,3) 
	AND AV.ALVEHICLECODE = R.carCategoryCode AND AL.ALAtAirport=1 AND R.carVendorKey = 'AL'
	INNER JOIN CarContent.dbo.CarCompanies C		  WITH(NOLOCK) ON C.CarCompanyCode   = R.carVendorKey
	INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH(NOLOCK) ON AV.ALVEHICLECLASSSIZE = S.VehicleClassSize
    LEFT OUTER JOIN  dbo.CarRequest					  WITH(NOLOCK) ON R.carRequestKey = dbo.CarRequest.carRequestKey
    LEFT OUTER JOIN Vault.dbo.CarDirectConnectVendors V WITH (NOLOCK) ON V.VendorCode = 'AL'

UNION ALL

SELECT 
	  C.CarCompanyName 
	, R.carResponseKey
	, R.carRequestKey 
	, R.carVendorKey 
	, R.supplierId 
	, R.carCategoryCode
	, R.carLocationCode
	, R.carLocationCategoryCode
	, R.minRate AS PerDayRate
	, R.minRateTax 
	, R.TotalChargeAmt
	, R.minRate
	, R.RateQualifier
    , R.ReferenceType
    , R.ReferenceDateTime
    , R.ReferenceId  
    , dbo.CarRequest.pickupDate
	, dbo.CarRequest.dropoffDate
	, 'ZL' as VENDORCODE
    , NV.ZLLOCATIONCODE as LocationCode
	, NV.ZLTRANSMISSIONTYPE as VechileTransmission
	, NV.ZLAIRCONDITIONIND as VechileAirConditioning
	, NV.ZLBAGGAGEQUANTITY
	, NV.ZLPASSENGERQUANTITY
	, NV.ZLVEHICLECATEGORY as VehicleCategory
	, NV.ZLDOORCOUNT as vehicleDoorCount
	, NV.ZLVEHICLECLASSSIZE as VehicleClassSize
	, NV.ZLVEHICLENAME as VehicleName
	, NV.ZLVEHICLECODE as VehicleCode
	, NV.ZLVEHICLEIMAGE as VehicleImage
	, NL.ZLAtAirport
	, NL.ZLLocationName as pickupLocationName
	, NL.ZLLocationAddress1 as pickupLocationAddress
	, NL.ZLLocationAddress2
	, NL.ZLLocationCityName as pickupCity
	, NL.ZLLocationStateCode
	, NL.ZLLocationStateName as pickupState
	, NL.ZLLocationCountryCode as pickupCountry
	, NL.ZLPhoneNumbers
	, NL.ZLLocationName as dropoffLocationName
	, NL.ZLLocationAddress1 as dropoffLocationAddress
	, NL.ZLLocationCityName as dropoffCity
	, NL.ZLLocationStateName as dropoffState
	, NL.ZLLocationCountryCode as dropoffCountry
	, NV.ZLPASSENGERQUANTITY as Passenger
	, NV.ZLBAGGAGEQUANTITY as Baggage
	, S.VehicleClass as SippCodeDescription
	, S.VehicleClass as SippCodeClass
	, V.CompanyNameCode as CompanyNameCode
    , V.CompanyShortName as CompanyShortName
    , V.RequestorId as RequestorId
    , V.RequestorIdType as RequestorIdType
    , V.IATANo as IATANo
    ,R.contractCode
FROM  
	CarContent.dbo.NationalVehicles NV					WITH(NOLOCK)
	INNER JOIN CarContent.dbo.NationalLocations NL		WITH(NOLOCK) ON NV.ZLLOCATIONCODE = NL.ZLLocationCode
	INNER JOIN dbo.CarResponse R						WITH(NOLOCK) ON R.carLocationCode =left(NV.ZLLOCATIONCODE,3) 
	AND NV.ZLVEHICLECODE = R.carCategoryCode AND NL.ZLAtAirport=1 AND R.carVendorKey = 'ZL'
	INNER JOIN CarContent.dbo.CarCompanies C			WITH(NOLOCK) ON C.CarCompanyCode   = R.carVendorKey
	INNER JOIN CarContent.dbo.DirectConnectSipCodes S	WITH(NOLOCK) ON NV.ZLVEHICLECLASSSIZE = S.VehicleClassSize
    LEFT OUTER JOIN  dbo.CarRequest						WITH(NOLOCK) ON R.carRequestKey = dbo.CarRequest.carRequestKey
    LEFT OUTER JOIN Vault.dbo.CarDirectConnectVendors V WITH (NOLOCK) ON V.VendorCode = 'ZL'
   
UNION ALL

SELECT 
	  C.CarCompanyName 
	, R.carResponseKey
	, R.carRequestKey
	, R.carVendorKey 
	, R.supplierId
	, R.carCategoryCode
	, R.carLocationCode
	, R.carLocationCategoryCode 
	, R.minRate AS PerDayRate 
	, R.minRateTax 
	, R.TotalChargeAmt 
	, R.minRate 
	, R.RateQualifier
    , R.ReferenceType
    , R.ReferenceDateTime
    , R.ReferenceId  
    , dbo.CarRequest.pickupDate 
	, dbo.CarRequest.dropoffDate
	, 'ZR' as VENDORCODE --Dollar
    , DV.ZRLOCATIONCODE as LocationCode
	, DV.ZRTRANSMISSIONTYPE as VechileTransmission
	, DV.ZRAIRCONDITIONIND as VechileAirConditioning
	, DV.ZRBAGGAGEQUANTITY
	, DV.ZRPASSENGERQUANTITY
	, DV.ZRVEHICLECATEGORY as VehicleCategory
	, DV.ZRDOORCOUNT as vehicleDoorCount
	, DV.ZRVEHICLECLASSSIZE as VehicleClassSize
	, DV.ZRVEHICLENAME as VehicleName
	, DV.ZRVEHICLECODE as VehicleCode
	, DV.ZRVEHICLEIMAGE as VehicleImage
	, DL.ZRAtAirport
	, DL.ZRLocationName as pickupLocationName
	, DL.ZRAddress1 as pickupLocationAddress
	, DL.ZRAddress2
	, DL.ZRCityName as pickupCity
	, DL.ZRStateCode
	, DL.ZRStateName as pickupState
	, DL.ZRCountryCode as pickupCountry
	, DL.ZRPhoneNumbers
	, DL.ZRLocationName as dropoffLocationName
	, DL.ZRAddress1 as dropoffLocationAddress
	, DL.ZRCityName as dropoffCity
	, DL.ZRStateName as dropoffState
	, DL.ZRCountryCode as dropoffCountry
	, DV.ZRPASSENGERQUANTITY as Passenger
	, DV.ZRBAGGAGEQUANTITY as Baggage
	, S.VehicleClass as SippCodeDescription
	, S.VehicleClass as SippCodeClass
	, V.CompanyNameCode as CompanyNameCode
    , V.CompanyShortName as CompanyShortName
    , V.RequestorId as RequestorId
    , V.RequestorIdType as RequestorIdType
    , V.IATANo as IATANo
    ,R.contractCode
 FROM  
	CarContent.dbo.DollarVehicles DV					WITH(NOLOCK)
	INNER JOIN CarContent.dbo.DollarLocations DL		WITH(NOLOCK) ON DV.ZRLOCATIONCODE = DL.ZRLocationCode
	INNER JOIN dbo.CarResponse R						WITH(NOLOCK) ON R.carLocationCode =left(DV.ZRLOCATIONCODE,3) 
	AND DV.ZRVEHICLECODE = R.carCategoryCode AND DL.ZRAtAirport=1 AND R.carVendorKey = 'ZR'
    INNER JOIN CarContent.dbo.CarCompanies C			WITH(NOLOCK) ON C.CarCompanyCode   = R.carVendorKey
    INNER JOIN CarContent.dbo.DirectConnectSipCodes S	WITH(NOLOCK) ON DV.ZRVEHICLECLASSSIZE = S.VehicleClassSize
    LEFT OUTER JOIN  dbo.CarRequest						WITH(NOLOCK) ON R.carRequestKey = dbo.CarRequest.carRequestKey
    LEFT OUTER JOIN Vault.dbo.CarDirectConnectVendors V WITH (NOLOCK) ON V.VendorCode = 'ZR'

UNION ALL
SELECT 
	 C.CarCompanyName 
	, R.carResponseKey
	, R.carRequestKey 
	, R.carVendorKey 
	, R.supplierId
	, R.carCategoryCode
	, R.carLocationCode
	, R.carLocationCategoryCode
	, R.minRate AS PerDayRate
	, R.minRateTax
	, R.TotalChargeAmt
	, R.minRate
	, R.RateQualifier
    , R.ReferenceType
    , R.ReferenceDateTime
    , R.ReferenceId  
    , dbo.CarRequest.pickupDate
	, dbo.CarRequest.dropoffDate
	, 'ZT' as VENDORCODE --Thrifty
    , TV.ZTLOCATIONCODE as LocationCode
	, TV.ZTTRANSMISSIONTYPE as VechileTransmission
	, TV.ZTAIRCONDITIONIND as VechileAirConditioning
	, TV.ZTBAGGAGEQUANTITY
	, TV.ZTPASSENGERQUANTITY
	, TV.ZTVEHICLECATEGORY as VehicleCategory
	, TV.ZTDOORCOUNT as vehicleDoorCount
	, TV.ZTVEHICLECLASSSIZE as VehicleClassSize
	, TV.ZTVEHICLENAME as VehicleName
	, TV.ZTVEHICLECODE as VehicleCode
	, TV.ZTVEHICLEIMAGE as VehicleImage
	, TL.ZTAtAirport
	, TL.ZTLocationName as pickupLocationName
	, TL.ZTAddress1 as pickupLocationAddress
	, TL.ZTAddress2
	, TL.ZTCityName as pickupCity
	, TL.ZTStateCode
	, TL.ZTStateName as pickupState
	, TL.ZTCountryCode as pickupCountry
	, TL.ZTPhoneNumbers
	, TL.ZTLocationName as dropoffLocationName
	, TL.ZTAddress1 as dropoffLocationAddress
	, TL.ZTCityName as dropoffCity
	, TL.ZTStateName as dropoffState
	, TL.ZTCountryCode as dropoffCountry
	, TV.ZTPASSENGERQUANTITY as Passenger
	, TV.ZTBAGGAGEQUANTITY as Baggage
	, S.VehicleClass as SippCodeDescription
	, S.VehicleClass as SippCodeClass
	, V.CompanyNameCode as CompanyNameCode
    , V.CompanyShortName as CompanyShortName
    , V.RequestorId as RequestorId
    , V.RequestorIdType as RequestorIdType
    , V.IATANo as IATANo
    ,R.contractCode

FROM  
	CarContent.dbo.ThriftyVehicles TV					WITH(NOLOCK)
	INNER JOIN CarContent.dbo.ThriftyLocations TL		WITH(NOLOCK) ON TV.ZTLOCATIONCODE = TL.ZTLocationCode
	INNER JOIN dbo.CarResponse R						WITH(NOLOCK) ON R.carLocationCode =left(TV.ZTLOCATIONCODE,3) 
	AND TV.ZTVEHICLECODE = R.carCategoryCode AND TL.ZTAtAirport=1 AND R.carVendorKey = 'ZT'
	INNER JOIN CarContent.dbo.CarCompanies C			WITH(NOLOCK) ON C.CarCompanyCode   = R.carVendorKey
    INNER JOIN CarContent.dbo.DirectConnectSipCodes S	WITH(NOLOCK) ON TV.ZTVEHICLECLASSSIZE = S.VehicleClassSize
    LEFT OUTER JOIN  dbo.CarRequest						WITH(NOLOCK) ON R.carRequestKey = dbo.CarRequest.carRequestKey
    LEFT OUTER JOIN Vault.dbo.CarDirectConnectVendors V WITH (NOLOCK) ON V.VendorCode = 'ZT'
GO
