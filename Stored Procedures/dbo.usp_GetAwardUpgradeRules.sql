SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create   PROC [dbo].[usp_GetAwardUpgradeRules]  
(  
 @FromAirportCode VARCHAR(3),  
 @ToAirportCode VARCHAR(3),   
 @SiteKey INT  
 
)  
AS  
BEGIN   
  
 SET NOCOUNT ON;  
  
 DECLARE @FromCountryCode VARCHAR(2),  
   @ToCountryCode VARCHAR(2),  
   @FromStateCode VARCHAR(2),  
   @ToStateCode VARCHAR(2),  
   @FromCount INT,  
   @ToCount INT,  
   @IsAvailable BIT  
  
 DECLARE @FromRegionIds TABLE  
 (  
  FromRegionId INT    
 )  
  
 DECLARE @ToRegionIds TABLE  
 (  
  ToRegionId INT    
 )  
  
 SET @IsAvailable = 1  
  
 SELECT @FromCountryCode = CountryCode,  
     @FromStateCode = StateCode    
 FROM AirportLookup WITH(NOLOCK)  
 WHERE AirportCode = @FromAirportCode  
  
 SELECT   
   @ToCountryCode = CountryCode,  
   @ToStateCode = StateCode    
 FROM AirportLookup WITH(NOLOCK)  
 WHERE AirportCode = @ToAirportCode  
  
 IF (@FromCountryCode = 'IN' OR @ToCountryCode = 'IN')  
 BEGIN     
  SET @IsAvailable = 0  
 END   
  
  
 -- INDIA is Excluded
 IF (@IsAvailable = 1)  
 BEGIN    
  --IF (@FromCount = 0 OR @ToCount = 0)  
  BEGIN   
   INSERT INTO @FromRegionIds  
   SELECT RegionId FROM RegionCountryMapping WITH(NOLOCK)  
   WHERE CountryCode = @FromCountryCode  
   AND ISNULL(StateCode,'') = CASE WHEN LTRIM(RTRIM(LOWER(@FromStateCode))) = 'hi' THEN 'HI' ELSE '' END  
  
   INSERT INTO @ToRegionIds  
   SELECT RegionId FROM RegionCountryMapping WITH(NOLOCK)    
   WHERE CountryCode = @ToCountryCode  
   AND ISNULL(StateCode,'') = CASE WHEN LTRIM(RTRIM(LOWER(@ToStateCode))) = 'hi' THEN 'HI' ELSE '' END  
  END  
 END  
 --SELECT @FromCountryCode, @ToCountryCode  
  
 --SELECT * FROM @FromRegionIds  
 --SELECT * FROM @ToRegionIds  
  
 SELECT   
  FromRegionId,   
  ToRegionId,   
  --RegionName,   
  RuleData   
 FROM AwardUpgradeRules WITH(NOLOCK)  
  /*  
 INNER JOIN RegionLookup ON   
  (BXRules.FromRegionId = RegionLookup.Id   
   OR  
  BXRules.ToRegionId = RegionLookup.Id )  
 */  
 WHERE FromRegionId IN (SELECT DISTINCT FromRegionId FROM @FromRegionIds)  
 AND   
  ToRegionId IN (SELECT DISTINCT  ToRegionId FROM @ToRegionIds)  
 AND  
  siteKey = @SiteKey  
   
 --SELECT * FROM BXRules  
  
END
GO
