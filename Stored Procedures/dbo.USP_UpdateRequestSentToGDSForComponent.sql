SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[USP_UpdateRequestSentToGDSForComponent]   
(  
@requestID int ,   
@nooFRequests int ,  
@componentType int = 1,  
@searchType int =1  
)   
  
AS   
  
IF @componentType =1    
BEGIN   
Update TripRequest_air SET  NoOFRequestSentToGDS = @nooFRequests where airRequestKey = @requestID   
END   
ELSE IF @componentType = 2   
BEGIN   
Update TripRequest_car SET  NoOFRequestSentToGDS = @nooFRequests, searchType=@searchType where carRequestKey = @requestID   
END  
ELSE IF @componentType = 4   
BEGIN   
Update TripRequest_hotel SET  NoOFRequestSentToGDS = @nooFRequests where hotelRequestKey = @requestID   
END  
   
 
GO
