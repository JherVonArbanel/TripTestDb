SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetCruiseHoldCabinResponsesForRequest] 
CREATE PROCEDURE [dbo].[USP_GetCruiseHoldCabinResponsesForRequest]
( @CruiseCabinResponseKey VARCHAR(100)
 )
AS
BEGIN
	SELECT 
	   [CruiseHoldCabinKey]
	  ,[CruiseCabinResponseKey]
      ,[DiningLabel]
      ,[DiningStatus]
      ,[InsuranceCode]
  FROM [Trip].[dbo].[CruiseHoldCabin] CH
  WHERE CH.CruiseCabinResponseKey = @CruiseCabinResponseKey

 END
GO
