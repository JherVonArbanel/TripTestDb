SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--
-- Description:	update existing rows in TripPassengerCreditCardInfo table after new columns inserted(depency removed from CreditCard table in vault Db)
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateExistingRecInTripPassengerCreditCardInfoForCCInfo] 
AS
BEGIN
	
UPDATE TripPassengerCreditCardInfo 
SET creditCardVendorCode = CC.creditCardProviderKey,
       creditCardDescription = CC.creditCardDescription,
       creditCardLastFourDigit = CC.creditCardLastFourDigit ,
       expiryMonth = CC.expiryMonth,
       expiryYear = CC.expiryYear,
       creditCardTypeKey = CC.creditCardTypeKey
FROM vault.dbo.CreditCard CC
inner join TripPassengerCreditCardInfo TPC on TPC.CreditCardKey = CC.creditCardKey
--WHERE TPC.CreditCardKey = CC.creditCardKey
   
END
GO
