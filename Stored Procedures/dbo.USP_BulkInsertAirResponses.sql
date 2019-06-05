SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_BulkInsertAirResponses]
	@airReponses [TVP_AirResponse] READONLY
AS
BEGIN
	INSERT INTO AirResponse (airResponseKey, airSubRequestKey, airPriceBase, airPriceTax,
		gdsSourceKey, refundable, airClass, isBrandedFare, cabinClass, fareType,
		isGeneratedBundle, ValidatingCarrier, contractCode, airPriceBaseSenior,
		airPriceTaxSenior, airPriceBaseChildren, airPriceTaxChildren, airPriceBaseInfant,
		airPriceTaxInfant, airPriceBaseDisplay, airPriceTaxDisplay, airPriceBaseTotal,
		airPriceTaxTotal, airPriceBaseYouth, airPriceTaxYouth, airPriceBaseInfantWithSeat,
		airPriceTaxInfantWithSeat, isReturnFare, agentwareQueryID, agentwareItineraryID)
	SELECT airResponseKey, airSubRequestKey, airPriceBase, airPriceTax,
		gdsSourceKey, refundable, airClass,	isBrandedFare, cabinClass,
		fareType, isGeneratedBundle, ValidatingCarrier, contractCode,
		airPriceBaseSenior, airPriceTaxSenior, airPriceBaseChildren,
		airPriceTaxChildren, airPriceBaseInfant, airPriceTaxInfant, airPriceBaseDisplay,
		airPriceTaxDisplay, airPriceBaseTotal, airPriceTaxTotal, airPriceBaseYouth,
		airPriceTaxYouth, airPriceBaseInfantWithSeat, airPriceTaxInfantWithSeat,
		isReturnFare,agentwareQueryID, agentwareItineraryID
	FROM @airReponses 
END
GO
