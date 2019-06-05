SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,INSERT INTO Trip.dbo.TripHotelResponse table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveHotelBookedInformation_TripHotelResponse]
@hotelResponseKey uniqueidentifier,
@supplierHotelKey varchar(50),
@tripKey int,
@supplierId varchar(50),
@minRate float, 
@minRateTax float,
@hotelDailyPrice float,
@hotelDescription varchar(500),
@hotelRatePlanCode varchar(50),
@hotelTotalPrice float,
@hotelPriceType int,
@hotelTaxRate float,
@rateDescription varchar(100),
@guaranteeCode nchar(10),
@SearchHotelPrice float,
@searchHotelTax float,
@actualHotelPrice float,
@actualHotelTax float ,
@checkInDate datetime,
@checkOutDate datetime,
@recordLocator varchar(50),
@confirmationNumber varchar(50),
@CurrencyCodeKey nvarchar(10)

AS
BEGIN
 
INSERT INTO Trip.dbo.TripHotelResponse (hotelResponseKey,supplierHotelKey,tripKey,supplierId,minRate,minRateTax,hotelDailyPrice,hotelDescription,hotelRatePlanCode,hotelTotalPrice,hotelPriceType,hotelTaxRate,rateDescription,guaranteeCode,SearchHotelPrice,searchHotelTax,actualHotelPrice,actualHotelTax,checkInDate,checkOutDate,recordLocator,confirmationNumber,CurrencyCodeKey)Values(@hotelResponseKey,@supplierHotelKey,@tripKey,@supplierId,@minRate,@minRateTax,@hotelDailyPrice,@hotelDescription,@hotelRatePlanCode,@hotelTotalPrice,@hotelPriceType,@hotelTaxRate,@rateDescription,@guaranteeCode,@SearchHotelPrice,@searchHotelTax,@actualHotelPrice,@actualHotelTax,@checkInDate,@checkOutDate,@recordLocator,@confirmationNumber,@CurrencyCodeKey)

END
GO
