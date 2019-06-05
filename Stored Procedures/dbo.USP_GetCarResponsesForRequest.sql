SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetCarResponsesForRequest]      
( @CarRequestKey int ,      
  @carVendors varchar(200)='',      
  @sortField varchar(50)='',      
  @carClasses varchar(200)='',      
  @carTypes varchar(200)='',      
  @Price float=9999999999.99,  
  @UserKey int =0,  
  @CompanyKey int =0 ,  
  @UserGroupKey Int = 0 
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
         
         
   IF @sortField = ''      
    begin      
  
 SELECT *,CONVERT(VARCHAR(20), 'NONE') AS ReasonCode, CONVERT(BIT,0) AS IsSuppressVendor  INTO #tmpCarResponseDetail  FROM CarResponseDetail WITH (NOLOCK) WHERE carResponseKey IN (SELECT CarResponsekey from CarResponse WITH (NOLOCK) WHERE carRequestKey=@CarRequestKey)  
  
     -- Policy Implementation Start  
  DECLARE @IsPolicyApplicable BIT= 0, @TripType VARCHAR(50) , @tripTypeKey INT,   
    @MaxFareTotal FLOAT,   @IsHideFare BIT=0,@HighFareTotal FLOAT, @IsHighFareTotal BIT=0,@LowFareThreshold FLOAT,@IsLowFareThreshold BIT=0 ,
	@SuppressedRentalCars VARCHAR(500), @IsSuppressCar BIT
  SELECT @tripTypeKey = tripTypeKey FROM trip..TripRequest WHERE tripRequestKey =  (SELECT TripRequestkey FROM Trip..TripRequest_car WHERE carRequestKey = @CarRequestKey)  
  SELECT @TripType =  tripTypeName FROM TripTypeLookup WHERE tripTypeKey = @tripTypeKey  
  
--IF (@siteKey = 0)
--BEGIN
--  IF (@UserKey <> 0)  
--   BEGIN  
--      SELECT @siteKey = siteKey FROM Vault..[User] WHERE userkey = @UserKey  
--   END  
--END
  
--  IF (@siteKey <> 0)  
--  BEGIN  
--   SELECT @IsPolicyApplicable = ISNULL(data.value('(/Site/UI/IsPolicyApplicable/node())[1]', 'BIT'),0)  
--   FROM Vault..SiteConfiguration   
--   WHERE siteKey = @SiteKey  
--  END  
IF OBJECT_ID('tempdb..#tmp_vw_sabreCarResponse') IS NOT NULL  
 DROP TABLE #tmp_vw_sabreCarResponse  
 SELECT     dbo.CarResponse.carResponseKey, dbo.CarResponse.carRequestKey, dbo.CarResponse.carVendorKey, dbo.CarResponse.supplierId,   
                      dbo.CarResponse.carCategoryCode, dbo.CarResponse.carLocationCode, dbo.CarResponse.carLocationCategoryCode,CarResponse.carDropOffLocationCode,CarResponse.carDropOffLocationCategoryCode, dbo.CarResponse.minRate AS PerDayRate,   
                      CarContent.dbo.SabreVehicles.VehicleName, SabreLocations_1.LocationName AS pickupLocationName,   
                      SabreLocations_1.LocationAddress1 AS pickupLocationAddress, SabreLocations_1.Latitude AS pickupLatitude, SabreLocations_1.Longitude AS pickupLongitude,   
                      SabreLocations_1.ZipCode AS pickupZipCode, CarContent.dbo.SabreLocations.Latitude AS dropoffLatitude,   
                      CarContent.dbo.SabreLocations.Longitude AS dropoffLongitude, CarContent.dbo.SabreLocations.ZipCode AS dropoffZipCode,   
                      CarContent.dbo.SabreLocations.LocationAddress1 AS dropoffLocationAddress, CarContent.dbo.SabreLocations.LocationName AS dropoffLocationName,   
                      dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate, CarContent.dbo.SippCodes.SippCodeDescription, CarContent.dbo.SippCodes.SippCodeTransmission,   
                      CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, CarContent.dbo.SippCodes.SippCodeClass,   
                      CarContent.dbo.SabreLocations.LocationCity AS dropoffCity, CarContent.dbo.SabreLocations.Locationstate AS dropoffState,   
                      CarContent.dbo.SabreLocations.LocationCountry AS dropoffCountry,CarContent.dbo.SabreLocations.Distance as AirportDistance,CarContent.dbo.SabreLocations.DistanceUnit as AirportDistanceUnit, SabreLocations_1.LocationCity AS pickupCity,
 SabreLocations_1.Locationstate AS pickupState,   
                      SabreLocations_1.LocationCountry AS pickupCountry, dbo.CarResponse.minRateTax, dbo.CarResponse.TotalChargeAmt, dbo.CarResponse.minRate,   
                      CarContent.dbo.SabreVehicles.PsgrCapacity AS passenger, CarContent.dbo.SabreVehicles.Baggage, dbo.CarResponse.MileageAllowance,   
                      dbo.CarResponse.RatePlan, dbo.CarResponse.contractCode,dbo.CarResponse.OperationTimeStart,dbo.CarResponse.OperationTimeEnd,  
       dbo.CarResponse.PickupDistance,dbo.CarResponse.DropDistance,dbo.CarResponse.PickupDistanceUnit,dbo.CarResponse.DropDistanceUnit, dbo.CarResponse.PickupAddress,dbo.CarResponse.DropAddress,dbo.CarResponse.RequestType  
                      ,dbo.CarResponse.PickUpLatLong,dbo.CarResponse.DropOffLatLong,dbo.CarRequest.pickupCityCode, dbo.CarRequest.dropoffCityCode  
                      , (SELECT top 1 AirportName from dbo.AirportLookup where AirportCode = dbo.CarRequest.pickupCityCode) as pickupairport  
                      , (SELECT top 1 AirportName from dbo.AirportLookup where AirportCode = dbo.CarRequest.dropoffCityCode) as dropoffairport  
					  , dbo.CarResponse.inTerminal
  INTO #tmp_vw_sabreCarResponse  
  FROM         CarContent.dbo.CarCompanies WITH (NOLOCK)   
         INNER JOIN  dbo.CarResponse WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey   
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
  WHERE dbo.CarResponse.carRequestKey =@CarRequestKey          


   If ((@UserKey = 0) AND (@CompanyKey = 0) AND (@UserGroupKey=0))
		SET @IsPolicyApplicable = 0
   ELSE
		SET @IsPolicyApplicable = 1

  IF (@IsPolicyApplicable=1)  
  BEGIN  
   DECLARE @tblCarPolicy as Table        
   (        
    MaxFareTotalCar FLOAT,   
    IsMaxFareTotalCar BIT,  
    HighFareTolCar FLOAT,  
    IsHighFareTolCar BIT,  
    IsApproveHighFareTolCar BIT,  
    IsNotifyHighFareTolCar BIT,
	IsSuppressCar BIT,
	SuppressedRentalCars VARCHAR(500)
   )    
  
   INSERT INTO @tblCarPolicy( MaxFareTotalCar, IsMaxFareTotalCar,  
          HighFareTolCar, IsHighFareTolCar,  
          IsApproveHighFareTolCar,IsNotifyHighFareTolCar,IsSuppressCar,SuppressedRentalCars)   
   SELECT      CarSpendingCap,IsCarSpendingCap,   
          DomesticHighFareTol,IsDomesticHighFareTol,    
          IsApproveCarSpendingCap,NotifyDomesticHighFareCap,IsSuppressCar,SuppressedRentalCars
   FROM      vault.dbo.[udf_GetPolicyDetailsForCar](@UserKey, @CompanyKey, @TripType,@UserGroupKey)  
  
     
   SELECT TOP 1 @MaxFareTotal = MaxFareTotalCar, @IsHideFare = IsMaxFareTotalCar,  @HighFareTotal = HighFareTolCar,@IsHighFareTotal = IsHighFareTolCar, @SuppressedRentalCars = SuppressedRentalCars,@IsSuppressCar = IsSuppressCar  FROM @tblCarPolicy  
  
   IF ((@MaxFareTotal != 0) and (@IsHideFare = 1))  
   BEGIN  
    DELETE FROM #tmpCarResponseDetail   
    WHERE carResponseDetailKey IN  (SELECT A.carResponseDetailKey from #tmpCarResponseDetail A WHERE ROUND(ISNULL(A.minRate,0),2) > ROUND(@MaxFareTotal,2))  

	DELETE FROM #tmp_vw_sabreCarResponse
	WHERE carResponseKey IN  (SELECT A.carResponseKey from #tmp_vw_sabreCarResponse A WHERE ROUND(ISNULL(A.minRate,0),2) > ROUND(@MaxFareTotal,2))  

   END  
  
   IF (@HighFareTotal != 0 AND @IsHighFareTotal = 1)  
   BEGIN  
    IF (@MaxFareTotal !=0)  
    BEGIN  
     UPDATE #tmpCarResponseDetail   
     SET ReasonCode = 'High'   
     WHERE carResponseDetailKey IN (SELECT A.carResponseDetailKey   
            FROM #tmpCarResponseDetail A   
            WHERE ROUND(A.minRate,2) > ROUND(@HighFareTotal,2)  
            AND ROUND(A.minRate,2) <=  ROUND(@MaxFareTotal,2))  
    END  
    ELSE  
    BEGIN  
     UPDATE #tmpCarResponseDetail   
     SET ReasonCode  = 'High'   
     WHERE carResponseDetailKey IN (SELECT A.carResponseDetailKey   
            FROM #tmpCarResponseDetail A   
            WHERE ROUND(A.minRate,2) > ROUND(@HighFareTotal,2))  
    END  
   END  


   	IF (@IsSuppressCar = 1) 
	BEGIN
	    DECLARE @SuppressedVendor  TABLE (vendorCode VARCHAR (5) )  
		INSERT INTO @SuppressedVendor(vendorCode)  SELECT * FROM vault.dbo.ufn_CSVToTable (@SuppressedRentalCars )

		--UPDATE #tmpCarResponseDetail 
		--SET IsSuppressVendor = 1
		--WHERE carResponseDetailKey IN (SELECT A.carResponseDetailKey 
		--							FROM #tmpCarResponseDetail A 
		--							WHERE LTRIM(RTRIM(A.carVendorKey)) IN (SELECT vendorCode FROM @SuppressedVendor))

		DELETE FROM #tmpCarResponseDetail 
		WHERE carResponseDetailKey IN (SELECT A.carResponseDetailKey 
									FROM #tmpCarResponseDetail A 
									WHERE LTRIM(RTRIM(A.carVendorKey)) IN (SELECT vendorCode FROM @SuppressedVendor))

		DELETE FROM #tmp_vw_sabreCarResponse 
		WHERE carResponseKey IN (SELECT A.carResponseKey 
									FROM #tmp_vw_sabreCarResponse A 
									WHERE LTRIM(RTRIM(A.carVendorKey)) IN (SELECT vendorCode FROM @SuppressedVendor))
	END


 END  
 --Policy Implementation Ends here  
 
  
  SELECT * FROM(    
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
   vwCarResponse.carDropOffLocationCategoryCode,  
   vwCarResponse.AirportDistance,  
   vwCarResponse.AirportDistanceUnit,  
   vwCarResponse.PickupDistance,  
   vwCarResponse.DropDistance,  
   vwCarResponse.PickupDistanceUnit,  
   vwCarResponse.DropDistanceUnit,  
    vwCarResponse.PickupAddress,  
 vwCarResponse.DropAddress,  
 vwCarResponse.RequestType,  
 vwCarResponse.PickUpLatLong,  
 vwCarResponse.DropOffLatLong,
 vwCarResponse.inTerminal
 ,ROW_NUMBER() OVER (PARTITION BY vwCarResponse.carVendorKey,vwCarResponse.carCategoryCode ORDER BY vwCarResponse.carVendorKey) AS rn  
 FROM #tmp_vw_sabreCarResponse vwCarResponse      
  Left join         
  (  select   CD.carVendorKey, CD.minRate as PerDayminRate  , CD.carResponseKey ,CarContent.dbo.SippCodes.SippCodeCarType as SippCodeCarType           
  from #tmpCarResponseDetail CD  WITH (NOLOCK)     
  Inner join carresponse Cd1 WITH (NOLOCK) on CD.carResponseKey = Cd1.carResponseKey  and Cd1.carRequestKey = @CarRequestKey       
  Inner join CarContent.dbo.SippCodes WITH (NOLOCK) ON cd1.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType      
  --Group by  CD.carVendorKey, CD.carResponseKey
  ) as A  on vwCarResponse.carResponseKey = A.carResponseKey       
  where vwCarResponse.carRequestKey=@CarRequestKey      
  and vwCarResponse.PerDayRate<= @Price and PerDayminRate <> 0 
  )TN
  WHERE TN.rn=1 OR TN.RequestType=2
  order by TN.minRate,TN.pickupLocationName,TN.CarCompanyName   
       
-- SELECT     dbo.CarResponse.carResponseKey, dbo.CarResponse.carRequestKey, dbo.CarResponseDetail.carVendorKey, dbo.CarResponse.supplierId,       
--                      dbo.CarResponse.carCategoryCode, dbo.CarResponse.carLocationCode, dbo.CarResponse.carLocationCategoryCode, MIN(dbo.CarResponseDetail.minRate)       
--                      AS PerDayRate, CarContent.dbo.SabreVehicles.VehicleName, SabreLocations_1.LocationName AS pickupLocationName,       
--                      SabreLocations_1.LocationAddress1 AS pickupLocationAddress, SabreLocations_1.Latitude AS pickupLatitude, SabreLocations_1.Longitude AS pickupLongitude,       
--                      SabreLocations_1.ZipCode AS pickupZipCode, CarContent.dbo.SabreLocations.Latitude AS dropoffLatitude,       
--                      CarContent.dbo.SabreLocations.Longitude AS dropoffLongitude, CarContent.dbo.SabreLocations.ZipCode AS dropoffZipCode,       
--                      CarContent.dbo.SabreLocations.LocationAddress1 AS dropoffLocationAddress, CarContent.dbo.SabreLocations.LocationName AS dropoffLocationName,       
--                      dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate, CarContent.dbo.SippCodes.SippCodeDescription, CarContent.dbo.SippCodes.SippCodeTransmission,       
--                      CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, CarContent.dbo.SippCodes.SippCodeClass,       
--                      CarContent.dbo.SabreLocations.LocationCity AS dropoffCity, CarContent.dbo.SabreLocations.Locationstate AS dropoffState,       
--                      CarContent.dbo.SabreLocations.LocationCountry AS dropoffCountry, SabreLocations_1.LocationCity AS pickupCity, SabreLocations_1.Locationstate AS pickupState,       
--                      SabreLocations_1.LocationCountry AS pickupCountry, dbo.CarResponse.minRateTax, dbo.CarResponse.TotalChargeAmt, dbo.CarResponse.minRate      
--FROM         dbo.CarResponseDetail INNER JOIN      
--                      dbo.CarResponse ON dbo.CarResponseDetail.carResponseKey = dbo.CarResponse.carResponseKey INNER JOIN      
--                      CarContent.dbo.SippCodes ON dbo.CarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType INNER JOIN      
--                      CarContent.dbo.CarCompanies ON dbo.CarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType AND       
--                      CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey INNER JOIN      
--                      CarContent.dbo.SabreLocations LEFT OUTER JOIN      
--                      CarContent.dbo.SabreVehicles ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode AND       
--                      CarContent.dbo.SabreLocations.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND       
--                      CarContent.dbo.SabreLocations.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode INNER JOIN      
--                      CarContent.dbo.SabreLocations AS SabreLocations_1 ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode AND       
--                      CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode AND       
--                      CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode ON       
--                      dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode AND      
--                       dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND       
--                      dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode LEFT OUTER JOIN      
--                      dbo.CarRequest ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey      
--                      where dbo.CarRequest .carRequestKey=@CarRequestKey      
--                       and  dbo.CarResponseDetail.carVendorKey in ( select * from vault.dbo.ufn_CSVToTable ( @carVendors )) and dbo.CarResponseDetail.minRate<= @Price      
                             
--GROUP BY dbo.CarResponseDetail.carVendorKey, dbo.CarResponse.carResponseKey, dbo.CarResponse.TotalChargeAmt, dbo.CarResponse.carRequestKey,       
--                      dbo.CarResponse.supplierId, dbo.CarResponse.carCategoryCode, dbo.CarResponse.carLocationCode, dbo.CarResponse.carLocationCategoryCode,       
--                      CarContent.dbo.SabreVehicles.VehicleName, SabreLocations_1.LocationName, SabreLocations_1.LocationAddress1, SabreLocations_1.Latitude,       
--                      SabreLocations_1.Longitude, SabreLocations_1.ZipCode, CarContent.dbo.SabreLocations.Latitude, CarContent.dbo.SabreLocations.Longitude,       
--                      CarContent.dbo.SabreLocations.ZipCode, CarContent.dbo.SabreLocations.LocationAddress1, CarContent.dbo.SabreLocations.LocationName,       
--                      dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate, CarContent.dbo.SippCodes.SippCodeDescription, CarContent.dbo.SippCodes.SippCodeTransmission,       
--                      CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, CarContent.dbo.SippCodes.SippCodeClass,       
--                      CarContent.dbo.SabreLocations.LocationCity, CarContent.dbo.SabreLocations.Locationstate, CarContent.dbo.SabreLocations.LocationCountry,       
--                      SabreLocations_1.LocationCity, SabreLocations_1.Locationstate, SabreLocations_1.LocationCountry, dbo.CarResponse.minRateTax,       
--                      dbo.CarResponse.TotalChargeAmt, dbo.CarResponse.minRate      
       
      
/*SELECT carVendorKey as carCompany ,CarCompanyname, MIN (minRate)as LowestPrice, carCategoryCode as carClassCat FROM vw_sabreCarResponse      
 where CarRequestKey=@CarRequestKey group by carVendorKey,CarCompanyname,carCategoryCode*/      
--SELECT   
--carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey as carCompany ,vw_sabreCarResponse.CarCompanyname, MIN(carresponsedetail.minRate) as LowestPrice,      
--carresponsedetail.carCategoryCode as carClassCat,CarContent.dbo.SippCodes.SippCodeClass as carClassDes ,carresponsedetail.NoOfDays,      
--CarContent.dbo.SabreVehicles.ImageName, ImageName,   
--CarContent.dbo.SabreVehicles.VehicleName,CarResponse.carLocationCode,vw_sabreCarResponse.pickupCity,      
--vw_sabreCarResponse.pickupLocationAddress,vw_sabreCarResponse.dropoffLocationAddress,vw_sabreCarResponse.pickupDate,vw_sabreCarResponse.TotalChargeAmt,      
--vw_sabreCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity as passenger, CarContent.dbo.SabreVehicles.baggage as baggage,  
--carresponsedetail.minRateTax as minRateTax,CarContent.dbo.SippCodes.SippCodeTransmission, CarContent.dbo.SippCodes.SippCodeDescription,             
--   CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.SabreVehicles.VehicleName as newVehicleName, 'no-image.jpg' as newImageName,  
--   vw_sabreCarResponse.pickupLatitude,vw_sabreCarResponse.pickupLongitude, carresponsedetail.contractCode, vw_sabreCarResponse.dropoffCity,  
--   carresponse.PickupLocInfoCode, vw_sabreCarResponse.dropoffState as DropoffState, vw_sabreCarResponse.dropoffCountry as DropoffCountry  
--   , vw_sabreCarResponse.pickupState as PickupState, vw_sabreCarResponse.pickupCountry as PickupCountry  
--   ,vw_sabreCarResponse.dropoffDate, vw_sabreCarResponse.pickupCityCode, vw_sabreCarResponse.dropoffCityCode, vw_sabreCarResponse.pickupairport, vw_sabreCarResponse.dropoffairport  
-- FROM vw_sabreCarResponse      
-- inner join      
-- carresponsedetail      
-- on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey   
-- inner join CarResponse on      
-- CarResponse.carResponseKey=CarResponseDetail.carResponseKey      
-- inner join CarContent .dbo.SippCodes   on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType      
-- inner join CarContent.dbo.SabreVehicles on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode      
-- and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode      
-- and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode      
-- WHERE vw_sabreCarResponse.carRequestKey=@CarRequestKey   
-- group by   
-- carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey ,vw_sabreCarResponse.CarCompanyname, carresponsedetail.minRate ,      
--carresponsedetail.carCategoryCode ,CarContent.dbo.SippCodes.SippCodeClass  ,carresponsedetail.NoOfDays,      
--CarContent.dbo.SabreVehicles.ImageName, ImageName,   
--CarContent.dbo.SabreVehicles.VehicleName,CarResponse.carLocationCode,vw_sabreCarResponse.pickupCity,      
--vw_sabreCarResponse.pickupLocationAddress,vw_sabreCarResponse.dropoffLocationAddress,vw_sabreCarResponse.pickupDate,vw_sabreCarResponse.TotalChargeAmt,      
--vw_sabreCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity , CarContent.dbo.SabreVehicles.baggage ,  
--carresponsedetail.minRateTax ,CarContent.dbo.SippCodes.SippCodeTransmission, CarContent.dbo.SippCodes.SippCodeDescription,             
--   CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.SabreVehicles.VehicleName ,newImageName,  
--   vw_sabreCarResponse.pickupLatitude,vw_sabreCarResponse.pickupLongitude, carresponsedetail.contractCode, vw_sabreCarResponse.dropoffCity,  
--   carresponse.PickupLocInfoCode, vw_sabreCarResponse.dropoffState , vw_sabreCarResponse.dropoffCountry  
--   , vw_sabreCarResponse.pickupState , vw_sabreCarResponse.pickupCountry   
--   ,vw_sabreCarResponse.dropoffDate, vw_sabreCarResponse.pickupCityCode, vw_sabreCarResponse.dropoffCityCode, vw_sabreCarResponse.pickupairport, vw_sabreCarResponse.dropoffairport  
     
--  Having  Min(carresponsedetail.minRate) <> 0         
-- order by CarResponseDetail.minRate   
    SELECT * FROM   
(  
 SELECT    
 carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey as carCompany ,vw_sabreCarResponse.CarCompanyname,carresponsedetail.minRate as LowestPrice,      
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
    ,vw_sabreCarResponse.dropoffDate, vw_sabreCarResponse.pickupCityCode, vw_sabreCarResponse.dropoffCityCode, vw_sabreCarResponse.pickupairport, vw_sabreCarResponse.dropoffairport,  
     vw_sabreCarResponse.AirportDistance,vw_sabreCarResponse.AirportDistanceUnit,vw_sabreCarResponse.PickupDistance,vw_sabreCarResponse.DropDistance,vw_sabreCarResponse.PickupDistanceUnit,  
  vw_sabreCarResponse.DropDistanceUnit,vw_sabreCarResponse.PickupAddress,vw_sabreCarResponse.DropAddress,vw_sabreCarResponse.RequestType, vw_sabreCarResponse.PickUpLatLong,  
     vw_sabreCarResponse.DropOffLatLong, carresponsedetail.ReasonCode,carresponsedetail.IsSuppressVendor, ROW_NUMBER() OVER (PARTITION BY carresponsedetail.carVendorKey,carresponsedetail.carCategoryCode ORDER BY carresponsedetail.carVendorKey) AS rn,vw_sabreCarResponse.inTerminal  
      FROM #tmp_vw_sabreCarResponse vw_sabreCarResponse WITH (NOLOCK)     
  inner join      
  #tmpCarResponseDetail carresponsedetail WITH (NOLOCK)     
  on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey   
  inner join CarResponse WITH (NOLOCK) on   
  CarResponse.carResponseKey=CarResponseDetail.carResponseKey      
  inner join CarContent .dbo.SippCodes WITH (NOLOCK)   on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType      
  inner join CarContent.dbo.SabreVehicles WITH (NOLOCK) on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode      
  and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode      
  and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode      
  WHERE vw_sabreCarResponse.carRequestKey=@CarRequestKey and CarResponseDetail.minRate <= @Price  
--  group by   
--  carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey ,vw_sabreCarResponse.CarCompanyname, carresponsedetail.minRate ,      
-- carresponsedetail.carCategoryCode ,CarContent.dbo.SippCodes.SippCodeClass  ,carresponsedetail.NoOfDays,      
-- CarContent.dbo.SabreVehicles.ImageName,   
-- CarContent.dbo.SabreVehicles.VehicleName,CarResponse.carLocationCode,vw_sabreCarResponse.pickupCity,      
-- vw_sabreCarResponse.pickupLocationAddress,vw_sabreCarResponse.dropoffLocationAddress,vw_sabreCarResponse.pickupDate,vw_sabreCarResponse.TotalChargeAmt,      
-- vw_sabreCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity , CarContent.dbo.SabreVehicles.baggage ,  
-- carresponsedetail.minRateTax ,CarContent.dbo.SippCodes.SippCodeTransmission, CarContent.dbo.SippCodes.SippCodeDescription,             
--    CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.SabreVehicles.VehicleName ,newImageName,  
--    vw_sabreCarResponse.pickupLatitude,vw_sabreCarResponse.pickupLongitude, carresponsedetail.contractCode, vw_sabreCarResponse.dropoffCity,  
--    carresponse.PickupLocInfoCode, vw_sabreCarResponse.dropoffState , vw_sabreCarResponse.dropoffCountry  
--    , vw_sabreCarResponse.pickupState , vw_sabreCarResponse.pickupCountry   
--    ,vw_sabreCarResponse.dropoffDate, vw_sabreCarResponse.pickupCityCode, vw_sabreCarResponse.dropoffCityCode, vw_sabreCarResponse.pickupairport, vw_sabreCarResponse.dropoffairport  
--    ,vw_sabreCarResponse.AirportDistance,vw_sabreCarResponse.AirportDistanceUnit,vw_sabreCarResponse.PickupDistance,vw_sabreCarResponse.DropDistance,vw_sabreCarResponse.PickupDistanceUnit,  
--    vw_sabreCarResponse.DropDistanceUnit,vw_sabreCarResponse.PickupAddress,vw_sabreCarResponse.DropAddress,vw_sabreCarResponse.RequestType,vw_sabreCarResponse.PickUpLatLong,vw_sabreCarResponse.DropOffLatLong, carresponsedetail.ReasonCode  
--   Having  Min(carresponsedetail.minRate) <> 0         
--) tmp WHERE RowNum = 1     
)tmp 
WHERE tmp.rn=1 OR tmp.RequestType=2 
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
 FROM vw_sabreCarResponse      
 inner join      
 #tmpCarResponseDetail carresponsedetail WITH (NOLOCK)   
 on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey      
       
 where CarRequestKey=@CarRequestKey      
  and carresponsedetail.minRate <> 0     
 group by CarResponseDetail.carCategoryCode      
  order by carresponsedetail.carCategoryCode      
       
       
       
  select MIN(minrate) as FilterLowestPrice,carVendorKey as FilterCarCompany,CarCompanyname from vw_sabreCarResponse      
  where CarRequestKey= @CarRequestKey group by carVendorKey,CarCompanyname having MIN(minrate) <> 0       
       
Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice FROM vw_sabreCarResponse where CarRequestKey=@CarRequestKey and minrate <> 0   
SELECT SippCodeClass as carClassCat , MIN (minRate)as LowestPrice FROM vw_sabreCarResponse where CarRequestKey=@CarRequestKey and minrate <> 0 group by SippCodeClass    
      
 end      
       
 else      
 begin      
       
 SET @sqlString ='SELECT * FROM #tmp_vw_sabreCarResponse vw_sabreCarResponse where carRequestKey= '+CONVERT(varchar,@CarRequestKey)      
 +' and  minRate<='+ CONVERT(varchar,@Price)      
 + ' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'      
      
       
 exec(@sqlString)      
        
 --SELECT * FROM vw_sabreCarResponse where carRequestKey=@CarRequestKey      
 --and  carVendorKey in ( select * from ufn_CSVToTable ( @carVendors )) and minRate<= @Price      
       
      
/*SELECT carVendorKey as carCompany ,CarCompanyname, MIN (minRate)as LowestPrice,carCategoryCode as carClassCat FROM vw_sabreCarResponse      
 where CarRequestKey=@CarRequestKey group by carVendorKey,CarCompanyname,carCategoryCode*/      
--select * from carresponsedetail      
 SELECT carresponsedetail.carResponseDetailKey,vw_sabreCarResponse.carVendorKey as carCompany ,vw_sabreCarResponse.CarCompanyname,  
 carresponsedetail.minRate as LowestPrice,      
carresponsedetail.carCategoryCode as carClassCat,CarContent .dbo.SippCodes.SippCodeDescription as carClassDes ,      
CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.VehicleName,passenger, vw_sabreCarResponse.baggage,CarContent.dbo.SippCodes.SippCodeTransmission,             
   CarContent.dbo.SippCodes.SippCodeAC, carresponsedetail.contractCode,CarResponseDetail.inTerminal      
 FROM #tmp_vw_sabreCarResponse vw_sabreCarResponse      
 inner join      
 #tmpCarResponseDetail carresponsedetail WITH (NOLOCK)   
 on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey      
 inner join CarContent.dbo.SippCodes   WITH (NOLOCK) on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType       
 inner join CarContent.dbo.SabreVehicles WITH (NOLOCK) on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode      
   and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode      
 and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode      
 where CarRequestKey=@CarRequestKey       
 order by CarResponseDetail.minRate      
      
       
       
-- SELECT distinct       
--carresponsedetail.carResponseKey,      
--carresponsedetail.carVendorKey, carresponsedetail.carCategoryCode,carresponsedetail.minRate,      
--CarContent.dbo.SabreVehicles.LocationAirportCode,max(CarContent.dbo.SabreVehicles.LocationId)as LocId,CarContent.dbo.SabreVehicles.ImageName      
-- FROM vw_sabreCarResponse      
-- inner join      
-- carresponsedetail      
-- on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey      
-- inner join CarContent.dbo.SabreVehicles on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode      
-- and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey      
-- and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode      
       
-- where vw_sabreCarResponse.carRequestKey=@CarRequestKey      
-- and CarContent.dbo.SabreVehicles.ImageName is not null       
      
-- group by      
      
--carresponsedetail.carResponseKey,      
--carresponsedetail.carVendorKey, carresponsedetail.carCategoryCode,carresponsedetail.minRate,      
--CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.LocationAirportCode,      
--CarContent.dbo.SabreVehicles.ImageName      
      
       
      
 SELECT COUNT(*)  as NoOfCars,CarResponseDetail.carCategoryCode      
 FROM #tmp_vw_sabreCarResponse vw_sabreCarResponse      
 inner join      
 #tmpCarResponseDetail carresponsedetail WITH (NOLOCK)   
 on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey      
       
 where CarRequestKey=@CarRequestKey      
 group by CarResponseDetail.carCategoryCode      
  order by carresponsedetail.carCategoryCode      
       
      
      
  select MIN(minrate) as FilterLowestPrice,carVendorKey as FilterCarCompany,CarCompanyname   
  from #tmp_vw_sabreCarResponse vw_sabreCarResponse      
  where CarRequestKey= @CarRequestKey group by carVendorKey,CarCompanyname      
        
Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice   
FROM #tmp_vw_sabreCarResponse vw_sabreCarResponse   
where CarRequestKey=@CarRequestKey   
SELECT SippCodeClass as carClassCat , MIN (minRate)as LowestPrice  
FROM #tmp_vw_sabreCarResponse vw_sabreCarResponse   
where CarRequestKey=@CarRequestKey group by SippCodeClass      
      

       
 end      
  
  
  
GO
