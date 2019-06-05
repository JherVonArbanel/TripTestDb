SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetCarCacheData]
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
	  SELECT CacheData FROM TRIP..CarCacheData C  
	  INNER JOIN @tblTopDestinations T ON C.Origin = T.Destination AND [MONTH] = @Month  
	 END  
	 ELSE IF (@TopDestinationCities IS NOT NULL)  
	 BEGIN  
	  SELECT CacheData FROM TRIP..CarCacheData C  
	  INNER JOIN @tblTopDestinations T ON C.Origin = T.Destination 
	 END  
	 ELSE IF ((@TopDestinationCities IS NULL) AND @Origin IS NOT NULL AND @Month IS NOT NULL)  
	 BEGIN  
	  SELECT CacheData FROM TRIP..CarCacheData WHERE (Origin = @Origin AND [MONTH] = @Month)
	 END  
	 ELSE IF ((@TopDestinationCities IS NULL) AND @Origin IS NOT NULL AND @Month IS NULL)  
	 BEGIN  
	   SELECT CacheData FROM TRIP..CarCacheData WHERE Origin = @Origin   
	   ORDER BY id ASC
	 END  
	 ELSE IF ((@TopDestinationCities IS NULL) AND @Origin IS NULL AND @Month IS NOT NULL)  
	 BEGIN  
	  SELECT CacheData FROM TRIP..CarCacheData WHERE [MONTH] = @Month 
	 END  
END
GO
