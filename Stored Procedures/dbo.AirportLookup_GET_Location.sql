SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[AirportLookup_GET_Location]    
(    
 @AirportCode VARCHAR(100),    
 @DepartAirportCode VARCHAR(100) = ''    
)    
AS    
BEGIN    
    
 SELECT  
  AirportName,    
  CityName,    
  StateCode,    
  CountryCode,    
  AirportCode, Latitude, Longitude,AirportKey      
 FROM AirportLookup     
 WHERE AirportCode = @AirportCode    
 AND IsVisible = 1   
     
 SELECT     
  AirportName,    
  CityName,    
  StateCode,    
  CountryCode,    
  AirportCode, Latitude, Longitude,  AirportKey      
 FROM AirportLookup     
 WHERE AirportCode = @DepartAirportCode    
 AND IsVisible = 1   
     
END 
GO
