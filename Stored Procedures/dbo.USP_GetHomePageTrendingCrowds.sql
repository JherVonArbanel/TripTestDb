SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  <Author,,Name>    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================    
--USP_GetHomePageTrendingCrowds  2, 1
CREATE PROCEDURE [dbo].[USP_GetHomePageTrendingCrowds] 
 @GroupNo int = 0  ,  
 @FromIndex int = 1  
AS    
BEGIN    
DECLARE @ToIndex INT = 0  
DECLARE @TrendingCrowds  TABLE (ID int IDENTITY (1,1), ImageUrl VARCHAR(5000),AirportCode VARCHAR(50),CrowdCount INT,CityName VARCHAR(150),AvgSaving FLOAT DEFAULT(0))  
 
  IF (@FromIndex) = 0
  BEGIN
  SET @FromIndex = 1
  END
  
 IF @GroupNo = 0    
 BEGIN    
  INSERT INTO @TrendingCrowds (ImageUrl,AirportCode,CrowdCount,CityName,AvgSaving)  
  SELECT  ImageUrl,AirportCode,CrowdCount,CityName,ROUND(AvgSaving,0,0) AS [AvgSaving] FROM Trip..RegionAirportGroup 
  WHERE CrowdCount >0 OR ROUND(AvgSaving,0,0) >0
  ORDER BY CrowdCount DESC, AvgSaving DESC    
 END    
 ELSE    
 BEGIN    
  INSERT INTO @TrendingCrowds (ImageUrl,AirportCode,CrowdCount,CityName,AvgSaving)  
  SELECT ImageUrl,AirportCode,CrowdCount,CityName,ROUND(AvgSaving,0,0) AS [AvgSaving] FROM Trip..RegionAirportGroup WHERE GroupNumber=@GroupNo    
  AND ( CrowdCount >0 OR ROUND(AvgSaving,0,0) >0)
  ORDER BY CrowdCount DESC, AvgSaving DESC    
 END    
  
 SET @ToIndex = @FromIndex + 19  
 SELECT  * FROM @TrendingCrowds WHERE ID BETWEEN @FromIndex AND @ToIndex  
  
     
END
GO
