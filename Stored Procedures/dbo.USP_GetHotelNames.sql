SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetHotelNames]  
(  
 @hotelRequestKey INT = 0,  
 @HotelName   VARCHAR(150)  
)  
AS  
BEGIN  
  
 IF(@hotelRequestKey != 0)
  
 SELECT HotelName FROM vw_hotelDetailedResponse1 
 WHERE hotelRequestKey = @hotelRequestKey AND HotelName LIKE '%' + @HotelName + '%'  
  
 ELSE
  
 SELECT distinct(HotelName) FROM vw_hotelDetailedResponse1 
 WHERE HotelName LIKE '%' + @HotelName + '%'
  
  
END
GO
