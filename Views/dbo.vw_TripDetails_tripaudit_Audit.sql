SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vw_TripDetails_tripaudit_Audit]          
AS          
SELECT     ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder, 'air' AS TYPE, trip.tripKey, tripName, u.userFirstName, u.userLastName, u.userKey,           
trip.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey,(case when resp.actualAirPrice=0 then resp.searchAirPrice else resp.actualAirPrice end )  AS basecost, (case when resp.actualAirTax=0 then resp.searchAirTax else resp.actualAirTax end ) AS tax, seg.airSegmentMarketingAirlineCode AS vendorcode,           
vendor.ShortName AS VendorName, seg.airSegmentDepartureAirport, seg.airSegmentArrivalAirport, CONVERT(varchar(20), seg.airSegmentFlightNumber) AS flightNumber,           
seg.airSegmentDepartureDate AS departuredate, seg.airSegmentArrivalDate AS arrivaldate, NULL AS carType, CONVERT(varchar(20), seg.airLegNumber) AS Ratingtype,           
seg.airSegmentKey AS responseKey, seg.recordLocator AS vendorLocator,  Trip.siteKey, trip.createdDate, trip.tripRequestKey          
, '' As VehicleCompanyName          
,0 as NoofDays          
,'' as CityName          
,'' as StateCode          
,'' as CountryCode          
,'' as HotelRating      
, ISNULL(resp.discountedBaseFare,0) as DiscountFare          
FROM         Trip WITH (NOLOCK) INNER JOIN          
                      TripAirResponse resp WITH (NOLOCK) ON resp.tripGUIDKey=(case when trip.trippurchasedkey is not null then trip.trippurchasedkey else trip.tripsavedkey end ) 
                      INNER JOIN          
                      TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey INNER JOIN          
                      TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber LEFT OUTER JOIN          
                      AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode LEFT OUTER JOIN          
                      Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey          
WHERE     ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   AND Trip.tripStatusKey <> 17        
UNION          
SELECT     ROW_NUMBER() OVER (ORDER BY carresponsekey), 'car' AS TYPE, tripkey, tripName, u.userFirstName, u.userLastName, u.userKey,           
recordLocator, endDate, startDate, tripStatusKey, actualCarPrice, actualCarTax, carVendorKey,           
carCompanyName, carLocationCode, carLocationCode, NULL, PickUpdate, dropOutDate,           
SippCodeClass, NULL AS Ratingtype, t .carResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey          
, VehicleName As VehicleCompanyName          
,t.NoofDays          
,'' as CityName          
,'' as StateCode          
,'' as CountryCode          
,'' as HotelRating      
, 0 as  DiscountFare              
FROM         [vw_TripCarResponse_Audit] t WITH (NOLOCK) LEFT OUTER JOIN          
                      Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey          
UNION          
SELECT     ROW_NUMBER() OVER (ORDER BY hotelresponsekey), 'hotel' AS TYPE, tripkey, tripName, u.userFirstName, u.userLastName, u.userKey, recordLocator, endDate,           
startDate, tripStatusKey, actualHotelPrice, actualHotelTax, ChainCode, hotelname, cityname + ',' + StateCode, cityname + ',' + StateCode, NULL, checkindate,           
checkoutdate, NULL, Ratingtype, t .hotelResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey          
, '' As VehicleCompanyName          
,0 as NoofDays          
,t.CityName          
,t.StateCode          
,t.CountryCode          
,t.Rating as HotelRating      
,0 as DiscountFare          
FROM  vw_TripHotelResponse_tripaudit_Audit t WITH (NOLOCK) LEFT OUTER JOIN          
                      Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey
GO
