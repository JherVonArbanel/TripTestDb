SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateNightlyHotelDetails]
	-- Add the parameters for the stored procedure here
	@HotelResponseKey UniqueIdentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @MinimumPrice Float
			,@HotelResponseDetailKey UniqueIdentifier
	
	Select Top 1 @MinimumPrice = hotelTotalPrice, @HotelResponseDetailKey = hotelResponseDetailKey 
	From HotelResponseDetail Where hotelResponseKey = @HotelResponseKey
	Order By hotelTotalPrice Asc
	
	Update NightlyDealProcess Set currentPrice = @MinimumPrice,responseDetailKey = @HotelResponseDetailKey 
	Where responseKey = @HotelResponseKey
	
END
GO
