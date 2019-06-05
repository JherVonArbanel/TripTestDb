SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 12-06-2014 12:32pm  
-- Description: Car Response Cache Result  
  
--exec [USP_GetCarCacheResponsesForRequest] 116087,'','','','',9999999999.99
-- =============================================  
CREATE PROCEDURE [dbo].[USP_GetCarCacheResponsesForRequest]  
( @CarRequestKey int ,      
  @carVendors varchar(200)='',      
  @sortField varchar(50)='',      
  @carClasses varchar(200)='',      
  @carTypes varchar(200)='',      
  @Price float=9999999999.99      
        
 )      
AS      
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
     
  Declare @pickUpCityCode varchar(3)  
  Declare @dropOffCityCode varchar(3)  
    
    DECLARE @carResponseResult TABLE                 
  (                
 rowNum INT IDENTITY(1,1) NOT NULL,                 
 carResponseKey uniqueidentifier,  
 carRequestKey int ,  
 carVendorKey VARCHAR(50) ,  
 supplierId VARCHAR(50) ,  
 carCategoryCode VARCHAR(50) ,  
 carLocationCode VARCHAR(50) ,  
 carLocationCategoryCode VARCHAR(50) ,  
 minRate float ,  
 minRateTax float,  
 DailyRate float,  
 TotalChargeAmt float,  
 NoOfDays int ,  
 RateQualifier VARCHAR(25) ,  
 ReferenceType VARCHAR(10) ,  
 ReferenceDateTime VARCHAR(20) ,  
 ReferenceId VARCHAR(50),  
 MileageAllowance VARCHAR(10),  
 RatePlan VARCHAR(10),  
 contractCode VARCHAR(20),  
 OperationTimeStart VARCHAR(10),  
 OperationTimeEnd VARCHAR(10),  
 PickupLocationInfo VARCHAR(100),  
 PickupLocInfoCode VARCHAR(4),
 RequestType int,
 PickupDistance float,
 DropDistance float,
 AirportDistance float,
 PickupDistanceUnit VARCHAR(4), 
 DropDistanceUnit VARCHAR(4),
 PickupAddress  VARCHAR(100),
 DropAddress  VARCHAR(100), 
 AirportDistanceUnit VARCHAR(2)
  )     
    
  SELECT @pickUpCityCode = pickUpCityCode FROM Trip..CarRequest WITH (NOLOCK) WHERE carRequestKey=@CarRequestKey  
  SET @dropOffCityCode = @pickUpCityCode;  
    
  --INSERT INTO @carResponseResult VALUES ('06F56848-EEC8-48C6-81EF-F26160700DA8',@CarRequestKey,'ZA','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('9B18524F-69F4-4DF0-96AD-8C0970CA7428',@CarRequestKey,'AD','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('3BBB7FB1-7DB7-448F-A134-9983A84A8E6C',@CarRequestKey,'ZD','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('C435D09C-443F-4F96-83A3-88C7D3D2A471',@CarRequestKey,'FX','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('4124C8FA-3F13-494D-8CF6-8EA4B6EA50F1',@CarRequestKey,'FF','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('18BC32E2-BB37-48F0-9943-A11B4704E07E',@CarRequestKey,'ET','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('20620EE3-D370-4364-8DB9-C78CE17500E1',@CarRequestKey,'SC','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('7D0EDA3E-A7D0-4DD4-A1ED-86FB6F83ACF6',@CarRequestKey,'AL','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('FD8FFFE1-3A83-49E2-ADD9-A085B779D2C7',@CarRequestKey,'ZI','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('14543332-B2E2-4C74-A053-F133668F1812',@CarRequestKey,'ZL','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
  --INSERT INTO @carResponseResult VALUES ('044AB748-4362-47C2-BCD9-DAAC25D6E764',@CarRequestKey,'ZE','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,'UNL','DY',NULL,NULL,NULL,NULL,NULL)  
    
	WITH summary AS (
		SELECT 
			p.SippCode, 			
			p.VendorCode, 
			ROW_NUMBER() 
		OVER(PARTITION BY p.VendorCode ORDER BY p.VendorCode ASC) AS rk
		FROM 
			CarContent.dbo.SabreVehicles p
		WHERE 
			LocationAirportCode = @pickUpCityCode and LocationCategoryCode = @pickUpCityCode)
		INSERT INTO @carResponseResult       
		SELECT 
			NEWID(),
			@CarRequestKey,s.VendorCode,'Sabre',s.SippCode,
			@pickUpCityCode,@dropOffCityCode,0,0,0,0,NULL,0,NULL,NULL,NULL,
			'UNL','DY',NULL,NULL,NULL,NULL,NULL,0,0,0,0,NULL,NULL,NULL,NULL,NULL
		FROM 
			summary s
		WHERE 
			s.rk = 1
          
  DECLARE @carDetailResponseResult TABLE                 
  (   
 rowNum INT IDENTITY(1,1) NOT NULL,           
 carResponseDetailKey uniqueidentifier ,  
 carResponseKey uniqueidentifier ,  
 carVendorKey VARCHAR(50) ,  
 supplierId VARCHAR(50) ,  
 carCategoryCode VARCHAR(50) ,  
 carLocationCode VARCHAR(50) ,  
 carLocationCategoryCode VARCHAR(50) ,  
 minRate float ,  
 minRateTax float ,  
 NoOfDays int ,  
 RateQualifier VARCHAR(25) ,  
 ReferenceType VARCHAR(10) ,  
 ReferenceDateTime VARCHAR(20) ,  
 ReferenceId VARCHAR(50) ,  
 MileageAllowance VARCHAR(10) ,  
 RatePlan VARCHAR(10) ,  
 GuaranteeCode VARCHAR(20) ,  
 SellGuaranteeReq bit ,  
 contractCode VARCHAR(20) ,  
 rateTypeCode VARCHAR(20) ,  
 carRules VARCHAR(2000),
 RequestType int,
 PickupDistance float,
 DropDistance float,
 AirportDistance float,
 PickupDistanceUnit VARCHAR(4), 
 DropDistanceUnit VARCHAR(4),
 PickupAddress  VARCHAR(100),
 DropAddress  VARCHAR(100), 
 AirportDistanceUnit VARCHAR(2)
 );
   
      
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','06F56848-EEC8-48C6-81EF-F26160700DA8','ZA','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'ZA',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','9B18524F-69F4-4DF0-96AD-8C0970CA7428','AD','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'AD',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','3BBB7FB1-7DB7-448F-A134-9983A84A8E6C','ZD','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'ZD',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','C435D09C-443F-4F96-83A3-88C7D3D2A471','FX','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'FX',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','4124C8FA-3F13-494D-8CF6-8EA4B6EA50F1','FF','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'FF',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','18BC32E2-BB37-48F0-9943-A11B4704E07E','ET','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'ET',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','20620EE3-D370-4364-8DB9-C78CE17500E1','SC','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'SC',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','7D0EDA3E-A7D0-4DD4-A1ED-86FB6F83ACF6','AL','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'AL',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','FD8FFFE1-3A83-49E2-ADD9-A085B779D2C7','ZI','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'Z1',NULL)        
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','14543332-B2E2-4C74-A053-F133668F1812','ZL','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'ZL',NULL)            
--INSERT INTO @carDetailResponseResult VALUES ('00000000-0000-0000-0000-000000000000','044AB748-4362-47C2-BCD9-DAAC25D6E764','ZE','Sabre','ECAR',@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL','DY','G',0,NULL,'ZE',NULL)        
      
	WITH newsummary AS (
		SELECT 
			p.SippCode, 			
			p.VendorCode, 
			ROW_NUMBER() 
		OVER(PARTITION BY p.VendorCode ORDER BY p.VendorCode ASC) AS rk
		FROM 
			CarContent.dbo.SabreVehicles p
		WHERE 
			LocationAirportCode = @pickUpCityCode and LocationCategoryCode = @pickUpCityCode)
		INSERT INTO @carDetailResponseResult       
		SELECT 
			'00000000-0000-0000-0000-000000000000','06F56848-EEC8-48C6-81EF-F26160700DA8',
			s.VendorCode,'Sabre',s.SippCode,@pickUpCityCode,@dropOffCityCode,0,0,1,'D',NULL,NULL,NULL,'UNL',
			'DY','G',0,NULL,s.VendorCode,NULL,0,0,0,0,NULL,NULL,NULL,NULL,NULL
		FROM 
			newsummary s
		WHERE 
			s.rk = 1;  
    
  DECLARE @carDetails TABLE                 
  (      
 rowNum INT IDENTITY(1,1) NOT NULL,                 
 carResponseKey uniqueidentifier,  
 carRequestKey int ,  
 carVendorKey VARCHAR(50) ,  
 supplierId VARCHAR(50) ,  
 carCategoryCode VARCHAR(50) ,  
 carLocationCode VARCHAR(50) ,  
 carLocationCategoryCode VARCHAR(50) ,  
 PerDayRate float ,  
 VehicleName VARCHAR(50) ,  
 pickupLocationName VARCHAR(50) ,  
 pickupLocationAddress VARCHAR(150),  
 pickupLongitude VARCHAR(50),  
 pickupLatitude VARCHAR(50),  
 pickupZipCode VARCHAR(50),  
 dropoffLatitude VARCHAR(50),  
 dropoffLongitude VARCHAR(50),  
 dropoffZipCode VARCHAR(50),  
 dropoffLocationAddress VARCHAR(150),  
 dropoffLocationName VARCHAR(50),  
 pickupDate DateTime,  
 dropoffDate DateTime,  
 SippCodeDescription VARCHAR(50),  
 SippCodeTransmission VARCHAR(50),  
 SippCodeAC VARCHAR(50),  
 CarCompanyName VARCHAR(50),  
 SippCodeClass VARCHAR(50),  
 dropoffCity VARCHAR(50),  
 dropoffState VARCHAR(50),  
 dropoffCountry VARCHAR(50),  
 pickupCity VARCHAR(50),  
 pickupState VARCHAR(50),  
 pickupCountry VARCHAR(50),  
 minRateTax float,  
 TotalChargeAmt float,  
 minRate float,  
    passenger VARCHAR(50),  
    Baggage VARCHAR(50),  
    MileageAllowance VARCHAR(50),  
    RatePlan VARCHAR(50),  
    contractCode VARCHAR(50),  
    OperationTimeStart VARCHAR(50),  
    OperationTimeEnd VARCHAR(50),
    pickupCityCode DATETIME, 
    dropoffCityCode VARCHAR(50), 
    pickupairport VARCHAR(50), 
    dropoffairport VARCHAR(50),
 carDropOffLocationCode VARCHAR(50),
 carDropOffLocationCategoryCode VARCHAR(50),
 RequestType int,
 PickupDistance float,
 DropDistance float,
 AirportDistance FLOAT,
 PickupDistanceUnit VARCHAR(4), 
 DropDistanceUnit VARCHAR(4),
 PickupAddress  VARCHAR(100),
 DropAddress  VARCHAR(100), 
 AirportDistanceUnit VARCHAR(4)
  )  
    
  INSERT INTO @carDetails   
  SELECT     CR.carResponseKey, CR.carRequestKey, CR.carVendorKey, CR.supplierId,   
                      CR.carCategoryCode, CR.carLocationCode, CR.carLocationCategoryCode, CR.minRate AS PerDayRate,   
                      CarContent.dbo.SabreVehicles.VehicleName, SabreLocations_1.LocationName AS pickupLocationName,   
                      SabreLocations_1.LocationAddress1 AS pickupLocationAddress, SabreLocations_1.Latitude AS pickupLatitude, SabreLocations_1.Longitude AS pickupLongitude,   
                      SabreLocations_1.ZipCode AS pickupZipCode, CarContent.dbo.SabreLocations.Latitude AS dropoffLatitude,   
                      CarContent.dbo.SabreLocations.Longitude AS dropoffLongitude, CarContent.dbo.SabreLocations.ZipCode AS dropoffZipCode,   
                      CarContent.dbo.SabreLocations.LocationAddress1 AS dropoffLocationAddress, CarContent.dbo.SabreLocations.LocationName AS dropoffLocationName,   
                      dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate, CarContent.dbo.SippCodes.SippCodeDescription, CarContent.dbo.SippCodes.SippCodeTransmission,   
                      CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, CarContent.dbo.SippCodes.SippCodeClass,   
                      CarContent.dbo.SabreLocations.LocationCity AS dropoffCity, CarContent.dbo.SabreLocations.Locationstate AS dropoffState,   
                      CarContent.dbo.SabreLocations.LocationCountry AS dropoffCountry, SabreLocations_1.LocationCity AS pickupCity, SabreLocations_1.Locationstate AS pickupState,   
                      SabreLocations_1.LocationCountry AS pickupCountry, CR.minRateTax, CR.TotalChargeAmt, CR.minRate,   
                      CarContent.dbo.SabreVehicles.PsgrCapacity AS passenger, CarContent.dbo.SabreVehicles.Baggage, CR.MileageAllowance,   
                      CR.RatePlan, CR.contractCode,CR.OperationTimeStart,CR.OperationTimeEnd, '', '', '', ''  ,SabreLocations.LocationAirportCode as carDropOffLocationCode,SabreLocations.LocationAirportCode as carDropOffLocationCategoryCode,
					  CR.RequestType, CR.PickupDistance, CR.DropDistance, CR.AirportDistance, CR.PickupDistanceUnit,  CR.DropDistanceUnit, CR.PickupAddress, CR.DropAddress,  CR.AirportDistanceUnit
FROM         CarContent.dbo.CarCompanies WITH (NOLOCK)   
       LEFT OUTER JOIN  @carResponseResult CR ON CarContent.dbo.CarCompanies.CarCompanyCode = CR.carVendorKey   
       INNER JOIN  CarContent.dbo.SippCodes WITH (NOLOCK) ON CR.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType   
       INNER JOIN  CarContent.dbo.SabreVehicles WITH (NOLOCK) ON CR.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode   
         AND CR.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode   
         AND CR.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode   
         AND CR.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode   
       INNER JOIN  CarContent.dbo.SabreLocations WITH (NOLOCK) ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode   
       INNER JOIN  CarContent.dbo.SabreLocations AS SabreLocations_1 WITH (NOLOCK) ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode   
         AND SabreLocations_1.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode   
         AND SabreLocations_1.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode   
       INNER JOIN dbo.CarRequest WITH (NOLOCK) ON CR.carRequestKey = dbo.CarRequest.carRequestKey   
         AND dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationAirportCode   
         AND dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationCategoryCode   
         AND dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationAirportCode   
         AND dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationCategoryCode  
  WHERE dbo.CarRequest.carRequestKey = @CarRequestKey  
    
     
        
              
  SELECT   
   vwCarResponse.carResponseKey,      
   vwCarResponse.carRequestKey,      
   vwCarResponse.carVendorKey,      
   vwCarResponse.supplierId,      
   vwCarResponse.carCategoryCode,      
   vwCarResponse.carLocationCode,      
   vwCarResponse.carLocationCategoryCode,      
   --vwCarResponse.PerDayRate,      
   isnull(0 , vwCarResponse.PerDayRate)    PerDayRate,      
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
   ISNULL('ECAR' ,  vwCarResponse.SippCodeClass) as SippCodeCarType ,      
   --A.SippCodeCarType  as SippCodeCarType ,      
   vwCarResponse.dropoffCity,      
   vwCarResponse.dropoffState,      
   vwCarResponse.dropoffCountry,      
   vwCarResponse.pickupCity,      
   vwCarResponse.pickupState,      
   vwCarResponse.pickupCountry,      
   vwCarResponse.minRateTax,      
   vwCarResponse.TotalChargeAmt,      
   isnull(0 , vwCarResponse.minRate)    minRate,      
   vwCarResponse.passenger,      
   vwCarResponse.baggage,    
   vwCarResponse.MileageAllowance,     
   vwCarResponse.contractCode,  
   vwCarResponse.OperationTimeStart,vwCarResponse.OperationTimeEnd  ,
   vwCarResponse.carDropOffLocationCode,
   vwCarResponse.carDropOffLocationCategoryCode,
vwCarResponse.RequestType ,
vwCarResponse.PickupDistance,
vwCarResponse.PickupDistanceUnit,
vwCarResponse.DropDistance,
vwCarResponse.DropDistanceUnit,
vwCarResponse.PickupAddress,
vwCarResponse.DropAddress,
vwCarResponse.AirportDistance,
vwCarResponse.AirportDistanceUnit
 FROM @carDetails vwCarResponse    
 WHERE vwCarResponse.carRequestKey =@CarRequestKey  
 order by CarCompanyName   
       
  
SELECT CRD.carResponseDetailKey,CRD.carVendorKey as carCompany ,vw_sabreCacheCarResponse.CarCompanyname
, CRD.minRate as LowestPrice, CRD.carCategoryCode as carClassCat
,CarContent.dbo.SippCodes.SippCodeClass as carClassDes ,CRD.NoOfDays,      
(ISNull(CarContent.dbo.SabreVehicles.ImageName,  
ISNULL((SELECT TOP 1 N.CarImage FROM CarContent.dbo.NewCarImages N WITH (NOLOCK) WHERE N.VendorCode = CRD.carVendorKey  AND N.CarCode = CRD.carCategoryCode),
ISNULL((SELECT TOP 1 N.CarImage FROM CarContent.dbo.NewCarImages N WITH (NOLOCK) WHERE N.VendorCode = CRD.carVendorKey  AND LEFT(N.CarCode, 1) = LEFT(CRD.carCategoryCode, 1)), 'no-image.jpg')))) as ImageName,
CarContent.dbo.SabreVehicles.VehicleName,CR.carLocationCode,vw_sabreCacheCarResponse.pickupCity,      
vw_sabreCacheCarResponse.pickupLocationAddress,vw_sabreCacheCarResponse.dropoffLocationAddress,vw_sabreCacheCarResponse.pickupDate,vw_sabreCacheCarResponse.TotalChargeAmt,      
vw_sabreCacheCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity as passenger, CarContent.dbo.SabreVehicles.baggage as baggage,CRD.minRateTax as minRateTax,CarContent.dbo.SippCodes.SippCodeTransmission,             
   CarContent.dbo.SippCodes.SippCodeAC,(CASE WHEN CarContent.dbo.SabreVehicles.ImageName IS NULL  
   THEN   
    CASE WHEN (SELECT TOP 1 N.CarName FROM CarContent.dbo.NewCarImages N WITH (NOLOCK) WHERE N.VendorCode = CRD.carVendorKey  AND N.CarCode = CRD.carCategoryCode) IS NULL   
     THEN CASE WHEN (SELECT TOP 1 N.CarName FROM CarContent.dbo.NewCarImages N WITH (NOLOCK) WHERE N.VendorCode = CRD.carVendorKey  AND LEFT(N.CarCode, 1) = LEFT(CRD.carCategoryCode, 1)) IS NULL  
      THEN CarContent.dbo.SabreVehicles.VehicleName  
      ELSE (SELECT TOP 1 N.CarName FROM CarContent.dbo.NewCarImages N  WITH (NOLOCK) WHERE N.VendorCode = CRD.carVendorKey  AND LEFT(N.CarCode, 1) = LEFT(CRD.carCategoryCode, 1))  
      END  
    ELSE (SELECT TOP 1 N.CarName FROM CarContent.dbo.NewCarImages N  WITH (NOLOCK) WHERE N.VendorCode = CRD.carVendorKey  AND N.CarCode = CRD.carCategoryCode)   
    END  
   ELSE CarContent.dbo.SabreVehicles.VehicleName  
   END) as newVehicleName, 'no-image.jpg' as newImageName,  
   vw_sabreCacheCarResponse.pickupLatitude,vw_sabreCacheCarResponse.pickupLongitude, CRD.contractCode, vw_sabreCacheCarResponse.dropoffCity,CarContent.dbo.SippCodes.SippCodeDescription,  
   CR.PickupLocInfoCode, vw_sabreCacheCarResponse.dropoffState as DropoffState, vw_sabreCacheCarResponse.dropoffCountry as DropoffCountry  
   , vw_sabreCacheCarResponse.pickupState as PickupState, vw_sabreCacheCarResponse.pickupCountry as PickupCountry  
   ,vw_sabreCacheCarResponse.dropoffDate, vw_sabreCacheCarResponse.pickupCityCode, vw_sabreCacheCarResponse.dropoffCityCode, vw_sabreCacheCarResponse.pickupairport, vw_sabreCacheCarResponse.dropoffairport,
    vw_sabreCacheCarResponse.RequestType, vw_sabreCacheCarResponse.PickupDistance, vw_sabreCacheCarResponse.DropDistance, vw_sabreCacheCarResponse.AirportDistance, vw_sabreCacheCarResponse.PickupDistanceUnit,
	  vw_sabreCacheCarResponse.DropDistanceUnit, vw_sabreCacheCarResponse.PickupAddress, vw_sabreCacheCarResponse.DropAddress,  vw_sabreCacheCarResponse.AirportDistanceUnit
 FROM @carDetails vw_sabreCacheCarResponse      
 inner join      
 @carDetailResponseResult CRD     
 on CRD.carVendorKey=vw_sabreCacheCarResponse.carVendorKey      
 inner join @carResponseResult CR on      
 CR.carVendorKey=CRD.carVendorKey      
 inner join CarContent .dbo.SippCodes   WITH (NOLOCK) on CRD.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType      
 inner join CarContent.dbo.SabreVehicles  WITH (NOLOCK) on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCacheCarResponse.carLocationCode      
 and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode      
 and CarContent.dbo.SabreVehicles.VendorCode=CRD.carVendorKey 
 and CarContent.dbo.SabreVehicles.SippCode=CRD.carCategoryCode      
  where vw_sabreCacheCarResponse.carRequestKey=@CarRequestKey        
 order by CRD.minRate
 
-- SELECT
-- carResponseDetailKey
--,carVendorKey AS carCompany
--,CarCompanyname = 'Payless'
--,MinRate AS LowestPrice
--,carCategoryCode AS carClasscat
--,carClassDes = 'Economy'
--,NoOfDays
--,ImageName = 'FORD-FUSION.gif'
--,VehicleName = 'FORD FUSION'
--,carLocationCode
--,pickupCity = carLocationCode
--,pickupLocationAddress = @pickUpCityCode
--,dropoffLocationAddress = @dropOffCityCode
--,pickupDate = GETDATE()
--,TotalChargeAmt = 0
--,carResponseKey
--,passenger = 1
--,baggage = ''
--,minRateTax
--,SippCodeTransmission = 'Automatic'
--,SippCodeAC = 'Air Conditioning'
--,newVehicleName = 'FORD FUSION'
--,newImageName = 'no-image.jpg'
--,pickupLatitude = -0.450825
--,pickupLongitude = 51.4722
--,contractCode
--,dropoffCity = @dropOffCityCode
--,SippCodeDescription = '2/4 Door'
--,PickupLocInfoCode = NULL
--,DropoffState = ''
--,DropoffCountry = @pickUpCityCode
--,PickupState = ''
--,PickupCountry = ''
--,dropoffDate = GETDATE()
--,pickupCityCode = @pickUpCityCode
--,dropoffCityCode = @dropOffCityCode
--,pickupairport = @pickUpCityCode
--,dropoffairport = @dropOffCityCode
--FROM
--@carDetailResponseResult
--order by minRate
      
      
 SELECT COUNT(*)  as NoOfCars,CRD.carCategoryCode      
 FROM @carDetails  CD    
 inner join      
 @carDetailResponseResult CRD     
 on CRD.carVendorKey=CD.carVendorKey      
       
 where CarRequestKey=@CarRequestKey      
  --and CRD.minRate <> 0     
 group by CRD.carCategoryCode      
  order by CRD.carCategoryCode      
       
       
       
  select MIN(minrate) as FilterLowestPrice,carVendorKey as FilterCarCompany,CarCompanyname from @carDetails      
  where CarRequestKey= @CarRequestKey group by carVendorKey,CarCompanyname   
  --having MIN(minrate) <> 0       
       
Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice FROM @carDetails where CarRequestKey=@CarRequestKey   
--and minrate <> 0   
SELECT SippCodeClass as carClassCat , MIN (minRate)as LowestPrice FROM @carDetails where CarRequestKey=@CarRequestKey  
 --and minrate <> 0  
  group by SippCodeClass    
      
 end      
       
 else      
 begin      
 print @sortField      
      
 SET @sqlString ='SELECT * FROM @carDetails where carRequestKey= '+CONVERT(varchar,@CarRequestKey)      
 +' and  minRate<='+ CONVERT(varchar,@Price)      
 + ' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'
       
 exec(@sqlString)
    
 SELECT CRD.carResponseDetailKey,CRD.carVendorKey as carCompany ,vw_sabreCacheCarResponse.CarCompanyname, MIN (CRD.minRate)as LowestPrice,      
CRD.carCategoryCode as carClassCat,CarContent .dbo.SippCodes.SippCodeDescription as carClassDes ,      
CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.VehicleName,passenger, vw_sabreCacheCarResponse.baggage,CarContent.dbo.SippCodes.SippCodeTransmission,             
   CarContent.dbo.SippCodes.SippCodeAC, CRD.contractCode      
 FROM @carDetails vw_sabreCacheCarResponse      
 inner join      
 @carDetailResponseResult CRD      
 on CRD.carresponsekey=vw_sabreCacheCarResponse.carResponseKey      
 inner join CarContent.dbo.SippCodes    WITH (NOLOCK) on CRD.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType       
 inner join CarContent.dbo.SabreVehicles  WITH (NOLOCK) on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCacheCarResponse.carLocationCode      
   and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode      
 and CarContent.dbo.SabreVehicles.VendorCode=CRD.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=CRD.carCategoryCode      
 where CarRequestKey=@CarRequestKey      
  group by       
 CRD.carVendorKey,      
 vw_sabreCacheCarResponse.CarCompanyname,CRD.carCategoryCode,      
 CarContent .dbo.SippCodes.SippCodeDescription,CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.VehicleName,      
  CRD.carResponseDetailKey,CRD.minRate,passenger, vw_sabreCacheCarResponse.baggage,CarContent.dbo.SippCodes.SippCodeTransmission,             
   CarContent.dbo.SippCodes.SippCodeAC, CRD.contractCode      
 order by CRD.minRate      
          
       
      
 SELECT COUNT(*)  as NoOfCars,CRD.carCategoryCode      
 FROM @carDetails CD      
 inner join      
 @carDetailResponseResult CRD     
 on CRD.carresponsekey=CD.carResponseKey      
       
 where CarRequestKey=@CarRequestKey      
 group by CRD.carCategoryCode      
  order by CRD.carCategoryCode      
       
      
      
  select MIN(minrate) as FilterLowestPrice,carVendorKey as FilterCarCompany,CarCompanyname from @carDetails      
  where CarRequestKey= @CarRequestKey group by carVendorKey,CarCompanyname      
        
Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice FROM @carDetails where CarRequestKey=@CarRequestKey      
SELECT SippCodeClass as carClassCat , MIN (minRate)as LowestPrice FROM @carDetails where CarRequestKey=@CarRequestKey group by SippCodeClass      
      
       
 end      
  
  
GO
