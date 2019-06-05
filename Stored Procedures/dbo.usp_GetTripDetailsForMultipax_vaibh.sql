SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
--exec [usp_GetTripDetailsForMultipax] 39484,0      
CREATE PROCEDURE [dbo].[usp_GetTripDetailsForMultipax_vaibh] (                            
--DECLARE      
 @tripID   int   ,   
 @tripRequestID Int = 0   
) AS                                
  
 --SELECT  @tripId=219878,@tripRequestId=0    
  
BEGIN   
  
 DECLARE @TripPurchasedKey UNIQUEIDENTIFIER, @TripStatusKey INT   
 SELECT @TripPurchasedKey = tripPurchasedKey, @TripStatusKey = tripStatusKey    
 FROM Trip   
 WHERE tripKey = @tripId   

if(@TripPurchasedKey is null)
begin
SELECT @TripPurchasedKey = tripSavedKey
FROM Trip   
 WHERE tripKey = @tripId 
end      

 DECLARE @tblTrip as table   
 (   
  tripKey int,   
  RequestKey int,   
  statusKey int,   
  Event_Key varchar(50),   
  Event_company_Key bigint   
  , tripPurchasedKey UNIQUEIDENTIFIER  
 )                              
                              
                              
 if(@tripRequestID is Null  or @tripRequestID = 0 )                               
 BEGIN    
                             
  INSERT Into @tblTrip                              
  SELECT  @tripID,   tripRequestKey, tripStatusKey , Event_Key = meetingCodeKey ,Event_company_Key=0  
   , case isnull(tripPurchasedKey,'00000000-0000-0000-0000-000000000000') when '00000000-0000-0000-0000-000000000000' then tripSavedKey else tripPurchasedKey end as tripPurchasedKey    
  FROM Trip WITH(NOLOCK)   
  WHERE tripKey  = @tripID and   tripStatusKey <>17   
  --ORDER BY tripKey DESC    
    
 END                              
 ELSE                               
 BEGIN           
                      
  INSERT Into @tblTrip                              
  SELECT  tripKey ,  tripRequestKey, tripStatusKey , Event_Key = meetingCodeKey ,Event_company_Key=0  
   , case isnull(tripPurchasedKey,'00000000-0000-0000-0000-000000000000') when '00000000-0000-0000-0000-000000000000' then tripSavedKey else tripPurchasedKey end as tripPurchasedKey    
  FROM Trip WITH(NOLOCK)   
  WHERE tripRequestKey  = @tripRequestID  and   tripStatusKey <>17   
  --ORDER BY tripKey DESC    
      
 END                              
 --SELECT 'Delete', * FROM @tblTrip      
  
 DECLARE @tripAirResponseKey INT = 0  
 SELECT @tripAirResponseKey = tripAirResponseKey  
 FROM TripAirResponse WHERE tripKey IN (SELECT tripKey FROM @tblTrip)  
  
PRINT @tripAirResponseKey  
   
 IF @tripAirResponseKey IS NULL OR @tripAirResponseKey = 0  
 BEGIN  
  SELECT @tripAirResponseKey = tripAirResponseKey  
  FROM TripAirResponse WHERE tripGUIDKey IN (SELECT tripPurchasedKey FROM @tblTrip)  
 END  
    
 DECLARE @tblUser AS TABLE   
 (                              
  UserKey INT,   
  UserFirst_Name NVARCHAR(200),   
  UserLast_Name NVARCHAR(200),   
  User_Login NVARCHAR(50) ,   
  companyKey INT,   
  ReceiptEmail NVARCHAR(100)   
 )                              
      
 INSERT INTO @tblUser   
 SELECT DISTINCT U.userKey , LTRIM(RTRIM(U.userFirstName)) userFirstName , LTRIM(RTRIM(U.userLastName)) userLastName   
  , U.userLogin  ,U.companyKey, UP.ReceiptEmail  
 FROM Vault.dbo.[User] U  WITH(NOLOCK)   
  INNER JOIN Trip T WITH(NOLOCK) on  U.userKey = T.userKey AND T.tripStatusKey <>17   
  INNER JOIN @tblTrip tt on tt.tripKey = T.tripKey AND T.tripStatusKey <>17   
  INNER JOIN Vault.dbo.UserProfile UP WITH(NOLOCK) ON U.userKey = UP.userKey   
             
 UPDATE tbl  
  SET   Event_company_Key  = M.CompanyKey   
 FROM @tblTrip tbl   
  INNER JOIN vault.dbo.Meeting M ON tbl.Event_Key = M.meetingCode   
 WHERE ISNULL(tbl.Event_Key ,'')<>''   
  
 SELECT  Trip.*, CASE WHEN AirResp.isSplit IS NULL THEN 'false' ELSE AirResp.isSplit END AS isSplit,   
  vault.dbo.Agency.agencyKey AS Agency_ID, U.UserKey, u.UserFirst_Name, u.UserLast_Name, u.User_Login,   
  companyKey = CASE WHEN ISNULL(u.companyKey,0)  > 0 THEN u.companyKey ELSE tt.Event_company_Key END,   
  u.ReceiptEmail  
 FROM Trip                  
  --left outer join TripAirResponse   AirResp  WITH(NOLOCK) on AirResp.tripGUIDKey  = trip.tripPurchasedKey   
  LEFT OUTER JOIN TripAirResponse   AirResp  WITH(NOLOCK) ON AirResp.tripAirResponseKey  = @tripAirResponseKey  
  INNER JOIN vault.dbo.Agency WITH(NOLOCK) ON trip.agencyKey = Agency .agencyKey   
  LEFT OUTER JOIN @tblUser U  ON Trip.userKey = U.UserKey   
  INNER JOIN @tblTrip tt on tt.tripKey = Trip.tripKey AND Trip.tripStatusKey <>17   
 ORDER BY tripKey   
  
 SELECT TPI.TripPassengerInfoKey,TPI.TripKey,TPI.PassengerKey,PassengerTypeKey,IsPrimaryPassenger   
  , PassengerEmailID, LTRIM(RTRIM(PassengerFirstName)) PassengerFirstName, LTRIM(RTRIM(PassengerLastName)) PassengerLastName  
  , PassengerLocale, PassengerTitle, PassengerGender, PassengerBirthDate, TravelReferenceNo, PassengerRedressNo  
  , PassengerKnownTravellerNo, IsExcludePricingInfo   
 FROM TripPassengerInfo TPI WITH(NOLOCK)   
  INNER JOIN @tblTrip tt ON tt.tripKey = TPI.tripKey   
 WHERE TPI.Active = 1    
 ORDER by TPI.IsPrimaryPassenger desc --PassengerTypeKey   
  
 /*Getting Add Collect Amount From Trip Ticket Info table*/                        
 DECLARE @AddCollectAmount FLOAT, @ExchangeFee FLOAT   
 SET @AddCollectAmount = 0   
 SET @ExchangeFee = 0   
  
 --SELECT TOP 1 @AddCollectAmount = AddCollectFare + serviceCharge FROM TripTicketInfo TTI   
 --INNER JOIN @tblTrip tt ON tt.tripKey = TTI.tripKey WHERE IsExchanged = 1 AND tt.statusKey = 12   
 --ORDER BY tripTicketInfoKey Desc   
      
 SELECT TOP 1 @AddCollectAmount = TotalFare,@ExchangeFee = ExchangeFee   
 FROM TripTicketInfo TTI   
  INNER JOIN @tblTrip tt ON tt.tripKey = TTI.tripKey WHERE IsExchanged = 1 AND tt.statusKey = 12   
 ORDER BY tripTicketInfoKey DESC   
---------------------------------------------   
                              
 SELECT DISTINCT T.tripKey, t.tripRequestKey, segments.tripAirSegmentKey, segments.airSegmentKey,   
  segments.tripAirLegsKey, --segments.airResponseKey,   
  segments.airLegNumber, segments.airSegmentMarketingAirlineCode, segments.airSegmentOperatingAirlineCode,   
  segments.airSegmentFlightNumber, segments.airSegmentDuration, segments.airSegmentMiles,   
  segments.airSegmentDepartureDate, segments.airSegmentArrivalDate, segments.airSegmentDepartureAirport,   
  segments.airSegmentArrivalAirport, segments.airSegmentResBookDesigCode, segments.airSegmentDepartureOffset,   
  segments.airSegmentArrivalOffset,   
  (CASE WHEN AircraftsLookup.AircraftName IS NULL THEN airSegmentEquipment ELSE AircraftsLookup.AircraftName END) AS airSegmentEquipment,   
  segments.airSegmentSeatRemaining, segments.airSegmentMarriageGrp, segments.airFareBasisCode,   
  segments.airFareReferenceKey, segments.airSelectedSeatNumber, segments.ticketNumber, segments.airsegmentcabin,   
  segments.recordLocator as SegRecordLocator, segments.PNRNo as SegPNRNO, segments.airSegmentOperatingAirlineCompanyShortName   
  , legs.gdsSourceKey, departureAirport.AirportName  as departureAirportName,   
  departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode   
  , departureAirport.CountryCode as departureAirportCountryCode, arrivalAirport.AirportName  as arrivalAirportName   
  ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,   
  arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,   
  legs.recordLocator ,     --AirResp.actualAirPrice, --AirResp.actualAirTax, --AirResp.airResponseKey ,      
  ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode ) AS MarketingAirLine,airSegmentOperatingAirlineCode,   
  AirResp.CurrencyCodeKey as CurrencyCode, ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) AS OperatingAirLine,   
  ISNULL(airSelectedSeatNumber,0) AS SeatNumber, segments.ticketNumber AS TicketNumber  
  , segments.airsegmentcabin AS airsegmentcabin, --AirResp.isExpenseAdded,   
  ISNULL(t.deniedReason,'') AS deniedReason, t.CreatedDate, segments.airSegmentOperatingFlightNumber, --airresp.bookingcharges ,      
  ISNULL(seatMapStatus,'') AS seatMapStatus, @AddCollectAmount AS AddCollectAmount, @ExchangeFee AS ExchangeBookingFee,   
  G.AgentURL, segments.RPH, segments.ArrivalTerminal, segments.DepartureTerminal, AirResp.*,   
  legs.ValidatingCarrier as LegValidatingCarrier, segments.airSegmentBrandName, segments.IsChangeTripSeg   
  --   ,TPR.RemarkFieldName --,TPR.RemarkFieldValue --,TPR.TripTypeKey --,TPR.RemarksDesc --,TPR.GeneratedType --,TPR.CreatedOn   
 FROM TripAirSegments  segments  WITH(NOLOCK)   
  INNER JOIN TripAirLegs legs  WITH(NOLOCK) ON ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey   
   AND segments .airLegNumber = legs .airLegNumber)   
  INNER JOIN TripAirResponse   AirResp  WITH(NOLOCK) ON segments .airResponseKey = AirResp .airResponseKey   
  INNER JOIN Trip t WITH(NOLOCK) ON AirResp.tripGUIDKey  = t.tripPurchasedKey  or AirResp.tripGUIDKey = t.tripSavedKey 
  INNER JOIN @tblTrip tt ON tt.tripKey = t.tripKey   
  LEFT OUTER JOIN AirVendorLookup airVen  WITH(NOLOCK) ON segments .airSegmentMarketingAirlineCode =airVen.AirlineCode   
  LEFT OUTER JOIN AirVendorLookup airOperatingVen  WITH(NOLOCK) ON segments .airSegmentOperatingAirlineCode =airOperatingVen.AirlineCode   
  LEFT OUTER JOIN AirportLookup departureAirport WITH(NOLOCK) ON departureAirport .AirportCode = segments.airSegmentdepartureAirport   
  LEFT OUTER JOIN AirportLookup arrivalAirport WITH(NOLOCK) ON arrivalAirport.AirportCode = segments.airSegmentarrivalAirport   
  INNER JOIN Vault.dbo.GDSSourceLookup G WITH(NOLOCK) ON G.gdsSourceKey = legs.gdsSourceKey   
  LEFT OUTER JOIN AircraftsLookup WITH (NOLOCK) ON (segments.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)   
 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0 AND T.tripStatusKey <> 17   
   AND ISNULL (AirResp.ISDELETED ,0) = 0   
 ORDER BY T.tripKey ,segments.airLegNumber, segments.tripAirSegmentKey , segments.airSegmentDepartureDate   
 -- where t.tripRequestKey = @tripRequestID                                   
                 
 --Commented as suggested by Hemali/Asha-New view is used                
 --select                        
 --hotel.*,GL.AgentURL from vw_TripHotelResponse hotel --commented as suggested by Asha as it was not displaying duplicate hotel                               
 --inner join trip t on hotel.tripkey = t.tripkey                                 
 --Inner join @tblTrip tt on tt.tripKey = t.tripKey                
 --Inner Join vault.dbo.GDSSourceLookup GL On GL.GDSName = hotel.SupplierId                
 --Order by t.tripKey                
 --End Commented as suggested by Hemali/Asha-New view is used                
      
         
                
 SELECT hotel.*, t.tripKey, GL.AgentURL, HI.SupplierImageURL, CRH.RedeemedAmount   
 FROM vw_TripHotelResponseDetails hotel WITH(NOLOCK)   
  INNER JOIN trip t WITH(NOLOCK) ON (hotel.tripGUIDKey = t.tripPurchasedKey or hotel.tripGUIDKey = t.tripSavedKey) AND T.tripStatusKey <>17   
  INNER JOIN @tblTrip tt on tt.tripKey = t.tripKey AND T.tripStatusKey <>17   
  INNER JOIN vault.dbo.GDSSourceLookup GL WITH(NOLOCK) ON GL.GDSName = hotel.SupplierId   
  LEFT OUTER JOIN HotelContent..HotelImages HI WITH(NOLOCK) ON HI.HotelId = hotel.HotelId AND HI.ImageType = 'Exterior'   
  LEFT OUTER JOIN Loyalty..CashRewardHistory CRH WITH(NOLOCK) ON CRH.Id = T.cashRewardId   
 ORDER BY t.tripKey   
                                
 --Select * from vw_TripCarResponse car WITH(NOLOCK) inner join                                 
 --trip t WITH(NOLOCK) on car .tripkey =t.tripkey                               
 --Inner join @tblTrip tt on tt.tripKey  = t.tripKey                     
 --Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = car.SupplierId                              
 --Inner join vault.dbo.[User] U on t.userKey = U.userKey                               
  --where t.tripRequestKey = @tripRequestID                               
  --Order by t.tripKey                              
       
 --SELECT T.tripKey as tripKey,* FROM vw_TripCarResponseDetails TD        
 -- INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey    and   T.tripStatusKey <>17         
 -- Inner join @tblTrip tt ON tt.tripKey  = T.tripKey       and   T.tripStatusKey <>17                  
 -- Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TD.SupplierId                              
 -- UNION         
 -- SELECT T.tripKey as tripKey,* FROM vw_TripCarResponseDetails TD        
 -- INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripguidkey = T.tripPurchasedKey    and   T.tripStatusKey <>17         
 -- Inner join @tblTrip tt ON tt.tripKey  = T.tripKey            and   T.tripStatusKey <>17             
 -- Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TD.SupplierId                              
 -- ORDER BY T.tripKey                      
         
 SELECT T.tripKey, TD.recordLocator, TD.carResponseKey, confirmationNumber, carVendorKey, supplierId, carCategoryCode  
  , carLocationCode, carLocationCategoryCode, PerDayRate, searchCarTax, actualCarPrice, actualCarTax, SearchCarPrice  
  , VehicleName, pickupLocationName, pickupLocationAddress, pickupLatitude, pickupLongitude, pickupZipCode, dropoffLatitude  
  , dropoffLongitude, dropoffZipCode, dropoffLocationAddress, dropoffLocationName, PickUpdate, dropOutDate, SippCodeDescription  
  , SippCodeTransmission, SippCodeAC, CarCompanyName, SippCodeClass, dropoffCity, dropoffState, dropoffCountry, pickupCity  
  , pickupState, pickupCountry, minRateTax, TotalChargeAmt, minRate, passenger, baggage, isExpenseAdded, NoOfDays, tripGUIDKey   
  , contractCode, carRules, rateTypeCode, OperationTimeStart, OperationTimeEnd, PickupLocationInfo, InvoiceNumber, MileageAllowance  
  , RPH, CurrencyCodeKey, imageName, PhoneNumber, carDropOffLocationCode, carDropOffLocationCategoryCode, tripName, userKey, startDate   
  , endDate, tripStatusKey, tripSavedKey, T.tripPurchasedKey, agencyKey, tripComponentType, tripRequestKey, CreatedDate, meetingCodeKey   
  , deniedReason, siteKey, isBid, isOnlineBooking, tripAdultsCount, tripSeniorsCount, tripChildCount, tripInfantCount, tripYouthCount  
  , noOfTotalTraveler, noOfRooms, noOfCars, PurchaseComponentType, tripTotalBaseCost, tripTotalTaxCost, ModifiedDateTime, IsWatching  
  , tripOriginalTotalBaseCost, tripOriginalTotalTaxCost, tripInfantWithSeatCount, passiveRecordLocator, isAudit, bookingCharges  
  , isUserCreatedSavedTrip, ISSUEDATE, privacyType, HomeAirport, DestinationSmallImageURL, FollowersCount, tripCreationPath, CrowdCount  
  , TrackingLogID, bookingFeeARC, IsHotelCrowdSavings, SabreCreationDate, promoId, cashRewardId, HostUserId, RetainOrReplace, GroupKey  
  , cancellationflag, IsShowMyPic, UserIPAddress, SessionId, EventKey, AttendeeGuid, gdsSourceKey, GDSName, SeatMapAirlines, AgentURL  
  , TD.IsChangeTripCar  
 FROM vw_TripCarResponseDetails TD        
  INNER JOIN dbo.Trip T WITH (NOLOCK) ON (TD.tripGUIDKey = T.tripPurchasedKey or TD.tripGUIDKey = T.tripSavedKey) AND T.tripStatusKey <>17   --TD.tripKey = T.tripKey  
  INNER JOIN @tblTrip tt ON tt.tripKey  = T.tripKey AND T.tripStatusKey <> 17   
  INNER JOIN vault.dbo.GDSSourceLookup GL WITH(NOLOCK) ON GL.GDSName = TD.SupplierId   
    
 UNION   
  
 SELECT T.tripKey, TD.recordLocator, TD.carResponseKey, confirmationNumber, carVendorKey, supplierId, carCategoryCode, carLocationCode  
  , carLocationCategoryCode, PerDayRate, searchCarTax, actualCarPrice, actualCarTax, SearchCarPrice, VehicleName, pickupLocationName  
  , pickupLocationAddress, pickupLatitude, pickupLongitude, pickupZipCode, dropoffLatitude, dropoffLongitude, dropoffZipCode  
  , dropoffLocationAddress, dropoffLocationName, PickUpdate, dropOutDate, SippCodeDescription, SippCodeTransmission, SippCodeAC  
  , CarCompanyName, SippCodeClass, dropoffCity, dropoffState, dropoffCountry, pickupCity, pickupState, pickupCountry, minRateTax  
  , TotalChargeAmt, minRate, passenger, baggage, isExpenseAdded, NoOfDays, tripGUIDKey, contractCode, carRules, rateTypeCode  
  , OperationTimeStart, OperationTimeEnd, PickupLocationInfo, InvoiceNumber, MileageAllowance, RPH, CurrencyCodeKey, imageName  
  , PhoneNumber, carDropOffLocationCode, carDropOffLocationCategoryCode, tripName, userKey, startDate, endDate, tripStatusKey  
  , tripSavedKey, T.tripPurchasedKey, agencyKey, tripComponentType, tripRequestKey, CreatedDate, meetingCodeKey, deniedReason  
  , siteKey, isBid, isOnlineBooking, tripAdultsCount, tripSeniorsCount, tripChildCount, tripInfantCount, tripYouthCount  
  , noOfTotalTraveler, noOfRooms, noOfCars, PurchaseComponentType, tripTotalBaseCost, tripTotalTaxCost, ModifiedDateTime, IsWatching  
  , tripOriginalTotalBaseCost, tripOriginalTotalTaxCost, tripInfantWithSeatCount, passiveRecordLocator, isAudit, bookingCharges  
  , isUserCreatedSavedTrip, ISSUEDATE, privacyType, HomeAirport, DestinationSmallImageURL, FollowersCount, tripCreationPath, CrowdCount  
  , TrackingLogID, bookingFeeARC, IsHotelCrowdSavings, SabreCreationDate, promoId, cashRewardId, HostUserId, RetainOrReplace, GroupKey  
  , cancellationflag, IsShowMyPic, UserIPAddress, SessionId, EventKey, AttendeeGuid, gdsSourceKey, GDSName, SeatMapAirlines, AgentURL   
  , TD.IsChangeTripCar  
 FROM vw_TripCarResponseDetails TD   
  INNER JOIN dbo.Trip T WITH (NOLOCK) ON (TD.tripguidkey = T.tripPurchasedKey or td.tripGUIDKey = t.tripSavedKey) and T.tripStatusKey <>17   
  INNER JOIN @tblTrip tt ON tt.tripKey  = T.tripKey AND T.tripStatusKey <>17   
  INNER JOIN vault.dbo.GDSSourceLookup GL WITH(NOLOCK) ON GL.GDSName = TD.SupplierId   
 WHERE TD.tripkey IS NULL AND T.tripStatusKey = 1   
  
 UNION         
  
 SELECT T.tripKey, TD.recordLocator, TD.carResponseKey, confirmationNumber, carVendorKey, supplierId, carCategoryCode, carLocationCode  
  , carLocationCategoryCode, PerDayRate, searchCarTax, actualCarPrice, actualCarTax, SearchCarPrice, VehicleName, pickupLocationName  
  , pickupLocationAddress, pickupLatitude, pickupLongitude, pickupZipCode, dropoffLatitude, dropoffLongitude, dropoffZipCode  
  , dropoffLocationAddress, dropoffLocationName, PickUpdate, dropOutDate, SippCodeDescription, SippCodeTransmission, SippCodeAC  
  , CarCompanyName, SippCodeClass, dropoffCity, dropoffState, dropoffCountry, pickupCity, pickupState, pickupCountry, minRateTax  
  , TotalChargeAmt, minRate, passenger, baggage, isExpenseAdded, NoOfDays, tripGUIDKey, contractCode, carRules, rateTypeCode  
  , OperationTimeStart, OperationTimeEnd, PickupLocationInfo, InvoiceNumber, MileageAllowance, RPH, CurrencyCodeKey, imageName  
  , PhoneNumber, carDropOffLocationCode, carDropOffLocationCategoryCode, tripName, userKey, startDate, endDate, tripStatusKey  
  , tripSavedKey, T.tripPurchasedKey, agencyKey, tripComponentType, tripRequestKey, CreatedDate, meetingCodeKey, deniedReason  
  , siteKey, isBid, isOnlineBooking, tripAdultsCount, tripSeniorsCount, tripChildCount, tripInfantCount, tripYouthCount  
  , noOfTotalTraveler, noOfRooms, noOfCars, PurchaseComponentType, tripTotalBaseCost, tripTotalTaxCost, ModifiedDateTime, IsWatching  
  , tripOriginalTotalBaseCost, tripOriginalTotalTaxCost, tripInfantWithSeatCount, passiveRecordLocator, isAudit, bookingCharges  
  , isUserCreatedSavedTrip, ISSUEDATE, privacyType, HomeAirport, DestinationSmallImageURL, FollowersCount, tripCreationPath, CrowdCount  
  , TrackingLogID, bookingFeeARC, IsHotelCrowdSavings, SabreCreationDate, promoId, cashRewardId, HostUserId, RetainOrReplace, GroupKey  
  , cancellationflag, IsShowMyPic, UserIPAddress, SessionId, EventKey, AttendeeGuid, gdsSourceKey, GDSName, SeatMapAirlines, AgentURL   
  , TD.IsChangeTripCar  
 FROM vw_TripCarResponseDetails TD        
  INNER JOIN dbo.Trip T WITH (NOLOCK) ON (TD.tripguidkey = T.tripPurchasedKey or td.tripGUIDKey = t.tripSavedKey) AND T.tripStatusKey <>17   
  INNER JOIN @tblTrip tt ON tt.tripKey  = T.tripKey AND T.tripStatusKey <>17   
  INNER JOIN vault.dbo.GDSSourceLookup GL WITH(NOLOCK) ON GL.GDSName = TD.SupplierId   
 WHERE TD.tripGUIDKey = @TripPurchasedKey AND T.tripStatusKey <> 1   
  
 SELECT TAVP.*, TPI.PassengerFirstName, TPI.PassengerLastName, TPI.PassengerLocale, TPI.PassengerEmailID  
 FROM TripPassengerInfo TPI WITH(NOLOCK)                             
  INNER JOIN TripPassengerAirVendorPreference TAVP WITH(NOLOCK) ON TPI.TripKey = TAVP.TripKey   
  INNER JOIN @tblTrip tt ON tt.tripKey = TPI.tripKey   
 WHERE TPI.Active = 1 AND TAVP.Active = 1   
 ORDER BY TPI.TripKey   
  
 SELECT GeneratedType, TPR.TripKey, TPR.RemarksDesc, RemarkFieldName, RemarkFieldValue   
 FROM TripPNRRemarks TPR WITH(NOLOCK)   
  INNER JOIN @tblTrip tt on TPR.tripKey = tt.tripKey   
 WHERE TPR.Active= 1 AND (tt.statusKey != 5)   
 --AND DATEDIFF( DAY  ,CreatedOn, GETDATE())<=1   
  
 SELECT TOP 1 ISNULL(ReasonDescription,'') as ReasonDescription, ReasonCode, TripKey   
 FROM TripPolicyException   
 WHERE TripKey = @tripID   
  
 SELECT DISTINCT TAVP.AirsegmentKey, TAVP.PassengerKey, TAVP.OriginAirportCode, TAVP.TicketDelivery, TAVP.AirSeatingType,   
  TAVP.AirRowType, TAVP.AirMealType, TAVP.AirSpecialSevicesType, TAVP.Active, TAVP.AirsegmentKey, TPI.PassengerFirstName  
  , TPI.PassengerLastName, TPI.PassengerLocale,TPI.PassengerEmailID ,TPI.tripKey,TPI.TripPassengerInfoKey    
 FROM TripPassengerInfo TPI WITH(NOLOCK)   
  INNER JOIN  TripPassengerAirPreference  TAVP WITH(NOLOCK) ON TPI.TripKey = TAVP.TripKey   
  INNER JOIN @tblTrip tt ON tt.tripKey = TPI.tripKey   
 WHERE TPI.Active = 1 AND TAVP.Active = 1   
  
 SELECT TCVP.*   
 FROM TripPassengerInfo TPI WITH(NOLOCK)   
  INNER JOIN  TripPassengerUDIDInfo TCVP WITH(NOLOCK) ON TCVP.TripKey = TPI.TripKey   
  Inner join @tblTrip tt   on tt.tripKey = TPI.tripKey   
 WHERE TCVP.Active=1   
 ORDER BY TPI.TripKey   
  
 SELECT * FROM vw_TripCruiseResponse cruise WITH(NOLOCK)   
 INNER JOIN trip t WITH(NOLOCK) ON cruise.tripGuidkey = t.tripPurchasedKey AND T.tripStatusKey <> 17   
 INNER JOIN @tblTrip tt ON tt.tripKey = t.tripKey and T.tripStatusKey <>17   
 ORDER BY t.tripKey   
  
    /***tripairleg pax info****/                  
                      
 SELECT TLP.* ,TLA.tripAirLegsKey   
 FROM TripAirLegPassengerInfo TLP  WITH(NOLOCK)   
  INNER JOIN TripAirLegs  TLA WITH(NOLOCK) ON Tlp.tripAirLegKey = TLA.tripAirLegsKey   
  INNER JOIN TripAirResponse TA  WITH(NOLOCK) ON TLA.airResponseKey= TA.airResponseKey   
  INNER JOIN Trip T WITH(NOLOCK) ON TA.tripGUIDKey = t.tripPurchasedKey   
  INNER JOIN @tblTrip Tbl ON t.tripKey = tbl.tripKey AND T.tripStatusKey <>17   
 WHERE TLA.isDeleted = 0   
  
    /****TRipSEGMENT pax details DETAILS***/                  
 SELECT TSP.* ,TSA.airSegmentKey   
 FROM TripAirSegmentPassengerInfo TSP  WITH(NOLOCK)   
  INNER JOIN TripAirSegments TSA WITH(NOLOCK) ON TSp.tripAirSegmentkey = TSA.tripAirSegmentKey   
  INNER JOIN TripAirResponse TA  ON TSA.airResponseKey= TA.airResponseKey   
  INNER JOIN Trip T ON (TA.tripGUIDKey = t.tripPurchasedKey or  ta.tripGUIDKey = t.tripSavedKey)   
  INNER JOIN @tblTrip Tbl ON t.tripKey = tbl.tripKey AND T.tripStatusKey <> 17   
 WHERE TSA.isDeleted = 0   
                  
 /* trip hotel pax info */                
 --SELECT THP.*   
 --FROM TripHotelResponsePassengerInfo THP WITH(NOLOCK)   
 -- INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TPI.TripPassengerInfoKey = THP.TripPassengerInfoKey   
 -- INNER JOIN TripHotelResponse TH WITH(NOLOCK) ON TH.hotelResponseKey = THP.hotelResponseKey   
 -- INNER JOIN Trip T WITH(NOLOCK) ON TH.tripGUIDKey = T.tripPurchasedKey and T.tripStatusKey <>17   
 -- INNER JOIN @tblTrip Tbl ON T.tripKey = tbl.tripKey AND T.tripStatusKey <> 17   
   
 SELECT THP.*     
 FROM @tblTrip Tbl  
 INNER JOIN Trip T WITH(NOLOCK) ON (Tbl.tripPurchasedKey = T.tripPurchasedKey or  Tbl.tripPurchasedKey = t.tripSavedKey) and T.tripStatusKey <>17  
 INNER JOIN TripHotelResponse TH WITH(NOLOCK) ON t.tripPurchasedKey = TH.tripGUIDKey   or t.tripSavedKey = TH.tripGUIDKey  
 INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON Tbl.tripKey = TPI.TripKey  
 INNER JOIN TripHotelResponsePassengerInfo THP WITH(NOLOCK) ON TPI.TripPassengerInfoKey = THP.TripPassengerInfoKey   
  AND TH.hotelResponsekey = THP.hotelResponsekey  
  
 SELECT TT.tripKey, friendEmailAddress   
 FROM TripConfirmationFriendEmail TCFE WITH(NOLOCK)   
  INNER JOIN @tblTrip TT ON TCFE.tripKey = TT.tripKey   
  
 /* Trip Activity Details */   
 SELECT TAR.ActivityResponseKey, ISNULL(ConfirmationNumber, '')as ConfirmationNumber, ISNULL(RecordLocator, '') as RecordLocator,   
  ISNULL(ActivityType, '') as ActivityType, ISNULL(ActivityTitle, '') as ActivityTitle, ISNULL(ActivityText, '') as ActivityText,   
  ActivityDate, ISNULL(VoucherURL, '') as VoucherURL, ISNULL(CancellationFormURL, '') as CancellationFormURL, NoOfAdult,   
  NoOfChild, NoOfYouth, NoOfInfant, NoOfSenior, TotalPrice, ISNULL(Link, '') as Link, TAR.ActivityCode, TAR.OptionCode,   
  AL.City, AL.IATACode   
 FROM TripActivityResponse  TAR WITH(NOLOCK)   
  INNER JOIN Activity..ActivityLookUp AC WITH(NOLOCK) ON TAR.ActivityCode = AC.Code   
  INNER JOIN Activity.dbo.ActivityLocations AL WITH(NOLOCK) ON AC.Id = AL.ActivityId   
  INNER JOIN @tblTrip TT ON TAR.tripKey = TT.tripKey AND ISNULL(TAR.isDeleted,0) = 0   
                 
 /* Trip Insurance Details */                
 SELECT *   
 FROM [TripPurchasedInsurance] TPI WITH(NOLOCK)   
  INNER JOIN @tblTrip TT ON TPI.tripKey = TT.tripKey AND TPI.isDeleted = 0  AND ISNULL(TPI.isDeleted,0) = 0   
       
 /* Trip Rail Details */      
 SELECT *   
 FROM TripRailResponse rail WITH(NOLOCK)   
  INNER JOIN trip t WITH(NOLOCK) ON (rail.TripGUIDKey = t.tripPurchasedKey or rail.TripGUIDKey = t.tripSavedKey   ) and T.tripStatusKey <>17   
  INNER JOIN @tblTrip tt on tt.tripKey = t.tripKey  and   T.tripStatusKey <> 17 AND ISNULL(rail.isDeleted,0) = 0   
 ORDER BY t.tripKey   
  
 SELECT TR.tripRequestKey, TR.tripFrom1 AS 'From', TR.tripTo1 AS 'To'   
 FROM TripRequest TR   
  INNER JOIN @tblTrip TT ON TR.tripRequestKey=TT.RequestKey   
  
 SELECT TTI.tripKey, recordLocator, isExchanged, isVoided, isRefunded, oldTicketNumber, newTicketNumber, issuedDate AS IssueDate   
  ,oldFare, newFare, addCollectFare, serviceCharge, residualFare, TotalFare, ExchangeFee, BaseFare, TaxFare   
 FROM TripTicketInfo TTI   
  INNER JOIN @tblTrip tt ON tt.tripKey = TTI.tripKey   
 ORDER BY tripTicketInfoKey DESC   
  
 SELECT TT.tripKey, tripAdultBase, tripAdultTax, tripSeniorBase, tripSeniorTax, tripYouthBase, tripYouthTax, tripChildBase, tripChildTax  
  , tripInfantBase, tripInfantTax, tripInfantWithSeatBase, tripInfantWithSeatTax   
 FROM TripAirPrices TAP   
  INNER JOIN TripAirResponse TAR ON TAR.actualAirPriceBreakupKey = TAP.tripAirPriceKey   
  INNER JOIN Trip TT on TT.tripPurchasedKey = TAR.tripGUIDKey or   TT.tripSavedKey = TAR.tripGUIDKey
 WHERE TT.tripKey =  @tripID   
  
 /*Get EMDInfo by TripId*/  
 SELECT EMDInfo.tripKey, EMDInfo.recordLocator, EMDInfo.DocumentNumber, EMDInfo.TotalTaxFare  
  , EMDInfo.TotalBaseFare, EMDInfo.TotalFare, EMDInfo.FlightNumber, EMDInfo.AirlineCode, EMDInfo.SeatNumber, EMDInfo.IssuedDate   
 FROM TripEMDTicketInfo EMDInfo   
 WHERE EMDInfo.tripKey = @tripID   
  
END   
GO
