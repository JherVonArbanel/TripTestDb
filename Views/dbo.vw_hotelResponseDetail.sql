SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_hotelResponseDetail]      
AS      
SELECT HS.Rating, HC.ChainName, HS.ChainCode, HR.minRate, HR.hotelRequestKey, 
			HREQ.checkInDate, HREQ.checkOutDate, (HR.minRate * DATEDIFF(day, HREQ.checkInDate, HREQ.checkOutDate)) AS TotalPrice
FROM         dbo.HotelResponse AS HR INNER JOIN      
              HotelContent.dbo.SupplierHotels1 AS SH ON SH.SupplierHotelId =     
              HR.supplierHotelKey INNER JOIN      
              HotelContent.dbo.Hotels AS HS ON HS.HotelId = SH.HotelId INNER JOIN      
              HotelContent.dbo.HotelChains AS HC ON HC.ChainCode = HS.ChainCode INNER JOIN
              HotelRequest AS HREQ ON HREQ.hotelRequestKey = HR.hotelRequestKey
GROUP BY HS.ChainCode, HC.ChainName, HR.minRate, HR.hotelRequestKey, HS.Rating, 
	HREQ.checkInDate, HREQ.checkOutDate
GO
