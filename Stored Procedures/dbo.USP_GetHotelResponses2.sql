SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelResponses2]  
(  
 @hotelRequestKey INT,  
 @hotelResponseKey UNIQUEIDENTIFIER,  
 @hotelID   INT = 0  
)  
AS  
BEGIN  
  
 IF @hotelRequestKey IS NOT NULL  
 BEGIN  
  SELECT * FROM vw_hotelDetailedResponse1 WHERE hotelRequestKey = @hotelRequestKey  
 END  
 ELSE IF @hotelID <> 0  
 BEGIN  
  SELECT  * FROM vw_hotelDetailedResponse1 WHERE hotelID = @hotelID  
 END  
 ELSE IF @hotelResponseKey IS NOT NULL  
 BEGIN  
  SELECT  * FROM vw_hotelDetailedResponse1 WHERE hotelResponseKey = @hotelResponseKey  
 END  
  
END
GO
