SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  <Vivek Upadhyay>    
-- Create date: <02-01-2017>    
-- Description: <After removing the itinerary from cart and again we go to add any itinerary then we will insert that info into Response table>    
--EXEC usp_InsertTripResponseForAirCarHotel '79fa06a1-4a31-4b5f-86f6-3156f92fe387','44AEEFEC-1AC7-4D8C-B15B-A35F0924FE3B',''    
-- =============================================    
CREATE PROCEDURE [dbo].[usp_InsertTripResponseForAirCarHotel]    
 -- Add the parameters for the stored procedure here    
 (    
 @tripResponseDetailKey uniqueidentifier,    
 --@tripResponseKey uniqueidentifier,    
 @tripSavedKey uniqueidentifier,    
 @tripComponentType varchar(10)  ,  
 @noofCars int =0  
 )    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
     
 DECLARE @carCount INT    
 SET @carCount = (SELECT COUNT(*) FROM TripCarResponse WHERE tripGUIDKey=@tripSavedKey)    
 DECLARE @hotelCount INT    
 SET @hotelCount = (SELECT COUNT(*) FROM TripHotelResponse WHERE tripGUIDKey=@tripSavedKey)    
     
 IF(@tripComponentType = 'Car' AND @carCount = 0)    
 BEGIN    
    INSERT INTO TripCarResponse    
    (    
    carResponseKey,    
 tripKey,    
 tripGUIDKey,    
 carVendorKey,    
 supplierId,    
 carCategoryCode,    
 carLocationCode,    
 carLocationCategoryCode,    
 minRate,    
 minRateTax,    
 DailyRate,    
 TotalChargeAmt,    
 NoOfDays,    
 SearchCarPrice,    
 searchCarTax,    
 actualCarPrice,    
 actualCarTax,    
 pickUpDate,    
 dropOutDate,    
 recordLocator,    
 confirmationNumber,    
 CurrencyCodeKey,    
 --PolicyReasonCodeID,    
 --CarPolicyKey,    
 --PolicyResaonCode,    
 --isExpenseAdded,    
 --status,    
 --isDeleted,    
 contractCode,    
 --creationDate,    
 TripPassengerInfoKey,    
 rateTypeCode,    
 carRules,    
 OperationTimeStart,    
 OperationTimeEnd,    
 PickupLocationInfo,    
 --isOnlineBooking,    
 InvoiceNumber,    
 MileageAllowance,    
 RPH,    
 PhoneNumber,    
 carDropOffLocationCode,    
 carDropOffLocationCategoryCode    
    )    
    SELECT CR.carResponseKey,null,@tripSavedKey,CR.carVendorKey,CR.supplierId,CR.carCategoryCode,CR.carLocationCode,CR.carLocationCategoryCode,    
    CR.minRate,CR.minRateTax,CR.DailyRate,CR.TotalChargeAmt,CR.NoOfDays,    
    CASE WHEN CRD.minRate > 0 AND CRD.NoOfDays > 0 THEN CRD.minRate * CRD.NoOfDays ELSE CRD.minRate END AS SearchCarPrice,--CR.SearchCarPrice,    
    CRD.minRateTax AS searchCarTax,    
    CASE WHEN CRD.NoOfDays > 0 THEN CRD.minRate * CRD.NoOfDays ELSE CRD.minRate END AS actualCarPrice,--CR.actualCarPrice    
    CRD.minRateTax AS actualCarTax,    
    dbo.CarRequest.pickupDate,dbo.CarRequest.dropoffDate,     
 null,--CR.recordLocator,    
 '??',--CR.confirmationNumber,    
 'USD',--CR.CurrencyCodeKey,     
 '',--CR.contractCode,    
 NULL,--CR.TripPassengerInfoKey,     
 CRD.rateTypeCode,--CR.rateTypeCode,    
 CRD.carRules,    
 CR.OperationTimeStart,CR.OperationTimeEnd,CR.PickupLocationInfo,    
 '',CR.MileageAllowance,0,NULL,    
 CR.carDropOffLocationCode,CR.carDropOffLocationCategoryCode    
 FROM CarResponseDetail CRD INNER JOIN CarResponse CR ON CRD.carResponseKey = CR.carResponseKey     
 INNER JOIN dbo.CarRequest ON CR.carRequestKey = dbo.CarRequest.carRequestKey    
 WHERE CRD.carResponseDetailKey=@tripResponseDetailKey    
     
 IF EXISTS(Select hotelResponseKey from TripHotelResponse where tripGUIDKey=@tripSavedKey)    
  BEGIN    
   IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripSavedKey)    
   BEGIN    
    UPDATE Trip SET tripComponentType = 7 , noOfCars = @noofCars WHERE tripSavedKey = @tripSavedKey  /*--added by pradeep for adding noofcars when you are adding car from tripsummary/save trip page.*/  
   END    
   ELSE    
   BEGIN    
    UPDATE Trip SET tripComponentType = 6 , noOfCars = @noofCars WHERE tripSavedKey = @tripSavedKey    
   END    
  END    
 ELSE IF EXISTS(Select carResponseKey from TripCarResponse where tripGUIDKey=@tripSavedKey)    
  BEGIN    
   IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripSavedKey)    
   BEGIN    
    UPDATE Trip SET tripComponentType = 3, noOfCars = @noofCars WHERE tripSavedKey = @tripSavedKey    
   END    
   ELSE    
   BEGIN    
    UPDATE Trip SET tripComponentType = 2, noOfCars = @noofCars WHERE tripSavedKey = @tripSavedKey    
   END    
  END    
     
 END    
        
    IF(@tripComponentType = 'Hotel' AND @hotelCount = 0)    
    BEGIN    
        
    INSERT INTO Trip.dbo.TripHotelResponse    
 (    
 hotelResponseKey,supplierHotelKey,tripGUIDKey,supplierId,minRate,minRateTax,hotelDailyPrice,hotelDescription,hotelRatePlanCode,    
 hotelTotalPrice,hotelPriceType,hotelTaxRate,rateDescription,guaranteeCode,    
 SearchHotelPrice,searchHotelTax,actualHotelPrice,actualHotelTax,checkInDate,checkOutDate,recordLocator,CurrencyCodeKey,PolicyReasonCodeId,HotelPolicyKey,    
 roomAmenities,cancellationPolicy,checkInInstruction,hotelCheckInTime,hotelCheckOutTime,vendorCode,cityCode,    
 HotelPolicy,yieldManagementValueKey, SupplierType,perPersonDailyBaseCost,perPersonDailyTotal,hotelRoomTypeCode,    
 preferenceOrder,contractCode,salesTaxAndHotelOccupancyTax,originalHotelTotalPrice,InvoiceNumber,RPH,roomDescriptionShort,    
 IsPromoTrue,PromoDescription,AverageBaseRate,PromoId,MarketplaceMarginPercent,HotelId    
 )    
    SELECT HRD.hotelResponseKey,HRD.supplierHotelKey,@tripSavedKey,HRD.supplierId,0,0,HRD.hotelDailyPrice,HRD.hotelDescription,hrd.hotelRatePlanCode,    
 HRD.hotelTotalPrice,HRD.hotelPriceType,HRD.hotelTaxRate,hrd.rateDescription,HRD.guaranteeCode,    
 HRD.hotelTotalPrice,HRD.hotelTaxRate,HRD.hotelTotalPrice,HRD.hotelTaxRate,VHDR.checkInDate,VHDR.checkOutDate,NULL,'USD',0,0,    
 HRD.roomAmenities,HRD.CancellationPolicy,VHDR.checkInInstruction,VHDR.checkInTime,VHDR.checkOutTime,VHDR.ChainCode,VHDR.cityCode,    
 VHDR.hotelPolicy,hrd.yieldManagementValueKey,HRD.hotelsComSupplierType,HRD.hotelDailyPrice,HRD.hotelTotalPrice/HRD.numberOfNights,HRD.hotelRoomTypeCode,    
 HR.preferenceOrder,HR.corporateCode,HRD.salesTaxAndHotelOccupancyTax,HRD.originalHotelTotalPrice,'',0,HRD.roomDescriptionShort,    
 HRD.IsPromoTrue,HRD.PromoDescription,HRD.AverageBaseRate,HRD.PromoId,HRD.MarketplaceMarginPercent,SH.HotelId
 FROM HotelResponseDetail HRD INNER JOIN HotelResponse HR ON hrd.hotelResponseKey = HR.hotelResponseKey    
 INNER JOIN vw_hotelDetailedResponse1 VHDR ON HR.hotelResponseKey = VHDR.hotelResponseKey    
 INNER JOIN HotelContent..SupplierHotels1 SH on SH.SupplierHotelId = HRD.supplierHotelKey AND SH.SupplierFamily = HRD.supplierId
 WHERE HRD.hotelResponseDetailKey=@tripResponseDetailKey    
        
    IF EXISTS(Select carResponseKey from TripCarResponse where tripGUIDKey=@tripSavedKey)    
  BEGIN    
   IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripSavedKey)    
   BEGIN    
    UPDATE Trip SET tripComponentType = 7 WHERE tripSavedKey = @tripSavedKey    
   END    
   ELSE    
   BEGIN    
    UPDATE Trip SET tripComponentType = 6 WHERE tripSavedKey = @tripSavedKey    
   END    
  END    
 ELSE IF EXISTS(Select hotelResponseKey from TripHotelResponse where tripGUIDKey=@tripSavedKey)    
  BEGIN    
   IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripSavedKey)    
   BEGIN    
    UPDATE Trip SET tripComponentType = 5 WHERE tripSavedKey = @tripSavedKey    
   END    
   ELSE    
   BEGIN    
    UPDATE Trip SET tripComponentType = 4 WHERE tripSavedKey = @tripSavedKey    
   END    
  END    
        
    END    
END
GO
