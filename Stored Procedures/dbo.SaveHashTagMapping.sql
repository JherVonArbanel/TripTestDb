SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
      
-- =============================================      
-- Author:  Keyur Sheth      
-- Create date: 24 November 2014      
-- Description: Procedure used to store hash tag mapping with trip and user      
-- =============================================      
CREATE PROCEDURE [dbo].[SaveHashTagMapping]      
 @TripKey INT = 0,      
 @HashTag NVARCHAR(800),      
 @UserID INT,      
 @EventKey INT = 0    
AS      
BEGIN  

--exec SaveHashTagMapping 27788,'#SanFrancisco',0,2296

IF (@EventKey > 0)
BEGIN
	--IF (SELECT COUNT(1) FROM  [Trip].[dbo].[TripHashTagMapping] WHERE EventKey = @EventKey) < 2  
	IF (SELECT COUNT(1) FROM  [Trip].[dbo].[TripHashTagMapping] WHERE EventKey = @EventKey and TripKey = @TripKey and HashTag = @HashTag) < 1  
	BEGIN     
	 INSERT INTO [Trip].[dbo].[TripHashTagMapping] (TripKey, EventKey, HashTag) VALUES (@TripKey,@EventKey, @HashTag)      
	END  
		
END
ELSE IF (@TripKey > 0)
BEGIN
	IF (SELECT COUNT(1) FROM  [Trip].[dbo].[TripHashTagMapping] WHERE TripKey = @TripKey) < 2  
	BEGIN     
	 INSERT INTO [Trip].[dbo].[TripHashTagMapping] (TripKey, EventKey, HashTag) VALUES (@TripKey,@EventKey, @HashTag)      
	END  
END
  
      
 IF NOT EXISTS (SELECT 1 FROM [Loyalty].[dbo].[PreferedVacationCustom] WHERE [Description] = @HashTag AND [UserId] = @UserID)      
 BEGIN      
  INSERT INTO [Loyalty].[dbo].[PreferedVacationCustom] VALUES (@HashTag, @UserID, 1)      
 END      
END 
GO
