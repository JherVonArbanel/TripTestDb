SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into [TripPolicyException] table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_PolicyException]
	 @TripKey As int,
	 @TripRequestKey As int, 
	 @TimeBandTotalThresholdAmt As float ,
	 @AlternateAirportTotalThresholdAmt As float , 
	 @AdvancePurchaseAirportTotalThresholdAmt As float ,
	 @penaltyFareTotalThresholdAmt As float , 
	 @xConnectionsPolicyTotalThresholdAmt As float , 
	 @lowestPriceOfTrip As float , 
	 @ReasonCode As varchar(100), 
	 @PolicyKey As int , 
	 @ReasonDescription As nvarchar(3000) ,
     @thresholdamt As float , 
     @LowFarePolicyAmt As float , 
     @LowestAmtFromAllPolicy As float
	 
AS
BEGIN
 
INSERT INTO  TripPolicyException 
			(TripKey, TripRequestKey, TimeBandTotalThresholdAmt, AlternateAirportTotalThresholdAmt, AdvancePurchaseAirportTotalThresholdAmt
			,penaltyFareTotalThresholdAmt, xConnectionsPolicyTotalThresholdAmt, lowestPriceOfTrip, ReasonCode, PolicyKey 
			,ReasonDescription, thresholdamt, LowFarePolicyAmt, LowestAmtFromAllPolicy)
        Values 
			(@TripKey, @TripRequestKey,@TimeBandTotalThresholdAmt ,@AlternateAirportTotalThresholdAmt, @AdvancePurchaseAirportTotalThresholdAmt
            ,@penaltyFareTotalThresholdAmt   , @xConnectionsPolicyTotalThresholdAmt , @lowestPriceOfTrip, @ReasonCode, @PolicyKey
            ,@ReasonDescription ,@thresholdamt, @LowFarePolicyAmt, @LowestAmtFromAllPolicy)
			
SELECT Scope_Identity()
                    
END


GO
