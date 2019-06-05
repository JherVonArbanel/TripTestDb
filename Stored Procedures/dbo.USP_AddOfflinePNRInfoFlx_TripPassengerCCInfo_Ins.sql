SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoFlx_TripPassengerCCInfo_Ins]
(  
	@TripKey INT, 
	@PassengerKey INT, 
	@TripTypeComponent INT, 
	@CreditCardKey INT,
	@creditCardVendorCode NCHAR(4), 
	@creditCardDescription VARCHAR(50), 
	@creditCardLastFourDigit INT, 
	@ExpiryMonth INT, 
	@ExpiryYear INT, 
	@creditCardTypeKey INT
)
AS  
  
BEGIN  

	INSERT INTO TripPassengerCreditCardInfo(TripKey, PassengerKey, TripTypeComponent, CreditCardKey, Active, 
		creditCardVendorCode, creditCardDescription, creditCardLastFourDigit, ExpiryMonth, ExpiryYear, creditCardTypeKey)
	VALUES (@TripKey, @PassengerKey, @TripTypeComponent, @CreditCardKey, 1, 
		@creditCardVendorCode, @creditCardDescription, @creditCardLastFourDigit, @ExpiryMonth, @ExpiryYear, @creditCardTypeKey)

END  

GO
