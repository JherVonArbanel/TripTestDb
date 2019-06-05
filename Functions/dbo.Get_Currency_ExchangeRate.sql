SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
SELECT TOP 59 * FROM vault..ExchangeRate ORDER BY 1 DESC
SELECT 1/0.8830313576
*/
-- =============================================
-- Author:		Niraj Jain
-- Create date: 19-04-2013
-- Description:	Get Currency exchange rate table to convert amount in given currency
-- =============================================
CREATE FUNCTION [dbo].[Get_Currency_ExchangeRate]
(	
	-- Add the parameters for the function here
	@currencyCode VARCHAR(5) 
)
RETURNS @exchangeRateTable TABLE ( ToCurrency VARCHAR(5), FromCurrency VARCHAR(5) , ExchangeRate FLOAT)

AS
BEGIN
	-- Add the SELECT statement with parameter references here
	DECLARE @toCurrencyExchangeAmount AS FLOAT = (
		SELECT exchangeRateAmount   
		from vault.dbo.ExchangeRate E  
			inner join vault.dbo.Currency C on e.currencyKey = c.currencyKey  
		WHERE currencyCode =@currencyCode AND exchangeRateDate = (SELECT  MAX(exchangeRateDate ) from vault.dbo.ExchangeRate )
		)	
 
	IF (@currencyCode = 'USD')
	BEGIN
		-- insert data into output table if currency is USD
		INSERT INTO @exchangeRateTable SELECT @currencyCode, C.currencyCode , E.exchangeRateAmount   
		FROM vault.dbo.ExchangeRate E left outer join vault.dbo.Currency C on e.currencyKey = c.currencyKey  
		WHERE exchangeRateDate = (SELECT  MAX(exchangeRateDate ) FROM vault.dbo.ExchangeRate )
	END
	ELSE
	BEGIN
		-- insert data into output table if currency is not USD
		--INSERT INTO @exchangeRateTable SELECT @currencyCode, C.currencyCode ,(1 / E.exchangeRateAmount) * @toCurrencyExchangeAmount
		INSERT INTO @exchangeRateTable SELECT @currencyCode, C.currencyCode ,(@toCurrencyExchangeAmount)
		FROM vault.dbo.ExchangeRate E inner join vault.dbo.Currency C on e.currencyKey = c.currencyKey
		WHERE exchangeRateDate = (SELECT  MAX(exchangeRateDate ) from vault.dbo.ExchangeRate )
	END
	RETURN
		
END
GO
