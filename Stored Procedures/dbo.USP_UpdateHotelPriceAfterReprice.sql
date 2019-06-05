SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE PROCEDURE [dbo].[USP_UpdateHotelPriceAfterReprice]
(
@hotelResponseKey uniqueidentifier, 
@hotelDailyPrice float,
@hotelRatePlanCode varchar(50),
@hotelRoomTypeCode VARCHAR(50),
@hotelTotalPrice float,
@hotelTaxRate float,
@guaranteeCode nchar(10),
@creationDate DateTime,
@originalHotelTotalPrice float
)
AS 
BEGIN
UPDATE TripHotelResponse
SET hotelDailyPrice = @hotelDailyPrice,
	hotelRatePlanCode = @hotelRatePlanCode,
	hotelRoomTypeCode = @hotelRoomTypeCode,
	hotelTotalPrice = @hotelTotalPrice,
	hotelTaxRate = @hotelTaxRate,
	guaranteeCode = @guaranteeCode,
	creationDate = @creationDate,
	originalHotelTotalPrice = @originalHotelTotalPrice
WHERE hotelResponseKey = @hotelResponseKey
END
 

GO
