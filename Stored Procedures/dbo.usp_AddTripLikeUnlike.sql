SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_AddTripLikeUnlike]    
(    
@tripKey AS INT,    
@userkey AS INT ,    
@tripLike AS INT,    
@createdDate AS DATETIME    
)    
AS     
BEGIN     
 DECLARE @tripSavedKey AS UNIQUEIDENTIFIER    
 SELECT @tripSavedKey = tripSavedKey FROM TRIP WHERE Tripkey =  @tripKey    
     
IF NOT EXISTS (SELECT * FROM [Trip].[dbo].[TripLike] WHERE [tripKey] = @tripKey  AND [userKey] = @userKey)  
	BEGIN     
	INSERT INTO [Trip].[dbo].[TripLike] ([tripSavedKey], [tripKey] ,[userKey],[tripLike],[createdDate])      
	VALUES(@tripSavedKey,@tripKey,@userkey,1,@createdDate)     
	END  
ELSE  
	Begin
	IF(@tripLike=1)  
		BEGIN
		DELETE FROM [Trip].[dbo].[TripLike]  WHERE [tripKey] = @tripKey AND [userKey] = @userKey  
		END
	End

/*SELECT SUM(tripLike) as tripLike FROM  TripLike WHERE TripSavedkey =  @tripSavedKey */    
SELECT COUNT(*) as tripLike FROM  TripLike WHERE Tripkey =  @tripKey    
END
GO
