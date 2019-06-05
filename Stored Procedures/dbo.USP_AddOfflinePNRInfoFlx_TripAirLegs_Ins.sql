SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoFlx_TripAirLegs_Ins]
(  
	@airResponseKey		UNIQUEIDENTIFIER, 
	@gdsSourceKey		INT, 
	@selectedBrand		VARCHAR(50), 
	@recordLocator		VARCHAR(50), 
	@airLegNumber		INT, 
	@tripKey			INT
)AS  
  
BEGIN  

	INSERT INTO [TripAirLegs]([airResponseKey], [gdsSourceKey], [selectedBrand], [recordLocator], [airLegNumber], [tripKey])
    VALUES (@airResponseKey, @gdsSourceKey, @selectedBrand, @recordLocator, @airLegNumber, @tripKey) 
    
    SELECT SCOPE_IDENTITY()

END  

GO
