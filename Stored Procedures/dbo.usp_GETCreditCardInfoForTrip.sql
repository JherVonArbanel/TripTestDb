SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GETCreditCardInfoForTrip] ( @tripKey as int )   
As   
   
 SELECT --TPC.*,  
	TPC.TripPassengerCreditCardInfoKey,
	TPC.TripKey,
	TPC.PassengerKey,
	TPC.TripTypeComponent,
	TPC.CreditCardKey,
	TPC.Active,
    CCPL.CreditCardProviderKey,  
    CC.creditCardKey,   
    CC.creditCardName ,  
    CC.creditCardDescription ,  
    CT.creditCardTypeName,   
    CC.creditCardTypeKey,  
    CC.creditCardName as 'account',  
    CCPl.CreditCardProviderName ,   
    CC.creditCardLastFourDigit,  
    CC.expiryMonth,  
    CC.expiryYear,  
    defaultCardFor,  
    CONVERT(VARCHAR, DecryptByKey(CC.CRDNumber)) AS creditCardnumber,  
    AD.addressLine1,  
    AD.addressLine2,  
    AD.city,  
    AD.countryCode,  
    AD.stateCode,  
    AD.zip         
   FROM  TripPassengerInfo TPI   
    INNER JOIN  TripPassengerCreditCardInfo TPC ON TPI.TripKey = TPC.TripKey   
     INNER JOIN Vault.dbo.CreditCard CC ON TPC.CreditCardKey = CC.creditCardKey    
    LEFT OUTER JOIN Vault.dbo.CreditCardProviderLookup CCPL ON CCPL.CreditCardProviderKey = CC.creditCardProviderkey   
    LEFT OUTER JOIN Vault.dbo.CreditCardTypeLookup CT ON CC.creditCardTypeKey = CT.creditCardTypeKey   
    LEFT OUTER JOIN Vault.dbo.[Address] AD ON AD.addressKey = CC.billingAddresskey   
    WHERE   TPI.TripKey = @TripKey  And TPI.Active = 1 and TPC.Active = 1   
    order by TPI.TripKey   
GO
