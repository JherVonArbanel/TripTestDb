SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
      
--usp_GetEventTripMappings 0,36217,570300    
CREATE Procedure [dbo].[usp_GetEventTripMappings]      
(      
@eventId BIGINT = 0 ,      
@tripId BIGINT = 0 ,      
@userId BIGINT = 0       
)      
      
AS       
BEGIN       
 DECLARE @isHost as BIT = 0       
 DECLARE @attendeeStatusKey AS INT =0       
 DECLARE @isTripWatcher AS BIT =0      
 DECLARE @hostfirstName varchar(50)      
 DECLARE @hostlastName varchar(50)      
 DECLARE @hostImageUrl varchar(500)      
 DECLARE @isEventPrivate AS BIT = 0      
 DECLARE @isTripPrivate AS INT = 0      
      
 IF ( @eventId > 0 )       
 BEGIN       
  SELECT       
   @tripId = ISNULL(attendeeTripKey,0)      
  FROM EventAttendees EA WITH (NOLOCK)      
   LEFT OUTER JOIN AttendeeTravelDetails ATD WITH (NOLOCK) ON EA.eventAttendeeKey =ATD.eventAttendeeKey       
  WHERE       
   eventKey = @eventId       
   AND userKey = CASE WHEN @userId = 0 THEN userKey ELSE @userId END -- and attendeeStatusKey =3       
      
 END       
 ELSE IF ( @tripId >0)      
 BEGIN            
         
  SELECT       
   @eventId = eventKey      
  FROM       
   AttendeeTravelDetails ATD  WITH (NOLOCK)      
   RIGHT OUTER JOIN EventAttendees EA  WITH (NOLOCK) on ATD.eventAttendeekey = Ea.eventAttendeeKey       
  WHERE       
   attendeeTripKey = @tripId      
 END      
   
      
  --- If trip is mapped to event then get watcher information from Trip table      
 IF @tripId > 0       
 BEGIN       
  IF EXISTS (SELECT * FROM Trip  WITH (NOLOCK) WHERE tripKey = @tripId AND userKey= @userId)      
  BEGIN       
   SET @isTripWatcher = 1        
  END      
 END       
        
        
 IF (@eventId > 0)      
 BEGIN       
  DECLARE @hostUserId AS BIGINT       
  SELECT @hostUserId =userkey FROM Events WITH(NOLOCK) where eventKey =@eventId       
         
  SELECT @hostfirstName =ISNULL( U.userFirstName,'') ,@hostlastName =ISNULL(u.userLastName,'') ,@hostImageUrl =ISNULL(UM.ImageURL,'')      
  FROM vault..[User] U WITH(NOLOCK) LEFT OUTER JOIN       
  Loyalty..UserMap UM WITH(NOLOCK) ON U.userKey = UM.UserId      
  WHERE U.userKey = @hostUserId      
        --commented by pradeep for TFS #14200
  --SELECT @isEventPrivate = EV.eventViewershipType FROM [Events] EV WHERE EV.eventKey = @eventId      
	SELECT @isEventPrivate = case EV.eventViewershipType when 1 then 0 when 2 then 1 else 0 end FROM [Events] EV WHERE EV.eventKey = @eventId        
  SELECT       
    @isHost = isHost      
   ,@attendeeStatusKey = attendeeStatusKey       
  FROM       
   EventAttendees EA  WITH (NOLOCK)      
  WHERE       
   eventKey = @eventId      
   AND EA.userKey = @userId      
 END      
      
 IF @userId = 0 --Incase of not loggedin user      
 BEGIN       
  SET @attendeeStatusKey = 0       
 END      
        
 SELECT @isTripPrivate = tr.privacyType FROM trip..trip tr WHERE tr.tripKey = @tripId      
      
 SELECT       
  @isHost AS IsHost,       
  @tripId AS tripId,       
  @eventId AS eventId,      
  @isTripWatcher AS isTripWatcher,      
  @attendeeStatusKey AS attendeeStatusKey,      
  @hostfirstName AS hostFirstName,      
  @hostlastName AS hostLastName,      
  @hostImageUrl AS hostImageUrl,       
  @isEventPrivate AS isEventPrivate,      
  @isTripPrivate AS isTripPrivate,
  @hostUserId AS hostUserKey      
END 
GO
