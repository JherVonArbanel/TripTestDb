SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_GetNeighbourHoodHotelsId]   
@destination varchar (10)= null,  
@neighbourhood varchar(50) = null  
   
AS  
BEGIN  
  
DECLARE @regionId int   
  
 --select @regionId = DN.RegionId from trip..DestinationNeighborhood DN where DN.Destination = @destination and REPLACE(DN.Neighborhood,' ','') = REPLACE(@neighbourhood,' ','')     
    
 --Select RM.HotelId,RM.RegionId from trip..DestinationNeighborhood DN   
 --INNER JOIN HotelContent..RegionHotelIDMapping RM ON RM.RegionId = DN.RegionID AND Destination=@destination AND   
 --DN.RegionID=@regionId  
 ----REPLACE(DN.Neighborhood,' ','') = REPLACE('Austell - Six Flags',' ','')   
  
 
 select @regionId = HR.RegionId from trip..HotelCacheRegionMapping HR where HR.CityCode = @destination and REPLACE(hr.RegionName,' ','') = REPLACE(@neighbourhood,' ','')     
  
 select Distinct HotelId,RegionName from Trip..HotelCacheRegionMapping where RegionId = @regionId and CityCode = @destination  
   
   
 --Select RM.HotelId,RM.RegionId from trip..HotelCacheRegionMapping HR   
 --INNER JOIN HotelContent..RegionHotelIDMapping RM ON RM.RegionId = HR.RegionID AND HR.CityCode=@destination AND   
 --HR.RegionID=@regionId  
  
   
END
GO
