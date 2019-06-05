SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_SelectUserKey]
(  
	@farelogixProfileIndex INT
)AS  
  
BEGIN  

	SELECT userKey FROM Vault.dbo.[user] WHERE farelogixProfileIndex = @farelogixProfileIndex
 
END  

GO
