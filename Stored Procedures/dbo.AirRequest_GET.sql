SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AirRequest_GET]    
(    
 @airRequestKey INT    
)    
AS    
BEGIN    
    
 SELECT AirRequest.airRequestKey, AirRequest.airRequestTypeKey, TripRequest_air.airRequestClassKey,    
  TripRequest_air.airRequestIsNonStop,TripRequest_air.airRequestDepartureAirportAlternate,    
  TripRequest_air.airRequestArrivalAirportAlternate, AirRequest.isInternationalTrip, TripRequest_air.airRequestRefundable   
 FROM TripRequest_air     
  LEFT OUTER JOIN AirRequest ON TripRequest_air.airRequestKey = AirRequest.airRequestKey   
 WHERE airRequest.airRequestKey = @airRequestKey   
    
END
GO
