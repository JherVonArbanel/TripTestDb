SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelImages] 
(  
 @HotelID INT  
)  
AS  
BEGIN  
  
 SELECT  max(ImageType) as Imagetype,max(SupplierImageURL) as ImageURL     
 FROM [HotelContent].[dbo].[HotelImages]   
 WHERE IsThumbnail =0 AND HotelId = @HotelID AND ImageType = 'Exterior'
 group by ImageType  
  
END
GO
