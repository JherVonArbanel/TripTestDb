SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetNearestAirports] 
(
@airportCode varchar(10),
@isSame bit = 0

)
AS 
DECLARE @cityForAirport AS VARCHAR (10)
select @cityForAirport =CityCode  FROM AirportLookup WITH (NOLOCK) where AirportCode =@airportCode

if @isSame = 0 
BEGIN 
SELECT  AirportName,    
  CityName,    
  StateCode,    
  CountryCode,    
  AirportCode,    
  CityCode,     
  gmt_offset,  
  Latitude,  
  Longitude   FROM AirportLookup WITH (NOLOCK) WHERE CityCode =@cityForAirport AND Preference =1 
END 
ELSE 
BEGIN 
SELECT  AirportName,    
  CityName,    
  StateCode,    
  CountryCode,    
  AirportCode,    
  CityCode,     
  gmt_offset,  
  Latitude,  
  Longitude   FROM AirportLookup WHERE AirportCode  =@airportCode AND Preference =1 
END
GO
