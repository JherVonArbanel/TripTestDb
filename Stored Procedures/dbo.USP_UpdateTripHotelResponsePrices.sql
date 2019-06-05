SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 25th May 2015
-- Description:	Will update TripHotelResponse with prices
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateTripHotelResponsePrices]	
	@touricoTaxRate FLOAT
	,@hotelTotalPrice FLOAT
	,@dailyPrice FLOAT
	,@hotelResponseKey UNIQUEIDENTIFIER
	,@MarketMarginPercent FLOAT = 0
AS
BEGIN	
	SET NOCOUNT ON;
    
    UPDATE TripHotelResponse 
    SET hotelTaxRate = @touricoTaxRate
    ,hotelTotalPrice = @hotelTotalPrice 
    ,hotelDailyPrice = @dailyPrice
    ,MarketplaceMarginPercent = @MarketMarginPercent
    WHERE hotelResponseKey = @hotelResponseKey
    
END
GO
