SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_TripDetails]    
AS    
SELECT     ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder, 'air' AS TYPE, trip.tripKey, tripName, u.userFirstName, u.userLastName, u.userKey,     
trip.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, resp.actualAirPrice AS basecost, resp.actualAirTax AS tax, seg.airSegmentMarketingAirlineCode AS vendorcode,     
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
                      TripAirResponse resp WITH (NOLOCK) ON trip.tripKey = resp.tripKey INNER JOIN    
                      TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey INNER JOIN    
                      TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber LEFT OUTER JOIN    
                      AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode LEFT OUTER JOIN    
                      Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey    
WHERE     ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0  AND Trip.tripStatusKey <> 17 
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
FROM         vw_TRipCarResponse t WITH (NOLOCK) LEFT OUTER JOIN    
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
FROM         vw_TripHotelResponse t WITH (NOLOCK) LEFT OUTER JOIN    
                      Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[18] 4[13] 2[49] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 29
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vw_TripDetails', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_TripDetails', NULL, NULL
GO
