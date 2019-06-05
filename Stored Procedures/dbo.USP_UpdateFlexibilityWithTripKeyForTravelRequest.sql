SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel
-- Create date: 23/Aug/2013
-- Description:	Update Trip Key in Flexibility table.
-- Exec USP_UpdateFlexibilityWithTripKeyForTravelRequest 234,131932
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateFlexibilityWithTripKeyForTravelRequest]
	-- Add the parameters for the stored procedure here
	@tripKey INT,
	@TripRequestKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Update Trip Key into AirFlexibility
    UPDATE TripAirFlexibilities
	SET tripKey = @tripKey
	WHERE airFlexibilityKey = (SELECT TOP 1 airFlexibilityKey 
								FROM TripAirFlexibilities 
							    WHERE TripRequestKey = @tripRequestKey ORDER BY 1 DESC)
	
	-- Update Trip Key into HotelFlexibility
    UPDATE TripHotelFlexibilities
	SET tripKey = @tripKey
	WHERE hotelFlexibilityKey = (SELECT TOP 1 hotelFlexibilityKey 
								FROM TripHotelFlexibilities 
							    WHERE TripRequestKey = @tripRequestKey ORDER BY 1 DESC)
							    
	-- Update Trip Key into CarFlexibility
    UPDATE TripCarFlexibilities
	SET tripKey = @tripKey
	WHERE carFlexibilityKey = (SELECT TOP 1 carFlexibilityKey 
								FROM TripCarFlexibilities 
							    WHERE TripRequestKey = @tripRequestKey ORDER BY 1 DESC)
							    
						    
END
GO
