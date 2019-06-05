SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  Manoj Kumar Naik    
-- Create date: 28-06-2017     
-- Description: Get Booking information for hotel by trip id or pnr    
-- =============================================    
CREATE PROCEDURE [dbo].[USP_GetBookingInfoFoHotelByTripId]    
@tripKey int =0    
    
AS    
BEGIN    
    
   SELECT TP.confirmationNumber, TH.atMerchant, TP.ItineraryNumber, TH.SupplierId, TI.PassengerEmailID  FROM Trip..Trip TR    
   INNER JOIN Trip..TripHotelResponse TH ON TH.tripGUIDKey = TR.tripPurchasedKey    
   INNER JOIN Trip..TripHotelResponsePassengerInfo TP ON TP.hotelResponsekey = TH.hotelResponseKey AND TR.tripKey = @tripKey    
   INNER JOIN Trip..TripPassengerInfo TI ON TI.TripPassengerInfoKey = TP.TripPassengerInfoKey  
    
END 

GO
