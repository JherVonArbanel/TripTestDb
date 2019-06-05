SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- =============================================    
-- Author:  Manoj Kumar Naik    
-- Create date: 27-09-2016    
-- Description: GetPreCheckInHotelData    
-- =============================================    
CREATE PROCEDURE [dbo].[USP_GetPreCheckInHotelBookedData]     
     
AS    
BEGIN    
DECLARE @uploadKey uniqueidentifier

 SELECT Top 1 @uploadKey = uploadKey FROM Trip.dbo.PreCheckInHotelBooked ORDER BY CreatedDate desc  
 
 SELECT * FROM Trip..PreCheckInHotelBooked  WHERE Status is NULL and UploadKey = @uploadKey 
     
END
GO
