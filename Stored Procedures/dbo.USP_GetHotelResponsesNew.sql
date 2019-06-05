SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/***********************************                         
  updatedBy - Manoj Kumar Naik                           
  updated on - 10/08/2017                        
  summary - removed view, removed unused column regionName and regionId , implemented culture for multi-language project.                      
  updatedBy - Chetan Dalvi                           
  updated on - 20-Nov-2017      
  summary - Added isNull condition on select columns      
***********************************/                      
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesNew]            
(            
 @hotelRequestKey INT,            
 @hotelResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000',            
 @hotelID   INT = 0  ,          
 @culture varchar(10) = 'en-US'          
)            
AS            
BEGIN            
          
IF @hotelID <> 0          
BEGIN          
--print'1'          
    SELECT     CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS hotelResponseKey, 0 AS supplierHotelKey, 0 AS hotelRequestKey, '' AS supplierId, HS.LowRate AS minRate, ISNULL(HS.HotelName, 'tourico')           
     AS HotelName, ISNULL(HS.Rating, 4) AS Rating, ISNULL(HS.RatingType,'') as RatingType, ISNULL(HS.ChainCode,'') as ChainCode, HS.HotelId, HS.Latitude, HS.Longitude, HS.Address1, HS.CityName, HS.StateCode, HS.CountryCode, ISNULL(HS.ZipCode,'') as ZipCode ,           
     ISNULL(HS.PhoneNumber,'') as PhoneNumber, ISNULL(HS.FaxNumber,'') as FaxNumber , ISNULL(HS.CityCode,'') as CityCode, ISNULL(AH.Distance, 3) AS Distance, '1900-01-01' AS checkInDate, '1900-01-01' AS checkOutDate,           
     (CASE WHEN @culture = 'en-US' THEN REPLACE(HD.HotelDescription, '', '')           
     WHEN @culture = 'fr-CA' THEN REPLACE(HD.HotelDescriptions_fr_CA, '', '')           
     ELSE REPLACE(HD.HotelDescription, '', '') END)          
     AS HotelDescription, ISNULL(HC.ChainName,'') as ChainName, 0 AS minRateTax, HotelContent.dbo.HotelImages_Exterior.SupplierImageURL AS ImageURL, 0 AS preferenceOrder, '' AS corporateCode, '' AS hotelPolicy,           
     '' AS checkInInstruction, HS.reviewRating AS tripAdvisorRating, '' AS checkInTime, '' AS checkOutTime,           
     HS.richMediaUrl, 0 as RegionId, '' AS RegionName,0 as hasGovRate            
    FROM         HotelContent.dbo.Hotels AS HS LEFT OUTER JOIN          
     HotelContent.dbo.HotelDescriptions AS HD ON HS.HotelId = HD.HotelId LEFT OUTER JOIN          
     HotelContent.dbo.HotelImages_Exterior ON HotelContent.dbo.HotelImages_Exterior.HotelId = HS.HotelId AND HotelContent.dbo.HotelImages_Exterior.ImageType = 'Exterior' LEFT OUTER JOIN          
     HotelContent.dbo.AirportHotels AS AH ON HS.HotelId = AH.HotelId AND HS.CityCode = AH.AirportCode LEFT OUTER JOIN          
     HotelContent.dbo.HotelChains AS HC ON HS.ChainCode = HC.ChainCode            
    WHERE HS.HotelId = @hotelID                 
                        
END          
ELSE IF @hotelResponseKey <> '00000000-0000-0000-0000-000000000000'          
BEGIN          
--print'2'        
      
DECLARE @corporateCode varchar(100), @companyContract varchar(100), @hotelKey int, @hotelRequestId int, @hasGovRate bit      
      
SELECT  @hotelKey = hotelId , @hotelRequestId = hotelRequestKey  FROM [Trip].[dbo].[HotelResponse] WHERE hotelResponseKey = @hotelResponseKey           
      
SELECT top 1 @corporateCode = corporateCode from [Trip].[dbo].[HotelResponse] where  supplierId='Sabre' and( corporateCode is not null AND corporateCode !='')  and hotelId = @hotelKey  and hotelRequestKey = @hotelRequestId      

SELECT top 1 @companyContract = CompanyContractApplied FROM [Trip].[dbo].[HotelResponse] where  supplierId='Sabre' and( CompanyContractApplied is not null AND CompanyContractApplied !='')  and hotelId = @hotelKey  and hotelRequestKey = @hotelRequestId           
 -- group by minRate,corporateCode  order by  Min(minRate)      
      
SELECT top 1 @hasGovRate = hasGovRate from [Trip].[dbo].[HotelResponse] where   hasGovRate=1 and hotelId = @hotelKey  and hotelRequestKey = @hotelRequestId     
        
  SELECT     @hotelResponseKey AS hotelResponseKey, HR.supplierHotelKey AS supplierHotelKey, hotelRequestKey AS hotelRequestKey, Hr.supplierId AS supplierId, HS.LowRate AS minRate, ISNULL(HS.HotelName, 'tourico')           
 AS HotelName, ISNULL(HS.Rating, 4) AS Rating, ISNULL(HS.RatingType,'') as RatingType, ISNULL(HS.ChainCode,'') as ChainCode, HS.HotelId, HS.Latitude, HS.Longitude, HS.Address1, HS.CityName, HS.StateCode, HS.CountryCode, ISNULL(HS.ZipCode,'') as ZipCode,  
         
                      ISNULL(HS.PhoneNumber,'') as PhoneNumber, ISNULL(HS.FaxNumber,'') as FaxNumber, ISNULL(HS.CityCode,'') as CityCode , ISNULL(AH.Distance, 3) AS Distance, '1900-01-01' AS checkInDate, '1900-01-01' AS checkOutDate,           
                      (CASE WHEN @culture = 'en-US' THEN REPLACE(HD.HotelDescription, '', '')           
                           WHEN @culture = 'fr-CA' THEN REPLACE(HD.HotelDescriptions_fr_CA, '', '')           
                           ELSE REPLACE(HD.HotelDescription, '', '') END)          
                            AS HotelDescription, ISNULL(HC.ChainName,'') as ChainName, 0 AS minRateTax, HotelContent.dbo.HotelImages_Exterior.SupplierImageURL AS ImageURL, 0 AS preferenceOrder, @corporateCode AS corporateCode, '' AS hotelPolicy,          
 
                      '' AS checkInInstruction, HS.reviewRating AS tripAdvisorRating, '' AS checkInTime, '' AS checkOutTime,           
                      HS.richMediaUrl, 0 as RegionId, '' AS RegionName, @hasGovRate AS hasGovRate,@companyContract as CompanyContractApplied         
FROM HotelContent.dbo.Hotels AS HS LEFT OUTER JOIN          
                      HotelContent.dbo.HotelDescriptions AS HD ON HS.HotelId = HD.HotelId LEFT OUTER JOIN          
                      HotelContent.dbo.HotelImages_Exterior ON HotelContent.dbo.HotelImages_Exterior.HotelId = HS.HotelId AND HotelContent.dbo.HotelImages_Exterior.ImageType = 'Exterior' LEFT OUTER JOIN          
                      HotelContent.dbo.AirportHotels AS AH ON HS.HotelId = AH.HotelId AND HS.CityCode = AH.AirportCode LEFT OUTER JOIN          
                      HotelContent.dbo.HotelChains AS HC ON HS.ChainCode = HC.ChainCode            
                      INNER JOIN Trip..HotelResponse HR ON HS.HotelId = HR.hotelId          
                 
              WHERE HR.hotelResponseKey = @hotelResponseKey           
END          
ELSE           
BEGIN          
--print'3'          
  SELECT     CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS hotelResponseKey, 0 AS supplierHotelKey, @hotelRequestKey AS hotelRequestKey, HR.supplierId AS supplierId, HS.LowRate AS minRate, ISNULL(HS.HotelName, 'tourico')           
                      AS HotelName, ISNULL(HS.Rating, 4) AS Rating, ISNULL(HS.RatingType,'') as RatingType, ISNULL(HS.ChainCode,'') as ChainCode, HS.HotelId, HS.Latitude, HS.Longitude, HS.Address1, HS.CityName, HS.StateCode, HS.CountryCode, ISNULL(HS.ZipCode,'') as ZipCode,           
                      ISNULL(HS.PhoneNumber,'') as PhoneNumber, ISNULL(HS.FaxNumber,'') as FaxNumber, ISNULL(HS.CityCode,'') as CityCode, ISNULL(AH.Distance, 3) AS Distance, '1900-01-01' AS checkInDate, '1900-01-01' AS checkOutDate,           
                      (CASE WHEN @culture = 'en-US' THEN REPLACE(HD.HotelDescription, '', '')           
                           WHEN @culture = 'fr-CA' THEN REPLACE(HD.HotelDescriptions_fr_CA, '', '')           
                           ELSE REPLACE(HD.HotelDescription, '', '') END)          
                            AS HotelDescription, ISNULL(HC.ChainName,'') as ChainName , 0 AS minRateTax, HotelContent.dbo.HotelImages_Exterior.SupplierImageURL AS ImageURL, 0 AS preferenceOrder, HR.corporateCode AS corporateCode, '' AS hotelPolicy,       
  
    
                      '' AS checkInInstruction, HS.reviewRating AS tripAdvisorRating, '' AS checkInTime, '' AS checkOutTime,           
                      HS.richMediaUrl, 0 as RegionId, '' AS RegionName,hasGovRate,@companyContract as CompanyContractApplied                   
FROM         HotelContent.dbo.Hotels AS HS LEFT OUTER JOIN          
                      HotelContent.dbo.HotelDescriptions AS HD ON HS.HotelId = HD.HotelId LEFT OUTER JOIN          
                      HotelContent.dbo.HotelImages_Exterior ON HotelContent.dbo.HotelImages_Exterior.HotelId = HS.HotelId AND HotelContent.dbo.HotelImages_Exterior.ImageType = 'Exterior' LEFT OUTER JOIN       
                      HotelContent.dbo.AirportHotels AS AH ON HS.HotelId = AH.HotelId AND HS.CityCode = AH.AirportCode LEFT OUTER JOIN          
                      HotelContent.dbo.HotelChains AS HC ON HS.ChainCode = HC.ChainCode            
                      INNER JOIN Trip..HotelResponse HR ON HS.HotelId = HR.hotelId          
                 
              WHERE HR.hotelRequestKey = @hotelRequestKey           
END          
               
               
END 
GO
