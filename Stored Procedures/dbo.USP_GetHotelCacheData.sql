SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelCacheData]       
(       
@Origin varchar(5),      
@Month varchar(15),      
@TopDestinationCities varchar(max)      
)      
AS      
BEGIN      
  DECLARE @tblTopDestinations AS TABLE (Destination varchar(5))         
  INSERT @tblTopDestinations (Destination) SELECT * FROM vault.dbo.ufn_CSVToTable(@TopDestinationCities)        
      
 IF (@TopDestinationCities IS NOT NULL) AND (@Month IS NOT NULL)      
 BEGIN      
  --SELECT FilteredCacheData FROM HotelCacheData H      
  SELECT CacheData as [FilteredCacheData] FROM HotelCacheData H      
  INNER JOIN @tblTopDestinations T ON H.Origin = T.Destination AND [MONTH] = @Month      
  ORDER BY LowestPrice       
 END      
 ELSE IF (@TopDestinationCities IS NOT NULL)      
 BEGIN    
  SELECT FilteredCacheData,Origin,MONTH,LowestPrice FROM HotelCacheData H      
  INNER JOIN @tblTopDestinations T ON H.Origin = T.Destination 
  AND H.LowestPrice = (SELECT MIN(LowestPrice) FROM HotelCacheData WHERE Origin = H.Origin)      
  ORDER BY LowestPrice       
  --ORDER BY H.Origin, H.Id  
 END      
 ELSE IF ((@TopDestinationCities IS NULL) AND @Origin IS NOT NULL AND @Month IS NOT NULL)      
 BEGIN      
  --SELECT top 1 FilteredCacheData FROM HotelCacheData WHERE (Origin = @Origin AND [MONTH] = @Month)ORDER BY LowestPrice       
   SELECT top 1 CacheData as [FilteredCacheData] FROM HotelCacheData WHERE (Origin = @Origin AND [MONTH] = @Month)ORDER BY LowestPrice       
 END      
 ELSE IF ((@TopDestinationCities IS NULL) AND @Origin IS NOT NULL AND @Month IS NULL)      
 BEGIN     
   SELECT FilteredCacheData FROM HotelCacheData WHERE Origin = @Origin       
   ORDER BY id ASC    
   --ORDER BY LowestPrice      
 END      
 ELSE IF ((@TopDestinationCities IS NULL) AND @Origin IS NULL AND @Month IS NOT NULL)      
 BEGIN      
  --SELECT top 1 FilteredCacheData FROM HotelCacheData WHERE [MONTH] = @Month ORDER BY LowestPrice    
  SELECT top 1 CacheData as [FilteredCacheData] FROM HotelCacheData WHERE [MONTH] = @Month ORDER BY LowestPrice        
 END      
END
GO
