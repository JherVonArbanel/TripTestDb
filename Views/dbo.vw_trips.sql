SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_trips]
AS
SELECT     dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, dbo.Trip.recordLocator, dbo.Trip.startDate, dbo.Trip.endDate, dbo.Trip.tripStatusKey, 
                      dbo.Trip.agencyKey, dbo.Trip_carResponse.carResponseKey, dbo.Trip_airResponse.airResponseKey, 
                      dbo.Trip_hotelResponse.hotelResponseKey
FROM         dbo.Trip INNER JOIN
                      dbo.Trip_airResponse ON dbo.Trip.tripKey = dbo.Trip_airResponse.tripKey INNER JOIN
                      dbo.Trip_carResponse ON dbo.Trip.tripKey = dbo.Trip_carResponse.tripKey INNER JOIN
                      dbo.Trip_hotelResponse ON dbo.Trip.tripKey = dbo.Trip_hotelResponse.tripKey
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[48] 4[29] 2[5] 3) )"
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
         Begin Table = "Trip"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 242
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Trip_airResponse"
            Begin Extent = 
               Top = 14
               Left = 453
               Bottom = 99
               Right = 611
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Trip_carResponse"
            Begin Extent = 
               Top = 237
               Left = 473
               Bottom = 322
               Right = 634
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Trip_hotelResponse"
            Begin Extent = 
               Top = 129
               Left = 633
               Bottom = 229
               Right = 830
            End
            DisplayFlags = 280
            TopColumn = 0
         End
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
', 'SCHEMA', N'dbo', 'VIEW', N'vw_trips', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_trips', NULL, NULL
GO
