SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_SaveOptionalServices]
(  
	@airSegmentKey		UNIQUEIDENTIFIER, 
	@description		VARCHAR(MAX), 
	@descriptionDetail	VARCHAR(MAX), 
	@icon				VARCHAR(50), 
	@subcode			VARCHAR(50), 
	@serviceAmount		FLOAT, 
	@method				VARCHAR(10), 
	@serviceType		VARCHAR(50), 
	@ReasonCode			VARCHAR(50), 
	@type				VARCHAR(50), 
	@bookingInstructions VARCHAR(200), 
	@serviceCode		VARCHAR(50), 
	@attributes			VARCHAR(500)
)AS  
  
BEGIN  

	INSERT INTO AirSegmentOptionalServices(airSegmentKey, [description], descriptionDetail, icon, subcode, serviceAmount, 
		method, serviceType, ReasonCode, [type], bookingInstructions, serviceCode, attributes) 
	VALUES(@airSegmentKey, @description, @descriptionDetail, @icon, @subcode, @serviceAmount, 
		@method, @serviceType, @ReasonCode, @type, @bookingInstructions, @serviceCode, @attributes) 
		
	SELECT Scope_Identity() 
	
END  

GO
