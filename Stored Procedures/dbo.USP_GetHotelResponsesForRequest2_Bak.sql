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
   
 -- exec USP_GetHotelResponsesForRequest2 36685,'','','','','','','','',1,100,'','',0,1,0
    
 **********************************/        
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesForRequest2_Bak]                    
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
  @hotelGroupId INT = 0,     
  @isMatrixRequired bit = 0, 
  @isNearByRegionRequired bit = 0
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
  highRate FLOAT 
  )                     

   INSERT INTO @hotelResponseResult(hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType,                  
          ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,                  
          CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceORDER, 
          CorporateCode, hotelPolicy, checkInInstruction, tripAdvisorRating,checkInTime,checkOutTime,
          richMediaUrl,hotelSequence, offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage, customHotelImageUrl,cmsHotelName,lowRate,highRate)                     
   (
   Select  HRD.hotelResponseKey,HRD.supplierHotelKey,VW.hotelRequestKey,HRD.SupplierId,VW.minRate,HT.HotelName,HT.Rating,HT.RatingType,HT.ChainCode,VW.HotelId,    
		HT.Latitude,HT.Longitude,HT.Address1,HT.CityName,HT.StateCode,HT.CountryCode,HT.ZipCode,'','',HT.CityCode,
		AH.Distance,null,null,HD.HotelDescription,HC.ChainName,0,HI.SupplierImageURL,HRD.preferenceOrder,HRD.corporateCode,'','',
		HT.reviewRating as tripAdvisorRating ,'','',''
		,CASE ISNULL(HGM.HotelSequence,0) WHEN 0 THEN 2 ELSE HGM.HotelSequence END, offerName, primaryOffertext, secondaryOffertext, linktoPage, inStripOfferImage, CHI.ImageURL AS customHotelImageUrl, 
		CH.H1Title As cmsHotelName, HRD.lowRate, HRD.highRate 
    from vw_uniqueHotelID VW     
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
           
 IF(@hotelGroupId > 0)
 BEGIN
	DECLARE @pricesort bit
	SELECT @pricesort = pricesortorder from [CMS].[dbo].[CustomHotelGroup] WHERE hotelgroupid = @hotelGroupId
	IF(@pricesort = 1)
	BEGIN
		SELECT * FROM @hotelResponseResult order by hotelSequence desc, minRate desc    
	END
	ELSE
	BEGIN
		SELECT * FROM @hotelResponseResult order by hotelSequence desc, minRate asc    
	END
 END
 ELSE
 BEGIN
	SELECT * FROM @hotelResponseResult order by hotelSequence desc, minRate asc    
 END                        
 
 
 SELECT  Distinct MIN ( minRate) AS BestPrice,Rating AS Rating FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey GROUP BY Rating ORDER BY Rating                              

SELECT MIN (minRate)AS LowestPrice ,MAX (minRate)AS HighestPrice FROM @hotelResponseResult WHERE  hotelRequestKey=@hotelRequestKey    

IF (@isNearByRegionRequired = 1)
BEGIN
	 /**Region Mapping with hotels**/  
	 --SELECT RegionId, RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT  
		--  ON  RM.HotelId = HT.HotelId 
		
	DECLARE @regionId INT
	SELECT @regionId = [RegionId] FROM [CMS].[dbo].[CustomHotelGroup] WHERE [HotelGroupId] = @hotelGroupId
	
	IF (@regionId > 0)
	BEGIN
		SELECT RM.RegionId, RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT  
		  ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR 
		  ON PR.RegionId = RM.RegionId  AND  PR.ParentRegionID = @regionId		  
		  --PR.RegionType='Neighborhood' and PR.subclass <> 'city' AND
	END
	ELSE
	BEGIN
		SELECT RM.RegionId, RM.HotelId From HotelContent..RegionHotelIDMapping RM INNER JOIN @hotelResponseResult HT  
		  ON  RM.HotelId = HT.HotelId  INNER JOIN [HotelContent].[dbo].[ParentRegionList] PR 
		  ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'
		  INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL ON PR.ParentRegionID = AL.MainCityID  AND AL.AirportCode = @cityCode 
	END		 	
	 	  
	 /**Region list display for city code**/
	 
	 --SELECT top 15 PR.RegionID,PR.RegionName  FROM [HotelContent].[dbo].[ParentRegionList] PR INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL  
	 --ON PR.ParentRegionID = AL.MainCityID  WHERE AL.AirportCode = @cityCode --and pr.regionname IN ('East Orange','North Bergen','Jamaica','Fort Lee','Woodside','Brooklyn','Ridgefield','Secaucus','Queens Village','Long Island City')
	 
	SELECT  PR.RegionID,PR.RegionName  FROM [HotelContent].[dbo].[ParentRegionList] PR INNER JOIN [HotelContent].[dbo].AirportCoordinatesList AL  
	 ON PR.ParentRegionID = AL.MainCityID  WHERE AL.AirportCode = @cityCode AND PR.RegionType='Neighborhood' and PR.subclass <> 'city'	 
	         
	 END 
  END           
IF(@isMatrixRequired = 1)
  BEGIN                   
	                               
	                    
	SELECT MIN (0)AS Minimumdistance ,MAX (distance)AS Maximumdistance FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey           
	AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                   
	                  
	                    
	/***** Matrix for all brANDs AS per distance ****/                    
	                    
	                    
	 SELECT min(minrate) AS minRate ,chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                  
	     
	 AND distance >= 0 AND distance <= 2  AND chaincode is not null and chaincode <> ''    GROUP BY chaincode ,chainname ,Rating                     
	   UNION                     
	   SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))               
	        
	   AND distance > 2 AND distance <=5  AND chaincode is not null and chaincode <> ''  GROUP BY chaincode ,chainname  ,Rating                    
	   UNION                     
	 SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))                
	       
	 AND   distance  > 5  AND chaincode is not null and chaincode <> '' GROUP BY chaincode ,chainname  ,Rating                    
	     
	 SELECT COUNT(*)AS NoOfHotels,'0-2' AS distance  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance >= 0 AND distance <= 2                      
	 UNION                    
	 SELECT COUNT(*)AS NoOfHotels,'2-5' AS distance  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance > 2 AND distance <=5                    
	 UNION                    
	 SELECT COUNT(*)AS NoOfHotels,'>5' AS distance  FROM  @hotelResponseResult WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND   distance > 5                     
	                      
	 SELECT COUNT(*) AS [TotalCount] FROM @hotelResponseResult                     
	 /****** Matrix ENDs here *****/              

print 'com' 
 END
GO
