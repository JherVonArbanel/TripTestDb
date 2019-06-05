SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <21st Aug 17>
-- Description:	<To Insert Car Travelcomponent>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TravelComponent_CAR_Insert]
	-- Add the parameters for the stored procedure here
	@xmldata XML, @TripPurchaseKey uniqueidentifier,@tripId int, @TripPassenger SavePurchaseTrip_TripPassenger Readonly
AS
BEGIN
	--DECLARE @carResponseKey uniqueidentifier
	--set @carResponseKey = NEWID()
	
	INSERT INTO TripCarResponse(carResponseKey, tripGUIDKey, carVendorKey, supplierId, carCategoryCode, carLocationCode, carLocationCategoryCode,
					carDropOffLocationCode,	carDropOffLocationCategoryCode, minRate, minRateTax, DailyRate, TotalChargeAmt, NoOfDays, SearchCarPrice,
					searchCarTax, actualCarPrice, actualCarTax, pickUpDate, dropOutDate, recordLocator, confirmationNumber, CurrencyCodeKey, PolicyReasonCodeId,
					CarPolicyKey, contractCode, TripPassengerInfoKey, rateTypeCode, OperationTimeStart, OperationTimeEnd, PickupLocationInfo,
					carRules, RPH, InvoiceNumber, MileageAllowance, PhoneNumber,PickupAddress,DropAddress,RequestType)
	SELECT TripCarResponse.value('(carResponseKey/text())[1]','VARCHAR(50)') AS carResponseKey, @TripPurchaseKey,
		TripCarResponse.value('(carVendorKey/text())[1]','VARCHAR(50)') AS carVendorKey,
		TripCarResponse.value('(supplierId/text())[1]','VARCHAR(50)') AS supplierId,
		TripCarResponse.value('(carCategoryCode/text())[1]','VARCHAR(50)') AS carCategoryCode,
		TripCarResponse.value('(carLocationCode/text())[1]','VARCHAR(50)') AS carLocationCode,
		TripCarResponse.value('(carLocationCategoryCode/text())[1]','VARCHAR(50)') AS carLocationCategoryCode,
		TripCarResponse.value('(carDropOffLocationCode/text())[1]','VARCHAR(50)') AS carDropOffLocationCode,
		TripCarResponse.value('(carDropOffLocationCategoryCode/text())[1]','VARCHAR(50)') AS carDropOffLocationCategoryCode,
		TripCarResponse.value('(minRate/text())[1]','float') AS minRate,
		TripCarResponse.value('(minRateTax/text())[1]','float') AS minRateTax,
		TripCarResponse.value('(DailyRate/text())[1]','float') AS DailyRate,
		TripCarResponse.value('(TotalChargeAmt/text())[1]','float') AS TotalChargeAmt,
		TripCarResponse.value('(NoOfDays/text())[1]','int') AS NoOfDays,
		TripCarResponse.value('(SearchCarPrice/text())[1]','float') AS SearchCarPrice,
		TripCarResponse.value('(searchCarTax/text())[1]','float') AS searchCarTax,
		TripCarResponse.value('(actualCarPrice/text())[1]','float') AS actualCarPrice,
		TripCarResponse.value('(actualCarTax/text())[1]','float') AS actualCarTax,
		(case when (charindex('-', TripCarResponse.value('(pickUpDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripCarResponse.value('(pickUpDate/text())[1]','VARCHAR(30)'), 103) 
			else TripCarResponse.value('(pickUpDate/text())[1]','datetime') end) AS pickUpDate,
		(case when (charindex('-', TripCarResponse.value('(dropOffDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripCarResponse.value('(dropOffDate/text())[1]','VARCHAR(30)'), 103) 
			else TripCarResponse.value('(dropOffDate/text())[1]','datetime') end) AS dropOffDate,
		TripCarResponse.value('(recordLocator/text())[1]','VARCHAR(50)') AS recordLocator,
		TripCarResponse.value('(confirmationNumber/text())[1]','VARCHAR(50)') AS confirmationNumber,
		TripCarResponse.value('(CurrencyCodeKey/text())[1]','VARCHAR(10)') AS CurrencyCodeKey,
		TripCarResponse.value('(PolicyReasonCodeId/text())[1]','int') AS PolicyReasonCodeId,
		TripCarResponse.value('(CarPolicyKey/text())[1]','int') AS CarPolicyKey,
		TripCarResponse.value('(contractCode/text())[1]','VARCHAR(50)') AS contractCode,
		P.TripPassengerInfoKey,--TripCarResponse.value('(TripPassengerInfoKey/text())[1]','int') AS TripPassengerInfoKey,
		TripCarResponse.value('(rateTypeCode/text())[1]','VARCHAR(20)') AS rateTypeCode,
		TripCarResponse.value('(OperationTimeStart/text())[1]','VARCHAR(10)') AS OperationTimeStart,
		TripCarResponse.value('(OperationTimeEnd/text())[1]','VARCHAR(10)') AS OperationTimeEnd,
		TripCarResponse.value('(PickupLocationInfo/text())[1]','VARCHAR(100)') AS PickupLocationInfo,
		TripCarResponse.value('(carRules/text())[1]','VARCHAR(2000)') AS carRules,
		TripCarResponse.value('(RPH/text())[1]','VARCHAR(2)') AS RPH,
		TripCarResponse.value('(InvoiceNumber/text())[1]','VARCHAR(20)') AS InvoiceNumber,
		TripCarResponse.value('(MileageAllowance/text())[1]','VARCHAR(10)') AS MileageAllowance,
		TripCarResponse.value('(PhoneNumber/text())[1]','VARCHAR(30)') AS PhoneNumber,
		TripCarResponse.value('(PickupAddress/text())[1]','VARCHAR(250)') AS PickupAddress,
		TripCarResponse.value('(DropAddress/text())[1]','VARCHAR(250)') AS DropAddress,
		TripCarResponse.value('(RequestType/text())[1]','VARCHAR(10)') AS RequestType		
	FROM @xmldata.nodes('/Car/TripCarResponse')AS TEMPTABLE(TripCarResponse)
		left outer join (select top 1 * from @TripPassenger) P on TripCarResponse.value('(TripPassengerInfoKey/text())[1]','int') = P.PassengerKey	
	
	Declare @TripPolicyRowCount int =0

	select @TripPolicyRowCount = count(*) from TripCarPolicyException where TripKey=@tripId

	if(isnull(@TripPolicyRowCount,0)=0)
	begin
	INSERT INTO  TripCarPolicyException (TripKey, TripRequestKey, ReasonCode, PolicyKey, ReasonDescription,lowestPriceOfTrip,LowFarePolicyAmt)	
	SELECT	@tripId,
		TripCarPolicyException.value('(TripRequestKey/text())[1]','int') AS TripRequestKey,
		TripCarPolicyException.value('(ReasonCode/text())[1]','VARCHAR(100)') AS ReasonCode,
		TripCarPolicyException.value('(PolicyKey/text())[1]','int') AS PolicyKey,
		TripCarPolicyException.value('(ReasonDescription/text())[1]','VARCHAR(3000)') AS ReasonDescription,
		TripCarPolicyException.value('(lowestPriceOfTrip/text())[1]','float') AS lowestPriceOfTrip,
		TripCarPolicyException.value('(LowFarePolicyAmt/text())[1]','float') AS LowFarePolicyAmt
	FROM @xmldata.nodes('/Car/TripCarResponse/TripCarPolicyExceptions/TripCarPolicyException')AS TEMPTABLE(TripCarPolicyException)
	end
		
	Declare @TripCarFlexibilityRowCount int =0

	select @TripCarFlexibilityRowCount = count(*) from [TripCarFlexibilities] where TripKey=@tripId

	if(isnull(@TripCarFlexibilityRowCount,0)=0)
	begin	
	INSERT INTO [TripCarFlexibilities]([carResponseKey], [carCompanies], [flexibleCarType], [carRateTypeOptions], [isOffAirpot])
	SELECT TripCarFlexibilities.value('(carResponseKey/text())[1]','VARCHAR(50)') AS carResponseKey,--@carResponseKey,
		TripCarFlexibilities.value('(carCompanies/text())[1]','VARCHAR(4000)') AS carCompanies,		 
		TripCarFlexibilities.value('(flexibleCarType/text())[1]','VARCHAR(100)') AS flexibleCarType,
		TripCarFlexibilities.value('(carRateTypeOptions/text())[1]','VARCHAR(100)') AS carRateTypeOptions,
		TripCarFlexibilities.value('(isOffAirpot/text())[1]','bit') AS isOffAirpot
	FROM @xmldata.nodes('/Car/TripCarFlexibilities')AS TEMPTABLE(TripCarFlexibilities)	
	end			
END
GO
