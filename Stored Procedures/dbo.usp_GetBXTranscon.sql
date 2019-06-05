SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- EXEC usp_GetBXRules 'LHR', 'HAV', 70  
CREATE PROC [dbo].[usp_GetBXTranscon]  
(  
 @SiteKey INT   
)  
AS  
BEGIN   
  
 SET NOCOUNT ON;  
  
 SELECT DepartureCode,ArrivalCode FROM BXTranscon WHERE siteKey = @SiteKey  
  
END
GO
