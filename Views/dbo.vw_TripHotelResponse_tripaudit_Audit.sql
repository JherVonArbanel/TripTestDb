SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_TripHotelResponse_tripaudit_Audit]            
AS            
SELECT     dbo.Trip.tripKey, dbo.Trip.tripName, HR.recordLocator, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, dbo.Trip.userKey, HR.hotelResponseKey,             
                      HR.supplierHotelKey, HR.supplierId, HR.minRate, HT.HotelName, ISNULL(HT.Rating, 0) AS Rating, HT.RatingType, HT.ChainCode, HT.HotelId, HT.Latitude,             
                      HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, HT.FaxNumber, HT.CityCode, AH.Distance, HR.checkInDate,             
                      HR.checkOutDate, HC.ChainName, HR.minRateTax, HR.SearchHotelPrice, HR.searchHotelTax, HR.actualHotelPrice, HR.actualHotelTax, HR.confirmationNumber,             
                      HR.isExpenseAdded, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey, HR.roomAmenities, HR.cancellationPolicy, HR.checkInInstruction,             
                      HR.rateDescription, HR.hotelRatePlanCode, HR.hotelTotalPrice, HR.hotelPriceType, HR.hotelTaxRate, HR.TripHotelResponseKey, HR.hotelDailyPrice,             
                      HR.hotelDescription, HR.hotelRatePlanCode AS Expr1, HR.hotelTotalPrice AS Expr2, HR.hotelPriceType AS Expr3, HR.hotelTaxRate AS Expr4, HR.guaranteeCode,             
                      HR.SearchHotelPrice AS Expr5, HR.searchHotelTax AS Expr6, HR.actualHotelPrice AS Expr7, HR.actualHotelTax AS Expr8, HR.checkInDate AS Expr9,             
                      HR.checkOutDate AS Expr10, HR.confirmationNumber AS Expr11, HR.CurrencyCodeKey, HR.PolicyReasonCodeID, HR.HotelPolicyKey, HR.PolicyResaonCode,             
                      HR.isExpenseAdded AS Expr12, HR.roomAmenities AS Expr13, HR.cancellationPolicy AS Expr14, HR.checkInInstruction AS Expr15, HR.hotelCheckInTime,             
                      HR.hotelCheckOutTime, HR.TripHotelResponseKey AS Expr16, HR.PolicyResaonCode AS Expr17, HR.CurrencyCodeKey AS Expr18, HR.guaranteeCode AS Expr19,             
                      HR.tripGUIDKey,HR.HotelPolicy            
FROM         HotelContent.dbo.Hotels AS HT WITH (NOLOCK) RIGHT OUTER JOIN            
                      HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) RIGHT OUTER JOIN            
                      dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId LEFT OUTER JOIN            
                      HotelContent.dbo.AirportHotels AS AH WITH (NOLOCK) ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN            
                      HotelContent.dbo.HotelDescriptions AS HD WITH (NOLOCK) ON SH.HotelId = HD.HotelId LEFT OUTER JOIN            
                      HotelContent.dbo.HotelChains AS HC WITH (NOLOCK) ON HT.ChainCode = HC.ChainCode LEFT OUTER JOIN                      
                      dbo.Trip WITH (NOLOCK) ON dbo.Trip.tripStatusKey <> 17  And  HR.tripGUIDKey = (case when dbo.Trip.tripPurchasedKey is not null then dbo.Trip.tripPurchasedKey else dbo.Trip.tripsavedkey end )            
WHERE SH.SupplierFamily='Sabre'                      
                      
UNION            
SELECT     dbo.Trip.tripKey, dbo.Trip.tripName, HR.recordLocator, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, dbo.Trip.userKey, HR.hotelResponseKey,             
                      HR.supplierHotelKey, HR.supplierId, HR.minRate, HT.HotelName, ISNULL(HT.Rating, 0) AS Rating, HT.RatingType, HT.ChainCode, HT.HotelId, HT.Latitude,             
                      HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, HT.FaxNumber, HT.CityCode, AH.Distance, HR.checkInDate,             
                      HR.checkOutDate, HC.ChainName, HR.minRateTax, HR.SearchHotelPrice, HR.searchHotelTax, HR.actualHotelPrice, HR.actualHotelTax, HR.confirmationNumber,             
                      HR.isExpenseAdded, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey, HR.roomAmenities, HR.cancellationPolicy, HR.checkInInstruction,             
                      HR.rateDescription, HR.hotelRatePlanCode, HR.hotelTotalPrice, HR.hotelPriceType, HR.hotelTaxRate, HR.TripHotelResponseKey, HR.hotelDailyPrice,             
            HR.hotelDescription, HR.hotelRatePlanCode AS Expr1, HR.hotelTotalPrice AS Expr2, HR.hotelPriceType AS Expr3, HR.hotelTaxRate AS Expr4, HR.guaranteeCode,             
                      HR.SearchHotelPrice AS Expr5, HR.searchHotelTax AS Expr6, HR.actualHotelPrice AS Expr7, HR.actualHotelTax AS Expr8, HR.checkInDate AS Expr9,             
                      HR.checkOutDate AS Expr10, HR.confirmationNumber AS Expr11, HR.CurrencyCodeKey, HR.PolicyReasonCodeID, HR.HotelPolicyKey, HR.PolicyResaonCode,             
                      HR.isExpenseAdded AS Expr12, HR.roomAmenities AS Expr13, HR.cancellationPolicy AS Expr14, HR.checkInInstruction AS Expr15, HR.hotelCheckInTime,             
                      HR.hotelCheckOutTime, HR.TripHotelResponseKey AS Expr16, HR.PolicyResaonCode AS Expr17, HR.CurrencyCodeKey AS Expr18, HR.guaranteeCode AS Expr19,             
                      HR.tripGUIDKey,HR.HotelPolicy            
FROM         HotelContent.dbo.Hotels AS HT WITH (NOLOCK) RIGHT OUTER JOIN            
                      HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK)  RIGHT OUTER JOIN            
                      dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId  LEFT OUTER JOIN            
                      HotelContent.dbo.AirportHotels AS AH WITH (NOLOCK) ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN            
                      HotelContent.dbo.HotelDescriptions AS HD WITH (NOLOCK) ON SH.HotelId = HD.HotelId LEFT OUTER JOIN            
                      HotelContent.dbo.HotelChains AS HC WITH (NOLOCK) ON HT.ChainCode = HC.ChainCode INNER JOIN            
                      dbo.Trip WITH (NOLOCK) ON dbo.Trip.tripStatusKey <> 17  And (HR.tripGUIDKey = (case when dbo.Trip.tripPurchasedKey is not null then dbo.Trip.tripPurchasedKey else dbo.Trip.tripsavedkey end )     
                      AND (hr.tripKey IS NULL OR            
                      hr.tripKey = 0))            
WHERE     (ISNULL(HR.isDeleted, 0) = 0) AND SH.SupplierFamily='Sabre'
GO
