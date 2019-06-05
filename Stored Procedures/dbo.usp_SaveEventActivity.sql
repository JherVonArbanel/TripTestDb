SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE PROC [dbo].[usp_SaveEventActivity]  
(  
 @eventActivityKey BIGINT,  
 @eventKey BIGINT,  
 @activityDate DATETIME,  
 @activityDescription VARCHAR(500),  
 @userKey BIGINT  
  
)  
AS   
BEGIN  
   
 IF (@eventActivityKey = 0)  
 BEGIN  
   INSERT INTO EventActivities  
   (  
    eventKey,  
    activityDate,  
    activityDescription,  
    userKey,  
    creationDate,      
    isDeleted     
   )  
   VALUES  
   (  
    @eventKey,  
    @activityDate,  
    @activityDescription,  
    @userKey,  
    GETDATE(),  
    0     
   )  
    
  
  SELECT SCOPE_IDENTITY()  
   
 END  
 ELSE  
 BEGIN  
     
     
   IF(LTRIM(RTRIM(@activityDescription)) = '' OR ISNULL(@activityDescription,'') = '')  
   BEGIN   
      
    DELETE FROM EventActivities  
    WHERE eventActivityKey = @eventActivityKey     
      
    SELECT 0  
      
   END  
   ELSE  
   BEGIN  
     
    UPDATE EventActivities  
    SET               
     activityDescription = @activityDescription,  
     userKey = @userKey,  
     activityDate = @activityDate,      
     modifiedDate = GETDATE()         
    FROM   
     EventActivities  
    WHERE       
     eventActivityKey = @eventActivityKey      
      
      
    SELECT @eventActivityKey     
      
   END  
    
   
 END  
   
  
  
  
END  
GO
