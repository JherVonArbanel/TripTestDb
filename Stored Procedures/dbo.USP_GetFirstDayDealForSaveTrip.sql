SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
-- =============================================  
-- Author:  Jayant Guru  
-- Create date: 25th October 2013  
-- Description: Gets data for first day of save trip  
-- =============================================  
--EXEC USP_GetFirstDayDealForSaveTrip 225866, 'WN', 1, 0, 0, 3  
--exec USP_GetFirstDayDealForSaveTrip @travelRequestID=161480,@excludedAirlines=N'WN',@isFlightSelected=0,@isCarSelected=0,@isHotelSelected=1,@fromPage=2,@hotelStarRatingForTripSummary=4,@noOfAirStopsForTripSummary=0,@carTypeForTripSummary=N'',@responseKey='3EEEA8D6-96FF-4527-A322-B994D58A48E5'  
--exec USP_GetFirstDayDealForSaveTrip @travelRequestID=244562,@excludedAirlines=N'WN',@isFlightSelected=0,@isCarSelected=0,@isHotelSelected=1,@fromPage=3  
  
--USP_GetFirstDayDealForSaveTrip 394393 ,'WN' ,1,0, 0, 2 ,0 ,0.0 ,1 ,'' ,'eed6bbb9-b7ea-44b5-bfff-350a44436925'  
--USP_GetFirstDayDealForSaveTrip 491662 ,'WN' ,0,0, 1, 3 ,0 ,5.0 ,0 ,'' ,'00000000-0000-0000-0000-000000000000'  
  
CREATE PROCEDURE [dbo].[USP_GetFirstDayDealForSaveTrip]   
   
 @travelRequestID as INT  
 ,@excludedAirlines AS VARCHAR (200) = ''  
 ,@isFlightSelected AS BIT  
 ,@isCarSelected AS BIT  
 ,@isHotelSelected AS BIT   
 ,@fromPage AS INT /*-Follow Deal Page => 1  
      -Trip Summary Page => 2  
      -Get Deals/Home Page => 3*/  
 --Applicable when called from Trip Summary page  
 ,@isSeo BIT = 0  
 ,@hotelStarRatingForTripSummary FLOAT = 0  
 ,@noOfAirStopsForTripSummary INT = 0  
 ,@carTypeForTripSummary CHAR = ''  
 ,@responseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'  
   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
 /*Variable Declaration*/  
 DECLARE @leadComponentType INT = 0  
   ,@airRequestId INT     
   ,@hotelRequestId INT     
   ,@carRequestId INT     
   ,@hotelGroupId INT  
   ,@noOfAirStops INT  
   ,@starRating FLOAT  
   ,@hotelRegionId FLOAT  
   ,@carType VARCHAR(10)  
 /*END - Variable Declaration*/  
    
 /*Setting lead component type  
 As "1" is for follow deal,   
 we dont need to set lead component type. Follow deal will always   
 return 1 travel option for each component*/  
 IF @fromPage <> 1  
 BEGIN  
  IF(@isHotelSelected = 1)  
  BEGIN  
   SET @leadComponentType = 4 --Hotel  
  END  
 ELSE IF(@isFlightSelected = 1)  
  BEGIN  
   SET @leadComponentType = 1 --Air  
  END  
 ELSE  
  BEGIN  
   SET @leadComponentType = 2 --Car  
  END  
 END  
 /*END - Setting lead component type*/   
   
 /*Setting RequestID for each Component*/  
 IF (@isFlightSelected = 1)   
 BEGIN  
  IF(@fromPage = 2)  
  BEGIN  
   INSERT INTO TripAirFlexibilities (noofStops, TripRequestKey, airResponseKey)  
   VALUES (@noOfAirStopsForTripSummary, @travelRequestID, '00000000-0000-0000-0000-000000000000')  
  END  
  SET @airRequestID = (SELECT airRequestKey FROM TripRequest_air   
        WITH(NOLOCK) WHERE tripRequestKey = @travelRequestID)    
 END  
    
 IF (@isHotelSelected = 1)   
 BEGIN  
  IF(@fromPage = 2 OR @fromPage = 3)  
  BEGIN  
   INSERT INTO TripHotelFlexibilities (altHotelRating, TripRequestKey, hotelResponseKey)  
   VALUES (@hotelStarRatingForTripSummary, @travelRequestID, '00000000-0000-0000-0000-000000000000')  
  END  
  SET @hotelRequestID = (SELECT top 1  hotelRequestkey FROM TripRequest_hotel   
          WITH(NOLOCK) WHERE tripRequestKey = @travelRequestID)    
  SET @hotelGroupId =   (SELECT tripToHotelGroupId FROM TripRequest   
          WITH(NOLOCK) WHERE tripRequestKey = @travelRequestID)  
 END   
     
 IF (@isCarSelected = 1)   
 BEGIN  
  IF(@fromPage = 2)  
  BEGIN  
   INSERT INTO TripCarFlexibilities (flexibleCarType, TripRequestKey, carResponseKey)  
   VALUES (@carTypeForTripSummary, @travelRequestID, '00000000-0000-0000-0000-000000000000')  
  END  
  SET @carRequestID = (SELECT TOP 1 carRequestKey  FROM TripRequest_car   
        WITH (NOLOCK) WHERE tripRequestKey = @travelRequestID ORDER BY carRequestKey DESC)    
 END  
 /*END - Setting RequestID for each Component*/  
   
 /*Setting flexibility options*/  
 SET @noOfAirStops = (SELECT TOP 1 ISNULL(noofStops,1) FROM TripAirFlexibilities   
      WITH (NOLOCK) WHERE TripRequestKey = @travelRequestID    
      ORDER BY airFlexibilityKey DESC)  
   
 SELECT TOP 1 @starRating =  altHotelRating  
    ,@hotelRegionId = RegionId  
    FROM TripHotelFlexibilities   
    WITH (NOLOCK) WHERE TripRequestKey = @travelRequestID    
    ORDER BY hotelFlexibilityKey DESC  
   
 SET @carType = (SELECT TOP 1 flexibleCarType  FROM TripCarFlexibilities   
     WITH (NOLOCK) WHERE TripRequestKey = @travelRequestID   
     ORDER BY carFlexibilityKey DESC)  
 /*END - Setting flexibility options*/  
    
 IF (@isFlightSelected = 1)  
  BEGIN  
   IF(@fromPage = 2 AND @leadComponentType <> 1)  
    BEGIN  
     SELECT AirResponse = 'CALLED FROM TRIP SUMMARY PAGE. NO DATA WILL BE NEEDED'  
     SELECT AirSegments = 'CALLED FROM TRIP SUMMARY PAGE. NO DATA WILL BE NEEDED'   
    END  
   ELSE  
    BEGIN  
     --print @airRequestID  
     --print @noOfAirStops  
     --print @leadComponentType  
     --print @responseKey  
     EXEC USP_GetFirstDayAirDealForSaveTrip @airRequestID, @noOfAirStops  
     ,@leadComponentType, @fromPage, @excludedAirlines, @responseKey   
    END  
  END  
 ELSE  
  BEGIN  
   SELECT AirResponse = 'FLIGHT NOT SELECTED'  
   SELECT AirSegments = 'FLIGHT NOT SELECTED'  
  END  
   
 IF (@isHotelSelected = 1)  
  BEGIN  
   --print @hotelRequestId  
   --print @starRating  
   --print @hotelRegionId  
   --print @fromPage  
   --print @responseKey  
   --print @hotelGroupId  
   --print @isSeo  
   EXEC USP_GetFirstDayHotelDealForSaveTrip @hotelRequestId, @starRating, @hotelRegionId, @fromPage  
   ,@responseKey, @hotelGroupId, @isSeo  
  END  
 ELSE  
  BEGIN  
   SELECT HotelResponse = 'HOTEL NOT SELECTED'  
  END  
   
 IF (@isCarSelected = 1)  
  BEGIN  
   IF(@fromPage = 2 AND @leadComponentType <> 2)  
    BEGIN  
     SELECT CarResponse = 'CALLED FROM TRIP SUMMARY PAGE. NO DATA WILL BE NEEDED'  
    END  
   ELSE  
    BEGIN       
     --select @carRequestID, @carType, @leadComponentType, @fromPage, @responseKey  
     EXEC USP_GetFirstDayCarDealForSaveTrip @carRequestID, @carType, @leadComponentType  
     ,@fromPage, @responseKey  
       
    END  
  END   
 ELSE  
  BEGIN  
   SELECT CarResponse = 'CAR NOT SELECTED'  
  END  
   
END  
GO
