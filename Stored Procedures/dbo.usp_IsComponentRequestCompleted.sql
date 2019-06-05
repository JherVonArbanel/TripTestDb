SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--sp_helptext 'usp_IsComponentRequestCompleted'  
  
CREATE PROCEDURE [dbo].[usp_IsComponentRequestCompleted]  
  
(  
  
@requestKey INT ,  
  
@componentType INT  
  
)  
  
AS  
  
BEGIN  
  
DECLARE @noOfRequestMade as INT  
DECLARE @searchType as INT  
  
DECLARE @success as BIT = 0  
  
IF ( @componentType = 2 )  
  
BEGIN  
  
SELECT @noOfRequestMade =NoOFRequestSentToGDS,@searchType =searchType from TripRequest_car WITH(NOLOCK) where carRequestKey = @requestKey 
  
END  
  
ELSE IF (@componentType = 4)  
  
BEGIN  
  
SET @noOfRequestMade = (SELECT NoOFRequestSentToGDS from TripRequest_hotel WITH(NOLOCK) where hotelRequestKey = @requestKey )  
  
END  
  
IF (@componentType = 4)  
  
BEGIN  
  
IF ( SELECT COUNT(*) FROM RequestCompletionStatus WITH(NOLOCK) WHERE componentType = @componentType AND requestKey = @requestKey ) >=@noOfRequestMade
  
BEGIN  
  
SET @success = 1  
  
END  
  
END  
  
IF (@componentType = 2)  
  
BEGIN  
  
IF ( SELECT COUNT(*) FROM RequestCompletionStatus WITH(NOLOCK) WHERE componentType = @componentType AND searchType <>1   AND requestKey = @requestKey ) >=1
  
BEGIN  
  
SET @success = 1  
  
END  
ELSE IF ( SELECT COUNT(*) FROM RequestCompletionStatus WITH(NOLOCK) WHERE componentType = @componentType AND searchType =@searchType   AND requestKey = @requestKey ) >=2
  
BEGIN
	SET @success = 1  
END

END


ELSE  
  
BEGIN  
  
IF ( SELECT COUNT(*) FROM RequestCompletionStatus WITH(NOLOCK) WHERE componentType = @componentType AND requestKey = @requestKey ) >= @noOfRequestMade  
  
BEGIN  
  
SET @success = 1  
  
END  
  
END  
  
SELECT @success  
  
END  

GO
