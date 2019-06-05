SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author : DISHA GUJAR
-- Create date : Feb/19/2013
-- Description : Get AirFlexibleType & HotelFlexibleType based on trip key.
-- Param : TripKey.
-- =============================================   
   
CREATE PROCEDURE [dbo].[usp_GetFlexibleTypeByTripKey]     
	@tripKey INT
AS    
BEGIN       
	SELECT Trip.userKey,
	CASE WHEN TAF.airResponseKey IS NULL THEN 'same' ELSE 'alt' END as airflexible,
	CASE WHEN THF.hotelResponseKey IS NULL THEN 'same' ELSE 'alt' END as hotelflexible       
	FROM  Trip
	LEFT OUTER JOIN TripAirResponse TAR WITH (NOLOCK) ON Isnull(trip.tripPurchasedKey,trip.tripSavedKey) = TAR.tripGUIDKey      
	LEFT OUTER JOIN TripAirFlexibilities TAF WITH (NOLOCK) ON TAR.airResponseKey=TAF.airResponseKey  
	LEFT OUTER JOIN TripHotelResponse THR WITH (NOLOCK) ON  THR.tripGUIDKey =
	(case when trip.trippurchasedkey is not null then trip.trippurchasedkey else trip.tripsavedkey end )
	LEFT OUTER JOIN TripHotelFlexibilities THF WITH (NOLOCK) ON THR.hotelResponseKey=THF.hotelResponseKey    
	where Trip.tripKey= @tripKey
END
GO
