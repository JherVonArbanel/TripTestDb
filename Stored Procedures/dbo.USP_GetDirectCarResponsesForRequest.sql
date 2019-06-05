SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetDirectCarResponsesForRequest] 1923 
CREATE proc [dbo].[USP_GetDirectCarResponsesForRequest]
( @CarRequestKey int ,
  @carVendors varchar(200)='',
  @sortField varchar(50)='',
  @carClasses varchar(200)='',
  @carTypes varchar(200)='',
  @Price float=9999999999.99
 )
as
begin
Declare @sortColumn varchar(50)
Declare @sqlString varchar(2000)
 IF @sortField <> ''
		 BEGIN
			IF @sortField = 'Price'
			   BEGIN
				 SET @sortColumn = 'minRate'
			   END
			ELSE IF @sortField = 'Airport'
			   BEGIN
				 SET @sortColumn = 'pickupLocationName' 
			   END
			   ELSE IF @sortField = 'CarVendor'
			   BEGIN
				 SET @sortColumn = 'CarCompanyName'
			   END
			end   
IF @sortField = ''
BEGIN
	SELECT 
			vwCarResponse.carResponseKey,
			vwCarResponse.carRequestKey,
			vwCarResponse.carVendorKey,
			vwCarResponse.supplierId,
			vwCarResponse.carCategoryCode,
			vwCarResponse.carLocationCode,
			vwCarResponse.carLocationCategoryCode,
			isnull(A.PerDayminRate , vwCarResponse.PerDayRate)    PerDayRate,
			vwCarResponse.VehicleName,
			vwCarResponse.pickupLocationName,
			vwCarResponse.pickupLocationAddress,
			vwCarResponse.dropoffLocationAddress,
			vwCarResponse.dropoffLocationName,
			vwCarResponse.pickupDate,
			vwCarResponse.dropoffDate,
			vwCarResponse.VechileTransmission,
			vwCarResponse.VechileAirConditioning,
			vwCarResponse.VehicleName,
			vwCarResponse.VehicleCategory,
			vwCarResponse.VehicleClassSize ,
			vwCarResponse.CarCompanyName,
			vwCarResponse.dropoffCity,
			vwCarResponse.dropoffState,
			vwCarResponse.dropoffCountry,
			vwCarResponse.pickupCity,
			vwCarResponse.pickupState,
			vwCarResponse.pickupCountry,
			vwCarResponse.minRateTax,
			vwCarResponse.TotalChargeAmt,
			isnull(A.PerDayminRate , vwCarResponse.minRate)    minRate,
			vwCarResponse.passenger,
			vwCarResponse.baggage,
			S.VehicleClass as SippCodeDescription, --vwCarResponse.SippCodeDescription, 
		    S.VehicleClass as SippCodeClass, --vwCarResponse.SippCodeClass,
			vwCarResponse.RateQualifier,
			vwCarResponse.ReferenceType,
			vwCarResponse.ReferenceDateTime,
			vwCarResponse.ReferenceId,
			vwCarResponse.RequestorId,
			vwCarResponse.RequestorIdType,
			vwCarResponse.CompanyNameCode,
			vwCarResponse.CompanyShortName,
			vwCarResponse.IATANo,
			vwCarResponse.contractCode
			
	FROM vw_DirectCarResponse vwCarResponse
	LEFT JOIN
	(  SELECT  CD.carVendorKey, MIN(CD.minRate) as PerDayminRate  , CD.carResponseKey ,CR.carCategoryCode as SippCodeCarType --CarContent.dbo.SippCodes.SippCodeCarType as SippCodeCarType   
		 FROM carresponsedetail CD 
		 INNER JOIN carresponse CR on CD.carResponseKey = CR.carResponseKey  and CR.carRequestKey = @CarRequestKey 
		 --INNER JOIN CarContent.dbo.SippCodes ON CR.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType
		 GROUP BY CD.carVendorKey, CD.carResponseKey ,CR.carCategoryCode  --CarContent.dbo.DirectConnectSipCodes.SippCodeCarType
	 ) AS A  ON vwCarResponse.carResponseKey = A.carResponseKey 
	INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  vwCarResponse.VehicleClassSize =S.VehicleClassSize
	WHERE vwCarResponse.carRequestKey=@CarRequestKey
	--and vwCarResponse.PerDayRate<= @Price and PerDayminRate <> 0  
	ORDER BY minRate,pickupLocationName,CarCompanyName 
 
 --Start
 SELECT * FROM
 ( 	SELECT	CD.carResponseDetailKey,
			CD.carVendorKey as carCompany ,
			DR.CarCompanyname, 
			MIN (CD.minRate)as LowestPrice,
			CD.carCategoryCode as carClassCat,
			S.VehicleClass as carClassDes ,
			CD.NoOfDays,
			AL.ALVEHICLEIMAGE as VehicleImage,
			AL.ALVEHICLENAME as VehicleName,
			CR.carLocationCode,
			DR.pickupCity,
			DR.pickupLocationAddress,
			DR.dropoffLocationAddress,
			DR.pickupDate,
			DR.TotalChargeAmt,
			DR.carResponseKey,
		    AL.ALPASSENGERQUANTITY as passenger, 
			AL.ALBAGGAGEQUANTITY as Baggage
	FROM	vw_DirectCarResponse DR
	INNER JOIN  carresponsedetail CD 	ON CD.carresponsekey=DR.carResponseKey
	INNER JOIN CarResponse CR			ON CR.carResponseKey=CD.carResponseKey
    --INNER JOIN CarContent.dbo.SippCodes ON CD.carCategoryCode=CarContent.dbo.SippCodes.SippCodeCarType
    LEFT OUTER JOIN CarContent.dbo.ALAMOVEHICLES AL 
										ON left(AL.ALLOCATIONCODE,3) = DR.carLocationCode
										AND AL.ALVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey 
    INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  AL.ALVEHICLECLASSSIZE =S.VehicleClassSize
	WHERE DR.carRequestKey=@CarRequestKey AND DR.VENDORCODE = 'AL'
	GROUP BY CD.carVendorKey,
			 DR.CarCompanyname,
			 CD.carCategoryCode,
			 S.VehicleClass,
			 AL.ALVEHICLEIMAGE,
			 AL.ALVEHICLENAME,
			 CD.carResponseDetailKey,
			 CD.minRate,
			 CD.NoOfDays,
			 CR.carLocationCode,
			 DR.pickupCity,
			 DR.pickupLocationAddress,
			 DR.dropoffLocationAddress,
			 DR.pickupDate,
			 DR.TotalChargeAmt,
			 DR.carResponseKey,
			 AL.ALPASSENGERQUANTITY, 
			 AL.ALBAGGAGEQUANTITY
	--ORDER BY CD.minRate
	UNION ALL
	SELECT	CD.carResponseDetailKey,
			CD.carVendorKey as carCompany ,
			DR.CarCompanyname, 
			MIN (CD.minRate)as LowestPrice,
			CD.carCategoryCode as carClassCat,
			S.VehicleClass as carClassDes ,
			CD.NoOfDays,
			ZL.ZLVEHICLEIMAGE as VehicleImage,
			ZL.ZLVEHICLENAME as VehicleName,
			CR.carLocationCode,
			DR.pickupCity,
			DR.pickupLocationAddress,
			DR.dropoffLocationAddress,
			DR.pickupDate,
			DR.TotalChargeAmt,
			DR.carResponseKey,
			ZL.ZLPASSENGERQUANTITY as Passenger, 
			ZL.ZLBAGGAGEQUANTITY as Baggage
	FROM	vw_DirectCarResponse DR
	INNER JOIN  carresponsedetail CD 	ON CD.carresponsekey=DR.carResponseKey
	INNER JOIN CarResponse CR			ON CR.carResponseKey=CD.carResponseKey
    --INNER JOIN CarContent.dbo.SippCodes ON CD.carCategoryCode=CarContent.dbo.SippCodes.SippCodeCarType
    LEFT OUTER JOIN CarContent.dbo.NationalVehicles ZL 
										ON left(ZL.ZLLOCATIONCODE,3) = DR.carLocationCode
										AND ZL.ZLVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey 
    INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  ZL.ZLVEHICLECLASSSIZE =S.VehicleClassSize
	WHERE DR.carRequestKey=@CarRequestKey AND DR.VENDORCODE = 'ZL'
	GROUP BY CD.carVendorKey,
			 DR.CarCompanyname,
			 CD.carCategoryCode,
			 S.VehicleClass,
			 ZL.ZLVEHICLEIMAGE,
			 ZL.ZLVEHICLENAME,
			 CD.carResponseDetailKey,
			 CD.minRate,
			 CD.NoOfDays,
			 CR.carLocationCode,
			 DR.pickupCity,
			 DR.pickupLocationAddress,
			 DR.dropoffLocationAddress,
			 DR.pickupDate,
			 DR.TotalChargeAmt,
			 DR.carResponseKey,
			 ZL.ZLPASSENGERQUANTITY, 
			 ZL.ZLBAGGAGEQUANTITY
	--ORDER BY CD.minRate
	UNION ALL
	SELECT	CD.carResponseDetailKey,
			CD.carVendorKey as carCompany ,
			DR.CarCompanyname, 
			MIN (CD.minRate)as LowestPrice,
			CD.carCategoryCode as carClassCat,
			S.VehicleClass as carClassDes ,
			CD.NoOfDays,
			ZR.ZRVEHICLEIMAGE as VehicleImage,
			ZR.ZRVEHICLENAME as VehicleName,
			CR.carLocationCode,
			DR.pickupCity,
			DR.pickupLocationAddress,
			DR.dropoffLocationAddress,
			DR.pickupDate,
			DR.TotalChargeAmt,
			DR.carResponseKey,
			ZR.ZRPASSENGERQUANTITY as Passenger, 
			ZR.ZRBAGGAGEQUANTITY as Baggage
	FROM	vw_DirectCarResponse DR
	INNER JOIN  carresponsedetail CD 	ON CD.carresponsekey=DR.carResponseKey
	INNER JOIN CarResponse CR			ON CR.carResponseKey=CD.carResponseKey
    --INNER JOIN CarContent.dbo.SippCodes ON CD.carCategoryCode=CarContent.dbo.SippCodes.SippCodeCarType
    LEFT OUTER JOIN CarContent.dbo.DollarVehicles ZR
										ON left(ZR.ZRLOCATIONCODE,3) = DR.carLocationCode
										AND ZR.ZRVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey 
    INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  ZR.ZRVEHICLECLASSSIZE =S.VehicleClassSize
	WHERE DR.carRequestKey=@CarRequestKey AND DR.VENDORCODE = 'ZR'
	GROUP BY CD.carVendorKey,
			 DR.CarCompanyname,
			 CD.carCategoryCode,
			 S.VehicleClass,
			 ZR.ZRVEHICLEIMAGE,
			 ZR.ZRVEHICLENAME,
			 CD.carResponseDetailKey,
			 CD.minRate,
			 CD.NoOfDays,
			 CR.carLocationCode,
			 DR.pickupCity,
			 DR.pickupLocationAddress,
			 DR.dropoffLocationAddress,
			 DR.pickupDate,
			 DR.TotalChargeAmt,
			 DR.carResponseKey,
			 ZR.ZRPASSENGERQUANTITY, 
			 ZR.ZRBAGGAGEQUANTITY
	--ORDER BY CD.minRate
	UNION ALL
	SELECT	CD.carResponseDetailKey,
			CD.carVendorKey as carCompany ,
			DR.CarCompanyname, 
			MIN (CD.minRate)as LowestPrice,
			CD.carCategoryCode as carClassCat,
			S.VehicleClass as carClassDes ,
			CD.NoOfDays,
			ZT.ZTVEHICLEIMAGE as VehicleImage,
			ZT.ZTVEHICLENAME as VehicleName,
			CR.carLocationCode,
			DR.pickupCity,
			DR.pickupLocationAddress,
			DR.dropoffLocationAddress,
			DR.pickupDate,
			DR.TotalChargeAmt,
			DR.carResponseKey,
			ZT.ZTPASSENGERQUANTITY as Passenger, 
			ZT.ZTBAGGAGEQUANTITY as Baggage
	FROM	vw_DirectCarResponse DR
	INNER JOIN  carresponsedetail CD 	ON CD.carresponsekey=DR.carResponseKey
	INNER JOIN CarResponse CR			ON CR.carResponseKey=CD.carResponseKey
    --INNER JOIN CarContent.dbo.SippCodes ON CD.carCategoryCode=CarContent.dbo.SippCodes.SippCodeCarType
    LEFT OUTER JOIN CarContent.dbo.ThriftyVehicles ZT
										ON left(ZT.ZTLOCATIONCODE,3) = DR.carLocationCode
										AND ZT.ZTVEHICLECODE = CD.carCategoryCode
										AND DR.VendorCode=CD.carVendorKey
    INNER JOIN CarContent.dbo.DirectConnectSipCodes S ON  ZT.ZTVEHICLECLASSSIZE =S.VehicleClassSize
	WHERE DR.carRequestKey=@CarRequestKey AND DR.VENDORCODE = 'ZT'
	GROUP BY CD.carVendorKey,
			 DR.CarCompanyname,
			 CD.carCategoryCode,
			 S.VehicleClass,
			 ZT.ZTVEHICLEIMAGE,
			 ZT.ZTVEHICLENAME,
			 CD.carResponseDetailKey,
			 CD.minRate,
			 CD.NoOfDays,
			 CR.carLocationCode,
			 DR.pickupCity,
			 DR.pickupLocationAddress,
			 DR.dropoffLocationAddress,
			 DR.pickupDate,
			 DR.TotalChargeAmt,
			 DR.carResponseKey,
			 ZT.ZTPASSENGERQUANTITY, 
			 ZT.ZTBAGGAGEQUANTITY
			 ) A 
	ORDER BY LowestPrice
	
	--end	
	
	SELECT	COUNT(*) AS NoOfCars,
			CD.carCategoryCode
	  FROM  vw_DirectCarResponse DR
	  INNER JOIN  carresponsedetail CD ON CD.carresponsekey=DR.carResponseKey
      WHERE CarRequestKey=@CarRequestKey
	  GROUP BY CD.carCategoryCode
      ORDER BY CD.carCategoryCode
  
	SELECT  MIN(minrate) AS FilterLowestPrice,
			carVendorKey AS FilterCarCompany,
			CarCompanyname 
	FROM vw_DirectCarResponse
	WHERE CarRequestKey= @CarRequestKey 
	GROUP BY carVendorKey,CarCompanyname
	
	SELECT  MIN(minRate)as LowestPrice ,
			MAX (minRate)as HighestPrice 
	 FROM   vw_DirectCarResponse 
	 WHERE CarRequestKey=@CarRequestKey
	 
	 SELECT SippCodeClass as carClassCat , 
			MIN (minRate)as LowestPrice 
	 FROM vw_DirectCarResponse 
	 WHERE CarRequestKey=@CarRequestKey 
	 GROUP BY SippCodeClass

 end
 
ELSE
BEGIN
	 print @sortField
	 SET @sqlString ='SELECT * FROM vw_DirectCarResponse where carRequestKey= '+CONVERT(varchar,@CarRequestKey)
	+' and  minRate<='+ CONVERT(varchar,@Price)
	+ ' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'
	
	 exec(@sqlString)
	 print @sqlString
  
	 SELECT CD.carResponseDetailKey,
			CD.carVendorKey as carCompany, 
			vw_DirectCarResponse.CarCompanyname, 
			MIN (CD.minRate)as LowestPrice,
			CD.carCategoryCode as carClassCat,
			--CarContent .dbo.SippCodes.SippCodeDescription as carClassDes ,
			vw_DirectCarResponse.SippCodeDescription as carClassDes,
			vw_DirectCarResponse.vehicleImage,
			vw_DirectCarResponse.VehicleName,
			vw_DirectCarResponse.passenger, 
			vw_DirectCarResponse.baggage
	 FROM vw_DirectCarResponse
	 INNER JOIN
	 carresponsedetail CD  ON CD.carresponsekey=vw_DirectCarResponse.carResponseKey
	 AND vw_DirectCarResponse.VehicleCode = CD.carCategoryCode
	 AND vw_DirectCarResponse.VENDORCODE = CD.carVendorKey
	 --INNER JOIN CarContent .dbo.SippCodes ON CD.carCategoryCode=CarContent.dbo.SippCodes.SippCodeCarType
	 WHERE CarRequestKey=@CarRequestKey
	 GROUP BY	CD.carVendorKey,
				vw_DirectCarResponse.CarCompanyname,
				CD.carCategoryCode,
				--CarContent .dbo.SippCodes.SippCodeDescription,
				vw_DirectCarResponse.SippCodeDescription,
				vw_DirectCarResponse.vehicleImage,
				vw_DirectCarResponse.VehicleName,
				CD.carResponseDetailKey,CD.minRate,
				vw_DirectCarResponse.passenger, 
				vw_DirectCarResponse.baggage
	 ORDER BY   CD.minRate

	SELECT  COUNT(*)  as NoOfCars,
			CD.carCategoryCode
	FROM	vw_DirectCarResponse
	INNER JOIN 	carresponsedetail CD ON CD.carresponsekey=vw_DirectCarResponse.carResponseKey
    WHERE CarRequestKey=@CarRequestKey
	GROUP BY CD.carCategoryCode
    ORDER BY CD.carCategoryCode
 
	SELECT	MIN(minrate) as FilterLowestPrice,
			carVendorKey as FilterCarCompany,
			CarCompanyname 
	FROM    vw_DirectCarResponse
    WHERE   CarRequestKey= @CarRequestKey 
   GROUP BY carVendorKey,CarCompanyname
  
	SELECT	MIN (minRate)as LowestPrice ,
			MAX (minRate)as HighestPrice 
	FROM	vw_DirectCarResponse 
	WHERE   CarRequestKey=@CarRequestKey
	
	 SELECT SippCodeClass as carClassCat , 
			MIN (minRate)as LowestPrice 
	 FROM vw_DirectCarResponse 
	 WHERE CarRequestKey=@CarRequestKey 
	 GROUP BY SippCodeClass

 end
end
GO
