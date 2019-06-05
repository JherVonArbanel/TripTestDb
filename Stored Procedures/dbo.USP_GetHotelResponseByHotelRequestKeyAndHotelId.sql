SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Rohita Patel>  
-- Create date: <25/07/2017>  
-- Description: <To get the min rate for all vendor>  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_GetHotelResponseByHotelRequestKeyAndHotelId]  
@requestId int ,        
@hotelId int     
   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    SELECT  minRate,minRateTax,supplierId FROM TRIP..HotelResponse  
    WHERE hotelRequestKey=@requestId and hotelId=@hotelId and supplierId='Sabre'
END
GO
