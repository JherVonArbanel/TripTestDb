SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CruiseCategoryResponses_GET]    
( 
  @CruiseCategoryResponseKey UNIQUEIDENTIFIER= NULL   
 )    
AS    
BEGIN    

	SELECT [CruiseCategoryResponseKey]
      ,[CruiseFareResponseKey]
      ,[pricedCategory]
      ,[berthedCategory]
      ,[shipLocation]
      , SL.value as ShipLocationDescription
      ,[maxCabinOccupancy]
      ,[indicators]
      ,[StatusCode]
      ,[AmountQualifierCode] 
      ,[Amount]
      ,[breakdownCode]
      ,[breakdownQualifierCode]
  FROM [Trip].[dbo].[CruiseCategoryResponse] CC
      INNER JOIN Cruise.dbo.ShipLocation SL ON SL.code=CC.shipLocation
      WHERE CruiseCategoryResponseKey =  @CruiseCategoryResponseKey
      AND StatusCode = 'AVL'
	 
 END
GO
