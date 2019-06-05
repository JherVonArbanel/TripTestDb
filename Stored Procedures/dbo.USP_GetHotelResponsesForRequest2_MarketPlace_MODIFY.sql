SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

    
      
/***********************************               
  updatedBy - Manoj Kumar Naik                 
  updated on - 16/06/2012              
  Remarks - Added   hotelPolicy varchar(2000),                     
                    checkInInstruction varchar(2000),              
                    tripAdvisorRating varchar(10)              
            to temp @hotelResponseResult table. Since vw_hotelDetailedResponse1 is modified.              
  updated on 18/05/2012 by Manoj Kumar Naik            
  Added  - checkInTime varchar(50)            
   -  checkOutTime varchar(50)            
  Added - tourico implementation on 09/07/2012            
  created backup file for static search results        
        
  updated on 31-10-2012        
  updatedBy - Manoj Kumar Naik            
        
  updated on 19-11-2012  14:22        
  summary - Restored the earlier implementation of CMS hotel.      
  updatedBy - Manoj Kumar Naik            
        
  New fields added to temp table       
  offerName varchar(200),      
  primaryOffertext varchar(600),      
  secondaryOffertext varchar(600),      
  linktoPage varchar(200),      
  inStripOfferImage varchar(500),      
  customHotelImageUrl varchar(128),      
  cmsHotelName varchar(128)       
        
  updated - manoj  on 24-11-2012 14:15      
  Summary - changed the table column tripEasy to hotelSequence &      
   implemented the richMediaUrl which was passed as empty string earlier.       
         
   updated - manoj on 18-12-2012 22:28      
   Summary - passed new parameter for MatrixRequired & NearByRegionRequired for the site &       
   only those tables will be called which are required.      
         
   updated - keyur sheth on 9-1-2013 13:00      
   Summary - added functionality for hotel result search based on hotel group id      
         
   updated - manoj on 10-1-2013 15:11      
   Summary - added lowRate & highRate column for tripaudit project requirement      
         
   updated - manoj on 07-03-2013 17:21      
   Summary - changed the logic which will show hotels which doesn't have exterior image      
      
   updated - keyur sheth on 21-03-2013 12:15      
   Summary - changed the logic for hotel sequence default values - now if hotel sequence is greater than 10 it will be taken as 1      
       
   updated - Samir Dedhia on 26-03-2013    
   Summary - "TOP 1" removed from InstripHotel Query as it was taking only one record into consideration though there were many records between     
             from date and to date.     
        
 updated - Keyur Sheth on 25-04-2013    
 Summary - Implemented the Hotel Name (Optional) and Star Rating Search from Hotel Section landing page.    
     
    updated - Manoj Naik on 13-09-2013    
 Summary - Removing duplication of hotels, if same hotel from multiple vendors have same price.    
     
 updated - Jitendra Verma on 27-09-2013    
 Summary - Hotel Chain List as per site requirement.    
   
 Updated - Jayant Guru on 19th Sep 2014  
 Summary - Implemented new marketplace rules  
   
 Updated - Manoj Naik on 20th Nov 2014  
 Summary - Added minRateTax  
   
 Updated - Manoj Naik on 17th Dec 2014  
 Summary - Added isNonRefundable  
         
 Updated - Manoj on 20-01-2015 14:36  
 Added MinRate of hotel and RegionName in HotelRegionMapping query.  TFS-11494.        
 
 Updated - Hemali on 09-04-2015 14:36  
 Exclude non contracted fare from Sabre Hotel List when Contracted Fare is avaialble for same Hotel
 
 Updated - Manoj on 21-04-2015 12:36  
 Hotel Images from CustomHotelImages should only be avilable for HotelGroupId=1
 
 Updated - Manoj on 17-08-2015 15:56  
 Added ProximityDistance and ProximityUnit for mobile device proximity search. Return those two values.
 
  Updated - Manoj on 20-04-2016 18:37  
 Added Average Rate with respect to star rating in the return table.
 
 --exec USP_GetHotelResponsesForRequest2_MarketPlace @hotelRequestKey =146773,@hotelRatings=N'0,1,2,3,4,5',@pageNo=1,@pageSize=10,@cityCode=N'DFW',@hotelGroupId=134,@isMatrixRequired=1,@isNearByRegionRequired=1,@isLimitedChainList=1  
          
 **********************************/              
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesForRequest2_MarketPlace_MODIFY]    
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
/*Pefrormance Optimization*/    
--Select  @hotelRequestKey =247022,@hotelRatings=N'0,1,2,3,4,5',@pageNo=1,@pageSize=10,@cityCode=N'SFO',@hotelGroupId=323,@isMatrixRequired=1,@isNearByRegionRequired=1                   
-- EXEC [USP_GetHotelResponsesForRequest2] @hotelRequestKey =58860,@hotelRatings=N'0,1,2,3,4,5',@pageNo=1,@pageSize=10,@cityCode=N'SFO',@hotelGroupId=0,@isMatrixRequired=0,@isNearByRegionRequired=1,@isLimitedChainList=1  
-- EXEC [USP_GetHotelResponsesForRequest2] @hotelRequestKey =58881,@hotelRatings=N'0,1,2,3,4,5',@pageNo=1,@pageSize=10,@cityCode=N'LAS',@hotelGroupId=196,@isMatrixRequired=0,@isNearByRegionRequired=1,@isLimitedChainList=1  
  
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
  Rating INT,                          
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
  proximityUnit varchar(50) NULL  
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
        ,promoId, eanBarRate, touricoCalculatedBarRate, touricoNetRate, touricoCostBasisRate, marketPlaceVariableId, isNonRefundable,proximityDistance,proximityUnit   
 )  
   (    
  SELECT FHR.hotelResponseKey,FHR.supplierHotelKey,FHR.hotelRequestKey,FHR.SupplierId,FHR.minRate,HT.HotelName,HT.Rating,HT.RatingType, FHR.corporateCode, FHR.preferenceOrder,  
   (CASE WHEN (HT.ChainCode='') THEN CONVERT(varchar(50), FHR.HotelId) ELSE HT.ChainCode END) AS ChainCode,
   FHR.HotelId,HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode,   
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
   ,FHR.promoId, FHR.eanBarRate, FHR.touricoCalculatedBarRate, FHR.touricoNetRate, FHR.touricoCostBasisRate, FHR.marketPlaceVariableId, FHR.isNonRefundable, FHR.proximityDistance, FHR.proximityUnit
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
        ,promoId, eanBarRate, touricoCalculatedBarRate, touricoNetRate, touricoCostBasisRate, marketPlaceVariableId, isNonRefundable, proximityDistance, proximityUnit
 )  
   (    
  SELECT FHR.hotelResponseKey,FHR.supplierHotelKey,FHR.hotelRequestKey,FHR.SupplierId,FHR.minRate,HT.HotelName,HT.Rating,HT.RatingType, FHR.corporateCode, FHR.preferenceOrder,  
  (CASE WHEN (HT.ChainCode='') THEN CONVERT(varchar(50), FHR.HotelId)  ELSE HT.ChainCode END) As ChainCode,
   FHR.HotelId,HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode,   
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
   ,FHR.promoId, FHR.eanBarRate, FHR.touricoCalculatedBarRate, FHR.touricoNetRate, FHR.touricoCostBasisRate, FHR.marketPlaceVariableId, FHR.isNonRefundable, FHR.proximityDistance, FHR.proximityUnit
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
 print '3'  
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
 print '5'  
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
 print '7'  
   SELECT * FROM @hotelResponseResult WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) order by hotelSequence desc, minRate asc          
--SELECT GetDate() AS [7]  
  
  END    
  ELSE    
  BEGIN    
  print '8'     
   SELECT * FROM @hotelResponseResult WHERE Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND HotelName LIKE @hotelName order by hotelSequence desc, minRate asc          
--SELECT GetDate() AS [8]  
  
  END    
 END                             
       
IF (@hotelName = '')    
BEGIN    
 --Select GETDATE() [9]    
 SELECT  Distinct MIN ( minRate) AS BestPrice, AVG(minRate) AS AvgRate, Rating AS Rating   
 FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) GROUP BY Rating ORDER BY Rating                       
--SELECT GetDate() AS [9]  
  
               
END    
ELSE    
BEGIN    
-- Select GETDATE() [10]    
 SELECT  Distinct MIN (minRate) AS BestPrice , AVG(minRate) AS AvgRate ,Rating AS Rating   
 FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND HotelName LIKE @hotelName AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 GROUP BY Rating ORDER   
BY Rating                                    
--SELECT GetDate() AS [10]  
  
END     
      
IF (@hotelName = '')    
BEGIN     
-- Select GETDATE() [11]    
 SELECT MIN (minRate)AS LowestPrice ,MAX (minRate)AS HighestPrice   
 FROM @hotelResponseResult   
 WHERE  hotelRequestKey=@hotelRequestKey    
 AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))        
--SELECT GetDate() AS [11]  
  
END    
ELSE    
BEGIN    
-- Select GETDATE() [12]    
 SELECT MIN (minRate)AS LowestPrice ,MAX (minRate)AS HighestPrice   
 FROM @hotelResponseResult   
 WHERE  hotelRequestKey=@hotelRequestKey    
 AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND HotelName LIKE @hotelName      
--SELECT GetDate() AS [12]  
END    
    
IF(@isMatrixRequired = 1)      
  BEGIN                         
                                      
 --Select GETDATE() [13]    
 SELECT MIN (0)AS Minimumdistance ,MAX (distance)AS Maximumdistance FROM  @hotelResponseResult     
 WHERE hotelRequestKey=@hotelRequestKey                 
 AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                         
  
--SELECT GetDate() AS [13]  
                           
 /***** Matrix for all brANDs AS per distance ****/       
 --print @isLimitedChainList                     
IF(@isLimitedChainList = 1)    
BEGIN                         
           
  IF( @hotelName = '' )    
  BEGIN    
  
--SELECT GetDate() AS [14]  
  
  
    SELECT min(minrate) AS minRate ,HR.chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult As HR INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode    
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
    AND distance between 0 AND 2     
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null         
    GROUP BY HR.chaincode ,chainname ,Rating  
    UNION   
    SELECT min(minrate) AS minRate  ,HR.chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating    
    FROM  @hotelResponseResult As HR   
 INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
 ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
    AND (distance > 2 AND distance <=5)   
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null   
    GROUP BY HR.chaincode ,chainname  ,Rating   
    UNION                     
    SELECT min(minrate) AS minRate  ,HR.chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating   
    FROM  @hotelResponseResult AS HR INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode =   
 HR.chainCode WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
    AND   distance  > 5      
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null     
    GROUP BY HR.chaincode ,chainname  ,Rating     
    order by chainname asc      
--SELECT GetDate() AS [15]  
    
  END    
  ELSE    
  BEGIN    
--SELECT GetDate() AS [16]  
    SELECT min(minrate) AS minRate ,HR.chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult AS HR INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode   
    WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
    AND distance between 0 AND 2     
    AND HR.chaincode is not null   
    AND HR.chaincode <> '' And ChainName is not null      
    AND HotelName LIKE @hotelName     
    GROUP BY HR.chaincode ,chainname ,Rating  
    UNION                           
    SELECT min(minrate) AS minRate  ,HR.chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating    
    FROM  @hotelResponseResult AS HR   
    INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode   
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                 
    AND distance > 2 AND distance <=5      
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null     
    AND HotelName LIKE @hotelName    
    GROUP BY HR.chaincode ,chainname  ,Rating  
    UNION                           
    SELECT min(minrate) AS minRate  ,HR.chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating   
    FROM  @hotelResponseResult AS HR   
    INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
    AND   distance  > 5      
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null     
    AND HotelName LIKE @hotelName    
    GROUP BY HR.chaincode ,chainname  ,Rating     
    ORDER BY chainname ASC    
--SELECT GetDate() AS [17]  
  
  END    
                          
END    
ELSE    
BEGIN    
  IF( @hotelName = '' )    
  BEGIN    
 -- Select GETDATE() [14]   
--SELECT GetDate() AS [18]  
    
    SELECT min(minrate) AS minRate ,chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))    
    AND distance between 0 AND 2     
    AND chaincode is not null and chaincode <> ''   
    And ChainName is not null         
    GROUP BY chaincode ,chainname ,Rating     
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                
    AND (distance > 2 AND distance <=5)      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    GROUP BY chaincode ,chainname  ,Rating  
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating   
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))               
    AND   distance  > 5      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    GROUP BY chaincode ,chainname  ,Rating     
--SELECT GetDate() AS [19]  
    
  END    
  ELSE    
  BEGIN    
  -- Select GETDATE() [15]    
--SELECT GetDate() AS [20]  
    SELECT min(minrate) AS minRate ,chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))    
    AND distance between 0 AND 2     
    AND chaincode is not null and chaincode <> ''   
    And ChainName is not null      
    AND HotelName LIKE @hotelName     
    GROUP BY chaincode ,chainname ,Rating  
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                
    AND distance > 2 AND distance <=5      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    AND HotelName LIKE @hotelName    
    GROUP BY chaincode ,chainname  ,Rating       
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating   
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))              
    AND   distance  > 5      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    AND HotelName LIKE @hotelName    
    GROUP BY chaincode ,chainname  ,Rating     
--SELECT GetDate() AS [21]  
  END    
END      
      
      
IF( @hotelName = '' )    
BEGIN    
--SELECT GetDate() AS [22]  
  
 SELECT COUNT(*)AS NoOfHotels,'0-2' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND distance between 0 AND 2                            
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'2-5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND distance > 2 AND distance <=5                          
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'>5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND   distance > 5                            
--SELECT GetDate() AS [23]  
END    
ELSE    
BEGIN    
--SELECT GetDate() AS [24]  
  
 SELECT COUNT(*)AS NoOfHotels,'0-2' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in   
 ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance between 0 AND 2 AND HotelName LIKE @hotelName          
                   
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'2-5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in   
 ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance > 2 AND distance <=5 AND HotelName LIKE @hotelName      
                     
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'>5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND   distance > 5 AND HotelName LIKE @hotelName                     
--SELECT GetDate() AS [25]  
  
END    
    
-- Select GETDATE() [18]     
  SELECT COUNT(*) AS [TotalCount] FROM @hotelResponseResult                           
  /****** Matrix ENDs here *****/                    
--SELECT GetDate() AS [26]  
       
 END      
    
      
IF (@isNearByRegionRequired = 1)      
BEGIN      
  /**Region Mapping with hotels**/        
  --SELECT RegionId, RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT        
  --  ON  RM.HotelId = HT.HotelId       
--SELECT GetDate() AS [27]  
  
 DECLARE @regionId INT      
 SELECT @regionId = [RegionId] FROM [CMS].[dbo].[CustomHotelGroup] WITH(NOLOCK) WHERE [HotelGroupId] = @hotelGroupId      
  
--SELECT GetDate() AS [28]  
       
 IF (@regionId > 0)      
 BEGIN      
--SELECT GetDate() AS [29]  
  
  SELECT RM.RegionId, RM.HotelId, HT.minRate, PR.RegionName From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK)   
  INNER JOIN @hotelResponseResult HT        
  ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR       
  ON PR.RegionId = RM.RegionId  AND  PR.ParentRegionID = @regionId          
    --PR.RegionType='Neighborhood' and PR.subclass <> 'city' AND    
 UNION    
 SELECT 0, HT.HotelId, HT.minRate, '' AS RegionName FROM @hotelResponseResult HT     
 WHERE HotelId NOT IN (SELECT RM.HotelId From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK) INNER JOIN @hotelResponseResult HT        
    ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK)     
    ON PR.RegionId = RM.RegionId  AND  PR.ParentRegionID = @regionId )      
--SELECT GetDate() AS [30]  
 END      
 ELSE      
 BEGIN    
/* Old One    
SELECT RM.RegionId, RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT        
    ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR       
    ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'      
    INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL ON PR.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode    
 UNION    
 SELECT 0, HT.HotelId FROM @hotelResponseResult HT     
 WHERE HotelId NOT IN (SELECT RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT        
    ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR       
    ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'      
    INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL ON PR.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode)        
    
--*/    
    
    
     
--SELECT GetDate() AS [31]  
  
Declare @RM Table (HotelId int)     
Insert Into @RM (HotelId)    
 SELECT RM.HotelId    
 From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK)   
   INNER JOIN @hotelResponseResult HT ON  RM.HotelId = HT.HotelId    
   INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK) ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' --and PR.subclass <> 'city'      
   INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL WITH(NOLOCK) ON PR.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode    
    
--SELECT GetDate() AS [32]  
  
Declare @RHM Table (RegionId int, HotelId int, MinRate float, RegionName nvarchar(200))    
Insert Into @RHM (RegionId,HotelId,MinRate,RegionName)     
 SELECT  RM.RegionId    
   ,RM.HotelId, HT.minRate, PR.RegionName     
 From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK)    
   INNER JOIN @hotelResponseResult HT ON  RM.HotelId = HT.HotelId    
   INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK) ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' --and PR.subclass <> 'city'      
   INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL WITH(NOLOCK) ON PR.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode    
    
--SELECT GetDate() AS [33]  
  
Insert Into @RHM (RegionId,HotelId,MinRate,RegionName)     
SELECT 0, HT.HotelId, HT.minRate,''  FROM @hotelResponseResult HT     
 WHERE HotelId NOT IN (Select HotelId from @RM)   
--SELECT GetDate() AS [34]  
     
Select  RegionId    
  ,HotelId, MinRate, RegionName  
From @RHM   WHERE RegionID > 0  
--SELECT GetDate() AS [35]  
  
    
/*    
-- Select GETDATE() [24]      
 SELECT  RM.RegionId    
   ,RM.HotelId     
 From HotelContent..RegionHotelIDMapping RM     
   INNER JOIN @hotelResponseResult HT ON  RM.HotelId = HT.HotelId    
   INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'      
   INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL ON PR.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode    
 --UNION    
-- Select GETDATE() [25]    
*/    
     
/*     
 SELECT   0    
    ,HT.HotelId     
 FROM   @hotelResponseResult HT     
 WHERE   HotelId NOT IN (    
 SELECT RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT        
    ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR       
    ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'      
    INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL ON PR.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode)        
*/        
 END          
           
  /**Region list display for city code**/      
        
  --SELECT top 15 PR.RegionID,PR.RegionName  FROM [HotelContent].[dbo].[ParentRegionList] PR INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL        
  --ON PR.ParentRegionID = AL.MainCityID  WHERE AL.AirportCode = @cityCode --and pr.regionname IN ('East Orange','North Bergen','Jamaica','Fort Lee','Woodside','Brooklyn','Ridgefield','Secaucus','Queens Village','Long Island City')      
--SELECT GetDate() AS [36]  
  
 SELECT  PR.RegionID,PR.RegionName  FROM [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK)   
 INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL WITH(NOLOCK)  
  ON PR.ParentRegionID = AL.MainCityID    
  WHERE AL.AirportCode = @cityCode AND PR.RegionType='Neighborhood' --and PR.subclass <> 'city'        
--SELECT GetDate() AS [37]  
  
  END       
    
  
    
--IF (@isLandmarkRequired = 1)    
--BEGIN    
-- SELECT TOP 10     
--  RegionId AS LandmarkId    
--  , RegionName AS LandmarkName     
-- FROM     
--  [HotelContent].[dbo].[ParentRegionList]     
-- WHERE     
--  RegionType = 'Point of Interest'    
--END    
  
  
        
  END      
        
  DROP TABLE #FinalHotelResponse  
  DROP TABLE #TmpHotelResponse
GO
