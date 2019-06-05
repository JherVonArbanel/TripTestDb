SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


  
-- =============================================    
-- Author:  Asha Bhosale   
-- Create date: 12th June 2013    
-- Description: To create blind bid based on data selected   
-- =============================================    
CREATE Procedure [dbo].[usp_GetPackagedOptionForTravelRequest]   
(  
@travelRequestID as INT ,  
@excludedAirlines AS VARCHAR( 200) =''  ,
@isFlightSelected AS BIT,
@isCarSelected AS BIT,
@isHotelSelected AS BIT,
@noOFResults AS INT  
)  
AS   
BEGIN   
 DECLARE @airRequestID AS INT   
 DECLARE @hotelRequestID AS INT   
 DECLARE @carRequestID AS INT   
 DECLARE @hotelGroupID AS INT 
 
   IF ( @isFlightSelected = 1 ) 
  BEGIN
	SET @airRequestID = (SELECT airRequestKey FROM TripRequest_air WITH (NOLOCK)WHERE tripRequestKey = @travelRequestID)  
  END
  IF ( @isHotelSelected = 1 ) 
  BEGIN
	SET @hotelRequestID = (SELECT hotelRequestkey FROM TripRequest_hotel WITH (NOLOCK) WHERE tripRequestKey = @travelRequestID)  
	SET @hotelGroupID = (SELECT tripToHotelGroupId FROM TripRequest where tripRequestKey=@travelRequestID)
  END	
  IF ( @isCarSelected = 1) 
  BEGIN
    SET @carRequestID = (SELECT carRequestKey  FROM TripRequest_car WITH (NOLOCK) WHERE tripRequestKey = @travelRequestID)  
  END
 DECLARE @noOfStops AS INT =  1   
 SET @noOfStops = (SELECT top 1 noofStops  FROM TripAirFlexibilities WITH (NOLOCK) where TripRequestKey = @travelRequestID  ORDER BY airFlexibilityKey DESC)  
 IF ( @noOfStops is null )   
 BEGIN  
  SET @noOfStops = 1   
 END   
 DECLARE @starRating AS FLOAT = 0   
 DECLARE @regionID AS INT    
 SELECT top 1 @starRating =  altHotelRating ,@regionID =RegionId  FROM TripHotelFlexibilities WITH (NOLOCK) where TripRequestKey = @travelRequestID  ORDER BY hotelFlexibilityKey DESC  
 IF ( @starRating IS Null )   
 BEGIN  
  SET @starRating = 0   
 END  
 IF ( @regionID IS NULL )  
 BEGIN   
  SET @regionID = 0   
 END  
 DECLARE @carType AS VARCHAR(20)  
 SET @carType = (SELECT top 1 flexibleCarType  FROM TripCarFlexibilities WITH (NOLOCK) where TripRequestKey = @travelRequestID ORDER BY carFlexibilityKey DESC)  
  
 EXEC usp_GetLowestAirResponseForAirRequest  @airRequestID ,@noOfStops , @excludedAirlines  
  
 EXEC usp_GetLowestHotelResponseForRequest @hotelRequestID,@starRating,@regionID ,@hotelGroupID, @noOFResults 
   
 EXEC usp_GetLowestCarResponseForRequest @carRequestID ,@carType  
  
END

GO
