SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

    
-- =============================================          
-- Author:  Jitendra Verma           
-- Create date: 15/June/2016          
-- Description: It is used to get Cword Members Details by City wise.        
/*  
Exec [[USP_GetCrowdMemberDetailsByCity]] 561138 , 'followers',560799    
 Exec [[USP_GetCrowdMemberDetailsByCity]] 561138 , 'following',560799  
 */  
-- =============================================          
    
CREATE PROCEDURE [dbo].[USP_GetCrowdMemberDetailsByCity]          
    
 
AS          
BEGIN          
    
  SET NOCOUNT ON -- added to prevent extra result sets from          
       
	SELECT U.userFirstName, U.userLastName, TS.CrowdId, TS.userKey ,UM.BadgeName, UM.ImageURL, C.crowdDestination
	FROM Trip.dbo.Trip T 
		INNER JOIN Trip.dbo.TripSaved TS ON T.tripSavedKey = TS.tripSavedKey
		INNER JOIN [Vault]..[User] U ON U.userKey = TS.userKey
		LEFT OUTER JOIN [Loyalty]..[UserMap] UM ON TS.userKey = UM.UserId
		LEFT OUTER JOIN Trip.dbo.Crowd C ON C.crowdId = TS.CrowdId
		
	WHERE T.siteKey = 5 and T.endDate > DATEAdd(DAY,1 ,getdate()) 
	and T.tripStatusKey in( 1,2,4,14,15,17)
	    
    
 
     
END
GO
