SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select * from sys.objects where name like '%cruise%' order by create_date desc
CREATE VIEW [dbo].[vw_TripCruiseResponse]
AS  
SELECT Cruise.[CruiseResponseKey] 
	  ,tripKey 
	  ,confirmationNumber
	  ,recordLocator
	  ,tripCruiseTotalPrice
      ,Cruise.[CruiseLineCode]  
      ,C.value AS CruiseLineName  
      ,Cruise.[ShipCode]  
      ,SP.value AS ShipName  
      ,Cruise.[SailingDepartureDate]  
      ,Cruise.[SailingDuration]  
      ,Cruise.[ArrivalPort]  
      ,Cruise.[DeparturePort]  
      ,CL.CityName as DepartureCityName  
      ,Cruise.[RegionCode]  
      ,RG.value AS RegionName 
      ,berthedCategory
	  ,shipLocation
	  ,cabinNbr
	  ,deckId ,cruise.tripGUIDKey 
  from TripCruiseResponse Cruise
  INNER JOIN Cruise.dbo.CruiseLine C  WITH(NOLOCK) ON C.code = Cruise.CruiseLineCode  
  INNER JOIN Cruise.dbo.Ship SP  WITH(NOLOCK) ON Cruise.ShipCode = SP.code  
  INNER JOIN Cruise.dbo.Region RG WITH(NOLOCK) ON RG.code = Cruise.RegionCode   
  INNER JOIN Vault.dbo.CityLookup CL WITH(NOLOCK) ON CL.IataCityCode = Cruise.DeparturePort
GO
