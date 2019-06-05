SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
- Default Car Type is S
- if not exist then we will display this car preference not exist.
- EXEC usp_GetLowestCarResponseForRequest 60811,'K'
*/

CREATE PROCEDURE [dbo].[usp_GetLowestCarResponseForRequest] (@carRequestID INT , @carType VARCHAR(20))  
AS   
BEGIN  
	-- Set Default Car type if cartype not exist.
	IF(@carType IS NULL OR @carType = '')
		BEGIN
		SET @carType = 'S'
		END
	
   DECLARE @carResponseDet AS TABLE (CarResponseDetKey UNIQUEIDENTIFIER)  	
   
   INSERT @carResponseDet   
	   SELECT  TOP 1
	   dbo.CarResponseDetail.carResponseDetailKey        
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
		WHERE  dbo.CarRequest.carRequestKey = @carRequestID AND SUBSTRING(dbo.CarResponseDetail.carCategoryCode ,1,1)= @carType order BY dbo.CarResponseDetail.minRate  asc   
		
	IF ( SELECT COUNT(*) FROM @carResponseDet ) = 0   
	BEGIN  
		INSERT @carResponseDet 	 
		  SELECT  TOP 1
		   dbo.CarResponseDetail.carResponseDetailKey        
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
			WHERE  dbo.CarRequest.carRequestKey = @carRequestID order BY dbo.CarResponseDetail.minRate  asc    
	 END 
	 
	 SELECT  TOP 1
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
		   CarContent.dbo.SippCodes.SippCodeClass,         
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
		   ,dbo.CarResponse.OperationTimeStart,dbo.CarResponse.OperationTimeEnd,dbo.CarResponse.PickupLocationInfo,   dbo.CarResponse.PickupLocInfoCode
		   ,dbo.CarResponseDetail.NoOfDays  
		   ,dbo.CarResponse.MileageAllowance,
		   CarRequest.dropoffCityCode as carDropOffLocationCode,
		   CarRequest.dropoffCityCode as carDropOffLocationCategoryCode
		   --,dbo.carResponseDetail.carVehicleCategory,        
		   --dbo.carResponseDetail.carVehicleSize        
			FROM         CarContent.dbo.CarCompanies WITH (NOLOCK)     
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
						 INNER JOIN @carResponseDet CRD ON CRD.CarResponseDetKey = dbo.CarResponseDetail.carResponseDetailKey 
						 
			WHERE  dbo.CarRequest.carRequestKey = @carRequestID order BY dbo.CarResponseDetail.minRate  asc   
END  
  
GO
