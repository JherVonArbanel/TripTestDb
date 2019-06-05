SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CruiseRequests_GET]  
(  
 @tripRequestKey INT = NULL,  
 @CruiseRequestKey INT = NULL  
)  
AS  
BEGIN  
   
 IF @tripRequestKey IS NOT NULL   
 BEGIN  
  SELECT   
     CR.cruiseRequestKey
    ,CR.destinationRegionCode
	,CR.sailingDuration
	,CR.maxSailingDuration
	,CR.DepartureDate
	,CR.DepartureCityCode
	,CR.cruiseLineCode
	,CR.cruiseRequestCreated
	,CR.NoofGuests
  FROM TripRequest_Cruise   
   LEFT OUTER JOIN CruiseRequest CR ON TripRequest_Cruise.CruiseRequestKey = CR.CruiseRequestKey   
  WHERE tripRequestKey = @tripRequestKey  
 END  
 ELSE  
 BEGIN  
  SELECT   
    CR.cruiseRequestKey
    ,CR.destinationRegionCode
	,CR.sailingDuration
	,CR.maxSailingDuration
	,CR.DepartureDate
	,CR.DepartureCityCode
	,CR.cruiseLineCode
	,CR.cruiseRequestCreated
	,CR.NoofGuests
  FROM TripRequest_Cruise   
   LEFT OUTER JOIN CruiseRequest CR ON TripRequest_Cruise.CruiseRequestKey = CR.CruiseRequestKey   
  WHERE CR.CruiseRequestKey = @CruiseRequestKey  
 END  
END  
GO
