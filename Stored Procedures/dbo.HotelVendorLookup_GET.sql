SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[HotelVendorLookup_GET] 
AS 
BEGIN 

	SELECT hotelVendorCode, ISNULL(CAST(hotelVendorName AS VARCHAR(50)),'') + '          ('
      + COALESCE(hotelVendorCode,'') + ')' as hotelVendorName
	FROM HotelVendorLookup 
	ORDER BY hotelVendorName ASC

END
GO
