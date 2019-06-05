SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetCruiseCabinResponsesForRequest] 37 
CREATE PROCEDURE [dbo].[USP_GetCruiseCabinResponsesForRequest]
( @CruiseCategoryResponseKey VARCHAR(100)
 )
AS
BEGIN
	SELECT [CruiseCabinResponseKey]
      ,CC.[CruiseCategoryResponseKey]
      ,[cabinNbr]
      ,[remark]
      ,[positionInShip]
      ,[maxOccupancy]
      ,[deckId]
      ,[bedType]
      ,[bedConfiguration]
      ,CC.[cabinStatus]
  FROM [Trip].[dbo].[CruiseCabinResponse] CC
  INNER JOIN CruiseCategoryResponse CF ON CC.CruiseCategoryResponseKey = CF.CruiseCategoryResponseKey
	AND CF.CruiseCategoryResponseKey = @CruiseCategoryResponseKey

 END
GO
