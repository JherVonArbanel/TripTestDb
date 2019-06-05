SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
-- EXEC usp_GetEventById 86    
CREATE PROC [dbo].[usp_GetEventById]    
(    
 @eventKey BIGINT    
)    
AS     
BEGIN    
    
SET NOCOUNT ON     
    
DECLARE @date_from DATE,     
  @date_to DATE,    
  @FromIndex INT,    
  @ToIndex INT,    
  @EventDate DATE,    
  @ActivityId BIGINT      
    
    
DECLARE @tmpEvent AS TABLE    
(    
 eventKey BIGINT,    
 eventName VARCHAR(50),       
 eventDescription VARCHAR(1000),    
 userKey BIGINT,    
 eventStartDate DATE,    
 eventEndDate DATE,    
 eventViewershipType INT,    
 isInviteFromAttendeeAllowed BIT,    
 isAttendeeActivityEditAllowed BIT,    
 IsRecommendingHotel BIT ,    
 eventRecommendedHotelId INT,    
 eventImageURL VARCHAR(500) ,    
 eventDestination VARCHAR(50),    
 eventHotelGroupId INT,    
 eventCityId INT,    
 isRecommendingFlight BIT,    
 airResponseKey UNIQUEIDENTIFIER    
)    
DECLARE @tmpEventActivity AS TABLE    
(    
 eventActivityKey BIGINT,    
 eventKey BIGINT,    
 activityDate DATETIME,    
 activityDescription VARCHAR(500),     
 userKey BIGINT    
)    
    
DECLARE @EventDates AS TABLE    
(    
 Id INT IDENTITY(1,1),    
 Dates DATE    
)    
     
 DECLARE @EventImageURL VARCHAR(500)    
     
 SELECT TOP 1 PERCENT    
  @EventImageURL = ImageURL    
 FROM     
  CMS..EventImages    
 ORDER BY     
  NEWID()      
    
    
 INSERT INTO @tmpEvent    
 SELECT     
  eventKey,    
  ISNULL(eventName,'') as eventName ,      
  ISNULL(eventDescription,'') as eventDescription,    
  userKey,    
  eventStartDate ,    
  eventEndDate,    
  ISNULL(eventViewershipType,0) as eventViewershipType,    
  ISNULL(isInviteFromAttendeeAllowed, 0) as isInviteFromAttendeeAllowed,    
  ISNULL(isAttendeeActivityEditAllowed,0) as isAttendeeActivityEditAllowed,     
  ISNULL(IsRecommendingHotel,0) as IsRecommendingHotel,    
  ISNULL(eventRecommendedHotelId,0) as eventRecommendedHotelId,     
  ISNULL(eventImageURL,@EventImageURL) AS eventImageURL,    
  ISNULL (eventDestination,''),    
  ISNULL(eventHotelGroupId,0),    
  ISNULL(eventCityId,0),    
  ISNULL(IsRecommendingFlight, 0),    
  AirResponseKey    
 FROM     
  [Events] WITH (NOLOCK)    
 WHERE    
  eventKey = @eventKey    
 AND      
  isDeleted = 0      
    
     
 SELECT * FROM @tmpEvent    
     
     
 SELECT     
  @date_from = eventStartDate,    
  @date_to = eventEndDate        
 FROM @tmpEvent    
     
    
 PRINT CAST(@date_from as VARCHAR)    
 PRINT CAST(@date_to as VARCHAR)    
    
    
 ;WITH EventDates AS(    
  SELECT    
   @date_from AS activityDate    
  UNION ALL    
  SELECT     
   DATEADD(d,1,activityDate)    
  FROM     
   EventDates WHERE activityDate < @date_to    
 )    
     
 INSERT INTO @EventDates    
 SELECT * FROM EventDates    
    
 SET @FromIndex = 1     
 SELECT @ToIndex = COUNT(Id) FROM @EventDates    
     
     
 WHILE(@FromIndex <= @ToIndex)    
 BEGIN    
         
  SET @ActivityId = 0    
        
  SELECT     
   @EventDate = Dates     
  FROM     
   @EventDates     
  WHERE     
   Id = @FromIndex    
      
      
  SELECT     
   @ActivityId = ISNULL(eventActivityKey,0)     
  FROM     
   EventActivities WITH (NOLOCK)    
  WHERE     
   eventKey = @eventKey    
  AND     
   CAST(activityDate AS DATE) = @EventDate      
      
  IF @ActivityId = 0    
  BEGIN    
      
   INSERT INTO @tmpEventActivity    
   (    
    eventKey,    
    eventActivityKey,    
    activityDate,    
    activityDescription,    
    userKey       
   )    
   VALUES    
   (    
    @eventKey,    
    0,    
    @EventDate,    
    '',    
    0    
   )    
       
  END    
  ELSE    
  BEGIN    
      
   INSERT INTO @tmpEventActivity    
   SELECT     
    eventActivityKey ,    
    eventKey ,    
    activityDate ,    
    activityDescription ,     
    userKey          
   FROM     
    EventActivities WITH (NOLOCK)    
   WHERE     
    eventKey = @eventKey    
   AND     
    CAST(activityDate AS DATE) = @EventDate      
      
  END     
      
      
  SET @FromIndex = @FromIndex + 1    
     
 END    
     
 SELECT * FROM @tmpEventActivity    
     
 SELECT * FROM @EventDates    
        
    SELECT REPLACE(HashTag,'#','') as HashTag FROM trip..TripHashTagMapping WHERE EventKey = @eventKey   
    --ORDER BY 1 DESC    
        --//TFS #18878 replace #
    
SET NOCOUNT OFF      
    
END
GO
