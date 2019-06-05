SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vw_TripHotelResponseNew]
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
                      HR.hotelCheckOutTime, HR.TripHotelResponseKey AS Expr16, HR.PolicyResaonCode AS Expr17, HR.CurrencyCodeKey AS Expr18, 
                      HR.guaranteeCode AS Expr19
FROM         HotelContent.dbo.Hotels AS HT WITH (NOLOCK) RIGHT OUTER JOIN
                      HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.AirportHotels AS AH WITH (NOLOCK) ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN
                      HotelContent.dbo.HotelDescriptions AS HD WITH (NOLOCK) ON SH.HotelId = HD.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.HotelChains AS HC WITH (NOLOCK) ON HT.ChainCode = HC.ChainCode INNER JOIN
                      dbo.Trip WITH (NOLOCK) ON HR.tripKey = dbo.Trip.tripKey
WHERE     (ISNULL(HR.isDeleted, 0) = 0)
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "HT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SH"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 125
               Right = 439
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HR"
            Begin Extent = 
               Top = 6
               Left = 477
               Bottom = 125
               Right = 674
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AH"
            Begin Extent = 
               Top = 6
               Left = 712
               Bottom = 125
               Right = 878
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HD"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HC"
            Begin Extent = 
               Top = 126
               Left = 243
               Bottom = 245
               Right = 413
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Trip"
            Begin Extent = 
               Top = 126
               Left = 451
               Bottom = 245
               Right = 635
            End
            DisplayFlags = 280
            TopColumn = 0
        ', 'SCHEMA', N'dbo', 'VIEW', N'vw_TripHotelResponseNew', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N' End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
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
', 'SCHEMA', N'dbo', 'VIEW', N'vw_TripHotelResponseNew', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_TripHotelResponseNew', NULL, NULL
GO
