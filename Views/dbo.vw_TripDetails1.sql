SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE VIEW [dbo].[vw_TripDetails1]    
AS    
SELECT     ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder, 'air' AS TYPE, trip.tripKey, tripName, u.userFirstName, u.userLastName, u.userKey,     
trip.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, resp.actualAirPrice AS basecost, resp.actualAirTax AS tax, seg.airSegmentMarketingAirlineCode AS vendorcode,     
vendor .ShortName AS VendorName, seg.airSegmentDepartureAirport, seg.airSegmentArrivalAirport, CONVERT(varchar(20), seg.airSegmentFlightNumber) AS flightNumber,     
seg.airSegmentDepartureDate AS departuredate, seg.airSegmentArrivalDate AS arrivaldate, NULL AS carType, CONVERT(varchar(20), seg.airLegNumber) AS Ratingtype,     
seg.airSegmentKey AS responseKey, leg.recordLocator AS vendorLocator, Trip.siteKey, trip.createdDate, trip.tripRequestKey, '' AS VehicleCompanyName,     
0 AS NoofDays,  airLookup.CityName AS CityName, '' AS StateCode, '' AS CountryCode, '' AS HotelRating, '' AS HotelAddressLine1
FROM         Trip WITH (NOLOCK) INNER JOIN    
                      TripAirResponse resp WITH (NOLOCK) ON trip.tripKey = resp.tripKey INNER JOIN    
                      TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey INNER JOIN    
                      TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber LEFT OUTER JOIN    
                      AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode LEFT OUTER JOIN    
                      Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey  LEFT OUTER JOIN  
                      AirportLookup airLookup WITH (NOLOCK) ON ltrim(rtrim(seg.airSegmentArrivalAirport)) = airLookup.AirportCode  
WHERE     ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0    
UNION    
SELECT     ROW_NUMBER() OVER (ORDER BY carresponsekey), 'car' AS TYPE, tripkey, tripName, u.userFirstName, u.userLastName, u.userKey, recordLocator, endDate,     
startDate, tripStatusKey, actualCarPrice, actualCarTax, carVendorKey, carCompanyName, carLocationCode, carLocationCode, NULL, PickUpdate, dropOutDate,     
SippCodeClass, NULL AS Ratingtype, t .carResponseKey, t .recordLocator,t .siteKey, t .createdDate, t .tripRequestKey, VehicleName AS VehicleCompanyName,     
t .NoofDays, '' AS CityName, '' AS StateCode, '' AS CountryCode, '' AS HotelRating, '' AS HotelAddressLine1
FROM         vw_TRipCarResponse t WITH (NOLOCK) LEFT OUTER JOIN    
                      Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey    
UNION    
SELECT     ROW_NUMBER() OVER (ORDER BY hotelresponsekey), 'hotel' AS TYPE, tripkey, tripName, u.userFirstName, u.userLastName, u.userKey, recordLocator, endDate,     
startDate, tripStatusKey, actualHotelPrice, actualHotelTax, ChainCode, hotelname, cityname + ',' + StateCode, cityname + ',' + StateCode, NULL, checkindate,     
checkoutdate, NULL, Ratingtype, t .hotelResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey, '' AS VehicleCompanyName, 0 AS NoofDays,     
t .CityName, t .StateCode, t .CountryCode, t .Rating AS HotelRating, t.Address1 AS HotelAddressLine1
FROM         vw_TripHotelResponse t WITH (NOLOCK) LEFT OUTER JOIN    
                      Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey    

GO
