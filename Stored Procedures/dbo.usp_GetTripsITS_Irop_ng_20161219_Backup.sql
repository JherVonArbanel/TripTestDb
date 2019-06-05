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
EXEC [usp_GetTripsITS_Irop_ng] 
@SiteGUID = N'2D620B87-E702-4AE9-A91F-88F864FDC2D1'
	, @CompanyGUID = 'BB767541-E713-449E-9B3E-F0A213979D83'
	, @UserGUID = 'B45EE4E3-C7AA-4B4C-BBC9-04F79AF564CD'
	, @PageName = 'ActiveTrips'
	, @PNR = ''
	, @UDIDandValue = 'UD5:12345,UD10:ADVGB,UD7:09/13/2016'
	
	EXEC [usp_GetTripsITS_Irop_ng] 
@SiteGUID = N'2D620B87-E702-4AE9-A91F-88F864FDC2D1'
	, @CompanyGUID = 'BB767541-E713-449E-9B3E-F0A213979D83'
	, @UserGUID = 'B45EE4E3-C7AA-4B4C-BBC9-04F79AF564CD'
	, @PageName = 'mytrips'
	, @PNR = ''
	, @UDIDandValue = 'UD10:MYNTHW,UD5:154,UD3:FLG001'
*/
-- =============================================                         

--EXEC [dbo].[usp_GetTripsITS_Irop_ng]   @SiteGUID=N'1F33CD4E-BCCC-466C-A618-2C5A36AB5B93',@CompanyGUID=N'4CB134CD-6C48-40AF-BBD2-2EA1F0802B5B',@UserGUID=N'5568CD20-A7F3-4535-BF1B-AB7E66863F72',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=NULL

CREATE PROCEDURE [dbo].[usp_GetTripsITS_Irop_ng_20161219_Backup] 
--DECLARE
	@SiteGUID nvarchar(500) 
	, @CompanyGUID nvarchar(50) 
	, @UserGUID nvarchar(500)
	, @PageName NVARCHAR(500) -- 'mytrips','activetrips','pasttrips'
	, @PNR NVARCHAR(12)
	, @UDIDandValue NVARCHAR(MAX) --- 'UD10:MYNTHW,UD5:154,UD3:FLG001

AS 
BEGIN

	DECLARE 	@RoleTripId INT

--SELECT @SiteGUID=N'5FEED8B9-FC73-473B-B2C6-221BDD13369C',@CompanyGUID=N'2F2F1E84-3C10-4058-BC5C-FB9E417557F7'
--	,@UserGUID=N'65DE26A7-ADFA-4650-9DC9-BC8C14EDEF11'
--	,@PageName=N'pasttrips',@PNR=N'',@UDIDandValue=NULL

--SELECT @SiteGUID=N'1F33CD4E-BCCC-466C-A618-2C5A36AB5B93',@CompanyGUID=N'4CB134CD-6C48-40AF-BBD2-2EA1F0802B5B'
--	,@UserGUID=N'C644172C-9129-4E13-90A4-7DE64BA8D74A',@PageName=N'mytrips',@PNR=N'',@UDIDandValue=NULL
	
	IF @PNR = '' SET @PNR = null

	DECLARE @tblSelectedUDIDs table (ID int, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))
	DECLARE @tblSelectedUDIDsTrips table (ID int, TRIPID BIGINT, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))
	DECLARE @tblSelectedUDIDsTripsForUDID table (ID int, TRIPID BIGINT, DATA nvarchar(500), UDID nvarchar(50), UDIDValue nvarchar(500))

	DECLARE @SiteKey INT, @CompanyKey INT, @UserKey INT, @AgencyKey INT
	DECLARE	@dbResponse TABLE (STATUSCODE nvarchar(50), STATUSMESSAGE NVARCHAR(500))
	
	--SELECT	 @SiteKey=SiteKey, @AgencyKey = data.value('(/Site/Agency/key/node())[1]', 'INT')
	--FROM	 Vault..SiteConfiguration 
	----WHERE siteKey = 64 AND @SiteGUID = '2D620B87-E702-4AE9-A91F-88F864FDC2D1'
	--WHERE	 data.value('(/Site/SiteGUID/node())[1]', 'NVARCHAR(500)') = @SiteGUID

	SELECT	 @SiteKey=SiteKey, @AgencyKey = data.value('(/Site/Agency/key/node())[1]', 'INT')
	FROM	 Vault..SiteConfiguration 
	WHERE siteKey = 20 AND @SiteGUID = '1F33CD4E-BCCC-466C-A618-2C5A36AB5B93'
	
	SELECT @CompanyKey = CompanyKey FROM Vault..Company WHERE CompanyGUID = @CompanyGUID 

	SELECT @Userkey = UserKey FROM Vault..[User] WHERE UserGUID = @UserGUID
	
	SELECT @RoleTripId = userRoles FROM Vault..[UserProfile]  WHERE userKey = @UserKey

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
	
	INSERT INTO #tblUser                          
	SELECT DISTINCT userKey FROM Vault.dbo.GetAllArrangees(@userkey, @companyKey)                       
	
	--DECLARE  @GMTNOW DATETIME = DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), GETDATE())
	--	,@GMT_Today_4_AM DATETIME 
	--SET @GMT_Today_4_AM = CONVERT(DATETIME, (CONVERT(VARCHAR,@GMTNOW,103)  + ' ' + CONVERT(VARCHAR,'04:00:00.000')),103)
	DECLARE @SixHrsBeforeTime DATETIME = DATEADD(HOUR, -6, GETDATE())
	
	IF @PageName = 'mytrips'                            
	BEGIN 
		IF @RoleTripId = 1  -- Travller 
		BEGIN
			INSERT INTO #tmpTrip 
			SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
				Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
				, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
				,CASE WHEN Trip.StartDate < @SixHrsBeforeTime --@GMT_Today_4_AM 
									AND Trip.tripStatusKey IN (2,3)
				Then 'Past'
				WHEN Trip.StartDate >= @SixHrsBeforeTime --@GMT_Today_4_AM 
								AND Trip.tripStatusKey IN (2,3) 
				THEN 'Purchased'
				ELSE S.tripStatusName END
				, Trip.agencyKey, U.userFirstName, U.userLastName
				, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
				, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
				, 0 
			FROM trip WITH(NOLOCK)               
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
				LEFT OUTER JOIN vault..[Group] GRP ON Trip.GroupKey = GRP.groupKey
				INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
			WHERE Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' AND 
				Trip.recordLocator = CASE WHEN @PNR IS NOT NULL THEN @PNR ELSE Trip.RecordLocator END AND
				Trip.siteKey = @siteKey 
				AND trip.userKey = @userkey 
				-- AND trip.userKey = CASE WHEN @RoleTripId = 1 THEN @userkey ELSE trip.userKey END
		END
		ELSE
		BEGIN
			INSERT INTO #tmpTrip 
			SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
				Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
				, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
				,CASE WHEN Trip.StartDate  < @SixHrsBeforeTime --@GMT_Today_4_AM 
								AND Trip.tripStatusKey IN (2,3)
				Then 'Past'
				WHEN Trip.StartDate >= @SixHrsBeforeTime --@GMT_Today_4_AM 
							AND Trip.tripStatusKey IN (2,3) 
				THEN 'Purchased'
				ELSE S.tripStatusName END
				, Trip.agencyKey, U.userFirstName, U.userLastName
				, LEFT(ISNULL(U.userFirstName, ''), 1) + ' ' +U.userLastName AS userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
				, LTRIM(RTRIM(ISNULL(TPI.PassengerLastName, '') + '/' + LEFT(ISNULL(TPI.PassengerFirstName, ''), 1)))
				, 0 
			FROM trip WITH(NOLOCK)               
				INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
				LEFT OUTER JOIN vault..[Group] GRP ON Trip.GroupKey = GRP.groupKey
				INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
			WHERE Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' AND 
				Trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE Trip.RecordLocator END AND
				Trip.siteKey = @siteKey 
				AND trip.userKey = @userkey 
		END
	END	
	
	IF @PageName = 'activetrips'
	BEGIN
	IF @RoleTripId <> 1 -- No Access to Traveller
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
		FROM trip WITH(NOLOCK)               
			INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17 
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
			LEFT OUTER JOIN vault..[Group] GRP ON Trip.GroupKey = GRP.groupKey
			INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
		WHERE --Trip.endDate >= GETDATE() 
				Trip.StartDate >= @SixHrsBeforeTime --@GMT_Today_4_AM
			AND Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' AND 
			Trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE Trip.RecordLocator END AND
			Trip.siteKey = @siteKey 
			-- AND trip.userKey = @userkey
	END
	END
	
	IF @PageName = 'pasttrips'
	BEGIN
	IF @RoleTripId <> 1 -- No Access to Traveller
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
		FROM trip WITH(NOLOCK)               
			INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey 
				AND Trip.tripStatusKey <> 10    AND Trip.tripStatusKey <> 17 
				INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey  
			LEFT OUTER JOIN vault..[Group] GRP ON Trip.GroupKey = GRP.groupKey
			INNER JOIN TripPassengerInfo TPI ON trip.TripKey = TPI.TripKey AND TPI.IsPrimaryPassenger = 1
		WHERE --Trip.endDate < GETDATE() 
			Trip.StartDate < @SixHrsBeforeTime --@GMT_Today_4_AM
		AND Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' AND 
			Trip.recordLocator = CASE WHEN (@PNR <> '' AND @PNR IS NOT NULL) THEN @PNR ELSE Trip.RecordLocator END AND
			Trip.siteKey = @siteKey 
			-- AND trip.userKey = @userkey
END
	END
	
	INSERT INTO #tbl_vw_TRipCarResponse 
	SELECT trip.tripKey, trip.tripName, trip.userKey, TripCarResponse.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey
		, dbo.TripCarResponse.actualCarPrice, dbo.TripCarResponse.actualCarTax, dbo.TripCarResponse.carVendorKey
		, CarContent.dbo.CarCompanies.CarCompanyName, dbo.TripCarResponse.carLocationCode, dbo.TripCarResponse.PickUpdate
		, dbo.TripCarResponse.dropOutDate, CarContent.dbo.SippCodes.SippCodeClass, dbo.TripCarResponse.carResponseKey
		, Trip.siteKey, trip.createdDate, trip.tripRequestKey, CarContent.dbo.SabreVehicles.VehicleName, TripCarResponse.NoOfDays
		, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare, TripCarResponse.RPH AS RPH
	FROM CarContent.dbo.CarCompanies WITH (NOLOCK) 
		INNER JOIN dbo.TripCarResponse WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) ON dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType ON 
			CarContent.dbo.CarCompanies.CarCompanyCode = dbo.TripCarResponse.carVendorKey And dbo.TripCarResponse.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.SabreLocations 
		LEFT OUTER JOIN CarContent.dbo.SabreVehicles WITH (NOLOCK) ON CarContent.dbo.SabreLocations.VendorCode = CarContent.dbo.SabreVehicles.VendorCode AND 
			CarContent.dbo.SabreLocations.LocationAirportCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
			CarContent.dbo.SabreLocations.LocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode ON 
			dbo.TripCarResponse.carVendorKey = CarContent.dbo.SabreVehicles.VendorCode AND 
			dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SabreVehicles.SippCode AND 
			dbo.TripCarResponse.carLocationCode = CarContent.dbo.SabreVehicles.LocationAirportCode AND 
			dbo.TripCarResponse.carLocationCategoryCode = CarContent.dbo.SabreVehicles.LocationCategoryCode 
			AND  TripCarResponse.SupplierId = 'Sabre' AND ISNULL (dbo.TripCarResponse.ISDELETED ,0) = 0 
		INNER JOIN dbo.Trip WITH (NOLOCK) ON (dbo.TripCarResponse.tripKey = dbo.Trip.tripKey or 
					( dbo.TripCarResponse.tripguidkey = dbo.trip.tripPurchasedKey  and 
					(dbo.TripCarResponse.tripKey is null or dbo.TripCarResponse.tripKey=0 )) ) 
			AND Trip.tripStatusKey <> 17 
		INNER JOIN #tmpTrip tmp ON Trip.tripKey = tmp.tripKey 

	UNION ALL

	SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
		, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
		, S.VehicleClass AS SippCodeClass, TR.carResponseKey, Trip.siteKey, trip.createdDate, trip.tripRequestKey, AV.ALVehicleName
		, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare, TR.RPH AS RPH
	FROM TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
			AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.AlamoLocations AL WITH (NOLOCK) ON TR.carLocationCode = LEFT(AL.ALLocationCode, 3) AND AL.ALAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.ALAMOVEHICLES AV WITH (NOLOCK) ON AL.ALLocationCode = AV.ALLOCATIONCODE AND AV.ALVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.AlamoLocations AL_1 ON AL.ALLocationCode = AL_1.ALLocationCode AND AL_1.ALAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON AV.ALVEHICLECLASSSIZE = S.VehicleClassSize 
		INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )))
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'AL'  AND dbo.Trip.tripStatusKey <> 17 

	UNION ALL

	SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
		, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
		, S.VehicleClass AS SippCodeClass, TR.carResponseKey, Trip.siteKey, trip.createdDate, trip.tripRequestKey, NV.ZLVehicleName
		, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare, TR.RPH AS RPH
	FROM TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
			AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.NationalLocations NL WITH (NOLOCK) ON TR.carLocationCode = LEFT(NL.ZLLocationCode, 3) AND NL.ZLAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.NationalVehicles NV WITH (NOLOCK) ON NL.ZLLocationCode = NV.ZLLOCATIONCODE AND NV.ZLVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.NationalLocations NL_1 ON NL.ZLLocationCode = NL_1.ZLLocationCode AND NL_1.ZLAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON NV.ZLVEHICLECLASSSIZE = S.VehicleClassSize
		INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 ))) 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZL'  AND dbo.Trip.tripStatusKey <> 17  
	
	UNION ALL

	SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
		, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
		, S.VehicleClass AS SippCodeClass, TR.carResponseKey, Trip.siteKey, trip.createdDate, trip.tripRequestKey, ZV.ZRVehicleName
		, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare, TR.RPH AS RPH
	FROM TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
			AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.DollarLocations ZL WITH (NOLOCK) ON TR.carLocationCode = LEFT(ZL.ZRLocationCode, 3) AND ZL.ZRAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.DollarVehicles ZV WITH (NOLOCK) ON ZL.ZRLocationCode = ZV.ZRLOCATIONCODE AND ZV.ZRVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.DollarLocations ZL_1 ON ZL.ZRLocationCode = ZL_1.ZRLocationCode AND ZL_1.ZRAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON ZV.ZRVEHICLECLASSSIZE = S.VehicleClassSize
		INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )))
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZR'  AND dbo.Trip.tripStatusKey <> 17  

	UNION ALL

	SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
		, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
		, S.VehicleClass AS SippCodeClass, TR.carResponseKey, Trip.siteKey, trip.createdDate, trip.tripRequestKey, TV.ZTVEHICLENAME
		, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode, '' As HotelRating, 0 AS DiscountFare, TR.RPH AS RPH
	FROM TripCarResponse TR WITH (NOLOCK) 
		INNER JOIN CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
			AND TR.isDeleted = 0
		LEFT OUTER JOIN CarContent.dbo.ThriftyLocations TL WITH (NOLOCK) ON TR.carLocationCode = LEFT(TL.ZTLocationCode, 3) AND TL.ZTAtAirport = 1 
		LEFT OUTER JOIN CarContent.dbo.ThriftyVehicles TV WITH (NOLOCK) ON TL.ZTLocationCode = TV.ZTLOCATIONCODE AND TV.ZTVEHICLECODE = TR.carCategoryCode 
		INNER JOIN CarContent.dbo.ThriftyLocations TL_1 ON TL.ZTLocationCode = TL_1.ZTLocationCode AND TL_1.ZTAtAirport = 1 
		INNER JOIN CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON TV.ZTVEHICLECLASSSIZE = S.VehicleClassSize
		INNER JOIN Trip WITH (NOLOCK) ON (TR.tripKey = Trip.tripKey OR (TR.tripGUIDKey = Trip.tripPurchasedKey and (tr.tripKey is null or tr.tripKey =0 )) ) 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZT' AND dbo.Trip.tripStatusKey <> 17  

	INSERT INTO #tbl_vw_TripHotelResponse_tripaudit
	SELECT tripKey, tripName, userKey, recordLocator, endDate, startDate, tripStatusKey, actualHotelPrice, actualHotelTax, 
		ChainCode, HotelName, CityName, StateCode, checkInDate, checkOutDate, RatingType , hotelResponseKey, 
		siteKey, CreatedDate, tripRequestKey , VehicleCompanyName,  NoofDays, CountryCode, Rating, DiscountFare, RPH
	FROM 
	(
		SELECT ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID ORDER BY SH.AddDate DESC) RN
			, dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
			, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
			, HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
			, HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
			, '' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare, HR.RPH as RPH   
		FROM HotelContent.dbo.Hotels AS HT WITH (NOLOCK) 
			INNER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) 
			INNER JOIN dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId 
				AND SH.SupplierFamily = HR.supplierId AND HR.isDeleted = 0 
			INNER JOIN dbo.Trip WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	)a WHERE a.RN = 1
	
	UNION 
	
	SELECT tripKey, tripName, userKey, recordLocator, endDate, startDate, tripStatusKey, actualHotelPrice, actualHotelTax, 
		ChainCode, HotelName, CityName, StateCode, checkInDate, checkOutDate, RatingType , hotelResponseKey, 
		siteKey, CreatedDate, tripRequestKey , VehicleCompanyName,  NoofDays, CountryCode, Rating, DiscountFare, RPH 
	FROM 
	(
		SELECT ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID ORDER BY SH.AddDate DESC) RN
			, dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
			, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
			, HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
			, HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
			, '' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare, HR.RPH AS RPH
		FROM HotelContent.dbo.Hotels AS HT WITH (NOLOCK) 
			INNER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) 
			INNER JOIN dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId 
				AND SH.SupplierFamily = HR.supplierId AND HR.isDeleted = 0 
			INNER JOIN dbo.Trip WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
		WHERE (ISNULL(HR.isDeleted, 0) = 0) 
	) b WHERE b.RN = 1
		                    
	INSERT INTO #tbl_vw_TripDetails_tripaudit 
	SELECT ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder, 'air' AS TYPE, trip.tripKey, trip.tripName, u.userFirstName
		, u.userLastName, u.userKey, trip.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, resp.actualAirPrice AS basecost
		, resp.actualAirTax AS tax, seg.airSegmentMarketingAirlineCode AS vendorcode, vendor.ShortName AS VendorName
		, seg.airSegmentDepartureAirport, seg.airSegmentArrivalAirport, CONVERT(varchar(20), seg.airSegmentFlightNumber) AS flightNumber, 
		seg.airSegmentDepartureDate AS departuredate, seg.airSegmentArrivalDate AS arrivaldate, NULL AS carType
		, CONVERT(varchar(20), seg.airLegNumber) AS Ratingtype, seg.airSegmentKey AS responseKey, seg.recordLocator AS vendorLocator
		,  Trip.siteKey, trip.createdDate, trip.tripRequestKey, '' As VehicleCompanyName, 0 as NoofDays, '' as CityName 
		, '' as StateCode, '' as CountryCode, '' as HotelRating, ISNULL(resp.discountedBaseFare,0) as DiscountFare, ISNULL(seg.RPH, 0) 
	FROM Trip WITH (NOLOCK) 
		INNER JOIN TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
		INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
		INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
		LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 
		LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
	WHERE ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   and Trip.tripStatusKey <> 17 

	UNION 

	SELECT ROW_NUMBER() OVER (ORDER BY t.carresponsekey), 'car' AS TYPE, t.tripKey, t.tripName, u.userFirstName, u.userLastName, u.userKey
		, t.recordLocator, t.endDate, t.startDate, t.tripStatusKey, t.actualCarPrice, t.actualCarTax, t.carVendorKey, carCompanyName, t.carLocationCode
		, t.carLocationCode, NULL, t.PickUpdate, t.dropOutDate, SippCodeClass, NULL AS Ratingtype, t.carResponseKey, t.recordLocator, t.siteKey
		, t.createdDate, t.tripRequestKey, VehicleName As VehicleCompanyName, t.NoofDays, '' as CityName, '' as StateCode, '' as CountryCode 
		, '' as HotelRating, 0 as  DiscountFare, ISNULL(t.RPH, 0) 
	FROM #tbl_vw_TRipCarResponse t WITH (NOLOCK) 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
		--LEFT OUTER JOIN TripCarResponse seg ON tmp.tripPurchasedKey= seg.tripGUIDKey
		LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

	UNION 

	SELECT ROW_NUMBER() OVER (ORDER BY t.hotelresponsekey), 'hotel' AS TYPE, t.tripkey, t.tripName, u.userFirstName, u.userLastName, u.userKey
		, t.recordLocator, t.endDate, t.startDate, t.tripStatusKey, t.actualHotelPrice, t.actualHotelTax, ChainCode
		, hotelname, cityname + ',' + StateCode, cityname + ',' + StateCode, NULL, t.checkindate, t.checkoutdate, NULL, Ratingtype
		, t .hotelResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey , '' As VehicleCompanyName ,0 as NoofDays
		, t.CityName, t.StateCode, t.CountryCode, t.Rating AS HotelRating, 0 AS DiscountFare, ISNULL(t.RPH, 0)
	FROM #tbl_vw_TripHotelResponse_tripaudit t WITH (NOLOCK) 
		INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
		--LEFT OUTER JOIN TripHotelResponse seg ON tmp.tripPurchasedKey = seg.tripGUIDKey
		LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

--ALTER TABLE #tmpTrip ADD TotalCost FLOAT

	UPDATE t SET TotalCost = (vw.basecost + vw.tax)
	FROM #tmpTrip t
		INNER JOIN 
		(
			SELECT tripKey, basecost, tax 
			FROM #tbl_vw_TripDetails_tripaudit 
			GROUP BY tripKey, basecost, tax 
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
		SELECT	 Tripkey
				, CompanyUDIDNumber
				, PassengerUDIDValue
		FROM	TripPassengerUDIDInfo 
		WHERE	TripKey IN (SELECT tripKey FROM #tmpTrip)
				 --AND CompanyUDIDNumber + ';' + PassengerUDIDValue IN (SELECT DATA FROM @tblSelectedUDIDs)
		
		UPDATE 	@tblSelectedUDIDsTrips SET DATA = UDID +':' + UDIDValue  

		---- WITH UDID conditions		
		INSERT INTO @tblSelectedUDIDsTripsForUDID (TRIPID, DATA, UDID, UDIDValue)
		SELECT  TRIPID, DATA, UDID, UDIDValue
		FROM	@tblSelectedUDIDsTrips
		WHERE	DATA IN (SELECT DATA FROM @tblSelectedUDIDs)
		
		--SELECT TRIPID FROM @tblSelectedUDIDsTripsForUDID
		
		SELECT trip.tripKey, trip.TripRequestKey, tripName, trip.TravelerName, trip.userKey, recordLocator, trip.startDate startDate
			, trip.endDate endDate, tripStatusKey,trip.tripStatusName, agencyKey, userFirstName, userLastName
			, userLogin = LEFT(userFirstName,1) + ' ' + userLastName
			, groupKey,groupName, CreatedDate , trip.TotalCost      
		FROM #tmpTrip trip 
			INNER JOIN TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		WHERE Trip.tripKey in (SELECT TripID from @tblSelectedUDIDsTripsForUDID)
		ORDER BY Trip.tripKey DESC
		
		---  get the Air, car and hotel response detail for filtered trips            
		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode, vt.VendorName, vt.airSegmentDepartureAirport
			, vt.airSegmentArrivalAirport, vt.flightNumber, vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey
			, vt.vendorLocator 
		FROM #tbl_vw_TripDetails_tripaudit vt WITH(NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey 
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey 
		WHERE tmp.tripKey in (SELECT TripID from @tblSelectedUDIDsTripsForUDID)
		ORDER BY vt.tripKey, vt.RPH

		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
			INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 
		WHERE T.tripKey in (SELECT TripID from @tblSelectedUDIDsTripsForUDID)

	END
	ELSE
	BEGIN
	
		SELECT trip.tripKey, trip.TripRequestKey, tripName, trip.TravelerName, trip.userKey, recordLocator, trip.startDate startDate
			, trip.endDate endDate, tripStatusKey,
			tripStatusName = trip.tripStatusName
			, agencyKey, userFirstName, userLastName
			, userLogin = LEFT(userFirstName,1) + ' ' + userLastName, groupKey,groupName, CreatedDate , trip.TotalCost      
		FROM #tmpTrip trip 
			INNER JOIN TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		ORDER BY Trip.tripKey DESC   ---- This is steve's requirment to show always recent booking on top of the list           
	
		---  get the Air, car and hotel response detail for filtered trips            
		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode, vt.VendorName
		,airSegmentDepartureAirport  = ISNULL(TA_Dep.CityName,'') +', '+ ISNULL(TA_Dep.StateCode,'') + ' (' + TA_Dep.AirportCode + ')'
		,airSegmentArrivalAirport = ISNULL(TA_Arr.CityName,'') +', '+ ISNULL(TA_Arr.StateCode,'') + ' (' + TA_Arr.AirportCode + ')'
		, vt.flightNumber, vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey
			, vt.vendorLocator 
		FROM #tbl_vw_TripDetails_tripaudit vt WITH(NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey 
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey 
			INNER JOIN TRIP.DBO.AirportLookup TA_Dep ON TA_Dep.AirportCode = vt.airSegmentDepartureAirport
			INNER JOIN TRIP.DBO.AirportLookup TA_Arr ON TA_Arr.AirportCode = vt.airSegmentArrivalAirport
		ORDER BY vt.tripKey, vt.RPH

		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
			INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 

	END
	
	DROP TABLE #tblUser
	DROP TABLE #tmpTrip
	DROP TABLE #tbl_vw_TRipCarResponse
	DROP TABLE #tbl_vw_TripHotelResponse_tripaudit
	DROP TABLE #tbl_vw_TripDetails_tripaudit

END	
GO
