SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
        
-- =============================================                        
-- Author : Gopal                      
-- Create date : Jan/10/2012                        
-- Description : Trip Information will be received from Web Service.                        
-- Param : TripKey is optional.                      
/*
exec usp_GetTripsITS_Irop_ng_top5 @SiteGUID=N'9701C5A8-643D-42BC-92DD-984C6D9CB4A2'
	,@CompanyGUID=N'44C0E255-3ED9-43BD-9CC6-78693498F537',@UserGUID=N'072E6912-4473-4FCF-8EBD-13F7785103C6'
	,@PageName=N'activetrips',@PNR=NULL,@UDIDandValue=NULL,@StartDate=NULL,@EndDate=NULL
GO
*/
-- =============================================                         

--EXEC [dbo].[usp_GetTripsITS_Irop_ng]   @SiteGUID=N'1F33CD4E-BCCC-466C-A618-2C5A36AB5B93',@CompanyGUID=N'4CB134CD-6C48-40AF-BBD2-2EA1F0802B5B',@UserGUID=N'5568CD20-A7F3-4535-BF1B-AB7E66863F72',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=NULL

CREATE PROCEDURE [dbo].[usp_GetTripsITS_Irop_ng_top5] 
--DECLARE
	  @SiteGUID nvarchar(500) 
	, @CompanyGUID nvarchar(50) 
	, @UserGUID nvarchar(500)
	, @PageName NVARCHAR(500) -- 'mytrips','activetrips','pasttrips'
	, @PNR NVARCHAR(12)
	, @UDIDandValue NVARCHAR(MAX) --- 'UD10:MYNTHW,UD5:154,UD3:FLG001
	, @StartDate AS DATE ---- Commented as this is not on prod
	, @EndDate AS DATE ---- Commented as this is not on prod

 AS
-- SELECT  @SiteGUID=N'5FEED8B9-FC73-473B-B2C6-221BDD13369C',@CompanyGUID=N'7C14DA42-2412-40D9-ACA8-1E5C2B9D8467',
--@UserGUID=N'0FB78E02-D691-47AC-84BE-E5F9271E694A',@PageName=N'activetrips',@PNR=NULL,@UDIDandValue=NULL,@StartDate=NULL,@EndDate=NULL
  
BEGIN
DECLARE @FromDate as DateTime, @ToDate as DateTime

	SET @fromDate = convert(varchar, convert(datetime, CASE WHEN @StartDate IS NULL THEN GETDATE() ELSE @StartDate END), 111) + ' 00:00:00'  
	SET @ToDate = convert(varchar, convert(datetime, CASE WHEN @EndDate IS NULL THEN DATEADD(YEAR, 100, GETDATE()) ELSE @EndDate END), 111) + ' 23:59:59'

	--SET @fromDate = convert(varchar, convert(datetime, @StartDate), 111) + ' 00:00:00'  
	--SET @ToDate = convert(varchar, convert(datetime, @EndDate), 111) + ' 23:59:59'
--select @fromDate , @ToDate
	DECLARE 	@RoleTripId INT

--SELECT @SiteGUID=N'5FEED8B9-FC73-473B-B2C6-221BDD13369C',@CompanyGUID=N'2F2F1E84-3C10-4058-BC5C-FB9E417557F7'
--	,@UserGUID=N'65DE26A7-ADFA-4650-9DC9-BC8C14EDEF11'
--	,@PageName=N'pasttrips',@PNR=N'',@UDIDandValue=NULL

	IF @PNR = '' SET @PNR = null

	DECLARE @tblSelectedUDIDs table (ID int, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))
	DECLARE @tblSelectedUDIDsTrips table (ID int, TRIPID BIGINT, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))
	DECLARE @tblSelectedUDIDsTripsForUDID table (ID int, TRIPID BIGINT, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))

	DECLARE @SiteKey INT, @CompanyKey INT, @UserKey INT, @AgencyKey INT
	DECLARE	@dbResponse TABLE (STATUSCODE nvarchar(50), STATUSMESSAGE NVARCHAR(500))
	
	SELECT	 @SiteKey=SiteKey, @AgencyKey = data.value('(/Site/Agency/key/node())[1]', 'INT')
	FROM	 Vault.DBO.SiteConfiguration WITH(NOLOCK) 
	--WHERE siteKey = 64 AND @SiteGUID = '2D620B87-E702-4AE9-A91F-88F864FDC2D1'
	
	WHERE	 data.value('(/Site/siteGUID/node())[1]', 'NVARCHAR(500)') = @SiteGUID

	SELECT @CompanyKey = CompanyKey FROM Vault.DBO.Company WITH(NOLOCK) WHERE CompanyGUID = @CompanyGUID 

	SELECT @Userkey = UserKey FROM Vault.DBO.[User] WITH(NOLOCK) WHERE UserGUID = @UserGUID
	
	SELECT @RoleTripId = userRoles FROM Vault.DBO.[UserProfile] WITH(NOLOCK) WHERE userKey = @UserKey

--SELECT @SiteKey SiteKey, @AgencyKey AgencyKey, @CompanyKey CompanyKey, @UserKey UserKey


	CREATE TABLE #tblUser                          
	(                          
		UserKey INT 
	)                          

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

	CREATE TABLE #tbl_vw_TRipCarResponse
	(                          
		tripKey   INT, 
		tripName   NVARCHAR(50), 
		userKey   INT, 
		recordLocator   NVARCHAR(50), 
		endDate   DATETIME, 
		startDate   DATETIME, 
		tripStatusKey   INT, 
		actualCarPrice   FLOAT, 
		actualCarTax   FLOAT, 
		carVendorKey   NVARCHAR(50), 
		CarCompanyName   NVARCHAR(64), 
		carLocationCode   NVARCHAR(50), 
		PickUpdate   DATETIME, 
		dropOutDate   DATETIME, 
		SippCodeClass   NVARCHAR(32), 
		carResponseKey   UNIQUEIDENTIFIER, 
		siteKey   INT, 
		createdDate   DATETIME, 
		tripRequestKey   INT, 
		VehicleName   NVARCHAR(64), 
		NoOfDays   INT, 
		CityName NVARCHAR(50),
		StateCode NVARCHAR(50),
		CountryCode NVARCHAR(50),
		HotelRating NVARCHAR(50),
		DiscountFare INT,
		RPH INT
	)
	create clustered index ix_tripKey on #tbl_vw_TRipCarResponse(tripKey)  

	CREATE TABLE #tbl_vw_TripHotelResponse_tripaudit
	(
		tripKey INT, 
		tripName NVARCHAR(50), 
		userKey INT, 
		recordLocator NVARCHAR(50), 
		endDate DATETIME, 
		startDate DATETIME, 
		tripStatusKey INT, 
		actualHotelPrice FLOAT, 
		actualHotelTax FLOAT, 
		ChainCode NVARCHAR(50), 
		HotelName NVARCHAR(100), 
		CityName NVARCHAR(50), 
		StateCode NVARCHAR(50), 
		checkInDate DATETIME, 
		checkOutDate DATETIME, 
		RatingType NVARCHAR(16), 
		hotelResponseKey UNIQUEIDENTIFIER, 
		siteKey INT, 
		CreatedDate DATETIME, 
		tripRequestKey INT, 
		VehicleCompanyName NVARCHAR(100), 
		NoofDays INT, 
		CountryCode NVARCHAR(50), 
		Rating NVARCHAR(50), 
		DiscountFare INT,
		RPH INT
	)
	create clustered index IX_tripKey on #tbl_vw_TripHotelResponse_tripaudit(tripKey)  

	CREATE TABLE #tbl_vw_TripDetails_tripaudit
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
	create clustered index IX_tripKey on #tbl_vw_TripDetails_tripaudit (tripKey)  

	INSERT INTO #tblUser                          
	SELECT DISTINCT userKey FROM Vault.dbo.GetAllArrangees(@userkey, @companyKey)                       
	
	--DECLARE  @GMTNOW DATETIME = DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), GETDATE())
	--	,@GMT_Today_4_AM DATETIME 
	--SET @GMT_Today_4_AM = CONVERT(DATETIME, (CONVERT(VARCHAR,@GMTNOW,103)  + ' ' + CONVERT(VARCHAR,'04:00:00.000')),103)

	/*We will consider this lateron*/	
	DECLARE @SixHrsBeforeTime DATETIME = DATEADD(HOUR, -6, GETDATE())
	
	IF @PageName = 'mytrips'                            
	BEGIN 
Print 'Inside MyTrips'
	
		IF @RoleTripId = 1  -- Travller 
		BEGIN
Print 'Inside @RoleTripId'
		
			INSERT INTO #tmpTrip 
			SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
					TOP 5 Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
					, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
					,CASE	WHEN Trip.StartDate < @SixHrsBeforeTime --@GMT_Today_4_AM 
										AND Trip.tripStatusKey IN (2,3) Then 'Past'
							WHEN Trip.StartDate >= @SixHrsBeforeTime --@GMT_Today_4_AM 
										AND Trip.tripStatusKey IN (2,3) THEN 'Purchased'
							ELSE S.tripStatusName 
					END
					, Trip.agencyKey, U.userFirstName, U.userLastName
					, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
					, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
					, 0 
			FROM	Trip.dbo.trip WITH(NOLOCK)               
					INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17
					INNER JOIN Trip.dbo.TripStatusLookup S WITH (NOLOCK) ON trip.tripStatusKey = S.tripStatusKey  
					LEFT OUTER JOIN vault.dbo.[Group] GRP WITH(NOLOCK)  ON trip.GroupKey = GRP.groupKey
					INNER JOIN Trip.dbo.TripPassengerInfo TPI WITH(NOLOCK)  ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
			WHERE	
					--trip.recordlocator IS NOT NULL 
					--AND trip.recordlocator <> '' 
					--AND trip.recordLocator = CASE WHEN @PNR IS NOT NULL THEN @PNR ELSE trip.RecordLocator END 
					((Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' ) OR (trip.tripStatusKey = 21)) 
					AND	ISNULL(Trip.recordLocator,'') = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE ISNULL(Trip.RecordLocator,'') END 
					AND trip.siteKey = @siteKey 
					AND trip.userKey = @userkey
			ORDER BY trip.startDate DESC
		END
		ELSE
		BEGIN
Print 'Inside @RoleTripId --->'
			INSERT INTO #tmpTrip 
			SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
					TOP 5 Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
					, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
					,CASE	WHEN Trip.StartDate  < @SixHrsBeforeTime --@GMT_Today_4_AM 
									AND Trip.tripStatusKey IN (2,3) Then 'Past'
							WHEN Trip.StartDate >= @SixHrsBeforeTime --@GMT_Today_4_AM 
									AND Trip.tripStatusKey IN (2,3) 
							THEN 'Purchased'
							ELSE S.tripStatusName 
					END
					, Trip.agencyKey, U.userFirstName, U.userLastName
					, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
					, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
					, 0 
			FROM	trip WITH(NOLOCK)               
					INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17
					INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
					LEFT OUTER JOIN vault.dbo.[Group] GRP WITH(NOLOCK) ON Trip.GroupKey = GRP.groupKey
					INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
			WHERE	
					--Trip.recordlocator IS NOT NULL 
					--AND Trip.recordlocator <> '' 
					--AND	Trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE Trip.RecordLocator END 
					((Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' ) OR (trip.tripStatusKey = 21)) 
					AND	ISNULL(Trip.recordLocator,'') = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE ISNULL(Trip.RecordLocator,'') END 
					AND	Trip.siteKey = @siteKey 
					AND trip.userKey = @userkey 
			ORDER BY Trip.startDate DESC
		END
	END	
	
	IF @PageName = 'activetrips'
	BEGIN

		INSERT INTO #tmpTrip 
		SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
				TOP 5 Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
				, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
				, CASE WHEN Trip.tripStatusKey IN ( 2,3) THEN 'Purchased' else S.tripStatusName END
				, Trip.agencyKey, U.userFirstName, U.userLastName
				, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
				, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
				, 0 
		FROM	trip WITH(NOLOCK)               
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
				LEFT OUTER JOIN vault.dbo.[Group] GRP WITH(NOLOCK) ON Trip.GroupKey = GRP.groupKey
				INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
		
		WHERE	trip.StartDate >= @SixHrsBeforeTime --@GMT_Today_4_AM
				--AND trip.recordlocator IS NOT NULL AND trip.recordlocator <> '' 
				--AND trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE trip.RecordLocator END 
				AND ((Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' ) OR (trip.tripStatusKey = 21)) 
				AND	ISNULL(Trip.recordLocator,'') = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE ISNULL(Trip.RecordLocator,'') END 
				AND	trip.siteKey = @siteKey 
				AND trip.userKey = @UserKey 

	END
	
	IF @PageName = 'pasttrips'
	BEGIN
--PRINT 'pasttrips'	

		INSERT INTO #tmpTrip 
		SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
				TOP 5 Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
				, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
				, CASE WHEN Trip.tripStatusKey IN ( 2,3) THEN 'Past' else S.tripStatusName END
				, Trip.agencyKey, U.userFirstName, U.userLastName
				,  LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
				, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
				, 0 				
		FROM	trip WITH(NOLOCK)               
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10    AND Trip.tripStatusKey <> 17 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
				LEFT OUTER JOIN vault.dbo.[Group] GRP WITH(NOLOCK) ON Trip.GroupKey = GRP.groupKey
				INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1				
		WHERE	Trip.StartDate < @SixHrsBeforeTime --@GMT_Today_4_AM
				--AND Trip.startDate BETWEEN @FromDate AND @ToDate  --  @StartDate AND @EndDate
				--AND Trip.recordlocator IS NOT NULL 
				--AND Trip.recordlocator <> '' 
				--AND Trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE Trip.RecordLocator END 
				AND ((Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' ) OR (trip.tripStatusKey = 21)) 
				AND	ISNULL(Trip.recordLocator,'') = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE ISNULL(Trip.RecordLocator,'') END 
				AND Trip.siteKey = @siteKey 
				AND Trip.userKey = @UserKey 
		ORDER BY Trip.startDate 
		
	END
	
	INSERT	
	INTO		#tbl_vw_TRipCarResponse 
	SELECT		trip.tripKey
				,trip.tripName
				,trip.userKey
				,TripCarResponse.recordLocator
				,trip.endDate
				,trip.startDate
				,trip.tripStatusKey
				,dbo.TripCarResponse.actualCarPrice
				,dbo.TripCarResponse.actualCarTax
				,dbo.TripCarResponse.carVendorKey
				,CarContent.dbo.CarCompanies.CarCompanyName
				,dbo.TripCarResponse.carLocationCode
				,dbo.TripCarResponse.PickUpdate
				,dbo.TripCarResponse.dropOutDate
				,CarContent.dbo.SippCodes.SippCodeClass
				,dbo.TripCarResponse.carResponseKey
				,Trip.siteKey
				,trip.createdDate
				,trip.tripRequestKey
				,CarContent.dbo.SabreVehicles.VehicleName
				,TripCarResponse.NoOfDays
				,'' As CityName
				,'' AS StateCode
				,'' AS CountryCode
				,'' As HotelRating
				,0 AS DiscountFare
				,TripCarResponse.RPH AS RPH
	FROM		CarContent.dbo.CarCompanies WITH (NOLOCK) 
				INNER JOIN Trip.dbo.TripCarResponse WITH (NOLOCK) 
				INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK)	ON Trip.dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType 
																	ON CarContent.dbo.CarCompanies.CarCompanyCode = Trip.dbo.TripCarResponse.carVendorKey 
																		And Trip.dbo.TripCarResponse.isDeleted = 0
				LEFT OUTER JOIN CarContent.dbo.SabreLocations WITH(NOLOCK) 
				LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK)	ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode 
																				AND	CarContent.dbo.SabreLocations.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
																				AND CarContent.dbo.SabreLocations.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
																			ON Trip.dbo.TripCarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode 
																				AND Trip.dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode 
																				AND Trip.dbo.TripCarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode 
																				AND Trip.dbo.TripCarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
																				AND Trip.dbo.TripCarResponse.SupplierId = 'Sabre' 
																				AND ISNULL (dbo.TripCarResponse.ISDELETED ,0) = 0 
				INNER JOIN Trip.dbo.Trip WITH (NOLOCK) ON	(Trip.dbo.TripCarResponse.tripKey = Trip.dbo.Trip.tripKey 
																OR ( Trip.dbo.TripCarResponse.tripguidkey = Trip.dbo.trip.tripPurchasedKey  
															AND (Trip.dbo.TripCarResponse.tripKey is null or Trip.dbo.TripCarResponse.tripKey=0 )) 
															) 
															AND Trip.tripStatusKey <> 17 
				INNER JOIN #tmpTrip tmp ON Trip.tripKey = tmp.tripKey 

	UNION ALL

	SELECT		trip.tripKey
				,trip.tripName
				,trip.userKey
				,TR.recordLocator
				,trip.endDate
				,trip.startDate
				,trip.tripStatusKey
				,TR.actualCarPrice
				,TR.actualCarTax
				,TR.carVendorKey
				,CarContent.dbo.CarCompanies.CarCompanyName
				,TR.carLocationCode
				,TR.PickUpdate
				,TR.dropOutDate
				,S.VehicleClass AS SippCodeClass
				,TR.carResponseKey
				,Trip.siteKey
				,trip.createdDate
				,trip.tripRequestKey
				,AV.ALVehicleName
				,TR.NoOfDays
				,'' As CityName
				,'' AS StateCode
				,'' AS CountryCode
				,'' As HotelRating
				,0 AS DiscountFare
				,TR.RPH AS RPH
	FROM		Trip.dbo.TripCarResponse TR WITH (NOLOCK) 
				INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
				LEFT OUTER JOIN CarContent.dbo.AlamoLocations AL WITH (NOLOCK) ON TR.carLocationCode = LEFT(AL.ALLocationCode, 3) AND AL.ALAtAirport = 1 
				LEFT OUTER JOIN CarContent.dbo.ALAMOVEHICLES AV WITH (NOLOCK) ON AL.ALLocationCode = AV.ALLOCATIONCODE AND AV.ALVEHICLECODE = TR.carCategoryCode 
				INNER JOIN CarContent.dbo.AlamoLocations AL_1 WITH(NOLOCK) ON AL.ALLocationCode = AL_1.ALLocationCode AND AL_1.ALAtAirport = 1 
				INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON AV.ALVEHICLECLASSSIZE = S.VehicleClassSize 
				INNER JOIN Trip.dbo.Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )))
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE		TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'AL'  AND Trip.dbo.Trip.tripStatusKey <> 17 

	UNION ALL

	SELECT		trip.tripKey
				,trip.tripName
				,trip.userKey
				,TR.recordLocator
				,trip.endDate
				,trip.startDate
				,trip.tripStatusKey
				,TR.actualCarPrice
				,TR.actualCarTax
				,TR.carVendorKey
				,CarContent.dbo.CarCompanies.CarCompanyName
				,TR.carLocationCode
				,TR.PickUpdate
				,TR.dropOutDate
				,S.VehicleClass AS SippCodeClass
				,TR.carResponseKey
				,Trip.siteKey
				,trip.createdDate
				,trip.tripRequestKey
				,NV.ZLVehicleName
				,TR.NoOfDays
				,'' As CityName
				,'' AS StateCode
				,'' AS CountryCode
				,'' As HotelRating
				,0 AS DiscountFare
				,TR.RPH AS RPH
	FROM		TripCarResponse TR WITH (NOLOCK) 
				INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
				LEFT OUTER JOIN CarContent.dbo.NationalLocations NL WITH (NOLOCK) ON TR.carLocationCode = LEFT(NL.ZLLocationCode, 3) AND NL.ZLAtAirport = 1 
				LEFT OUTER JOIN CarContent.dbo.NationalVehicles NV WITH (NOLOCK) ON NL.ZLLocationCode = NV.ZLLOCATIONCODE AND NV.ZLVEHICLECODE = TR.carCategoryCode 
				INNER JOIN CarContent.dbo.NationalLocations NL_1 WITH(NOLOCK) ON NL.ZLLocationCode = NL_1.ZLLocationCode AND NL_1.ZLAtAirport = 1 
				INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON NV.ZLVEHICLECLASSSIZE = S.VehicleClassSize
				INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 ))) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE		TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZL'  AND Trip.dbo.Trip.tripStatusKey <> 17  
	
	UNION ALL

	SELECT		trip.tripKey
				,trip.tripName
				,trip.userKey
				,TR.recordLocator
				,trip.endDate
				,trip.startDate
				,trip.tripStatusKey
				,TR.actualCarPrice
				,TR.actualCarTax
				,TR.carVendorKey
				,CarContent.dbo.CarCompanies.CarCompanyName
				,TR.carLocationCode
				,TR.PickUpdate
				,TR.dropOutDate
				,S.VehicleClass AS SippCodeClass
				,TR.carResponseKey
				,Trip.siteKey
				,trip.createdDate
				,trip.tripRequestKey
				,ZV.ZRVehicleName
				,TR.NoOfDays
				,'' As CityName
				,'' AS StateCode
				,'' AS CountryCode
				,'' As HotelRating
				,0 AS DiscountFare
				,TR.RPH AS RPH
	FROM		TripCarResponse TR WITH (NOLOCK) 
				INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
				LEFT OUTER JOIN CarContent.dbo.DollarLocations ZL WITH (NOLOCK) ON TR.carLocationCode = LEFT(ZL.ZRLocationCode, 3) AND ZL.ZRAtAirport = 1 
				LEFT OUTER JOIN CarContent.dbo.DollarVehicles ZV WITH (NOLOCK) ON ZL.ZRLocationCode = ZV.ZRLOCATIONCODE AND ZV.ZRVEHICLECODE = TR.carCategoryCode 
				INNER JOIN CarContent.dbo.DollarLocations ZL_1 WITH(NOLOCK) ON ZL.ZRLocationCode = ZL_1.ZRLocationCode AND ZL_1.ZRAtAirport = 1 
				INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON ZV.ZRVEHICLECLASSSIZE = S.VehicleClassSize
				INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )))
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE		TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZR'  AND Trip.dbo.Trip.tripStatusKey <> 17  

	UNION ALL

	SELECT		trip.tripKey
				,trip.tripName
				,trip.userKey
				,TR.recordLocator
				,trip.endDate
				,trip.startDate
				,trip.tripStatusKey
				,TR.actualCarPrice
				,TR.actualCarTax
				,TR.carVendorKey
				,CarContent.dbo.CarCompanies.CarCompanyName
				,TR.carLocationCode
				,TR.PickUpdate
				,TR.dropOutDate
				,S.VehicleClass AS SippCodeClass
				,TR.carResponseKey
				,Trip.siteKey
				,trip.createdDate
				,trip.tripRequestKey
				,TV.ZTVEHICLENAME
				,TR.NoOfDays
				,'' As CityName
				,'' AS StateCode
				,'' AS CountryCode
				,'' As HotelRating
				,0 AS DiscountFare
				,TR.RPH AS RPH
	FROM		TripCarResponse TR WITH (NOLOCK) 
				INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey AND TR.isDeleted = 0
				LEFT OUTER JOIN CarContent.dbo.ThriftyLocations TL WITH (NOLOCK) ON TR.carLocationCode = LEFT(TL.ZTLocationCode, 3) AND TL.ZTAtAirport = 1 
				LEFT OUTER JOIN CarContent.dbo.ThriftyVehicles TV WITH (NOLOCK) ON TL.ZTLocationCode = TV.ZTLOCATIONCODE AND TV.ZTVEHICLECODE = TR.carCategoryCode 
				INNER JOIN CarContent.dbo.ThriftyLocations TL_1 WITH(NOLOCK) ON TL.ZTLocationCode = TL_1.ZTLocationCode AND TL_1.ZTAtAirport = 1 
				INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON TV.ZTVEHICLECLASSSIZE = S.VehicleClassSize
				INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )) ) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE		TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZT' AND dbo.Trip.tripStatusKey <> 17  

	;WITH CTE AS
	(
				SELECT	ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID, Trip.tripKey ORDER BY SH.AddDate DESC) RN
					,dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
					,dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
					,HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
					,HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
					,'' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare, HR.RPH as RPH   
				FROM #tmpTrip tmp 
					INNER JOIN dbo.Trip WITH(NOLOCK) ON tmp.tripKey = Trip.tripKey
					INNER JOIN Trip.dbo.TripHotelResponse AS HR WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey 
						AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
					LEFT OUTER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) ON HR.supplierHotelKey = SH.SupplierHotelId 
						AND HR.supplierId = SH.SupplierFamily
					LEFT OUTER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK) ON SH.HotelId = HT.HotelId 
				WHERE HR.isDeleted = 0  
	)

	INSERT INTO	#tbl_vw_TripHotelResponse_tripaudit
	SELECT		tripKey
				,tripName
				,userKey
				,recordLocator
				,endDate
				,startDate
				,tripStatusKey
				,actualHotelPrice
				,actualHotelTax
				,ChainCode
				,HotelName
				,CityName
				,StateCode
				,checkInDate
				,checkOutDate
				,RatingType 
				,hotelResponseKey
				,siteKey
				,CreatedDate
				,tripRequestKey 
				,VehicleCompanyName
				,NoofDays
				,CountryCode
				,Rating
				,DiscountFare
				,RPH
	FROM CTE WHERE RN=1
	--(
	--			SELECT	ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID, Trip.tripKey ORDER BY SH.AddDate DESC) RN
	--				,dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
	--				,dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
	--				,HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
	--				,HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
	--				,'' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare, HR.RPH as RPH   
	--			FROM #tmpTrip tmp 
	--				INNER JOIN dbo.Trip WITH(NOLOCK) ON tmp.tripKey = Trip.tripKey
	--				INNER JOIN Trip.dbo.TripHotelResponse AS HR WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey 
	--					AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
	--				LEFT OUTER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) ON HR.supplierHotelKey = SH.SupplierHotelId 
	--					AND HR.supplierId = SH.SupplierFamily
	--				LEFT OUTER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK) ON SH.HotelId = HT.HotelId 
	--			WHERE HR.isDeleted = 0  
	--)a WHERE a.RN = 1
	
	--UNION 
	
	--SELECT		tripKey
	--			,tripName
	--			,userKey
	--			,recordLocator
	--			,endDate
	--			,startDate
	--			,tripStatusKey
	--			,actualHotelPrice
	--			,actualHotelTax
	--			,ChainCode
	--			,HotelName
	--			,CityName
	--			,StateCode
	--			,checkInDate
	--			,checkOutDate
	--			,RatingType 
	--			,hotelResponseKey
	--			,siteKey
	--			,CreatedDate
	--			,tripRequestKey 
	--			,VehicleCompanyName
	--			,NoofDays
	--			,CountryCode
	--			,Rating
	--			,DiscountFare
	--			,RPH 
	--FROM 
	--(
	--			SELECT	ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID , Trip.tripKey ORDER BY SH.AddDate DESC) RN
	--					,dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
	--					,dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
	--					,HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
	--					,HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
	--					,'' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare, HR.RPH AS RPH
	--			FROM #tmpTrip tmp
	--				INNER JOIN dbo.Trip WITH(NOLOCK) ON tmp.tripKey = Trip.tripKey
	--				INNER JOIN Trip.dbo.TripHotelResponse AS HR WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
	--				LEFT OUTER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) ON HR.supplierHotelKey = SH.SupplierHotelId 
	--					AND HR.supplierId = SH.SupplierFamily
	--				LEFT OUTER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK) ON SH.HotelId = HT.HotelId AND HR.isDeleted = 0 


	--)b WHERE b.RN = 1
	
		                    
	INSERT	
	INTO		#tbl_vw_TripDetails_tripaudit 
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

	--UNION 
	INSERT  INTO #tbl_vw_TripDetails_tripaudit 
	SELECT		ROW_NUMBER() OVER (ORDER BY t.carresponsekey)
				,'car' AS TYPE
				,t.tripKey
				,t.tripName
				,u.userFirstName
				,u.userLastName
				,u.userKey
				,t.recordLocator
				,t.endDate
				,t.startDate
				,t.tripStatusKey
				,t.actualCarPrice
				,t.actualCarTax
				,t.carVendorKey
				,carCompanyName
				,t.carLocationCode
				,t.carLocationCode
				,NULL
				,t.PickUpdate
				,t.dropOutDate
				,SippCodeClass
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
	FROM		#tbl_vw_TRipCarResponse t WITH (NOLOCK) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
				--LEFT OUTER JOIN TripCarResponse seg ON tmp.tripPurchasedKey= seg.tripGUIDKey
				LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

	--UNION 

	INSERT  INTO #tbl_vw_TripDetails_tripaudit 
	SELECT		ROW_NUMBER() OVER (ORDER BY t.hotelresponsekey)
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
				,hotelname
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
	FROM		#tbl_vw_TripHotelResponse_tripaudit t WITH (NOLOCK) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
				--LEFT OUTER JOIN TripHotelResponse seg ON tmp.tripPurchasedKey = seg.tripGUIDKey
				LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

--ALTER TABLE #tmpTrip ADD TotalCost FLOAT

	--UPDATE		t 
	--SET			TotalCost = (vw.basecost + vw.tax)
	--FROM		#tmpTrip t
	--INNER JOIN 
	--(
	--			SELECT tripKey, basecost, tax 
	--			FROM #tbl_vw_TripDetails_tripaudit 
	--			GROUP BY tripKey, basecost, tax 
	--)vw ON t.tripKey = vw.tripKey

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

	IF LEN(ISNULL(@UDIDandValue,'')) > 0 
	BEGIN

		SET @UDIDandValue = REPLACE(@UDIDandValue,'UD','')

		INSERT INTO @tblSelectedUDIDs (ID, DATA, UDID, UDIDValue)
		SELECT	ID
				,DATA 
				,UD  = SUBSTRING(DATA, 1, CHARINDEX(':', DATA)-1)		
				,UDValue  = SUBSTRING(DATA, CHARINDEX(':', DATA)+1, LEN(DATA))		
		FROM	VAULT.dbo.UFn_StringSplit(@UDIDandValue,',')

		--SELECT ID, DATA, UDID, UDIDValue FROM @tblSelectedUDIDs

		-- Search in TripPassengerUDIDInfo wihtout UDID Conditions, Because In futre there will be performance issue.
		INSERT INTO @tblSelectedUDIDsTrips (TRIPID, UDID, UDIDValue)
		SELECT		Tripkey
					, CompanyUDIDNumber
					, PassengerUDIDValue
		FROM		TripPassengerUDIDInfo WITH(NOLOCK) 
		WHERE		TripKey IN (SELECT tripKey FROM #tmpTrip)
					 --AND CompanyUDIDNumber + ';' + PassengerUDIDValue IN (SELECT DATA FROM @tblSelectedUDIDs)
		
		UPDATE 	@tblSelectedUDIDsTrips SET DATA = UDID +':' + UDIDValue  

		---- WITH UDID conditions		
		INSERT INTO @tblSelectedUDIDsTripsForUDID (TRIPID, DATA, UDID, UDIDValue)
		SELECT		TRIPID, DATA, UDID, UDIDValue
		FROM		@tblSelectedUDIDsTrips
		WHERE		DATA IN (SELECT DATA FROM @tblSelectedUDIDs)

	END
	
	IF @PageName = 'mytrips' OR @PageName = 'activetrips'                           
	BEGIN
	 	
		SELECT	trip.tripKey, trip.TripRequestKey, tripName, trip.TravelerName, trip.userKey, recordLocator, trip.startDate startDate
			, trip.endDate endDate, tripStatusKey, tripStatusName = trip.tripStatusName, agencyKey, userFirstName, userLastName
			, userLogin = LEFT(userFirstName,1) + ' ' + userLastName, groupKey, groupName, CreatedDate, trip.TotalCost      
		FROM	#tmpTrip trip 
				--INNER JOIN Trip.dbo.TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		ORDER BY Trip.startDate DESC   ---- This is steve's requirment to show always recent booking on top of the list           
	
		/*get the Air, car and hotel response detail for filtered trips   */
		         
		SELECT	vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode, vt.VendorName
			, airSegmentDepartureAirport  = ISNULL(TA_Dep.CityName,'') +', '+ ISNULL(TA_Dep.StateCode,'') + ' (' + TA_Dep.AirportCode + ')'
			, airSegmentArrivalAirport = ISNULL(TA_Arr.CityName,'') +', '+ ISNULL(TA_Arr.StateCode,'') + ' (' + TA_Arr.AirportCode + ')'
			, vt.flightNumber, vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator 
		FROM	#tbl_vw_TripDetails_tripaudit vt WITH(NOLOCK) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey 
				INNER JOIN TRIP.DBO.AirportLookup TA_Dep WITH(NOLOCK) ON TA_Dep.AirportCode = vt.airSegmentDepartureAirport
				INNER JOIN TRIP.DBO.AirportLookup TA_Arr WITH(NOLOCK) ON TA_Arr.AirportCode = vt.airSegmentArrivalAirport
		ORDER BY vt.tripKey, vt.RPH

		SELECT	OPT.* 
		FROM	TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
				INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 

	END
	ELSE
	BEGIN
	
		SELECT	trip.tripKey, trip.TripRequestKey, tripName, trip.TravelerName, trip.userKey, recordLocator, trip.startDate startDate
			, trip.endDate endDate, tripStatusKey, tripStatusName = trip.tripStatusName, agencyKey, userFirstName, userLastName
			, userLogin = LEFT(userFirstName,1) + ' ' + userLastName, groupKey, groupName, CreatedDate, trip.TotalCost      
		FROM	#tmpTrip trip 
				--INNER JOIN Trip.dbo.TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		ORDER BY Trip.startDate ASC   ---- This is steve's requirment to show always recent booking on top of the list           
	
		/*get the Air, car and hotel response detail for filtered trips   */
		         
		SELECT	vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode, vt.VendorName
			, airSegmentDepartureAirport  = ISNULL(TA_Dep.CityName,'') +', '+ ISNULL(TA_Dep.StateCode,'') + ' (' + TA_Dep.AirportCode + ')'
			, airSegmentArrivalAirport = ISNULL(TA_Arr.CityName,'') +', '+ ISNULL(TA_Arr.StateCode,'') + ' (' + TA_Arr.AirportCode + ')'
			, vt.flightNumber, vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator 
		FROM	#tbl_vw_TripDetails_tripaudit vt WITH(NOLOCK) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey 
				INNER JOIN TRIP.DBO.AirportLookup TA_Dep WITH(NOLOCK) ON TA_Dep.AirportCode = vt.airSegmentDepartureAirport
				INNER JOIN TRIP.DBO.AirportLookup TA_Arr WITH(NOLOCK) ON TA_Arr.AirportCode = vt.airSegmentArrivalAirport
		ORDER BY vt.tripKey, vt.RPH

		SELECT	OPT.* 
		FROM	TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
				INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 
	
	END
	
	DROP TABLE #tblUser
	DROP TABLE #tmpTrip
	DROP TABLE #tbl_vw_TRipCarResponse
	DROP TABLE #tbl_vw_TripHotelResponse_tripaudit
	DROP TABLE #tbl_vw_TripDetails_tripaudit

END
GO
