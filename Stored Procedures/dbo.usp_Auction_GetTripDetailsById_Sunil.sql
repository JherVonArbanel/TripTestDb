SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec usp_Auction_GetTripDetailsById 4944
CREATE PROC [dbo].[usp_Auction_GetTripDetailsById_Sunil]
(
--Declare
	@TripKey int
) AS 
BEGIN 

--Set @TripKey = 6359

------------ TRIP INFO ------------

 
--select * from Trip where tripSavedKey is not null
declare @tripSavedKey uniqueidentifier, @userkey int
select @tripSavedKey =tripSavedKey, @userkey=userKey FROM     Trip 
where	 tripkey=@TripKey

select @tripSavedKey

SELECT   TripKey
		,'TripName' = tripName
		,UserKey
		,AdultCount = tripAdultsCount
		,ChildCount = tripChildCount
		,RecordLocator
		,StartDate
		,EndDate
		,tripStatusKey
		,tripSavedKey
		,InfantCount = tripInfantCount
		,YouthCount = tripYouthCount
		,SeniorsCount = tripSeniorsCount
FROM     Trip 
where	 tripkey=@TripKey

------------ PASSENGER INFO ------------
--use vault 
SELECT  UR.userKey
		,PassengerEmailID = ISNULL(up.userEmail,'')
		,PassengerFirstName = ISNULL(UR.userFirstName,'')
		,PassengerLastName = ISNULL(UR.userLastName,'')		
		,PassengerPhone = UP.workPhone
FROM     vault..[User] UR
		left outer join vault..UserProfile UP on UR.userKey = up.userKey 
WHERE    ur.userkey = @userkey


------------ AIR INFO ------------
SELECT 
		 *
FROM	 TripAirResponse --vw_TripDetails
WHERE	 tripGUIDKey = @tripSavedKey

--SELECT 
--		 airSegmentDepartureAirport 'Origin'
--		,airSegmentArrivalAirport 'Destination'
--		,departuredate 'DepatureDateTime'
--		,BookingType = ''
--		,NumberOfPassengers = 1
--		,AdultCount = 1
--		,ChildCount = 0
--		,VendorCode 'AirlineCode' 
--		,BaseCost =basecost
--		,Disc_Price = (basecost-0.10*basecost)
--		,Tax = tax
--FROM	 TripAirResponse --vw_TripDetails
--WHERE	 tripGUIDKey = @tripSavedKey --And [Type] = 'air'

------------ CAR INFO ------------



SELECT 
		 PickupAirport = pickupCity
		,PickupCity
		,PickupState
		,PickupCountry
		,DropoffAirport = dropoffCity
		,DropoffCity
		,DropoffState
		,DropoffCountry
		,OneWayRental = ''
		,PickUpDate
		,DropOutDate
		,CarCategoryCode
		,PrefferedVendorCode = ''
		,CarType = ''
		,CarTransmission = SippCodeTransmission
		,DemandStatus = ''
		,ModifiedBy  = userKey
		,ModifiedDate = GETDATE()				
		
		FROM dbo.vw_TripCarResponse
		WHERE tripKey = @TripKey

--SELECT * FROM vw_TripCarResponse


------------ HOTEL INFO ------------


--SELECT *  FROM vw_TripHotelResponse
--WHERE tripKey = 4944


	SELECT 
		 AirportCode = ''
		,City = CityName
		,State = StateCode
		,Country = CountryCode 
		,Brand = ''
		,Longitude
		,Latitude
		,CheckInDate
		,NumOfNights = DATEDIFF(DAY,startDate,endDate)  
		,NumOfRooms = ''
		,DemandStatus = ''
		,ModifiedBy = userKey
		,ModifiedDate = GETDATE()		
		 				
	FROM 
		vw_TripHotelResponse
	WHERE tripKey = @TripKey
			
END
GO
