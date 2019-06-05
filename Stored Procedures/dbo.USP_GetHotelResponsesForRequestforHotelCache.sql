SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec USP_GetHotelResponsesForRequestforHotelCache @hotelRequestKey =151330,@hotelRatings=N'3,4,5',@pageNo=1,@pageSize=10,@cityCode=N'MIA',@hotelGroupId=0,@isMatrixRequired=0,@isNearByRegionRequired=1,@isLimitedChainList=0
 
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesForRequestforHotelCache]      
(       
--declare       
 @hotelRequestKey  INT,      
 @sortField VARCHAR(50)='',                            
 @hotelRatings VARCHAR(200)='',                            
 @mindistance FLOAT = 0 ,                            
 @maxdistance FLOAT= 1000,                            
 @minPrice FLOAT=0.0 ,                            
 @maxPrice FLOAT=999999999.99,                            
 @hotelAmenities VARCHAR(200)='',                             
 @chainCode VARCHAR(10) = 'ALL' ,                            
 @pageNo INT ,                            
 @pageSize INT ,                            
 @hotelName VARCHAR(100) = '',           
 @cityCode VARCHAR(50) = '',        
 @hotelGroupId INT = 0,             
 @isMatrixRequired bit = 0,         
 @isNearByRegionRequired bit = 0,       
 @isLimitedChainList bit = 0,      
 @isLandmarkRequired bit = 1      
)    
AS                          
BEGIN         
 SET NOCOUNT ON;    

 IF ( @mindistance > 0 )                             
 BEGIN                            
  SET @mindistance = @mindistance + 0.01                            
 END    
    
--SELECT GetDate() AS [1]    
    
 --Temporary Table For HotelResponse    
 CREATE TABLE #TmpHotelResponse    
 (    
  [hotelResponseKey] [uniqueidentifier] NOT NULL,    
  [hotelRequestKey] [int] NOT NULL,    
  [supplierHotelKey] [varchar](50) NULL,    
  [supplierId] [varchar](50) NULL,    
  [minRate] [float] NOT NULL,    
  [preferenceOrder] [int] NULL,    
  [corporateCode] [varchar](30) NULL,      
  [cityCode] [varchar](10) NULL,    
  [hotelId] [int] NULL,      
  [isPromoTrue] [bit] NULL,    
  [promoDescription] [varchar](300) NULL,    
  [averageBaseRate] [float] NULL,    
  [promoId] [varchar](20) NULL,    
  [eanBarRate] [float] NULL,    
  [touricoCalculatedBarRate] [float] NULL,    
  [touricoNetRate] [float] NULL,    
  [touricoCostBasisRate] [float] NULL,    
  [marketPlaceVariableId] [int] NULL,    
  [minRateTax] [float] NOT NULL,    
  [IsNonRefundable] [bit],    
  [proximityDistance][FLOAT],  
  [proximityUnit] [varchar](50) NULL     
 )    
     
 --This table holds the final data to be displayed in hotel list page    
 CREATE TABLE #FinalHotelResponse    
 (     
  hotelResponseKey UNIQUEIDENTIFIER    
  ,supplierHotelKey VARCHAR(50)    
  ,minRate FLOAT    
  ,hotelId INT    
  ,hotelRequestKey INT    
  ,SupplierId VARCHAR(30)    
  ,isPromoTrue BIT    
  ,promoDescription VARCHAR(300)    
  ,averageBaseRate FLOAT    
  ,eanBarRate FLOAT    
  ,touricoCalculatedBarRate FLOAT    
  ,touricoNetRate FLOAT    
  ,preferenceOrder int    
  ,corporateCode varchar(30)    
  ,marketPlaceVariableId INT    
  ,promoId varchar(20) NULL    
  ,touricoCostBasisRate float NULL    
  ,minRateTax FLOAT    
  ,isNonRefundable bit   
  ,proximityDistance FLOAT  
  ,proximityUnit varchar(50)    
 )    
               
 DECLARE @hotelResponseResult TABLE                             
 (                            
  rowNum INT IDENTITY(1,1) NOT NULL,                             
  hotelResponseKey uniqueidentIFier,                            
  supplierHotelKey VARCHAR(50),                            
  hotelRequestKey INT,                            
  supplierId VARCHAR(50),                            
  minRate FLOAT,                            
  HotelName VARCHAR(128),                            
  Rating FLOAT,                            
  RatingType VARCHAR(50),                            
  ChainCode VARCHAR(50),                            
  HotelId INT,                            
  Latitude FLOAT,                            
  Longitude FLOAT,                            
  Address1 VARCHAR(256),                            
  CityName VARCHAR(64),                            
  StateCode VARCHAR(2),                            
  CountryCode VARCHAR(2),                            
  ZipCode VARCHAR(16),                            
  PhoneNumber VARCHAR(32),                            
  FaxNumber VARCHAR(32),                            
  CityCode VARCHAR(3),           
  CountryName VARCHAR(50),                       
  distance FLOAT,                           
  checkInDate DATETIME,                            
  checkOutDate DATETIME,                            
  HotelDescription VARCHAR(8000),                            
  ChainName VARCHAR(128),                          
  minRateTax FLOAT,                            
  ImageURL VARCHAR(1000),                            
  hotelPolicy varchar(2000),                       
  checkInInstruction varchar(2000),                
  tripAdvisorRating varchar(10),              
  checkInTime varchar(50),              
  checkOutTime varchar(50) ,            
  richMediaUrl  varchar(150),        
  hotelSequence int,        
  offerName varchar(200),        
  primaryOffertext varchar(600),        
  secondaryOffertext varchar(600),        
  linktoPage varchar(200),        
  inStripOfferImage varchar(500),        
  customHotelImageUrl varchar(500),        
  cmsHotelName varchar(128),          
  realRating FLOAT,      
  rowNumber int ,    
  IsPromo bit,    
  PromoDescription varchar(300),    
  AverageBaseCost float,    
  preferenceOrder int,    
  corporateCode varchar(30),        
  averageBaseRate float NULL,    
  promoId varchar(20) NULL,    
  eanBarRate float NULL,    
  touricoCalculatedBarRate float NULL,    
  touricoNetRate float NULL,    
  touricoCostBasisRate float NULL,    
  marketPlaceVariableId int NULL,    
  isNonRefundable bit,  
  proximityDistance float NULL,    
  proximityUnit varchar(50) NULL  ,  
  RegionId BIGint,  
  RegionName varchar(100) null  
 )                             
     
 /*Insert all the hotels from hotels response table based on hotel request key     
 for which we have hotel id in our hotel content database*/    
 INSERT INTO #TmpHotelResponse    
 (    
  hotelResponseKey    
  ,hotelRequestKey    
  ,supplierHotelKey    
  ,supplierId    
  ,minRate      
  ,cityCode    
  ,hotelId      
  ,isPromoTrue    
  ,promoDescription    
  ,averageBaseRate    
  ,promoId    
  ,eanBarRate    
  ,touricoCalculatedBarRate    
  ,touricoNetRate    
  ,touricoCostBasisRate    
  ,corporateCode    
  ,preferenceOrder    
  ,marketPlaceVariableId     
  ,minRateTax    
  ,isNonRefundable   
  ,proximityDistance  
  ,proximityUnit  
 )    
 SELECT    
  hotelResponseKey    
  ,hotelRequestKey    
  ,supplierHotelKey    
  ,supplierId    
  ,minRate      
  ,cityCode    
  ,hotelId      
  ,isPromoTrue    
  ,promoDescription    
  ,averageBaseRate    
  ,promoId    
  ,eanBarRate    
  ,touricoCalculatedBarRate    
  ,touricoNetRate    
  ,touricoCostBasisRate    
  ,corporateCode    
  ,preferenceOrder    
  ,marketPlaceVariableId    
  ,minRateTax      
  ,isNonRefundable    
  ,proximityDistance  
  ,proximityUnit  
 FROM HotelResponse    
 WHERE hotelRequestKey = @hotelRequestKey    
 AND hotelId IS NOT NULL    
     
 --First insert all the data of hotelsCOm in Final table     
 INSERT INTO #FinalHotelResponse    
 (    
  minRate    
  ,hotelId    
  ,hotelRequestKey    
  ,SupplierId    
  ,eanBarRate    
  ,hotelResponseKey    
  ,supplierHotelKey    
  ,isPromoTrue    
  ,promoDescription    
  ,averageBaseRate    
  ,corporateCode    
  ,preferenceOrder    
  ,marketPlaceVariableId    
  ,promoId    
  ,minRateTax      
  ,isNonRefundable    
  ,proximityDistance  
  ,proximityUnit    
 )    
 SELECT     
  minRate    
  ,hotelId    
  ,hotelRequestKey    
  ,supplierId    
  ,eanBarRate    
  ,hotelResponseKey    
  ,supplierHotelKey    
  ,isPromoTrue    
  ,promoDescription    
  ,averageBaseRate    
  ,corporateCode    
  ,preferenceOrder    
  ,marketPlaceVariableId    
  ,promoId      
  ,minRateTax    
  ,isNonRefundable    
  ,proximityDistance  
  ,proximityUnit    
 FROM #TmpHotelResponse    
 WHERE supplierId = 'HotelsCom'    
     
 /*Update touricoCalculatedBarRate, touricoNetRate & touricoCostBasisRate for those    
 hotels of HotelsCom which has its equivalent tourico rate    
 Update touricoCalculatedBarRate with HotelsCom Minrate as the display price should    
 be same across all GDS*/    
 UPDATE FHR    
 SET FHR.touricoCalculatedBarRate = FHR.minRate    
 ,FHR.touricoNetRate = THR.touricoNetRate    
 ,FHR.touricoCostBasisRate = THR.touricoCostBasisRate    
 FROM #FinalHotelResponse FHR    
 INNER JOIN #TmpHotelResponse THR    
 ON THR.hotelId = FHR.hotelId    
 AND THR.supplierId = 'Tourico'    
     
 /*Insert tourico only hotels in final table. Insert touricoCalculatedBarRate in minRate column*/    
 INSERT INTO #FinalHotelResponse    
 (    
  minRate      
  ,hotelRequestKey    
  ,SupplierId    
  ,hotelId    
  ,touricoCalculatedBarRate    
  ,touricoNetRate    
  ,hotelResponseKey    
  ,supplierHotelKey    
  ,isPromoTrue    
  ,promoDescription    
  ,averageBaseRate    
  ,corporateCode    
  ,preferenceOrder    
  ,marketPlaceVariableId      
  ,touricoCostBasisRate    
  ,minRateTax    
  ,isNonRefundable    
  ,proximityDistance  
  ,proximityUnit    
 )    
 SELECT    
  touricoCalculatedBarRate    
  ,hotelRequestKey    
  ,supplierId    
  ,hotelId    
  ,touricoCalculatedBarRate    
  ,touricoNetRate    
  ,hotelResponseKey    
  ,supplierHotelKey    
  ,isPromoTrue    
  ,promoDescription    
  ,averageBaseRate    
  ,corporateCode    
  ,preferenceOrder    
  ,marketPlaceVariableId      
  ,touricoCostBasisRate    
  ,minRateTax    
  ,isNonRefundable    
  ,proximityDistance  
  ,proximityUnit    
 FROM #TmpHotelResponse    
 WHERE hotelId NOT IN    
 (      
  SELECT hotelId    
  FROM #FinalHotelResponse    
 )    
 AND supplierId = 'Tourico'    
     
 /*Insert Sabre only hotels*/    
 INSERT INTO #FinalHotelResponse    
 (    
  minRate      
  ,hotelRequestKey    
  ,SupplierId    
  ,hotelId      
  ,hotelResponseKey    
  ,supplierHotelKey    
  ,corporateCode    
  ,preferenceOrder    
  ,minRateTax    
  ,isNonRefundable    
  ,proximityDistance  
  ,proximityUnit    
 )    
 SELECT    
  minRate    
  ,hotelRequestKey    
  ,supplierId    
  ,hotelId    
  ,hotelResponseKey    
  ,supplierHotelKey    
  ,corporateCode    
  ,preferenceOrder    
  ,minRateTax    
  ,isNonRefundable    
  ,proximityDistance  
  ,proximityUnit    
 FROM #TmpHotelResponse    
 WHERE hotelId NOT IN    
 (      
  SELECT hotelId    
  FROM #FinalHotelResponse    
 )    
 AND supplierId = 'Sabre'    
   
  
      
IF(@isLimitedChainList = 0)    
BEGIN    
    
    
   INSERT INTO @hotelResponseResult    
   (    
  hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType    
  ,corporateCode, preferenceOrder, ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode    
  ,ZipCode,PhoneNumber,FaxNumber, CityCode,CountryName,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,         
        hotelPolicy, checkInInstruction, tripAdvisorRating,checkInTime,checkOutTime,        
        richMediaUrl,hotelSequence, offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage    
        ,customHotelImageUrl,cmsHotelName, realRating, rowNumber , IsPromo , PromoDescription , AverageBaseCost    
        ,promoId, eanBarRate, touricoCalculatedBarRate, touricoNetRate, touricoCostBasisRate, marketPlaceVariableId, isNonRefundable,proximityDistance,proximityUnit ,RegionId,RegionName    
 )    
   (      
  SELECT FHR.hotelResponseKey,FHR.supplierHotelKey,FHR.hotelRequestKey,FHR.SupplierId,FHR.minRate,HT.HotelName,HT.Rating,HT.RatingType, FHR.corporateCode, FHR.preferenceOrder,    
   HT.ChainCode,FHR.HotelId,HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode,     
   '',    
   0,    
   null,null,    
   '',    
   HC.ChainName,FHR.minRateTax,    
   HI.SupplierImageURL,'','',HT.reviewRating as tripAdvisorRating ,'','',''    
   ,CASE WHEN (ISNULL(HGM.HotelSequence,0) = 0) THEN 2 WHEN (ISNULL(HGM.HotelSequence,0) > 10) THEN 1 ELSE HGM.HotelSequence END,     
   offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage, CHI.ImageURL AS customHotelImageUrl,    
   CH.H1Title As cmsHotelName, HT.Rating,    
   ROW_NUMBER() OVER(PARTITION BY FHR.HotelId,FHR.hotelRequestKey,FHR.minRate ORDER BY FHR.SupplierId ASC) AS rowNumber,    
   isnull(FHR.IsPromoTrue,0) as IsPromoTrue,Isnull(FHR.PromoDescription,'') as PromoDescription ,Isnull(FHR.AverageBaseRate,0) as   AverageBaseRate    
   ,FHR.promoId, FHR.eanBarRate, FHR.touricoCalculatedBarRate, FHR.touricoNetRate, FHR.touricoCostBasisRate, FHR.marketPlaceVariableId, FHR.isNonRefundable, FHR.proximityDistance, FHR.proximityUnit,PR.RegionId,PR.RegionName    
  FROM HotelContent.dbo.Hotels AS HT WITH(NOLOCK)     
  LEFT OUTER JOIN HotelContent.dbo.HotelImages_Exterior AS HI WITH(NOLOCK) ON HI.HotelId = HT.HotelId AND  HI.ImageType = 'Exterior'          
  INNER JOIN #FinalHotelResponse FHR ON FHR.HotelId = HT.HotelId --AND FHR.HotelRequestKey =@hotelRequestKey      
  LEFT OUTER JOIN [CMS].[dbo].[CustomHotelGroupMapping] HGM WITH(NOLOCK) ON HGM.HotelId = HT.HotelId AND HGM.HotelGroupId = @hotelGroupId   
  LEFT OUTER JOIN HotelContent.dbo.HotelChains AS HC WITH(NOLOCK) ON HC.ChainCode = HT.ChainCode             
  LEFT OUTER JOIN [CMS].[dbo].[CustomHotelImages] AS CHI WITH(NOLOCK) ON CHI.HotelId = FHR.HotelId AND CHI.OrderId = 1 AND HGM.HotelGroupId =1  
  LEFT OUTER JOIN [CMS].[dbo].[CustomHotels] AS CH WITH(NOLOCK) ON CH.HotelId = FHR.HotelId         
  LEFT OUTER JOIN         
  (        
   SELECT  ISNULL(OfferName, '') as OfferName, ISNULL(PrimaryOffertext, '') as PrimaryOffertext,         
   ISNULL(SecondaryOffertext, '') as SecondaryOffertext, ISNULL(LinktoPage, '') as LinktoPage,        
   ISNULL(InStripOfferImage, '') as  InStripOfferImage, HotelVendorMatch, HotelChainMatch, OfferDisplayStartDate        
   , OfferDisplayEndDate, MerchandiseType        
   FROM CMS..Merchandise WITH(NOLOCK) WHERE MerchandiseType = 'InStripMessageHotel'     
   AND GETDATE() BETWEEN ISNULL(OfferDisplayStartDate,GETDATE())     
   AND ISNULL(OfferDisplayEndDate, GETDATE())      
  ) mer ON FHR.HotelId = mer.HotelVendorMatch OR (mer.HotelChainMatch <> '0' AND HT.ChainCode = ISNULL(HT.ChainCode,mer.HotelChainMatch))     
  LEFT OUTER JOIN HotelContent..RegionHotelIDMapping RHM on RHM.HotelId = HT.HotelId  
  LEFT OUTER JOIN HotelContent..ParentRegionList PR on PR.RegionID = RHM.RegionId  
  --INNER JOIN #TmpHotelResponse AS HRD WITH(NOLOCK) ON HRD.hotelRequestKey = FHR.hotelRequestKey AND  HRD.HotelId = FHR.HotelId AND HRD.minRate = FHR.minRate       
 )        
    
     
END    
ELSE    
BEGIN    
    
   INSERT INTO @hotelResponseResult    
   (    
  hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType    
  ,corporateCode, preferenceOrder, ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode    
  ,ZipCode,PhoneNumber,FaxNumber, CityCode,CountryName,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,         
        hotelPolicy, checkInInstruction, tripAdvisorRating,checkInTime,checkOutTime,        
        richMediaUrl,hotelSequence, offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage    
        ,customHotelImageUrl,cmsHotelName, realRating, rowNumber , IsPromo , PromoDescription , AverageBaseCost    
        ,promoId, eanBarRate, touricoCalculatedBarRate, touricoNetRate, touricoCostBasisRate, marketPlaceVariableId, isNonRefundable, proximityDistance, proximityUnit,RegionId,RegionName    
 )    
   (      
  SELECT FHR.hotelResponseKey,FHR.supplierHotelKey,FHR.hotelRequestKey,FHR.SupplierId,FHR.minRate,HT.HotelName,HT.Rating,HT.RatingType, FHR.corporateCode, FHR.preferenceOrder,    
   HT.ChainCode,FHR.HotelId,HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode,     
   '',    
   ISNULL(AH.Distance,0) as Distance,    
   null,null,    
   '',    
   HC.ChainName,FHR.minRateTax,    
   HI.SupplierImageURL,'','',HT.reviewRating as tripAdvisorRating ,'','',''    
   ,CASE WHEN (ISNULL(HGM.HotelSequence,0) = 0) THEN 2 WHEN (ISNULL(HGM.HotelSequence,0) > 10) THEN 1 ELSE HGM.HotelSequence END,     
   offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage, CHI.ImageURL AS customHotelImageUrl,    
   CH.H1Title As cmsHotelName, HT.Rating,    
   ROW_NUMBER() OVER(PARTITION BY FHR.HotelId,FHR.hotelRequestKey,FHR.minRate ORDER BY FHR.SupplierId ASC) AS rowNumber,    
   isnull(FHR.IsPromoTrue,0) as IsPromoTrue,Isnull(FHR.PromoDescription,'') as PromoDescription ,Isnull(FHR.AverageBaseRate,0) as   AverageBaseRate    
   ,FHR.promoId, FHR.eanBarRate, FHR.touricoCalculatedBarRate, FHR.touricoNetRate, FHR.touricoCostBasisRate, FHR.marketPlaceVariableId, FHR.isNonRefundable, FHR.proximityDistance, FHR.proximityUnit,PR.RegionId,PR.RegionName    
  FROM HotelContent.dbo.Hotels AS HT WITH(NOLOCK)     
  LEFT OUTER JOIN HotelContent.dbo.HotelImages_Exterior AS HI WITH(NOLOCK) ON HI.HotelId = HT.HotelId AND  HI.ImageType = 'Exterior'          
  INNER JOIN #FinalHotelResponse FHR ON FHR.HotelId = HT.HotelId --AND FHR.HotelRequestKey =@hotelRequestKey      
  Left outer join HotelContent.dbo.AirportHotels AS AH WITH(NOLOCK) ON AH.HotelId = HT.HotelId AND AH.AirportCode = HT.CityCode     
  LEFT OUTER JOIN [CMS].[dbo].[CustomHotelGroupMapping] HGM WITH(NOLOCK) ON HGM.HotelId = HT.HotelId AND HGM.HotelGroupId = @hotelGroupId    
  LEFT OUTER JOIN HotelContent.dbo.HotelChains AS HC WITH(NOLOCK) ON HC.ChainCode = HT.ChainCode             
  LEFT OUTER JOIN [CMS].[dbo].[CustomHotelImages] AS CHI WITH(NOLOCK) ON CHI.HotelId = FHR.HotelId AND CHI.OrderId = 1 AND HGM.HotelGroupId =1       
  LEFT OUTER JOIN [CMS].[dbo].[CustomHotels] AS CH WITH(NOLOCK) ON CH.HotelId = FHR.HotelId         
  LEFT OUTER JOIN         
  (        
   SELECT  ISNULL(OfferName, '') as OfferName, ISNULL(PrimaryOffertext, '') as PrimaryOffertext,         
   ISNULL(SecondaryOffertext, '') as SecondaryOffertext, ISNULL(LinktoPage, '') as LinktoPage,        
   ISNULL(InStripOfferImage, '') as  InStripOfferImage, HotelVendorMatch, HotelChainMatch, OfferDisplayStartDate        
   , OfferDisplayEndDate, MerchandiseType        
   FROM CMS..Merchandise WITH(NOLOCK) WHERE MerchandiseType = 'InStripMessageHotel'     
   AND GETDATE() BETWEEN ISNULL(OfferDisplayStartDate,GETDATE())     
   AND ISNULL(OfferDisplayEndDate, GETDATE())      
  ) mer ON FHR.HotelId = mer.HotelVendorMatch OR (mer.HotelChainMatch <> '0' AND HT.ChainCode = ISNULL(HT.ChainCode,mer.HotelChainMatch))        
  LEFT OUTER JOIN HotelContent..RegionHotelIDMapping RHM on RHM.HotelId = HT.HotelId  
  LEFT OUTER JOIN HotelContent..ParentRegionList PR on PR.RegionID = RHM.RegionId  
  --INNER JOIN #TmpHotelResponse AS HRD WITH(NOLOCK) ON HRD.hotelRequestKey = FHR.hotelRequestKey AND  HRD.HotelId = FHR.HotelId AND HRD.minRate = FHR.minRate       
 )        
   
END    
 -- Deleting multiple records of same hotelId with same hotel rates.      
DELETE FROM @hotelResponseResult WHERE rowNumber > 1      
    
--Delete non contracted fare from sabre when contracted fare is available  
DELETE FROM @hotelResponseResult   
WHERE SupplierHotelKey in(SELECT B.SupplierHotelKey    
    FROM @hotelResponseResult B   
    WHERE B.SupplierHotelKey = SupplierHotelKey AND B.SupplierId = 'Sabre' AND (B.CorporateCode IS NOT NULL AND LTRIM(RTRIM(B.CorporateCode)) <> ''))  
AND (CorporateCode IS NULL OR LTRIM(RTRIM(corporateCode)) = '') AND supplierId = 'Sabre'  
       
       
--print 'er'    
 IF(@hotelGroupId > 0)        
 BEGIN        
 DECLARE @pricesort bit        
 SELECT @pricesort = pricesortorder from [CMS].[dbo].[CustomHotelGroup] WITH(NOLOCK) WHERE hotelgroupid = @hotelGroupId        
 IF(@pricesort = 1)        
  BEGIN      
   IF (@hotelName = '')      
   BEGIN        
-- print '3'    
--SELECT GetDate() AS [3]    
    
    SELECT * FROM @hotelResponseResult     
    WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))     
    order by hotelSequence desc, minRate desc            
   END      
   ELSE      
   BEGIN      
--SELECT GetDate() AS [4]    
    
    SELECT * FROM @hotelResponseResult     
    WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))     
    AND HotelName LIKE @hotelName     
    order by hotelSequence desc, minRate desc            
   END      
  END        
 ELSE        
  BEGIN      
   IF (@hotelName = '')      
   BEGIN      
 --print '5'    
    SELECT * FROM @hotelResponseResult WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) order by hotelSequence desc, minRate asc            
--SELECT GetDate() AS [5]    
    
   END      
   ELSE      
   BEGIN      
 --print '6'    
    SELECT * FROM @hotelResponseResult WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND HotelName LIKE @hotelName order by hotelSequence desc, minRate asc            
--SELECT GetDate() AS [6]    
    
   END      
  END        
END        
 ELSE        
 BEGIN      
  IF (@hotelName = '')      
  BEGIN        
-- print '7'    
   SELECT * FROM @hotelResponseResult WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) order by hotelSequence desc, minRate asc            
--SELECT GetDate() AS [7]    
    
  END      
  ELSE      
  BEGIN      
  --print '8'       
   SELECT * FROM @hotelResponseResult WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND HotelName LIKE @hotelName order by hotelSequence desc, minRate asc            
--SELECT GetDate() AS [8]    
    
  END
 END  
          
  END        
          
  DROP TABLE #FinalHotelResponse    
  DROP TABLE #TmpHotelResponse
GO
