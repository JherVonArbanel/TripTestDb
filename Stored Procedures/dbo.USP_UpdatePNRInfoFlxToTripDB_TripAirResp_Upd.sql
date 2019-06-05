SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdatePNRInfoFlxToTripDB_TripAirResp_Upd]
(  
	@searchAirPrice FLOAT,
	@searchAirTax FLOAT,
	@actualAirPrice FLOAT,
	@actualAirTax FLOAT,
	@CurrencyCodeKey NVARCHAR(10),
	@airResponseKey UNIQUEIDENTIFIER
)
AS  
  
BEGIN  

	UPDATE  [TripAirResponse] 
	SET searchAirPrice = @searchAirPrice, 
		searchAirTax = @searchAirTax, 
		actualAirPrice = @actualAirPrice, 
		actualAirTax = @actualAirTax, 
		CurrencyCodeKey = @CurrencyCodeKey 
	WHERE airResponseKey = @airResponseKey
 
END  

GO
