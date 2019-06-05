SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 20 Jan 2015
-- Description:	Saves first day savetrip option for Air/Car/Hotel
-- =============================================
CREATE PROCEDURE [dbo].[USP_SaveFirstDaySaveTripOption] 
	@hasAir BIT = 0
	,@hasCar BIT = 0
	,@hasHotel BIT = 0
	,@tripKey BIGINT
	,@tripSavedKey UNIQUEIDENTIFIER
	,@userKey BIGINT
	,@tripFrom VARCHAR(3)
	,@tripTo VARCHAR(3)
	,@tripStartDate DATETIME
	,@tripEndMonth INT
	,@tripEndYear INT
	,@tripEndDate DATETIME
	
	/*##########AIR##########*/
	,@latestDealAirSavingsPerPerson FLOAT = 0
	,@latestDealAirSavingsTotal FLOAT = 0
	,@latestDealAirPricePerPerson FLOAT = 0
	,@latestDealAirPriceTotal FLOAT = 0
	,@airRequestTypeName VARCHAR(50) = ''
	,@airCabin VARCHAR(50) = ''
	,@latestAirLineCode VARCHAR(30) = ''
	,@latestAirlineName VARCHAR(64) = ''
	,@numberOfCurrentAirStops INT = 0
	,@airResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	,@originalPerPersonPriceAir FLOAT = 0
	,@originalTotalPriceAir FLOAT = 0
	,@vendorDetailsAir VARCHAR(100) = ''
	
	/*##########HOTEL##########*/
	,@latestDealHotelSavingsPerPerson FLOAT  = 0
	,@latestDealHotelSavingsTotal FLOAT  = 0
	,@latestDealHotelPricePerPerson FLOAT  = 0
	,@latestDealHotelPriceTotal FLOAT  = 0
	,@latestDealHotelPricePerPersonPerDay FLOAT  = 0
	,@hotelDailyPriceOriginal FLOAT  = 0
	,@hotelPricePerPersonOriginal FLOAT  = 0	
	,@hotelPriceTotalOriginal FLOAT  = 0
	,@hotelPricePerPersonPerDayOriginal FLOAT  = 0
	,@latestHotelRegionId INT = 0
	,@latestHotelId INT = 0
	,@latestHotelChainCode VARCHAR(20) = ''
	,@currentHotelsComId VARCHAR(10) = ''
	,@hotelResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	,@hotelName VARCHAR(100) = ''
	,@hotelRating FLOAT  = 0
	,@hotelRegionName VARCHAR(50) = ''
	,@vendorDetailsHotel VARCHAR(30) = ''
	,@noOfRooms INT = 0
	,@hotelNoOfDays INT = 0
	
	/*##########CAR##########*/
	 ,@latestDealCarSavingsPerDay FLOAT = 0
	 ,@latestDealCarSavingsTotal FLOAT = 0
	 ,@latestDealCarPricePerDay FLOAT = 0
	 ,@latestDealCarPriceTotal FLOAT = 0
     ,@originalPerDayPriceCar FLOAT = 0
     ,@originalTotalPriceCar FLOAT = 0
     ,@carClass VARCHAR(50) = ''
	 ,@carVendorCode VARCHAR(2) = ''
	 ,@latestCarVendorName VARCHAR(30) = ''
	 ,@carResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
					
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @fromCountryCode VARCHAR(2)
			,@fromCountryName VARCHAR(128)
			,@fromStateCode VARCHAR(2)
			,@fromCityName VARCHAR(64)
			,@toCountryCode VARCHAR(2)
			,@toCountryName VARCHAR(128)
			,@toStateCode VARCHAR(2)
			,@toCityName VARCHAR(64)
			,@remarks VARCHAR(50)
			,@crowdId INT
	
	SELECT TOP 1 @FromCountryCode = AL.CountryCode 
	,@FromCountryName = CL.CountryName
	,@FromStateCode = AL.StateCode
	,@FromCityName = AL.CityName
	FROM AirportLookup AL WITH (NOLOCK)
	LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)
	ON CL.CountryCode = AL.CountryCode
	WHERE AL.AirportCode = @tripFrom
	
	IF(@tripFrom <> @tripTo)
	BEGIN
		SELECT TOP 1 @ToCountryCode = AL.CountryCode 
		,@ToCountryName = CL.CountryName
		,@ToStateCode = AL.StateCode
		,@ToCityName = AL.CityName
		FROM AirportLookup AL WITH (NOLOCK)
		LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)
		ON CL.CountryCode = AL.CountryCode
		WHERE AL.AirportCode = @tripTo
	END
	ELSE
	BEGIN
		SELECT @ToCountryCode = @FromCountryCode
	   ,@ToCountryName = @FromCountryName
	   ,@ToStateCode = @FromStateCode
	   ,@ToCityName = @FromCityName
	END
	
	SET @crowdId = (SELECT CrowdId FROM TripSaved WITH (NOLOCK) WHERE tripSavedKey = @tripSavedKey)
	
	SET @remarks = 'First day deal'
	
	--FOR AIR
	IF(@hasAir = 1)
	BEGIN
		PRINT 'AIR'
		IF NOT EXISTS(SELECT tripKey FROM TripDetails WHERE tripKey = @tripKey)
		BEGIN
			INSERT INTO TripDetails
			(
				tripKey
				,tripSavedKey
				,userKey
				,tripFrom
				,tripTo
				,tripStartDate
				,tripEndMonth
				,tripEndYear
				,latestDealAirSavingsPerPerson
				,latestDealAirSavingsTotal
				,latestDealAirPricePerPerson
				,latestDealAirPriceTotal
				,AirRequestTypeName
				,AirCabin
				,FromCountryCode
				,FromCountryName
				,FromStateCode
				,FromCityName
				,ToCountryCode
				,ToCountryName
				,ToStateCode
				,ToCityName
				,tripEndDate
				,LatestAirLineCode
				,LatestAirlineName
				,NumberOfCurrentAirStops
				,originalPerPersonPriceAir
				,originalTotalPriceAir
				,CrowdId
			)
			VALUES
			(
				@tripKey
				,@tripSavedKey
				,@userKey
				,@tripFrom
				,@tripTo
				,@tripStartDate
				,@tripEndMonth
				,@tripEndYear
				,CONVERT(DECIMAL(10,2),(@latestDealAirSavingsPerPerson))
				,CONVERT(DECIMAL(10,2),(@latestDealAirSavingsTotal))
				,CONVERT(DECIMAL(10,2),(@latestDealAirPricePerPerson))
				,CONVERT(DECIMAL(10,2),(@latestDealAirPriceTotal))
				,@airRequestTypeName
				,@airCabin
				,@fromCountryCode
				,@fromCountryName
				,@fromStateCode
				,@fromCityName
				,@toCountryCode
				,@toCountryName
				,@toStateCode
				,@toCityName
				,@tripEndDate
				,@latestAirLineCode
				,@latestAirlineName
				,@numberOfCurrentAirStops
				,@originalPerPersonPriceAir
				,@originalTotalPriceAir
				,@crowdId
			)
		END
		ELSE
		BEGIN
			UPDATE TripDetails SET			
			latestDealAirSavingsPerPerson = CONVERT(DECIMAL(10,2),(@latestDealAirSavingsPerPerson))
			,latestDealAirSavingsTotal = CONVERT(DECIMAL(10,2),(@latestDealAirSavingsTotal))
			,latestDealAirPricePerPerson = CONVERT(DECIMAL(10,2),@latestDealAirPricePerPerson)
			,latestDealAirPriceTotal = CONVERT(DECIMAL(10,2),@latestDealAirPriceTotal)
			,AirRequestTypeName = @airRequestTypeName
			,AirCabin = @airCabin
			,FromCountryCode = @FromCountryCode
			,FromCountryName = @FromCountryName
			,FromStateCode = @FromStateCode
			,FromCityName = @FromCityName
			,ToCountryCode = @ToCountryCode
			,ToCountryName = @ToCountryName
			,ToStateCode = @ToStateCode
			,ToCityName = @ToCityName
			,LatestAirLineCode = @latestAirLineCode
			,LatestAirlineName = @latestAirlineName
			,NumberOfCurrentAirStops = @numberOfCurrentAirStops
			,originalPerPersonPriceAir = @originalPerPersonPriceAir
			,originalTotalPriceAir = @originalTotalPriceAir
			,CrowdId = @crowdId
			,lastUpdatedDate = GETDATE()
			WHERE tripKey = @tripKey
		END
		
		Insert Into TripSavedDeals 
		(
			tripKey
			,responseKey
			,componentType
			,currentPerPersonPrice
			,originalPerPersonPrice
			,fareCategory
			,isAlternate
			,vendorDetails
			,currentTotalPrice
			,originalTotalPrice
			,Remarks
		)
		VALUES
		(
			@tripKey
			,@airResponseKey
			,1
			,@latestDealAirPricePerPerson
			,@originalPerPersonPriceAir
			,'Publish'
			,1
			,@vendorDetailsAir
			,@latestDealAirPriceTotal
			,@originalTotalPriceAir
			,@remarks
		)		
	END
	
	--FOR HOTEL
	IF(@hasHotel = 1)
	BEGIN
		PRINT 'HOTEL'
		IF NOT EXISTS(SELECT tripKey FROM TripDetails WHERE tripKey = @tripKey)
		BEGIN
			INSERT INTO TripDetails
			(
				tripKey
				,tripSavedKey
				,userKey
				,tripFrom
				,tripTo
				,tripStartDate
				,tripEndDate
				,tripEndMonth
				,tripEndYear
				,HotelRegionName
				,HotelRating
				,HotelName
				,fromCountryCode
				,fromCountryName
				,fromStateCode
				,fromCityName
				,toCountryCode
				,toCountryName
				,toStateCode
				,toCityName
				,HotelResponseKey							
				,LatestHotelId							
				,LatestHotelRegionId	
				,latestDealHotelSavingsPerPerson
				,latestDealHotelSavingsTotal
				,latestDealHotelPricePerPerson
				,latestDealHotelPriceTotal
				,LatestDealHotelPricePerPersonPerDay				
				,originalPerPersonPriceHotel
				,originalTotalPriceHotel
				,originalPerPersonDailyTotalHotel
				,dailyPriceHotel				
				,LatestHotelChainCode
				,CurrentHotelsComId
				,NoOfHotelRooms
				,HotelNoOfDays
				,CrowdId
			)
			VALUES
			(
				@tripKey
				,@TripSavedKey
				,@UserKey
				,@TripFrom
				,@TripTo
				,@TripStartDate
				,@TripEndDate
				,@TripEndMonth
				,@TripEndYear
				,@hotelRegionName
				,ISNULL(@hotelRating, 0)
				,@HotelName
				,@FromCountryCode
				,@FromCountryName
				,@FromStateCode
				,@FromCityName
				,@ToCountryCode
				,@ToCountryName
				,@ToStateCode
				,@ToCityName
				,@HotelResponseKey							
				,@latestHotelId								
				,@latestHotelRegionId
				,@latestDealHotelSavingsPerPerson
				,@latestDealHotelSavingsTotal
				,@latestDealHotelPricePerPerson
				,@latestDealHotelPriceTotal
				,@latestDealHotelPricePerPersonPerDay				
				,@hotelPricePerPersonOriginal
				,@hotelPriceTotalOriginal
				,@hotelPricePerPersonPerDayOriginal
				,@hotelDailyPriceOriginal
				,@LatestHotelChainCode
				,@CurrentHotelsComId
				,@noOfRooms
				,@hotelNoOfDays
				,@crowdId
			)
		END
		ELSE
		BEGIN
			UPDATE TripDetails SET				
				HotelRegionName = @hotelRegionName
				,HotelRating = ISNULL(@hotelRating, 0)
				,HotelName = @HotelName
				,fromCountryCode = @FromCountryCode
				,fromCountryName = @FromCountryName
				,fromStateCode = @FromStateCode
				,fromCityName = @FromCityName
				,toCountryCode = @ToCountryCode
				,toCountryName = @ToCountryName
				,toStateCode = @ToStateCode
				,toCityName = @ToCityName
				,HotelResponseKey = @HotelResponseKey
				,LatestHotelId = @latestHotelId							
				,LatestHotelRegionId = @latestHotelRegionId
				,latestDealHotelSavingsPerPerson = @latestDealHotelSavingsPerPerson
				,latestDealHotelSavingsTotal = @latestDealHotelSavingsTotal
				,latestDealHotelPricePerPerson = @latestDealHotelPricePerPerson
				,latestDealHotelPriceTotal = @latestDealHotelPriceTotal
				,LatestDealHotelPricePerPersonPerDay = @latestDealHotelPricePerPersonPerDay				
				,originalPerPersonPriceHotel = @hotelPricePerPersonOriginal
				,originalTotalPriceHotel = @hotelPriceTotalOriginal
				,originalPerPersonDailyTotalHotel = @hotelPricePerPersonPerDayOriginal
				,dailyPriceHotel = @hotelDailyPriceOriginal				
				,LatestHotelChainCode = @latestHotelChainCode
				,CurrentHotelsComId = @CurrentHotelsComId
				,NoOfHotelRooms = @noOfRooms
				,HotelNoOfDays = @hotelNoOfDays
				,CrowdId = @crowdId
				,lastUpdatedDate = GETDATE()
			WHERE tripKey = @tripKey
		END
		
		INSERT INTO TripSavedDeals 
		(
			tripKey
			,responseKey
			,componentType
			,currentPerPersonPrice
			,originalPerPersonPrice
			,fareCategory
			,isAlternate
			,vendorDetails
			,currentTotalPrice
			,originalTotalPrice
			,responseDetailKey
			,Remarks
		)
		VALUES
		(
			@tripKey
			,@hotelResponseKey
			,4
			,@latestDealHotelPricePerPerson
			,@hotelPricePerPersonOriginal
			,'Publish'
			,1
			,@vendorDetailsHotel
			,@latestDealHotelPriceTotal
			,@hotelPriceTotalOriginal
			,@hotelResponseKey
			,@remarks
		)
		
	END
	
	--FOR CAR
	IF(@hasCar = 1)
	BEGIN
		PRINT 'CAR'
		IF NOT EXISTS(SELECT tripKey FROM TripDetails WHERE tripKey = @tripKey)
		BEGIN
			INSERT INTO TripDetails
			(
				tripKey
				,tripSavedKey
				,userKey
				,tripFrom
				,tripTo
				,tripStartDate
				,tripEndDate
				,tripEndMonth
				,tripEndYear
				,fromCountryCode
				,fromCountryName
				,fromStateCode
				,fromCityName
				,toCountryCode
				,toCountryName
				,toStateCode
				,toCityName
				,latestDealCarSavingsPerPerson
				,latestDealCarSavingsTotal
				,latestDealCarPricePerPerson
				,latestDealCarPriceTotal
				,CarClass
				,CarVendorCode
				,originalPerPersonPriceCar
				,originalTotalPriceCar
				,LatestCarVendorName
				,CrowdId
			)
			VALUES
			(
				@tripKey
				,@tripSavedKey
				,@userKey
				,@tripFrom
				,@tripTo
				,@tripStartDate
				,@tripEndDate
				,@tripEndMonth
				,@tripEndYear
				,@fromCountryCode
				,@fromCountryName
				,@fromStateCode
				,@fromCityName
				,@toCountryCode
				,@toCountryName
				,@toStateCode
				,@toCityName
				,@latestDealCarSavingsPerDay
				,@latestDealCarSavingsTotal
				,@latestDealCarPricePerDay
				,@latestDealCarPriceTotal
				,@carClass
				,@carVendorCode
				,@originalPerDayPriceCar
				,@originalTotalPriceCar
				,@latestCarVendorName
				,@crowdId
			)
		END
		ELSE
		BEGIN
			UPDATE TripDetails SET				
				latestDealCarSavingsPerPerson = @latestDealCarSavingsPerDay
				,latestDealCarSavingsTotal = @latestDealCarSavingsTotal
				,latestDealCarPricePerPerson = @latestDealCarPricePerDay
				,latestDealCarPriceTotal = @latestDealCarPriceTotal
				,CarClass = @carClass
				,CarVendorCode = @carVendorCode
				,originalPerPersonPriceCar = @originalPerDayPriceCar
				,originalTotalPriceCar = @originalTotalPriceCar
				,LatestCarVendorName = @latestCarVendorName
				,CrowdId = @crowdId
			WHERE tripKey = @tripKey
		END
		
		INSERT INTO TripSavedDeals 
		(
			tripKey
			,responseKey
			,componentType
			,currentPerPersonPrice
			,originalPerPersonPrice
			,fareCategory
			,responseDetailKey
			,isAlternate
			,vendorDetails
			,currentTotalPrice
			,originalTotalPrice
			,Remarks
		)
		VALUES
		(
			@tripKey
			,@carResponseKey
			,2
			,@latestDealCarPricePerDay
			,@originalPerDayPriceCar
			,'Publish'
			,@carResponseKey
			,1
			,@carVendorCode
			,@latestDealCarPriceTotal
			,@originalTotalPriceCar
			,@remarks
		) 
	END
	
END
GO
