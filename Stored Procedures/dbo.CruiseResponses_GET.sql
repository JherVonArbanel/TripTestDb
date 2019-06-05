SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CruiseResponses_GET]    
( @CruiseRequestKey INT				= NULL,
  @CruiseResponseKey UNIQUEIDENTIFIER= NULL   
 )    
AS    
BEGIN    

	IF @CruiseRequestKey IS NULL
	BEGIN
      SELECT vwCruiseResponse.[CruiseResponseKey]    
      ,vwCruiseResponse.[CruiseRequestKey]    
      ,vwCruiseResponse.[CruiseLineCode]    
      ,vwCruiseResponse.[CruiseLineName]    
      ,vwCruiseResponse.[ShipCode]    
      ,vwCruiseResponse.[ShipName]    
      ,vwCruiseResponse.[SailingDepartureDate]    
      ,vwCruiseResponse.[SailingDuration]    
      ,vwCruiseResponse.[ArrivalPort]    
      ,vwCruiseResponse.[DeparturePort]    
      ,vwCruiseResponse.[DepartureCityName]    
      ,vwCruiseResponse.[RegionCode]    
      ,vwCruiseResponse.[RegionName]    
      ,vwCruiseResponse.[NoofPorts]    
      ,vwCruiseResponse.[SailingStatusCode]    
      ,vwCruiseResponse.[ModeOfTransportation]    
      ,vwCruiseResponse.[MOTCity]    
      ,vwCruiseResponse.[CurrencyQualifier]    
      ,vwCruiseResponse.[CurrencyISOCode]    
      ,vwCruiseResponse.[CruiseVoyageNo] 
	 FROM vw_CruiseResponse vwCruiseResponse    
	 INNER JOIN CruiseResponse CR ON CR.CruiseRequestKey = vwCruiseResponse.CruiseRequestKey AND Cr.CruiseResponseKey = vwCruiseResponse.CruiseResponseKey    
	 WHERE CR.CruiseResponseKey=@CruiseResponseKey  AND CR.SailingStatusCode = 'AVL'
   END
 ELSE
  BEGIN
	SELECT vwCruiseResponse.[CruiseResponseKey]    
      ,vwCruiseResponse.[CruiseRequestKey]    
      ,vwCruiseResponse.[CruiseLineCode]    
      ,vwCruiseResponse.[CruiseLineName]    
      ,vwCruiseResponse.[ShipCode]    
      ,vwCruiseResponse.[ShipName]    
      ,vwCruiseResponse.[SailingDepartureDate]    
      ,vwCruiseResponse.[SailingDuration]    
      ,vwCruiseResponse.[ArrivalPort]    
      ,vwCruiseResponse.[DeparturePort]    
      ,vwCruiseResponse.[DepartureCityName]    
      ,vwCruiseResponse.[RegionCode]    
      ,vwCruiseResponse.[RegionName]    
      ,vwCruiseResponse.[NoofPorts]    
      ,vwCruiseResponse.[SailingStatusCode]    
      ,vwCruiseResponse.[ModeOfTransportation]    
      ,vwCruiseResponse.[MOTCity]    
      ,vwCruiseResponse.[CurrencyQualifier]    
      ,vwCruiseResponse.[CurrencyISOCode]    
      ,vwCruiseResponse.[CruiseVoyageNo]    
	 FROM vw_CruiseResponse vwCruiseResponse    
	 INNER JOIN CruiseResponse CR ON CR.CruiseRequestKey = vwCruiseResponse.CruiseRequestKey AND Cr.CruiseResponseKey = vwCruiseResponse.CruiseResponseKey    
	 WHERE CR.CruiseRequestKey=@CruiseRequestKey AND CR.SailingStatusCode = 'AVL'
   END
	 
 END
GO
