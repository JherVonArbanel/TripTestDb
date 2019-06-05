SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
	
  CREATE PROCEDURE [dbo].[usp_GetHostRecommendedHotel]
 @eventKey AS BIGINT 
 AS 
 BEGIN 
    DECLARE @tripKey AS BIGINT 
	SELECT @tripKey = attendeeTripKey FROM AttendeeTravelDetails ATA WITH (NOLOCK) INNER JOIN  
	EventAttendees EA WITH (NOLOCK) ON ATA.eventAttendeekey = Ea.eventAttendeeKey 
	WHERE eventKey= @eventKey AND isHost = 1
	
	DECLARE @tripSavedKey AS UNIQUEIDENTIFIER
			,@isHotelCrowdSavings BIT
			
	SELECT @tripSavedKey = TripSavedKey, @isHotelCrowdSavings = ISNULL(IsHotelCrowdSavings, 0)
	FROM Trip WITH (NOLOCK) WHERE tripKey = @tripKey 
	
	SELECT *, IsHotelCrowdSavings = @isHotelCrowdSavings 
	FROM vw_tripHotelResponseDetails 
	WHERE tripGUIDKey = @tripSavedKey
  
 END
GO
