SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vw_hotelDetailedResponse1]  
AS  
SELECT     HR.hotelResponseKey, HR.supplierHotelKey, HR.hotelRequestKey, HR.supplierId, HR.minRate, HT.HotelName, HT.Rating, ISNULL(HT.RatingType,'') as RatingType , ISNULL(HT.ChainCode,'') As ChainCode  , HT.HotelId,   
                      HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode, ISNULL(HT.ZipCode,'')as ZipCode, ISNULL(HT.PhoneNumber,'') AS PhoneNumber, ISNULL(HT.FaxNumber,'') as FaxNumber, ISNULL(HT.cityCode,   
                      HR.CityCode) AS cityCode, ISNULL(AH.Distance, 3) AS Distance, HQ.checkInDate, HQ.checkOutDate, REPLACE(HD.HotelDescription, '', '') AS HotelDescription,   
                      ISNULL(HC.ChainName,'') as ChainName, HR.minRateTax, ISNULL(HotelContent.dbo.HotelImages_Exterior.SupplierImageURL, CHI.ImageURL) AS ImageURL, HR.preferenceOrder, ISNULL(HR.corporateCode,'') as corporateCode,   
                      dbo.HotelDescription.hotelPolicy, dbo.HotelDescription.checkInInstruction, HT.reviewRating AS tripAdvisorRating, dbo.HotelDescription.checkInTime,   
                      dbo.HotelDescription.checkOutTime, ISNULL(HT.richMediaUrl,'') as richMediaUrl,ISNULL(PR.RegionID,'') as RegionID,ISNULL(PR.RegionName,'') as RegionName
FROM         dbo.HotelResponse AS HR WITH ( NOLOCK)INNER JOIN  
                      HotelContent.dbo.SupplierHotels1 AS SH WITH ( NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey AND SH.SupplierFamily = HR.supplierId INNER JOIN  
                      HotelContent.dbo.Hotels AS HT WITH ( NOLOCK) ON SH.HotelId = HT.HotelId LEFT OUTER JOIN  
                      dbo.HotelDescription WITH ( NOLOCK) ON dbo.HotelDescription.hotelResponseKey = HR.hotelResponseKey LEFT OUTER JOIN  
                      HotelContent.dbo.HotelImages_Exterior WITH ( NOLOCK) ON HotelContent.dbo.HotelImages_Exterior.HotelId = HT.HotelId AND HotelContent.dbo.HotelImages_Exterior.ImageType = 'Exterior' LEFT OUTER JOIN  
                      HotelContent.dbo.AirportHotels AS AH WITH ( NOLOCK) ON HT.HotelId = AH.HotelId AND HT.CityCode = AH.AirportCode LEFT OUTER JOIN  
                      dbo.HotelRequest AS HQ WITH ( NOLOCK) ON HR.hotelRequestKey = HQ.hotelRequestKey LEFT OUTER JOIN  
                      HotelContent.dbo.HotelDescriptions AS HD WITH ( NOLOCK) ON SH.HotelId = HD.HotelId LEFT OUTER JOIN  
                      HotelContent.dbo.HotelChains AS HC WITH ( NOLOCK) ON HT.ChainCode = HC.ChainCode LEFT OUTER JOIN  
                      CMS.dbo.CustomHotelImages AS CHI  WITH ( NOLOCK) ON CHI.HotelId = HT.HotelId AND CHI.OrderId = 1  LEFT OUTER JOIN 
                      HotelContent.dbo.RegionHotelIDMapping RM ON RM.HotelId = HT.HotelId LEFT OUTER JOIN 
					  HotelContent.dbo.ParentRegionList PR WITH(NOLOCK) ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood'


GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[2] 2[39] 3) )"
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
         Begin Table = "HR"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SH"
            Begin Extent = 
               Top = 6
               Left = 254
               Bottom = 125
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HotelDescription"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 125
               Right = 638
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HotelImages (HotelContent.dbo)"
            Begin Extent = 
               Top = 6
               Left = 676
               Bottom = 125
               Right = 877
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HT"
            Begin Extent = 
               Top = 6
               Left = 915
               Bottom = 125
               Right = 1116
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
         Begin Table = "HQ"
            Begin Extent = 
               Top = 126
               Left = 242
               Bottom = 245
               Right = 434
            End
            DisplayFlags ', 'SCHEMA', N'dbo', 'VIEW', N'vw_hotelDetailedResponse1', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'= 280
            TopColumn = 0
         End
         Begin Table = "HD"
            Begin Extent = 
               Top = 126
               Left = 472
               Bottom = 245
               Right = 639
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HC"
            Begin Extent = 
               Top = 126
               Left = 677
               Bottom = 245
               Right = 847
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
', 'SCHEMA', N'dbo', 'VIEW', N'vw_hotelDetailedResponse1', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_hotelDetailedResponse1', NULL, NULL
GO
