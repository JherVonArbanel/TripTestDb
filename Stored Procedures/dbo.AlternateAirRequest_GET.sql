SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AlternateAirRequest_GET]    
(    
 @airRequestKey INT    
)    
AS    
BEGIN    
    
 --SELECT AirRequest.airRequestKey, AirRequest.airRequestTypeKey, TripRequest_air.airRequestClassKey,    
 -- TripRequest_air.airRequestIsNonStop,TripRequest_air.airRequestDepartureAirportAlternate,    
 -- TripRequest_air.airRequestArrivalAirportAlternate, AirRequest.isInternationalTrip, TripRequest_air.airRequestRefundable   
 --FROM TripRequest_air     
 -- LEFT OUTER JOIN AirRequest ON TripRequest_air.airRequestKey = AirRequest.airRequestKey   
 --WHERE airRequest.airRequestKey = @airRequestKey 
 DECLARE @tripRequestKey AS INT;
 SELECT @tripRequestKey = triprequestkey from TripRequest_air where airRequestKey = @airRequestKey
 
SELECT AirRequest.airRequestKey, AirRequest.airRequestTypeKey, TripRequest_air.airRequestClassKey,    
  TripRequest_air.airRequestIsNonStop,TripRequest_air.airRequestDepartureAirportAlternate,    
  TripRequest_air.airRequestArrivalAirportAlternate, AirRequest.isInternationalTrip, TripRequest_air.airRequestRefundable   
 FROM TripRequest_air     
  LEFT OUTER JOIN AirRequest ON TripRequest_air.airRequestKey = AirRequest.airRequestKey   
 WHERE airRequest.airRequestKey <> @airRequestKey And TripRequest_air.tripRequestKey = @tripRequestKey 
    
END
GO
