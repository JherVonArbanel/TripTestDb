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
            to temp @hotelResponseResult table. Since vw_sabreHotelResponse is modified.    
  updated on 18/05/2012 by Manoj Kumar Naik  
  Added  - checkInTime varchar(50)  
   -  checkOutTime varchar(50)  
 **********************************/    
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesForRequest_Sujit]                
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
  @hotelName VARCHAR(100) = ''              
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
  ContractCode VARCHAR(30),       
  hotelPolicy varchar(2000),           
  checkInInstruction varchar(2000),    
  tripAdvisorRating varchar(10),  
  checkInTime varchar(50),  
  checkOutTime varchar(50)    
  )                
   INSERT INTO @hotelResponseResult(hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType,              
          ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,              
          CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceORDER, ContractCode, hotelPolicy, checkInInstruction, tripAdvisorRating,checkInTime,checkOutTime)                 
   (SELECT * FROM vw_sabreHotelResponse               
    WHERE supplierId='hotelsCom'               
    AND hotelId Not in (SELECT HotelId FROM vw_sabreHotelResponse WHERE supplierId='sabre' AND hotelRequestKey = @hotelRequestKey              
        AND HotelName <> ''              
         AND replace(HotelName,'''','') LIKE case when @hotelName='' then '%'+ replace(@hotelName,'',HotelName) + '%' else replace(@hotelName,'',HotelName) end --'%'+ replace(@hotelName,'',HotelName) + '%'               
         AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable(replace(@hotelRatings,'',Rating)))              
         AND minRate between @minPrice AND @maxPrice              
         AND Distance between @mindistance AND @maxdistance              
         AND chaincode = CASE @chaincode WHEN 'ALL' THEN chaincode else @chaincode END)               
    AND hotelRequestKey = @hotelRequestKey              
    AND HotelName <> ''              
    AND replace(HotelName,'''','') LIKE case when @hotelName='' then '%'+ replace(@hotelName,'',HotelName) + '%' else replace(@hotelName,'',HotelName) end --'%'+ replace(@hotelName,'',HotelName) + '%'               
    AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable(replace(@hotelRatings,'',Rating)))              
    AND minRate between @minPrice AND @maxPrice              
    AND Distance between @mindistance AND @maxdistance              
    AND chaincode = CASE @chaincode WHEN 'ALL' THEN chaincode else @chaincode END              
     )               
    UNION all               
    (SELECT * FROM vw_sabreHotelResponse               
    WHERE  supplierId='sabre'                
    AND hotelRequestKey = @hotelRequestKey              
    AND HotelName <> ''              
    AND replace(HotelName,'''','') LIKE case when @hotelName='' then '%'+ replace(@hotelName,'',HotelName) + '%' else replace(@hotelName,'',HotelName) end --'%'+ replace(@hotelName,'',HotelName) + '%'               
    AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable(replace(@hotelRatings,'',Rating)))              
    AND minRate between @minPrice AND @maxPrice              
    AND Distance between @mindistance AND @maxdistance              
    AND chaincode = CASE @chaincode WHEN 'ALL' THEN chaincode else @chaincode END              
    )               
    --ORDER BY preferenceORDER, minRate,distance,Rating,HotelName ASc              
                     
     Delete @hotelResponseResult              
    FROM @hotelResponseResult t,              
    (              
     SELECT supplierHotelKey AS  supplierKey ,min(rowNum)  AS derivedhotelIdentity              
     FROM @hotelResponseResult m              
     GROUP BY  supplierHotelKey              
     having count(1) > 1              
    ) AS derived              
    WHERE t.supplierHotelKey  = derived.supplierKey AND  rowNum > derivedhotelIdentity              
              
IF @sortField = ''              
BEGIN  
print 1            
 SELECT distance,* FROM @hotelResponseResult ORDER BY 1 ASc              
END              
ELSE IF @hotelAmenities='ALL'              
BEGIN              
print 2
 SELECT * FROM @hotelResponseResult ORDER BY CASE @sortField WHEN 'Hotel' THEN HotelName WHEN 'Price' THEN minRate WHEN 'Rating' THEN Rating WHEN 'distance' THEN distance END ASC              
END              
ELSE              
BEGIN  
print 3            
 SELECT * FROM @hotelResponseResult ORDER BY CASE @sortField WHEN 'Hotel' THEN HotelName WHEN 'Price' THEN minRate WHEN 'Rating' THEN Rating WHEN 'distance' THEN distance END ASC              
END              
               
SELECT MIN (minRate)AS LowestPrice ,MAX (minRate)AS HighestPrice FROM vw_sabreHotelResponse WHERE  hotelRequestKey=@hotelRequestKey AND HotelName <> ''                
                
SELECT  Distinct MIN ( minRate) AS BestPrice,Rating AS Rating FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey GROUP BY Rating ORDER BY Rating                 
                
SELECT MIN (distance)AS Minimumdistance ,MAX (distance)AS Maximumdistance FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey       
AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))               
              
                
/***** Matrix for all brANDs AS per distance ****/                
                
                
 SELECT min(minrate) AS minRate ,chaincode ,ChainName, 0 AS mindistance ,2 AS Maxdistance,Rating  FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))               
 AND distance between 0 AND 2  GROUP BY chaincode ,chainname ,Rating                 
   UNION                 
   SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 2 AS mindistance ,5 AS Maxdistance,Rating  FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))              
 
   AND distance > 2 AND distance <5   GROUP BY chaincode ,chainname  ,Rating                
   UNION                 
 SELECT min(minrate) AS minRate  ,chaincode ,ChainName, 5 AS mindistance ,10 AS Maxdistance ,Rating FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings ))               
 AND   distance  > 5   GROUP BY chaincode ,chainname  ,Rating                
                 
 SELECT COUNT(*)AS NoOfHotels,'0-2' AS distance  FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance between 0 AND 2                  
 UNION                
 SELECT COUNT(*)AS NoOfHotels,'2-5' AS distance  FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND distance > 2 AND distance <5                
 UNION                
 SELECT COUNT(*)AS NoOfHotels,'>5' AS distance  FROM  vw_sabreHotelResponse WHERE hotelRequestKey=@hotelRequestKey AND Rating in ( SELECT * FROM vault.dbo.ufn_CSVToTable ( @hotelRatings )) AND   distance > 5                 
                  
 SELECT COUNT(*) AS [TotalCount] FROM @hotelResponseResult                 
 /****** Matrix ENDs here *****/                
 END 
GO
