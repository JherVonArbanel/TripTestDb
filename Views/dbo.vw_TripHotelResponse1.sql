SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_TripHotelResponse1]
AS
SELECT     dbo.Trip.tripKey AS Expr2, dbo.Trip.tripName, HR.recordLocator AS Expr3, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, dbo.Trip.userKey, 
                      HR.hotelResponseKey AS Expr4, HR.supplierHotelKey AS Expr5, HR.supplierId AS Expr6, HR.minRate AS Expr7, HT.HotelName, ISNULL(HT.Rating, 0) AS Rating, 
                      HT.RatingType, HT.ChainCode, HT.HotelId, HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, 
                      HT.FaxNumber, HT.CityCode, AH.Distance, HR.checkInDate AS Expr8, HR.checkOutDate AS Expr9, HD.HotelDescription AS Expr10, HC.ChainName, 
                      HR.minRateTax AS Expr11, HR.SearchHotelPrice AS Expr12, HR.searchHotelTax AS Expr13, HR.actualHotelPrice AS Expr14, HR.actualHotelTax AS Expr15, 
                      HR.confirmationNumber AS Expr16, HR.isExpenseAdded AS Expr17, dbo.Trip.isBid, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey, 
                      HR.roomAmenities AS Expr18, HR.cancellationPolicy AS Expr19, HR.checkInInstruction AS Expr20, HR.rateDescription AS Expr21, HR.hotelDescription AS Expr1, 
                      HR.hotelRatePlanCode AS Expr22, HR.hotelTotalPrice AS Expr23, HR.hotelPriceType AS Expr24, HR.hotelTaxRate AS Expr25, HR.TripHotelResponseKey, 
                      HR.hotelResponseKey, HR.supplierHotelKey, HR.tripKey, HR.supplierId, HR.minRate, HR.minRateTax, HR.hotelDailyPrice, HR.hotelDescription, 
                      HR.hotelRatePlanCode, HR.hotelTotalPrice, HR.hotelPriceType, HR.hotelTaxRate, HR.rateDescription, HR.guaranteeCode, HR.SearchHotelPrice, HR.searchHotelTax, 
                      HR.actualHotelPrice, HR.actualHotelTax, HR.checkInDate, HR.checkOutDate, HR.recordLocator, HR.confirmationNumber, HR.CurrencyCodeKey, 
                      HR.PolicyReasonCodeID, HR.HotelPolicyKey, HR.PolicyResaonCode, HR.isExpenseAdded, HR.roomAmenities, HR.cancellationPolicy, HR.checkInInstruction, 
                      HR.hotelCheckInTime AS Expr26, HR.hotelCheckOutTime AS Expr27, HR.TripHotelResponseKey AS Expr28, HR.tripKey AS Expr29, HR.PolicyResaonCode AS Expr30, 
                      HR.HotelPolicyKey AS Expr31, HR.PolicyReasonCodeID AS Expr32, HR.CurrencyCodeKey AS Expr33, HR.hotelDailyPrice AS Expr34, 
                      HR.guaranteeCode AS Expr35
FROM         HotelContent.dbo.Hotels AS HT WITH (NOLOCK) RIGHT OUTER JOIN
                      HotelContent.dbo.SupplierHotels AS SH WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.AirportHotels AS AH WITH (NOLOCK) ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN
                      HotelContent.dbo.HotelDescriptions AS HD WITH (NOLOCK) ON SH.HotelId = HD.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.HotelChains AS HC WITH (NOLOCK) ON HT.ChainCode = HC.ChainCode INNER JOIN
                      dbo.Trip WITH (NOLOCK) ON HR.tripKey = dbo.Trip.tripKey
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[20] 2[33] 3) )"
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
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "HT"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 125
               Right = 441
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SH"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HR"
            Begin Extent = 
               Top = 126
               Left = 266
               Bottom = 245
               Right = 463
            End
            DisplayFlags = 280
            TopColumn = 29
         End
         Begin Table = "AH"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 204
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HD"
            Begin Extent = 
               Top = 246
               Left = 242
               Bottom = 365
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HC"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Trip"
            Begin Extent = 
               Top = 366
               Left = 246
               Bottom = 485
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
', 'SCHEMA', N'dbo', 'VIEW', N'vw_TripHotelResponse1', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 43
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
', 'SCHEMA', N'dbo', 'VIEW', N'vw_TripHotelResponse1', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_TripHotelResponse1', NULL, NULL
GO
