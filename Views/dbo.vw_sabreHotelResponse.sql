SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_sabreHotelResponse]  
AS  
SELECT     HR.hotelResponseKey, HR.supplierHotelKey, HR.hotelRequestKey, HR.supplierId, HR.minRate, HT.HotelName, ISNULL(HT.Rating, 0) AS Rating, HT.RatingType,   
                      HT.ChainCode, HT.HotelId, HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, HT.ZipCode, HT.PhoneNumber, HT.FaxNumber,   
                      HT.CityCode, AH.Distance, HQ.checkInDate, HQ.checkOutDate, REPLACE(HD.HotelDescription,'','') HotelDescription, HC.ChainName, HR.minRateTax, HotelContent.dbo.HotelImages.ImageURL,   
                      HR.preferenceOrder, HR.corporateCode, dbo.HotelDescription.hotelPolicy, dbo.HotelDescription.checkInInstruction, dbo.HotelDescription.tripAdvisorRating,   
                      dbo.HotelDescription.checkInTime, dbo.HotelDescription.checkOutTime  
FROM         HotelContent.dbo.SupplierHotels AS SH RIGHT OUTER JOIN  
                      dbo.HotelDescription RIGHT OUTER JOIN  
                      dbo.HotelResponse AS HR ON dbo.HotelDescription.hotelResponseKey = HR.hotelResponseKey ON SH.SupplierHotelId = HR.supplierHotelKey AND   
                      SH.SupplierFamily = HR.supplierId LEFT OUTER JOIN  
                      HotelContent.dbo.HotelImages LEFT OUTER JOIN  
                      HotelContent.dbo.Hotels AS HT ON HotelContent.dbo.HotelImages.HotelId = HT.HotelId ON SH.HotelId = HT.HotelId LEFT OUTER JOIN  
                      HotelContent.dbo.AirportHotels AS AH ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN  
                      dbo.HotelRequest AS HQ ON HR.hotelRequestKey = HQ.hotelRequestKey LEFT OUTER JOIN  
                      HotelContent.dbo.HotelDescriptions AS HD ON SH.HotelId = HD.HotelId LEFT OUTER JOIN  
                      HotelContent.dbo.HotelChains AS HC ON HT.ChainCode = HC.ChainCode  
WHERE     (HotelContent.dbo.HotelImages.ImageType = 'MediumThumbnail')  
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[39] 4[4] 2[53] 3) )"
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
         Top = -288
         Left = -221
      End
      Begin Tables = 
         Begin Table = "SH"
            Begin Extent = 
               Top = 5
               Left = 360
               Bottom = 120
               Right = 542
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HotelDescription"
            Begin Extent = 
               Top = 397
               Left = 395
               Bottom = 516
               Right = 550
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "HR"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 165
               Right = 170
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HotelImages (HotelContent.dbo)"
            Begin Extent = 
               Top = 308
               Left = 800
               Bottom = 525
               Right = 968
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HT"
            Begin Extent = 
               Top = 9
               Left = 644
               Bottom = 156
               Right = 825
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AH"
            Begin Extent = 
               Top = 25
               Left = 914
               Bottom = 259
               Right = 1072
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HQ"
            Begin Extent = 
               Top = 207
               Left = 541
               Bottom = 391
               Right = 725
            End
            DisplayF', 'SCHEMA', N'dbo', 'VIEW', N'vw_sabreHotelResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'lags = 280
            TopColumn = 0
         End
         Begin Table = "HD"
            Begin Extent = 
               Top = 186
               Left = 12
               Bottom = 411
               Right = 171
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HC"
            Begin Extent = 
               Top = 189
               Left = 177
               Bottom = 412
               Right = 347
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
      Begin ColumnWidths = 28
         Width = 284
         Width = 2370
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2250
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
', 'SCHEMA', N'dbo', 'VIEW', N'vw_sabreHotelResponse', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_sabreHotelResponse', NULL, NULL
GO
