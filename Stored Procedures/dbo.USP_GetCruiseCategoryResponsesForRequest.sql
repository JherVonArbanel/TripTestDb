SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetCruiseCategoryResponsesForRequest] 37 
CREATE PROCEDURE [dbo].[USP_GetCruiseCategoryResponsesForRequest]
( @CruiseFareResponseKey VARCHAR(100)
 )
AS
BEGIN
	SELECT [CruiseCategoryResponseKey]
      ,CC.[CruiseFareResponseKey]
      ,[pricedCategory]
      ,[berthedCategory]
      ,[shipLocation]
      , SL.value AS ShipLocationDescription
      ,[maxCabinOccupancy]
      ,[indicators]
      ,CC.[StatusCode]
      ,[AmountQualifierCode] 
      ,[Amount]
      ,[breakdownCode]
      ,[breakdownQualifierCode]
  FROM [Trip].[dbo].[CruiseCategoryResponse] CC
  INNER JOIN CruiseFareResponse CF ON CC.CruiseFareResponseKey = CF.CruiseFareResponseKey
  INNER JOIN Cruise.dbo.ShipLocation SL ON SL.code=CC.shipLocation
  WHERE CC.StatusCode='AVL'  AND CC.CruiseFareResponseKey = @CruiseFareResponseKey
  ORDER BY ShipLocation

 END
GO
