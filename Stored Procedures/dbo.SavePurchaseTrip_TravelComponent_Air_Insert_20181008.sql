SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <16th Aug 17>
-- Description:	<To Insert Air Travelcomponent>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TravelComponent_Air_Insert_20181008]
	-- Add the parameters for the stored procedure here
	@xmldata XML, @TripPurchaseKey uniqueidentifier, @tripId int, @TripPassenger SavePurchaseTrip_TripPassenger Readonly
AS
BEGIN
	DECLARE @airResponseKey uniqueidentifier, @actualAirPriceBreakupKey int, @repricedAirPriceBreakupKey int, @searchAirPriceBreakupKey int
	set @airResponseKey = NEWID()
	CREATE TABLE #output (id int, category nvarchar(50))
		declare @xmlTripAirPrices xml
		select @xmlTripAirPrices = @xmldata.query('/Air/TripAirPrices')
	INSERT INTO #output EXEC [dbo].[SavePurchaseTrip_TripAirPrices_Insert] @xmlTripAirPrices, @airResponseKey
		
	select @actualAirPriceBreakupKey = [id] from #output where category = 'Actual'
	select @repricedAirPriceBreakupKey = [id] from #output where category = 'Reprice'
	select @searchAirPriceBreakupKey = [id] from #output where category = 'Search'
	
	INSERT INTO [TripAirResponse]([airResponseKey], [tripGUIDKey], [searchAirPrice], [searchAirTax], [actualAirPrice], [actualAirTax], [CurrencyCodeKey],
					[bookingcharges], [appliedDiscount], actualAirPriceBreakupKey, repricedAirPriceBreakupKey, searchAirPriceBreakupKey, repricedAirPrice,
					repricedAirTax, isSplit, agentWareQueryID, agentwareItineraryID,redeemPoints,redeemAuthNumber) 				 
	SELECT @airResponseKey, @TripPurchaseKey,
	  TripAirResponse.value('(searchAirPrice/text())[1]','float') AS searchAirPrice,
	  TripAirResponse.value('(searchAirTax/text())[1]','float') AS searchAirTax,
	  TripAirResponse.value('(actualAirPrice/text())[1]','float') AS actualAirPrice,
	  TripAirResponse.value('(actualAirTax/text())[1]','float') AS actualAirTax,
	  TripAirResponse.value('(CurrencyCodeKey/text())[1]','VARCHAR(10)') AS CurrencyCodeKey,
	  TripAirResponse.value('(bookingcharges/text())[1]','float') AS bookingcharges,
	  TripAirResponse.value('(appliedDiscount/text())[1]','float') AS appliedDiscount,
	  @actualAirPriceBreakupKey, @repricedAirPriceBreakupKey, @searchAirPriceBreakupKey,
	  TripAirResponse.value('(repricedAirPrice/text())[1]','float') AS repricedAirPrice,
	  TripAirResponse.value('(repricedAirTax/text())[1]','float') AS repricedAirTax,	  
	  TripAirResponse.value('(isSplit/text())[1]','bit') AS isSplit,
	  TripAirResponse.value('(agentWareQueryID/text())[1]','VARCHAR(30)') AS agentWareQueryID,
	  TripAirResponse.value('(agentwareItineraryID/text())[1]','VARCHAR(30)') AS agentwareItineraryID,
 	  TripAirResponse.value('(redeemPoints/text())[1]','int') AS redeemPoints ,
   	  TripAirResponse.value('(redeemAuthNumber/text())[1]','VARCHAR(100)') AS redeemAuthNumber   
	FROM @xmldata.nodes('/Air/TripAirResponse')AS TEMPTABLE(TripAirResponse)
	
	declare @xmlTripAirLegs xml
	select @xmlTripAirLegs = @xmldata.query('/Air/TripAirResponse/TripAirLegs')	
	EXEC [dbo].[SavePurchaseTrip_TripAirLegs_Insert] @xmlTripAirLegs, @airResponseKey, @TripPassenger			
	
	--INSERT INTO  TripAirSegmentOptionalServices (tripKey, serviceStatus, airSegmentKey, [description], descriptionDetail, icon, subcode,
	--									serviceAmount, method, serviceType, ReasonCode, [type], bookingInstructions, serviceCode, attributes)
	--SELECT @tripId,	
	--	TripAirSegmentOptionalService.value('(serviceStatus/text())[1]','VARCHAR(100)') AS serviceStatus,
	--	TripAirSegmentOptionalService.value('(airSegmentKey/text())[1]','VARCHAR(100)') AS airSegmentKey,
	--	TripAirSegmentOptionalService.value('(description/text())[1]','VARCHAR') AS descript,
	--	TripAirSegmentOptionalService.value('(descriptionDetail/text())[1]','VARCHAR') AS descriptionDetail,
	--	TripAirSegmentOptionalService.value('(icon/text())[1]','VARCHAR(50)') AS icon,
	--	TripAirSegmentOptionalService.value('(subcode/text())[1]','VARCHAR(50)') AS subcode,
	--	TripAirSegmentOptionalService.value('(serviceAmount/text())[1]','float') AS serviceAmount,
	--	TripAirSegmentOptionalService.value('(method/text())[1]','VARCHAR(10)') AS method,
	--	TripAirSegmentOptionalService.value('(serviceType/text())[1]','VARCHAR(50)') AS serviceType,
	--	TripAirSegmentOptionalService.value('(ReasonCode/text())[1]','VARCHAR(50)') AS ReasonCode,
	--	TripAirSegmentOptionalService.value('(type/text())[1]','VARCHAR(50)') AS [type],
	--	TripAirSegmentOptionalService.value('(bookingInstructions/text())[1]','VARCHAR(200)') AS bookingInstructions,
	--	TripAirSegmentOptionalService.value('(serviceCode/text())[1]','VARCHAR(50)') AS serviceCode,
	--	TripAirSegmentOptionalService.value('(attributes/text())[1]','VARCHAR(500)') AS attributes
	--FROM @xmldata.nodes('/Air/TripAirResponse/TripAirLegs/TripAirSegments/TripAirSegment/TripAirSegmentOptionalServices/TripAirSegmentOptionalService')AS TEMPTABLE(TripAirSegmentOptionalService)
	
	
	 Declare @TripPolicyRowCount int =0

	select @TripPolicyRowCount = count(*) from TripPolicyException where TripKey=@tripId

	if(isnull(@TripPolicyRowCount,0)=0)
	begin
	
	INSERT INTO  TripPolicyException (TripKey, TripRequestKey, TimeBandTotalThresholdAmt, AlternateAirportTotalThresholdAmt, 
		AdvancePurchaseAirportTotalThresholdAmt, penaltyFareTotalThresholdAmt, xConnectionsPolicyTotalThresholdAmt, lowestPriceOfTrip, ReasonCode, 
		PolicyKey, ReasonDescription, thresholdamt, LowFarePolicyAmt, LowestAmtFromAllPolicy, TripPassengerInfoKey, TripHistoryKey)	
	SELECT	@tripId,
		TripPolicyException.value('(TripRequestKey/text())[1]','int') AS TripRequestKey,
		TripPolicyException.value('(TimeBandTotalThresholdAmt/text())[1]','float') AS TimeBandTotalThresholdAmt,
		TripPolicyException.value('(AlternateAirportTotalThresholdAmt/text())[1]','float') AS AlternateAirportTotalThresholdAmt,
		TripPolicyException.value('(AdvancePurchaseAirportTotalThresholdAmt/text())[1]','float') AS AdvancePurchaseAirportTotalThresholdAmt,
		TripPolicyException.value('(penaltyFareTotalThresholdAmt/text())[1]','float') AS penaltyFareTotalThresholdAmt,
		TripPolicyException.value('(xConnectionsPolicyTotalThresholdAmt/text())[1]','float') AS xConnectionsPolicyTotalThresholdAmt,
		TripPolicyException.value('(lowestPriceOfTrip/text())[1]','float') AS lowestPriceOfTrip,
		TripPolicyException.value('(ReasonCode/text())[1]','VARCHAR(100)') AS ReasonCode,
		TripPolicyException.value('(PolicyKey/text())[1]','int') AS PolicyKey,
		TripPolicyException.value('(ReasonDescription/text())[1]','VARCHAR(3000)') AS ReasonDescription,
		TripPolicyException.value('(thresholdamt/text())[1]','float') AS thresholdamt,
		TripPolicyException.value('(LowFarePolicyAmt/text())[1]','float') AS LowFarePolicyAmt,
		TripPolicyException.value('(LowestAmtFromAllPolicy/text())[1]','float') AS LowestAmtFromAllPolicy,
		@tripId,
		TripPolicyException.value('(TripHistoryKey/text())[1]','VARCHAR(100)') AS TripHistoryKey  
	FROM @xmldata.nodes('/Air/TripAirResponse/TripPolicyExceptions/TripPolicyException')AS TEMPTABLE(TripPolicyException)--TripPolicyException.value('(tripPassengerInfoKey/text())[1]','int') AS tripPassengerInfoKey,
	end
	
	Declare @TripAirFlexibilityRowCount int =0

	select @TripAirFlexibilityRowCount = count(*) from [TripAirFlexibilities] where TripKey=@tripId

	if(isnull(@TripAirFlexibilityRowCount,0)=0)
	begin
	
	INSERT INTO [TripAirFlexibilities](airResponseKey,airCarrierOption,flexibleTime,noofStops,isAltAirpot)
	SELECT @airResponseKey, 
	  TripAirFlexibilities.value('(airCarrierOption/text())[1]','VARCHAR(4000)') AS airCarrierOption,  
	  TripAirFlexibilities.value('(flexibleTime/text())[1]','VARCHAR(100)') AS flexibleTime,
	  TripAirFlexibilities.value('(noofStops/text())[1]','int') AS noofStops,  
	  TripAirFlexibilities.value('(isAltAirpot/text())[1]','bit') AS isAltAirpot  
	FROM @xmldata.nodes('/Air/TripAirResponse/TripAirFlexibilities')AS TEMPTABLE(TripAirFlexibilities)
	end
END
GO
