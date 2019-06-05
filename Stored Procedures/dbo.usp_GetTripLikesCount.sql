SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_GetTripLikesCount]    
(    
@tripKey AS INT      
)    
AS     
BEGIN     
 DECLARE @tripSavedKey AS UNIQUEIDENTIFIER    
 SELECT @tripSavedKey = tripSavedKey FROM TRIP WITH(NOLOCK) WHERE Tripkey =  @tripKey    
 --SELECT SUM(tripLike) AS TripLikeCount FROM  TripLike WITH(NOLOCK) WHERE TripSavedkey =  @tripSavedKey    
 SELECT SUM(tripLike) AS TripLikeCount FROM  TripLike WITH(NOLOCK) WHERE tripKey =  @tripKey
END
GO
