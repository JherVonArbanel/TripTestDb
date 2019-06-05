SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
    
/*      

declare @p11 xml
set @p11=convert(xml,N'<DocumentElement/>')
declare @p12 xml
set @p12=convert(xml,N'<DocumentElement><EventHashTags><TripKey>0</TripKey><HashTag>#apr</HashTag></EventHashTags><EventHashTags><TripKey>0</TripKey><HashTag>#Miami</HashTag></EventHashTags></DocumentElement>')
exec usp_AddEventTask @eventKey=0,@eventName=N'Jayant''s Miami Trip',@eventDescription=NULL,@eventStartDate='2016-04-18 00:00:00',@eventEndDate='2016-04-20 00:00:00',@tripKey=0,@userKey=560799,@IsAttendeeActivityEditAllowed=1,@IsInviteFromAttendeeAllowed=1,@EventViewershipType=2,@EventActivity=@p11,@EventHashTags=@p12,@EventDestination=N'MIA',@HotelGroupId=0,@CityId=0,@RecommendedHotelId=0,@RecommendedAirResponseKey='00000000-0000-0000-0000-000000000000'
*/      
      
CREATE PROC [dbo].[usp_AddEventTask]      
(      
 @eventKey BIGINT,      
 @eventName VARCHAR(50),    
 @eventDescription VARCHAR(1000),       
 @eventStartDate DATETIME,      
 @eventEndDate DATETIME,    
 @tripKey BIGINT,      
 @userKey BIGINT,    
 @IsAttendeeActivityEditAllowed BIT,    
 @IsInviteFromAttendeeAllowed BIT,    
 @EventViewershipType INT,     
 @EventActivity XML,      
 @EventHashTags XML,    
 @EventDestination VARCHAR(50) = NULL,    
 @HotelGroupId INT = 0,    
 @CityId INT = 0,  
 @RecommendedHotelId INT = 0,  
 @RecommendedAirResponseKey UNIQUEIDENTIFIER,
 @GroupKey INT =0   
)      
AS       
BEGIN      
     
 DECLARE @EventImageURL VARCHAR(500)      
       
 SELECT TOP 1 PERCENT       
  @EventImageURL = ImageURL       
 FROM       
  CMS..EventImages      
 ORDER BY     
  NEWID()     
     
 IF (@eventKey = 0)    
 BEGIN
  IF (@GroupKey >0)
  BEGIN
	SELECT @IsInviteFromAttendeeAllowed =IsInviteFromAttendeeAllowed, @IsAttendeeActivityEditAllowed = IsAttendeeActivityEditAllowed FROM vault..FriendsGroups WHERE GroupKey = @groupKey
  END   
      
  INSERT INTO [Events]    
  (    
    eventName    
   ,eventDestination    
   ,eventHotelGroupId    
   ,eventCityId    
   ,eventDescription    
   ,userKey    
   ,eventStartDate    
   ,eventEndDate    
   ,eventViewershipType    
   ,isInviteFromAttendeeAllowed    
   ,isAttendeeActivityEditAllowed    
   ,creationDate    
   ,modifiedDate    
   ,isDeleted    
   ,eventImageURL   
   ,eventRecommendedHotelId  
   ,AirResponseKey
   ,GroupKey
  )    
  VALUES    
  (    
    @eventName    
   ,@EventDestination    
   ,@HotelGroupId    
   ,@CityId    
   ,@eventDescription    
   ,@userKey    
   ,@eventStartDate    
   ,@eventEndDate    
   ,@EventViewershipType    
   ,@IsInviteFromAttendeeAllowed    
   ,@IsAttendeeActivityEditAllowed    
   ,GETDATE()    
   ,GETDATE()    
   ,0    
   ,@EventImageURL  
   ,@RecommendedHotelId  
   ,@RecommendedAirResponseKey
   ,@GroupKey
  )    
      
  SET @eventKey = SCOPE_IDENTITY()    
      
  IF (@eventKey > 0)    
  BEGIN    
   EXEC usp_SaveEventAttendee @eventKey, @userKey, NULL, NULL, NULL, NULL, 1, 3, 0    
   
   
   
  END    
          
 END    
 ELSE    
 BEGIN    
  UPDATE     
   [Events]      
   SET       
   eventName = @eventName,      
   eventDescription = @eventDescription,    
   eventStartDate = @eventStartDate,      
   eventEndDate = @eventEndDate,      
   isAttendeeActivityEditAllowed = @IsAttendeeActivityEditAllowed,    
   isInviteFromAttendeeAllowed = @IsInviteFromAttendeeAllowed,    
   eventViewershipType = @EventViewershipType,    
   modifiedDate = GETDATE()      
   WHERE       
   eventKey = @eventKey      
 END            
            
  SELECT       
   CAST(colx.query('data(eventKey)') as varchar) as eventKey,      
   CAST(colx.query('data(activityDate)') as varchar) as activityDate,      
   CAST(colx.query('data(activityDescription)') as varchar(500)) as activityDescription,      
   CAST(colx.query('data(userKey)') as varchar) as userKey      
  INTO      
   #tmpActivity        
  FROM       
   @EventActivity.nodes('DocumentElement/EventActivity') AS TABX(COLX);        
       
       
  INSERT INTO EventActivities      
  (        
   eventKey,      
   activityDate,      
   activityDescription,      
   userKey,      
   creationDate,      
   modifiedDate,      
   isDeleted       
  )       
  SELECT       
   @eventKey,      
   activityDate,      
   activityDescription,      
   userKey,      
   GETDATE(),      
   NULL,      
   0      
  FROM       
   #tmpActivity      
          
     
  DELETE FROM TripHashTagMapping    
  WHERE TripKey = @tripKey    
     
     
 DECLARE @HashTags AS TABLE    
 (    
  Id INT IDENTITY(1,1),    
  TripKey BIGINT,    
  HashTags NVARCHAR(800)    
 )     
     
 INSERT INTO @HashTags    
 (    
  TripKey,    
  HashTags    
 )    
 SELECT    
  CAST(colx.query('data(TripKey)') as varchar) as TripKey,      
  CAST(colx.query('data(HashTag)') as NVARCHAR(800)) as HashTag      
 FROM       
  @EventHashTags.nodes('DocumentElement/EventHashTags') AS TABX(COLX);        
      
      
 DECLARE @Count INT,    
   @FromIndex INT    
    
 SET @FromIndex = 1    
       
 SELECT @Count = COUNT(1) FROM @HashTags      
    
 WHILE (@FromIndex <= @Count)    
 BEGIN    
   DECLARE @TagValue NVARCHAR(800)    
       
   SELECT @TagValue = HashTags FROM @HashTags    
   WHERE Id = @FromIndex    
       
   EXEC SaveHashTagMapping @tripKey, @TagValue, @userKey, @eventKey      
      
  SET @FromIndex = @FromIndex + 1    
 END     
    
    
 DROP TABLE #tmpActivity      

----added by pradeep
--    Declare @tripSavedKey varchar (500)
--	select @tripSavedKey = TS.tripSavedKey from trip..TripSaved  TS
--	inner join trip..trip T on t.tripSavedKey = ts.tripSavedKey
--	inner join trip..AttendeeTravelDetails ATD on ATD.attendeeTripKey = t.tripKey
--	inner join trip..EventAttendees EA on EA.eventAttendeeKey = ATD.eventAttendeekey
--	inner join trip..Events E on E.eventKey = ea.eventKey
--	where e.eventKey = @eventKey and ts.userKey = @userKey
	 
--	print @tripSavedKey
	 
--    UPDATE TRIP..TripSaved  
--	SET privacyType = @EventViewershipType 
--	WHERE tripSavedKey= @tripSavedKey AND userKey=@userKey
    
--    --end of chagnes of pradeep 


 SELECT @eventKey    
     
END
GO
