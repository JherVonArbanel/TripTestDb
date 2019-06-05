SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <18th Aug 17>
-- Description:	<To Insert Hotel Travlecomponent>
-- Edited date: <2 Feb 18>
-- Description:	<To Insert Multiple Hotel Travlecomponent with unique Ids> 
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TravelComponent_Hotel_Insert]
	-- Add the parameters for the stored procedure here
	@xmldata XML, @TripPurchaseKey uniqueidentifier,@tripId int, @TripPassenger SavePurchaseTrip_TripPassenger Readonly
AS
BEGIN
	DECLARE @hotelResponseKey uniqueidentifier
	--set @hotelResponseKey = NEWID()
	--SELECT @hotelResponseKey = HotelResponse.value('(HotelResponseKey/text())[1]','VARCHAR(50)') 
	--	FROM @xmldata.nodes('/Hotel/TripHotelResponse')AS TEMPTABLE(HotelResponse)
	
	INSERT INTO TripHotelResponse (hotelResponseKey, tripGUIDKey, supplierHotelKey, supplierId, minRate, minRateTax, hotelDailyPrice, hotelDescription,
						hotelRatePlanCode, hotelTotalPrice, hotelPriceType, hotelTaxRate, rateDescription, guaranteeCode, SearchHotelPrice, searchHotelTax,
						actualHotelPrice, actualHotelTax, checkInDate, checkOutDate, recordLocator, CurrencyCodeKey, PolicyReasonCodeId, HotelPolicyKey,
						roomAmenities, cancellationPolicy, checkInInstruction, hotelCheckInTime, hotelCheckOutTime, vendorCode, cityCode, HotelPolicy,
						yieldManagementValueKey, SupplierType, perPersonDailyBaseCost, perPersonDailyTotal, hotelRoomTypeCode, preferenceOrder, contractCode,
						salesTaxAndHotelOccupancyTax, originalHotelTotalPrice, RPH, InvoiceNumber, roomDescriptionShort, IsPromoTrue, PromoDescription, 
						AverageBaseRate, PromoId, MarketplaceMarginPercent, estimatedRefundAmount, DepositAmount, HotelId,rateKey)
	SELECT TripHotelResponse.value('(HotelResponseKey/text())[1]','VARCHAR(50)') AS hotelResponseKey, 
		@TripPurchaseKey,
		TripHotelResponse.value('(supplierHotelKey/text())[1]','VARCHAR(50)') AS supplierHotelKey, 		
		TripHotelResponse.value('(supplierId/text())[1]','VARCHAR(50)') AS supplierId,
		TripHotelResponse.value('(minRate/text())[1]','float') AS minRate,
		TripHotelResponse.value('(minRateTax/text())[1]','float') AS minRateTax,
		TripHotelResponse.value('(hotelDailyPrice/text())[1]','float') AS hotelDailyPrice,
		TripHotelResponse.value('(hotelDescription/text())[1]','VARCHAR(8000)') AS hotelDescription,
		TripHotelResponse.value('(hotelRatePlanCode/text())[1]','VARCHAR(50)') AS hotelRatePlanCode,
		TripHotelResponse.value('(hotelTotalPrice/text())[1]','float') AS hotelTotalPrice,
		TripHotelResponse.value('(hotelPriceType/text())[1]','int') AS hotelPriceType,
		TripHotelResponse.value('(hotelTaxRate/text())[1]','float') AS hotelTaxRate,	  
		TripHotelResponse.value('(rateDescription/text())[1]','VARCHAR(1000)') AS rateDescription,
		TripHotelResponse.value('(guaranteeCode/text())[1]','VARCHAR(10)') AS guaranteeCode,
		TripHotelResponse.value('(SearchHotelPrice/text())[1]','float') AS SearchHotelPrice,
		TripHotelResponse.value('(searchHotelTax/text())[1]','float') AS searchHotelTax,
		TripHotelResponse.value('(actualHotelPrice/text())[1]','float') AS actualHotelPrice,
		TripHotelResponse.value('(actualHotelTax/text())[1]','float') AS actualHotelTax,
		(case when (charindex('-', TripHotelResponse.value('(checkInDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripHotelResponse.value('(checkInDate/text())[1]','VARCHAR(30)'), 103) 
			else TripHotelResponse.value('(checkInDate/text())[1]','datetime') end) AS checkInDate,
		(case when (charindex('-', TripHotelResponse.value('(checkOutDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripHotelResponse.value('(checkOutDate/text())[1]','VARCHAR(30)'), 103) 
			else TripHotelResponse.value('(checkOutDate/text())[1]','datetime') end) AS checkOutDate,
		TripHotelResponse.value('(recordLocator/text())[1]','VARCHAR(50)') AS recordLocator,
		TripHotelResponse.value('(CurrencyCodeKey/text())[1]','VARCHAR(10)') AS CurrencyCodeKey,
		TripHotelResponse.value('(PolicyReasonCodeId/text())[1]','VARCHAR(20)') AS PolicyReasonCodeId,
		TripHotelResponse.value('(HotelPolicyKey/text())[1]','int') AS HotelPolicyKey,
		TripHotelResponse.value('(roomAmenities/text())[1]','VARCHAR(2000)') AS roomAmenities,
		TripHotelResponse.value('(cancellationPolicy/text())[1]','VARCHAR(4000)') AS cancellationPolicy,
		TripHotelResponse.value('(checkInInstruction/text())[1]','VARCHAR(2000)') AS checkInInstruction,
		TripHotelResponse.value('(hotelCheckInTime/text())[1]','VARCHAR(50)') AS hotelCheckInTime,
		TripHotelResponse.value('(hotelCheckOutTime/text())[1]','VARCHAR(50)') AS hotelCheckOutTime,	  
		TripHotelResponse.value('(vendorCode/text())[1]','VARCHAR(50)') AS vendorCode,
		TripHotelResponse.value('(cityCode/text())[1]','VARCHAR(50)') AS cityCode,
		TripHotelResponse.value('(HotelPolicy/text())[1]','VARCHAR(2000)') AS HotelPolicy,
		TripHotelResponse.value('(yieldManagementValueKey/text())[1]','int') AS yieldManagementValueKey,
		TripHotelResponse.value('(SupplierType/text())[1]','VARCHAR(20)') AS SupplierType,
		TripHotelResponse.value('(perPersonDailyBaseCost/text())[1]','float') AS perPersonDailyBaseCost,	  
		TripHotelResponse.value('(perPersonDailyTotal/text())[1]','float') AS perPersonDailyTotal,
		TripHotelResponse.value('(hotelRoomTypeCode/text())[1]','VARCHAR(50)') AS hotelRoomTypeCode,
		TripHotelResponse.value('(preferenceOrder/text())[1]','int') AS preferenceOrder,
		TripHotelResponse.value('(contractCode/text())[1]','VARCHAR(50)') AS contractCode,
		TripHotelResponse.value('(salesAndOccupancyTax/text())[1]','float') AS salesAndOccupancyTax,
		TripHotelResponse.value('(originalHotelTotalPrice/text())[1]','float') AS originalHotelTotalPrice,
		TripHotelResponse.value('(RPH/text())[1]','VARCHAR(2)') AS RPH,
		TripHotelResponse.value('(InvoiceNumber/text())[1]','VARCHAR(20)') AS InvoiceNumber,
		TripHotelResponse.value('(roomDescriptionShort/text())[1]','VARCHAR(1000)') AS roomDescriptionShort,		
		TripHotelResponse.value('(IsPromoTrue/text())[1]','bit') AS IsPromoTrue,
		TripHotelResponse.value('(PromoDescription/text())[1]','VARCHAR(300)') AS PromoDescription,
		TripHotelResponse.value('(AverageBaseRate/text())[1]','float') AS AverageBaseRate,
		TripHotelResponse.value('(PromoId/text())[1]','VARCHAR(20)') AS PromoId,
		TripHotelResponse.value('(MarketplaceMarginPercent/text())[1]','float') AS MarketplaceMarginPercent,
		TripHotelResponse.value('(estimatedRefundAmount/text())[1]','float') AS estimatedRefundAmount,
		TripHotelResponse.value('(DepositAmount/text())[1]','float') AS DepositAmount,
		TripHotelResponse.value('(HotelId/text())[1]','int') AS HotelId,
		TripHotelResponse.value('(rateKey/text())[1]','VARCHAR(max)') AS rateKey
	FROM @xmldata.nodes('/Hotel/TripHotelResponse')AS TEMPTABLE(TripHotelResponse)	
	
	DECLARE @HotelSupplierId int, @Phone nvarchar(30)
	SELECT 
		@HotelSupplierId = TripHotelSupplier.value('(HotelSupplierId/text())[1]','int'), 
		@Phone = TripHotelSupplier.value('(Phone/text())[1]','VARCHAR(30)')
	FROM @xmldata.nodes('/Hotel')AS TEMPTABLE(TripHotelSupplier)
		
	EXEC [dbo].[usp_updateSabreHotelCarContentBySupplierID] @HotelSupplierId, @Phone
		
	INSERT INTO [TripHotelResponsePassengerInfo] ([hotelResponseKey],[TripPassengerInfoKey],[confirmationNumber],[ItineraryNumber])
	SELECT TripHotelResponsePassengerInfo.value('(HotelResponseKey/text())[1]','VARCHAR(50)') AS hotelResponseKey, 
		P.TripPassengerInfoKey,		
		TripHotelResponsePassengerInfo.value('(confirmationNumber/text())[1]','VARCHAR(50)') AS confirmationNumber,
		TripHotelResponsePassengerInfo.value('(ItineraryNumber/text())[1]','VARCHAR(MAX)') AS ItineraryNumber
	FROM @xmldata.nodes('/Hotel/TripHotelResponsePassengerInfos/TripHotelResponsePassengerInfo')AS TEMPTABLE(TripHotelResponsePassengerInfo)
		left outer join @TripPassenger P on TripHotelResponsePassengerInfo.value('(TripPassengerInfoKey/text())[1]','int') = P.PassengerKey
	
	
	 Declare @TripPolicyRowCount int =0

	select @TripPolicyRowCount = count(*) from TripHotelPolicyException where TripKey=@tripId

	if(isnull(@TripPolicyRowCount,0)=0)
	begin
	
	INSERT INTO  TripHotelPolicyException (TripKey, TripRequestKey, ReasonCode, PolicyKey, ReasonDescription,lowestPriceOfTrip,LowFarePolicyAmt)	
	SELECT	@tripId,
		TripHotelPolicyException.value('(TripRequestKey/text())[1]','int') AS TripRequestKey,
		TripHotelPolicyException.value('(ReasonCode/text())[1]','VARCHAR(100)') AS ReasonCode,
		TripHotelPolicyException.value('(PolicyKey/text())[1]','int') AS PolicyKey,
		TripHotelPolicyException.value('(ReasonDescription/text())[1]','VARCHAR(3000)') AS ReasonDescription,
		TripHotelPolicyException.value('(lowestPriceOfTrip/text())[1]','float') AS lowestPriceOfTrip,
		TripHotelPolicyException.value('(LowFarePolicyAmt/text())[1]','float') AS LowFarePolicyAmt
	FROM @xmldata.nodes('/Hotel/TripHotelResponse/TripHotelPolicyExceptions/TripHotelPolicyException')AS TEMPTABLE(TripHotelPolicyException)
	end

	Declare @TripHotelFlexibilityRowCount int =0

	select @TripHotelFlexibilityRowCount = count(*) from [TripHotelFlexibilities] where TripKey=@tripId

	if(isnull(@TripHotelFlexibilityRowCount,0)=0)
	begin
	INSERT INTO [TripHotelFlexibilities]([hotelResponseKey],[altHotelRating],[flexibleDistance],[HotelChain],[HotelName])
	SELECT TripHotelFlexibilities.value('(HotelResponseKey/text())[1]','VARCHAR(50)') AS hotelResponseKey,
		TripHotelFlexibilities.value('(altHotelRating/text())[1]','VARCHAR(100)') AS altHotelRating,		 
		TripHotelFlexibilities.value('(flexibleDistance/text())[1]','VARCHAR(100)') AS flexibleDistance,
		TripHotelFlexibilities.value('(HotelChain/text())[1]','VARCHAR(4000)') AS HotelChain,
		TripHotelFlexibilities.value('(HotelName/text())[1]','VARCHAR(100)') AS HotelName
	FROM @xmldata.nodes('/Hotel/TripHotelFlexibilities')AS TEMPTABLE(TripHotelFlexibilities)	
	end
					
END
GO
