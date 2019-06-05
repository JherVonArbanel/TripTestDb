SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***********************************   
  updatedBy - Manoj Kumar Naik     
  updated on - 16/06/2012  
  Remarks - Added   hotelPolicy varchar(2000),         
                    checkInInstruction varchar(2000),  
                    tripAdvisorRating varchar(10)  
            to temp @hotelResponseResult table. Since vw_hotelDetailedResponse1 is modified.  
  updated on 18/05/2012 by Manoj Kumar Naik
  Added  - checkInTime varchar(50)
		 -  checkOutTime varchar(50)
 **********************************/  
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesForRequest]              
( @hotelRequestKey  INT ,              
  @sortField VARCHAR(50)='',              
  @hotelRatings VARCHAR(200)='',              
  @mindistance FLOAT = 0 ,              
  @maxdistance FLOAT= 1000,              
  @minPrice FLOAT=0.0 ,              
  @maxPrice FLOAT=999999999.99,              
  @hotelAmenities VARCHAR(200)='',               
  @chainCode VARCHAR(10) = 'ALL' ,              
  @pageNo INT ,              
  @pageSize INT ,              
  @hotelName VARCHAR(100) = ''            
)            
AS            
BEGIN              
SELECT 1            
 END
GO
