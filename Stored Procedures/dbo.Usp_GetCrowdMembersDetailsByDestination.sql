SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  <Jitendra Verma>    
-- Create date: <17-June-20616>    
-- Description: <Get Crowd Members Details by Destination for HasTag>    
-- =============================================    
CREATE PROCEDURE [dbo].[Usp_GetCrowdMembersDetailsByDestination]    
 ( @loggedInUserKey INT = 0 )     
AS    
BEGIN    
     
    SELECT CD.userKey, CD.destination, CD.userFirstName, CD.userLastName, CD.userImageUrl, CD.badgeName, UM.UserImageData, CD.CrowdCount  
  FROM CrowdMemberDetails CD JOIN Loyalty..[UserMap] UM ON CD.userKey = UM.UserId  WHERE CD.userKey <> @loggedInUserKey  
END
GO
