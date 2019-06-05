SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_hotelDetails]
AS
SELECT     CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS hotelResponseKey, 0 AS supplierHotelKey, 0 AS hotelRequestKey, '' AS supplierId, 0 AS minRate, 
                      ISNULL(HS.HotelName, 'tourico') AS HotelName, ISNULL(HS.Rating, 4) AS Rating, HS.RatingType, HS.ChainCode, HS.HotelId, HS.Latitude, HS.Longitude, HS.Address1, 
                      HS.CityName, HS.StateCode, HS.CountryCode, HS.ZipCode, HS.PhoneNumber, HS.FaxNumber, HS.CityCode, ISNULL(AH.Distance, 3) AS Distance, 
                      '1900-01-01' AS checkInDate, '1900-01-01' AS checkOutDate, REPLACE(HD.HotelDescription, '', '') AS HotelDescription, HC.ChainName, 0 AS minRateTax, 
                      HotelContent.dbo.HotelImages.SupplierImageURL AS ImageURL, 0 AS preferenceOrder, '' AS corporateCode, '' AS hotelPolicy, '' AS checkInInstruction, 
                      '' AS tripAdvisorRating, '' AS checkInTime, '' AS checkOutTime, HS.richMediaUrl
FROM         HotelContent.dbo.Hotels AS HS LEFT OUTER JOIN
                      HotelContent.dbo.HotelDescriptions AS HD ON HS.HotelId = HD.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.HotelImages ON HotelContent.dbo.HotelImages.HotelId = HS.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.AirportHotels AS AH ON HS.HotelId = AH.HotelId AND HS.CityCode = AH.AirportCode LEFT OUTER JOIN
                      HotelContent.dbo.HotelChains AS HC ON HS.ChainCode = HC.ChainCode
GO
