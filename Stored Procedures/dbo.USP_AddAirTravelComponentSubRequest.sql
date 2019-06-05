SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddAirTravelComponentSubRequest]
(  
	@airRequestKey					INT, 
	@airSubRequestLegIndex			INT,
	@airRequestDateTypeKey			INT, 
	@airRequestDepartureAirport		VARCHAR(50), 
	@airRequestArrivalAirport		VARCHAR(50), 
	@airRequestDepartureDate		DATETIME, 
	@airRequestArrivalDate			DATETIME
)AS  
  
BEGIN  

	INSERT INTO AirSubRequest(airRequestKey, airSubRequestLegIndex, airRequestDateTypeKey, 
					airRequestDepartureAirport, airRequestArrivalAirport, airRequestDepartureDate, airRequestArrivalDate)
	VALUES (@airRequestKey, @airSubRequestLegIndex, @airRequestDateTypeKey, 
		@airRequestDepartureAirport, @airRequestArrivalAirport, @airRequestDepartureDate, @airRequestArrivalDate) 
	
	SELECT Scope_Identity()    
	
END  

GO
