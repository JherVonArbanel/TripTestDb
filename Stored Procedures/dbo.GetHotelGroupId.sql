SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
SELECT * FROM TripRequest
ORDER BY 1 DESC  
  
  */
  
-- EXEC GetHotelGroupId 'DFW',1
CREATE PROCEDURE [dbo].[GetHotelGroupId]  
(  
 @prefixText VARCHAR(100),      
 @isAirport bit = 0      
)AS      
BEGIN
	PRINT '@isAirport :- ' +  CAST(@isAirport AS VARCHAR)      
   IF (@isAirport = 0)  
   BEGIN  
		SELECT   
			HotelGroupId   
		FROM   
			[CMS].[dbo].[CustomHotelGroup]  
		WHERE  
			  HotelGroupName = @prefixText  
			  AND Visible = 1  
   END  
   ELSE  
   BEGIN 
		PRINT 'Inside ELSE' 
		SELECT   
			HotelGroupId   
		FROM   
			[CMS].[dbo].[CustomHotelGroup]  
		WHERE  
			AirportCode = @prefixText  
			AND Visible = 0  
	END  
END
GO
