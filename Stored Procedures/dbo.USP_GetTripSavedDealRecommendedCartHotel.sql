SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
-- =============================================  
-- Author:  Vivek Upadhyay  
-- Create date: 09th February 2017  
-- Description: Gets hotel deal for save trip created
-- EXEC USP_GetTripSavedDealRecommendedCartHotel '2c97e3f6-4c15-427d-9b68-b00f8e8dc2c4', 3.5, 2, 0  
-- =============================================  

CREATE PROC [dbo].[USP_GetTripSavedDealRecommendedCartHotel]
(
@hotelResponseKey UNIQUEIDENTIFIER,
@starRating FLOAT,
@fromPage INT = 2,
@isSeo FLOAT = 0
)
AS
BEGIN
SET NOCOUNT ON;

DECLARE @hotelRequestKey INT = 0
SET @hotelRequestKey = (SELECT hotelRequestKey FROM HotelResponse WHERE hotelResponseKey = @hotelResponseKey)
--print @hotelRequestKey
DECLARE @travelRequestKey INT = 0
IF(@hotelRequestKey > 0)
BEGIN
	SET @travelRequestKey = (SELECT tripRequestKey FROM TripRequest_hotel WHERE hotelRequestKey = @hotelRequestKey)
END
--print @travelRequestKey
DECLARE @tripToHotelGroupId INT = 0
IF(@travelRequestKey > 0)
BEGIN
	SET @tripToHotelGroupId = (SELECT tripToHotelGroupId FROM TripRequest WHERE tripRequestKey = @travelRequestKey)
END
--print @tripToHotelGroupId
EXEC USP_GetFirstDayHotelDealForSaveTrip @hotelRequestKey, @starRating, NULL, 2, @hotelResponseKey, @tripToHotelGroupId, @isSeo
--EXEC USP_GetFirstDayHotelDealForSaveTrip 157713, 3.5, null, 2  ,'2c97e3f6-4c15-427d-9b68-b00f8e8dc2c4', 323, 0  

END
GO
