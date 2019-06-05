SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 29th Sep 2014
-- Description:	Get's Tourico HotelTotalPrice
-- =============================================
CREATE FUNCTION [dbo].[udf_GetTouricoHotelTotalPrice] 
(
	@hotelDailyPrice FLOAT
	,@numberOfNights FLOAT
	,@hotelTax FLOAT	
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @touricoTotalCost FLOAT = 0			
    
    SET @touricoTotalCost = (@hotelDailyPrice * @numberOfNights) + @hotelTax
    
	RETURN @touricoTotalCost

END


GO
