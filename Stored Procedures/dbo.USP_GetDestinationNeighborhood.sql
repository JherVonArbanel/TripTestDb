SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  <Pradeep Gupta>  
-- Create date: <26-July-2016>  
-- Description: <To Get all Neighbourhood according to destination>   
-- =============================================    
CREATE PROCEDURE [dbo].[USP_GetDestinationNeighborhood]     
     
     
 @Destination varchar(10) = null    
AS    
BEGIN    
     
 --SELECT REPLACE(Neighborhood, ' ','') as [HashTag] FROM Trip..DestinationNeighborhood where Destination = @Destination     
 --order by Destination  
   
 --select top 10 /*COUNT(RegionName) as [Count],*/RegionName,RegionId from HotelCacheRegionMapping where CityCode = 'DFW' group by RegionName,RegionId order by COUNT(RegionName) desc   
 
 select top 10 REPLACE(RegionName, ' ','')  AS [HashTag] from HotelCacheRegionMapping where CityCode = @Destination  and RegionId>0 group by RegionName,RegionId order by COUNT(RegionName) desc   
 --select top 10 REPLACE(RegionName, ' ','')  AS [HashTag] from HotelCacheRegionMapping where CityCode = @Destination group by RegionName,RegionId order by COUNT(RegionName) desc   
  
     
    
END
GO
