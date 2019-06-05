SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetCruisePriceBookingResponsesForRequest] 
CREATE PROCEDURE [dbo].[USP_GetCruisePriceBookingResponsesForRequest]
( @CruiseCabinResponseKey VARCHAR(100)
 )
AS
BEGIN
	SELECT
	   [CruisePriceResponseKey]  
      ,[CruiseCabinResponseKey]  
      ,[AmountQualifierCode]  
      ,[Amount]  
      ,[PriceStatus]  
      ,ISNULL(value,code) AS [AmountQualifierDescription]  
  FROM [Trip].[dbo].[CruisePriceResponse] CP 
  LEFT JOIN [Cruise].[dbo].[PriceItem] IP ON IP.code = CP.[AmountQualifierCode]  
 where  CP.[CruiseCabinResponseKey] = @CruiseCabinResponseKey   
 AND CP.Amount > 0 

 END
GO
