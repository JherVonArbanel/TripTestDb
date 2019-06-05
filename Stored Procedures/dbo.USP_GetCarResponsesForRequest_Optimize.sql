SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec [USP_GetCarResponsesForRequest] 27223,'','','','',9999999999.99 - 3E5CB5B7-C1A0-420A-BBB4-D2665BEF667C    
    
CREATE PROCEDURE [dbo].[USP_GetCarResponsesForRequest_Optimize]    
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
       
       
   IF @sortField = ''    
    begin    
          
            
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
   vwCarResponse.contractCode
 FROM vw_sabreCarResponse vwCarResponse    
  Left join       
  (  select   CD.carVendorKey, MIN(CD.minRate) as PerDayminRate  , CD.carResponseKey ,CarContent.dbo.SippCodes.SippCodeCarType as SippCodeCarType         
  from carresponsedetail CD  WITH (NOLOCK)   
  Inner join carresponse Cd1 WITH (NOLOCK) on CD.carResponseKey = Cd1.carResponseKey  and Cd1.carRequestKey = @CarRequestKey     
  Inner join CarContent.dbo.SippCodes WITH (NOLOCK) ON cd1.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType    
  Group by  CD.carVendorKey, CD.carResponseKey ,CarContent.dbo.SippCodes.SippCodeCarType) as A  on vwCarResponse.carResponseKey = A.carResponseKey     
  where vwCarResponse.carRequestKey=@CarRequestKey    
  and vwCarResponse.PerDayRate<= @Price and PerDayminRate <> 0      
  order by minRate,pickupLocationName,CarCompanyName 
     
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
SELECT carresponsedetail.carResponseDetailKey,carresponsedetail.carVendorKey as carCompany ,vw_sabreCarResponse.CarCompanyname, MIN (carresponsedetail.minRate)as LowestPrice,    
carresponsedetail.carCategoryCode as carClassCat,CarContent .dbo.SippCodes.SippCodeDescription as carClassDes ,carresponsedetail.NoOfDays,    
ISNull(CarContent.dbo.SabreVehicles.ImageName,'no-image.jpg') as ImageName,CarContent.dbo.SabreVehicles.VehicleName,CarResponse.carLocationCode,vw_sabreCarResponse.pickupCity,    
vw_sabreCarResponse.pickupLocationAddress,vw_sabreCarResponse.dropoffLocationAddress,vw_sabreCarResponse.pickupDate,vw_sabreCarResponse.TotalChargeAmt,    
vw_sabreCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity as passenger, CarContent.dbo.SabreVehicles.baggage as baggage,MIN (carresponsedetail.minRateTax )as minRateTax,CarContent.dbo.SippCodes.SippCodeTransmission,           
   CarContent.dbo.SippCodes.SippCodeAC,CarContent.dbo.SabreVehicles.VehicleName as newVehicleName, 'no-image.jpg' as newImageName,
   vw_sabreCarResponse.pickupLatitude,vw_sabreCarResponse.pickupLongitude, carresponsedetail.contractCode, vw_sabreCarResponse.dropoffCity,
   carresponse.PickupLocInfoCode
 FROM vw_sabreCarResponse    
 inner join    
 carresponsedetail    
 on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey    
 inner join CarResponse on    
 CarResponse.carResponseKey=CarResponseDetail.carResponseKey    
 inner join CarContent .dbo.SippCodes   on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType    
 inner join CarContent.dbo.SabreVehicles on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode    
 and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode    
 and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode    
  where vw_sabreCarResponse.carRequestKey=@CarRequestKey    
  group by     
 carresponsedetail.carVendorKey,    
 vw_sabreCarResponse.CarCompanyname,carresponsedetail.carCategoryCode,    
 CarContent .dbo.SippCodes.SippCodeDescription,CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.VehicleName,    
  carresponsedetail.carResponseDetailKey,CarResponseDetail.minRate,carresponsedetail.NoOfDays,CarResponse.carLocationCode,vw_sabreCarResponse.pickupCity,vw_sabreCarResponse.pickupLocationAddress,    
  vw_sabreCarResponse.dropoffLocationAddress,vw_sabreCarResponse.pickupDate,vw_sabreCarResponse.TotalChargeAmt,vw_sabreCarResponse.carResponseKey,CarContent.dbo.SabreVehicles.PsgrCapacity, CarContent.dbo.SabreVehicles.baggage,   CarContent.dbo.SippCodes.SippCodeTransmission,           
   CarContent.dbo.SippCodes.SippCodeAC,
   vw_sabreCarResponse.pickupLatitude,vw_sabreCarResponse.pickupLongitude, carresponsedetail.contractCode, vw_sabreCarResponse.dropoffCity,
   carresponse.PickupLocInfoCode
 having MIN (carresponsedetail.minRate) <> 0      
 order by CarResponseDetail.minRate 
    
     
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
 carresponsedetail    
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
 print @sortField    
    
 SET @sqlString ='SELECT * FROM vw_sabreCarResponse where carRequestKey= '+CONVERT(varchar,@CarRequestKey)    
 +' and  minRate<='+ CONVERT(varchar,@Price)    
 + ' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'    
    
     
 exec(@sqlString)    
 print @sqlString    
     
 --SELECT * FROM vw_sabreCarResponse where carRequestKey=@CarRequestKey    
 --and  carVendorKey in ( select * from ufn_CSVToTable ( @carVendors )) and minRate<= @Price    
     
    
/*SELECT carVendorKey as carCompany ,CarCompanyname, MIN (minRate)as LowestPrice,carCategoryCode as carClassCat FROM vw_sabreCarResponse    
 where CarRequestKey=@CarRequestKey group by carVendorKey,CarCompanyname,carCategoryCode*/    
--select * from carresponsedetail    
 SELECT carresponsedetail.carResponseDetailKey,carresponsedetail.carVendorKey as carCompany ,vw_sabreCarResponse.CarCompanyname, MIN (carresponsedetail.minRate)as LowestPrice,    
carresponsedetail.carCategoryCode as carClassCat,CarContent .dbo.SippCodes.SippCodeDescription as carClassDes ,    
CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.VehicleName,passenger, vw_sabreCarResponse.baggage,CarContent.dbo.SippCodes.SippCodeTransmission,           
   CarContent.dbo.SippCodes.SippCodeAC, carresponsedetail.contractCode    
 FROM vw_sabreCarResponse    
 inner join    
 carresponsedetail    
 on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey    
 inner join CarContent.dbo.SippCodes   on carresponsedetail.carCategoryCode=CarContent .dbo.SippCodes.SippCodeCarType     
 inner join CarContent.dbo.SabreVehicles on CarContent.dbo.SabreVehicles.LocationAirportCode=vw_sabreCarResponse.carLocationCode    
   and CarContent.dbo.SabreVehicles.LocationAirportCode= CarContent.dbo.SabreVehicles.LocationCategoryCode    
 and CarContent.dbo.SabreVehicles.VendorCode=carresponsedetail.carVendorKey and CarContent.dbo.SabreVehicles.SippCode=carresponsedetail.carCategoryCode    
 where CarRequestKey=@CarRequestKey    
  group by     
 carresponsedetail.carVendorKey,    
 vw_sabreCarResponse.CarCompanyname,carresponsedetail.carCategoryCode,    
 CarContent .dbo.SippCodes.SippCodeDescription,CarContent.dbo.SabreVehicles.ImageName,CarContent.dbo.SabreVehicles.VehicleName,    
  carresponsedetail.carResponseDetailKey,CarResponseDetail.minRate,passenger, vw_sabreCarResponse.baggage,CarContent.dbo.SippCodes.SippCodeTransmission,           
   CarContent.dbo.SippCodes.SippCodeAC, carresponsedetail.contractCode    
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
 FROM vw_sabreCarResponse    
 inner join    
 carresponsedetail    
 on carresponsedetail.carresponsekey=vw_sabreCarResponse.carResponseKey    
     
 where CarRequestKey=@CarRequestKey    
 group by CarResponseDetail.carCategoryCode    
  order by carresponsedetail.carCategoryCode    
     
    
    
  select MIN(minrate) as FilterLowestPrice,carVendorKey as FilterCarCompany,CarCompanyname from vw_sabreCarResponse    
  where CarRequestKey= @CarRequestKey group by carVendorKey,CarCompanyname    
      
Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice FROM vw_sabreCarResponse where CarRequestKey=@CarRequestKey    
SELECT SippCodeClass as carClassCat , MIN (minRate)as LowestPrice FROM vw_sabreCarResponse where CarRequestKey=@CarRequestKey group by SippCodeClass    
    
     
 end
GO
