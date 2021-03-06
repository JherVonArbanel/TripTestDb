SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 11 Jun 2013
-- Description:	Get min room rate
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetMinRoomRate]
	@HotelResponseKey UniqueIdentifier
	--,@SiteEnvironment Varchar(20)
	--,@TripKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT TOP 1 * FROM vw_hotelDetailedResponse1 where hotelResponseKey = @HotelResponseKey ORDER BY minRate ASC
	
	--Declare @MinimumPrice Float
	--		,@HotelResponseDetailKey UniqueIdentifier
	--		,@NoOfDays Int
	--		,@NoOfRooms Int
	--		--,@TripKey Int
	--		,@HotelPolicy Varchar(2000)
	--		,@CheckInInstruction Varchar(2000)
	
	--If(@SiteEnvironment = 'PRODUCTION')
	--Begin
	--	Select Top 1 @MinimumPrice = hotelTotalPrice, @HotelResponseDetailKey = hotelResponseDetailKey 
	--	From HotelResponseDetail With (NoLock) Where hotelResponseKey = @HotelResponseKey 
	--	And (rateDescription Not Like ('%A A A%') And rateDescription Not Like ('%AAA%') And rateDescription Not Like ('%SENIOR%') 
	--	And rateDescription Not Like ('%GOV%'))
	--	Order By hotelTotalPrice Asc
	--End
	--Else
	--Begin
	--	Select Top 1 @MinimumPrice = hotelTotalPrice, @HotelResponseDetailKey = hotelResponseDetailKey 
	--	From HotelResponseDetail With (NoLock) Where hotelResponseKey = @HotelResponseKey 
	--	And (rateDescription Not Like ('%A A A%') AND rateDescription Not Like ('%AAA%') AND rateDescription Not Like ('%SENIOR%') 
	--	AND rateDescription Not Like ('%GOV%')) And guaranteeCode <> 'D'
	--	Order By hotelTotalPrice Asc
	--End
	
	
		
	--	Select Top 1 @HotelPolicy = hotelPolicy, @CheckInInstruction = checkInInstruction From HotelDescription With (NoLock) 
	--	Where hotelResponseKey = @HotelResponseKey Order By hotelPolicy Desc
			
	--	Set @NoOfDays = (Select Top 1 DATEDIFF(day, CONVERT(VARCHAR(10), checkInDate, 120), CONVERT(VARCHAR(10), checkOutDate, 120)) 
	--	From TripHotelResponse With (NoLock) Where hotelResponseKey = @HotelResponseKey)
		
	--	--Set @TripKey = (Select Top 1 tripKey From TripSavedDeals Where responseKey = @HotelResponseKey)
	--	Set @NoOfRooms = (Select noOfRooms From Trip Where tripKey = @TripKey)
			
	--	UPDATE T  SET  supplierHotelKey = HD.supplierHotelKey, supplierId = HD.supplierId, hotelTotalPrice = HD.hotelTotalPrice 
	--	,hotelDailyPrice = HD.hotelDailyPrice, hotelTaxRate = HD.hotelTaxRate, hotelRatePlanCode = HD.hotelRatePlanCode 
	--	,rateDescription = HD.rateDescription,guaranteeCode = hd.guaranteeCode, hotelDescription = CASE WHEN HD.roomDescription 
	--	IS NULL OR HD.roomDescription = '' THEN HD.hotelDescription ELSE HD.roomDescription END, SupplierType = HD.hotelsComSupplierType
	--	,salesTaxAndHotelOccupancyTax = HD.salesTaxAndHotelOccupancyTax,originalHotelTotalPrice = HD.originalHotelTotalPrice
	--	,cancellationPolicy = HD.CancellationPolicy, roomDescriptionShort = CASE WHEN HD.roomDescriptionShort IS NULL OR HD.roomDescriptionShort = '' 
	--	THEN HD.hotelDescription ELSE HD.roomDescriptionShort END
	--	From TripHotelResponse T 
	--	Inner Join  HotelResponseDetail HD ON t.hotelResponseKey = HD.hotelResponseKey  
	--	AND HD.hotelResponseDetailKey = @HotelResponseDetailKey
			
		
END
GO
