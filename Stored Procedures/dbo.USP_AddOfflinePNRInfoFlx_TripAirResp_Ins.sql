SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoFlx_TripAirResp_Ins]
(  
	@airResponseKey		UNIQUEIDENTIFIER, 
	@tripKey			INT, 
	@searchAirPrice		FLOAT, 
	@searchAirTax		FLOAT, 
	@actualAirPrice		FLOAT, 
	@actualAirTax		FLOAT, 
	@CurrencyCodeKey	NVARCHAR(20)
)AS  
  
BEGIN  

	INSERT INTO [TripAirResponse]([airResponseKey], [tripKey], [searchAirPrice], [searchAirTax], [actualAirPrice], 
		[actualAirTax], [CurrencyCodeKey]) 
	VALUES(@airResponseKey, @tripKey, @searchAirPrice, @searchAirTax, @actualAirPrice, @actualAirTax, @CurrencyCodeKey) 

	SELECT SCOPE_IDENTITY() 

END  

GO
