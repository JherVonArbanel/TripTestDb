SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripHotelResponse table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_TripHotelResponse]
	 @hotelResponseKey As uniqueidentifier ,
	 @supplierHotelKey As varchar(50) ,
	 @tripKey As int,
	 @supplierId As varchar(50),
	 @minRate As float ,
	 @minRateTax As float,
	 @hotelDailyPrice As float,
	 @hotelDescription As varchar(500),
	 @hotelRatePlanCode As varchar(50) ,
	 @hotelTotalPrice As float,
	 @hotelPriceType As int,
	 @hotelTaxRate As float,
	 @rateDescription As varchar(100) ,
	 @guaranteeCode As nchar(20) ,
	 @SearchHotelPrice As float,
	 @searchHotelTax As float,
	 @actualHotelPrice As float,
	 @actualHotelTax As float,
	 @checkInDate As datetime,
	 @checkOutDate As datetime,
	 @recordLocator As varchar(50),
	 @confirmationNumber As varchar(50),
	 @CurrencyCodeKey As nvarchar(20) ,
	 @PolicyReasonCodeID As int ,
	 @HotelPolicyKey As int
	 
AS
BEGIN
 
INSERT INTO Trip.dbo.TripHotelResponse
		(hotelResponseKey, supplierHotelKey, tripKey  ,supplierId,minRate,minRateTax,hotelDailyPrice,hotelDescription,hotelRatePlanCode
        ,hotelTotalPrice,hotelPriceType,hotelTaxRate,rateDescription,guaranteeCode,SearchHotelPrice,searchHotelTax,actualHotelPrice
        ,actualHotelTax,checkInDate,checkOutDate,recordLocator,confirmationNumber,CurrencyCodeKey,PolicyReasonCodeID,HotelPolicyKey)
      Values
		(@hotelResponseKey,@supplierHotelKey,@tripKey,@supplierId,@minRate,@minRateTax,@hotelDailyPrice,@hotelDescription,@hotelRatePlanCode
		,@hotelTotalPrice,@hotelPriceType,@hotelTaxRate,@rateDescription,@guaranteeCode,@SearchHotelPrice,@searchHotelTax,@actualHotelPrice
		,@actualHotelTax,@checkInDate,@checkOutDate,@recordLocator,@confirmationNumber,@CurrencyCodeKey,@PolicyReasonCodeID,@HotelPolicyKey)

END

GO
