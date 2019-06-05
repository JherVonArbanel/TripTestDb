SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_BulkInsertAirResponsesMultiBrand]
	@airReponsesMultiBrand [TVP_AirResponseMultiBrand] READONLY
AS
BEGIN
	INSERT INTO AirResponseMultiBrand(airResponseMultiBrandKey,
	airResponseKey, airSubRequestKey, airPriceBase, airPriceTax, gdsSourceKey,
	refundable, airClass, priceClassComments, airPriceClassSelected,
	cabinClass, fareType, isGeneratedBundle, ValidatingCarrier,
	contractCode, airPriceBaseSenior, airPriceTaxSenior, airPriceBaseChildren,
	airPriceTaxChildren, airPriceBaseInfant, airPriceTaxInfant, airPriceBaseDisplay,
	airPriceTaxDisplay, airPriceBaseTotal, airPriceTaxTotal, airPriceBaseYouth,
	airPriceTaxYouth, airPriceBaseInfantWithSeat, airPriceTaxInfantWithSeat,
	airCurrencyCode, isReturnFare)
	SELECT airResponseMultiBrandKey,
	airResponseKey, airSubRequestKey, airPriceBase, airPriceTax, gdsSourceKey,
	refundable, airClass, priceClassComments, airPriceClassSelected,
	cabinClass, fareType, isGeneratedBundle, ValidatingCarrier,
	contractCode, airPriceBaseSenior, airPriceTaxSenior, airPriceBaseChildren,
	airPriceTaxChildren, airPriceBaseInfant, airPriceTaxInfant, airPriceBaseDisplay,
	airPriceTaxDisplay, airPriceBaseTotal, airPriceTaxTotal, airPriceBaseYouth,
	airPriceTaxYouth, airPriceBaseInfantWithSeat, airPriceTaxInfantWithSeat,
	airCurrencyCode, isReturnFare
	FROM @airReponsesMultiBrand 
END
GO
