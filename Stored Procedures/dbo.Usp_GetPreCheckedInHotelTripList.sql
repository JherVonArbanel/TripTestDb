SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  Manoj Kumar Naik    
-- Create date: 30-09-2016 19:18    
-- Description: GetPreCheckedInHotelTripList By UploadKey    
-- =============================================    
CREATE PROCEDURE [dbo].[Usp_GetPreCheckedInHotelTripList]     
 @uploadKey uniqueidentifier    
AS    
BEGIN    
 IF (@uploadKey ='00000000-0000-0000-0000-000000000000')  
 BEGIN  
   SELECT Top 1 @uploadKey = uploadKey FROM Trip.dbo.PreCheckInHotelBooked ORDER BY CreatedDate desc  
 END     
   SELECT * FROM Trip.dbo.PreCheckInHotelBooked WHERE uploadKey=@uploadKey  ORDER BY savings desc  
   
   SELECT Count(1) as totalCount, status  from Trip..PreCheckInHotelBooked where UploadKey=@uploadKey  
   Group by Status   
END
GO
