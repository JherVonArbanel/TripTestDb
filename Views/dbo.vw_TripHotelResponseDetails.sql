SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vw_TripHotelResponseDetails]    
AS    

SELECT   DISTINCT  HR.recordLocator, HR.hotelResponseKey, HR.supplierHotelKey, HR.supplierId, HR.minRate, HT.HotelName, ISNULL(HT.Rating, 0) AS Rating, HT.RatingType,       
                      HT.ChainCode, HT.HotelId, HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, HT.FaxNumber,       
                      HT.CityCode, AH.Distance, HR.checkInDate, HR.checkOutDate, HC.ChainName, HR.minRateTax, HR.SearchHotelPrice, HR.searchHotelTax, HR.actualHotelPrice,       
                      HR.actualHotelTax, HR.confirmationNumber, HR.isExpenseAdded, HR.roomAmenities, HR.cancellationPolicy, HR.checkInInstruction, HR.rateDescription,       
                      HR.hotelRatePlanCode, HR.hotelTotalPrice, HR.hotelPriceType,
                      HR.hotelTaxRate  AS hotelTaxRate,  /*added by pradeep/vivek for TFS : 17513,18719,19499,19445,19415  --AND HR.hotelTaxRate = 0*/
                      /*HR.hotelTaxRate ,  */ /*commented by pradeep/vivek for TFS : 17513,18719,19499,19445,19415*/
                      HR.TripHotelResponseKey, HR.hotelDailyPrice, HR.hotelDescription,       
                      HR.guaranteeCode, HR.CurrencyCodeKey, HR.PolicyReasonCodeID, HR.HotelPolicyKey, HR.PolicyResaonCode, ISNULL(HI.SupplierImageURL, CHI.ImageURL)       
                      AS ImageURL, CASE WHEN HR.hotelCheckInTime IS NULL OR      
                      HR.hotelCheckinTime = '' THEN HT.CheckInTime ELSE HR.hotelCheckInTime END AS hotelCheckInTime, CASE WHEN HR.hotelCheckOutTime IS NULL OR      
                      HR.hotelCheckOutTime = '' THEN HT.CheckOutTime ELSE HR.hotelCheckOutTime END AS hotelCheckOutTime, HR.tripGUIDKey, HR.HotelPolicy, HR.SupplierType,       
                      HR.hotelRoomTypeCode, HR.preferenceOrder, HR.contractCode, Ht.reviewRating AS tripAdvisorRating, hr.salesTaxAndHotelOccupancyTax,       
                      HR.originalHotelTotalPrice, HR.InvoiceNumber, HR.roomDescriptionShort,       
                      HR.RPH,  HR.IsPromoTrue, HR.PromoDescription, HR.AverageBaseRate, HR.PromoId,HR.MarketplaceMarginPercent, TP.PromotionDiscount , HR.IsChangeTripHotel      
					  ,HR.atMerchant, HR.rateKey
					FROM dbo.TripHotelResponse AS HR WITH (NOLOCK)       
                      LEFT OUTER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey 
						AND SH.SupplierFamily = HR.supplierId AND	SH.supplierHotelId = ISNULL(HR.HotelId, SH.supplierHotelId)
                      LEFT OUTER JOIN HotelContent.dbo.HotelDescriptions AS HD WITH (NOLOCK) ON SH.HotelId = HD.HotelId 
                      LEFT OUTER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK) ON ISNULL(HR.HotelId, SH.HotelId) = HT.HotelId  
                      LEFT OUTER JOIN HotelContent.dbo.AirportHotels AS AH WITH (NOLOCK) ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode 
                      LEFT OUTER JOIN HotelContent.dbo.HotelChains AS HC WITH (NOLOCK) ON HT.ChainCode = HC.ChainCode 
                      LEFT OUTER JOIN HotelContent.dbo.HotelImages_Exterior AS HI WITH (NOLOCK) ON HT.HotelId = HI.HotelId AND HI.ImageType = 'Exterior' 
                      LEFT OUTER JOIN CMS.dbo.CustomHotelImages AS CHI WITH (NOLOCK) ON HT.HotelId = CHI.HotelId AND CHI.OrderId = 1 
                      LEFT OUTER JOIN Trip..TripPromotionHistory TP ON TP.TripGuidKey = HR.tripGUIDKey     
          --LEFT OUTER JOIN HotelResponseDetail HRD on HRD.hotelResponseKey = HR.hotelResponseKey AND HRD.supplierHotelKey = HR.supplierHotelKey  /*added by pradeep/vivek for TFS : 17513,18719,19499,19445,19415*/
WHERE     (ISNULL(HR.isDeleted, 0) = 0)-- AND HR.TripHotelResponseKey =400449     
GO
