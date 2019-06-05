SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [dbo].[usp_AddAirPricesForHisorty]
@PNR varchar(20),
@HistoryPNRAirResponseKey uniqueidentifier

AS
begin
declare @searchAirPriceBreakupKey int = 0 
declare @ActualAirPriceBreakupKey int = 0 
declare @repricedAirPriceBreakupKey int = 0 
if(( select ISNULL( searchAirPriceBreakupKey,0) 
		from   TripairResponse TAR 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR))  > 0 )
begin
INSERT INTO TripAirPrices (tripAdultBase,
tripAdultTax,
tripSeniorBase,
tripSeniorTax,
tripYouthBase,
tripYouthTax,
tripChildBase,
tripChildTax,
tripInfantBase,
tripInfantTax,
creationDate,
tripInfantWithSeatBase,
tripInfantWithSeatTax)

Select tripAdultBase,
tripAdultTax,
tripSeniorBase,
tripSeniorTax,
tripYouthBase,
tripYouthTax,
tripChildBase,
tripChildTax,
tripInfantBase,
tripInfantTax,
GETDATE() as creationDate ,
tripInfantWithSeatBase,
tripInfantWithSeatTax 
From TripAirPrices TAP 
		Inner join TripairResponse TAR on Tap.tripAirPriceKey = TAR.searchAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR )

select @searchAirPriceBreakupKey = @@IDENTITY

--Insert into tripAirResponseTax (
--[airResponseKey], 
--[tripAirPriceKey]  ,
--[amount],
--[designator],
--[nature],
--[description]) 

--Select 
--@HistoryPNRAirResponseKey , 
--@ActualAirPriceBreakupKey ,
--[amount],
--[designator],
--[nature],
--[description]

--From tripAirResponseTax Tap  Inner join TripairResponse TAR on Tap.[tripAirPriceKey] = TAR.searchAirPriceBreakupKey 
--Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR ) 

end 

if(( select ISNULL( actualAirPriceBreakupKey,0) 
		from   TripairResponse TAR 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR))  > 0 )
begin
Insert into TripAirPrices (tripAdultBase,
tripAdultTax,
tripSeniorBase,
tripSeniorTax,
tripYouthBase,
tripYouthTax,
tripChildBase,
tripChildTax,
tripInfantBase,
tripInfantTax,
creationDate,
tripInfantWithSeatBase,
tripInfantWithSeatTax)

Select tripAdultBase,
tripAdultTax,
tripSeniorBase,
tripSeniorTax,
tripYouthBase,
tripYouthTax,
tripChildBase,
tripChildTax,
tripInfantBase,
tripInfantTax,
GETDATE() as creationDate ,
tripInfantWithSeatBase,
tripInfantWithSeatTax 
From TripAirPrices TAP 
		Inner join TripairResponse TAR on Tap.tripAirPriceKey = TAR.actualAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR )

select @ActualAirPriceBreakupKey = @@IDENTITY 


Insert into tripAirResponseTax (
[airResponseKey], 
[tripAirPriceKey]  ,
[amount],
[designator],
[nature],
[description]) 

Select 
@HistoryPNRAirResponseKey , 
@ActualAirPriceBreakupKey ,
[amount],
[designator],
[nature],
[description]

From tripAirResponseTax Tap  Inner join TripairResponse TAR on Tap.[tripAirPriceKey] = TAR.actualAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR ) 





end

if(( select ISNULL( repricedAirPriceBreakupKey,0) 
		from   TripairResponse TAR 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR))  > 0 )
begin


Insert into TripAirPrices (tripAdultBase,
tripAdultTax,
tripSeniorBase,
tripSeniorTax,
tripYouthBase,
tripYouthTax,
tripChildBase,
tripChildTax,
tripInfantBase,
tripInfantTax,
creationDate,
tripInfantWithSeatBase,
tripInfantWithSeatTax)

Select tripAdultBase,
tripAdultTax,
tripSeniorBase,
tripSeniorTax,
tripYouthBase,
tripYouthTax,
tripChildBase,
tripChildTax,
tripInfantBase,
tripInfantTax,
GETDATE() as creationDate ,
tripInfantWithSeatBase,
tripInfantWithSeatTax 
From TripAirPrices TAP 
		Inner join TripairResponse TAR on Tap.tripAirPriceKey = TAR.repricedAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR )
select @repricedAirPriceBreakupKey = @@IDENTITY 


Insert into tripAirResponseTax (
[airResponseKey], 
[tripAirPriceKey]  ,
[amount],
[designator],
[nature],
[description]) 

Select 
@HistoryPNRAirResponseKey , 
@repricedAirPriceBreakupKey ,
[amount],
[designator],
[nature],
[description]

From tripAirResponseTax Tap  Inner join TripairResponse TAR on Tap.[tripAirPriceKey] = TAR.repricedAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR ) 


end

select @ActualAirPriceBreakupKey  as ActualAirPriceBreakupKey ,
 @searchAirPriceBreakupKey  as searchAirPriceBreakupKey ,
 @repricedAirPriceBreakupKey  as repricedAirPriceBreakupKey 
end
GO
