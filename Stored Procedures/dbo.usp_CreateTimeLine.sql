SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
    
      
-- =============================================      
-- Author:  Anupam Patel  
-- Create date: 23-Apr-2015  
-- Description: This stored procedure is used to insert data in Timeline     
-- Updated by Manoj 20-01-2016 14:49. Added column showALert for adding timeline record. 
-- =============================================      
CREATE PROCEDURE [dbo].[usp_CreateTimeLine]      
(      
   @userKey INT,  
   @timeLineGroupKey INT,  
   @jsonData nVarchar(MAX),  
   @isRead BIT = 0,  
   @tripKey INT = 0,  
   @CreationDate DateTime,
   @showAlert BIT = 1,
   @savings Float = 0
)      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
 INSERT INTO [Trip].[dbo].[TimeLine]      
  (      
   userKey,  
   timeLineGroupKey,  
   jsonData,  
   isRead,  
   tripKey,  
   createdDate,
   showAlert,
   savings
  )      
  VALUES      
  (      
   @userKey,  
   @timeLineGroupKey,  
   @jsonData,  
   @isRead,  
   @tripKey,  
   @CreationDate,
   @showAlert,
   @savings
  )      
        
  --SELECT TOP 1 eventkey FROM [Trip].[dbo].[Events] WHERE [userKey] = @userKey ORDER BY eventkey DESC       
  SELECT ISNULL(CAST(scope_identity() AS INT),0)      
END      

GO
