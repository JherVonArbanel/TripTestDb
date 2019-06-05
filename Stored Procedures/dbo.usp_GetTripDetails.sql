SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetTripDetails]

 @tripID   int 
as
select Trip.tripKey, tripName, userKey, recordLocator, startDate,endDate,tripStatusKey,tripSavedKey,tripPurchasedKey,Trip.agencyKey
	,tripComponentType,Trip.tripRequestKey, CreatedDate, meetingCodeKey, deniedReason, Trip.siteKey, isBid, isOnlineBooking 
	,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount,noOfTotalTraveler,noOfRooms
	,noOfCars,PurchaseComponentType,tripTotalBaseCost,tripTotalTaxCost,ModifiedDateTime,IsWatching,tripOriginalTotalBaseCost
	,tripOriginalTotalTaxCost,tripInfantWithSeatCount,passiveRecordLocator,isAudit,bookingCharges,ISSUEDATE,privacyType
	,DestinationSmallImageURL,FollowersCount,tripCreationPath,isUserCreatedSavedTrip,CrowdCount,TrackingLogID,bookingFeeARC
	,IsHotelCrowdSavings,SabreCreationDate,promoId,cashRewardId,HostUserId,RetainOrReplace,groupKey,cancellationflag
	,IsShowMyPic,UserIPAddress,SessionId,EventKey,AttendeeGuid,HomeAirport 
	, vault.dbo.Agency.agencyKey As Agency_ID, TripPassengerInfo.PassengerFirstName, TripPassengerInfo.PassengerLastName
	, TripPassengerInfo.PassengerEmailID, TripPassengerInfo.PassengerGender  
from Trip 
inner join vault.dbo.Agency  on trip.agencyKey = Agency .agencyKey 
inner join TripPassengerInfo on trip.tripKey = TripPassengerInfo.TripKey 
 where Trip.tripKey = @tripID  


select  
		distinct  segments.* ,legs.gdsSourceKey ,
		 departureAirport.AirportName  as departureAirportName ,
		 departureAirport.CityCode	as departureAirportCityCode,departureAirport.StateCode   as departureAirportStateCode 
		 ,departureAirport.CountryCode as departureAirportCountryCode,
		arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,
		arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,
		legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax  ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )
		as MarketingAirLine,airSegmentOperatingAirlineCode  ,
		ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirLine,
		 isnull(airSelectedSeatNumber,0)  as SeatNumber
 from TripAirSegments  segments 
		inner join TripAirLegs legs 
			on ( segments .tripAirLegsKey = segments .tripAirLegsKey and segments .airResponseKey = legs.airResponseKey 
			and segments .airLegNumber = legs .airLegNumber  )
		inner join TripAirResponse   AirResp 
			on segments .airResponseKey = AirResp .airResponseKey  
		left outer join AirVendorLookup airVen 
			on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode 
		left outer join AirVendorLookup airOperatingVen 
			on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode 
		left outer join AirportLookup departureAirport 
			on departureAirport .AirportCode = segments .airSegmentdepartureAirport 
	left outer join AirportLookup arrivalAirport 
			on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport 
 where AirResp.tripKey= @tripID AND ISNULL (segments .ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
   order by segments .airSegmentDepartureDate 

select * from vw_TripHotelResponse hotel  
inner join trip on hotel.tripKey = trip.tripKey  where trip.tripKey = @tripid 


Select * from vw_TripCarResponse car inner join 
 trip on car .tripKey =trip.tripKey where trip.tripKey = @tripiD
GO
