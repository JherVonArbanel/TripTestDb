SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_UnfollowTrip]     
(    
 @tripKey INT ,    
 @userKey INT    
)    
AS    
 BEGIN     
 DECLARE @tripSavedKey AS UNIQUEIDENTIFIER      
 SELECT @tripSavedKey = tripSavedKey FROM TRIP WHERE Tripkey =  @tripKey     
 DECLARE @userTripKey AS INT     
     
 SELECT @userTripKey = tripKey from Trip Where tripSavedKey = @tripSavedKey AND userKey = @userKey  AND iswatching = 1        
  
--commented by pradeep because , usertripkey has no data to hold
--exec usp_EnableSaveTrip @tripKey , 0     

UPDATE Trip SET IsWatching = 0 WHERE tripKey = @userTripKey  
 
 DECLARE @tripCount AS INT
 SELECT @tripCount = COUNT(*) FROM TripSaved WHERE tripSavedKey = @tripSavedKey AND userKey = @userKey
IF(@tripCount > 0)
	BEGIN
		UPDATE TripSaved SET parentSaveTripKey = NULL WHERE tripSavedKey = @tripSavedKey AND userKey = @userKey
	END
ELSE
	BEGIN
		UPDATE Trip SET tripSavedKey = NULL WHERE tripKey = @userTripKey AND userKey = @userKey
	END

 SELECT COUNT (*) FROM TRIP WHERE TripSavedKey = @tripSavedKey AND iswatching = 1     
END
GO
