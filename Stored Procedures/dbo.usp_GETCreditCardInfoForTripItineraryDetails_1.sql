SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[usp_GETCreditCardInfoForTripItineraryDetails_1] ( @tripKey as int )   
As   
   
SELECT     TPI.TripPassengerInfoKey, TPI.TripKey, TPI.PassengerKey, TPI.PassengerTypeKey, TPI.TripRequestKey, TPI.IsPrimaryPassenger, TPI.AdditionalRequest, TPI.Active,   
                      TPI.PassengerEmailID, TPC.TripPassengerCreditCardInfoKey, TPC.UsedforAir, TPC.UsedforHotel, TPC.UsedforCar, TPC.TripKey AS Expr1, TPC.PassengerKey AS Expr2, TPC.TripTypeComponent, TPC.CreditCardKey,   
                      TPC.Active AS Expr3, TPC.creditCardDescription, TPC.creditCardLastFourDigit, TPC.expiryMonth, TPC.expiryYear, TPC.creditCardTypeKey,   
                      Vault.dbo.CreditCardTypeLookup.creditCardTypeKey AS Expr4, Vault.dbo.CreditCardTypeLookup.creditCardTypeName,   
                      Vault.dbo.CreditCardProviderLookup.CreditCardProviderKey, Vault.dbo.CreditCardProviderLookup.CreditCardProviderName, TPC.creditCardVendorCode, TPC.NameOnCard  
FROM         Vault.dbo.CreditCardTypeLookup RIGHT OUTER JOIN  
                      TripPassengerCreditCardInfo AS TPC ON Vault.dbo.CreditCardTypeLookup.creditCardTypeKey = TPC.creditCardTypeKey RIGHT OUTER JOIN  
                      TripPassengerInfo AS TPI ON TPC.TripKey = TPI.TripKey RIGHT OUTER JOIN  
                      Vault.dbo.CreditCardProviderLookup ON TPC.creditCardVendorCode = Vault.dbo.CreditCardProviderLookup.CreditCardProviderKey  
WHERE     (TPI.TripKey = @TripKey) AND (TPI.Active = 1) AND (TPC.Active = 1)  
ORDER BY TPI.TripKey
GO
