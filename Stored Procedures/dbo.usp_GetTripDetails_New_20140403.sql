SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*Exec USP_GetTripDetails_New 5666,0*/            
CREATE PROCEDURE [dbo].[usp_GetTripDetails_New_20140403]                    
(                
 @tripID   int   ,                  
 @tripRequestID Int = 0                  
)                
as                    
BEGIN                  
                  
DECLARE @tblTrip as table                  
(                  
 tripKey int,                  
 RequestKey int,      
 statusKey int                  
)                  
                  
                  
if(@tripRequestID is Null  or @tripRequestID = 0 )                   
BEGIN                  
 INSERT Into @tblTrip                  
 Select  @tripID,   tripRequestKey, tripStatusKey  from Trip where tripKey  = @tripID and tripStatusKey <> 17                              
END                  
ELSE                   
BEGIN                  
 INSERT Into @tblTrip                  
 Select  tripKey ,  tripRequestKey, tripStatusKey  from Trip where tripRequestKey  = @tripRequestID    and tripStatusKey <> 17              
END                  
                  
                  
                  
                  
Declare @tblUser as table                  
(                  
 UserKey Int,                  
 UserFirst_Name nvarchar(200),                  
 UserLast_Name nvarchar(200),                  
 User_Login nvarchar(50) ,                  
 companyKey int                   
)                  
                  
                   
                   
                   
Insert into @tblUser                   
Select distinct U.userKey , U.userFirstName , U.userLastName , U.userLogin  ,U.companyKey                   
From Vault.dbo.[User] U                   
 inner join Trip T on  U.userKey = T.userKey  and T.tripStatusKey <> 17               
 Inner join @tblTrip tt on tt.tripKey = T.tripKey  and T.tripStatusKey <> 17                
      
      
                  
                  
select Trip.*, vault.dbo.Agency .agencyKey As Agency_ID, U.* from Trip                   
inner join vault.dbo.Agency  on trip.agencyKey = Agency .agencyKey                   
Left Outer join @tblUser U on Trip.userKey = U.UserKey                   
Inner join @tblTrip tt on tt.tripKey = Trip.tripKey    and Trip.tripStatusKey <> 17                 
Order by tripKey                   
                  
      
/*Getting Add Collect Amount From Trip Ticket Info table*/                  
DECLARE @AddCollectAmount FLOAT,@ExchangeFee Float
SET @AddCollectAmount = 0 
Set @ExchangeFee = 0     
      
--SELECT TOP 1 @AddCollectAmount = AddCollectFare + serviceCharge FROM TripTicketInfo TTI       
--INNER JOIN @tblTrip tt ON tt.tripKey = TTI.tripKey WHERE IsExchanged = 1 AND tt.statusKey = 12      
--ORDER BY tripTicketInfoKey Desc      

SELECT TOP 1 @AddCollectAmount = TotalFare,@ExchangeFee = ExchangeFee FROM TripTicketInfo TTI       
INNER JOIN @tblTrip tt ON tt.tripKey = TTI.tripKey WHERE IsExchanged = 1 AND tt.statusKey = 12      
ORDER BY tripTicketInfoKey Desc      

                  
select                      
distinct T.tripKey ,                  
                   
  segments.tripAirSegmentKey,            
segments.airSegmentKey,            
segments.tripAirLegsKey,            
segments.airResponseKey,            
segments.airLegNumber,            
segments.airSegmentMarketingAirlineCode,            
segments.airSegmentOperatingAirlineCode,            
segments.airSegmentFlightNumber,            
segments.airSegmentDuration,            
segments.airSegmentEquipment,            
segments.airSegmentMiles,            
segments.airSegmentDepartureDate,            
segments.airSegmentArrivalDate,            
segments.airSegmentDepartureAirport,            
segments.airSegmentArrivalAirport,            
segments.airSegmentResBookDesigCode,            
segments.airSegmentDepartureOffset,            
segments.airSegmentArrivalOffset,            
segments.airSegmentSeatRemaining,            
segments.airSegmentMarriageGrp,            
segments.airFareBasisCode,            
segments.airFareReferenceKey,            
segments.airSelectedSeatNumber,            
segments.ticketNumber,            
segments.airsegmentcabin,            
segments.recordLocator as SegRecordLocator,
segments.airSegmentOperatingAirlineCompanyShortName
                
     ,legs.gdsSourceKey ,                    
   departureAirport.AirportName  as departureAirportName ,                    
   departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode                     
   ,departureAirport.CountryCode as departureAirportCountryCode,                    
  arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,                    
  arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,                    
  legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax ,AirResp.airResponseKey ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )                    
  as MarketingAirLine,airSegmentOperatingAirlineCode  ,  AirResp.CurrencyCodeKey as CurrencyCode,                  
  ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirLine,                    
   isnull(airSelectedSeatNumber,0)  as SeatNumber  , segments.ticketNumber as TicketNumber ,segments.airsegmentcabin as airsegmentcabin    ,AirResp.isExpenseAdded,                
   ISNULL(t.deniedReason,'') as deniedReason, t.CreatedDate       , segments.airSegmentOperatingFlightNumber ,airresp.bookingcharges            
   ,ISNULL(seatMapStatus,'') AS seatMapStatus, AirResp.ValidatingCarrier        
   ,@AddCollectAmount AS AddCollectAmount,@ExchangeFee as ExchangeBookingFee     
,arule.airFareBasisCode AS AirTripRuleBasicCode,arule.airTripRulesContent    
      
--   ,TPR.RemarkFieldName                  
--,TPR.RemarkFieldValue                  
--,TPR.TripTypeKey                  
--,TPR.RemarksDesc                  
--,TPR.GeneratedType                  
--,TPR.CreatedOn                  
                     
                     
                     
from TripAirSegments  segments                     
inner join TripAirLegs legs                     
on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                     
and segments .airLegNumber = legs .airLegNumber  )                    
inner join TripAirResponse   AirResp                     
on segments .airResponseKey = AirResp .airResponseKey                     
inner join Trip t on AirResp.tripKey = t.tripKey             
Inner join @tblTrip tt on tt.tripKey = t.tripKey    
left outer join AirTripRule arule    
on segments.airSegmentKey=arule.airSegmentKey                    
left outer join AirVendorLookup airVen                     
on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                     
left outer join AirVendorLookup airOperatingVen                     
on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                     
left outer join AirportLookup departureAirport                     
on departureAirport .AirportCode = segments .airSegmentdepartureAirport                     
left outer join AirportLookup arrivalAirport                     
on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                     
    
WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0    and T.tripStatusKey <> 17                  
                  
                  
                  
 order by T.tripKey ,segments.tripAirSegmentKey , segments .airSegmentDepartureDate                     
-- where t.tripRequestKey = @tripRequestID                       
select                   
                  
hotel.* from vw_TripHotelResponse hotel                      
inner join trip t on hotel.tripKey = t.tripKey    and T.tripStatusKey <> 17                   
Inner join @tblTrip tt on tt.tripKey = t.tripKey    and T.tripStatusKey <> 17                   
--Inner join vault.dbo.[User] U on t.userKey = U.userKey                   
                  
--where t.tripRequestKey = @tripRequestID                   
Order by t.tripKey                  
                   
                    
--Select * from vw_TripCarResponse car inner join                     
-- trip t on car .tripKey =t.tripKey                   
-- Inner join @tblTrip tt on tt.tripKey = t.tripKey                   
-- --Inner join vault.dbo.[User] U on t.userKey = U.userKey                   
----where t.tripRequestKey = @tripRequestID                   
-- Order by t.tripKey                  

Select T.tripKey as tripKey,* from vw_TripCarResponseDetails TD
 INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey   and T.tripStatusKey <> 17 
  Inner join @tblTrip tt on tt.tripKey = T.tripKey                   
UNION 
Select T.tripKey as tripKey,* from vw_TripCarResponseDetails TD
 INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripguidkey = T.tripPurchasedKey   and T.tripStatusKey <> 17 
  Inner join @tblTrip tt on tt.tripKey = T.tripKey                   
Order by T.tripKey              
                     
select TAVP.*, TPI.PassengerFirstName,TPI.PassengerLastName, TPI.PassengerLocale,TPI.PassengerEmailID  from TripPassengerInfo TPI                   
  INNER JOIN  TripPassengerAirVendorPreference TAVP ON TPI.TripKey = TAVP.TripKey                  
  Inner join @tblTrip tt on tt.tripKey = TPI.tripKey                    
  WHERE    TPI.Active = 1 and TAVP.Active = 1                   
  order by TPI.TripKey                  
                  
select count (GeneratedType) as NoOfRemarks ,GeneratedType ,TPR.TripKey ,TPR.RemarksDesc from TripPNRRemarks   TPR                  
  Inner join @tblTrip tt on TPR.tripKey = tt.tripKey           
  Inner join Trip T on tt.tripKey  = T.TripKey                    
  WHERE TPR.Active= 1   and (T.tripStatusKey = 2 or T.tripStatusKey = 1  )and  DATEDIFF( DAY  ,CreatedOn, GETDATE())<=1                  
  Group by GeneratedType , TPR.TripKey  , TPR.RemarksDesc                
                    
                    
                  
SELECT TOP 1                
  ISNULL(ReasonDescription,'') as ReasonDescription,                
  TripKey                 
FROM                 
  TripPolicyException                
WHERE                 
  TripKey = @tripID             
            
            
select distinct TAVP.AirsegmentKey,             
            
TAVP.PassengerKey,            
TAVP.OriginAirportCode,            
TAVP.TicketDelivery,            
TAVP.AirSeatingType,            
TAVP.AirRowType,            
TAVP.AirMealType,            
TAVP.AirSpecialSevicesType,            
TAVP.Active,            
TAVP.AirsegmentKey            
 , TPI.PassengerFirstName,TPI.PassengerLastName, TPI.PassengerLocale,TPI.PassengerEmailID ,TPI.tripKey  from TripPassengerInfo TPI                   
  INNER JOIN  TripPassengerAirPreference  TAVP ON TPI.TripKey = TAVP.TripKey                  
  Inner join @tblTrip tt on tt.tripKey = TPI.tripKey                    
  WHERE    TPI.Active = 1 and TAVP.Active = 1                   
            
            
            
select TPI.* from TripPassengerInfo TPI                   
  Inner join @tblTrip tt on tt.tripKey = TPI.tripKey                    
  WHERE    TPI.Active = 1             
            
select TCVP.* from TripPassengerInfo TPI               
  INNER JOIN  TripPassengerUDIDInfo TCVP ON TCVP.TripKey = TPI.TripKey                 
   Inner join @tblTrip tt   on tt.tripKey = TPI.tripKey            
  WHERE   TCVP.Active=1            
  order by TPI.TripKey              
            
Select * from vw_TripCruiseResponse cruise          
 inner join trip t on cruise.tripKey =t.tripKey     and t.tripStatusKey <> 17                       
 Inner join @tblTrip tt on tt.tripKey = t.tripKey     and t.tripStatusKey <> 17                      
    Order by t.tripKey           
END      
      
GO
