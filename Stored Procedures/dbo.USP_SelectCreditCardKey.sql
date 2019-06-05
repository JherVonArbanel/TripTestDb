SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_SelectCreditCardKey]
(  
	@LastFourDigit INT,
	@userKey INT
)
AS  
  
BEGIN  

	SELECT creditCardKey, defaultCardfor, creditCardTypeKey, ExpiryMonth, ExpiryYear 
	FROM Vault.dbo.[CreditCard] 
	WHERE creditCardLastFourDigit = @LastFourDigit AND creditCarduserKey = @userKey AND isDeleted = 0 

END  

GO
