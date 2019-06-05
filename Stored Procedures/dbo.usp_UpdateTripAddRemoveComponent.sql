SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Pradeep Gupta
-- Create date: 23-Jan-17
-- Description:	for updataing TripDetails table for updating car value for showing correct TripInformation on all pages.
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateTripAddRemoveComponent]
	@carVendorCode varchar(20) = null,
	@carClass varchar(20) = null,
	@tripkey int = 0,
	@userkey  int = 0,
	@rating int = 0,
	@hotelname varchar(100) = null,
	@hotelregionname varchar(100) = null,
	@IsCar bit = 0,
	@IsHotel bit =0,
	@IsAir bit = 0
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IsAir = 1)
	BEGIN
		print 'is air present'
	END

	IF(@IsHotel = 1)
	BEGIN
		--print 'is hotel present'
			  
	   UPDATE Trip..TripDetails 
	   SET HotelRating = @rating ,HotelName = @hotelname , HotelRegionName = @hotelregionname
	   WHERE tripKey = @tripkey and userKey = @userkey
	END

	IF(@IsCar = 1)
	BEGIN
		--print 'is car present'
		UPDATE Trip..TripDetails 
		SET CarClass = @carClass, CarVendorCode = @carVendorCode 
		WHERE tripKey = @tripkey and userKey = @userkey
	END

   
END
GO
