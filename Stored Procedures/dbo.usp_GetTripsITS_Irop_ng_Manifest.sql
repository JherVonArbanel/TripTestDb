SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================                        
-- Author : Gopal                      
-- Create date : May/11/2018 
-- Description : Trip Information will be received from Web Service. Only Events related
-- Param : TripKey is optional. 

/*
exec usp_GetTripsITS_Irop_ng_Manifest @SiteGUID=N'764D1324-B6F4-4B07-9C91-11AE6427857E',@CompanyGUID=N'A12EB075-5508-49E8-90E7-03A15B83B4E1',@UserGUID=N'9CE9CD90-1254-4434-98F3-73C575058B20',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=N'',@StartDate=N'',@EndDate=N''
244587
SELECT * FROM TripAirSegments WHERE tripAirSegmentKey IN (1622749, 1622750)
exec  usp_GetTripsITS_Irop_ng_Manifest    '68596B78-C7CE-4DB6-BBA9-FF16BCB95853',
'EE1AE673-F50B-4FED-BE97-4791E4F2DD95','336F7799-BC21-4D42-B828-A7A5172A41D2','mytrips',null,null,'','','' 
*/
-- =============================================    

CREATE PROCEDURE [dbo].[usp_GetTripsITS_Irop_ng_Manifest]
--DECLARE
	@SiteGUID nvarchar(500) 
	, @CompanyGUID nvarchar(50) 
	, @UserGUID nvarchar(500)
	, @PageName NVARCHAR(500) -- 'mytrips','activetrips','pasttrips'
	, @PNR NVARCHAR(12)
	, @UDIDandValue NVARCHAR(MAX) --- 'UD10:MYNTHW,UD5:154,UD3:FLG001
	, @StartDate AS DATE
	, @EndDate AS DATE
	,@SearchUsers  NVARCHAR(MAX)=''
--WITH RECOMPILE	
AS 

BEGIN

--SELECT @SiteGUID=N'764D1324-B6F4-4B07-9C91-11AE6427857E',@CompanyGUID=N'A12EB075-5508-49E8-90E7-03A15B83B4E1'
--	,@UserGUID=N'9CE9CD90-1254-4434-98F3-73C575058B20',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=N'',@StartDate=N'',@EndDate=N''

--SELECT @SiteGUID=N'764D1324-B6F4-4B07-9C91-11AE6427857E',@CompanyGUID=N'E76DA9F3-4BE6-48D9-B4FC-C476D9F04BE3',@UserGUID=N'2F8630AB-EA63-4CA7-A615-4AD5BB883934',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=N'',@StartDate=N'',@EndDate=N''
--select @SiteGUID=N'764D1324-B6F4-4B07-9C91-11AE6427857E',@CompanyGUID=N'E76DA9F3-4BE6-48D9-B4FC-C476D9F04BE3',@UserGUID=N'2F8630AB-EA63-4CA7-A615-4AD5BB883934',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=N'',@StartDate=N'',@EndDate=N''
--SELECT @SiteGUID=N'764D1324-B6F4-4B07-9C91-11AE6427857E',@CompanyGUID=N'E76DA9F3-4BE6-48D9-B4FC-C476D9F04BE3'
--	,@UserGUID=N'2F8630AB-EA63-4CA7-A615-4AD5BB883934',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=N'',@StartDate=N'',@EndDate=N''

	DECLARE @tblSelectedUDIDs TABLE (ID INT, DATA NVARCHAR(500), UDID NVARCHAR(50), UDIDValue NVARCHAR(500))
	DECLARE @tblSelectedUDIDsTrips TABLE (ID INT, TRIPID BIGINT, DATA NVARCHAR(500), UDID NVARCHAR(50), UDIDValue NVARCHAR(500))
	DECLARE @tblSelectedUDIDsTripsForUDID TABLE (ID INT, TRIPID BIGINT, DATA NVARCHAR(500), UDID NVARCHAR(50), UDIDValue NVARCHAR(500))
	DECLARE	@dbResponse TABLE (STATUSCODE nvarchar(50), STATUSMESSAGE NVARCHAR(500))

	DECLARE @RoleTripId INT, @SiteKey INT, @CompanyKey INT, @UserKey INT, @AgencyKey INT
	
	SELECT	 @SiteKey=SiteKey, @AgencyKey = data.value('(/Site/Agency/key/node())[1]', 'INT')
	FROM	 Vault..SiteConfiguration 
	WHERE	 data.value('(/Site/siteGUID/node())[1]', 'NVARCHAR(500)') = @SiteGUID
	
	SELECT @CompanyKey = CompanyKey FROM Vault..Company WHERE CompanyGUID = @CompanyGUID 
	
	/* To Be Removed - Start */
	--IF ISNULL(@CompanyKey,0) = 0
	--BEGIN
	--SELECT @CompanyKey = CompanyKey FROM Vault..Company WHERE COMPANYKEY = CONVERT(INT, @CompanyGUID )
	--END
	/* To Be Removed - End */
	

	 DECLARE @FromDate as DateTime, @ToDate as DateTime  
 SET @fromDate = convert(varchar, convert(datetime, CASE WHEN @StartDate IS NULL THEN DATEADD(DAY, -7, GETDATE())  ELSE @StartDate END), 111) + ' 00:00:00'    
 SET @ToDate = convert(varchar, convert(datetime, CASE WHEN @EndDate IS NULL THEN DATEADD(YEAR, 100, GETDATE()) ELSE @EndDate END), 111) + ' 23:59:59'  

	SELECT @Userkey = UserKey FROM Vault..[User] WHERE UserGUID = @UserGUID
	SELECT @RoleTripId = userRoles FROM Vault..[UserProfile]  WHERE userKey = @UserKey

PRINT 'SiteKey--->' + CONVERT(VARCHAR, @siteKey)
PRINT 'AgencyKey --->' + CONVERT(VARCHAR, @AgencyKey)
PRINT 'UserKey--->' + CONVERT(VARCHAR, @userKey)
PRINT 'CompanyKey --->' + CONVERT(VARCHAR, @CompanyKey)

	CREATE TABLE #tblUser( UserKey INT ) 
	--CREATE TABLE #tblSerachedUsers( UserKey INT ) 
	
	CREATE TABLE #tmpTrip
	(                          
		tripKey				INT,                          
		TripRequestKey		INT,                          
		tripName			NVARCHAR(100),                          
		userKey				INT,                          
		recordLocator		NVARCHAR(100),                          
		startDate			DATETIME,                          
		endDate				DATETIME,                          
		tripStatusKey		INT,                          
		tripStatusName		NVARCHAR(100),	
		agencyKey			INT,                          
		userFirstName		NVARCHAR(300),                          
		userLastName		NVARCHAR(300),                          
		userLogin			NVARCHAR(300),    
		tripPurchasedKey	UNIQUEIDENTIFIER,
		groupKey			INT, 
		groupName			NVARCHAR(100),
		CreatedDate			DATETIME, 
		TravelerName		VARCHAR(200)
		, TotalCost			DECIMAL(18,2)
		, NoOfStops			NVARCHAR(100) NULL 
		, TripRouteType		NVARCHAR(100) NULL
		, TripFrom			NVARCHAR(100) NULL
		, TripTo			NVARCHAR(100) NULL
		, AirlineCode		NVARCHAR(20) NULL
		, Airlinelogo		NVARCHAR(MAX) NULL 
		, DepartTime		NVARCHAR(50) NULL 
		, ArrivalTime		NVARCHAR(50) NULL
		, HotelCode			NVARCHAR(20) NULL
		, HotelLogo			NVARCHAR(MAX) NULL
		, HotelName			NVARCHAR(MAX) NULL
		, StarRating		NVARCHAR(MAX) NULL
		, HotelLocation		NVARCHAR(MAX) NULL 
		, CarCode			NVARCHAR(20) NULL
		, CarLogo			NVARCHAR(MAX) NULL
		, CarVendorName		NVARCHAR(MAX) NULL
		, CarType			NVARCHAR(MAX) NULL
		, CarPickupLocation	NVARCHAR(MAX) NULL 
		, LocationImage		NVARCHAR(MAX) NULL
		, UserImage			NVARCHAR(MAX) NULL
		, ComponentType		VARCHAR(100) null
		, IsArrangerBookForGuest	INT
		, MeetingListName	NVARCHAR(100) 
		, Traveler			NVARCHAR(210)
		, Invited			NVARCHAR(210)
		, [Status]			NVARCHAR(50)
		, PageName			NVARCHAR(20)
	)              
    CREATE CLUSTERED INDEX IX_tripKey ON #tmpTrip(tripKey)
   	
	CREATE TABLE #tbl_vw_TRipCarResponse
	(                          
		tripKey			INT, 
		tripName		NVARCHAR(50), 
		userKey			INT, 
		recordLocator   NVARCHAR(50), 
		endDate			DATETIME, 
		startDate		DATETIME, 
		tripStatusKey   INT, 
		actualCarPrice  FLOAT, 
		actualCarTax	FLOAT, 
		carVendorKey	NVARCHAR(50), 
		CarCompanyName  NVARCHAR(64), 
		carLocationCode NVARCHAR(50), 
		PickUpdate		DATETIME, 
		dropOutDate		DATETIME, 
		SippCodeClass   NVARCHAR(32), 
		carResponseKey  UNIQUEIDENTIFIER, 
		siteKey			INT, 
		createdDate		DATETIME, 
		tripRequestKey  INT, 
		VehicleName		NVARCHAR(64), 
		NoOfDays		INT, 
		CityName		NVARCHAR(50),
		StateCode		NVARCHAR(50),
		CountryCode		NVARCHAR(50),
		HotelRating		NVARCHAR(50),
		DiscountFare	INT,
		RPH				INT
	)
	CREATE CLUSTERED INDEX ix_tripKey ON #tbl_vw_TRipCarResponse(tripKey)

	CREATE TABLE #tbl_vw_TripHotelResponse_tripaudit
	(
		tripKey			INT, 
		tripName		NVARCHAR(50), 
		userKey			INT, 
		recordLocator	NVARCHAR(50), 
		endDate			DATETIME, 
		startDate		DATETIME, 
		tripStatusKey	INT, 
		actualHotelPrice	FLOAT, 
		actualHotelTax	FLOAT, 
		ChainCode		NVARCHAR(50), 
		HotelName		NVARCHAR(100), 
		CityName		NVARCHAR(50), 
		StateCode		NVARCHAR(50), 
		checkInDate		DATETIME, 
		checkOutDate	DATETIME, 
		RatingType		NVARCHAR(16), 
		hotelResponseKey	UNIQUEIDENTIFIER, 
		siteKey			INT, 
		CreatedDate		DATETIME, 
		tripRequestKey	INT, 
		VehicleCompanyName	NVARCHAR(100), 
		NoofDays		INT, 
		CountryCode		NVARCHAR(50), 
		Rating			NVARCHAR(50), 
		DiscountFare	INT,
		RPH				INT
	)
    CREATE CLUSTERED INDEX IX_tripKey ON #tbl_vw_TripHotelResponse_tripaudit(tripKey)
    
	CREATE TABLE #tbl_vw_TripDetails_tripaudit
	(                          
		segmentOrder	INT, 
		[TYPE]			NVARCHAR(30), 
		tripKey			INT, 
		tripName		NVARCHAR(50), 
		userFirstName   NVARCHAR(50), 
		userLastName	NVARCHAR(50), 
		userKey			INT, 
		recordLocator   NVARCHAR(50), 
		endDate			DATETIME, 
		startDate		DATETime, 
		tripStatusKey   INT, 
		basecost		FLOAT, 
		tax				FLOAT, 
		vendorcode		NVARCHAR(10), 
		VendorName		NVARCHAR(64), 
		airSegmentDepartureAirport	NVARCHAR(50), 
		airSegmentArrivalAirport	NVARCHAR(50), 
		flightNumber	NVARCHAR(20), 
		departuredate   DATETIME, 
		arrivaldate		DATETIME, 
		carType			NVARCHAR(16), 
		Ratingtype		NVARCHAR(16), 
		responseKey		UNIQUEIDENTIFIER, 
		vendorLocator   NVARCHAR(50), 
		siteKey			INT, 
		createdDate		DATETIME, 
		tripRequestKey  INT, 
		VehicleCompanyName	NVARCHAR(100), 
		NoofDays		INT, 
		CityName		NVARCHAR(50), 
		StateCode		NVARCHAR(50), 
		CountryCode		NVARCHAR(50), 
		HotelRating		NVARCHAR(50), 
		DiscountFare	FLOAT, 
		RPH				INT
	) 
	CREATE CLUSTERED INDEX IX_tripKey ON #tbl_vw_TripDetails_tripaudit (tripKey)
	
	CREATE TABLE #trps
	(
		tripKey INT
		, PageName NVARCHAR(20)
	)
	CREATE CLUSTERED INDEX IX_tripKey ON #trps (tripKey)

	/*Commented by SUnilK on 13-06-2018
	INSERT INTO #trps
	SELECT T.tripKey, CASE WHEN T.startDate > GETDATE() THEN 'Up Coming' ELSE 'Past' END AS PageName
	FROM Vault.dbo.Meeting_Attendees Att
		LEFT OUTER JOIN trip T WITH(NOLOCK) ON Att.TripId = T.tripKey
	WHERE 
		T.recordlocator IS NOT NULL AND T.recordlocator <> '' 
		AND	T.siteKey = @SiteKey 
		--AND T.userKey = 732
		 AND T.tripStatusKey <> 10 AND T.tripStatusKey <> 17 
		--AND (T.Meetingcodekey IS NOT NULL AND T.Meetingcodekey <> '')
	*/

	--Added by SunilK on 13-06-2018 to display Multitraveller PNR details
	IF @CompanyKey=318
	BEGIN
	INSERT INTO #trps
	SELECT T.tripKey, CASE WHEN T.startDate > GETDATE() THEN 'Up Coming' ELSE 'Past' END AS PageName
	FROM trip T WITH(NOLOCK)               
		 INNER JOIN Trip..TripPassengerInfo U WITH(NOLOCK) ON T.tripKey =  U.TripKey  
		 LEFT OUTER JOIN Vault.dbo.Meeting_Attendees Att ON Att.TripId = T.tripKey 
		 LEFT OUTER JOIN Vault.dbo.Meeting MET ON MET.Meetingcode = T.Meetingcodekey 
	WHERE	
		(((T.recordlocator IS NOT NULL AND T.recordlocator <> '' ) OR (T.tripStatusKey = 21))
		OR (T.recordlocator IS NULL and T.tripSavedKey IS NOT NULL and T.tripPurchasedKey IS NULL))  -- Added by SunilK on 12062018 to display savetrips
		AND T.siteKey = @SiteKey 
		AND T.tripStatusKey <> 10 AND T.tripStatusKey <> 17 
		AND ISNULL(MET.CompanyKey,0) = @CompanyKey
		and t.CreatedDate > '2018-05-16 14:08:11.403'
	END
	ELSE
	BEGIN
	INSERT INTO #trps
	SELECT T.tripKey, CASE WHEN T.startDate > GETDATE() THEN 'Up Coming' ELSE 'Past' END AS PageName
	FROM trip T WITH(NOLOCK)               
		 INNER JOIN Trip..TripPassengerInfo U WITH(NOLOCK) ON T.tripKey =  U.TripKey  
		 LEFT OUTER JOIN Vault.dbo.Meeting_Attendees Att ON Att.TripId = T.tripKey 
		 LEFT OUTER JOIN Vault.dbo.Meeting MET ON MET.Meetingcode = T.Meetingcodekey 
	WHERE	
		(((T.recordlocator IS NOT NULL AND T.recordlocator <> '' ) OR (T.tripStatusKey = 21))
		OR (T.recordlocator IS NULL and T.tripSavedKey IS NOT NULL and T.tripPurchasedKey IS NULL))  -- Added by SunilK on 12062018 to display savetrips
		AND T.siteKey = @SiteKey 
		AND T.tripStatusKey <> 10 AND T.tripStatusKey <> 17 
		AND ISNULL(MET.CompanyKey,0) = @CompanyKey
	END
	

--SELECT 'Delete it', * FROM #trps

	CREATE TABLE #trpsArrivalSegment
	(
		tripKey INT
		, tripAirLegsKey	BIGINT
		, tripAirSegmentKey BIGINT
		, tripOrigin		BIGINT
		, Origin			NVARCHAR(5)
		, LastLeg			NVARCHAR(5)
		, Dest				NVARCHAR(5)
		, Flight			NVARCHAR(25)
		, [Time]			DATETIME
		, [Type]			NVARCHAR(20)
	)	
	CREATE CLUSTERED INDEX IX_tripKey ON #trpsArrivalSegment (tripKey)

	--INSERT INTO #trpsArrivalSegment(tripKey, tripAirLegsKey, tripAirSegmentKey, [Type], tripOrigin)
	INSERT INTO #trpsArrivalSegment(tripKey, tripAirSegmentKey, [Type], tripOrigin)
	SELECT T.tripKey, --TAL.tripAirLegsKey
			MAX(TAS.tripAirSegmentKey), 'Arrival', MIN(TAS.tripAirSegmentKey)
	FROM #trps T	
		INNER JOIN Trip..Trip Trp ON T.tripKey = Trp.tripKey
		INNER JOIN Trip..TripAirResponse TAR ON Trp.TripPurchasedKey = TAR.tripGUIDKey
		INNER JOIN Trip..TripAirLegs TAL ON TAR.airResponseKey = TAL.airResponseKey
		INNER JOIN Trip..TripAirSegments TAS ON TAL.tripAirLegsKey = TAS.tripAirLegsKey 
	WHERE TAL.airLegNumber = 1 AND TAR.isDeleted = 0 AND TAL.isDeleted = 0 AND TAS.isDeleted = 0
	GROUP BY T.tripKey--, TAL.tripAirLegsKey
	ORDER BY T.tripKey 

--SELECT 'Delete it', * FROM #trpsArrivalSegment where tripkey=3855

	UPDATE t
	SET Dest = TAS.airSegmentArrivalAirport
		, LastLeg = TAS.airSegmentArrivalAirport
		, [Time] = TAS.airSegmentArrivalDate
		, Flight = TAS.airSegmentMarketingAirlineCode + ' #' + CONVERT(VARCHAR, ISNULL(TAS.airSegmentFlightNumber, 0))
		, Origin = Origin.airSegmentDepartureAirport
	FROM #trpsArrivalSegment t
		INNER JOIN Trip..TripAirSegments TAS ON t.tripAirSegmentKey = TAS.tripAirSegmentKey
		INNER JOIN Trip..TripAirSegments Origin ON t.tripOrigin = Origin.tripAirSegmentKey

	--UPDATE t
	--SET Origin = Origin.airSegmentDepartureAirport
	--FROM #trpsArrivalSegment t
	--	INNER JOIN Trip..TripAirSegments Origin ON t.tripOrigin = Origin.tripAirSegmentKey

	CREATE TABLE #trpsDepartureSegment
	(
		tripKey INT
		, tripAirLegsKey	BIGINT
		, tripAirSegmentKey BIGINT
		, DestSegmentKey	BIGINT
		, LastLegKey		BIGINT
		, LastSegmentKey	BIGINT
		,Origin				NVARCHAR(5)
		,LastLeg			NVARCHAR(5)
		,Dest				NVARCHAR(5)
		,Flight				NVARCHAR(25)
		,[Time]				DATETIME
		,[Type]				NVARCHAR(20)
	)	
	CREATE CLUSTERED INDEX IX_tripKey ON #trpsDepartureSegment (tripKey)

	--INSERT INTO #trpsDepartureSegment(tripKey, tripAirLegsKey, tripAirSegmentKey, DestSegmentKey, [Type], LastLegKey)
	INSERT INTO #trpsDepartureSegment(tripKey, tripAirSegmentKey, DestSegmentKey, [Type], LastLegKey)
	SELECT T.tripKey, --TAL.tripAirLegsKey, 
			MIN(TAS.tripAirSegmentKey), MAX(TAS.tripAirSegmentKey), 'Departure', MAX(TAL.tripAirLegsKey)
	FROM #trps T	
		INNER JOIN Trip..Trip Trp ON T.tripKey = Trp.tripKey
		INNER JOIN Trip..TripAirResponse TAR ON Trp.TripPurchasedKey = TAR.tripGUIDKey
		INNER JOIN Trip..TripAirLegs TAL ON TAR.airResponseKey = TAL.airResponseKey
		INNER JOIN Trip..TripAirSegments TAS ON TAL.tripAirLegsKey = TAS.tripAirLegsKey 
	WHERE TAL.airLegNumber = 2 AND TAR.isDeleted = 0 AND TAL.isDeleted = 0 AND TAS.isDeleted = 0
	GROUP BY T.tripKey--, TAL.tripAirLegsKey
	ORDER BY T.tripKey 

	UPDATE t
	SET DestSegmentKey = (SELECT MIN(TAS.tripAirSegmentKey) FROM Trip..TripAirSegments TAS WHERE TAS.tripAirLegsKey = t.LastLegKey)
	FROM #trpsDepartureSegment t
--		INNER JOIN Trip..TripAirSegments TAS ON t.LastLegKey = TAS.tripAirLegsKey

--select 'Delete it',* from #trpsDepartureSegment where tripkey=244587

	UPDATE t
	SET Dest = TAS.airSegmentDepartureAirport
		, [Time] = TAS.airSegmentDepartureDate
		, Flight = TAS.airSegmentMarketingAirlineCode + ' #' + CONVERT(VARCHAR, ISNULL(TAS.airSegmentFlightNumber, 0))
	FROM #trpsDepartureSegment t
		INNER JOIN Trip..TripAirSegments TAS ON t.tripAirSegmentKey = TAS.tripAirSegmentKey
	
	UPDATE t
	SET Origin = TAS.airSegmentDepartureAirport -- TAS.airSegmentArrivalAirport
	FROM #trpsDepartureSegment t
		INNER JOIN Trip..TripAirSegments TAS ON t.DestSegmentKey = TAS.tripAirSegmentKey

	UPDATE t
	SET LastSegmentKey = (SELECT MAX(TAS.tripAirSegmentKey) FROM Trip..TripAirSegments TAS WHERE TAS.tripAirLegsKey = t.LastLegKey)
	FROM #trpsDepartureSegment t
		--INNER JOIN Trip..TripAirSegments TAS ON t.LastLegKey = TAS.tripAirLegsKey

	UPDATE t
	SET LastLeg = TAS.airSegmentArrivalAirport
	FROM #trpsDepartureSegment t
		INNER JOIN Trip..TripAirSegments TAS ON t.LastSegmentKey = TAS.tripAirSegmentKey


--SELECT 'Delete it', * FROM #trpsDepartureSegment

	INSERT INTO #tblUser                          
	SELECT DISTINCT userKey FROM Vault.dbo.GetAllArrangees(@userkey, @companyKey)                       

	/*We will consider this lateron*/	
	DECLARE @SixHrsBeforeTime DATETIME = DATEADD(HOUR, -6, GETDATE())

	IF @RoleTripId = 1  -- Travller 
	BEGIN
Print 'Inside @RoleTripId'

		INSERT INTO #tmpTrip 
		SELECT Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate, Trip.endDate
			, Trip.tripStatusKey,	CASE	WHEN Trip.StartDate < @SixHrsBeforeTime AND Trip.tripStatusKey IN (2,3) Then 'Past'
											WHEN Trip.StartDate >= @SixHrsBeforeTime AND Trip.tripStatusKey IN (2,3) THEN 'Purchased'
											ELSE S.tripStatusName 
									END
			, Trip.agencyKey, U.userFirstName, U.userLastName, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin 
			, trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
			, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
			, 0, NULL NoOfStops, NULL TripRouteType, NULL TripFrom, NULL TripTo, NULL AirlineCode, NULL Airlinelogo 
			, NULL DepartTime, NULL ArrivalTime, NULL HotelCode, NULL HotelLogo, NULL HotelName, NULL StartRating 
			, NULL HotelLocation, NULL CarCode, NULL CarLogo, NULL CarVendorName, NULL CarType, NULL CarPickupLocation 
			, NULL LocationImage, NULL UserImage, NULL ComponentType, trip.IsArrangerBookForGuest 
			, MET.meetingListName--, ISNULL(Att.FirstName, '') + ' ' + ISNULL(Att.LastName, '') AS Traveler
			, ISNULL(TPI.PassengerFirstName, '') + ' ' + ISNULL(TPI.PassengerLastName, '') AS Traveler
			--, ISNULL(Inv.userFirstName, '') + ' ' + ISNULL(Inv.UserLastName, '') AS Invited --Commented by SunilK on 13-06-2018
			, COALESCE(Inv.userFirstName, TPI.PassengerFirstName) + ' ' 
			+ COALESCE(Inv.UserLastName, TPI.PassengerLastName) AS Invited --Added by SunilK on 13-06-2018 to display invited name
			, S.tripStatusName AS [Status], T.PageName
		FROM #trps T 
			INNER JOIN Trip.dbo.trip WITH(NOLOCK) ON T.tripKey = trip.tripKey
			LEFT OUTER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17
			INNER JOIN Trip.dbo.TripStatusLookup S WITH (NOLOCK) ON trip.tripStatusKey = S.tripStatusKey  
			LEFT OUTER JOIN vault.dbo.[Group] GRP ON trip.GroupKey = GRP.groupKey
			INNER JOIN Trip.dbo.TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
			LEFT OUTER JOIN Vault.dbo.Meeting MET ON MET.Meetingcode = Trip.Meetingcodekey 
			LEFT OUTER JOIN Vault.dbo.Meeting_Attendees Att ON Att.TripId = Trip.tripKey AND Att.MeetingCodeKey = MET.MeetingCodeKey
			LEFT OUTER JOIN Vault.dbo.[User] Inv ON Att.CreatedBy = Inv.userKey
		WHERE trip.recordlocator IS NOT NULL AND trip.recordlocator <> '' 
			AND trip.siteKey = @siteKey --AND trip.userKey = @userkey
			--AND (Trip.Meetingcodekey IS NOT NULL AND Trip.Meetingcodekey <> '')
			
	END
	ELSE
	BEGIN
Print 'Inside @RoleTripId Else --->'
		
		INSERT INTO #tmpTrip 
		SELECT Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate, Trip.endDate
			, Trip.tripStatusKey,	CASE	WHEN Trip.StartDate  < @SixHrsBeforeTime AND Trip.tripStatusKey IN (2,3) THEN 'Past' 
											WHEN Trip.StartDate >= @SixHrsBeforeTime AND Trip.tripStatusKey IN (2,3) THEN 'Purchased'
											ELSE S.tripStatusName 
									END
			, Trip.agencyKey, U.userFirstName, U.userLastName, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin 
			, trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
			, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
			, 0, NULL NoOfStops, NULL TripRouteType, NULL TripFrom, NULL TripTo, NULL AirlineCode, NULL Airlinelogo 
			, NULL DepartTime, NULL ArrivalTime, NULL HotelCode, NULL HotelLogo, NULL HotelName, NULL StartRating 
			, NULL HotelLocation, NULL CarCode, NULL CarLogo, NULL CarVendorName, NULL CarType, NULL CarPickupLocation 
			, NULL LocationImage, NULL UserImage, NULL ComponentType, trip.IsArrangerBookForGuest
			, MET.meetingListName--, ISNULL(Att.FirstName, '') + ' ' + ISNULL(Att.LastName, '') AS Traveler
			, ISNULL(TPI.PassengerFirstName, '') + ' ' + ISNULL(TPI.PassengerLastName, '') AS Traveler
			--, ISNULL(Inv.userFirstName, '') + ' ' + ISNULL(Inv.UserLastName, '') AS Invitee -- Commented by SunilK on 13-06-2018
			, COALESCE(Inv.userFirstName, TPI.PassengerFirstName) + ' ' 
			+ COALESCE(Inv.UserLastName, TPI.PassengerLastName) AS Invited --Added by SunilK on 13-06-2018 to display invited name
			, S.tripStatusName AS [Status], T.PageName
		FROM #trps T 
			INNER JOIN Trip.dbo.trip WITH(NOLOCK) ON T.tripKey = trip.tripKey
			LEFT OUTER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
			LEFT OUTER JOIN vault.dbo.[Group] GRP ON Trip.GroupKey = GRP.groupKey
			INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
			LEFT OUTER JOIN Vault.dbo.Meeting MET ON MET.Meetingcode = Trip.Meetingcodekey 
			LEFT OUTER JOIN Vault.dbo.Meeting_Attendees Att ON Att.TripId = Trip.tripKey AND Att.MeetingCodeKey = MET.MeetingCodeKey
			LEFT OUTER JOIN Vault.dbo.[User] Inv ON Att.CreatedBy = Inv.userKey
		WHERE Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' 
			AND	Trip.siteKey = @siteKey --AND trip.userKey = @userkey 
			--AND (Trip.Meetingcodekey IS NOT NULL AND Trip.Meetingcodekey <> '')

	END

--SELECT 'Delete it', * FROM #tmpTrip

	INSERT	
	INTO	#tbl_vw_TRipCarResponse 
	SELECT	trip.tripKey, trip.tripName, trip.userKey, TripCarResponse.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey
		, dbo.TripCarResponse.actualCarPrice, dbo.TripCarResponse.actualCarTax, dbo.TripCarResponse.carVendorKey
		, CarContent.dbo.CarCompanies.CarCompanyName, dbo.TripCarResponse.carLocationCode, dbo.TripCarResponse.PickUpdate
		, dbo.TripCarResponse.dropOutDate, CarContent.dbo.SippCodes.SippCodeClass, dbo.TripCarResponse.carResponseKey
		, Trip.siteKey, trip.createdDate, trip.tripRequestKey, CarContent.dbo.SabreVehicles.VehicleName, TripCarResponse.NoOfDays
		, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare
		, TripCarResponse.RPH AS RPH
	FROM	CarContent.dbo.CarCompanies WITH (NOLOCK) 
		INNER JOIN Trip.dbo.TripCarResponse WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK)	ON Trip.dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
			ON CarContent.dbo.CarCompanies.CarCompanyCode = Trip.dbo.TripCarResponse.carVendorKey AND Trip.dbo.TripCarResponse.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.SabreLocations 
		LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK)	ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode 
					AND	CarContent.dbo.SabreLocations.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
					AND CarContent.dbo.SabreLocations.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
			ON Trip.dbo.TripCarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
					AND Trip.dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode 
					AND Trip.dbo.TripCarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
					AND Trip.dbo.TripCarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
					AND Trip.dbo.TripCarResponse.SupplierId = 'Sabre' 
					AND ISNULL (Trip.dbo.TripCarResponse.ISDELETED ,0) = 0 
		INNER JOIN Trip.dbo.Trip WITH (NOLOCK) ON 
			(	Trip.dbo.TripCarResponse.tripKey = Trip.dbo.Trip.tripKey 
				OR ( Trip.dbo.TripCarResponse.tripguidkey = Trip.dbo.trip.tripPurchasedKey 
				AND (Trip.dbo.TripCarResponse.tripKey IS NULL OR Trip.dbo.TripCarResponse.tripKey = 0)) 
			) AND Trip.tripStatusKey <> 17 
	INNER JOIN #tmpTrip tmp ON Trip.tripKey = tmp.tripKey 

	UNION ALL

	SELECT	trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey
		, TR.actualCarPrice, TR.actualCarTax, TR.carVendorKey
		, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate
		, TR.dropOutDate, S.VehicleClass AS SippCodeClass, TR.carResponseKey
		, Trip.siteKey, trip.createdDate, trip.tripRequestKey, AV.ALVehicleName, TR.NoOfDays
		, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare
		, TR.RPH AS RPH
	FROM	Trip.dbo.TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.AlamoLocations AL WITH (NOLOCK) ON TR.carLocationCode = LEFT(AL.ALLocationCode, 3) AND AL.ALAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.ALAMOVEHICLES AV WITH (NOLOCK) ON AL.ALLocationCode = AV.ALLOCATIONCODE AND AV.ALVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.AlamoLocations AL_1 ON AL.ALLocationCode = AL_1.ALLocationCode AND AL_1.ALAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON AV.ALVEHICLECLASSSIZE = S.VehicleClassSize 
		INNER JOIN Trip.dbo.Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )))
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE	TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'AL'  AND Trip.dbo.Trip.tripStatusKey <> 17 

	UNION ALL

	SELECT	trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey
		, TR.actualCarPrice, TR.actualCarTax, TR.carVendorKey
		, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate
		, TR.dropOutDate, S.VehicleClass AS SippCodeClass, TR.carResponseKey
		, Trip.siteKey, trip.createdDate, trip.tripRequestKey, NV.ZLVehicleName, TR.NoOfDays
		, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare
		, TR.RPH AS RPH
	FROM	TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.NationalLocations NL WITH (NOLOCK) ON TR.carLocationCode = LEFT(NL.ZLLocationCode, 3) AND NL.ZLAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.NationalVehicles NV WITH (NOLOCK) ON NL.ZLLocationCode = NV.ZLLOCATIONCODE AND NV.ZLVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.NationalLocations NL_1 ON NL.ZLLocationCode = NL_1.ZLLocationCode AND NL_1.ZLAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON NV.ZLVEHICLECLASSSIZE = S.VehicleClassSize
		INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 ))) 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE	TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZL'  AND Trip.dbo.Trip.tripStatusKey <> 17  
	
	UNION ALL

	SELECT	trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey
		, TR.actualCarPrice, TR.actualCarTax, TR.carVendorKey
		, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate
		, TR.dropOutDate, S.VehicleClass AS SippCodeClass, TR.carResponseKey
		, Trip.siteKey, trip.createdDate, trip.tripRequestKey, ZV.ZRVehicleName, TR.NoOfDays
		, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare
		, TR.RPH AS RPH
	FROM	TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.DollarLocations ZL WITH (NOLOCK) ON TR.carLocationCode = LEFT(ZL.ZRLocationCode, 3) AND ZL.ZRAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.DollarVehicles ZV WITH (NOLOCK) ON ZL.ZRLocationCode = ZV.ZRLOCATIONCODE AND ZV.ZRVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.DollarLocations ZL_1 ON ZL.ZRLocationCode = ZL_1.ZRLocationCode AND ZL_1.ZRAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON ZV.ZRVEHICLECLASSSIZE = S.VehicleClassSize
		INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )))
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE	TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZR'  AND Trip.dbo.Trip.tripStatusKey <> 17  

	UNION ALL

	SELECT	trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey
		, TR.actualCarPrice, TR.actualCarTax, TR.carVendorKey
		, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate
		, TR.dropOutDate, S.VehicleClass AS SippCodeClass, TR.carResponseKey
		, Trip.siteKey, trip.createdDate, trip.tripRequestKey, TV.ZTVEHICLENAME, TR.NoOfDays
		, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare
		, TR.RPH AS RPH
	FROM	TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.ThriftyLocations TL WITH (NOLOCK) ON TR.carLocationCode = LEFT(TL.ZTLocationCode, 3) AND TL.ZTAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.ThriftyVehicles TV WITH (NOLOCK) ON TL.ZTLocationCode = TV.ZTLOCATIONCODE AND TV.ZTVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.ThriftyLocations TL_1 ON TL.ZTLocationCode = TL_1.ZTLocationCode AND TL_1.ZTAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON TV.ZTVEHICLECLASSSIZE = S.VehicleClassSize
		INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )) ) 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE	TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZT' AND dbo.Trip.tripStatusKey <> 17  

	INSERT INTO	#tbl_vw_TripHotelResponse_tripaudit
	SELECT	tripKey, tripName, userKey, recordLocator, endDate, startDate, tripStatusKey, actualHotelPrice, actualHotelTax
		, ChainCode, HotelName, CityName, StateCode, checkInDate, checkOutDate, RatingType, hotelResponseKey, siteKey
		, CreatedDate, tripRequestKey, VehicleCompanyName, NoofDays, CountryCode, Rating, DiscountFare, RPH
	FROM 
	(
		SELECT	ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID, Trip.tripKey ORDER BY SH.AddDate DESC) RN
		,dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
		,dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
		,HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
		,HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
		,'' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare, HR.RPH as RPH   
		FROM #tmpTrip tmp 
			INNER JOIN dbo.Trip ON tmp.tripKey = Trip.tripKey
			INNER JOIN Trip.dbo.TripHotelResponse AS HR WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey 
				AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
			LEFT OUTER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) ON HR.supplierHotelKey = SH.SupplierHotelId 
				AND HR.supplierId = SH.SupplierFamily
			LEFT OUTER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK) ON SH.HotelId = HT.HotelId 
		WHERE HR.isDeleted = 0 
	)a WHERE a.RN = 1
	
	UNION 
	
	SELECT	tripKey, tripName, userKey, recordLocator, endDate, startDate, tripStatusKey, actualHotelPrice, actualHotelTax
		, ChainCode, HotelName, CityName, StateCode, checkInDate, checkOutDate, RatingType, hotelResponseKey, siteKey
		, CreatedDate, tripRequestKey, VehicleCompanyName, NoofDays, CountryCode, Rating, DiscountFare, RPH 
	FROM 
	(
		SELECT	ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID, Trip.tripKey ORDER BY SH.AddDate DESC) RN
			,dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
			,dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
			,HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
			,HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
			,'' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare, HR.RPH AS RPH
		FROM #tmpTrip tmp
			INNER JOIN dbo.Trip ON tmp.tripKey = Trip.tripKey
			INNER JOIN Trip.dbo.TripHotelResponse AS HR WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
			LEFT OUTER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) ON HR.supplierHotelKey = SH.SupplierHotelId 
				AND HR.supplierId = SH.SupplierFamily
			LEFT OUTER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK) ON SH.HotelId = HT.HotelId AND HR.isDeleted = 0 
		WHERE	(ISNULL(HR.isDeleted, 0) = 0) 
	)b WHERE b.RN = 1

	INSERT	INTO	#tbl_vw_TripDetails_tripaudit 
	SELECT	ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder
		, 'air' AS TYPE, trip.tripKey, trip.tripName, u.userFirstName, u.userLastName, u.userKey, trip.recordLocator
		, trip.endDate, trip.startDate, trip.tripStatusKey, resp.actualAirPrice AS basecost, resp.actualAirTax AS tax
		, seg.airSegmentMarketingAirlineCode AS vendorcode, vendor.ShortName AS VendorName, seg.airSegmentDepartureAirport
		, seg.airSegmentArrivalAirport, CONVERT(varchar(20), seg.airSegmentFlightNumber) AS flightNumber
		, seg.airSegmentDepartureDate AS departuredate, seg.airSegmentArrivalDate AS arrivaldate, NULL AS carType
		, CONVERT(varchar(20), seg.airLegNumber) AS Ratingtype, seg.airSegmentKey AS responseKey, seg.recordLocator AS vendorLocator
		, Trip.siteKey, trip.createdDate, trip.tripRequestKey, '' As VehicleCompanyName, 0 as NoofDays, '' as CityName 
		, '' as StateCode, '' as CountryCode, '' as HotelRating, ISNULL(resp.discountedBaseFare,0) as DiscountFare, ISNULL(seg.RPH, 0) 
	FROM	Trip WITH (NOLOCK) 
		INNER JOIN TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
		INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
		INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
		LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 
		LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE	ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   and Trip.dbo.Trip.tripStatusKey <> 17 

	UNION 

	SELECT	ROW_NUMBER() OVER (ORDER BY t.carresponsekey)
		, 'car' AS TYPE, t.tripKey, t.tripName, u.userFirstName, u.userLastName, u.userKey, t.recordLocator
		, t.endDate, t.startDate, t.tripStatusKey, t.actualCarPrice, t.actualCarTax
		, t.carVendorKey, carCompanyName, t.carLocationCode
		, t.carLocationCode, NULL
		, t.PickUpdate, t.dropOutDate, SippCodeClass
	,NULL AS Ratingtype
	,t.carResponseKey
	,t.recordLocator
	,t.siteKey
	,t.createdDate
	,t.tripRequestKey
	,VehicleName As VehicleCompanyName
	,t.NoofDays
	,'' as CityName
	,'' as StateCode
	,'' as CountryCode 
	,'' as HotelRating
	,0 as  DiscountFare
	,ISNULL(t.RPH, 0) 
	FROM	#tbl_vw_TRipCarResponse t WITH (NOLOCK) 
	INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
	--LEFT OUTER JOIN TripCarResponse seg ON tmp.tripPurchasedKey= seg.tripGUIDKey
	LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

	UNION 

	SELECT	ROW_NUMBER() OVER (ORDER BY t.hotelresponsekey)
	,'hotel' AS TYPE
	,t.tripkey
	,t.tripName
	,u.userFirstName
	,u.userLastName
	,u.userKey
	,t.recordLocator
	,t.endDate
	,t.startDate
	,t.tripStatusKey
	,t.actualHotelPrice
	,0 --	,t.actualHotelTax
	,ChainCode
	,t.hotelname
	,cityname + ',' + StateCode
	,cityname + ',' + StateCode
	,NULL
	,t.checkindate
	,t.checkoutdate
	,NULL
	,Ratingtype
	,t.hotelResponseKey
	,t.recordLocator
	,t.siteKey
	,t.createdDate
	,t.tripRequestKey 
	,'' As VehicleCompanyName 
	,0 as NoofDays
	,t.CityName
	,t.StateCode
	,t.CountryCode
	,t.Rating AS HotelRating
	,0 AS DiscountFare
	,ISNULL(t.RPH, 0)
	FROM	#tbl_vw_TripHotelResponse_tripaudit t WITH (NOLOCK) 
	INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
	--LEFT OUTER JOIN TripHotelResponse seg ON tmp.tripPurchasedKey = seg.tripGUIDKey
	LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

--SELECT 'Delete this-#tmpTrip', * FROM #tmpTrip WHERE tripKey = 219145

--SELECT 'Delete this-#tbl_vw_TripDetails_tripaudit', * FROM #tbl_vw_TripDetails_tripaudit Order By tripKey, segmentOrder

	UPDATE	t 
	SET	TotalCost = (vw.basecost + vw.tax)
	FROM	#tmpTrip t
	INNER JOIN 
	(
		SELECT tripKey, SUM(basecost) basecost, SUM(tax) tax
		FROM --#tbl_vw_TripDetails_tripaudit 
		(	SELECT tripKey, [TYPE], basecost, tax
			FROM #tbl_vw_TripDetails_tripaudit 
			GROUP BY tripKey, [TYPE], basecost, tax 
		) t
		GROUP BY tripKey --, basecost, tax 
	)vw ON t.tripKey = vw.tripKey

	INSERT INTO @dbResponse (STATUSCODE, STATUSMESSAGE)
	SELECT	 STATUSCODE = '100' -- Skip Not Action required.
	,STATUSMESSAGE = 'Okay'
	
	SELECT	 STATUSCODE
	,STATUSMESSAGE
	FROM	 @dbResponse

	CREATE TABLE #Temp_Airline_Details
	(
		TripKey int,
		AirlineCode nvarchar(50),
	) 
	CREATE CLUSTERED INDEX IX_TripKey ON #Temp_Airline_Details(TripKey)
	
	IF OBJECT_ID('tempdb..#Temp_Air') IS NOT NULL
	DROP TABLE #Temp_Air
	
	SELECT DISTINCT trip.tripKey,trip.tripRequestKey,seg.airSegmentMarketingAirlineCode,vendor.ShortName AS VendorName
	INTO #Temp_Air 
	FROM Trip WITH (NOLOCK) 
		INNER JOIN TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
		INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
		INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
		LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 
		INNER JOIN #tmpTrip tmp ON trip.tripKey=tmp.tripKey 
	WHERE ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0 AND Trip.dbo.Trip.tripStatusKey <> 17
	
	INSERT INTO #Temp_Airline_Details
	SELECT DISTINCT s.tripKey,CASE WHEN a.IsMultiAir>1 then 'multiple airlines' else s.airSegmentMarketingAirlineCode end AirlineCode
	FROM #Temp_Air s 
	INNER JOIN   
		(select tripKey,COUNT(airSegmentMarketingAirlineCode) IsMultiAir FROM #Temp_Air GROUP BY tripkey) A ON s.tripKey=a.tripkey


	UPDATE T SET TripRouteType= CASE WHEN AR.AirRequestTypekey=1 THEN 'One Way'
								WHEN AR.AirRequestTypekey=2 THEN 'Round Trip'
								WHEN AR.AirRequestTypekey=3 THEN 'Multi City' 
							END
	FROM	#tmpTrip T
			INNER JOIN Trip..TripRequest_air TRA ON TRA.tripRequestKey=T.tripRequestKey
			INNER JOIN Trip..AirRequest AR ON AR.airRequestkey=TRA.airRequestkey 
			
	
	 --UPDATE T SET T.NoOfStops=1, T.DepartTime='6:23P' ,T.ArrivalTime='8:55P'
		--		--,HotelName='Hilton Chicago'	,StarRating=4,
		--		--T.HotelLocation='Downtown', T.CarVendorName='Hertz Rental Car', T.CarType='Economy Car',CarPickupLocation='Airport'
	 --FROM	#tmpTrip T	

	;WITH  CTE AS 
	(
		SELECT 
			T.tripkey, COUNT(seg.airresponsekey)-1 as NoOfStops,
			SUBSTRING(CONVERT(VARCHAR,MIN(airSegmentDepartureDate),100),13,6) DepartTime,
			SUBSTRING(CONVERT(VARCHAR,MAX(airSegmentArrivalDate),100),13,6) ArrivalTime
		FROM #tmpTrip T WITH (NOLOCK) 
		INNER JOIN TripAirResponse resp WITH (NOLOCK) ON T.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
		INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
		INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber
		WHERE	
		ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   and T.tripStatusKey <> 17 --AND T.ComponentType=
		GROUP BY T.tripkey
	 )
	 UPDATE T SET 
		T.NoOfStops=CTE.NoOfStops,T.DepartTime=CTE.DepartTime,T.ArrivalTime=CTE.ArrivalTime
	 FROM #tmpTrip T INNER JOIN CTE ON T.tripKey=cte.tripKey
	 	 
	 ------ Start LocationImage Logic 
	 BEGIN
		UPDATE T
		SET	TripFrom = TR.tripFrom1 
			, TripTo = TR.TripTo1 
			, ComponentType = TR.tripComponentType 
		FROM #tmpTrip T
			INNER JOIN Trip.dbo.TripRequest TR ON T.tripRequestKey = TR.tripRequestKey
     
		IF OBJECT_ID('tempdb..#DestinationImage') is not null
		DROP TABLE #DestinationImage

		CREATE Table #DestinationImage(AptCode VARChar(10), DestinationId INT, ImageURL VARCHAR(MAX), OrderID INT)
			
		INSERT INTO #DestinationImage(AptCode, DestinationId, ImageURL, OrderId)
		SELECT D.AptCode, DI.DestinationID, REPLACE(DI.ImageURL, '/Content/','http://cdn2.carryon.com/'), DI.OrderId 
		FROM CMS.dbo.DestinationImages DI
			INNER JOIN CMS.dbo.[Destination] D ON DI.DestinationId = D.DestinationId
		WHERE DI.DestinationID IN 
			(
				SELECT [DestinationId]  FROM [CMS].[dbo].[Destination] 
				WHERE AptCode IN (SELECT DISTINCT TripTo FROM #tmpTrip ) 
			) ORDER BY DestinationID, OrderId
		
		
		
	    ;WITH CTE AS
        (
            select T.tripto,T.LocationImage, DI.ImageURL, NTILE(25) OVER(partition by T.tripTo Order By DI.ImageURL) AS [Rank]
            from #tmpTrip T
                INNER JOIN #DestinationImage DI ON T.tripTo = DI.AptCode 
        )
        UPDATE T  
        SET T.LocationImage=DI.ImageURL  
        FROM CTE T
        INNER JOIN #DestinationImage DI ON T.TripTo = DI.AptCode AND T.[Rank]=DI.OrderId
        
        UPDATE T
		SET	TripFrom = '', TripTo = ''
		FROM #tmpTrip T
		
		UPDATE T
		SET	TripFrom = TR.tripFrom1 , TripTo = TR.TripTo1 
		FROM #tmpTrip T
			INNER JOIN Trip.dbo.TripRequest TR ON T.tripRequestKey = TR.tripRequestKey
			INNER JOIN Trip..TripRequest_air TRA ON TRA.tripRequestKey=T.tripRequestKey
			INNER JOIN Trip..AirRequest AR ON AR.airRequestkey=TRA.airRequestkey
		/*
        UPDATE T
		SET T.LocationImage = DI.ImageURL
		FROM #tmpTrip T
			INNER JOIN #DestinationImage DI ON T.TripTo = DI.AptCode
		*/
		--END	 
		------ End LocationImage Logic
	
		SELECT trip.tripKey, trip.TripRequestKey, trip.tripName, trip.TravelerName, trip.userKey, trip.recordLocator, trip.startDate startDate
			, trip.endDate endDate, trip.tripStatusKey, tripStatusName = trip.tripStatusName, trip.agencyKey, trip.userFirstName
			, trip.userLastName, userLogin = trip.userFirstName + ' ' + trip.userLastName, groupKey, groupName, trip.CreatedDate 
			, trip.TotalCost, TRIP.NoOfStops, TRIP.TripRouteType, Trip.TripFrom, Trip.TripTo, Air.AirlineCode, trip.Airlinelogo
			, trip.DepartTime, trip.ArrivalTime, Hotel.ChainCode HotelCode, trip.HotelLogo, Hotel.hotelname HotelName
			, REPLACE(Hotel.Rating,'.','') StarRating, Hotel.cityname HotelLocation, Car.carVendorKey  CarCode, trip.CarLogo
			, car.carCompanyName CarVendorName, car.SippCodeClass CarType, car.carLocationCode CarPickupLocation, trip.LocationImage
			, UP.UserPicture UserImage, Trip.ComponentType
			, CASE WHEN trip.tripStatusKey = 7 
			  THEN '/travel/cart/payment?Id='+CONVERT(NVARCHAR, trip.tripKey) + '&travelReqId=' + CONVERT(NVARCHAR, trip.TripRequestKey)
			  ELSE '/travel/itinerary/tripconfirmation?Id='+CONVERT(NVARCHAR, trip.tripKey) + '&travelReqId='  +CONVERT(NVARCHAR, trip.TripRequestKey) 
			  END AS ViewTripRedirectURL
			, trip.IsArrangerBookForGuest
			, trip.MeetingListName EventName, trip.Traveler, trip.Invited, trip.[Status]
			, Arr.Origin, Arr.LastLeg, Arr.Dest, Arr.Flight, Arr.[Time], Arr.[Type], trip.PageName
		FROM #tmpTrip trip 
			LEFT OUTER JOIN #tbl_vw_TRipCarResponse Car ON Car.tripKey=trip.tripKey 
			LEFT OUTER JOIN #tbl_vw_TripHotelResponse_tripaudit Hotel ON Hotel.tripKey=trip.tripKey 
			INNER JOIN #trpsArrivalSegment Arr ON Arr.tripKey=trip.TripKey
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey 
			LEFT OUTER JOIN vault..userprofile UP ON u.userKey=up.userKey
			LEFT OUTER JOIN	#Temp_Airline_Details Air ON trip.tripKey=Air.TripKey --and trip.tripRequestKey=AirDtl.tripRequestKey
--WHERE trip.tripKey = 244587
		--ORDER BY Trip.tripKey DESC  

		UNION ALL
		
		SELECT trip.tripKey, trip.TripRequestKey, trip.tripName, trip.TravelerName, trip.userKey, trip.recordLocator, trip.startDate startDate
			, trip.endDate endDate, trip.tripStatusKey, tripStatusName = trip.tripStatusName, trip.agencyKey, trip.userFirstName
			, trip.userLastName, userLogin = trip.userFirstName + ' ' + trip.userLastName, groupKey, groupName, trip.CreatedDate 
			, trip.TotalCost, TRIP.NoOfStops, TRIP.TripRouteType, Trip.TripFrom, Trip.TripTo, Air.AirlineCode, trip.Airlinelogo
			, trip.DepartTime, trip.ArrivalTime, Hotel.ChainCode HotelCode, trip.HotelLogo, Hotel.hotelname HotelName
			, REPLACE(Hotel.Rating,'.','') StarRating, Hotel.cityname HotelLocation, Car.carVendorKey  CarCode, trip.CarLogo
			, car.carCompanyName CarVendorName, car.SippCodeClass CarType, car.carLocationCode CarPickupLocation, trip.LocationImage
			, UP.UserPicture UserImage, Trip.ComponentType
			, CASE WHEN trip.tripStatusKey = 7 
			  THEN '/travel/cart/payment?Id='+CONVERT(NVARCHAR, trip.tripKey) + '&travelReqId=' + CONVERT(NVARCHAR, trip.TripRequestKey)
			  ELSE '/travel/itinerary/tripconfirmation?Id='+CONVERT(NVARCHAR, trip.tripKey) + '&travelReqId='  +CONVERT(NVARCHAR, trip.TripRequestKey) 
			  END AS ViewTripRedirectURL
			, trip.IsArrangerBookForGuest
			, trip.MeetingListName EventName, trip.Traveler, trip.Invited, trip.[Status]
			, Dep.Origin, Dep.LastLeg, Dep.Dest, Dep.Flight, Dep.[Time], Dep.[Type], trip.PageName
		FROM #tmpTrip trip 
			LEFT OUTER JOIN #tbl_vw_TRipCarResponse Car ON Car.tripKey=trip.tripKey 
			LEFT OUTER JOIN #tbl_vw_TripHotelResponse_tripaudit Hotel ON Hotel.tripKey=trip.tripKey 
			INNER JOIN #trpsDepartureSegment Dep ON Dep.tripKey=trip.TripKey
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey 
			LEFT OUTER JOIN vault..userprofile UP ON u.userKey=up.userKey
			LEFT OUTER JOIN	#Temp_Airline_Details Air ON trip.tripKey=Air.TripKey --and trip.tripRequestKey=AirDtl.tripRequestKey
--WHERE trip.tripKey = 244587
		ORDER BY Trip.tripKey DESC   ---- This is steve's requirment to show always recent booking on top of the list           

		/*get the Air, car and hotel response detail for filtered trips   */
		SELECT	 vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode, vt.VendorName
			, airSegmentDepartureAirport  = ISNULL(TA_Dep.CityName,'') +', '+ ISNULL(TA_Dep.StateCode,'') + ' (' + TA_Dep.AirportCode + ')'
			, airSegmentArrivalAirport = ISNULL(TA_Arr.CityName,'') +', '+ ISNULL(TA_Arr.StateCode,'') + ' (' + TA_Arr.AirportCode + ')'
			, vt.flightNumber, vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator  ,'29A' as SeatNumber 
		FROM	#tbl_vw_TripDetails_tripaudit vt WITH(NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey 
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey 
			LEFT OUTER JOIN TRIP.DBO.AirportLookup TA_Dep ON TA_Dep.AirportCode = vt.airSegmentDepartureAirport
			LEFT OUTER JOIN TRIP.DBO.AirportLookup TA_Arr ON TA_Arr.AirportCode = vt.airSegmentArrivalAirport
		ORDER BY vt.tripKey, vt.RPH
	 
		SELECT	OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
		INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 
	 
	END
	
	DROP TABLE #tblUser
	DROP TABLE #tmpTrip
	DROP TABLE #tbl_vw_TRipCarResponse
	DROP TABLE #tbl_vw_TripHotelResponse_tripaudit
	DROP TABLE #tbl_vw_TripDetails_tripaudit
	DROP TABLE #Temp_Airline_Details
	DROP TABLE #trps
	DROP TABLE #trpsArrivalSegment
	DROP TABLE #trpsDepartureSegment

END
GO
