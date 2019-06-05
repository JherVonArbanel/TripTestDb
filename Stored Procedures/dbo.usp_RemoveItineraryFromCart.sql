SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Vivek upadhyay>  
-- Create date: <02-01-2017>  
-- Description: <To remove itineraries from Trip Summary page>  
-- EXEC usp_RemoveItineraryFromCart 33151,'Air'  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_RemoveItineraryFromCart]   
 -- Add the parameters for the stored procedure here  
 (  
 @tripKey int,  
 @componentType varchar(20)  
 )  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  -- DECLARE @tripsaveddealkey int --TFS #19499
  DECLARE @comptype int --TFS #19499
    DECLARE @tripGUIDKey uniqueidentifier;  
    SET @tripGUIDKey = (Select tripSavedKey from Trip where tripKey=@tripKey)  
      
    --------------------------------------Air Response Start-----------------------------------  
    IF(@componentType = 'Air')  
    BEGIN  
    SET @comptype = 1
    DELETE FROM TripAirResponse WHERE tripGUIDKey=@tripGUIDKey  
  IF EXISTS(Select carResponseKey from TripCarResponse where tripGUIDKey=@tripGUIDKey)  
  BEGIN  
   IF EXISTS(Select hotelResponseKey from TripHotelResponse where tripGUIDKey=@tripGUIDKey)  
   BEGIN  
    UPDATE Trip SET tripComponentType = 6 WHERE tripKey = @tripKey  
    UPDATE TripDetails SET     
    latestDealAirSavingsPerPerson = 0  
    ,latestDealAirSavingsTotal = 0  
    ,latestDealAirPricePerPerson = 0  
    ,latestDealAirPriceTotal = 0  
    ,AirRequestTypeName = NULL  
    ,AirCabin = NULL  
    --,FromCountryCode = @FromCountryCode  
    --,FromCountryName = @FromCountryName  
    --,FromStateCode = @FromStateCode  
    --,FromCityName = @FromCityName  
    --,ToCountryCode = @ToCountryCode  
    --,ToCountryName = @ToCountryName  
    --,ToStateCode = @ToStateCode  
    --,ToCityName = @ToCityName  
    ,LatestAirLineCode = NULL  
    ,LatestAirlineName = NULL  
    ,NumberOfCurrentAirStops = 0  
    ,originalPerPersonPriceAir = 0  
    ,originalTotalPriceAir = 0  
    --,CrowdId = @crowdId  
    ,lastUpdatedDate = GETDATE()  
    WHERE tripKey = @tripKey  
   END  
   ELSE  
   BEGIN  
    UPDATE Trip SET tripComponentType = 2 WHERE tripKey = @tripKey  
    UPDATE TripDetails SET     
    latestDealAirSavingsPerPerson = 0  
    ,latestDealAirSavingsTotal = 0  
    ,latestDealAirPricePerPerson = 0  
    ,latestDealAirPriceTotal = 0  
    ,AirRequestTypeName = NULL  
    ,AirCabin = NULL  
    --,FromCountryCode = @FromCountryCode  
    --,FromCountryName = @FromCountryName  
    --,FromStateCode = @FromStateCode  
    --,FromCityName = @FromCityName  
    --,ToCountryCode = @ToCountryCode  
    --,ToCountryName = @ToCountryName  
    --,ToStateCode = @ToStateCode  
    --,ToCityName = @ToCityName  
    ,LatestAirLineCode = NULL  
    ,LatestAirlineName = NULL  
    ,NumberOfCurrentAirStops = 0  
    ,originalPerPersonPriceAir = 0  
    ,originalTotalPriceAir = 0    
    ,HotelRegionName = NULL -- updating Hotel Details in Trip details table 
    ,HotelRating = 0  
    ,HotelName = NULL   
    ,HotelResponseKey = NULL  
    ,LatestHotelId = 0         
    ,LatestHotelRegionId = 0  
    ,latestDealHotelSavingsPerPerson = 0  
    ,latestDealHotelSavingsTotal = 0  
    ,latestDealHotelPricePerPerson = 0  
    ,latestDealHotelPriceTotal = 0  
    ,LatestDealHotelPricePerPersonPerDay = 0      
    ,originalPerPersonPriceHotel = 0  
    ,originalTotalPriceHotel = 0  
    ,originalPerPersonDailyTotalHotel = 0  
    ,dailyPriceHotel = 0      
    ,LatestHotelChainCode = NULL  
    ,CurrentHotelsComId = NULL  
    ,NoOfHotelRooms = 0  
    ,HotelNoOfDays = 0   
    ,lastUpdatedDate = GETDATE()  
    WHERE tripKey = @tripKey  
   END  
  END  
  ELSE IF EXISTS(Select hotelResponseKey from TripHotelResponse where tripGUIDKey=@tripGUIDKey)  
  BEGIN  
   UPDATE Trip SET tripComponentType = 4 WHERE tripKey = @tripKey  
   UPDATE TripDetails SET     
    latestDealAirSavingsPerPerson = 0  
    ,latestDealAirSavingsTotal = 0  
    ,latestDealAirPricePerPerson = 0  
    ,latestDealAirPriceTotal = 0  
    ,AirRequestTypeName = NULL  
    ,AirCabin = NULL   
    ,LatestAirLineCode = NULL  
    ,LatestAirlineName = NULL  
    ,NumberOfCurrentAirStops = 0  
    ,originalPerPersonPriceAir = 0  
    ,originalTotalPriceAir = 0    
    ,lastUpdatedDate = GETDATE() 
    ,latestDealCarSavingsPerPerson = 0  
    ,latestDealCarSavingsTotal = 0  
    ,latestDealCarPricePerPerson = 0  
    ,latestDealCarPriceTotal = 0  
    ,CarClass = NULL  
    ,CarVendorCode = NULL  
    ,originalPerPersonPriceCar = 0  
    ,originalTotalPriceCar = 0  
    ,LatestCarVendorName = NULL  
    WHERE tripKey = @tripKey  
  END  
    END  
    --------------------------------------Air Response End-----------------------------------  
      
    --------------------------------------Car Response Start-----------------------------------  
    IF(@componentType = 'Car')  
    BEGIN  
    SET @comptype = 2
 DELETE FROM TripCarResponse WHERE tripGUIDKey=@tripGUIDKey  
  IF EXISTS(Select hotelResponseKey from TripHotelResponse where tripGUIDKey=@tripGUIDKey)  
  BEGIN  
   IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripGUIDKey)  
   BEGIN  
    UPDATE Trip SET tripComponentType = 5 WHERE tripKey = @tripKey  
    UPDATE TripDetails SET      
    latestDealCarSavingsPerPerson = 0  
    ,latestDealCarSavingsTotal = 0  
    ,latestDealCarPricePerPerson = 0  
    ,latestDealCarPriceTotal = 0  
    ,CarClass = NULL  
    ,CarVendorCode = NULL  
    ,originalPerPersonPriceCar = 0  
    ,originalTotalPriceCar = 0  
    ,LatestCarVendorName = NULL  
    --,CrowdId = @crowdId  
    WHERE tripKey = @tripKey  
   END  
   ELSE  
   BEGIN  
    UPDATE Trip SET tripComponentType = 4 WHERE tripKey = @tripKey  
    UPDATE TripDetails SET      
    latestDealCarSavingsPerPerson = 0  
    ,latestDealCarSavingsTotal = 0  
    ,latestDealCarPricePerPerson = 0  
    ,latestDealCarPriceTotal = 0  
    ,CarClass = NULL  
    ,CarVendorCode = NULL  
    ,originalPerPersonPriceCar = 0  
    ,originalTotalPriceCar = 0  
    ,LatestCarVendorName = NULL  
    ,latestDealAirSavingsPerPerson = 0  --Updating Air details in Trip Details table
    ,latestDealAirSavingsTotal = 0  
    ,latestDealAirPricePerPerson = 0  
    ,latestDealAirPriceTotal = 0  
    ,AirRequestTypeName = NULL  
    ,AirCabin = NULL   
    ,LatestAirLineCode = NULL  
    ,LatestAirlineName = NULL  
    ,NumberOfCurrentAirStops = 0  
    ,originalPerPersonPriceAir = 0  
    ,originalTotalPriceAir = 0  
    --,CrowdId = @crowdId  
    ,lastUpdatedDate = GETDATE()
    WHERE tripKey = @tripKey  
   END  
  END  
  ELSE IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripGUIDKey)  
  BEGIN  
   UPDATE Trip SET tripComponentType = 1 WHERE tripKey = @tripKey  
   UPDATE TripDetails SET      
    latestDealCarSavingsPerPerson = 0  
    ,latestDealCarSavingsTotal = 0  
    ,latestDealCarPricePerPerson = 0  
    ,latestDealCarPriceTotal = 0  
    ,CarClass = NULL  
    ,CarVendorCode = NULL  
    ,originalPerPersonPriceCar = 0  
    ,originalTotalPriceCar = 0  
    ,LatestCarVendorName = NULL  
    ,HotelRegionName = NULL -- updating Hotel Details in Trip details table 
    ,HotelRating = 0  
    ,HotelName = NULL   
    ,HotelResponseKey = NULL  
    ,LatestHotelId = 0         
    ,LatestHotelRegionId = 0  
    ,latestDealHotelSavingsPerPerson = 0  
    ,latestDealHotelSavingsTotal = 0  
    ,latestDealHotelPricePerPerson = 0  
    ,latestDealHotelPriceTotal = 0  
    ,LatestDealHotelPricePerPersonPerDay = 0      
    ,originalPerPersonPriceHotel = 0  
    ,originalTotalPriceHotel = 0  
    ,originalPerPersonDailyTotalHotel = 0  
    ,dailyPriceHotel = 0      
    ,LatestHotelChainCode = NULL  
    ,CurrentHotelsComId = NULL  
    ,NoOfHotelRooms = 0  
    ,HotelNoOfDays = 0   
    ,lastUpdatedDate = GETDATE()  
    
    WHERE tripKey = @tripKey  
  END  
 END  
 --------------------------------------Car Response End-----------------------------------  
   
 --------------------------------------Hotel Response Start-----------------------------------  
 IF(@componentType = 'Hotel')  
    BEGIN  
    SET @comptype = 4
 DELETE FROM TripHotelResponse WHERE tripGUIDKey=@tripGUIDKey  
  IF EXISTS(Select carResponseKey from TripCarResponse where tripGUIDKey=@tripGUIDKey)  
  BEGIN  
   IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripGUIDKey)  
   BEGIN  
    UPDATE Trip SET tripComponentType = 3 WHERE tripKey = @tripKey  
    UPDATE TripDetails SET      
    HotelRegionName = NULL  
    ,HotelRating = 0  
    ,HotelName = NULL  
    --,fromCountryCode = @FromCountryCode  
    --,fromCountryName = @FromCountryName  
    --,fromStateCode = @FromStateCode  
    --,fromCityName = @FromCityName  
    --,toCountryCode = @ToCountryCode  
    --,toCountryName = @ToCountryName  
    --,toStateCode = @ToStateCode  
    --,toCityName = @ToCityName  
    ,HotelResponseKey = NULL  
    ,LatestHotelId = 0         
    ,LatestHotelRegionId = 0  
    ,latestDealHotelSavingsPerPerson = 0  
    ,latestDealHotelSavingsTotal = 0  
    ,latestDealHotelPricePerPerson = 0  
    ,latestDealHotelPriceTotal = 0  
    ,LatestDealHotelPricePerPersonPerDay = 0      
    ,originalPerPersonPriceHotel = 0  
    ,originalTotalPriceHotel = 0  
    ,originalPerPersonDailyTotalHotel = 0  
    ,dailyPriceHotel = 0      
    ,LatestHotelChainCode = NULL  
    ,CurrentHotelsComId = NULL  
    ,NoOfHotelRooms = 0  
    ,HotelNoOfDays = 0  
    --,CrowdId = @crowdId  
    ,lastUpdatedDate = GETDATE()  
    WHERE tripKey = @tripKey  
   END  
   ELSE  
   BEGIN  
    UPDATE Trip SET tripComponentType = 2 WHERE tripKey = @tripKey  
    UPDATE TripDetails SET      
    HotelRegionName = NULL  
    ,HotelRating = 0  
    ,HotelName = NULL  
    --,fromCountryCode = @FromCountryCode  
    --,fromCountryName = @FromCountryName  
    --,fromStateCode = @FromStateCode  
    --,fromCityName = @FromCityName  
    --,toCountryCode = @ToCountryCode  
    --,toCountryName = @ToCountryName  
    --,toStateCode = @ToStateCode  
    --,toCityName = @ToCityName  
    ,HotelResponseKey = NULL  
    ,LatestHotelId = 0         
    ,LatestHotelRegionId = 0  
    ,latestDealHotelSavingsPerPerson = 0  
    ,latestDealHotelSavingsTotal = 0  
    ,latestDealHotelPricePerPerson = 0  
    ,latestDealHotelPriceTotal = 0  
    ,LatestDealHotelPricePerPersonPerDay = 0      
    ,originalPerPersonPriceHotel = 0  
    ,originalTotalPriceHotel = 0  
    ,originalPerPersonDailyTotalHotel = 0  
    ,dailyPriceHotel = 0      
    ,LatestHotelChainCode = NULL  
    ,CurrentHotelsComId = NULL  
    ,NoOfHotelRooms = 0  
    ,HotelNoOfDays = 0  
    ,latestDealAirSavingsPerPerson = 0  --Updating Air details in Trip Details table
    ,latestDealAirSavingsTotal = 0  
    ,latestDealAirPricePerPerson = 0  
    ,latestDealAirPriceTotal = 0  
    ,AirRequestTypeName = NULL  
    ,AirCabin = NULL   
    ,LatestAirLineCode = NULL  
    ,LatestAirlineName = NULL  
    ,NumberOfCurrentAirStops = 0  
    ,originalPerPersonPriceAir = 0  
    ,originalTotalPriceAir = 0  
    --,CrowdId = @crowdId  
    ,lastUpdatedDate = GETDATE()
    WHERE tripKey = @tripKey  
   END  
  END  
  ELSE IF EXISTS(Select airResponseKey from TripAirResponse where tripGUIDKey=@tripGUIDKey)  
  BEGIN  
   UPDATE Trip SET tripComponentType = 1 WHERE tripKey = @tripKey  
   UPDATE TripDetails SET      
    HotelRegionName = NULL  
    ,HotelRating = 0  
    ,HotelName = NULL    
    ,HotelResponseKey = NULL  
    ,LatestHotelId = 0         
    ,LatestHotelRegionId = 0  
    ,latestDealHotelSavingsPerPerson = 0  
    ,latestDealHotelSavingsTotal = 0  
    ,latestDealHotelPricePerPerson = 0  
    ,latestDealHotelPriceTotal = 0  
    ,LatestDealHotelPricePerPersonPerDay = 0      
    ,originalPerPersonPriceHotel = 0  
    ,originalTotalPriceHotel = 0  
    ,originalPerPersonDailyTotalHotel = 0  
    ,dailyPriceHotel = 0      
    ,LatestHotelChainCode = NULL  
    ,CurrentHotelsComId = NULL  
    ,NoOfHotelRooms = 0  
    ,HotelNoOfDays = 0  
    --,CrowdId = @crowdId  
    ,lastUpdatedDate = GETDATE() 
    ,latestDealCarSavingsPerPerson = 0  
    ,latestDealCarSavingsTotal = 0  
    ,latestDealCarPricePerPerson = 0  
    ,latestDealCarPriceTotal = 0  
    ,CarClass = NULL  
    ,CarVendorCode = NULL  
    ,originalPerPersonPriceCar = 0  
    ,originalTotalPriceCar = 0  
    ,LatestCarVendorName = NULL 
    WHERE tripKey = @tripKey  
  END  
 END  
 --------------------------------------Hotel Response End-----------------------------------  
 
 -- added below lines for TFS #19499
 /*SELECT TOP 1  @tripsaveddealkey = TripSavedDealKey FROM Trip..TripSavedDeals WHERE tripKey=@tripKey AND componentType = @comptype */
	UPDATE Trip..TripSavedDeals
	SET componentType=0
	WHERE tripKey = @tripKey AND componentType = @comptype and Remarks='First day deal'
END
GO
