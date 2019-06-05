SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 

-- =============================================  
-- Author:  Jayant Guru  
-- Create date: 6th June 2013  
-- Description: To Save Hotel, Air, Car preference  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_AddFlexibilityForTravelRequest]   
 -- Add the parameters for the stored procedure here  
 @AirTripType INT = 0  
 ,@NoOfAirStops BIT = 0  
 ,@NoOfRooms INT = 0  
 ,@StarRating FLOAT = 0  
 ,@RegionId INT = 0  
 ,@NoOfCars INT = 0  
 ,@CarType VARCHAR(10) = ''  
 ,@TripRequestKey INT = 0  
 ,@TripKey INT = 0  
 ,@IsAirFlexibility BIT = 0  
 ,@IsCarFlexibility BIT = 0  
 ,@IsHotelFlexibility BIT = 0  ,
 @Responsekey uniqueidentifier = null
AS  
BEGIN  
  
 SET NOCOUNT ON;  
   
 IF(@IsAirFlexibility = 1)  
 BEGIN  
-- IF  NOT EXISTS (SELECT * FROM TripAirFlexibilities WHERE TripRequestKey =@TripRequestKey AND noofStops = @NoOfAirStops AND TripType = @AirTripType )
 --BEGIN
  INSERT INTO TripAirFlexibilities (noofStops, TripRequestKey, TripKey, TripType,airResponseKey )  
  VALUES(@NoOfAirStops, @TripRequestKey, @TripKey, @AirTripType,@Responsekey)  
-- END 
 END  
   
 IF(@IsCarFlexibility = 1)  
 BEGIN  
-- IF  NOT EXISTS (SELECT * FROM TripCarFlexibilities WHERE TripRequestKey =@TripRequestKey AND flexibleCarType = @CarType AND NoOfCars = @NoOfCars )
-- BEGIN
  INSERT INTO TripCarFlexibilities (NoOfCars, flexibleCarType, TripRequestKey, TripKey,carResponseKey)  
  VALUES (@NoOfCars, @CarType, @TripRequestKey, @TripKey,@Responsekey)  
-- END
 END  
   
 IF(@IsHotelFlexibility = 1)  
 BEGIN  
--  IF  NOT EXISTS (SELECT * FROM TripHotelFlexibilities WHERE TripRequestKey =@TripRequestKey AND NoOfRooms = @NoOfRooms AND altHotelRating = @StarRating AND RegionId = @RegionId )
-- BEGIN
  INSERT INTO TripHotelFlexibilities (NoOfRooms, altHotelRating, RegionId, TripRequestKey, TripKey,hotelResponseKey)  
  VALUES (@NoOfRooms, @StarRating, @RegionId, @TripRequestKey, @TripKey,@Responsekey)  
 --- END
 END  
  
END   
GO
