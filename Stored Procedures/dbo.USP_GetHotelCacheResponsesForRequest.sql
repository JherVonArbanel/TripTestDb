SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
      
/***********************************               
  createdBy - Manoj Kumar Naik                 
  created on - 02/06/2014  
    
  Reason: Created cache hotel response for hotel list page.               
  Updated by Manoj on 20-01-2015 14:36  
  Added MinRate of hotel and RegionName in HotelRegionMapping query.    - TFS-11494   
    Updated - Manoj on 20-04-2016 18:37  
 Added Average Rate with respect to star rating in the return table.
 -- exec USP_GetHotelCacheResponsesForRequest 84465,'','1,2,3,4,5','','','','','','',1,10,'','SFO',930,0,1,1,0     
  
          
 **********************************/              
CREATE PROCEDURE [dbo].[USP_GetHotelCacheResponsesForRequest]    
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
 @isLandmarkRequired bit = 1 ,
 @isGeoSearch  bit = 0,
 @isAirportSearch bit = 0
)  
AS                        
BEGIN       
 SET NOCOUNT ON;  
/*Pefrormance Optimization*/    
--Select  @hotelRequestKey =247022,@hotelRatings=N'0,1,2,3,4,5',@pageNo=1,@pageSize=10,@cityCode=N'SFO',@hotelGroupId=323,@isMatrixRequired=1,@isNearByRegionRequired=1    

Declare @TBL_HotelRatings table
(Ratings varchar(10))

Insert Into @TBL_HotelRatings
(Ratings)
SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )

               
 IF ( @mindistance > 0 )                           
 BEGIN                          
  SET @mindistance = @mindistance + 0.01                          
 END  
                            
 DECLARE @hotelResponseResult TABLE                           
 --Create Table @hotelResponseResult 
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
  preferenceORDER INT,                        
  CorporateCode VARCHAR(30),                 
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
  lowRate FLOAT,      
  highRate FLOAT,     
  realRating FLOAT ,  
  IsPromo bit,  
  PromoDescription varchar(300),  
  AverageBaseCost float,  
  promoId varchar(20) NULL,  
  eanBarRate float NULL,  
  touricoCalculatedBarRate float NULL,  
  touricoNetRate float NULL,  
  touricoCostBasisRate float NULL,  
  marketPlaceVariableId int NULL,  
  isNonRefundable bit,
  proximityDistance FLOAT,
  proximityUnit varchar(50),
  corporateRate float NULL,
  payLaterRate float NULL  
    
 )                           
   
    Declare @CityKey int =0  
    Select @CityKey=AirportKey FROM Trip..AirportLookup Where airportCode= @CityCode  
 print CAST(GetDate() AS varchar) + '1'      
   INSERT INTO @hotelResponseResult  
   (  
  hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType,                        
        ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,                        
        CityCode,CountryName,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceORDER,       
        CorporateCode, hotelPolicy, checkInInstruction, tripAdvisorRating,checkInTime,checkOutTime,      
        richMediaUrl,hotelSequence, offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage, customHotelImageUrl,cmsHotelName,   lowRate,highRate, realRating ,   
        IsPromo , PromoDescription , AverageBaseCost, isNonRefundable,proximityDistance,proximityUnit   
 )  
   (      
  Select '00000000-0000-0000-0000-000000000000','0',@hotelRequestKey,'HotelsCom',0,HT.HotelName,HT.Rating,HT.RatingType,HT.ChainCode,HT.HotelId,          
  HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode, ISNULL(CL.CountryName,'') as CountryName,      
  0,null,null,'',HC.ChainName,0,HI.SupplierImageURL,1,0,'','',      
  HT.reviewRating as tripAdvisorRating ,'','','',0,'','','','','','','',0,0,HT.Rating ,   
  0 , '', 0, 0,0,''   
  FROM HotelContent.dbo.Hotels AS HT  WITH(NOLOCK)   
  --Left outer join HotelContent.dbo.AirportHotels AS AH WITH(NOLOCK) ON AH.HotelId = HT.HotelId AND AH.AirportCode = HT.CityCode          
  LEFT OUTER JOIN [vault].[dbo].CountryLookup CL WITH(NOLOCK) ON HT.CountryCode = CL.CountryCode    
  Left outer join HotelContent.dbo.HotelImages_Exterior AS HI WITH(NOLOCK) ON HI.HotelId = HT.HotelId  AND  HI.ImageType = 'Exterior'              
  Left outer join HotelContent.dbo.HotelChains AS HC WITH(NOLOCK) ON HC.ChainCode = HT.ChainCode           
        WHERE HT.CityKey=@CityKey  
  --AND HT.Rating IN ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))      
 )      
   print CAST(GetDate() as varchar) + '2'  
 -- Deleting multiple records of same hotelId with same hotel rates.    
 --DELETE FROM @hotelResponseResult WHERE rowNumber > 1    
     
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
    SELECT top 50 * FROM @hotelResponseResult   
    WHERE Rating in (Select * From @TBL_HotelRatings) --( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
    order by hotelSequence desc, minRate desc          
   END    
   ELSE    
   BEGIN    
--print '4'  
    SELECT top 50 * FROM @hotelResponseResult   
    WHERE Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
    AND HotelName LIKE @hotelName   
    order by hotelSequence desc, minRate desc          
   END    
  END      
 ELSE      
  BEGIN    
   IF (@hotelName = '')    
   BEGIN    
 --print '5'  
    SELECT top 50 * FROM @hotelResponseResult WHERE Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
    order by hotelSequence desc, minRate asc          
   END    
   ELSE    
   BEGIN    
 --print '6'  
    SELECT top 50 * FROM @hotelResponseResult WHERE Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
    AND HotelName LIKE @hotelName order by hotelSequence desc, minRate asc          
   END    
  END      
END      
 ELSE      
 BEGIN    
  IF (@hotelName = '')    
  BEGIN      
-- print '7'  
   SELECT top 50 * FROM @hotelResponseResult WHERE Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
   order by hotelSequence desc, minRate asc          
  END    
  ELSE    
  BEGIN    
  --print '8'     
   SELECT top 50 * FROM @hotelResponseResult WHERE Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
   AND HotelName LIKE @hotelName order by hotelSequence desc, minRate asc          
  END    
 END                             
       
IF (@hotelName = '')    
BEGIN    
 --Select GETDATE() [9]    
 SELECT  Distinct MIN ( minRate) AS BestPrice, AVG(minRate) AS AvgRate ,Rating AS Rating   
 FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
 GROUP BY Rating ORDER BY Rating                       
               
END    
ELSE    
BEGIN    
-- Select GETDATE() [10]    
 SELECT  Distinct MIN (minRate) AS BestPrice, AVG(minRate) AS AvgRate ,Rating AS Rating   
 FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND HotelName LIKE @hotelName AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 GROUP BY Rating ORDER   
BY Rating                                    
END     
      
IF (@hotelName = '')    
BEGIN     
-- Select GETDATE() [11]    
 SELECT MIN (minRate)AS LowestPrice ,MAX (minRate)AS HighestPrice   
 FROM @hotelResponseResult   
 WHERE  hotelRequestKey=@hotelRequestKey    
 AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))        
END    
ELSE    
BEGIN    
-- Select GETDATE() [12]    
 SELECT MIN (minRate)AS LowestPrice ,MAX (minRate)AS HighestPrice   
 FROM @hotelResponseResult   
 WHERE  hotelRequestKey=@hotelRequestKey    
 AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND HotelName LIKE @hotelName      
END    
    
IF(@isMatrixRequired = 1)      
  BEGIN                         
                                      
 --Select GETDATE() [13]    
 SELECT MIN (0)AS Minimumdistance ,MAX (distance)AS Maximumdistance FROM  @hotelResponseResult     
 WHERE hotelRequestKey=@hotelRequestKey                 
 AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                         
                    
                           
 /***** Matrix for all brANDs AS per distance ****/       
 --print @isLimitedChainList                     
IF(@isLimitedChainList = 1)    
BEGIN                         
           
  IF( @hotelName = '' )    
  BEGIN    
  
--Select GETDATE() [14]  
  
    SELECT min(minrate) AS minRate ,HR.chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult As HR INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode    
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
    AND distance between 0 AND 2     
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null         
    GROUP BY HR.chaincode ,chainname ,Rating  
    UNION   
    SELECT min(minrate) AS minRate  ,HR.chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating    
    FROM  @hotelResponseResult As HR   
 INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
 ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
    AND (distance > 2 AND distance <=5)   
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null   
    GROUP BY HR.chaincode ,chainname  ,Rating   
    UNION                     
    SELECT min(minrate) AS minRate  ,HR.chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating   
    FROM  @hotelResponseResult AS HR INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode =   
 HR.chainCode WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
    AND   distance  > 5      
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null     
    GROUP BY HR.chaincode ,chainname  ,Rating     
    order by chainname asc      
    
  END    
  ELSE    
  BEGIN    
  -- Select GETDATE() [15]    
    SELECT min(minrate) AS minRate ,HR.chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult AS HR INNER JOIN [HotelContent].[dbo].[tbl_HotelChainMapping] WITH(NOLOCK)   
    ON [HotelContent].[dbo].[tbl_HotelChainMapping].ChainCode = HR.chainCode   
    WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
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
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                 
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
    AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
    AND   distance  > 5      
    AND HR.chaincode is not null and HR.chaincode <> '' And ChainName is not null     
    AND HotelName LIKE @hotelName    
    GROUP BY HR.chaincode ,chainname  ,Rating     
    ORDER BY chainname ASC    
        
  END    
                          
END    
ELSE    
BEGIN    
  IF( @hotelName = '' )    
  BEGIN    
 -- Select GETDATE() [14]   
    
    SELECT min(minrate) AS minRate ,chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))    
    AND distance between 0 AND 2     
    AND chaincode is not null and chaincode <> ''   
    And ChainName is not null         
    GROUP BY chaincode ,chainname ,Rating     
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                
    AND (distance > 2 AND distance <=5)      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    GROUP BY chaincode ,chainname  ,Rating  
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating   
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))               
    AND   distance  > 5      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    GROUP BY chaincode ,chainname  ,Rating     
    
  END    
  ELSE    
  BEGIN    
  -- Select GETDATE() [15]    
    SELECT min(minrate) AS minRate ,chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))    
    AND distance between 0 AND 2     
    AND chaincode is not null and chaincode <> ''   
    And ChainName is not null      
    AND HotelName LIKE @hotelName     
    GROUP BY chaincode ,chainname ,Rating  
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating    
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                
    AND distance > 2 AND distance <=5      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    AND HotelName LIKE @hotelName    
    GROUP BY chaincode ,chainname  ,Rating       
    UNION                           
    SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating   
    FROM  @hotelResponseResult   
    WHERE hotelRequestKey=@hotelRequestKey   
    AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))              
    AND   distance  > 5      
    AND chaincode is not null and chaincode <> '' And ChainName is not null     
    AND HotelName LIKE @hotelName    
    GROUP BY chaincode ,chainname  ,Rating     
  END    
END      
      
      
IF( @hotelName = '' )    
BEGIN    
-- Select GETDATE() [16]            
 SELECT COUNT(*)AS NoOfHotels,'0-2' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND distance between 0 AND 2                            
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'2-5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND distance > 2 AND distance <=5                          
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'>5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in (Select * From @TBL_HotelRatings)--( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))   
 AND   distance > 5                            
END    
ELSE    
BEGIN    
-- Select GETDATE() [17]            
 SELECT COUNT(*)AS NoOfHotels,'0-2' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey   
 AND Rating in   
 (Select * From @TBL_HotelRatings)
 --( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
 AND distance between 0 AND 2 AND HotelName LIKE @hotelName          
                   
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'2-5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND Rating in   
 (Select * From @TBL_HotelRatings)
 --( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
 AND distance > 2 AND distance <=5 AND HotelName LIKE @hotelName      
                     
 UNION                          
 SELECT COUNT(*)AS NoOfHotels,'>5' AS distance  FROM  @hotelResponseResult   
 WHERE hotelRequestKey=@hotelRequestKey AND 
 Rating in (Select * From @TBL_HotelRatings)
 --( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) 
 AND   distance > 5 AND HotelName LIKE @hotelName                     
        
END    
    
-- Select GETDATE() [18]     
  SELECT COUNT(*) AS [TotalCount] FROM @hotelResponseResult                           
  /****** Matrix ENDs here *****/                    
       
 END      
    
      
IF (@isNearByRegionRequired = 1)      
BEGIN      
  /**Region Mapping with hotels**/        
  --SELECT RegionId, RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT        
  --  ON  RM.HotelId = HT.HotelId       
-- Select GETDATE() [19]         
 DECLARE @regionId BIGINT      
 SELECT @regionId = [RegionId] FROM [CMS].[dbo].[CustomHotelGroup] WITH(NOLOCK) WHERE [HotelGroupId] = @hotelGroupId      
       
 IF (@regionId > 0)      
 BEGIN      
-- Select GETDATE() [20]    
  SELECT RM.RegionId, RM.HotelId , HT.minRate, PR.RegionName   From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK)   
  INNER JOIN @hotelResponseResult HT        
  ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR       
  ON PR.RegionId = RM.RegionId  AND  PR.ParentRegionID = @regionId          
    --PR.RegionType='Neighborhood' and PR.subclass <> 'city' AND    
 UNION    
 SELECT 0, HT.HotelId, HT.minRate, '' As RegionName FROM @hotelResponseResult HT     
 WHERE HotelId NOT IN (SELECT RM.HotelId From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK) INNER JOIN @hotelResponseResult HT        
    ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK)     
    ON PR.RegionId = RM.RegionId  AND  PR.ParentRegionID = @regionId )      
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
    
    
     
-- Select GETDATE() [21]     
Declare @RM Table (HotelId int)     
Insert Into @RM (HotelId)    
 SELECT RM.HotelId    
 From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK)   
   INNER JOIN @hotelResponseResult HT ON  RM.HotelId = HT.HotelId    
   INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK) ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' --and PR.subclass <> 'city'      
       INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR1 WITH(NOLOCK) ON PR1.RegionID = PR.ParentRegionID  
   INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL WITH(NOLOCK) ON PR1.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode    

    
-- Select GETDATE() [22]    
    
Declare @RHM Table (RegionId bigint, HotelId int, MinRate float, RegionName nvarchar(200))    
Insert Into @RHM (RegionId,HotelId,MinRate,RegionName)     
 SELECT  RM.RegionId    
   ,RM.HotelId, HT.minRate, PR.RegionName     
 From HotelContent..RegionHotelIDMapping RM WITH(NOLOCK)    
   INNER JOIN @hotelResponseResult HT ON  RM.HotelId = HT.HotelId    
   INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK) ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' --and PR.subclass <> 'city'      
        INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR1 WITH(NOLOCK) ON PR1.RegionID = PR.ParentRegionID  
   INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL WITH(NOLOCK) ON PR1.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode    

    
--SELECT GetDate() AS [33]  
  
Insert Into @RHM (RegionId,HotelId,MinRate,RegionName)     
SELECT 0, HT.HotelId, HT.minRate, ''  FROM @hotelResponseResult HT     
 WHERE HotelId NOT IN (Select HotelId from @RM)   
--SELECT GetDate() AS [34]  
     
Select  RegionId    
  ,HotelId, MinRate, RegionName  
From @RHM  WHERE RegionID > 0  
    
    
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
-- Select GETDATE() [22]        
 --SELECT  PR.RegionID,PR.RegionName  FROM [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK)   
 --INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL WITH(NOLOCK)  
 -- ON PR.ParentRegionID = AL.MainCityID    
 -- WHERE AL.AirportCode = @cityCode AND PR.RegionType='Neighborhood' --and PR.subclass <> 'city'  
 
 --SELECT  PR1.RegionID,PR1.RegionName  FROM [HotelContent].[dbo].[ParentRegionList] PR WITH(NOLOCK)   
 --INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL WITH(NOLOCK)  
 -- ON PR.ParentRegionID = AL.MainCityID    
 -- INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR1 ON PR.RegionID = Pr1.ParentRegionID
 -- WHERE AL.AirportCode = @cityCode AND PR1.RegionType='Neighborhood'      
-- Select GETDATE() [23]                
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
GO
