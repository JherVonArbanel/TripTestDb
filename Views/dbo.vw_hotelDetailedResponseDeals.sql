SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_hotelDetailedResponseDeals]
AS
SELECT     HR.hotelResponseKey, HR.supplierHotelKey, HR.hotelRequestKey, HR.supplierId, HR.minRate, HT.HotelName, HT.Rating, HT.RatingType, HT.ChainCode, HT.HotelId, 
                      HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, HT.FaxNumber, HT.CityCode, 
                      ISNULL(AH.Distance, 3) AS Distance, HQ.checkInDate, HQ.checkOutDate, REPLACE(HD.HotelDescription, '', '') AS HotelDescription, HC.ChainName, HR.minRateTax, 
                      HotelContent.dbo.HotelImages.SupplierImageURL AS ImageURL, HR.preferenceOrder, HR.corporateCode, dbo.HotelDescription.hotelPolicy, 
                      dbo.HotelDescription.checkInInstruction, HR.tripAdvisorRating, dbo.HotelDescription.checkInTime, dbo.HotelDescription.checkOutTime, HT.richMediaUrl
FROM         dbo.HotelResponse AS HR LEFT OUTER JOIN
                      HotelContent.dbo.SupplierHotels1 AS SH ON SH.SupplierHotelId = HR.supplierHotelKey AND SH.SupplierFamily = HR.supplierId LEFT OUTER JOIN
                      dbo.HotelDescription ON dbo.HotelDescription.hotelResponseKey = HR.hotelResponseKey LEFT OUTER JOIN
                      HotelContent.dbo.HotelImages LEFT OUTER JOIN
                      HotelContent.dbo.Hotels AS HT ON HotelContent.dbo.HotelImages.HotelId = HT.HotelId ON SH.HotelId = HT.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.AirportHotels AS AH ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN
                      dbo.HotelRequest AS HQ ON HR.hotelRequestKey = HQ.hotelRequestKey LEFT OUTER JOIN
                      HotelContent.dbo.HotelDescriptions AS HD ON SH.HotelId = HD.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.HotelChains AS HC ON HT.ChainCode = HC.ChainCode
GO
