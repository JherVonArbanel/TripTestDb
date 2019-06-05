SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vw_hotelDetailsNew]
AS
SELECT     CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS hotelResponseKey, 0 AS supplierHotelKey, 0 AS hotelRequestKey, '' AS supplierId, HS.LowRate AS minRate, ISNULL(HS.HotelName, 'tourico') 
                      AS HotelName, ISNULL(HS.Rating, 4) AS Rating, HS.RatingType, HS.ChainCode, HS.HotelId, HS.Latitude, HS.Longitude, HS.Address1, HS.CityName, HS.StateCode, HS.CountryCode, HS.ZipCode, 
                      HS.PhoneNumber, HS.FaxNumber, HS.CityCode, ISNULL(AH.Distance, 3) AS Distance, '1900-01-01' AS checkInDate, '1900-01-01' AS checkOutDate, REPLACE(HD.HotelDescription, '', '') 
                      AS HotelDescription, HC.ChainName, 0 AS minRateTax, HotelContent.dbo.HotelImages_Exterior.SupplierImageURL AS ImageURL, 0 AS preferenceOrder, '' AS corporateCode, '' AS hotelPolicy, 
                      '' AS checkInInstruction, HS.reviewRating AS tripAdvisorRating, '' AS checkInTime, '' AS checkOutTime, HS.richMediaUrl,PR.RegionID,PR.RegionName
FROM         HotelContent.dbo.Hotels AS HS LEFT OUTER JOIN
                      HotelContent.dbo.HotelDescriptions AS HD ON HS.HotelId = HD.HotelId LEFT OUTER JOIN
                      HotelContent.dbo.HotelImages_Exterior ON HotelContent.dbo.HotelImages_Exterior.HotelId = HS.HotelId AND HotelContent.dbo.HotelImages_Exterior.ImageType = 'Exterior' LEFT OUTER JOIN
                      HotelContent.dbo.AirportHotels AS AH ON HS.HotelId = AH.HotelId AND HS.CityCode = AH.AirportCode LEFT OUTER JOIN
                      HotelContent.dbo.HotelChains AS HC ON HS.ChainCode = HC.ChainCode LEFT OUTER JOIN 
                      HotelContent.dbo.RegionHotelIDMapping RM ON RM.HotelId = HS.HotelId LEFT OUTER JOIN 
					  HotelContent.dbo.ParentRegionList PR  ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood'

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
         Begin Table = "HS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HD"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 125
               Right = 444
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HotelImages (HotelContent.dbo)"
            Begin Extent = 
               Top = 6
               Left = 482
               Bottom = 125
               Right = 683
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AH"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 204
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HC"
            Begin Extent = 
               Top = 126
               Left = 242
               Bottom = 245
               Right = 412
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
         Or ', 'SCHEMA', N'dbo', 'VIEW', N'vw_hotelDetailsNew', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'= 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vw_hotelDetailsNew', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_hotelDetailsNew', NULL, NULL
GO
