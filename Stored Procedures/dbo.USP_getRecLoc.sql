SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_getRecLoc]
(  
	@tripKey INT
)AS  
  
BEGIN  

	SELECT TOP 1 recordLocator 
	FROM Trip 
	WHERE tripKey = (SELECT TOP 1 tripKey FROM TripAirLegs WHERE tripKey = @tripKey AND gdsSourceKey = 9 AND isDeleted = 0)
 
END  

GO
