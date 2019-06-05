SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- EXEC AuctionAirportLookup_GET_Location 'SFO'
CREATE PROCEDURE [dbo].[AuctionAirportLookup_GET_Location]  
(  
 @AirportCode VARCHAR(100)
 
)  
AS  
BEGIN  
  
 SELECT    
	AirportCode,
	AirportName,  
	CityCode,
	CityName,
	ST.StateCode,  
	ST.StateName,
	CT.CountryCode,  
	CT.CountryName     
 FROM AirportLookup AP   
 INNER JOIN vault..StateLookup ST ON AP.StateCode = ST.StateCode
 INNER JOIN  vault..CountryLookup CT ON AP.CountryCode = CT.CountryCode
 WHERE AirportCode = @AirportCode  
   
 
END  

GO
