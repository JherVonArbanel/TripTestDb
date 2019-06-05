SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 22-09-2017 16:59  
-- Description: Get City information from city name and country code  
-- =============================================  
CREATE PROCEDURE [dbo].[GetCityDetailsByName]   
 -- Add the parameters for the stored procedure here  
   @cityName varchar(50),  
   @countryName varchar(50)  
   
AS  
BEGIN  
       
     SELECT Top 1 * FROM Trip..CityLookup WHERE CityName like '%' + @cityName + '%' and CountryName like '%' + @countryName + '%'  
        
END  
GO
