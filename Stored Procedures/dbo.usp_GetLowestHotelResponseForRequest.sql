SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
     
--exec usp_GetLowestHotelResponseForRequest1   91648, 2, 6135785, 0, 3    
        
CREATE PROCEDURE [dbo].[usp_GetLowestHotelResponseForRequest] (@hotelRequestID INT , @hotelRating FLOAT , @regionId INT, @hotelGroupID INT = 0    
 ,@noOfResults INT = 1    
 )        
AS         
  BEGIN        
     
     /****UNIQUIFIYING RESULTS***/
CREATE TABLE #tmpResponse 
(
ROWNUMBER int identity (1,1),
HotelResponsekey uniqueidentifier ,
hotelID varchar(10),
minrate float ,
latitude float,
longitude float,
miles float 
)
INSERT  INTO #tmpResponse (HotelResponsekey,hotelID ,minrate ,latitude,longitude)
 SELECT   HotelResponsekey , HR.hotelid ,minrate,ht.Latitude,ht.Longitude  FROM HotelResponse HR  WITH (NoLOCK) 
 inner join HotelContent..Hotels HT on hr.hotelId =ht.HotelId 
 where hotelRequestKey =@hotelRequestID  ORDER BY minrate 
 
 
 
DELETE FROM #tmpResponse WHERE ROWNUMBER NOT IN 
 (
 SELECT MIN(RowNumber) ROWID  FROM #tmpResponse GROUP BY hotelID )
 
 IF (@regionId > 0 ) 
 BEGIN 
 DECLARE @regionLat AS FLOAT 
 DECLARE @regionLong AS FLOAT 
 
 SELECT @regionLat = CenterLatitude ,@regionLong =CenterLongitude   FROM HotelContent..RegionCenterCoordinatesList WHERE regionId =@regionId 
 
 UPDATE #tmpResponse SET miles = HotelContent.dbo.fnGetDistance(@regionLat, @regionLong, Latitude,  Longitude, 'Miles') 
 END
  
  
 --  DECLARE @hotelDetails AS TABLE       
 --(  
 --hotelResponseKey uniqueidentifier,      
 --hotelRequestKey int,      
 --supplierHotelKey varchar(50),      
 --supplierId varchar(50),      
 --minRate float,      
 --minRateTax float,      
 --hotelsComType nchar(20),      
 --preferenceOrder int,      
 --corporateCode varchar(30),      
 --orignalMinRate float,      
 --tripAdvisorRating varchar (10),      
 --tripAdvisorRatingUrl varchar(100),      
 --tripAdvisorReviewCount int,      
 --cityCode varchar(10),      
 --hotelId varchar(50),      
 --lowRate float,      
 --highRate float,      
 --hotelSequence int      
 --)      
      
 --INSERT @hotelDetails       
 --SELECT DISTINCT HR.* ,    
 --CASE WHEN (ISNULL(HGM.HotelSequence,0) = 0) THEN 2 WHEN (ISNULL(HGM.HotelSequence,0) > 10) THEN 1 ELSE HGM.HotelSequence END      
 --FROM HotelResponse HR  
 --INNER JOIN #tmpResponse T on HR.hotelResponseKey = T.HotelResponsekey 
 --LEFT OUTER JOIN       
 --CMS..CustomHotelGroupMapping HGM on HR.hotelId = HGM.HotelId       
 --AND HGM.HotelGroupId = case WHEN @hotelGroupID = 0 then HGM.HotelGroupId ELSE @hotelGroupId        END
 --WHERE hotelRequestKey = @hotelRequestID       
  
-- DECLARE @pricesort bit        
      
--SELECT @pricesort = pricesortorder from [CMS].[dbo].[CustomHotelGroup] WHERE hotelgroupid = @hotelGroupId        
       
DECLARE @hotelResponse AS TABLE (hotelResponseKey  UNIQUEIDENTIFIER , ID INT identity (1,1))        
 
 DECLARE @minRating AS Float = 0 
 DECLARE @MaxRating AS float = 5
 IF ( @hotelRating <  5 ) 
 BEGIN
 SELECT @minRating = @hotelRating  ,@MaxRating = @hotelRating + 2 
  
 END     
 
 ELSE IF (@hotelRating = 5)
 BEGIN 
 SELECT @minRating = @hotelRating-1  ,@MaxRating = @hotelRating  
 END 
  
  
 IF ( @regionID > 0   )     ---When region id and hotel rating is specified > 0     
 BEGIN 
 
   
    
    INSERT @hotelResponse        
   SELECT DISTINCT top (@noOfResults)   hotelResponseKey    
   FROM     
   (    
   SELECT  top (@noOfResults) HotelResponsekey   FROM #tmpResponse  HR         
   inner join HotelContent.dbo.Hotels AS HT ON HT.HotelId = HR.HotelId         
   INNER JOIN HotelContent..RegionHotelIDMapping HC on HT.HotelId = HC.HotelId
   WHERE HT.Rating between  @minRating AND @MaxRating AND RegionId =@regionId        
   AND hotelResponseKey NOT IN (SELECT hotelResponseKey from @hotelResponse )  
   ORDER BY  
   CASE WHEN @hotelRating = 5 THEN Rating END DESC ,
   CASE WHEN @hotelRating < 5 THEN Rating END ASC ,   
   minRate ASC  
   )  T   
   
    DECLARE @newCount INT = 0 
   
   IF ( SELECT COUNT(*) FROM @hotelResponse ) < @noOfResults 
   BEGIN 
 SET @newCount = @noOfResults -  ( SELECT COUNT(*) FROM @hotelResponse )
   
       
	    
	   
   INSERT @hotelResponse        
   SELECT DISTINCT TOP   (@newCount) hotelResponseKey    
   FROM     
   (    
	   SELECT TOP  (@newCount)  hotelResponseKey  FROM #tmpResponse  HR         
	   inner join HotelContent.dbo.Hotels AS HT ON HT.HotelId = HR.HotelId         
	   WHERE HT.Rating between  @minRating AND @MaxRating         
	   AND hotelResponseKey NOT IN (SELECT hotelResponseKey from @hotelResponse )	    	     
	   ORDER BY    
	   CASE WHEN @hotelRating = 5 THEN Rating END DESC ,
	   CASE WHEN @hotelRating < 5 THEN Rating END ASC ,  
	   miles ASC , 
	   minRate ASC     
   )  T  
   END
   
 END      
  
 ELSE IF ( @regionID = 0 AND @HotelRating > 0 )    --Region is not specified and hotel rating is  specified     
 BEGIN         
   INSERT @hotelResponse        
    SELECT DISTINCT TOP   (@noOfResults) hotelResponseKey    
   FROM     
   (     SELECT TOP  (@noOfResults)  hotelResponseKey  FROM #tmpResponse  HR         
   inner join HotelContent.dbo.Hotels AS HT ON HT.HotelId = HR.HotelId         
   AND HT.Rating between  @minRating AND @MaxRating         
   AND hotelResponseKey NOT IN (SELECT hotelResponseKey from @hotelResponse )  
   ORDER BY    
   CASE WHEN @hotelRating = 5 THEN Rating END DESC ,
   CASE WHEN @hotelRating < 5 THEN Rating END ASC ,  
   minRate ASC
   )T
 
 END
    
 
  
 
 SELECT   DISTINCT top (@noOfResults )       
       HR.hotelResponseKey, HR.supplierHotelKey, HR.hotelRequestKey, HR.supplierId, HR.minRate, HT.HotelName, HT.Rating, HT.RatingType, HT.ChainCode, HT.HotelId,       
                      HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, HT.FaxNumber, ISNULL(HR.cityCode,       
                      HT.CityCode) AS cityCode, ISNULL(AH.Distance, 3) AS Distance, HQ.checkInDate, HQ.checkOutDate, REPLACE(HD.HotelDescription, '', '') AS HotelDescription,       
                      HC.ChainName, HR.minRateTax, ISNULL(HotelContent.dbo.HotelImages.SupplierImageURL, CHI.ImageURL) AS ImageURL, HR.preferenceOrder, HR.corporateCode,       
                      --dbo.HotelDescription.hotelPolicy, dbo.HotelDescription.checkInInstruction, HT.reviewRating AS tripAdvisorRating, dbo.HotelDescription.checkInTime,       
                      --dbo.HotelDescription.checkOutTime,     
                      HT.richMediaUrl, ID, HM.RegionId
 FROM         dbo.HotelResponse AS HR   inner join @hotelResponse  VW ON VW.hotelResponseKey = HR.hotelResponseKey 
				INNER JOIN HotelContent.dbo.Hotels AS HT ON HR.HotelId = HT.HotelId
				INNER JOIN HotelContent.dbo.SupplierHotels1 AS SH ON (SH.SupplierHotelId = HR.supplierHotelKey AND SH.SupplierFamily = HR.supplierId AND HR.hotelId = SH.HotelId )
				LEFT OUTER JOIN      
				-- dbo.HotelDescription ON dbo.HotelDescription.hotelResponseKey = HR.hotelResponseKey LEFT OUTER JOIN      
				HotelContent.dbo.HotelImages ON HotelContent.dbo.HotelImages.HotelId = HT.HotelId AND HotelContent.dbo.HotelImages.ImageType = 'Exterior' LEFT OUTER JOIN      
				HotelContent.dbo.AirportHotels AS AH ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN      
				dbo.HotelRequest AS HQ ON HR.hotelRequestKey = HQ.hotelRequestKey LEFT OUTER JOIN      
				HotelContent.dbo.HotelDescriptions AS HD ON SH.HotelId = HD.HotelId LEFT OUTER JOIN      
				HotelContent.dbo.HotelChains AS HC ON HT.ChainCode = HC.ChainCode LEFT OUTER JOIN      
				CMS.dbo.CustomHotelImages AS CHI ON CHI.HotelId = HT.HotelId AND CHI.OrderId = 1  
				LEFT OUTER JOIN HotelContent..RegionHotelIDMapping HM on HM.HotelId = HT.HotelId    
				WHERE SH.IsDeleted = 0    
				ORDER BY ID ASC         
     
  END    
  DROP TABLE #tmpResponse
GO
