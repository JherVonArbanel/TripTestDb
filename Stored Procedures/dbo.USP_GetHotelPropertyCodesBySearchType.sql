SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 23-07-2018 02:44 pm  
-- Description: Get Sabre SupplierId by search type airport,city or hotelgroup  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_GetHotelPropertyCodesBySearchType]  
 -- Add the parameters for the stored procedure here  
 @id int,  
 @type varchar(50)  
AS  
BEGIN  
       
   SELECT * FROM Trip..HotelIdMappingForSearchType WHERE [type]=@type and pkId =@id  
           
END  
GO
