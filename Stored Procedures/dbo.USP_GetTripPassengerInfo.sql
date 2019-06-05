SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
/*  
USP_GetTripPassengerInfo 3875,794  
USP_GetTravelInfoAsPerRequestID 3522  
select * from TripPassengerInfo  
select * from TripPassengerInfo  
  
select * from PassengerTypeLookUp  
*/  
CREATE Procedure [dbo].[USP_GetTripPassengerInfo]  
@TripRequestKey Int,  
@TripKey Int,  
@UserKey  Int= 0 ,  
@CompanyKey Int = 0 ,  
@AgencyKey Int = 0   
  
AS  
BEGIN  
  
IF NOT  Exists (SELECT * FROM Vault.dbo.GetAllArrangees(@UserKey,@CompanyKey ))  
RETURN;   
  
  
 SELECT DISTINCT TPI.TripKey, T.recordLocator     
 FROM TripPassengerInfo TPI inner join Trip T on TPI.TripKey = T.tripKey   
 and T.tripRequestKey = TPI.TripRequestKey    
 WHERE  TPI.TripKey = @TripKey And TPI.Active = 1  and   T.tripStatusKey <>17     order by TripKey  
  
  
 SELECT TP.TripKey , ISNULL( TP.IsPrimaryPassenger, 0 ) as  IsPrimaryPassenger  , TP.PassengerKey, TP.PassengerTypeKey,PTL.PassengerTypeName,  
  TP.TripRequestKey, u.userKey , U.userFirstName , U.userLastName , UP.userEmail  as EmailAddress  , u.userBirthdate ,UP.cellPhone,  
   UP.homePhone, UP.workPhone  , U.userGender , TP.AdditionalRequest, U.agencyKey , U.companyKey, TP.PassengerFirstName, TP.PassengerLastName   
   
  FROM TripPassengerInfo  TP  
  INNER JOIN  Vault.dbo.[User]   U on TP.PassengerKey = U.userKey   
  INNER JOIN Vault.dbo.[UserProfile]   UP ON UP.userKey = U.userKey   
  Left join PassengerTypeLookUp PTL on TP.PassengerTypeKey = PTL.PassengerTypeKey  
 WHERE  TP.TripKey = @TripKey And TP.Active = 1  
 order by TP.TripKey  
   
 SELECT TPC.*,  
    CCPL.CreditCardProviderKey,  
    CC.creditCardKey,   
    CC.creditCardName ,      
    CT.creditCardTypeName,   
    CC.creditCardTypeKey,  
    CC.creditCardName as 'account',  
    CCPl.CreditCardProviderName ,   
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
    WHERE  TPI.TripKey = @TripKey  And TPI.Active = 1 and TPC.Active = 1   
    order by TPI.TripKey   
      
  
select TAP.*   from TripPassengerInfo TPI   
  INNER JOIN  TripPassengerAirPreference TAP ON TPI.TripKey = TAP.TripKey   
  WHERE  TPI.TripKey = @TripKey  And TPI.Active = 1 and TAP.Active = 1   
  order by TPI.TripKey  
  
  
select TAVP.* from TripPassengerInfo TPI   
  INNER JOIN  TripPassengerAirVendorPreference TAVP ON TPI.TripKey = TAVP.TripKey   
  WHERE  TPI.TripKey = @TripKey  And TPI.Active = 1 and TAVP.Active = 1   
  order by TPI.TripKey  
  
    
select TCPI.* from TripPassengerInfo TPI   
  INNER JOIN  TripPassengerCarPreference TCPI ON TCPI.TripKey = TPI.TripKey   
  WHERE  TPI.TripKey = @TripKey  And TPI.Active = 1 and TCPI.Active = 1   
  order by TPI.TripKey  
  
  
select TCVP.* from TripPassengerInfo TPI   
  INNER JOIN  TripPassengerCarVendorPreference TCVP ON TCVP.TripKey = TPI.TripKey   
  WHERE  TPI.TripKey = @TripKey  And TPI.Active = 1 and TCVP.Active = 1   
  order by TPI.TripKey  
  
      
select TCPI.* from TripPassengerInfo TPI   
  INNER JOIN  TripPassengerHotelPreference TCPI ON TCPI.TripKey = TPI.TripKey   
  WHERE TPI.TripKey = @TripKey  And TPI.Active = 1 and TCPI.Active = 1   
  order by TPI.TripKey  
  
  
select TCVP.* from TripPassengerInfo TPI   
  INNER JOIN  TripPassengerHotelVendorPreference TCVP ON TCVP.TripKey = TPI.TripKey   
  WHERE  TPI.TripKey = @TripKey And TPI.Active = 1 and TCVP.Active = 1   
  order by TPI.TripKey  
  
   
  
Select * from TripAirResponse where TripKey = @TripKey  
  
Select TAL.* from TripAirLegs TAL Inner join  TripAirResponse  TAR on TAL.airResponseKey = TAR.airResponseKey   
where TAR.TripKey = @TripKey  
  
  
select      
  distinct T.tripKey ,  
     segments.* ,  
       departureAirport.AirportName  as departureAirportName ,    
       departureAirport.CityCode as departureAirportCityCode,departureAirport.StateCode   as departureAirportStateCode     
       ,departureAirport.CountryCode as departureAirportCountryCode,    
      arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,    
      arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,    
      legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax  ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )    
      as MarketingAirLine,airSegmentOperatingAirlineCode  ,    
      ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirLine,    
       isnull(airSelectedSeatNumber,0)  as SeatNumber  , segments.ticketNumber as TicketNumber ,segments.airsegmentcabin as airsegmentcabin  
     from TripAirSegments  segments     
      inner join TripAirLegs legs     
       on ( segments .tripAirLegsKey = segments .tripAirLegsKey and segments .airResponseKey = legs.airResponseKey     
       and segments .airLegNumber = legs .airLegNumber  )    
      inner join TripAirResponse   AirResp     
       on segments .airResponseKey = AirResp .airResponseKey      
      inner join Trip t on AirResp.tripKey = t.tripKey   
      left outer join AirVendorLookup airVen     
       on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode     
      left outer join AirVendorLookup airOperatingVen     
       on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode     
      left outer join AirportLookup departureAirport     
       on departureAirport .AirportCode = segments .airSegmentdepartureAirport     
     left outer join AirportLookup arrivalAirport     
       on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport     
       Where  t.TripKey = @TripKey AND ISNULL (segments.ISDELETED ,0) = 0 AND ISNULL (legs.ISDELETED ,0) = 0    and   T.tripStatusKey <>17   
   order by T.tripKey ,segments .airSegmentDepartureDate     
-- where t.tripRequestKey = @tripRequestID       
select   
 hotel.* from vw_TripHotelResponse hotel      
 inner join trip t on hotel.tripKey = t.tripKey    
 Inner join vault.dbo.[User] U on t.userKey = U.userKey   
 where  t.TripKey = @TripKey   and   T.tripStatusKey <>17   
 Order by t.tripKey  
    
    
--Select * from vw_TripCarResponse car inner join     
--  trip t on car .tripKey =t.tripKey   
--  Inner join vault.dbo.[User] U on t.userKey = U.userKey   
-- where  t.TripKey = @TripKey  
--  Order by t.tripKey  
    
 Select * from vw_TripCarResponseDetails TD
 INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey and   T.tripStatusKey <>17   
 Inner join vault.dbo.[User] U on t.userKey = U.userKey     
 UNION 
 Select * from vw_TripCarResponseDetails TD
 INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripguidkey = T.tripPurchasedKey   and   T.tripStatusKey <>17   
 Inner join vault.dbo.[User] U on t.userKey = U.userKey    
 order by T.tripKey
  
  
select TCVP.* from TripPassengerInfo TPI   
  INNER JOIN  TripPassengerUDIDInfo TCVP ON TCVP.TripKey = TPI.TripKey      
  WHERE  TPI.TripKey = @TripKey  
  order by TPI.TripKey  
  
  
  
select * from TripPolicyException where TripKey = @TripKey   and Active = 1   
  
END
GO
