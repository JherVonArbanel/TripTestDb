SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================  
-- Author : Gopal
-- Create date : Jan/10/2012  
-- Description : Trip Information will be received from Web Service.  
-- Param : TripKey is optional.
-- =============================================   

-- =======================================================
--  EXECUTION STATEMENT

	--DECLARE @op INT
	--SET @op = 0

	--EXEC  usp_Action_Get_Page_Tripsdetail_Traveler 
	--	@PageName='bids',    
	--	@pageNo=1,
	--	@pageSize=25,
	--	@userkey=0, 
	--	@tripKey=NULL,    
	--	@fromDate='01-01-1900 00:00:00',    
	--	@toDate='31-12-9999 23:59:59',    
	--	@traveler=NULL,
	--	@status=2,
	--	@companyKey=0,
	--	@TripCompType='All', 
	--	@siteKey=1,
	--	@createdDate= '01-01-1900 00:00:00',
	--	@totalRecords = @op OUTPUT   
-- ========================================================	
Create PROCEDURE [dbo].[usp_Auction_Get_Page_Tripsdetail_Traveler] 
	@PageName		NVARCHAR(500),    
	@pageNo			INT,
	@pageSize		INT,
	@userkey		INT, 
	@tripKey		INT = NULL,    
	@fromDate		NVARCHAR(50),    
	@toDate			NVARCHAR(50),    
	@traveler		INT,
	@status			INT,
	@companyKey		INT = NULL ,
	@TripCompType	VARCHAR(10), 
	@siteKey		INT = NULL,
	@createdDate	DATETIME = '01-01-1900 00:00:00',
	@totalRecords	INT OUTPUT    
AS    
BEGIN       

	CREATE TABLE #tblUser    
	(    
		UserKey INT    
	)    
    CREATE TABLE #tmpTrip    
	(    
		RowID			INT,    
		tripKey			INT,    
		TripRequestKey	INT,    
		tripName		NVARCHAR(100),    
		userKey			INT,    
		recordLocator	NVARCHAR(100),    
		startDate		DATETIME,    
		endDate			DATETIME,    
		tripStatusKey	INT,    
		agencyKey		INT,    
		userFirstName	NVARCHAR(300),    
		userLastName	NVARCHAR(300),    
		userLogin		NVARCHAR(300)    
	)    
    
	IF(@traveler IS NOT NULL AND @traveler <> '' )     
	BEGIN    
		INSERT INTO #tblUser    
			SELECT @traveler    
	END    
	ELSE    
	BEGIN    
		INSERT INTO #tblUser    
		SELECT DISTINCT userKey FROM Vault.dbo.GetAllArrangees(@userkey, @companyKey) 
	END    
	
	IF @PageName <> N'bids'
	BEGIN
		SET @tripKey = CASE WHEN @tripKey IS NULL THEN 0 ELSE @tripKey END 
	END
	
	DECLARE @strQuery NVARCHAR(MAX), @paramDesc NVARCHAR(200)		

        ---- get the trip detail from trip table with filter parameter    
	IF @PageName = 'currenttrips' AND @tripKey = 0     
	BEGIN      
		INSERT INTO #tmpTrip 
		SELECT ROW_NUMBER() OVER (ORDER BY tripkey DESC),    
			Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate,
			Trip.endDate, Trip.tripStatusKey, Trip.agencyKey,     
			U.userFirstName, U.userLastName, U.userLogin     
		FROM trip WITH(NOLOCK)   
			INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey 
			INNER JOIN #tblUser TU ON U.userKey = TU.userKey  WHERE 1=1 
				AND tripKey = CASE WHEN @tripKey = 0 THEN tripKey ELSE @tripKey END 
				AND startDate between @fromDate and @toDate 
				AND dbo.IsTripStatusAsPerType(ISNULL(@status,Trip.tripStatusKey),@PageName) = 1 
				AND recordlocator IS NOT NULL AND recordlocator <> '' AND 
					endDate >= GETDATE() AND Trip.tripStatusKey = ISNULL(@status,Trip.tripStatusKey) 
			
		SELECT @totalRecords = COUNT(*) FROM #tmpTrip     ---get total records count in output parameter 
			
		SELECT tripKey, TripRequestKey, tripName, userKey, recordLocator, startDate, endDate,
			tripStatusKey, agencyKey, userFirstName, userLastName, userLogin 
		FROM #tmpTrip 
		WHERE RowID > (@pageNo-1)*@pageSize AND RowID <= @pageNo*@pageSize ORDER BY tripkey DESC 

        ---  get the Air, car and hotel response detail for filtered trips    
		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,
			vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,
			vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator 
		FROM vw_TripDetails vt WITH(NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey 
		ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC 
        
		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
			INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 

	END    
	ELSE IF @PageName = 'pasttrips' AND @tripKey = 0 
	BEGIN 
		---- Change the trip status from purchased to traveled of all trips which have purchased status and end date has been passed ----         
		---- LATER ON THIS IS STATEMENT SHOULD BE SCHEDULED TO EXECUTE EVERY DAY      
		---- START-----      
		UPDATE Trip SET tripStatusKey = 3 WHERE tripStatusKey = 2 AND endDate < GETDATE() 
		---- END  -----    
		INSERT INTO #tmpTrip 
		SELECT RowID = ROW_NUMBER() OVER (ORDER BY tripkey DESC), 
			Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator,
			Trip.startDate, Trip.endDate, Trip.tripStatusKey, Trip.agencyKey, 
			U.userFirstName, U.userLastName, U.userLogin 
		FROM trip WITH(NOLOCK) 
			INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey = U.UserKey 
			INNER JOIN #tblUser TU ON U.userKey = TU.userKey  WHERE 1=1 
				AND tripKey = CASE WHEN @tripKey = 0 THEN tripKey ELSE @tripKey END 
				AND startDate BETWEEN @fromDate AND @toDate 
				AND dbo.IsTripStatusAsPerType(ISNULL(@status, Trip.tripStatusKey), @PageName) = 1 
				AND recordlocator IS NOT NULL AND recordlocator <> '' AND 
					endDate < GETDATE() AND Trip.tripStatusKey = ISNULL(@status, Trip.tripStatusKey) 
			
		SELECT @totalRecords = COUNT(*) FROM #tmpTrip      ---get total records count in output parameter 

		SELECT tripKey, TripRequestKey, tripName, userKey, recordLocator, startDate, endDate,
			tripStatusKey, agencyKey, userFirstName, userLastName, userLogin 
		FROM #tmpTrip 
		WHERE RowID > (@pageNo-1)*@pageSize AND RowID <= @pageNo*@pageSize ORDER BY tripkey DESC 

        ---  get the Air, car and hotel response detail for filtered trips    
		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,
			vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,
			vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator 
		FROM vw_TripDetails vt WITH(NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey 
		ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC 
        
		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
			INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 
	END     
	ELSE IF @PageName = 'savedtrips' AND @tripKey = 0     
	BEGIN    
		INSERT INTO #tmpTrip 
			SELECT RowID = ROW_NUMBER() OVER (ORDER BY tripkey DESC), 
				Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate,
				Trip.endDate, Trip.tripStatusKey, Trip.agencyKey, 
				U.userFirstName, U.userLastName, U.userLogin 
			FROM trip WITH(NOLOCK) 
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey = U.UserKey 
				INNER JOIN #tblUser TU ON U.userKey = TU.userKey  
			WHERE 1=1 AND tripKey = CASE WHEN @tripKey = 0 THEN tripKey ELSE @tripKey END 
					AND startDate BETWEEN @fromDate AND @toDate 
					AND dbo.IsTripStatusAsPerType(ISNULL(@status, Trip.tripStatusKey), @PageName) = 1 
					AND recordlocator IS NULL OR recordlocator = '' 
			
		SELECT @totalRecords = COUNT(*) FROM #tmpTrip      ---get total records count in output parameter 

		SELECT tripKey, TripRequestKey, tripName, userKey, recordLocator, startDate, endDate,
			tripStatusKey, agencyKey, userFirstName, userLastName, userLogin 
		FROM #tmpTrip 
		WHERE RowID > (@pageNo-1) * @pageSize AND RowID <= @pageNo*@pageSize 
		ORDER BY tripkey DESC 

        ---  get the Air, car and hotel response detail for filtered trips    
		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,
			vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,
			vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator 
		FROM vw_TripDetails vt WITH(NOLOCK) 
			INNER JOIN #tmpTrip tmp ON  tmp.tripKey = vt.tripKey 
		ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC 
        
		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
			INNER JOIN #tmpTrip T  ON OPT. tripKey = T.tripKey AND isDeleted = 0 
	END  
	ELSE IF @PageName = 'bids' 
	BEGIN
		SET @tripKey = CASE WHEN @tripKey = 0 THEN NULL ELSE @tripKey END 
		
		INSERT INTO #tmpTrip 
		SELECT RowID = ROW_NUMBER() OVER (ORDER BY tripkey desc), 
			Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate,
			Trip.endDate, Trip.tripStatusKey, Trip.agencyKey, 
			U.userFirstName, U.userLastName, U.userLogin 
		FROM trip WITH(NOLOCK) 
			LEFT OUTER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey = U.UserKey 
				AND trip.siteKey = ISNULL(@siteKey, trip.siteKey)
				--AND trip.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), trip.createdDate)
				AND trip.CreatedDate >= ISNULL(@createdDate, trip.createdDate)
		WHERE tripKey = ISNULL(@tripKey, tripKey) AND recordlocator IS NOT NULL AND recordlocator <> '' 
			AND isBid = 1
			
			/*
		SELECT tripKey,TripRequestKey,tripName,userKey,recordLocator,startDate,endDate,
			tripStatusKey,agencyKey,userFirstName,userLastName,userLogin  
		FROM #tmpTrip      
		WHERE RowID > (@pageNo-1)*@pageSize AND RowID <= @pageNo*@pageSize 
		ORDER BY tripkey DESC    
		*/
		/*
		IF @TripCompType = 'air' 
		BEGIN
			SELECT ROW_NUMBER() OVER(ORDER BY tripAirsegmentkey) segmentOrder, 'air' AS TYPE, trip.tripKey, tripName, trip.tripRequestKey,
				u.userFirstName, 
				u.userLastName, u.userKey, trip.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, 
				resp.actualAirPrice AS basecost, resp.actualAirTax AS tax, seg.airSegmentMarketingAirlineCode AS vendorcode, 
				vendor.ShortName AS VendorName, seg.airSegmentDepartureAirport, seg.airSegmentArrivalAirport, 
				CONVERT (VARCHAR(20), seg.airSegmentFlightNumber) AS flightNumber, seg.airSegmentDepartureDate AS departuredate, 
				seg.airSegmentArrivalDate AS arrivaldate, NULL AS carType, CONVERT (VARCHAR(20), seg.airLegNumber) AS Ratingtype, 
				seg.airSegmentKey AS responseKey, leg.recordLocator AS vendorLocator, Trip.isBid 
			FROM Trip WITH(NOLOCK)  
				INNER JOIN TripAirResponse resp WITH(NOLOCK) ON trip.tripKey = ISNULL(@tripKey, trip.tripKey) AND trip.tripKey =resp.tripKey
						AND trip.siteKey = ISNULL(@siteKey, trip.siteKey) 
						--AND trip.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), trip.createdDate)
						AND trip.CreatedDate >= ISNULL(@createdDate, trip.createdDate)
				INNER JOIN TripAirLegs leg WITH(NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
				INNER JOIN TripAirSegments seg WITH(NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
				LEFT OUTER JOIN AirVendorLookup vendor WITH(NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor.AirlineCode 
				LEFT OUTER JOIN Vault.dbo.[User] u WITH(NOLOCK) ON trip.userKey = u.userKey 
			WHERE ISNULL (seg.ISDELETED,0) = 0 AND ISNULL(leg.ISDELETED,0) = 0 
		END
		ELSE IF @TripCompType = 'car'
		BEGIN
			SELECT ROW_NUMBER() OVER(ORDER BY carresponsekey), 'car' AS TYPE, tripkey, tripName, t.tripRequestKey, u.userFirstName, 
				u.userLastName, u.userKey, recordLocator, endDate, startDate, tripStatusKey, 
				actualCarPrice, actualCarTax,carVendorKey, 
				--CarCompanyName, carLocationCode, carLocationCode, 
				vehicleName CarCompanyName, carLocationCode, carLocationCode, 
				NULL, PickUpdate, 
				dropOutDate, SippCodeClass, NULL AS Ratingtype, 
				t.carResponseKey, t.recordLocator, t.isBid 
			FROM vw_TRipCarResponse t WITH(NOLOCK) 
				LEFT OUTER JOIN Vault.dbo.[User] u WITH(NOLOCK) ON t.userKey = u.userKey AND t.tripKey = ISNULL(@tripKey, t.tripKey) 
					AND t.siteKey = ISNULL(@siteKey, t.siteKey) 
					--AND t.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), t.createdDate) 
					AND t.CreatedDate >= ISNULL(@createdDate, t.createdDate)
		END
		ELSE IF @TripCompType = 'hotel'
		BEGIN
			SELECT ROW_NUMBER() OVER(ORDER BY hotelresponsekey), 'hotel' AS TYPE, tripkey, tripName, t.tripRequestKey, u.userFirstName, 
				u.userLastName, u.userKey, recordLocator, endDate, startDate, tripStatusKey, 
				actualHotelPrice, actualHotelTax, ChainCode, 
				hotelname, cityname + ',' + StateCode, cityname + ',' + StateCode, 
				NULL, checkindate, 
				checkoutdate, NULL, Ratingtype, 
				t.hotelResponseKey, t.recordLocator, t.isBid 
			FROM vw_TripHotelResponse t WITH(NOLOCK) 
				LEFT OUTER JOIN Vault.dbo.[User] u WITH(NOLOCK) ON t.userKey = u.userKey AND t.tripKey = ISNULL(@tripKey, t.tripKey)
					AND t.siteKey = ISNULL(@siteKey, t.siteKey) 
					--AND t.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), t.createdDate)
					AND t.CreatedDate >= ISNULL(@createdDate, t.createdDate)
		END
		ELSE
		BEGIN
			SELECT vt.TYPE, vt.tripKey, vt.tripRequestKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,
				vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,
				vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator, vt.isBid,
				vt.VehicleCompanyName,vt.NoofDays
				,vt.CityName as HotelCityName
				,vt.StateCode as HotelStateCode
				,vt.CountryCode as HotelCountryCode
				,vt.HotelRating
			FROM vw_TripDetails vt WITH(NOLOCK)  
				 inner join #tmpTrip tmp on  tmp.tripKey = vt.tripKey 
			WHERE vt.isBid = 1 AND vt.tripKey = ISNULL(@tripKey, vt.tripKey) AND vt.siteKey = ISNULL(@siteKey, vt.siteKey)
				--AND vt.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), vt.createdDate)
				AND vt.CreatedDate >= ISNULL(@createdDate, vt.createdDate)
			ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC 
		END
		*/
		
		if @TripCompType = 'all' 
			SET @TripCompType = NULL
			
			--SELECT vt.TYPE, vt.tripKey, vt.tripRequestKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,
			--		vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,
			--		vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator, vt.isBid,
			--		vt.VehicleCompanyName,vt.NoofDays
			--		,vt.CityName as HotelCityName
			--		,vt.StateCode as HotelStateCode
			--		,vt.CountryCode as HotelCountryCode
			--		,vt.HotelRating
			--	FROM vw_TripDetails vt WITH(NOLOCK)  
			--		 inner join #tmpTrip tmp on  tmp.tripKey = vt.tripKey 
			--	WHERE vt.isBid = 1 AND vt.tripKey = ISNULL(@tripKey, vt.tripKey) AND vt.siteKey = ISNULL(@siteKey, vt.siteKey)
			--		--AND vt.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), vt.createdDate)
			--		AND vt.CreatedDate >= ISNULL(@createdDate, vt.createdDate)
			--		and vt.TYPE = ISNULL(@TripCompType, vt.TYPE)
			--	ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC 

			SELECT --vt.TYPE, 
					vt.tripKey, --vt.tripRequestKey, vt.recordLocator, 
					vt.basecost, vt.tax, --vt.vendorcode,
					vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, --vt.flightNumber,
					vt.departuredate, vt.arrivaldate, vt.carType, --vt.Ratingtype, vt.responseKey, vt.vendorLocator, vt.isBid,
					--vt.VehicleCompanyName,vt.NoofDays
					vt.CityName as HotelCityName
					,vt.StateCode as HotelStateCode
					,vt.CountryCode as HotelCountryCode
					,vt.HotelRating
				FROM vw_TripDetails vt WITH(NOLOCK)  
					 inner join #tmpTrip tmp on  tmp.tripKey = vt.tripKey 
				WHERE vt.isBid = 1 AND vt.tripKey = ISNULL(@tripKey, vt.tripKey) AND vt.siteKey = ISNULL(@siteKey, vt.siteKey)
					--AND vt.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), vt.createdDate)
					AND vt.CreatedDate >= ISNULL(@createdDate, vt.createdDate)
					and vt.TYPE = ISNULL(@TripCompType, vt.TYPE)
				ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC 

		SELECT @totalRecords=COUNT(*) FROM #tmpTrip
		/*
		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK)     
		INNER JOIN Trip T ON OPT.tripKey = T.tripKey AND t.tripKey = ISNULL(@tripKey, t.tripKey) AND isDeleted = 0 AND T.isBid = 1
			AND t.siteKey = ISNULL(@siteKey, t.siteKey) 
			--AND t.CreatedDate >= ISNULL(CONVERT(DATETIME, @createdDate, 103), t.createdDate)
			AND t.CreatedDate >= ISNULL(@createdDate, t.createdDate)
		INNER JOIN #tmpTrip tmp ON  tmp.tripKey = t.tripKey 
		*/
	END  
	ELSE  ------CALL FROM ANY OTHER PAGE    
	BEGIN      
		INSERT INTO #tmpTrip 
		SELECT ROW_NUMBER() OVER (ORDER BY tripkey DESC),    
			Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate,
			Trip.endDate, Trip.tripStatusKey, Trip.agencyKey, 
			U.userFirstName, U.userLastName, U.userLogin 
		FROM trip WITH(NOLOCK)  
			INNER JOIN Vault.dbo.[User] U  WITH(NOLOCK) ON trip.userKey = U.UserKey 
			INNER JOIN #tblUser TU ON U.userKey = TU.userKey  
		WHERE 1=1 AND tripKey = CASE WHEN @tripKey = 0 THEN tripKey ELSE @tripKey END 
				AND startDate BETWEEN @fromDate AND @toDate 
				AND Trip.tripStatusKey = ISNULL(@status, Trip.tripStatusKey) 
		
		SELECT @totalRecords=COUNT(*) FROM #tmpTrip     ---get total records count in output parameter 

		SELECT tripKey, TripRequestKey, tripName, userKey, recordLocator, startDate, endDate,
			tripStatusKey, agencyKey, userFirstName, userLastName, userLogin 
		FROM #tmpTrip 
		WHERE RowID > (@pageNo-1)*@pageSize AND RowID <= @pageNo*@pageSize ORDER BY tripkey DESC 

		---  get the Air, car and hotel response detail for filtered trips    
		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,
			vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,
			vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator 
		FROM vw_TripDetails vt WITH(NOLOCK) 
			INNER JOIN #tmpTrip tmp ON  tmp.tripKey = vt.tripKey 
		ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC 
        
		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
			INNER JOIN #tmpTrip T  ON OPT.tripKey = T.tripKey AND isDeleted = 0 

	END       
         
    DROP TABLE #tmpTrip  
    Drop Table #tblUser  
END    
GO
