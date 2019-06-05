SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_sabreCacheCarResponse]
AS
SELECT     dbo.CarResponse.carResponseKey, dbo.CarResponse.carRequestKey, dbo.CarResponse.carVendorKey, dbo.CarResponse.supplierId, 
                      dbo.CarResponse.carCategoryCode, dbo.CarResponse.carLocationCode, dbo.CarResponse.carLocationCategoryCode, dbo.CarResponse.minRate AS PerDayRate, 
                      CarContent.dbo.SabreVehicles.VehicleName, SabreLocations_1.LocationName AS pickupLocationName, 
                      SabreLocations_1.LocationAddress1 AS pickupLocationAddress, SabreLocations_1.Latitude AS pickupLatitude, SabreLocations_1.Longitude AS pickupLongitude, 
                      SabreLocations_1.ZipCode AS pickupZipCode, CarContent.dbo.SabreLocations.Latitude AS dropoffLatitude, 
                      CarContent.dbo.SabreLocations.Longitude AS dropoffLongitude, CarContent.dbo.SabreLocations.ZipCode AS dropoffZipCode, 
                      CarContent.dbo.SabreLocations.LocationAddress1 AS dropoffLocationAddress, CarContent.dbo.SabreLocations.LocationName AS dropoffLocationName, 
                      dbo.CarRequest.pickupDate, dbo.CarRequest.dropoffDate, CarContent.dbo.SippCodes.SippCodeDescription, CarContent.dbo.SippCodes.SippCodeTransmission, 
                      CarContent.dbo.SippCodes.SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, CarContent.dbo.SippCodes.SippCodeClass, 
                      CarContent.dbo.SabreLocations.LocationCity AS dropoffCity, CarContent.dbo.SabreLocations.Locationstate AS dropoffState, 
                      CarContent.dbo.SabreLocations.LocationCountry AS dropoffCountry, SabreLocations_1.LocationCity AS pickupCity, SabreLocations_1.Locationstate AS pickupState, 
                      SabreLocations_1.LocationCountry AS pickupCountry, dbo.CarResponse.minRateTax, dbo.CarResponse.TotalChargeAmt, dbo.CarResponse.minRate, 
                      CarContent.dbo.SabreVehicles.PsgrCapacity AS passenger, CarContent.dbo.SabreVehicles.Baggage, dbo.CarResponse.MileageAllowance, 
                      dbo.CarResponse.RatePlan, dbo.CarResponse.contractCode,dbo.CarResponse.OperationTimeStart,dbo.CarResponse.OperationTimeEnd
FROM         CarContent.dbo.CarCompanies WITH (NOLOCK) 
					  LEFT OUTER JOIN  dbo.CarResponse ON CarContent.dbo.CarCompanies.CarCompanyCode = dbo.CarResponse.carVendorKey 
					  INNER JOIN  CarContent.dbo.SippCodes WITH (NOLOCK) ON dbo.CarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
					  INNER JOIN  CarContent.dbo.SabreVehicles WITH (NOLOCK) ON dbo.CarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
									AND dbo.CarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
									AND dbo.CarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
									AND dbo.CarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode 
					  INNER JOIN  CarContent.dbo.SabreLocations WITH (NOLOCK) ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode 
					  INNER JOIN  CarContent.dbo.SabreLocations AS SabreLocations_1 WITH (NOLOCK) ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode 
									AND SabreLocations_1.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
									AND SabreLocations_1.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
					  INNER JOIN dbo.CarRequest WITH (NOLOCK) ON dbo.CarResponse.carRequestKey = dbo.CarRequest.carRequestKey 
									AND dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationAirportCode 
									AND dbo.CarRequest.dropoffCityCode = CarContent.dbo.SabreLocations.LocationCategoryCode 
									AND dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationAirportCode 
									AND dbo.CarRequest.pickupCityCode = SabreLocations_1.LocationCategoryCode

GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'              Bottom = 480
               Right = 200
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
      Begin ColumnWidths = 31
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2190
         Width = 1500
         Width = 1500
         Width = 2715
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2610
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
         Column = 2475
         Alias = 3855
         Table = 7785
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
', 'SCHEMA', N'dbo', 'VIEW', N'vw_sabreCacheCarResponse', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_sabreCacheCarResponse', NULL, NULL
GO
