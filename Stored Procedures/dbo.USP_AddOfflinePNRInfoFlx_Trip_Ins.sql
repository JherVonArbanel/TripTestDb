SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoFlx_Trip_Ins]
(  
	@tripName NVARCHAR(100), 
	@userKey INT, 
	@recordLocator VARCHAR(50),	 
	@startDate DATETIME, 
	@endDate DATETIME, 
	@tripStatusKey INT, 
	@agencyKey INT, 
	@tripComponentType SMALLINT, 
	@tripRequestKey INT
)AS  
  
BEGIN  

	INSERT INTO [dbo].[Trip]([tripName], [userKey], [recordLocator], [startDate], [endDate], [tripStatusKey], [agencyKey], 
		tripComponentType,tripRequestKey) 
	VALUES (@tripName, @userKey, @recordLocator, @startDate, @endDate, @tripStatusKey, @agencyKey, @tripComponentType, @tripRequestKey) 
	
	SELECT SCOPE_IDENTITY()
 
END  

GO
