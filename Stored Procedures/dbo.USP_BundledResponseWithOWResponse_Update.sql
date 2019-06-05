SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SELECT NEWID()

CREATE PROCEDURE [dbo].[USP_BundledResponseWithOWResponse_Update]
(
	@airResponseKey		uniqueidentifier,
	@airPriceBase		float,
	@airPriceTax		float,
	@airPriceBaseSenior	float,
	@airPriceTaxSenior	float,
	@airPriceBaseChildren	float,
	@airPriceTaxChildren	float,
	@airPriceBaseInfant	float,
	@airPriceTaxInfant	float,
	@airPriceBaseDisplay		float,
	@airPriceTaxDisplay		float,
	@airPriceBaseTotal	float,
	@airPriceTaxTotal	float,
	@airPriceBaseYouth	float,
	@airPriceTaxYouth	float,
	@airPriceBaseInfantWithSeat	float,
	@airPriceTaxInfantWithSeat	float,
	@segmentWithClasses nvarchar(max) 
)
AS
BEGIN
	IF OBJECT_ID('tempdb..#T1') IS NOT NULL  
		DROP TABLE #T1
	IF OBJECT_ID('tempdb..#T2') IS NOT NULL  
		DROP TABLE #T2
	CREATE TABLE #T1
	(
		UniqueSegmentswithClassesCombo nvarchar(1000)
	)
	CREATE TABLE #T2
	(
		segmentkey uniqueidentifier,
		class varchar(3) 
	)

	DECLARE @UniqueSegmentswithClassesCombo as VARCHAR(8000)

	UPDATE AirResponse
		SET airPriceBase = @airPriceBase,
			airPriceTax =		@airPriceTax,		
			airPriceBaseSenior = 	@airPriceBaseSenior,
			airPriceTaxSenior =	@airPriceTaxSenior, 
			airPriceBaseChildren = @airPriceBaseChildren,
			airPriceTaxChildren = 	@airPriceTaxChildren,
			airPriceBaseInfant = 	@airPriceBaseInfant,
			airPriceTaxInfant =	@airPriceTaxInfant,
			airPriceBaseDisplay = 	@airPriceBaseDisplay,
			airPriceTaxDisplay =	@airPriceTaxDisplay,
			airPriceBaseTotal =	@airPriceBaseTotal,
			airPriceTaxTotal =	@airPriceTaxTotal,
			airPriceBaseYouth =	@airPriceBaseYouth,
			airPriceTaxYouth =	@airPriceTaxYouth,
			airPriceBaseInfantWithSeat = @airPriceBaseInfantWithSeat,
			airPriceTaxInfantWithSeat = @airPriceTaxInfantWithSeat
	WHERE airResponseKey = @airResponseKey

	INSERT into #T1(UniqueSegmentswithClassesCombo)    
	SELECT * FROM vault.dbo.ufn_CSVToTable (@segmentWithClasses ) 
	
	INSERT into #T2(segmentkey,class)
	SELECT CONVERT(UNIQUEIDENTIFIER, Reverse(ParseName(Replace(Reverse(UniqueSegmentswithClassesCombo), '|', '.'), 1)))
		, Reverse(ParseName(Replace(Reverse(UniqueSegmentswithClassesCombo), '|', '.'), 2)) 
	FROM #T1
	
	UPDATE AirSegments
	SET airSegmentResBookDesigCode = class
	FROM AirSegments AirSeg
	INNER JOIN #T2
	ON #T2.segmentkey = AirSeg.airSegmentKey
		
	DROP TABLE #T1
	DROP TABLE #T2
		
END
GO
