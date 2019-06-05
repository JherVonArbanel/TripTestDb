SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddAirTravelComponentRequest]
(  
	@airRequestTypeKey		INT, 
	@airRequestCreated		DATETIME, 
	@isInternationalTrip	BIT
)AS  
  
BEGIN  

  INSERT INTO AirRequest(airRequestTypeKey, airRequestCreated, isInternationalTrip)
  VALUES (@airRequestTypeKey, @airRequestCreated, @isInternationalTrip) 
  
  SELECT SCOPE_IDENTITY() 
   
END  
GO
