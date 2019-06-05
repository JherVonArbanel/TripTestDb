SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--EXEC USP_GetHotelDetailsByResponseID '28632863-f844-4657-80a8-47bcf01d583d'    
CREATE PROCEDURE [dbo].[USP_GetHotelDetailsByResponseID]    
(    
 @hotelResponseKey UNIQUEIDENTIFIER    
)    
AS    
BEGIN    
DECLARE @GDS VARCHAR(50)    
DECLARE @MinDailyPrice FLOAT    
    
    SELECT  TOP 1  @MinDailyPrice = A.hotelDailyPrice, @GDS = A.supplierId   FROM HotelResponseDetail A where hotelResponseKey =@hotelResponseKey   
    And (rateDescription Not Like ('%A A A%') AND rateDescription Not Like ('%AAA%') AND rateDescription Not Like ('%SENIOR%') AND rateDescription Not Like ('%GOV%'))  
    ORDER BY hotelDailyPrice ASC  ,marketPlacePreferenceOrder ASC   
       
 --   FROM    
 -- (    
 -- SELECT * FROM HotelResponseDetail  where hotelResponseKey =@hotelResponseKey and supplierId='Sabre'     
 -- UNION    
 -- SELECT * FROM HotelResponseDetail  where hotelResponseKey =@hotelResponseKey and supplierId='Hotelscom'     
 -- UNION    
 -- SELECT * FROM HotelResponseDetail  where hotelResponseKey =@hotelResponseKey and supplierId='Tourico'     
 -- ) A    
 --ORDER BY hotelDailyPrice  ASC     
  
  
 --SELECT @MinDailyPrice,@GDS    
    
 SELECT *     
 FROM HotelResponseDetail     
 WHERE hotelResponseKey = @hotelResponseKey      
 AND supplierId = @GDS  And (rateDescription Not Like ('%A A A%') AND rateDescription Not Like ('%AAA%') AND rateDescription Not Like ('%SENIOR%') AND rateDescription Not Like ('%GOV%'))  
 ORDER BY hotelDailyPrice    
    
END
GO
