SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--[usp_GetTripDetails_New] 1666,0


CREATE PROCEDURE [dbo].[usp_GetTripDetailsByTripGUID]  
 @tripGUID as uniqueidentifier
as  


DECLARE @tripID   int   
DECLARE  @tripRequestID Int = 0
DECLARE @tblTrip as table
(
	tripKey int,
	RequestKey int
)
SET @tripID = ( select tripKey  from Trip where tripGuid = @tripGUID )

if(@tripRequestID is Null  or @tripRequestID = 0 ) 
BEGIN
	INSERT Into @tblTrip
	Select  @tripID,   tripRequestKey  from Trip where tripKey  = @tripID
END
ELSE 
BEGIN
	INSERT Into @tblTrip
	Select  tripKey ,  tripRequestKey  from Trip where tripRequestKey  = @tripRequestID
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
	inner join Trip T on  U.userKey = T.userKey 
	Inner join @tblTrip tt on tt.tripKey = T.tripKey 


select Trip.* , vault.dbo.Agency .agencyKey As Agency_ID, U.* from Trip 
inner join vault.dbo.Agency  on trip.agencyKey = Agency .agencyKey 
Inner join @tblUser U on Trip.userKey = U.UserKey 
Inner join @tblTrip tt on tt.tripKey = Trip.tripKey 
Order by tripKey 



select    
  distinct T.tripKey ,
 
    segments.* ,legs.gdsSourceKey ,  
   departureAirport.AirportName  as departureAirportName ,  
   departureAirport.CityCode as departureAirportCityCode,departureAirport.StateCode   as departureAirportStateCode   
   ,departureAirport.CountryCode as departureAirportCountryCode,  
  arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,  
  arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,  
  legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax ,AirResp.airResponseKey ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )  
  as MarketingAirLine,airSegmentOperatingAirlineCode  ,  
  ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirLine,  
   isnull(airSelectedSeatNumber,0)  as SeatNumber  , segments.ticketNumber as TicketNumber ,segments.airsegmentcabin as airsegmentcabin    ,AirResp.isExpenseAdded 
--   ,TPR.RemarkFieldName
--,TPR.RemarkFieldValue
--,TPR.TripTypeKey
--,TPR.RemarksDesc
--,TPR.GeneratedType
--,TPR.CreatedOn
   
   
   
 from TripAirSegments  segments   
  inner join TripAirLegs legs   
   on ( segments .tripAirLegsKey = segments .tripAirLegsKey and segments .airResponseKey = legs.airResponseKey   
   and segments .airLegNumber = legs .airLegNumber  )  
  inner join TripAirResponse   AirResp   
   on segments .airResponseKey = AirResp .airResponseKey    
  inner join Trip t on AirResp.tripKey = t.tripKey 
Inner join @tblTrip tt on tt.tripKey = t.tripKey 
  left outer join AirVendorLookup airVen   
   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode   
  left outer join AirVendorLookup airOperatingVen   
   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode   
  left outer join AirportLookup departureAirport   
   on departureAirport .AirportCode = segments .airSegmentdepartureAirport   
 left outer join AirportLookup arrivalAirport   
   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport   
  --left outer join TripPNRRemarks TPR  on tt.tripKey = TPR.TripKey 
  -- WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0 



 order by T.tripKey ,segments .airSegmentDepartureDate   
-- where t.tripRequestKey = @tripRequestID     
select 

hotel.* from vw_TripHotelResponse hotel    
inner join trip t on hotel.tripKey = t.tripKey  
Inner join @tblTrip tt on tt.tripKey = t.tripKey 
Inner join vault.dbo.[User] U on t.userKey = U.userKey 

--where t.tripRequestKey = @tripRequestID 
Order by t.tripKey
  
  
Select * from vw_TripCarResponse car inner join   
 trip t on car .tripKey =t.tripKey 
 Inner join @tblTrip tt on tt.tripKey = t.tripKey 
 Inner join vault.dbo.[User] U on t.userKey = U.userKey 
 --where t.tripRequestKey = @tripRequestID 
 Order by t.tripKey


select TAVP.* from TripPassengerInfo TPI 
		INNER JOIN  TripPassengerAirVendorPreference TAVP ON TPI.TripKey = TAVP.TripKey 
		WHERE  TPI.TripKey = @tripID   And TPI.Active = 1 and TAVP.Active = 1 
		order by TPI.TripKey

 
 

select count (GeneratedType) as NoOfRemarks ,GeneratedType ,TPR.TripKey  from TripPNRRemarks   TPR
		Inner join @tblTrip tt on TPR.tripKey = tt.tripKey 
		Inner join Trip T on tt.tripKey  = T.TripKey
		WHERE TPR.Active= 1  and T.tripStatusKey = 2 and  DATEDIFF( DAY  ,CreatedOn, GETDATE())<=1
		Group by GeneratedType , TPR.TripKey
		
		



GO
