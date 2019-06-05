SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [usp_Auction_GetTripDetailsById_cybage] 4944
CREATE PROC [dbo].[usp_Auction_GetTripDetailsById_cybage]
(
-- Declare
	@TripKey int
) AS 
BEGIN 

	--Set @TripKey = 6359

	------------ TRIP INFO ------------

	DECLARE @tripSavedKey UNIQUEIDENTIFIER, @userkey INT, @numberOfPassengers INT

	SELECT @tripSavedKey =tripSavedKey, @userkey=userKey 
		,@numberOfPassengers = ISNULL(tripAdultsCount,0) + ISNULL(tripChildCount, 0) + ISNULL(tripYouthCount, 0) + ISNULL(tripSeniorsCount, 0)
	FROM Trip WHERE	tripkey=@TripKey

	--SELECT @tripSavedKey, @userkey, @numberOfPassengers

	SELECT TripKey, 'TripName' = tripName, UserKey, AdultCount = tripAdultsCount, ChildCount = tripChildCount
		, RecordLocator, StartDate, EndDate, tripStatusKey, tripSavedKey, InfantCount = tripInfantCount
		, YouthCount = tripYouthCount, SeniorsCount = tripSeniorsCount
	FROM Trip 
	WHERE tripkey = @TripKey

------------ PASSENGER INFO ------------
	SELECT  UR.userKey, PassengerEmailID = ISNULL(up.userEmail,''), PassengerFirstName = ISNULL(UR.userFirstName,'')
		, PassengerLastName = ISNULL(UR.userLastName,''), PassengerPhone = UP.workPhone
	FROM vault..[User] UR
		LEFT OUTER JOIN vault..UserProfile UP ON UR.userKey = up.userKey 
	WHERE ur.userkey = @userkey

------------ AIR INFO ------------

	SELECT  seg.airSegmentDepartureAirport 'Origin', seg.airSegmentArrivalAirport 'Destination'
		, seg.airSegmentDepartureDate 'DepartureDateTime', '' BookingType, @numberOfPassengers NumberOfPassengers
		, tripAdultsCount, tripChildCount, tripInfantCount, tripYouthCount, tripSeniorsCount
		, seg.airSegmentMarketingAirlineCode 'AirlineCode', resp.actualAirPrice BaseCost, (resp.actualAirPrice-0.10*resp.actualAirPrice) Disc_Price
		, resp.actualAirTax Tax
	FROM Trip WITH (NOLOCK) 
		INNER JOIN TripAirResponse  resp WITH (NOLOCK) ON trip.tripKey = resp.tripKey 
		INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
		INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
	WHERE tripGUIDKey = @tripSavedKey AND ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0 

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
	SELECT PickupAirport = pickupCity, PickupCity, PickupState, PickupCountry, DropoffAirport = dropoffCity, DropoffCity, 
		DropoffState, DropoffCountry, OneWayRental = '', PickUpDate, DropOutDate, CarCategoryCode, PrefferedVendorCode = '', 
		CarType = '', CarTransmission = SippCodeTransmission, DemandStatus = '', ModifiedBy  = userKey, ModifiedDate = GETDATE() 
	FROM dbo.vw_TripCarResponse  
	WHERE tripGUIDKey = @tripSavedKey  

	--SELECT PickupAirport = pickupCity   -- SabreLocations_1.LocationCity
	--	,PickupCity  -- SabreLocations_1.LocationCity
	--	,PickupState -- SabreLocations_1.Locationstate
	--	,PickupCountry  -- SabreLocations_1.LocationCountry
	--	,DropoffAirport = dropoffCity  -- CarContent.dbo.SabreLocations.LocationCity
	--	,DropoffCity   -- CarContent.dbo.SabreLocations.LocationCity
	--	,DropoffState  -- CarContent.dbo.SabreLocations.Locationstate
	--	,DropoffCountry  -- CarContent.dbo.SabreLocations.LocationCountry
	--	,OneWayRental = ''
	--	,PickUpDate  -- dbo.TripCarResponse.PickUpdate
	--	,DropOutDate  -- dbo.TripCarResponse.dropOutDate
	--	,CarCategoryCode -- dbo.TripCarResponse.carCategoryCode
	--	,PrefferedVendorCode = ''
	--	,CarType = ''
	--	,CarTransmission = SippCodeTransmission  -- CarContent.dbo.SippCodes.SippCodeTransmission
	--	,DemandStatus = '' 
	--	,ModifiedBy  = userKey  -- trip.userKey
	--	,ModifiedDate = GETDATE()				
	--FROM dbo.TripCarResponse WITH (NOLOCK) 
	--	INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) ON dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
	--	LEFT OUTER JOIN CarContent.dbo.SabreLocations 
	--	LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) ON 
	--				CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode AND 
	--				CarContent.dbo.SabreLocations.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
	--				CarContent.dbo.SabreLocations.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
	--	INNER JOIN CarContent.dbo.SabreLocations AS SabreLocations_1 ON CarContent.dbo.SabreVehicles.VendorCode = SabreLocations_1.VendorCode AND 
	--				CarContent.dbo.SabreVehicles.LocationAirportCode = SabreLocations_1.LocationAirportCode AND 
	--				CarContent.dbo.SabreVehicles.LocationCategoryCode = SabreLocations_1.LocationCategoryCode 
	--WHERE TripCarResponse..tripGUIDKey = @tripSavedKey
		--FROM dbo.vw_TripCarResponse
		--WHERE tripKey = @TripKey

------------ HOTEL INFO ------------

	SELECT AirportCode = '', City = CityName, State = StateCode, Country = CountryCode, Brand = '', Longitude
		, Latitude, CheckInDate, NumOfNights = DATEDIFF(DAY, startDate, endDate), NumOfRooms = '', DemandStatus = ''
		, ModifiedBy = userKey, ModifiedDate = GETDATE() 
	FROM vw_TripHotelResponse 
	WHERE tripGUIDKey = @tripSavedKey 

	--SELECT 
	--	 AirportCode = ''
	--	,City = CityName
	--	,State = StateCode
	--	,Country = CountryCode 
	--	,Brand = ''
	--	,Longitude
	--	,Latitude
	--	,CheckInDate
	--	,NumOfNights = DATEDIFF(DAY,startDate,endDate)  
	--	,NumOfRooms = ''
	--	,DemandStatus = ''
	--	,ModifiedBy = userKey
	--	,ModifiedDate = GETDATE()		
		 				
	--FROM 
	--	vw_TripHotelResponse
	--WHERE tripKey = @TripKey
			
END
GO
