SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- EXEC usp_GetTMUFollowerDetails 13488
-- 12223
CREATE PROC [dbo].[usp_GetTMUFollowerDetails]
(
	@tripKey INT
)
AS 
BEGIN

SET NOCOUNT ON 

	DECLARE @tripSavedKey UNIQUEIDENTIFIER
	DECLARE @TripFollowersDetails AS TABLE
	(
		tripSavedKey UNIQUEIDENTIFIER,		
		userKey INT,
		userName VARCHAR(200) DEFAULT NULL,
		userImageURL VARCHAR(500)DEFAULT NULL		
	)
	

	SELECT @tripSavedKey = tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey
	
	
		INSERT INTO @TripFollowersDetails
		(
			tripSavedKey,		
			userKey ,
			userName ,
			userImageURL 		
		)
		SELECT 
			T.tripSavedKey, 			
			ISNULL(T.userKey,0),
			NULL,
			NULL				 
		FROM 
			Trip T WITH (NOLOCK)
		WHERE tripSavedKey = @tripSavedKey

/*

		INSERT INTO @TripFollowersDetails
		(
			tripSavedKey,		
			userKey ,
			userName ,
			userImageURL 
		)		
		SELECT 
			TS.tripSavedKey,			
			TS.userKey,
			NULL,
			NULL				
		FROM 
			TripSaved TS WITH (NOLOCK)							
		WHERE 
			TS.tripSavedKey = @tripSavedKey
			AND
			parentSaveTripKey IS NOT NULL

*/					
		UPDATE TFD
		SET 
			userName = ISNULL(U.userFirstName,'') + ' ' + LEFT(ISNULL(U.userLastName,''),1) + '.'
		FROM 
			@TripFollowersDetails TFD
		INNER JOIN 
			vault..[User] U ON TFD.userKey = U.userKey
		
		
		UPDATE TFD
		SET 
			userImageURL = ISNULL(UM.ImageURL,'')
		FROM 
			@TripFollowersDetails TFD
		LEFT JOIN 
			Loyalty..UserMap UM ON TFD.userKey = UM.UserId
		
	
		
		SELECT * FROM @TripFollowersDetails


SET NOCOUNT OFF

END
GO
