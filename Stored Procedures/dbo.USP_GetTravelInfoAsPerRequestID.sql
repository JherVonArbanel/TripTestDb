SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetTravelInfoAsPerRequestID] 68973
CREATE Procedure [dbo].[USP_GetTravelInfoAsPerRequestID]            
@TravelRequestId Int            
AS            
BEGIN    
    
Declare @TripFrom Varchar(5)    
  ,@TripTo  Varchar(5)    
  ,@TripFromCity  Varchar(200)    
  ,@TripToCity  Varchar(200)    
    
Set @TripFrom = (Select tripFrom1 From TripRequest WITH (NOLOCK) Where tripRequestKey = @TravelRequestId)    
Set @TripTo = (Select tripTo1 From TripRequest WITH (NOLOCK)  Where tripRequestKey = @TravelRequestId)    
Set @TripFromCity = (Select CityName from AirportLookup WITH (NOLOCK)  Where AirportCode = @TripFrom)    
Set @TripToCity = (Select CityName from AirportLookup WITH (NOLOCK)  Where AirportCode = @TripTo)    
    
SELECT TripFromCity = @TripFromCity,TripToCity = @TripToCity,*   
FROM TripRequest   WITH (NOLOCK)  
LEFT JOIN CMS..CustomHotelGroup CHG WITH (NOLOCK)  ON TripRequest.tripToHotelGroupId = CHG.HotelGroupId   
WHERE tripRequestKey = @TravelRequestId            
         
SELECT            
AR.airRequestTypeKey ,             
TRA.tripRequestKey,            
TRA.airRequestKey,            
TRA.airRequestClassKey,            
TRA.airRequestIsNonStop,            
--TRA.airRequestAdults,            
--TRA.airRequestSeniors,            
--TRA.airRequestChildren,       
--TRA.airRequestInfant,      
--TRA.airRequestNoofTravellers,            
TRA.airRequestDepartureAirportAlternate,            
TRA.airRequestArrivalAirportAlternate,            
TRA.airRequestRefundable,            
airRequestTypeKey,            
isInternationalTrip,            
airRequestCreated , AR.isRedeem           
 FROM TripRequest_air  TRA  WITH (NOLOCK)           
   INNER JOIN AirRequest AR WITH (NOLOCK)  ON TRA.tripRequestKey = @TravelRequestId AND TRA.airRequestKey = AR.airRequestKey             
            
--SELECT ASR.* FROM AirSubRequest ASR            
--  INNER JOIN AirRequest AR ON AR.airRequestKey = ASR.airRequestKey             
--WHERE ASR.airRequestKey = 3107            
            
            
SELECT            
            
ASR.airSubRequestKey,            
ASR.airRequestKey,            
ASR.airRequestDateTypeKey,            
ASR.airRequestDepartureAirport,            
ASR.airRequestArrivalAirport,            
ASR.airRequestDepartureDate,            
ASR.airRequestDepartureDateVariance,            
ASR.airRequestArrivalDate,            
ASR.airRequestArrivalDateVariance,            
ASR.airRequestCalendarMonth,            
ASR.airRequestCalendarMinDays,            
ASR.airRequestCalendarMaxDays,            
ASR.airSubRequestLegIndex,  
ASR.groupKey            
 FROM AirSubRequest ASR WITH (NOLOCK)            
  INNER JOIN AirRequest AR WITH (NOLOCK)  ON AR.airRequestKey = ASR.airRequestKey             
  Inner JOIN TripRequest_air TAR WITH (NOLOCK)  ON TAR.airRequestKey = AR.airRequestKey             
WHERE TAR.tripRequestKey = @TravelRequestId             
            
            
            
SELECT             
  noOfGuests,            
  tripRequestKey,            
  AR.hotelRequestKey,            
  hotelCityCode,            
  checkInDate,            
  checkOutDate,            
  hotelRequestCreated,            
  hotelAddress,            
  NoofRooms,            
  noOfGuests,  
  AR.HotelGroupId            
 FROM TripRequest_hotel  TRA WITH (NOLOCK)            
   INNER JOIN HotelRequest AR WITH (NOLOCK)  ON TRA.tripRequestKey = @TravelRequestId             
   AND TRA.hotelRequestKey = AR.hotelRequestKey and TRA.tripRequestKey = @TravelRequestId            
            
            
SELECT             
  tripRequestKey,            
  carClass,            
  AR.carrequestkey,            
  pickupcitycode,            
  dropoffcitycode,            
  pickupdate,            
  dropoffdate,            
  carrequestcreated,            
  NoofCars,
  carAddress,
  longitude,
  latitude      
 FROM TripRequest_car  TRA WITH (NOLOCK)            
   INNER JOIN CarRequest AR WITH (NOLOCK)             
   ON TRA.tripRequestKey = @TravelRequestId AND TRA.carRequestKey = AR.carRequestKey             
             
             
             
   SELECT     
    [tripRequestKey]            
   ,TRA.[cruiseRequestKey]            
   ,[destinationRegionCode]          
      ,[sailingDuration]          
      ,[maxSailingDuration]          
      ,[DepartureDate]          
      ,[DepartureCityCode]          
      ,[cruiseLineCode]          
      ,[cruiseRequestCreated]          
      ,[NoofGuests]          
 FROM TripRequest_cruise  TRA WITH (NOLOCK)            
   INNER JOIN CruiseRequest AR WITH (NOLOCK)             
   ON TRA.tripRequestKey = @TravelRequestId AND TRA.cruiseRequestKey = AR.cruiseRequestKey             
        
    
SELECT     
 TRA.activityRequestKey,    
 locationId,    
 activityType,    
 activityFromDate,    
 activityToDate    
FROM TripRequest_activity TRA WITH (NOLOCK)     
INNER JOIN ActivityRequest AR  WITH (NOLOCK)   
ON TRA.tripRequestKey = @TravelRequestId AND TRA.activityRequestKey = AR.activityRequestKey     
  
SELECT PassengerTypeKey, PassengerAge FROM PassengerAge WITH(NOLOCK)  WHERE TripRequestKey =@TravelRequestId  
  
    
 END  
GO
