SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[vw_TripSavedHotelResponse]
AS
SELECT     TS.tripSavedKey, TS.userKey, TR.tripKey, TR.tripName, TR.recordLocator, TR.startDate, TR.endDate, TR.tripStatusKey, TR.tripPurchasedKey, TR.agencyKey, 
                      TR.tripComponentType, TR.tripRequestKey, TR.CreatedDate, TR.meetingCodeKey, TR.deniedReason, TR.siteKey, TR.isOnlineBooking, TR.tripAdultsCount, 
                      TR.tripSeniorsCount, TR.tripChildCount, TR.tripInfantCount, TR.tripYouthCount, TR.noOfTotalTraveler, TR.noOfRooms, TR.noOfCars, 
                      THR.recordLocator AS hotelRecordLocater, THR.tripGUIDKey, THR.TripHotelResponseKey, THR.hotelResponseKey, THR.supplierHotelKey, THR.supplierId, 
                      THR.minRate, THR.minRateTax, THR.hotelDailyPrice, THR.hotelDescription, THR.hotelRatePlanCode, THR.hotelTotalPrice, THR.hotelPriceType, THR.hotelTaxRate, 
                      THR.rateDescription, THR.guaranteeCode, THR.SearchHotelPrice, THR.searchHotelTax, THR.actualHotelPrice, THR.actualHotelTax, THR.checkInDate, 
                      THR.checkOutDate, THR.confirmationNumber, THR.CurrencyCodeKey, THR.PolicyReasonCodeID, THR.HotelPolicyKey, THR.PolicyResaonCode, THR.isExpenseAdded, 
                      THR.roomAmenities, THR.cancellationPolicy, THR.checkInInstruction, THR.hotelCheckInTime, THR.hotelCheckOutTime, THR.status, THR.isDeleted, THR.vendorCode, 
                      THR.cityCode AS City, ISNULL(HT.Rating, 0) AS Rating, HT.RatingType, HT.ChainCode, HT.HotelId, HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, 
                      HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, HT.FaxNumber, HT.CityCode, TRQ.tripTo1, TR.isUserCreatedSavedTrip
FROM         HotelContent.dbo.Hotels AS HT WITH (NOLOCK) RIGHT OUTER JOIN
                      HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.TripHotelResponse AS THR WITH (NOLOCK) ON SH.SupplierHotelId = THR.supplierHotelKey AND SH.SupplierFamily = THR.supplierId ON HT.HotelId = SH.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.AirportHotels AS AH WITH (NOLOCK) ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN
                      HotelContent.dbo.HotelDescriptions AS HD WITH (NOLOCK) ON SH.HotelId = HD.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.HotelChains AS HC WITH (NOLOCK) ON HT.ChainCode = HC.ChainCode INNER JOIN
                      dbo.Trip AS TR WITH (NOLOCK) ON THR.tripGUIDKey = TR.tripSavedKey INNER JOIN
                      dbo.TripSaved AS TS ON TS.tripSavedKey = TR.tripSavedKey INNER JOIN
                      dbo.TripHotelResponse ON TS.tripSavedKey = dbo.TripHotelResponse.tripGUIDKey INNER JOIN
                      dbo.TripRequest TRQ ON TRQ.tripRequestKey = TR.tripRequestKey
WHERE dbo.TripHotelResponse.isDeleted = 0
/*WHERE     (TR.tripKey NOT IN
                          (SELECT     T.tripKey
                            FROM          dbo.Trip AS T INNER JOIN
                                                   dbo.TripHotelResponse AS TH ON T.tripPurchasedKey = TH.tripGUIDKey AND TH.isDeleted = 0))*/
GO
