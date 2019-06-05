SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_CruiseResponse]
AS
SELECT CR.[CruiseResponseKey]
      ,CR.[CruiseRequestKey]
      ,CR.[CruiseLineCode]
      ,C.value AS CruiseLineName
      ,CR.[ShipCode]
      ,SP.value AS ShipName
      ,CR.[SailingDepartureDate]
      ,CR.[SailingDuration]
      ,CR.[ArrivalPort]
      ,CR.[DeparturePort]
      ,CL.CityName as DepartureCityName
      ,CR.[RegionCode]
      ,RG.value AS RegionName
      ,CR.[NoofPorts]
      ,CR.[SailingStatusCode]
      ,CR.[ModeOfTransportation]
      ,CR.[MOTCity]
      ,CR.[CurrencyQualifier]
      ,CR.[CurrencyISOCode]
      ,CR.[CruiseVoyageNo]
  FROM [Trip].[dbo].[CruiseResponse] CR
  INNER JOIN Cruise.dbo.CruiseLine C	  WITH(NOLOCK) ON C.code = CR.CruiseLineCode
  INNER JOIN Cruise.dbo.Ship SP    		  WITH(NOLOCK) ON CR.ShipCode = SP.code AND CR.CruiseLineCode = SP.CruiseLine
  INNER JOIN Cruise.dbo.Region RG    	  WITH(NOLOCK) ON RG.code = CR.RegionCode 
  INNER JOIN Vault.dbo.CityLookup CL      WITH(NOLOCK) ON CL.IataCityCode = CR.DeparturePort 
  LEFT OUTER JOIN  dbo.CruiseRequest R	  WITH(NOLOCK) ON CR.CruiseRequestKey  = R.CruiseRequestKey
  AND CR.SailingStatusCode = 'AVL' 
GO
