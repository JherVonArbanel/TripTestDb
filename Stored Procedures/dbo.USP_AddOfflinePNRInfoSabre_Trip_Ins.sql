SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoSabre_Trip_Ins]  
(    
	@meetingCodeKey VARCHAR(50),
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
  
	INSERT INTO [dbo].[Trip](meetingCodeKey, [tripName], [userKey], [recordLocator], [startDate], [endDate], [tripStatusKey], [agencyKey], 
		tripComponentType,tripRequestKey) 
	VALUES (@meetingCodeKey,@tripName,@userKey,@recordLocator,@startDate,@endDate,@tripStatusKey ,@agencyKey,@tripComponentType,@tripRequestKey) 
	
	SELECT Scope_Identity()  
   
END    
  
GO
