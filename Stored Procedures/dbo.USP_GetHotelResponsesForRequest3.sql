SET QUOTED_IDENTIFIER ON
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
  
 -- exec USP_GetHotelResponsesForRequest2 19986,'','','','','','','','',1,10,'','LAS',0
    
 **********************************/        
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesForRequest3]                    
( @hotelRequestKey  INT ,                    
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
  @hotelGroupId INT = 0     
)                  
AS                  
BEGIN                    
IF ( @mindistance > 0 )                     
BEGIN                    
SET @mindistance = @mindistance + 0.01                    
END                     
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
  distance FLOAT,                    
  checkInDate DATETIME,                    
  checkOutDate DATETIME,                    
  HotelDescription VARCHAR(8000),                    
  ChainName VARCHAR(128),                  
  minRateTax FLOAT,                    
  ImageURL VARCHAR(100),                    
  preferenceORDER INT,                  
  CorporateCode VARCHAR(30),           
  hotelPolicy varchar(2000),               
  checkInInstruction varchar(2000),        
  tripAdvisorRating varchar(10),      
  checkInTime varchar(50),      
  checkOutTime varchar(50) ,    
  richMediaUrl  varchar(150),
  tripEasyRating FLOAT,
  offerName varchar(200),
  primaryOffertext varchar(600),
  secondaryOffertext varchar(600),
  linktoPage varchar(200),
  inStripOfferImage varchar(500),
  customHotelImageUrl varchar(128),
  cmsHotelName varchar(128) 
  )                    
      
     
      
 --  INSERT INTO @hotelResponseResult(hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType,                  
 --         ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,                  
 --         CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceORDER, 
 --         CorporateCode, hotelPolicy, checkInInstruction, tripAdvisorRating,checkInTime,checkOutTime,
 --         richMediaUrl,tripEasyRating)                     
 --  (
 --  Select  VW.hotelResponseKey,VW.supplierHotelKey,VW.hotelRequestKey,'',VW.minRate,HT.HotelName,HT.Rating,HT.RatingType,HT.ChainCode,VW.HotelId,    
	--	HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode,
	--	AH.Distance,null,null,HD.HotelDescription,HC.ChainName,0,HI.SupplierImageURL,0,null,'','',
	--	HRD.tripAdvisorRating,'','',''
	--	,CASE ISNULL(HGM.HotelSequence,0) WHEN 0 THEN 2 ELSE HGM.HotelSequence END      
	--	--,HGM.HotelSequence 
 --   from vw_uniqueHotelID VW     
 --   inner join HotelContent.dbo.Hotels AS HT ON HT.HotelId = VW.HotelId
 --   LEFT OUTER JOIN [CMS].[dbo].[CustomHotelGroupMapping] HGM ON HGM.HotelId = HT.HotelId AND HGM.HotelGroupId = @hotelGroupId
 --   Left outer join HotelContent.dbo.AirportHotels AS AH ON AH.HotelId = VW.HotelId    
 --   Left outer join HotelContent.dbo.HotelImages AS HI ON HI.HotelId = VW.HotelId     
 --   Left outer join HotelContent.dbo.HotelDescriptions AS HD ON HD.HotelId = VW.HotelId     
 --   Left outer join HotelContent.dbo.HotelChains AS HC ON HC.ChainCode = HT.ChainCode     
 --   Left outer join dbo.HotelResponse AS HRD ON HRD.hotelResponseKey = VW.hotelResponseKey     
        
	--where HI.ImageType = 'Exterior' and VW.HotelRequestKey =@hotelRequestKey
	--)  

   INSERT INTO @hotelResponseResult(hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType,                  
          ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,                  
          CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceORDER, 
          CorporateCode, hotelPolicy, checkInInstruction, tripAdvisorRating,checkInTime,checkOutTime,
          richMediaUrl,tripEasyRating, offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage, customHotelImageUrl,cmsHotelName)                     
   (
   Select  HRD.hotelResponseKey,HRD.supplierHotelKey,VW.hotelRequestKey,HRD.SupplierId,VW.minRate,HT.HotelName,HT.Rating,HT.RatingType,HT.ChainCode,VW.HotelId,    
		HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode,
		AH.Distance,null,null,HD.HotelDescription,HC.ChainName,0,HI.SupplierImageURL,HRD.preferenceOrder,HRD.corporateCode,'','',
		HT.reviewRating as tripAdvisorRating ,'','',''
		,CASE ISNULL(HGM.HotelSequence,0) WHEN 0 THEN 2 ELSE HGM.HotelSequence END, offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage, CHI.ImageURL AS customHotelImageUrl, CH.HotelName As cmsHotelName 
    from vw_uniqueHotelID1 VW     
    inner join HotelContent.dbo.Hotels AS HT ON HT.HotelId = VW.HotelId
    LEFT OUTER JOIN [CMS].[dbo].[CustomHotelGroupMapping] HGM ON HGM.HotelId = HT.HotelId AND HGM.HotelGroupId = @hotelGroupId
    Left outer join HotelContent.dbo.AirportHotels AS AH ON AH.HotelId = VW.HotelId AND AH.AirportCode = HT.CityCode    
    Left outer join HotelContent.dbo.HotelImages AS HI ON HI.HotelId = VW.HotelId     
    Left outer join HotelContent.dbo.HotelDescriptions AS HD ON HD.HotelId = VW.HotelId     
    Left outer join HotelContent.dbo.HotelChains AS HC ON HC.ChainCode = HT.ChainCode     
    INNER JOIN dbo.HotelResponse AS HRD ON HRD.hotelRequestKey = VW.hotelRequestKey AND  HRD.HotelId = VW.HotelId AND HRD.minRate = VW.minRate
    LEFT OUTER JOIN [CMS].[dbo].[CustomHotelImages] AS CHI ON CHI.HotelId = VW.HotelId AND CHI.OrderId = 1
    LEFT OUTER JOIN [CMS].[dbo].[CustomHotels] AS CH ON CH.HotelId = VW.HotelId 
	LEFT OUTER JOIN 
	(
		SELECT TOP 1 ISNULL(OfferName, '') as OfferName, ISNULL(PrimaryOffertext, '') as PrimaryOffertext, 
			ISNULL(SecondaryOffertext, '') as SecondaryOffertext, ISNULL(LinktoPage, '') as LinktoPage,
			ISNULL(InStripOfferImage, '') as  InStripOfferImage, HotelVendorMatch, HotelChainMatch, OfferDisplayStartDate
			, OfferDisplayEndDate, MerchandiseType
		FROM cms..Merchandise WHERE MerchandiseType = 'InStripMessageHotel' AND GETDATE() BETWEEN ISNULL(OfferDisplayStartDate,GETDATE()) AND ISNULL(OfferDisplayEndDate, GETDATE())
	)mer ON VW.HotelId = mer.HotelVendorMatch OR (mer.HotelChainMatch <> '0' AND HC.ChainCode = ISNULL(HC.ChainCode,mer.HotelChainMatch))
	where HI.ImageType = 'Exterior' and VW.HotelRequestKey =@hotelRequestKey
	)
                         
    -- Delete @hotelResponseResult                  
    --FROM @hotelResponseResult t,                  
    --(                  
    -- SELECT supplierHotelKey AS  supplierKey ,min(rowNum)  AS derivedhotelIdentity                  
    -- FROM @hotelResponseResult m                  
    -- GROUP BY  supplierHotelKey                  
    -- having count(1) > 1                  
    --) AS derived                  
    --WHERE t.supplierHotelKey  = derived.supplierKey AND  rowNum > derivedhotelIdentity                  
                  
--IF @sortField = ''                  
--BEGIN                  
 SELECT * FROM @hotelResponseResult order by tripEasyRating desc, minRate asc             
--END                  
--ELSE IF @hotelAmenities='ALL'                  
--BEGIN                  
-- SELECT * FROM @hotelResponseResult ORDER BY CASE @sortField WHEN 'Hotel' THEN HotelName WHEN 'Price' THEN minRate WHEN 'Rating' THEN Rating WHEN 'distance' THEN distance END ASC                  
--END                  
--ELSE                  
--BEGIN                  
-- SELECT * FROM @hotelResponseResult ORDER BY CASE @sortField WHEN 'Hotel' THEN HotelName WHEN 'Price' THEN minRate WHEN 'Rating' THEN Rating WHEN 'distance' THEN distance END ASC                  
--END                  
                   
SELECT MIN (minRate)AS LowestPrice ,MAX (minRate)AS HighestPrice FROM @hotelResponseResult WHERE  hotelRequestKey=@hotelRequestKey               
                    
SELECT  Distinct MIN ( minRate) AS BestPrice,Rating AS Rating FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey GROUP BY Rating ORDER BY Rating                     
                    
SELECT MIN (0)AS Minimumdistance ,MAX (distance)AS Maximumdistance FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey           
AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
                  
                    
/***** Matrix for all brANDs AS per distance ****/                    
                    
                    
 SELECT min(minrate) AS minRate ,chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                  
     
 AND distance between 0 AND 2  GROUP BY chaincode ,chainname ,Rating                     
   UNION                     
   SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))               
        
   AND distance > 2 AND distance <5   GROUP BY chaincode ,chainname  ,Rating                    
   UNION                     
 SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                
       
 AND   distance  > 5   GROUP BY chaincode ,chainname  ,Rating                    
     
 SELECT COUNT(*)AS NoOfHotels,'0-2' AS distance  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance between 0 AND 2                      
 UNION                    
 SELECT COUNT(*)AS NoOfHotels,'2-5' AS distance  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance > 2 AND distance <5                    
 UNION                    
 SELECT COUNT(*)AS NoOfHotels,'>5' AS distance  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND   distance > 5                     
                      
 SELECT COUNT(*) AS [TotalCount] FROM @hotelResponseResult                     
 /****** Matrix ENDs here *****/              
   
 /**Region Mapping with hotels**/  
 SELECT RegionId, RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT  
      ON  RM.HotelId = HT.HotelId   
  
 /**Region list display for city code**/  
 SELECT PR.RegionID,PR.RegionName  FROM [HotelContent].[dbo].[ParentRegionList] PR INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL  
 ON PR.ParentRegionID = AL.MainCityID  WHERE AL.AirportCode = @cityCode   
         
 END
GO
