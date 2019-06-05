SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[GET_FlixibleAirlines]      
@TripKey int      
AS      
Begin      
Select * from TripAirFlexibilities where       
airResponseKey = (select airResponseKey from TripAirResponse where tripGuidKey =      
(select case when trip.trippurchasedkey is not null       
then trip.tripPurchasedKey  else trip.tripSavedKey end from Trip where tripKey = @TripKey ))     
    
 Select * from TripHotelFlexibilities where       
hotelResponseKey in (select hotelResponseKey from TripHotelResponse where tripGuidKey =      
(select case when trip.trippurchasedkey is not null       
then trip.tripPurchasedKey  else trip.tripSavedKey end from Trip where tripKey = @TripKey))     
End
GO
