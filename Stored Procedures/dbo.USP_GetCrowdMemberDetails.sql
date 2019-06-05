SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

    
-- =============================================          
-- Author:  Jitendra Verma           
-- Create date: 15/June/2016          
-- Description: It is used to get Cword Members Details.        
/*  
Exec USP_GetCrowdMemberDetails 5
 */  
-- =============================================          
    
CREATE PROCEDURE [dbo].[USP_GetCrowdMemberDetails]  
    @siteKey INT = 0
 
AS          
BEGIN          
    
  SET NOCOUNT ON -- added to prevent extra result sets from          
    
    Truncate Table CrowdMemberDetails
     
    INSERT INTO CrowdMemberDetails    
		(    
			--crowdId,
			userKey, 
			destination,   
			userFirstName,    
			userLastName,    
			userImageUrl,    
			badgeName,    
			createdDateTime,
			CrowdCount
		)  
       
	--SELECT	TS.CrowdId, TS.userKey, C.crowdDestination, U.userFirstName, U.userLastName,  
	--		UM.ImageURL, UM.BadgeName, GETDATE()
	--FROM Trip.dbo.Trip T 
	--	INNER JOIN Trip.dbo.TripSaved TS ON T.tripSavedKey = TS.tripSavedKey
	--	INNER JOIN [Vault]..[User] U ON U.userKey = TS.userKey
	--	LEFT OUTER JOIN [Loyalty]..[UserMap] UM ON TS.userKey = UM.UserId
	--	LEFT OUTER JOIN Trip.dbo.Crowd C ON C.crowdId = TS.CrowdId
		
	--WHERE T.siteKey = 5 and T.endDate > DATEAdd(DAY,1 ,getdate()) 
	--and T.tripStatusKey in( 1,2,4,14,15,17)
	
	SELECT DISTINCT TS.userKey, C.crowdDestination, U.userFirstName, U.userLastName, UM.ImageURL, UM.BadgeName, GETDATE(),0
	FROM Trip.dbo.Trip T 
		   INNER JOIN Trip.dbo.TripSaved TS ON T.tripSavedKey = TS.tripSavedKey
		   INNER JOIN [Vault]..[User] U ON U.userKey = TS.userKey
		   LEFT OUTER JOIN [Loyalty]..[UserMap] UM ON TS.userKey = UM.UserId
		   LEFT OUTER JOIN Trip.dbo.Crowd C ON C.crowdId = TS.CrowdId
	WHERE T.siteKey = @siteKey and T.endDate > DATEAdd(DAY,1 ,getdate()) 
		  and T.tripStatusKey in( 1,2,4,14,15,17)
	ORDER BY userKey, crowdDestination ASC


	DECLARE @CrowdCounttbl TABLE ( TripTo VARCHAR(50), CrowdCount INT);

	INSERT INTO @CrowdCounttbl(TripTo,CrowdCount)    
	SELECT        
	  TD.tripTo,COUNT(TD.tripTo)    
	 FROM TRIP..TripDetails TD WITH (NOLOCK)      
	 INNER JOIN Trip..Trip T WITH (NOLOCK) ON T.tripKey = TD.tripKey       
	 WHERE       
	 T.tripStatusKey <> 17         
	 AND TD.tripTo IS NOT NULL      
	 AND TD.tripStartDate >= DATEADD(D,0, GetDate())      
	 AND T.PrivacyType <>2                
	 AND T.IsWatching = 1 AND T.isUserCreatedSavedTrip =1       
	 GROUP BY TD.tripTo    
    
	 UPDATE CMD
	 SET CMD.CrowdCount= TT.CrowdCount      
	 FROM Trip..CrowdMemberDetails CMD    
	 INNER JOIN @CrowdCounttbl TT ON TT.TripTo = CMD.destination
     
END
GO
