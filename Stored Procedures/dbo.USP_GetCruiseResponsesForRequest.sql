SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [USP_GetCruiseResponsesForRequest] 33 
CREATE PROCEDURE [dbo].[USP_GetCruiseResponsesForRequest]
( @CruiseRequestKey int ,
  @CruiseLines varchar(10)='',
  @sortField varchar(50)=''
 )
AS
BEGIN
	SELECT vwCruiseResponse.[CruiseResponseKey]
      ,vwCruiseResponse.[CruiseRequestKey]
      ,vwCruiseResponse.[CruiseLineCode]
      ,vwCruiseResponse.[CruiseLineName]
      ,vwCruiseResponse.[ShipCode]
      ,vwCruiseResponse.[ShipName]
      ,vwCruiseResponse.[SailingDepartureDate]
      ,vwCruiseResponse.[SailingDuration]
      ,vwCruiseResponse.[ArrivalPort]
      ,vwCruiseResponse.[DeparturePort]
      ,vwCruiseResponse.[DepartureCityName]
      ,vwCruiseResponse.[RegionCode]
      ,vwCruiseResponse.[RegionName]
      ,vwCruiseResponse.[NoofPorts]
      ,vwCruiseResponse.[SailingStatusCode]
      ,vwCruiseResponse.[ModeOfTransportation]
      ,vwCruiseResponse.[MOTCity]
      ,vwCruiseResponse.[CurrencyQualifier]
      ,vwCruiseResponse.[CurrencyISOCode]
      ,vwCruiseResponse.[CruiseVoyageNo]
      
	FROM vw_CruiseResponse vwCruiseResponse
	INNER JOIN CruiseResponse CR ON CR.CruiseRequestKey = vwCruiseResponse.CruiseRequestKey AND Cr.CruiseResponseKey = vwCruiseResponse.CruiseResponseKey
	WHERE CR.CruiseRequestKey=@CruiseRequestKey
	--ORDER BY 
 END
GO
