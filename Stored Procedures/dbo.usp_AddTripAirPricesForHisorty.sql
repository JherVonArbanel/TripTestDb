SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[usp_AddTripAirPricesForHisorty]
@PNR varchar(20)

AS

begin
declare @searchAirPriceBreakupKey int 
declare @actualAirPriceBreakupKey int 
declare @repricedAirPriceBreakupKey int 

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
creationDate,
tripInfantWithSeatBase,
tripInfantWithSeatTax 
From TripAirPrices TAP 
		Inner join TripairResponse TAR on Tap.tripAirPriceKey = TAR.searchAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR )

select @searchAirPriceBreakupKey = SCOPE_IDENTITY()

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
creationDate,
tripInfantWithSeatBase,
tripInfantWithSeatTax 
From TripAirPrices TAP 
		Inner join TripairResponse TAR on Tap.tripAirPriceKey = TAR.actualAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR )

select @actualAirPriceBreakupKey = SCOPE_IDENTITY()

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
creationDate,
tripInfantWithSeatBase,
tripInfantWithSeatTax 
From TripAirPrices TAP 
		Inner join TripairResponse TAR on Tap.tripAirPriceKey = TAR.repricedAirPriceBreakupKey 
Where tar.tripGUIDKey in (select tripPurchasedKey from Trip where recordLocator = @PNR )
select @repricedAirPriceBreakupKey = SCOPE_IDENTITY()

Select @searchAirPriceBreakupKey as searchAirPriceBreakupKey
Select @actualAirPriceBreakupKey as actualAirPriceBreakupKey
Select @repricedAirPriceBreakupKey as repricedAirPriceBreakupKey
end
GO
