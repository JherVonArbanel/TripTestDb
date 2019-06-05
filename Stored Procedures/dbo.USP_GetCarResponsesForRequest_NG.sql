SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- exec [USP_GetCarResponsesForRequest] 115278,'','','','',9999999999.99 - 3E5CB5B7-C1A0-420A-BBB4-D2665BEF667C    
-- exec USP_GetCarResponsesForRequest @carRequestKey=32124,@Price=70, @sortField = 'CarVendor'
    --USP_GetCarResponsesForRequest_NG @carRequestKey=32124,@Price=70
CREATE PROCEDURE [dbo].[USP_GetCarResponsesForRequest_NG]    
( @CarRequestKey int ,    
  @carVendors varchar(200)='',    
  @sortField varchar(50)='',    
  @carClasses varchar(200)='',    
  @carTypes varchar(200)='',    
  @Price float=9999999999.99    
      
 )    
as    
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
       
	DECLARE @tmpSabreCarResponse AS TABLE
	(
		[carResponseKey] [uniqueidentifier] NOT NULL,
		[carRequestKey] [int] NOT NULL,
		[carVendorKey] [varchar](50) NOT NULL,
		[supplierId] [varchar](50) NOT NULL,
		[carCategoryCode] [varchar](50) NOT NULL,
		[carLocationCode] [varchar](50) NOT NULL,
		[carLocationCategoryCode] [varchar](50) NOT NULL
		,[carDropOffLocationCode] [varchar](50) NULL
		,[carDropOffLocationCategoryCode] [varchar](50) NULL
		,[PerDayRate] [float] NOT NULL
		,[VehicleName] [nvarchar](64) NULL
		,[pickupLocationName] [nvarchar](256) NULL
		,[pickupLocationAddress] [nvarchar](128) NULL
		,[pickupLatitude] [float] NULL
		,[pickupLongitude] [float] NULL
		,[pickupZipCode] [nvarchar](16) NULL
		,[dropoffLatitude] [float] NULL
		,[dropoffLongitude] [float] NULL
		,[dropoffZipCode] [nvarchar](16) NULL
		,[dropoffLocationAddress] [nvarchar](128) NULL
		,[dropoffLocationName] [nvarchar](256) NULL
		,[pickupDate] [datetime] NOT NULL
		,[dropoffDate] [datetime] NOT NULL
		,[SippCodeDescription] [nvarchar](64) NULL
		,[SippCodeTransmission] [nvarchar](32) NULL
		,[SippCodeAC] [nvarchar](100) NULL
		,[CarCompanyName] [nvarchar](64) NULL
		,[SippCodeClass] [nvarchar](32) NULL
		,[dropoffCity] [nvarchar](64) NULL
		, [dropoffState] [nvarchar](32) NULL
		, [dropoffCountry] [nvarchar](64) NULL
		, [pickupCity] [nvarchar](64) NULL
		, [pickupState] [nvarchar](32) NULL
		, [pickupCountry] [nvarchar](64) NULL
		, [minRateTax] [float] NOT NULL
		, [TotalChargeAmt] [float] NULL
		, [minRate] [float] NOT NULL
		, [passenger] [nvarchar](50) NULL
		, [Baggage] [nvarchar](50) NULL
		, [MileageAllowance] [varchar](10) NULL
		, [RatePlan] [varchar](10) NULL
		, [contractCode] [varchar](20) NULL
		, [OperationTimeStart] [varchar](10) NULL
		, [OperationTimeEnd] [varchar](10) NULL
		, [pickupCityCode] [varchar](50) NOT NULL
		, [dropoffCityCode] [varchar](3) NOT NULL
		, [pickupairport] [varchar](100) NULL
		, [dropoffairport] [varchar](100) NULL
	)
	DECLARE @tmpCarVendor AS TABLE(carVendorKey NVARCHAR(5), PerDayminRate FLOAT, carResponseKey UNIQUEIDENTIFIER, SippCodeCarType NVARCHAR(10))

	INSERT INTO @tmpSabreCarResponse
	SELECT dbo.CarResponse.carResponseKey, dbo.CarResponse.carRequestKey, dbo.CarResponse.carVendorKey, dbo.CarResponse.supplierId, 
		  dbo.CarResponse.carCategoryCode, dbo.CarResponse.carLocationCode, dbo.CarResponse.carLocationCategoryCode,CarResponse.carDropOffLocationCode,CarResponse.carDropOffLocationCategoryCode, dbo.CarResponse.minRate AS PerDayRate, 
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
		  dbo.CarResponse.RatePlan, dbo.CarResponse.contractCode,dbo.CarResponse.OperationTimeStart,dbo.CarResponse.OperationTimeEnd
		  ,dbo.CarRequest.pickupCityCode, dbo.CarRequest.dropoffCityCode
		  , (SELECT top 1 AirportName from dbo.AirportLookup where AirportCode = dbo.CarRequest.pickupCityCode) as pickupairport
		  , (SELECT top 1 AirportName from dbo.AirportLookup where AirportCode = dbo.CarRequest.dropoffCityCode) as dropoffairport
	FROM         CarContent.dbo.CarCompanies WITH (NOLOCK) 
		  INNER JOIN  dbo.CarResponse ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey 
		  INNER JOIN  CarContent.dbo.SippCodes WITH (NOLOCK) ON dbo.CarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
		  INNER JOIN  CarContent.dbo.SabreVehicles WITH (NOLOCK) ON dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
						AND dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
						AND dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
						AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode 
		  INNER JOIN  CarContent.dbo.SabreLocations WITH (NOLOCK) ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode 
		  INNER JOIN  CarContent.dbo.SabreLocations AS SabreLocations_1 WITH (NOLOCK) ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode 
						AND SabreLocations_1.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
						AND SabreLocations_1.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
		  INNER JOIN dbo.CarRequest WITH (NOLOCK) ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey 
						AND dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationAirportCode 
						AND dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationCategoryCode 
						AND dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationAirportCode 
						AND dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationCategoryCode
	WHERE dbo.CarResponse.carRequestKey=@CarRequestKey and dbo.CarResponse.minRate <= @Price
	
	IF @sortField = ''    
	begin    

		INSERT INTO @tmpCarVendor 
		select   CD.carVendorKey, MIN(CD.minRate) as PerDayminRate  , CD.carResponseKey 
			,CarContent.dbo.SippCodes.SippCodeCarType as SippCodeCarType 
		from carresponsedetail CD  WITH (NOLOCK)   
			Inner join carresponse Cd1 WITH (NOLOCK) on CD.carResponseKey = Cd1.carResponseKey  --and Cd1.carRequestKey = 32124     
			Inner join CarContent.dbo.SippCodes WITH (NOLOCK) ON cd1.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType    
		Group by  CD.carVendorKey, CD.carResponseKey ,CarContent.dbo.SippCodes.SippCodeCarType

		DELETE FROM @tmpCarVendor WHERE PerDayminRate <= 0

		SELECT     
			vwCarResponse.carResponseKey,    
			vwCarResponse.carRequestKey,    
			vwCarResponse.carVendorKey,    
			vwCarResponse.supplierId,    
			vwCarResponse.carCategoryCode,    
			vwCarResponse.carLocationCode,    
			vwCarResponse.carLocationCategoryCode,    
			--vwCarResponse.PerDayRate,    
			isnull(A.PerDayminRate , vwCarResponse.PerDayRate)    PerDayRate,    
			vwCarResponse.VehicleName,    
			vwCarResponse.pickupLocationName,    
			vwCarResponse.pickupLocationAddress,    
			vwCarResponse.pickupLatitude,    
			vwCarResponse.pickupLongitude,    
			vwCarResponse.pickupZipCode,    
			vwCarResponse.dropoffLatitude,    
			vwCarResponse.dropoffLongitude,    
			vwCarResponse.dropoffZipCode,    
			vwCarResponse.dropoffLocationAddress,    
			vwCarResponse.dropoffLocationName,    
			vwCarResponse.pickupDate,    
			vwCarResponse.dropoffDate,    
			vwCarResponse.SippCodeDescription,    
			vwCarResponse.SippCodeTransmission,    
			vwCarResponse.SippCodeAC,    
			vwCarResponse.CarCompanyName,    
			ISNULL(A.SippCodeCarType ,  vwCarResponse.SippCodeClass) as SippCodeCarType ,    
			--A.SippCodeCarType  as SippCodeCarType ,    
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
			vwCarResponse.MileageAllowance,   
			vwCarResponse.contractCode,
			vwCarResponse.OperationTimeStart,vwCarResponse.OperationTimeEnd,
			vwCarResponse.carDropOffLocationCode,
			vwCarResponse.carDropOffLocationCategoryCode
		FROM @tmpSabreCarResponse vwCarResponse    
		--Left join       
		--(  
		--	select   CD.carVendorKey, MIN(CD.minRate) as PerDayminRate  , CD.carResponseKey ,CarContent.dbo.SippCodes.SippCodeCarType as SippCodeCarType 
		--	from carresponsedetail CD  WITH (NOLOCK)   
		--		Inner join carresponse Cd1 WITH (NOLOCK) on CD.carResponseKey = Cd1.carResponseKey  and Cd1.carRequestKey = @CarRequestKey     
		--		Inner join CarContent.dbo.SippCodes WITH (NOLOCK) ON cd1.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType    
		--	Group by  CD.carVendorKey, CD.carResponseKey ,CarContent.dbo.SippCodes.SippCodeCarType
		--) as A  on vwCarResponse.carResponseKey = A.carResponseKey     
			LEFT JOIN @tmpCarVendor A  on vwCarResponse.carResponseKey = A.carResponseKey 
		--where vwCarResponse.carRequestKey=@CarRequestKey and vwCarResponse.PerDayRate<= @Price and PerDayminRate <> 0      
		ORDER BY minRate,pickupLocationName,CarCompanyName 
				 
		SELECT * FROM 
		(
		SELECT ROW_NUMBER() OVER(PARTITION BY vw_sabreCarResponse.carVendorKey, carresponsedetail.carCategoryCode ORDER BY carresponsedetail.minRate) RowNum, 
		carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey as carCompany ,vw_sabreCarResponse.CarCompanyname, MIN(carresponsedetail.minRate) as LowestPrice,    
		carresponsedetail.carCategoryCode as carClassCat,CarContent.dbo.SippCodes.SippCodeClass as carClassDes ,carresponsedetail.NoOfDays,    
		CarContent.dbo.SabreVehicles.ImageName, 
		CarContent.dbo.SabreVehicles.VehicleName,CarResponse.carLocationCode,vw_sabreCarResponse.pickupCity,    
		vw_sabreCarResponse.pickupLocationAddress,vw_sabreCarResponse.dropoffLocationAddress,vw_sabreCarResponse.pickupDate,vw_sabreCarResponse.TotalChargeAmt,    
		vw_sabreCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity as passenger, CarContent.dbo.SabreVehicles.baggage as baggage,
		carresponsedetail.minRateTax as minRateTax,CarContent.dbo.SippCodes.SippCodeTransmission, CarContent.dbo.SippCodes.SippCodeDescription,           
		   CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.SabreVehicles.VehicleName as newVehicleName, 'no-image.jpg' as newImageName,
		   vw_sabreCarResponse.pickupLatitude,vw_sabreCarResponse.pickupLongitude, carresponsedetail.contractCode, vw_sabreCarResponse.dropoffCity,
		   carresponse.PickupLocInfoCode, vw_sabreCarResponse.dropoffState as DropoffState, vw_sabreCarResponse.dropoffCountry as DropoffCountry
		   , vw_sabreCarResponse.pickupState as PickupState, vw_sabreCarResponse.pickupCountry as PickupCountry
		   ,vw_sabreCarResponse.dropoffDate, vw_sabreCarResponse.pickupCityCode, vw_sabreCarResponse.dropoffCityCode, vw_sabreCarResponse.pickupairport, vw_sabreCarResponse.dropoffairport
		 FROM @tmpSabreCarResponse vw_sabreCarResponse    
		 inner join    
		 carresponsedetail WITH (NOLOCK)   
		 on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey 
		 inner join CarResponse WITH (NOLOCK) on 
		 CarResponse.carResponseKey=CarResponseDetail.carResponseKey    
		 inner join CarContent .dbo.SippCodes WITH (NOLOCK)   on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType    
		 inner join CarContent.dbo.SabreVehicles WITH (NOLOCK) on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode    
		 and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode    
		 and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode    
		 WHERE vw_sabreCarResponse.carRequestKey=@CarRequestKey and CarResponseDetail.minRate <= @Price
		 group by 
			carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey ,vw_sabreCarResponse.CarCompanyname, carresponsedetail.minRate ,    
			carresponsedetail.carCategoryCode ,CarContent.dbo.SippCodes.SippCodeClass  ,carresponsedetail.NoOfDays,    
			CarContent.dbo.SabreVehicles.ImageName, 
			CarContent.dbo.SabreVehicles.VehicleName,CarResponse.carLocationCode,vw_sabreCarResponse.pickupCity,    
			vw_sabreCarResponse.pickupLocationAddress,vw_sabreCarResponse.dropoffLocationAddress,vw_sabreCarResponse.pickupDate,vw_sabreCarResponse.TotalChargeAmt,    
			vw_sabreCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity , CarContent.dbo.SabreVehicles.baggage ,
			carresponsedetail.minRateTax ,CarContent.dbo.SippCodes.SippCodeTransmission, CarContent.dbo.SippCodes.SippCodeDescription,           
			CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.SabreVehicles.VehicleName ,newImageName,
			vw_sabreCarResponse.pickupLatitude,vw_sabreCarResponse.pickupLongitude, carresponsedetail.contractCode, vw_sabreCarResponse.dropoffCity,
			carresponse.PickupLocInfoCode, vw_sabreCarResponse.dropoffState , vw_sabreCarResponse.dropoffCountry
			, vw_sabreCarResponse.pickupState , vw_sabreCarResponse.pickupCountry 
			,vw_sabreCarResponse.dropoffDate, vw_sabreCarResponse.pickupCityCode, vw_sabreCarResponse.dropoffCityCode, vw_sabreCarResponse.pickupairport, vw_sabreCarResponse.dropoffairport
		  Having  Min(carresponsedetail.minRate) <> 0 
		) tmp WHERE RowNum = 1	  
		order by carClassCat, LowestPrice 
		 
		-- SELECT COUNT (*) as NoOfCars,carresponsedetail.carCategoryCode    
		--FROM vw_sabreCarResponse    
		--inner join    
		--carresponsedetail    
		--on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey    
		--inner join CarContent .dbo.SippCodes   on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType    
		--inner join CarContent.dbo.SabreVehicles on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode    
		--and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode    
		--where CarRequestKey=@CarRequestKey    
		--and  carresponsedetail.carCategoryCode in('ECAR','CCAR','ICAR','SCAR','FCAR','PCAR','LCAR','IFAR','FFAR','LFAR','MVAR')    
		--group by  carresponsedetail.carCategoryCode    

		SELECT COUNT(*)  as NoOfCars,CarResponseDetail.carCategoryCode    
		FROM @tmpSabreCarResponse vw_sabreCarResponse    
			inner join carresponsedetail WITH (NOLOCK) on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey    
		WHERE CarRequestKey=@CarRequestKey and carresponsedetail.minRate <> 0 
		GROUP BY CarResponseDetail.carCategoryCode    
		ORDER BY carresponsedetail.carCategoryCode    
		 
		select MIN(minrate) as FilterLowestPrice,carVendorKey as FilterCarCompany,CarCompanyname 
		from @tmpSabreCarResponse --vw_sabreCarResponse    
		--where CarRequestKey= @CarRequestKey 
		group by carVendorKey,CarCompanyname having MIN(minrate) <> 0     
		 
		Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice 
		FROM @tmpSabreCarResponse --vw_sabreCarResponse 
		--where CarRequestKey=@CarRequestKey and minrate <> 0 
		
		SELECT SippCodeClass as carClassCat , MIN (minRate)as LowestPrice 
		FROM @tmpSabreCarResponse --vw_sabreCarResponse 
		--where CarRequestKey=@CarRequestKey and minrate <> 0 
		group by SippCodeClass  

	end    
	else    
	begin    
     
		 SET @sqlString ='SELECT * FROM @tmpSabreCarResponse where carRequestKey= '+CONVERT(varchar,@CarRequestKey)    
		 +' and  minRate<='+ CONVERT(varchar,@Price)    
		 + ' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'  

		--SELECT * 
		--FROM @tmpSabreCarResponse 
		--WHERE carRequestKey = @CarRequestKey AND minRate <= @Price
		--ORDER BY @sortColumn ASC

		 exec(@sqlString)    
		      
		 SELECT carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey as carCompany ,vw_sabreCarResponse.CarCompanyname,
			carresponsedetail.minRate as LowestPrice,    
			carresponsedetail.carCategoryCode as carClassCat,CarContent .dbo.SippCodes.SippCodeDescription as carClassDes ,    
			CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.VehicleName,passenger, vw_sabreCarResponse.baggage,CarContent.dbo.SippCodes.SippCodeTransmission,           
			CarContent.dbo.SippCodes.SippCodeAC, carresponsedetail.contractCode    
		 FROM @tmpSabreCarResponse vw_sabreCarResponse    
			 inner join carresponsedetail WITH (NOLOCK) on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey 
			 inner join CarContent.dbo.SippCodes   WITH (NOLOCK) on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType     
			 inner join CarContent.dbo.SabreVehicles WITH (NOLOCK) on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode    
					and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode    
					and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode 
		 --where CarRequestKey=@CarRequestKey     
		 ORDER BY CarResponseDetail.minRate    
		    
		 SELECT COUNT(*)  as NoOfCars,CarResponseDetail.carCategoryCode    
		 FROM @tmpSabreCarResponse t -- vw_sabreCarResponse    
			 inner join carresponsedetail WITH (NOLOCK) on carresponsedetail.carresponsekey=t.carResponseKey 
		 --where CarRequestKey=@CarRequestKey    
		 group by CarResponseDetail.carCategoryCode 
		 order by carresponsedetail.carCategoryCode 
		     
		select MIN(minrate) as FilterLowestPrice,carVendorKey as FilterCarCompany,CarCompanyname 
		from @tmpSabreCarResponse -- vw_sabreCarResponse 
		--where CarRequestKey= @CarRequestKey 
		group by carVendorKey,CarCompanyname    
		      
		Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice 
		FROM @tmpSabreCarResponse -- vw_sabreCarResponse 
		--where CarRequestKey=@CarRequestKey 
		
		SELECT SippCodeClass as carClassCat , MIN (minRate)as LowestPrice 
		FROM @tmpSabreCarResponse --vw_sabreCarResponse 
		--where CarRequestKey=@CarRequestKey 
		group by SippCodeClass    
     
	end
GO
