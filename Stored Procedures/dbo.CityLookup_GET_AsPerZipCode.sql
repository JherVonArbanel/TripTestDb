SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CityLookup_GET_AsPerZipCode] 
(    
 @prefixText   VARCHAR(100), 
 @cityName   VARCHAR(100)   
)AS    
BEGIN    
    
 --DECLARE @myString VARCHAR(400)    
 --DECLARE @sCount INT    
 --DECLARE @iCount INT    
 --DECLARE @spart VARCHAR(200)     
    
 --DECLARE @tblAirportOfCity AS TABLE  
 --(    
 -- AirportName  VARCHAR(200),    
 -- CityName  VARCHAR(200),    
 -- StateCode  VARCHAR(50),    
 -- CountryCode  VARCHAR(50),    
 -- AirportCode  VARCHAR(50),    
 -- AirPriority  TINYINT,
 -- AirOrder INT          
 --)    
   
 SET @prefixText = LTRIM(RTRIM(@prefixText))  
 SET @cityName = LTRIM(RTRIM(@cityName))  
       
IF LEN(@prefixText)=3      
	BEGIN    
		--INSERT INTO @tblAirportOfCity   		   
		   SELECT CityName     
		   FROM CityLookup     
		   WHERE AirportCode = @prefixText AND CityName = @cityName
	END      
END
GO
