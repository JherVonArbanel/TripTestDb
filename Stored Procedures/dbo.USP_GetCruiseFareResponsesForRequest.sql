SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetCruiseFareResponsesForRequest] 37 
CREATE PROCEDURE [dbo].[USP_GetCruiseFareResponsesForRequest]
( @CruiseResponseKey VARCHAR(100)
 )
AS
BEGIN
	SELECT CF.[CruiseFareResponseKey]
      ,CF.[CruiseResponseKey]
      ,CF.[FareCode]
      ,CF.[FareDesc]
      ,CF.[Remark]
      ,CF.[StatusCode]
      ,CF.[ModeOfTransportation]
	  ,CF.[MOTCity] 
      ,CF.[DiningLabel]
	  ,CF.[DiningStatus]
	  ,CF.[CurrencyQualifier]
	  ,CF.[CurrencyISOCode]
	FROM CruiseResponse CR
	INNER JOIN CruiseFareResponse CF ON CR.CruiseResponseKey = CF.CruiseResponseKey
	AND CR.CruiseResponseKey = @CruiseResponseKey

 END
GO
