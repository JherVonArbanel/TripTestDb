SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
---EXEC usp_GetCreatorForSaveTrip 9685  
CREATE Procedure [dbo].[usp_GetCreatorForSaveTrip]   
(  
@tripKey AS INT  
)  
AS  
BEGIN   
DECLARE @tripSavedKey AS UNIQUEIDENTIFIER   
SELECT @tripSavedKey = TripsavedKey FROM Trip WITH(NOLOCK) where tripKey = @tripKey   
SELECT @tripKey = (SELECT MIN(tripKey) FROM Trip WITH(NOLOCK) WHERE  tripSavedKey = @tripSavedKey)  
  
SELECT UM.ImageUrl ,UI.userFirstName , UI.userLastName,UI.userKey  
FROM Trip T1 WITH(NOLOCK) 
INNER JOIN Vault..[User] UI WITH(NOLOCK) ON T1.userKey = UI.userKey  
LEFT JOIN Loyalty..UserMap UM WITH(NOLOCK) ON UI.userKey = UM.UserId WHERE tripKey =@tripKey  
  
END
GO
