SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 25-09-2012 16:44  
-- Description: Add Hotel Response for static hotel display in hotel landing page (SEO).  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_AddHotelResponse]   
 @hotelRequestKey int=0,     
 @supplierHotelKey VARCHAR(50)='',  
 @supplierId Varchar(50)='HotelsCom',  
    @minRate float=0,   
    @hotelId VARCHAR(50)=''  
AS  
BEGIN  
    Declare @hotelResponseKey uniqueidentifier  
    If(@supplierHotelKey <> '0')
    BEGIN
		SELECT @hotelResponseKey = NEWID()  
		INSERT INTO HotelResponse(hotelResponseKey,hotelRequestKey,hotelId,minRate,supplierHotelKey, supplierId  )  
		VALUES (@hotelResponseKey, @hotelRequestKey, @hotelId, @minRate, @supplierHotelKey, @supplierId)  
    END
    Else
    BEGIN
	  SELECT @supplierHotelKey = supplierHotelId FROM HotelContent..SupplierHotels1 WHERE HotelId=@hotelId AND SupplierFamily='Tourico'
	  SET @supplierId = 'Tourico'
	  SELECT @hotelResponseKey = NEWID()  
	  INSERT INTO HotelResponse(hotelResponseKey,hotelRequestKey,hotelId,minRate,supplierHotelKey, supplierId  )  
	  VALUES (@hotelResponseKey, @hotelRequestKey, @hotelId, @minRate, @supplierHotelKey, @supplierId)  
   END
 SELECT @hotelResponseKey as hotelResponseKey  
END
GO
