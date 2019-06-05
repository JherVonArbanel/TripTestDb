SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




   CREATE PROCEDURE [dbo].[usp_MapTripForEvent]
  @eventKey AS BIGINT,
   @userKey AS BIGINT,
   @tripKey AS BIGINT,
   @hotelID AS BIGINT ,
   @isPurchased AS BIT,
   @airResponseKey AS UNIQUEIDENTIFIER 
 AS 
  
 DECLARE @eventAttendeeKey AS BIGINT
 DECLARE @isHost AS BIT 
 
 
 SELECT @isHost = isHost , @eventAttendeeKey=eventAttendeeKey FROM EventAttendees WITH (NOLOCK) WHERE  userKey = @userKey and eventKey =@eventKey
 
 IF  @isHost = 1  AND @hotelID >0
 BEGIN
  
	UPDATE 
		[Events] 
	SET 
		eventRecommendedHotelId = @hotelID,
		IsRecommendingHotel = 1
	WHERE 
		eventKey =@eventKey 
 END
 
  IF  @isHost = 1 
 BEGIN
  
	UPDATE 
		[Events] 
	SET 
		airresponsekey = @airResponseKey,
		IsRecommendingFlight = 0
	WHERE 
		eventKey =@eventKey 
 END
 
 IF NOT EXISTS (SELECT * FROM AttendeeTravelDetails WITH (NOLOCK) WHERE eventAttendeekey =@eventAttendeeKey)
	 BEGIN 
		INSERT AttendeeTravelDetails ( eventAttendeekey ,isPurchased,attendeeTripKey) VALUES (@eventAttendeeKey,@isPurchased,@tripKey)
	 END 
 ELSE	
	BEGIN
		DECLARE @attendeeTravelKey AS BIGINT 
		SELECT @attendeeTravelKey = attendeeTravelKey FROM AttendeeTravelDetails WITH (NOLOCK) WHERE eventAttendeekey =@eventAttendeeKey 
		
		UPDATE AttendeeTravelDetails SET attendeeTripKey =@tripKey , isPurchased =@isPurchased WHERE attendeeTravelKey = @attendeeTravelKey
	END
  

IF (@isHost = 1 )
BEGIN

	IF (@eventKey > 0 AND @tripKey > 0)
	BEGIN
	
		UPDATE TripHashTagMapping
		SET TripKey = @tripKey
		WHERE EventKey = @eventKey
		
	END


END



GO
