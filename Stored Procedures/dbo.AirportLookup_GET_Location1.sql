SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*Exec AirportLookup_GET_Location1 'LON','DFW', 3465*/        
CREATE PROCEDURE [dbo].[AirportLookup_GET_Location1]        
(        
 @ArrivalAirportCode VARCHAR(100),        
 @DepartAirportCode VARCHAR(100),    
 @CompanyKey int=0        
)        
AS        
BEGIN     
    
declare @companyHomeCountryCode varchar(5)    
select @companyHomeCountryCode=homecountryCode from Vault..Company where COMPANYKEY=@CompanyKey    
if(ISNULL(@companyHomeCountryCode,'')='')       
Begin    
set @companyHomeCountryCode='US'    
End    
        
 SELECT         
  AirportName,        
  CityName,        
  StateCode,        
  CountryCode,        
  AirportCode,        
  CityCode,        
  gmt_offset,      
  Latitude,      
  Longitude,    
  IsUSDomestic = case when @companyHomeCountryCode=CountryCode then CONVERT(bit,1) else CONVERT(bit,0) end ,    
  IsDomesticRegion = case WHEN EXISTS(SELECT 1 FROM   NeighboringCountries      
       WHERE HomeCountryCode = @companyHomeCountryCode and  (NeighborRegionCode = CountryCode OR NeighborRegionCode LIKE CountryCode + ',%'     
        OR NeighborRegionCode LIKE '%,' + CountryCode + ',%' OR NeighborRegionCode LIKE '%,' + CountryCode))     
      then CONVERT(bit,1) else CONVERT(bit,0) end    ,  
  case when CityCenterLatitude is null then 0 else CityCenterLatitude end as CityCenterLatitude,
  case when CityCenterLongitude is null then 0 else CityCenterLongitude end as CityCenterLongitude,
  AirportKey  
 FROM AirportLookup WITH (NOLOCK)        
 WHERE AirportCode = @ArrivalAirportCode        
 AND IsVisible = 1     
         
  SELECT         
  AirportName,        
  CityName,        
  StateCode,        
  CountryCode,        
  AirportCode,        
  CityCode,         
  gmt_offset,      
  Latitude,      
  Longitude,    
  IsUSDomestic  = case when @companyHomeCountryCode=CountryCode then CONVERT(bit,1) else CONVERT(bit,0) end,    
  IsDomesticRegion = case WHEN EXISTS(SELECT 1 FROM   NeighboringCountries      
       WHERE  HomeCountryCode = @companyHomeCountryCode and  (NeighborRegionCode = CountryCode OR NeighborRegionCode LIKE CountryCode + ',%'     
        OR NeighborRegionCode LIKE '%,' + CountryCode + ',%' OR NeighborRegionCode LIKE '%,' + CountryCode))     
      then CONVERT(bit,1) else CONVERT(bit,0) end ,  
  case when CityCenterLatitude is null then 0 else CityCenterLatitude end as CityCenterLatitude,
  case when CityCenterLongitude is null then 0 else CityCenterLongitude end as CityCenterLongitude,
  AirportKey        
 FROM AirportLookup WITH (NOLOCK)        
 WHERE AirportCode = @DepartAirportCode        
 AND IsVisible = 1     
         
END     
GO
