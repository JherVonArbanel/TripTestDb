SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateTripDetailsFailedTMU] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	/*===========UPDATE NUMBER OF HOTEL ROOMS===========*/
	DECLARE @MissingHotelRooms AS TABLE
	(
		TripKey INT	
	)
	
	INSERT INTO @MissingHotelRooms
	SELECT tripKey
	FROM TripDetails WHERE tripKey in
	(
		SELECT TripKey FROM HotelRequestTripSavedDeal
	)
	AND (NoOfHotelRooms IS NULL OR NoOfHotelRooms = 0)
    
    UPDATE TD
	SET TD.NoOfHotelRooms = HR.NoOfRooms
	FROM TripDetails TD
	INNER JOIN HotelRequestTripSavedDeal HR
	ON HR.TripKey = TD.tripKey
	WHERE TD.tripKey IN
	(SELECT TripKey FROM @MissingHotelRooms)
	/*===========UPDATE NUMBER OF HOTEL ROOMS===========*/
	
	/*===========UPDATE MISSING ORIGINAL HOTEL PRICE===========*/
	DECLARE @MissingOriginalPriceTrips AS TABLE
	(
		TripKey INT		
	)
	
	INSERT INTO @MissingOriginalPriceTrips (TripKey)
	SELECT tripKey
	FROM TripDetails WHERE tripKey in
	(
		SELECT TripKey FROM HotelRequestTripSavedDeal
	)
	AND (originalPerPersonPriceHotel IS NULL OR originalTotalPriceHotel IS NULL)
		
	UPDATE TD
	SET TD.dailyPriceHotel = THR.hotelDailyPrice
	,TD.originalPerPersonDailyTotalHotel = THR.perPersonDailyTotal
	,TD.originalPerPersonPriceHotel = THR.hotelTotalPrice
	,TD.originalTotalPriceHotel = (THR.hotelTotalPrice * TD.NoOfHotelRooms)
	FROM TripDetails TD
	INNER JOIN TripHotelResponse THR
	ON THR.tripGUIDKey = TD.TripSavedKey
	WHERE TD.tripKey IN
	(SELECT TripKey FROM @MissingOriginalPriceTrips)
	/*===========UPDATE MISSING ORIGINAL HOTEL PRICE===========*/
	
	--DECLARE @MissingLatestPriceTrips AS TABLE
	--(
	--	TripKey INT		
	--)
	--SELECT tripKey
	--FROM TripDetails WHERE tripKey in
	--(
	--	SELECT TripKey FROM HotelRequestTripSavedDeal
	--)
	--AND (latestDealHotelPriceTotal IS NULL OR latestDealHotelpriceperperson IS NULL OR LatestDealHotelPricePerPersonPerDay IS NULL)
    
END
GO
