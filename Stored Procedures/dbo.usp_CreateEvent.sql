SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
    
-- =============================================    
-- Author:  Keyur Sheth    
-- Create date: 18th July 2014    
-- Description: This stored procedure is used to insert data in Events table    
-- =============================================    
CREATE PROCEDURE [dbo].[usp_CreateEvent]    
(    
 @eventName VARCHAR(50),    
 @eventDescription VARCHAR(1000),    
 @userKey BIGINT,    
 @eventStartDate DATETIME,    
 @eventEndDate DATETIME,    
 @eventViewershipType INT,    
 @attendeeInviteAllowed BIT,    
 @IsRecommendingHotel BIT = 0,  
 @CityId BIGINT,  
 @HotelGroupId BIGINT,  
 @eventDestination VARCHAR(3),  
 @isRecommendFlight BIT = 0,
 @recommendedHotelId BIGINT = 0,  
 @groupKey INT = 0  
)    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
 DECLARE @EventImageURL VARCHAR(500)    
     
 SELECT TOP 1 PERCENT     
  @EventImageURL = ImageURL     
 FROM     
  CMS..EventImages    
 ORDER BY NEWID()    
    
    
      INSERT INTO [Trip].[dbo].[Events]    
  (    
    [eventName]    
   ,[eventDestination]    
   ,[eventHotelGroupId]    
   ,[eventCityId]    
   ,[eventDescription]    
   ,[userKey]    
   ,[eventStartDate]    
   ,[eventEndDate]    
   ,[eventViewershipType]    
   ,[isInviteFromAttendeeAllowed]    
   ,[isAttendeeActivityEditAllowed]    
   ,[eventRecommendedHotelId]    
   ,[creationDate]    
   ,[modifiedDate]    
   ,[IsRecommendingHotel]    
   ,[isDeleted]    
   ,[eventImageURL]     
   ,IsRecommendingFlight
   ,groupKey
   
  )    
  VALUES    
  (    
    @eventName    
   ,@eventDestination    
   ,@HotelGroupId  
   ,@CityId    
   ,@eventDescription    
   ,@userKey    
   ,@eventStartDate    
   ,@eventEndDate    
   ,@eventViewershipType    
   ,@attendeeInviteAllowed    
   ,null    
   ,@recommendedHotelId    
   ,GETDATE()    
   ,GETDATE()    
   ,@IsRecommendingHotel    
   ,0    
   ,@EventImageURL  
   ,@isRecommendFlight 
   ,@groupKey
  )    
      
  --SELECT TOP 1 eventkey FROM [Trip].[dbo].[Events] WHERE [userKey] = @userKey ORDER BY eventkey DESC     
  SELECT ISNULL(CAST(scope_identity() AS INT),0)    
END
GO
