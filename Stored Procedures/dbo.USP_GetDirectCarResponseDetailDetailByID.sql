SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec USP_GetDirectCarResponseDetailDetailByID '19f02b5a-58a1-4d55-a34a-a3507427a7ed'  
CREATE PROCEDURE [dbo].[USP_GetDirectCarResponseDetailDetailByID]  
@CarResponseDetailDetailID nvarchar(50)  
as
DECLARE @VendorKey VARCHAR(10)

SELECT @VendorKey = carVendorKey 
FROM    
	vw_DirectCarResponse
WHERE carResponseKey = (SELECT carResponseKey 
						FROM CarResponseDetail 
						WHERE  upper(dbo.CarResponseDetail.CarResponseDetailKey) = upper (@CarResponseDetailDetailID))
IF @VendorKey = 'AL'
BEGIN
select  
   DR.carResponseKey,  
   carRequestKey,  
   DR.minRate,  
   DR.minRateTax,  
   pickupDate,  
   dropoffDate,  
   dropoffLocationAddress,  
   pickupLocationAddress,  
   dropoffLocationName,   
   AV.ALVEHICLENAME as VehicleName ,  
   AV.ALTRANSMISSIONTYPE as VechileTransmission,   
   AV.ALAIRCONDITIONIND as VechileAirConditioning,  
   dropoffCity,  
   dropoffState,   
   dropoffCountry,  
   pickupCity,
   pickupState,   
   pickupCountry,  
   TotalChargeAmt,  
   VehicleCategory,  
   S.VehicleClass,
   AV.ALVEHICLECLASSSIZE as VehicleClassSize,  
   DR.carLocationCode,  
   DR.carVendorKey,
   DR.supplierId,   
   CD.carCategoryCode,
   DR.RateQualifier,
   DR.ReferenceType,
   DR.ReferenceDateTime,
   DR.ReferenceId,
   DR.RequestorId,
   DR.RequestorIdType,
   DR.CompanyNameCode,
   DR.CompanyShortName ,
   DR.IATANo
FROM    
	vw_DirectCarResponse DR
	INNER JOIN CarResponseDetail  CD ON DR.carResponseKey = CD.carResponseKey
	AND upper(CD.CarResponseDetailKey) = upper (@CarResponseDetailDetailID)
    LEFT OUTER JOIN CarContent.dbo.ALAMOVEHICLES AV 
										ON LEFT(AV.ALLOCATIONCODE,3) = DR.carLocationCode
										AND AV.ALVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey 
   INNER JOIN CarContent.dbo.AlamoLocations AL WITH(NOLOCK) ON AL.ALLOCATIONCODE = AV.ALLOCATIONCODE AND AL.ALAtAirport = 1
   INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  AV.ALVEHICLECLASSSIZE =S.VehicleClassSize
  END
  ELSE IF @VendorKey = 'ZL'
  BEGIN
  select  
   DR.carResponseKey,  
   carRequestKey,  
   DR.minRate,  
   DR.minRateTax,  
   pickupDate,  
   dropoffDate,  
   dropoffLocationAddress,  
   pickupLocationAddress,  
   dropoffLocationName,   
   ZL.ZLVEHICLENAME as VehicleName ,  
   ZL.ZLTRANSMISSIONTYPE as VechileTransmission,   
   ZL.ZLAIRCONDITIONIND as VechileAirConditioning,  
   dropoffCity,  
   dropoffState,   
   dropoffCountry,  
   pickupCity,
   pickupState,   
   pickupCountry,  
   TotalChargeAmt,  
   VehicleCategory,  
   S.VehicleClass,
   ZL.ZLVEHICLECLASSSIZE as VehicleClassSize,  
   DR.carLocationCode,  
   DR.carVendorKey,
   DR.supplierId,   
   CD.carCategoryCode,
   DR.RateQualifier,
   DR.ReferenceType,
   DR.ReferenceDateTime,
   DR.ReferenceId,
   DR.RequestorId,
   DR.RequestorIdType,
   DR.CompanyNameCode,
   DR.CompanyShortName,
   DR.IATANo
FROM    
	vw_DirectCarResponse DR
	INNER JOIN CarResponseDetail  CD ON DR.carResponseKey = CD.carResponseKey
	AND upper(CD.CarResponseDetailKey) = upper (@CarResponseDetailDetailID)
	LEFT OUTER JOIN CarContent.dbo.NationalVehicles ZL 
										ON LEFT(ZL.ZLLOCATIONCODE,3) = DR.carLocationCode
										AND ZL.ZLVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey
   INNER JOIN CarContent.dbo.NationalLocations NL WITH(NOLOCK) ON ZL.ZLLOCATIONCODE = NL.ZLLocationCode AND NL.ZLAtAirport = 1
   INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  ZL.ZLVEHICLECLASSSIZE =S.VehicleClassSize
  END
  ELSE IF @VendorKey = 'ZR'
  BEGIN
  select  
   DR.carResponseKey,  
   carRequestKey,  
   DR.minRate,  
   DR.minRateTax,  
   pickupDate,  
   dropoffDate,  
   dropoffLocationAddress,  
   pickupLocationAddress,  
   dropoffLocationName,   
   ZR.ZRVEHICLENAME as VehicleName ,  
   ZR.ZRTRANSMISSIONTYPE as VechileTransmission,   
   ZR.ZRAIRCONDITIONIND as VechileAirConditioning,  
   dropoffCity,  
   dropoffState,   
   dropoffCountry,  
   pickupCity,
   pickupState,   
   pickupCountry,  
   TotalChargeAmt,  
   VehicleCategory,  
   S.VehicleClass,
   ZR.ZRVEHICLECLASSSIZE as VehicleClassSize,  
   CD.carLocationCode,  
   DR.carVendorKey,
   DR.supplierId,   
   DR.carCategoryCode,
   DR.RateQualifier,
   DR.ReferenceType,
   DR.ReferenceDateTime,
   DR.ReferenceId,
   DR.RequestorId,
   DR.RequestorIdType,
   DR.CompanyNameCode,
   DR.CompanyShortName,
   DR.IATANo
FROM    
	vw_DirectCarResponse DR
	INNER JOIN CarResponseDetail  CD ON DR.carResponseKey = CD.carResponseKey
	AND upper(CD.CarResponseDetailKey) = upper (@CarResponseDetailDetailID)
	LEFT OUTER JOIN CarContent.dbo.DollarVehicles ZR
										ON LEFT(ZR.ZRLOCATIONCODE,3) = DR.carLocationCode
										AND ZR.ZRVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey 
   INNER JOIN CarContent.dbo.DollarLocations DL WITH(NOLOCK) ON DL.ZRLocationCode = ZR.ZRLOCATIONCODE AND DL.ZRAtAirport = 1
   INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  ZR.ZRVEHICLECLASSSIZE =S.VehicleClassSize
  END
  ELSE IF @VendorKey = 'ZT'
  BEGIN
  select  
   DR.carResponseKey,  
   carRequestKey,  
   DR.minRate,  
   DR.minRateTax,  
   pickupDate,  
   dropoffDate,  
   dropoffLocationAddress,  
   pickupLocationAddress,  
   dropoffLocationName,   
   ZT.ZTVEHICLENAME as VehicleName ,  
   ZT.ZTTRANSMISSIONTYPE as VechileTransmission,   
   ZT.ZTAIRCONDITIONIND as VechileAirConditioning,  
   dropoffCity,  
   dropoffState,   
   dropoffCountry,  
   pickupCity,
   pickupState,   
   pickupCountry,  
   TotalChargeAmt,  
   VehicleCategory,  
   S.VehicleClass,
   ZT.ZTVEHICLECLASSSIZE as VehicleClassSize,  
   DR.carLocationCode,  
   DR.carVendorKey,
   DR.supplierId,   
   CD.carCategoryCode,
   DR.RateQualifier,
   DR.ReferenceType,
   DR.ReferenceDateTime,
   DR.ReferenceId,
   DR.RequestorId,
   DR.RequestorIdType,
   DR.CompanyNameCode,
   DR.CompanyShortName,
   DR.IATANo    
FROM    
	vw_DirectCarResponse DR
	INNER JOIN CarResponseDetail  CD ON DR.carResponseKey = CD.carResponseKey
	AND upper(CD.CarResponseDetailKey) = upper (@CarResponseDetailDetailID)
	 LEFT OUTER JOIN CarContent.dbo.ThriftyVehicles ZT
										ON LEFT(ZT.ZTLOCATIONCODE,3) = DR.carLocationCode
										AND ZT.ZTVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey
   INNER JOIN CarContent.dbo.ThriftyLocations TL WITH(NOLOCK) ON TL.ZTLocationCode = ZT.ZTLOCATIONCODE AND TL.ZTAtAirport = 1
   INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  ZT.ZTVEHICLECLASSSIZE  =S.VehicleClassSize
  END
  

   
GO
