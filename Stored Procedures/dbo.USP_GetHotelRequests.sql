SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***********************************               
  updatedBy - Manoj Kumar Naik                 
  updated on - 16/12/2013 15:33    
  Description - Added new column TripCreationPath : To identify shopping path or deal path hotel search request(carryon)    
                
 updated on - 22/09/2017 20:28 by Manoj Kumar Naik
 Description - return with hotelAddress,lat and long with hotelRequest.
      
************************************/      
CREATE PROCEDURE [dbo].[USP_GetHotelRequests]      
(      
 @tripRequestKey  INT,      
 @hotelRequestKey INT,      
 @ByID    VARCHAR(3)      
)      
AS      
BEGIN      
      
 IF @ByID = 'NO'      
 BEGIN      
  SELECT       
   HotelRequest.hotelRequestKey,      
   HotelRequest.hotelCityCode,      
   HotelRequest.checkInDate,      
   HotelRequest.checkOutDate,      
   noOfGuests,      
   HotelRequest.HotelGroupId,      
   HotelRequest.TripCreationPath,
   HotelRequest.hotelAddress,
   HotelRequest.latitude,
   HotelRequest.longitude    
  FROM TripRequest_hotel       
   LEFT OUTER JOIN HotelRequest ON TripRequest_hotel.hotelRequestKey = HotelRequest.hotelRequestKey       
  WHERE tripRequestKey = @tripRequestKey      
 END      
 ELSE      
 BEGIN      
  SELECT       
   HotelRequest.hotelRequestKey,      
   HotelRequest.hotelCityCode,      
   HotelRequest.checkInDate,      
   HotelRequest.checkOutDate,      
   noOfGuests,      
   HotelRequest.HotelGroupId,      
   HotelRequest.hotelAddress,
   HotelRequest.latitude,
   HotelRequest.longitude,  
   null as [tripCreationPath]  
  FROM TripRequest_hotel       
   LEFT OUTER JOIN HotelRequest ON TripRequest_hotel.hotelRequestKey = HotelRequest.hotelRequestKey       
  where HotelRequest.hotelRequestKey = @hotelRequestKey      
 END      
       
END 

GO
