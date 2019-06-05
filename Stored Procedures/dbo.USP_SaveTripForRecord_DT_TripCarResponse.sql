SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripCarResponse table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_TripCarResponse]
	 @carResponseKey As uniqueidentifier ,
	 @tripKey As int ,
	 @carVendorKey As varchar(50),
	 @supplierId As varchar(50),
	 @carCategoryCode As varchar(50),
	 @carLocationCode As varchar(50),
	 @carLocationCategoryCode As varchar(50) ,
	 @minRate As float ,
	 @minRateTax As float,
	 @DailyRate As float,
	 @TotalChargeAmt As float,
	 @NoOfDays As int,
	 @SearchCarPrice As float ,
	 @searchCarTax As float ,
	 @actualCarPrice As float ,
	 @actualCarTax As float,
	 @pickUpDate As datetime,
	 @dropOutDate As datetime,
	 @recordLocator As varchar(50),
	 @confirmationNumber As varchar(50),
	 @CurrencyCodeKey As nvarchar(20) ,
	 @PolicyReasonCodeID As int ,
	 @CarPolicyKey As int
	 
AS
BEGIN
 
INSERT INTO TripCarResponse
			(carResponseKey, tripKey, carVendorKey, supplierId, carCategoryCode, carLocationCode, carLocationCategoryCode
			,minRate, minRateTax, DailyRate, TotalChargeAmt, NoOfDays, SearchCarPrice, searchCarTax, actualCarPrice, actualCarTax
			,pickUpDate, dropOutDate, recordLocator, confirmationNumber, CurrencyCodeKey, PolicyReasonCodeID, CarPolicyKey)
        Values 
			(@carResponseKey,@tripKey,@carVendorKey,@supplierId,@carCategoryCode,@carLocationCode,@carLocationCategoryCode
			,@minRate,@minRateTax,@DailyRate,@TotalChargeAmt,@NoOfDays,@SearchCarPrice,@searchCarTax,@actualCarPrice,@actualCarTax
			,@pickUpDate,@dropOutDate,@recordLocator,@confirmationNumber,@CurrencyCodeKey, @PolicyReasonCodeID, @CarPolicyKey)

END
GO
