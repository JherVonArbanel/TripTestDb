SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetAirlines_Flight]
(  
	@prefixText	VARCHAR(3)
)AS  
  
BEGIN  

	SELECT  AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority 
	FROM AirportLookup 
	WHERE AirportCode = @prefixText
	
END  

GO
