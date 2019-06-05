SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetTrips_Irop] 
      @SiteKey INT
	, @CompanyKey INT 
	, @GroupName VARCHAR(100)
	, @PageName NVARCHAR(500) -- 'mytrips','activetrips','pasttrips'
	, @PNR NVARCHAR(12)
	, @UDIDandValue NVARCHAR(MAX) --- 'UD10:MYNTHW,UD5:154,UD3:FLG001
	, @StartDate AS DATE
	, @EndDate AS DATE 
AS 
BEGIN
DECLARE 
	@FromDate as DateTime
   ,@ToDate as DateTime
       
    IF @PNR = '' SET @PNR = null
	DECLARE @GroupKey INT
    SELECT @GroupKey = Groupkey FROM VAULT..[Group] WHERE scopeTypeValue = @CompanyKey AND LTRIM(RTRIM(groupName)) = LTRIM(RTRIM(@GroupName))
	
	DECLARE @tblSelectedUDIDs table (ID int, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))
	DECLARE @tblSelectedUDIDsTrips table (ID int, TRIPID BIGINT, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))
	DECLARE @tblSelectedUDIDsTripsForUDID table (ID int, TRIPID BIGINT, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))

	CREATE TABLE #tmpTrip
	(                          
--		RowID   INT,                          
		tripKey   INT,                          
		TripRequestKey INT,                          
		tripName  NVARCHAR(100),                          
		userKey   INT,                          
		recordLocator NVARCHAR(100),                          
		startDate  DATETIME,                          
		endDate   DATETIME,                          
		tripStatusKey INT,                          
		tripStatusName NVARCHAR(100),		
		agencyKey  INT,                          
		userFirstName NVARCHAR(300),                          
		userLastName NVARCHAR(300),                          
		userLogin  NVARCHAR(300),    
		tripPurchasedKey uniqueidentifier,
		groupKey INT, 
		groupName NVARCHAR(100),
		CreatedDate DATETIME, 
		TravelerName VARCHAR(200)
	   ,TotalCost DECIMAL(18,2)		
	)              

	CREATE TABLE #tmpTripDetails
	(                          
		segmentOrder   INT, 
		[TYPE]   NVARCHAR(30), 
		tripKey   INT, 
		tripName   NVARCHAR(50), 
		userFirstName   NVARCHAR(50), 
		userLastName   NVARCHAR(50), 
		userKey   INT, 
		recordLocator   NVARCHAR(50), 
		endDate   DATETIME, 
		startDate   DATETime, 
		tripStatusKey   INT, 
		basecost   FLOAT, 
		tax   FLOAT, 
		vendorcode   NVARCHAR(10), 
		VendorName   NVARCHAR(64), 
		airSegmentDepartureAirport   NVARCHAR(50), 
		airSegmentArrivalAirport   NVARCHAR(50), 
		flightNumber   NVARCHAR(20), 
		departuredate   DATETIME, 
		arrivaldate   DATETIME, 
		carType   NVARCHAR(16), 
		Ratingtype   NVARCHAR(16), 
		responseKey   UNIQUEIDENTIFIER, 
		vendorLocator   NVARCHAR(50), 
		siteKey   INT, 
		createdDate   DATETIME, 
		tripRequestKey   INT, 
		VehicleCompanyName   NVARCHAR(100), 
		NoofDays   INT, 
		CityName   NVARCHAR(50), 
		StateCode   NVARCHAR(50), 
		CountryCode   NVARCHAR(50), 
		HotelRating   NVARCHAR(50), 
		DiscountFare   FLOAT, 
		RPH	INT
	) 

	DECLARE @SixHrsBeforeTime DATETIME = DATEADD(HOUR, -6, GETDATE())
	
	IF @PageName = 'mytrips'                            
	BEGIN 
		INSERT INTO #tmpTrip 
		SELECT 	Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
				,Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
				,CASE	WHEN Trip.StartDate  < @SixHrsBeforeTime --@GMT_Today_4_AM 
								AND Trip.tripStatusKey IN (2,3) Then 'Past'
						WHEN Trip.StartDate >= @SixHrsBeforeTime --@GMT_Today_4_AM 
								AND Trip.tripStatusKey IN (2,3) 
						THEN 'Purchased'
						ELSE S.tripStatusName 
				 END
				,Trip.agencyKey, U.userFirstName, U.userLastName
				,LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
				,LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
				,0 
		FROM	trip WITH(NOLOCK)               
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
				LEFT OUTER JOIN vault.dbo.[Group] GRP ON Trip.GroupKey = GRP.groupKey 
				INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
		WHERE	
				Trip.recordlocator IS NOT NULL 
				AND Trip.recordlocator <> '' 
				AND	Trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE Trip.RecordLocator END 
				AND	Trip.siteKey = @siteKey 
				AND Trip.GroupKey = @GroupKey
				AND Trip.startDate BETWEEN @StartDate AND @EndDate
	END	
	
	IF @PageName = 'activetrips'
	BEGIN
	    INSERT INTO #tmpTrip 
		SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
				Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
				, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
				, CASE WHEN Trip.tripStatusKey IN ( 2,3) THEN 'Purchased' else S.tripStatusName END
				, Trip.agencyKey, U.userFirstName, U.userLastName
				, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
				, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
				, 0 
		FROM	trip WITH(NOLOCK)               
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
				LEFT OUTER JOIN vault.dbo.[Group] GRP ON Trip.GroupKey = GRP.groupKey
				INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
		WHERE	trip.recordlocator IS NOT NULL 
				AND trip.recordlocator <> '' 
				AND trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE trip.RecordLocator END 
				AND	trip.siteKey = @siteKey 
				AND Trip.GroupKey = @GroupKey
				AND Trip.startDate BETWEEN @StartDate AND @EndDate
	END
	
	IF @PageName = 'pasttrips'
	BEGIN
		INSERT INTO #tmpTrip 
		SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
				Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
				, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
				, CASE WHEN Trip.tripStatusKey IN ( 2,3) THEN 'Past' else S.tripStatusName END
				, Trip.agencyKey, U.userFirstName, U.userLastName
				,  LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
				, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
				, 0 
		FROM	trip WITH(NOLOCK)               
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10    AND Trip.tripStatusKey <> 17 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
				LEFT OUTER JOIN vault.dbo.[Group] GRP ON Trip.GroupKey = GRP.groupKey
				INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
		WHERE	Trip.StartDate < @SixHrsBeforeTime --@GMT_Today_4_AM
				AND Trip.startDate BETWEEN @FromDate AND @ToDate  --  @StartDate AND @EndDate
				AND Trip.recordlocator IS NOT NULL 
				AND Trip.recordlocator <> '' 
				AND Trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE Trip.RecordLocator END 
				AND Trip.siteKey = @siteKey 
				AND Trip.GroupKey = @GroupKey
	END
		                    
	INSERT	
	INTO		#tmpTripDetails
	SELECT		ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder
				,'air' AS TYPE
				,trip.tripKey
				,trip.tripName
				,u.userFirstName
				,u.userLastName
				,u.userKey
				,trip.recordLocator
				,trip.endDate
				,trip.startDate
				,trip.tripStatusKey
				,resp.actualAirPrice AS basecost
				,resp.actualAirTax AS tax
				,seg.airSegmentMarketingAirlineCode AS vendorcode
				,vendor.ShortName AS VendorName
				,seg.airSegmentDepartureAirport
				,seg.airSegmentArrivalAirport
				,CONVERT(varchar(20), seg.airSegmentFlightNumber) AS flightNumber
				,seg.airSegmentDepartureDate AS departuredate
				,seg.airSegmentArrivalDate AS arrivaldate
				,NULL AS carType
				,CONVERT(varchar(20), seg.airLegNumber) AS Ratingtype
				,seg.airSegmentKey AS responseKey
				,seg.recordLocator AS vendorLocator
				,Trip.siteKey
				,trip.createdDate
				,trip.tripRequestKey
				,'' As VehicleCompanyName
				,0 as NoofDays
				,'' as CityName 
				,'' as StateCode
				,'' as CountryCode
				,'' as HotelRating
				,ISNULL(resp.discountedBaseFare,0) as DiscountFare
				,ISNULL(seg.RPH, 0) 
	FROM		Trip WITH (NOLOCK) 
				INNER JOIN TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
				INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
				INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
				LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 
				LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE		ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   and Trip.dbo.Trip.tripStatusKey <> 17 

	UPDATE		t 
	SET			TotalCost = (vw.basecost + vw.tax)
	FROM		#tmpTrip t
	INNER JOIN 
	(
				SELECT tripKey, basecost, tax 
				FROM #tmpTripDetails
				GROUP BY tripKey, basecost, tax 
	)vw ON t.tripKey = vw.tripKey

	IF LEN(ISNULL(@UDIDandValue,'')) > 0 
	BEGIN
		SET @UDIDandValue = REPLACE(@UDIDandValue,'UD','')

		INSERT INTO @tblSelectedUDIDs (ID, DATA, UDID, UDIDValue)
		SELECT	ID
				,DATA 
				,UD  = SUBSTRING(DATA, 1, CHARINDEX(':', DATA)-1)		
				,UDValue  = SUBSTRING(DATA, CHARINDEX(':', DATA)+1, LEN(DATA))		
		FROM	VAULT.dbo.UFn_StringSplit(@UDIDandValue,',')

		-- Search in TripPassengerUDIDInfo wihtout UDID Conditions, Because In futre there will be performance issue.
		INSERT INTO @tblSelectedUDIDsTrips (TRIPID, UDID, UDIDValue)
		SELECT		Tripkey
					, CompanyUDIDNumber
					, PassengerUDIDValue
		FROM		TripPassengerUDIDInfo 
		WHERE		TripKey IN (SELECT tripKey FROM #tmpTrip)
					 --AND CompanyUDIDNumber + ';' + PassengerUDIDValue IN (SELECT DATA FROM @tblSelectedUDIDs)
		
		UPDATE 	@tblSelectedUDIDsTrips SET DATA = UDID +':' + UDIDValue  

		---- WITH UDID conditions		
		INSERT INTO @tblSelectedUDIDsTripsForUDID (TRIPID, DATA, UDID, UDIDValue)
		SELECT		TRIPID, DATA, UDID, UDIDValue
		FROM		@tblSelectedUDIDsTrips
		WHERE		DATA IN (SELECT DATA FROM @tblSelectedUDIDs)
		
		SELECT	trip.tripKey
				,trip.TripRequestKey
				,tripName
				,trip.TravelerName
				,trip.userKey
				,recordLocator
				,trip.startDate startDate
				,trip.endDate endDate
				,tripStatusKey
				,trip.tripStatusName
				,agencyKey
				,userFirstName
				,userLastName
				,userLogin = LEFT(userFirstName,1) + ' ' + userLastName
				,groupKey
				,groupName
				,CreatedDate 
				,trip.TotalCost      
		FROM	#tmpTrip trip 
				INNER JOIN Trip.dbo.TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		WHERE	trip.tripKey in (SELECT TripID from @tblSelectedUDIDsTripsForUDID)
		ORDER BY Trip.tripKey DESC
		
		---  get the Air, car and hotel response detail for filtered trips            
		SELECT	 TD.TYPE
				,TD.tripKey
				,TD.recordLocator
				,TD.basecost
				,TD.tax
				,TD.vendorcode
				,TD.VendorName
				,TD.airSegmentDepartureAirport
				,TD.airSegmentArrivalAirport
				,TD.flightNumber
				,TD.departuredate
				,TD.arrivaldate
				,TD.carType
				,TD.Ratingtype
				,TD.responseKey
				,TD.vendorLocator 
		FROM	#tmpTripDetails TD WITH(NOLOCK) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = TD.tripKey 
				INNER JOIN Trip.dbo.TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey 
		WHERE	tmp.tripKey in (SELECT TripID from @tblSelectedUDIDsTripsForUDID)
		ORDER BY TD.tripKey, TD.RPH

		SELECT	OPT.* 
		FROM	TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
				INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 
		WHERE	T.tripKey in (SELECT TripID from @tblSelectedUDIDsTripsForUDID)
	END
	ELSE
	BEGIN
		SELECT	trip.tripKey
				,trip.TripRequestKey
				,tripName
				,trip.TravelerName
				,trip.userKey
				,recordLocator
				,trip.startDate startDate
				,trip.endDate endDate
				,tripStatusKey
				,tripStatusName = trip.tripStatusName
				,agencyKey
				,userFirstName
				,userLastName
				,userLogin = LEFT(userFirstName,1) + ' ' + userLastName
				,groupKey
				,groupName
				,CreatedDate 
				,trip.TotalCost      
		FROM	#tmpTrip trip 
				INNER JOIN Trip.dbo.TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		ORDER BY Trip.tripKey DESC   ---- This is steve's requirment to show always recent booking on top of the list           
	
		/*get the Air detail for filtered trips   */
		SELECT	TD.TYPE
				,TD.tripKey
				,TD.recordLocator
				,TD.basecost
				,TD.tax
				,TD.vendorcode
				,TD.VendorName
				,airSegmentDepartureAirport  = ISNULL(TA_Dep.CityName,'') +', '+ ISNULL(TA_Dep.StateCode,'') + ' (' + TA_Dep.AirportCode + ')'
				,airSegmentArrivalAirport = ISNULL(TA_Arr.CityName,'') +', '+ ISNULL(TA_Arr.StateCode,'') + ' (' + TA_Arr.AirportCode + ')'
				,TD.flightNumber
				,TD.departuredate
				,TD.arrivaldate
				,TD.carType
				,TD.Ratingtype
				,TD.responseKey
				,TD.vendorLocator 
		FROM	#tmpTripDetails TD WITH(NOLOCK) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = TD.tripKey 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey 
				INNER JOIN TRIP.DBO.AirportLookup TA_Dep ON TA_Dep.AirportCode = TD.airSegmentDepartureAirport
				INNER JOIN TRIP.DBO.AirportLookup TA_Arr ON TA_Arr.AirportCode = TD.airSegmentArrivalAirport
				ORDER BY TD.tripKey, TD.RPH

		SELECT	OPT.* 
		FROM	TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
				INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 
	END

	DROP TABLE #tmpTrip
	DROP TABLE #tmpTripDetails
END
GO
