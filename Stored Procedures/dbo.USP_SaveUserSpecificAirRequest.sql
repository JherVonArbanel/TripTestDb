SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_SaveUserSpecificAirRequest]
(  
	@tripRequestKey							INT, 
	@airRequestKey							INT, 
	@airRequestClassKey						INT, 
	@airRequestIsNonStop					BIT, 
	--@airRequestAdults						INT, 
	--@airRequestSeniors						INT, 
	--@airRequestChildren						INT, 
	@airRequestDepartureAirportAlternate	BIT, 
	@airRequestArrivalAirportAlternate		BIT, 
	@airRequestRefundable					BIT 
)AS  
  
BEGIN  

	INSERT INTO TripRequest_air(tripRequestKey, airRequestKey, airRequestClassKey, airRequestIsNonStop, airRequestDepartureAirportAlternate, airRequestArrivalAirportAlternate, airRequestRefundable)
	VALUES(@tripRequestKey, @airRequestKey, @airRequestClassKey, @airRequestIsNonStop, @airRequestDepartureAirportAlternate, @airRequestArrivalAirportAlternate, @airRequestRefundable)
	
END
GO
