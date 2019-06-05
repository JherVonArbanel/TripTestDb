SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[vw_AmadeusCruiseResponse]  
as   
 Select 
R.CruiseResponseKey,  
R.CruiseLineCode,  
Cl.value CruiseLineValue,  
R.ShipCode,  
--Ship.value ShipName,  
SailingDepartureDate,  
SailingDuration,  
ArrivalPort,  
DeparturePort,  
City.value DeparturePortName,  
RegionCode,  
Region.value RegionValue,  
NoofPorts,  
SailingStatusCode,  
ModeOfTransportation,  
MOTCity,  
R.CurrencyQualifier,  
CurrencyISOCode,  
CruiseRequestKey
--,NoOfGuests 
From  --CruiseResponseDetail Detail WITH(NOLOCK)  
--inner join 
CruiseResponse R WITH(NOLOCK) --on R.CruiseLineCode=Detail.CruiseLineCode  
--inner join Cruise.dbo.Ship Ship WITH(NOLOCK) on Ship.code=Detail.ShipCode  
inner join Cruise.dbo.CruiseLine CL WITH(NOLOCK) on CL.code=R.CruiseLineCode  
inner join Cruise.dbo.Region Region WITH(NOLOCK) on Region.code=R.RegionCode  
inner join Cruise.dbo.City City WITH(NOLOCK) on City.code=R.DeparturePort  
GO
