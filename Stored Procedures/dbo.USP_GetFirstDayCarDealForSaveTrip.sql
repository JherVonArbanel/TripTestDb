SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Jayant Guru
-- Create date: 25th October 2013
-- Description:	Gets Car deals for first day of save trip
-- =============================================
--EXEC USP_GetFirstDayCarDealForSaveTrip 118242,'E',1,3
CREATE PROCEDURE [dbo].[USP_GetFirstDayCarDealForSaveTrip]
	@carRequestID INT 
	,@carType VARCHAR(20)
	,@leadComponentType INT
	,@fromPage INT
	,@carResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Set Default Car type if cartype does not exist.
	IF(@carType IS NULL OR @carType = '')
	BEGIN
		SET @carType = 'S'
	END
	
	DECLARE @carResponseDet AS TABLE 
	(
		CarResponseDetKey UNIQUEIDENTIFIER
		,DealType CHAR
	)
	/*
	DECLARE @carFinal AS TABLE
	(
		DealType CHAR 
		,carResponseKey UNIQUEIDENTIFIER
		,carRequestKey INT
		,minRate FLOAT
		,minRateTax FLOAT
		,VehicleName VARCHAR(300)
		,pickupDate DATETIME
		,dropoffDate DATETIME
		,pickupLatitude FLOAT
		,pickupLongitude FLOAT
		,pickupZipCode VARCHAR(30)
		,dropoffLatitude FLOAT
		,dropoffLongitude FLOAT
		,dropoffZipCode VARCHAR(30)
		,dropoffLocationAddress VARCHAR(300)
		,pickupLocationAddress VARCHAR(300)
		,dropoffLocationName VARCHAR(100)
		,pickupDate2 DATETIME
		,dropoffDate2 DATETIME
		,SippCodeDescription VARCHAR(200)
		,SippCodeTransmission VARCHAR(200)
		,SippCodeAC VARCHAR(400)
		,CarCompanyName VARCHAR(100)
		,SippCodeClass VARCHAR(100)
		,dropoffCity VARCHAR(100)
		,dropoffState VARCHAR(100)
		,dropoffCountry VARCHAR(100)
		,pickupCity VARCHAR(100)
		,pickupState VARCHAR(100)
		,pickupCountry VARCHAR(100)
		,minRateTax2 FLOAT   
		,TotalChargeAmt FLOAT
		,minRate2 FLOAT
		,passenger VARCHAR(150)
		,baggage VARCHAR(200)
		,carLocationCode VARCHAR(100)
		,carVendorKey VARCHAR(50)
		,supplierId VARCHAR(50)
		,carCategoryCode VARCHAR(50)
		,contractCode VARCHAR(20)     
		,rateTypeCode VARCHAR(20)
		,carRules VARCHAR(2000)
		,ImageName VARCHAR(500)
		,OperationTimeStart VARCHAR(10)
		,OperationTimeEnd VARCHAR(10)
		,PickupLocationInfo VARCHAR(100)
		,PickupLocInfoCode VARCHAR(4)
		,NoOfDays INT 
		,MileageAllowance VARCHAR(10)
	)*/
	
	DECLARE @carPriority INT
			,@downgradedCarType CHAR
			,@upgradedCarType CHAR
			,@maxCarPriority INT
			,@minCarPriority INT
			,@loweseDealCount INT
			,@upgradeDealCount INT
	
	SET @carPriority = (SELECT CarPriority	FROM CarPriorityByClass WITH(NOLOCK)
	WHERE CarClassShortName = @carType)
	
	/*NEEDED FOR CAR LOWEST AND HIGHEST PRIORITY COMPARISION*/
	SELECT @maxCarPriority = MIN(CarPriority) 
	,@minCarPriority = MAX(CarPriority)
	FROM CarPriorityByClass WITH(NOLOCK)
	
	/*Downgrading car type*/
	IF(@carPriority <> @minCarPriority)
	BEGIN
		SET @downgradedCarType = (SELECT TOP 1 CarClassShortName FROM CarPriorityByClass WITH(NOLOCK)
		WHERE CarPriority > @carPriority ORDER  BY CarPriority ASC) 
	END
	ELSE
	BEGIN
		SET @downgradedCarType = @carType
	END
	/*END: Downgrading car type*/
	
	/*Upgrading car type*/
	IF(@carPriority <> @maxCarPriority)
	BEGIN
		SET @upgradedCarType = (SELECT TOP 1 CarClassShortName FROM CarPriorityByClass WITH(NOLOCK) 
		WHERE CarPriority < @carPriority ORDER  BY CarPriority DESC) 
	END
	ELSE
	BEGIN
		SET @upgradedCarType = @carType
	END
	/*END: Upgrading car type*/	
	
	--PRINT @upgradedCarType
	--print @downgradedCarType
	
	/*For recommended deal*/
	IF(@fromPage = 1 OR @fromPage = 3) --from follow deal and get deals page
		BEGIN
		    INSERT @carResponseDet (CarResponseDetKey, DealType)
		    SELECT  TOP 1
		    dbo.CarResponseDetail.carResponseDetailKey, 'R'        
		    FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
		    INNER JOIN dbo.CarResponse WITH (NOLOCK)    
		    INNER JOIN carresponsedetail WITH (NOLOCK) ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
		    INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK)
			ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
			ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
			LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
			LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
			ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
			INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
			ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
			AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
			AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
			ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
			AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
			AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
			AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
			INNER JOIN dbo.CarRequest WITH (NOLOCK) 
			ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
			AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
			AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode               
			--INNER JOIN CarVendorPreference CVP WITH(NOLOCK) ON CarResponseDetail.carVendorKey = CVP.CarVendorCode
			WHERE  dbo.CarRequest.carRequestKey = @carRequestID AND SUBSTRING(dbo.CarResponseDetail.carCategoryCode ,1,1)= @carType 
			ORDER BY dbo.CarResponseDetail.minRate ASC--, CVP.CarVendorPreferenceKey ASC
						
			/*EXCEPTION BLOCK - IF RECOMMENDED CAR TYPE IS NOT AVAILABLE*/
			IF((SELECT COUNT(CarResponseDetKey) FROM @carResponseDet) = 0)
			BEGIN
				INSERT @carResponseDet (CarResponseDetKey, DealType)
				SELECT  TOP 1
				dbo.CarResponseDetail.carResponseDetailKey, 'R'        
				FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
				INNER JOIN dbo.CarResponse WITH (NOLOCK)    
				INNER JOIN carresponsedetail WITH (NOLOCK) 
				ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
				INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
				ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
				ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
				LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
				LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
				ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
				INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
				ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
				AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
				AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
				ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
				AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
				AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
				AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
				INNER JOIN dbo.CarRequest WITH (NOLOCK) 
				ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
				AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
				AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode               
				--INNER JOIN CarVendorPreference CVP WITH (NOLOCK) 
				--ON CarResponseDetail.carVendorKey = CVP.CarVendorCode
				WHERE  dbo.CarRequest.carRequestKey = @carRequestID 
				AND SUBSTRING(dbo.CarResponseDetail.carCategoryCode ,1,1) = @downgradedCarType 
				ORDER BY dbo.CarResponseDetail.minRate ASC--, CVP.CarVendorPreferenceKey ASC 
			END
			/*END: EXCEPTION BLOCK - IF RECOMMENDED CAR TYPE IS NOT AVAILABLE*/			
		
		END
	/*END: For recommended deal*/
	
	IF(@leadComponentType = 2)
		BEGIN					
			IF(@fromPage = 2 OR @fromPage = 3)--From trip summary and get deals page
			BEGIN
				/*For Downgraded Car Type*/
				INSERT INTO @carResponseDet (CarResponseDetKey, DealType)
				SELECT  TOP 1
				dbo.CarResponseDetail.carResponseDetailKey, 'L'        
				FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
				INNER JOIN dbo.CarResponse WITH (NOLOCK)    
				INNER JOIN carresponsedetail WITH (NOLOCK) 
				ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
				INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
				ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
				ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
				LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
				LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
				ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
				INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
				ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
				AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
				AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
				ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
				AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
				AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
				AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
				INNER JOIN dbo.CarRequest WITH (NOLOCK) 
				ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
				AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
				AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode
				--INNER JOIN CarVendorPreference CVP WITH (NOLOCK) 
				--ON CarResponseDetail.carVendorKey = CVP.CarVendorCode               
				WHERE  dbo.CarRequest.carRequestKey = @carRequestID 
				AND SUBSTRING(dbo.CarResponseDetail.carCategoryCode ,1,1) = @downgradedCarType
				AND dbo.CarResponseDetail.carResponseDetailKey NOT IN (SELECT CarResponseDetKey FROM @carResponseDet)
				AND dbo.CarResponseDetail.carResponseDetailKey <> @carResponseKey
				ORDER BY dbo.CarResponseDetail.minRate ASC--, cvp.CarVendorPreferenceKey ASC
				/*END: For Downgraded Car Type*/
				
				/*EXCEPTION BLOCK - WHEN DOWNGRADED OPTION IS NOT FOUND*/
				IF((SELECT COUNT(CarResponseDetKey) FROM @carResponseDet WHERE DealType = 'L') = 0)
				BEGIN
					INSERT INTO @carResponseDet (CarResponseDetKey, DealType)
					SELECT  TOP 1
					dbo.CarResponseDetail.carResponseDetailKey, 'L'        
					FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
					INNER JOIN dbo.CarResponse WITH (NOLOCK)    
					INNER JOIN carresponsedetail WITH (NOLOCK) 
					ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
					INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
					ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
					ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
					LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
					LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
					ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
					INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
					ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
					AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
					AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
					ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
					AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
					AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
					AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
					INNER JOIN dbo.CarRequest WITH (NOLOCK) 
					ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
					AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
					AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode
					--INNER JOIN CarVendorPreference CVP WITH (NOLOCK) 
					--ON CarResponseDetail.carVendorKey = CVP.CarVendorCode 
					LEFT OUTER JOIN CarPriorityByClass CPC WITH (NOLOCK)
					ON SUBSTRING(dbo.CarResponseDetail.carCategoryCode, 1, 1) = CPC.CarClassShortName              
					WHERE  dbo.CarRequest.carRequestKey = @carRequestID
					AND dbo.CarResponseDetail.carResponseDetailKey NOT IN (SELECT CarResponseDetKey FROM @carResponseDet)
					AND dbo.CarResponseDetail.carResponseDetailKey <> @carResponseKey
					AND CPC.CarPriority > @carPriority
					ORDER BY CPC.CarPriority DESC, dbo.CarResponseDetail.minRate ASC--, cvp.CarVendorPreferenceKey ASC	
				END
				/*EXCEPTION BLOCK - WHEN DOWNGRADED OPTION IS NOT FOUND*/
				
				/*For upgraded car type*/
				INSERT INTO @carResponseDet (CarResponseDetKey, DealType)
				SELECT  TOP 1
			    dbo.CarResponseDetail.carResponseDetailKey, 'U'        
				FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
				INNER JOIN dbo.CarResponse WITH (NOLOCK)    
				INNER JOIN carresponsedetail WITH (NOLOCK) 
				ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
				INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
				ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
				ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
				LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
				LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
				ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
				INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
				ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
				AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
				AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
				ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
				AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
				AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
				AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
				INNER JOIN dbo.CarRequest WITH (NOLOCK) 
				ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
				AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
				AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode 
				--INNER JOIN CarVendorPreference CVP WITH (NOLOCK) 
				--ON CarResponseDetail.carVendorKey = CVP.CarVendorCode
				WHERE  dbo.CarRequest.carRequestKey = @carRequestID 
				AND SUBSTRING(dbo.CarResponseDetail.carCategoryCode ,1,1) = @upgradedCarType
				AND dbo.CarResponseDetail.carResponseDetailKey NOT IN (SELECT CarResponseDetKey FROM @carResponseDet)
				AND dbo.CarResponseDetail.carResponseDetailKey <> @carResponseKey
				ORDER BY dbo.CarResponseDetail.minRate ASC--, CVP.CarVendorPreferenceKey ASC
				/*END: For upgraded car type*/
				
				/*EXCEPTION BLOCK - WHEN UPGRADED OPTION IS NOT FOUND*/
				IF((SELECT COUNT(CarResponseDetKey) FROM @carResponseDet WHERE DealType = 'U') = 0)
				BEGIN
					INSERT INTO @carResponseDet (CarResponseDetKey, DealType)
					SELECT  TOP 1
					dbo.CarResponseDetail.carResponseDetailKey, 'U'        
					FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
					INNER JOIN dbo.CarResponse WITH (NOLOCK)    
					INNER JOIN carresponsedetail WITH (NOLOCK) 
					ON carresponsedetail.carresponsekey = CarResponse.carResponseKey     
					INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
					ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
					ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
					LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
					LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
					ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
					INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
					ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
					AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
					AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
					ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
					AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
					AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
					AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
					INNER JOIN dbo.CarRequest WITH (NOLOCK) 
					ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
					AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
					AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode 
					--INNER JOIN CarVendorPreference CVP WITH (NOLOCK) 
					--ON CarResponseDetail.carVendorKey = CVP.CarVendorCode
					LEFT OUTER JOIN CarPriorityByClass CPC WITH (NOLOCK)
					ON SUBSTRING(dbo.CarResponseDetail.carCategoryCode, 1, 1) = CPC.CarClassShortName
					WHERE  dbo.CarRequest.carRequestKey = @carRequestID
					AND dbo.CarResponseDetail.carResponseDetailKey NOT IN (SELECT CarResponseDetKey FROM @carResponseDet)
					AND dbo.CarResponseDetail.carResponseDetailKey <> @carResponseKey
					AND CPC.CarPriority <= @carPriority
					ORDER BY CPC.CarPriority ASC, dbo.CarResponseDetail.minRate ASC--, CVP.CarVendorPreferenceKey ASC	
				END
				/*END: EXCEPTION BLOCK - WHEN UPGRADED OPTION IS NOT FOUND*/
				
			END
		END
	
	/*EXCEPTION BLOCK: IF RECOMMENDED CAR TYPE IS NOT AVAILABLE*/
	IF((@fromPage = 1 OR @fromPage = 3) AND ((SELECT COUNT(*) FROM @carResponseDet WHERE DealType = 'R') = 0))
	BEGIN  
		INSERT @carResponseDet (CarResponseDetKey, DealType) 	 
		SELECT  TOP 1
		dbo.CarResponseDetail.carResponseDetailKey, 'R'  
		FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
		INNER JOIN dbo.CarResponse WITH (NOLOCK)    
		INNER JOIN carresponsedetail WITH (NOLOCK) 
		ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
		INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
		ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
		ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
		LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
		LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
		ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
		INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
		ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
		AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
		AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
		ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
		AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
		AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
		AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
		INNER JOIN dbo.CarRequest WITH (NOLOCK) 
		ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
		AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
		AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode
		--INNER JOIN CarVendorPreference CVP WITH (NOLOCK) 
		--ON CarResponseDetail.carVendorKey = CVP.CarVendorCode             
		WHERE  dbo.CarRequest.carRequestKey = @carRequestID
		AND dbo.CarResponseDetail.carResponseDetailKey NOT IN (SELECT CarResponseDetKey FROM @carResponseDet)  
		ORDER BY dbo.CarResponseDetail.minRate  ASC--, CVP.CarVendorPreferenceKey ASC
	 END 
	/*END: EXCEPTION BLOCK: IF RECOMMENDED CAR TYPE IS NOT AVAILABLE*/ 
	 
	 /*
	 INSERT INTO @carFinal
	 SELECT DISTINCT DealType = CRD.DealType,
		   dbo.CarResponseDetail.carResponseKey,        
		   dbo.carResponse.carRequestKey,        
		   CarResponseDetail.minRate,        
		   CarResponseDetail.minRateTax,        
		   CarContent.dbo.SabreVehicles.VehicleName,        
		   dbo.CarRequest.pickupDate,        
		   dbo.CarRequest.dropoffDate,        
		   SabreLocations_1.Latitude,         
		   SabreLocations_1.Longitude,         
		   SabreLocations_1.ZipCode,         
		   CarContent.dbo.SabreLocations.Latitude,         
		   CarContent.dbo.SabreLocations.Longitude,         
		   CarContent.dbo.SabreLocations.ZipCode,         
		   CarContent.dbo.SabreLocations.LocationAddress1,        
		   SabreLocations_1.LocationAddress1,        
		   CarContent.dbo.SabreLocations.LocationName,         
		   dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate,         
		   CarContent.dbo.SippCodes.SippCodeDescription,        
		   CarContent.dbo.SippCodes.SippCodeTransmission,         
		   CarContent.dbo.SippCodes.SippCodeAC,        
		   CarContent.dbo.CarCompanies.CarCompanyName,		   
		   CarContent.dbo.SippCodeChars.SippCodeCharDescription,
		   CarContent.dbo.SabreLocations.LocationCity,        
		   CarContent.dbo.SabreLocations.Locationstate,         
		   CarContent.dbo.SabreLocations.LocationCountry,        
		   SabreLocations_1.LocationCity,        
		   SabreLocations_1.Locationstate,         
		   SabreLocations_1.LocationCountry,        
		   dbo.CarResponse.minRateTax,        
		   dbo.CarResponse.TotalChargeAmt,        
		   dbo.CarResponse.minRate,         
		   CarContent.dbo.SabreVehicles.PsgrCapacity,        
		   CarContent.dbo.SabreVehicles.Baggage,        
		   dbo.CarResponse.carLocationCode,        
		   dbo.carResponseDetail.carVendorKey
		   ,dbo.carResponseDetail.supplierId,         
		   dbo.carResponseDetail.carCategoryCode,      
		   dbo.CarResponseDetail.contractCode,       
		   dbo.CarResponseDetail.rateTypeCode,       
		   dbo.CarResponseDetail.carRules,      
		   CarContent.dbo.SabreVehicles.ImageName             
		   ,dbo.CarResponse.OperationTimeStart
		   ,dbo.CarResponse.OperationTimeEnd
		   ,dbo.CarResponse.PickupLocationInfo,   
		   dbo.CarResponse.PickupLocInfoCode
		   ,dbo.CarResponseDetail.NoOfDays  
		   ,dbo.CarResponse.MileageAllowance		  
			FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
			INNER JOIN dbo.CarResponse WITH (NOLOCK)    
			INNER JOIN carresponsedetail WITH (NOLOCK) 
			ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
			INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
			ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
			ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
			LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
			LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
			ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
			INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
			ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
			AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
			AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
			ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
			AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
			AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
			AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
			INNER JOIN dbo.CarRequest WITH (NOLOCK) 
			ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
			INNER JOIN CarContent.dbo.SippCodeChars WITH (NOLOCK)
			ON SUBSTRING(CarResponseDetail.carCategoryCode, 1, 1) = CarContent.dbo.SippCodeChars.SippCodeChar
			AND CarContent.dbo.SippCodeChars.SippCodeCharType = 'CLASS'
			AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
			AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode               
			INNER JOIN @carResponseDet CRD
			ON CRD.CarResponseDetKey = dbo.CarResponseDetail.carResponseDetailKey
			WHERE  dbo.CarRequest.carRequestKey = @carRequestID ORDER BY dbo.CarResponseDetail.minRate  ASC
	
	SET @loweseDealCount = (SELECT COUNT(DealType) FROM @carFinal WHERE DealType = 'L')
	SET @upgradeDealCount = (SELECT COUNT(DealType) FROM @carFinal WHERE DealType = 'U')
	--DELETE IF WE HAVE DUPLICATE DEALS
	IF(@loweseDealCount > 1)
	BEGIN
		DELETE TOP(@loweseDealCount - 1) FROM @carFinal WHERE DealType = 'L'		
		--DELETE FROM @carFinal LIMIT (@loweseDealCount - 1) WHERE DealType = 'L'
	END
	
	IF(@upgradeDealCount > 1)
	BEGIN
		DELETE TOP(@upgradeDealCount - 1) FROM @carFinal WHERE DealType = 'U'		
	END
	
	SELECT
		   DealType,
		   carResponseKey,        
		   carRequestKey,        
		   minRate,        
		   minRateTax,        
		   VehicleName,        
		   pickupDate,        
		   dropoffDate,        
		   pickupLatitude,         
		   pickupLongitude,         
		   pickupZipCode,         
		   dropoffLatitude,         
		   dropoffLongitude,         
		   dropoffZipCode,         
		   dropoffLocationAddress,        
		   pickupLocationAddress,        
		   dropoffLocationName,         
		   pickupDate2,
		   dropoffDate2,         
		   SippCodeDescription,        
		   SippCodeTransmission,         
		   SippCodeAC,        
		   CarCompanyName,		   
		   SippCodeClass,
		   dropoffCity,        
		   dropoffState,         
		   dropoffCountry,        
		   pickupCity,        
		   pickupState,         
		   pickupCountry,        
		   minRateTax2,        
		   TotalChargeAmt,        
		   minRate2,         
		   passenger,        
		   baggage,        
		   carLocationCode,        
		   carVendorKey,
		   supplierId,         
		   carCategoryCode,      
		   contractCode,       
		   rateTypeCode,       
		   carRules,      
		   ImageName,
		   OperationTimeStart,
		   OperationTimeEnd,
		   PickupLocationInfo,   
		   PickupLocInfoCode,
		   NoOfDays,
		   MileageAllowance
	FROM @carFinal */
	 	 
	 
	 SELECT DISTINCT DealType = CRD.DealType,
		   dbo.CarResponseDetail.carResponseKey,        
		   dbo.carResponse.carRequestKey,        
		   CarResponseDetail.minRate,        
		   CarResponseDetail.minRateTax,        
		   CarContent.dbo.SabreVehicles.VehicleName,        
		   dbo.CarRequest.pickupDate,        
		   dbo.CarRequest.dropoffDate,        
		   SabreLocations_1.Latitude AS pickupLatitude,         
		   SabreLocations_1.Longitude AS pickupLongitude,         
		   SabreLocations_1.ZipCode AS pickupZipCode,         
		   CarContent.dbo.SabreLocations.Latitude AS dropoffLatitude,         
		   CarContent.dbo.SabreLocations.Longitude AS dropoffLongitude,         
		   CarContent.dbo.SabreLocations.ZipCode AS dropoffZipCode,         
		   CarContent.dbo.SabreLocations.LocationAddress1 AS dropoffLocationAddress,        
		   SabreLocations_1.LocationAddress1 AS pickupLocationAddress,        
		   CarContent.dbo.SabreLocations.LocationName AS dropoffLocationName,         
		   dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate,         
		   CarContent.dbo.SippCodes.SippCodeDescription,        
		   CarContent.dbo.SippCodes.SippCodeTransmission,         
		   CarContent.dbo.SippCodes.SippCodeAC,        
		   CarContent.dbo.CarCompanies.CarCompanyName,        
		   --CarContent.dbo.SippCodes.SippCodeClass,         
		   CarContent.dbo.SippCodeChars.SippCodeCharDescription AS SippCodeClass,
		   CarContent.dbo.SabreLocations.LocationCity AS dropoffCity,        
		   CarContent.dbo.SabreLocations.Locationstate AS dropoffState,         
		   CarContent.dbo.SabreLocations.LocationCountry AS dropoffCountry,        
		   SabreLocations_1.LocationCity AS pickupCity,        
		   SabreLocations_1.Locationstate AS pickupState,         
		   SabreLocations_1.LocationCountry AS pickupCountry,        
		   dbo.CarResponse.minRateTax,        
		   dbo.CarResponse.TotalChargeAmt,        
		   dbo.CarResponse.minRate,         
		   CarContent.dbo.SabreVehicles.PsgrCapacity AS passenger,        
		   CarContent.dbo.SabreVehicles.Baggage AS baggage,        
		   dbo.CarResponse.carLocationCode,        
		   dbo.carResponseDetail.carVendorKey, dbo.carResponseDetail.supplierId,         
		   dbo.carResponseDetail.carCategoryCode,      
		   dbo.CarResponseDetail.contractCode,       
		   dbo.CarResponseDetail.rateTypeCode,       
		   dbo.CarResponseDetail.carRules,      
		   CarContent.dbo.SabreVehicles.ImageName as ImageName             
		   ,dbo.CarResponse.OperationTimeStart,dbo.CarResponse.OperationTimeEnd,dbo.CarResponse.PickupLocationInfo,   
		   dbo.CarResponse.PickupLocInfoCode
		   ,dbo.CarResponseDetail.NoOfDays  
		   ,dbo.CarResponse.MileageAllowance,
		    CarRequest.dropoffCityCode AS carDropOffLocationCode,
		    CarRequest.dropoffCityCode AS carDropOffLocationCategoryCode
		   --,dbo.carResponseDetail.carVehicleCategory,        
		   --dbo.carResponseDetail.carVehicleSize        
			FROM CarContent.dbo.CarCompanies WITH (NOLOCK)     
			INNER JOIN dbo.CarResponse WITH (NOLOCK)    
			INNER JOIN carresponsedetail WITH (NOLOCK) 
			ON carresponsedetail.carresponsekey=CarResponse.carResponseKey     
			INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) 
			ON dbo.CarResponseDetail.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
			ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey     
			LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH (NOLOCK)     
			LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) 
			ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode                     
			INNER JOIN  CarContent.dbo.SabreLocations  AS SabreLocations_1 WITH (NOLOCK) 
			ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode     
			AND  CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode     
			AND  CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
			ON dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
			AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode     
			AND  dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode     
			AND  dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode     
			INNER JOIN dbo.CarRequest WITH (NOLOCK) 
			ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey
			INNER JOIN CarContent.dbo.SippCodeChars WITH (NOLOCK)
			ON SUBSTRING(CarResponseDetail.carCategoryCode, 1, 1) = CarContent.dbo.SippCodeChars.SippCodeChar
			AND CarContent.dbo.SippCodeChars.SippCodeCharType = 'CLASS'
			AND CarContent.dbo.SabreLocations.LocationAirportCode = dbo.CarRequest.dropoffCityCode     
			AND CarContent.dbo.SabreLocations.LocationCategoryCode = dbo.CarRequest.dropoffCityCode               
			INNER JOIN @carResponseDet CRD
			ON CRD.CarResponseDetKey = dbo.CarResponseDetail.carResponseDetailKey
			WHERE  dbo.CarRequest.carRequestKey = @carRequestID ORDER BY dbo.CarResponseDetail.minRate  ASC
			
			
END


GO
