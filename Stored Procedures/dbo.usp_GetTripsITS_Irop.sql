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
declare @p11 int
set @p11=29
exec usp_GetTripsITS_Irop @pageName=N'MyTrips',@pageNo=1,@userkey=3478,@tripKey=0,@fromDate=N'1-1-1',@toDate=N'9999-12-31',@traveler=NULL,@status=NULL,@companyKey=404,@TripCompType=N'Trip',@totalRecords=@p11 output,@siteKey=39,@sortField=N'Traveler',@sortDirection=N'Ascending'
select @p11
*/
-- =============================================                         

CREATE PROCEDURE [dbo].[usp_GetTripsITS_Irop]          
--DECLARE	
	@PageName  NVARCHAR(500), 
	@pageNo   INT, 
	--@pageSize  INT,
	@userkey  INT, 
	@tripKey  INT = NULL, 
	@fromDate  NVARCHAR(50), 
	@toDate   NVARCHAR(50), 
	@traveler  INT, 
	@status   INT, 
	@companyKey  INT = NULL, 
	@TripCompType VARCHAR(10), 
	@siteKey  INT = NULL, 
	@createdDate DATETIME = '01-01-1900 00:00:00', 
	@totalRecords INT OUTPUT, 
	@sortField as varchar (200), 
	@sortDirection as varchar(20),
	@groupKey INT = 0 
AS 
BEGIN 

/*
SELECT @pageName=N'MyTrips',@pageNo=1,@userkey=3478,@tripKey=0,@fromDate=N'1-1-1',@toDate=N'9999-12-31',@traveler=NULL,@status=NULL,@companyKey=404,@TripCompType=N'Trip',@totalRecords=29,@siteKey=39,@sortField=N'Traveler',@sortDirection=N'Ascending'
*/

--SELECT GETDATE() AS [0.1]  
	                  
	CREATE TABLE #tblUser                          
	(                          
		UserKey INT 
	)                          

	CREATE TABLE #tmpTrip 
	(                          
		RowID   INT,                          
		tripKey   INT,                          
		TripRequestKey INT,                          
		tripName  NVARCHAR(100),                          
		userKey   INT,                          
		recordLocator NVARCHAR(100),                          
		startDate  DATETIME,                          
		endDate   DATETIME,                          
		tripStatusKey INT,                          
		agencyKey  INT,                          
		userFirstName NVARCHAR(300),                          
		userLastName NVARCHAR(300),                          
		userLogin  NVARCHAR(300),    
		tripPurchasedKey uniqueidentifier,
		groupKey INT, 
		groupName NVARCHAR(100),
		CreatedDate DATETIME
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
		DiscountFare INT
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
		DiscountFare   FLOAT
	) 

--SELECT GETDATE() AS [0.2] 
                           
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

--SELECT GETDATE() AS [0.3] 

	IF @PageName <> N'bids'                      
	BEGIN                      
		SET @tripKey = CASE WHEN @tripKey IS NULL THEN 0 ELSE @tripKey END                       
	END                      

--SELECT GETDATE() AS [0.4] 
                       
	DECLARE @strQuery NVARCHAR(MAX), @paramDesc NVARCHAR(200)                        
                      
        ---- get the trip detail from trip table with filter parameter                          
	IF @PageName = 'mytrips'                            
	BEGIN                            

		INSERT INTO #tmpTrip            
		SELECT ROW_NUMBER() OVER (ORDER BY  -----Implemented sorting          
			case when @sortField = 'Depart' and @sortDirection ='Descending' then    Trip.startDate  End   desc,               
			case when @sortField = 'Depart' and @sortDirection ='Ascending' then    Trip.startDate  End   asc,            
			case when @sortField = 'Return' and @sortDirection ='Descending' then    Trip.endDate  End   desc,               
			case when @sortField = 'Return' and @sortDirection ='Ascending' then    Trip.endDate  End   asc,            
			case when @sortField = 'Status' and @sortDirection ='Descending' then     S.tripStatusName  End   desc,               
			case when @sortField = 'Status' and @sortDirection ='Ascending' then     S.tripStatusName  End   asc,            
			case when @sortField = 'Amount' and @sortDirection ='Descending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   desc,               
			case when @sortField = 'Amount' and @sortDirection ='Ascending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   asc),             
			Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate,          
			Trip.endDate, Trip.tripStatusKey, Trip.agencyKey,                         
			U.userFirstName, U.userLastName, U.userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
		FROM trip WITH(NOLOCK)               
			INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey 
				AND Trip.tripStatusKey <> 10    AND Trip.tripStatusKey <> 17 
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey 
			LEFT OUTER JOIN vault..[Group] GRP ON Trip.GroupKey = GRP.groupKey
			LEFT OUTER JOIN TripAirResponse TAR WITH (NOLOCK) ON trip.tripPurchasedKey = TAR.tripGUIDKey AND TAR.isDeleted = 0 
			LEFT OUTER JOIN TripCarResponse TCR WITH (NOLOCK) ON trip.tripPurchasedKey = TCR.tripGUIDKey  And TCR.isDeleted = 0 
			LEFT OUTER JOIN TripHotelResponse THR WITH (NOLOCK) ON trip.tripPurchasedKey = THR.tripGUIDKey AND THR.isDeleted = 0 
			LEFT OUTER JOIN TripAirSegmentOptionalServices OPT WITH (NOLOCK) ON trip.tripKey = OPT.tripKey AND OPT.isDeleted = 0 
		WHERE Trip.tripKey = CASE WHEN @tripKey = 0 THEN Trip.tripKey ELSE @tripKey END 
			AND Trip.startDate between @fromDate and @toDate 
			--AND dbo.IsTripStatusAsPerType(ISNULL(@status,Trip.tripStatusKey),@PageName) = 1 
			AND Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' AND 
			Trip.endDate >= GETDATE() AND Trip.tripStatusKey = ISNULL(@status,Trip.tripStatusKey) 
			AND Trip.siteKey = CASE WHEN @siteKey IS NULL THEN Trip.siteKey ELSE @siteKey END  --Added for TFS 861 
			AND trip.userKey = @userkey

		--select * from #tmpTrip     
		SELECT @totalRecords = COUNT(*) FROM #tmpTrip     ---get total records count in output parameter            

		SELECT trip.tripKey, trip.TripRequestKey, tripName, trip.userKey, recordLocator, TR.tripFromDate1 startDate, TR.tripToDate1 endDate,                      
		tripStatusKey, agencyKey, userFirstName, userLastName, userLogin, groupKey,groupName, CreatedDate             
		FROM #tmpTrip trip 
			INNER JOIN TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		ORDER BY Trip.tripKey DESC   ---- This is steve's requirment to show always recent booking on top of the list           
		--WHERE RowID > (@pageNo-1)*@pageSize AND RowID <= @pageNo*@pageSize  --This condition has been commented since paging is being handled in code            


		INSERT INTO #tbl_vw_TRipCarResponse 
		SELECT trip.tripKey, trip.tripName, trip.userKey, TripCarResponse.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, dbo.TripCarResponse.actualCarPrice
			, dbo.TripCarResponse.actualCarTax, dbo.TripCarResponse.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, dbo.TripCarResponse.carLocationCode, dbo.TripCarResponse.PickUpdate, dbo.TripCarResponse.dropOutDate
			, CarContent.dbo.SippCodes.SippCodeClass, dbo.TripCarResponse.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, CarContent.dbo.SabreVehicles.VehicleName
			, TripCarResponse.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, AV.ALVehicleName
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, NV.ZLVehicleName
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, ZV.ZRVehicleName
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, TV.ZTVEHICLENAME
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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
			siteKey, CreatedDate, tripRequestKey , VehicleCompanyName,  NoofDays, CountryCode, Rating, DiscountFare 
		FROM 
		(
			SELECT ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID ORDER BY SH.AddDate DESC) RN
				, dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
				, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
				, HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
				, HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
				, '' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare   
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
			siteKey, CreatedDate, tripRequestKey , VehicleCompanyName,  NoofDays, CountryCode, Rating, DiscountFare 
		FROM 
		(
			SELECT ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID ORDER BY SH.AddDate DESC) RN
				, dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
				, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
				, HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
				, HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
				, '' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare
			FROM HotelContent.dbo.Hotels AS HT WITH (NOLOCK) 
				INNER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) 
				INNER JOIN dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId 
					AND SH.SupplierFamily = HR.supplierId AND HR.isDeleted = 0 
				INNER JOIN dbo.Trip WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
			WHERE (ISNULL(HR.isDeleted, 0) = 0) 
		) b WHERE b.RN = 1

			                    
		INSERT INTO #tbl_vw_TripDetails_tripaudit 
		SELECT ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder, 'air' AS TYPE, trip.tripKey, trip.tripName
			, u.userFirstName, u.userLastName, u.userKey, 
			trip.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, resp.actualAirPrice AS basecost, resp.actualAirTax AS tax
			, seg.airSegmentMarketingAirlineCode AS vendorcode, 
			vendor.ShortName AS VendorName, seg.airSegmentDepartureAirport, seg.airSegmentArrivalAirport
			, CONVERT(varchar(20), seg.airSegmentFlightNumber) AS flightNumber, 
			seg.airSegmentDepartureDate AS departuredate, seg.airSegmentArrivalDate AS arrivaldate, NULL AS carType
			, CONVERT(varchar(20), seg.airLegNumber) AS Ratingtype, 
			seg.airSegmentKey AS responseKey, seg.recordLocator AS vendorLocator,  Trip.siteKey, trip.createdDate, trip.tripRequestKey 
			, '' As VehicleCompanyName 
			,0 as NoofDays 
			,'' as CityName 
			,'' as StateCode 
			,'' as CountryCode 
			,'' as HotelRating 
			, ISNULL(resp.discountedBaseFare,0) as DiscountFare 
		FROM Trip WITH (NOLOCK) 
			INNER JOIN TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
			INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
			INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
			LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
		WHERE ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   and Trip.tripStatusKey <> 17 

		UNION 

		SELECT ROW_NUMBER() OVER (ORDER BY carresponsekey), 'car' AS TYPE, t.tripKey, t.tripName, u.userFirstName, u.userLastName, u.userKey,
			t.recordLocator, t.endDate, t.startDate, t.tripStatusKey, actualCarPrice, actualCarTax, carVendorKey, 
			carCompanyName, carLocationCode, carLocationCode, NULL, PickUpdate, dropOutDate, 
			SippCodeClass, NULL AS Ratingtype, t .carResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey 
			, VehicleName As VehicleCompanyName 
			,t.NoofDays 
			,'' as CityName 
			,'' as StateCode 
			,'' as CountryCode 
			,'' as HotelRating 
			, 0 as  DiscountFare 
		FROM #tbl_vw_TRipCarResponse t WITH (NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

		UNION 

		SELECT ROW_NUMBER() OVER (ORDER BY hotelresponsekey), 'hotel' AS TYPE, t.tripkey, t.tripName, u.userFirstName, u.userLastName, u.userKey
			, t.recordLocator, t.endDate, t.startDate, t.tripStatusKey, actualHotelPrice, actualHotelTax, ChainCode
			, hotelname, cityname + ',' + StateCode, cityname + ',' + StateCode, NULL, checkindate, checkoutdate
			, NULL, Ratingtype, t .hotelResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey 
			, '' As VehicleCompanyName 
			,0 as NoofDays 
			,t.CityName  
			,t.StateCode 
			,t.CountryCode 
			,t.Rating as HotelRating 
			,0 as DiscountFare 
		FROM #tbl_vw_TripHotelResponse_tripaudit t WITH (NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey


		---  get the Air, car and hotel response detail for filtered trips            
		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,                      
			vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,                 
			vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator          
		FROM #tbl_vw_TripDetails_tripaudit vt WITH(NOLOCK)                       
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey          
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey          
			LEFT OUTER JOIN TripAirResponse TAR WITH (NOLOCK) ON tmp.tripPurchasedKey = TAR.tripGUIDKey   ANd TAR.isDeleted = 0       
			LEFT OUTER JOIN TripCarResponse TCR WITH (NOLOCK) ON tmp.tripPurchasedKey = TCR.tripGUIDKey AND TCR.isDeleted = 0
			LEFT OUTER JOIN TripHotelResponse THR WITH (NOLOCK) ON tmp.tripPurchasedKey = THR.tripGUIDKey AND THR.isDeleted = 0          
			LEFT OUTER JOIN TripAirSegmentOptionalServices OPT WITH (NOLOCK) ON tmp.tripKey = OPT.tripKey AND OPT.isDeleted = 0             
		ORDER BY      -----Implemented sorting          
			case when @sortField = 'Traveler' and @sortDirection ='Descending' then    ltrim(tmp.userFirstName)     End   desc,               
			case when @sortField = 'Traveler' and @sortDirection ='Ascending' then    ltrim(tmp.userFirstName)  End   asc ,              
			case when @sortField = 'TripName' and @sortDirection ='Descending' then    tmp.TripName  End   desc,               
			case when @sortField = 'TripName' and @sortDirection ='Ascending' then    tmp.TripName  End   asc,            
			case when @sortField = 'Depart' and @sortDirection ='Descending' then    tmp.startDate  End   desc,               
			case when @sortField = 'Depart' and @sortDirection ='Ascending' then    tmp.startDate  End   asc,            
			case when @sortField = 'Return' and @sortDirection ='Descending' then    tmp.endDate  End   desc,               
			case when @sortField = 'Return' and @sortDirection ='Ascending' then    tmp.endDate  End   asc,            
			case when @sortField = 'Status' and @sortDirection ='Descending' then     S.tripStatusName  End   desc,               
			case when @sortField = 'Status' and @sortDirection ='Ascending' then     S.tripStatusName  End   asc,            
			case when @sortField = 'Amount' and @sortDirection ='Descending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   desc,               
			case when @sortField = 'Amount' and @sortDirection ='Ascending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   asc          

		SELECT OPT.* 
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK) 
		INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 

	END 
	ELSE IF @PageName = 'grouptrips' 
	BEGIN 

	------------ Altered By Gopal to improve performance and avoid using view ---------------------------
--SELECT GETDATE() AS [1.0] 

		INSERT INTO #tmpTrip 
		SELECT ROW_NUMBER() OVER (ORDER BY  -----Implemented sorting          
			case when @sortField = 'Depart' and @sortDirection ='Descending' then    Trip.startDate  End   desc,               
			case when @sortField = 'Depart' and @sortDirection ='Ascending' then    Trip.startDate  End   asc,            
			case when @sortField = 'Return' and @sortDirection ='Descending' then    Trip.endDate  End   desc,               
			case when @sortField = 'Return' and @sortDirection ='Ascending' then    Trip.endDate  End   asc,            
			case when @sortField = 'Status' and @sortDirection ='Descending' then     S.tripStatusName  End   desc,               
			case when @sortField = 'Status' and @sortDirection ='Ascending' then     S.tripStatusName  End   asc,            
			case when @sortField = 'Amount' and @sortDirection ='Descending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   desc,               
			case when @sortField = 'Amount' and @sortDirection ='Ascending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   asc),             
			Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate,          
			Trip.endDate, Trip.tripStatusKey, Trip.agencyKey,                         
			U.userFirstName, U.userLastName, U.userLogin , trip.tripPurchasedKey, trip.GroupKey,GRP.groupName, trip.CreatedDate 
		FROM trip WITH(NOLOCK)               
			INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey 
				AND Trip.tripStatusKey <> 10    AND Trip.tripStatusKey <> 17 
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey 
			LEFT OUTER JOIN vault..[Group] GRP ON Trip.GroupKey = GRP.groupKey
			LEFT OUTER JOIN TripAirResponse TAR WITH (NOLOCK) ON trip.tripPurchasedKey = TAR.tripGUIDKey AND TAR.isDeleted = 0 
			LEFT OUTER JOIN TripCarResponse TCR WITH (NOLOCK) ON trip.tripPurchasedKey = TCR.tripGUIDKey  And TCR.isDeleted = 0 
			LEFT OUTER JOIN TripHotelResponse THR WITH (NOLOCK) ON trip.tripPurchasedKey = THR.tripGUIDKey AND THR.isDeleted = 0 
			LEFT OUTER JOIN TripAirSegmentOptionalServices OPT WITH (NOLOCK) ON trip.tripKey = OPT.tripKey AND OPT.isDeleted = 0 
		WHERE Trip.tripKey = CASE WHEN @tripKey = 0 THEN Trip.tripKey ELSE @tripKey END 
			AND Trip.startDate between @fromDate and @toDate 
			--AND dbo.IsTripStatusAsPerType(ISNULL(@status,Trip.tripStatusKey),@PageName) = 1 
			AND Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> '' AND 
			Trip.endDate >= GETDATE() AND Trip.tripStatusKey = ISNULL(@status,Trip.tripStatusKey) 
			AND Trip.siteKey = CASE WHEN @siteKey IS NULL THEN Trip.siteKey ELSE @siteKey END  --Added for TFS 861 
			AND trip.GroupKey = @groupKey
			AND trip.userKey = ISNULL(@userkey, trip.userKey)
             
--SELECT 'DELETE_This' new, * FROM #tmpTrip
          
		SELECT @totalRecords = COUNT(*) FROM #tmpTrip     ---get total records count in output parameter            

		SELECT DISTINCT trip.tripKey, trip.TripRequestKey, tripName, trip.userKey, recordLocator, TR.tripFromDate1 startDate, TR.tripToDate1 endDate,                      
			tripStatusKey, agencyKey, userFirstName, userLastName, userLogin, groupKey,groupName, CreatedDate             
		FROM #tmpTrip trip 
			INNER JOIN TripRequest TR ON trip.TripRequestKey = TR.tripRequestKey 
		ORDER BY Trip.tripKey DESC   ---- This is steve's requirment to show always recent booking on top of the list 
  
--SELECT GETDATE() AS [1.3] 

--SELECT GETDATE() AS [1.8] 

		INSERT INTO #tbl_vw_TRipCarResponse 
		SELECT trip.tripKey, trip.tripName, trip.userKey, TripCarResponse.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, dbo.TripCarResponse.actualCarPrice
			, dbo.TripCarResponse.actualCarTax, dbo.TripCarResponse.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, dbo.TripCarResponse.carLocationCode, dbo.TripCarResponse.PickUpdate, dbo.TripCarResponse.dropOutDate
			, CarContent.dbo.SippCodes.SippCodeClass, dbo.TripCarResponse.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, CarContent.dbo.SabreVehicles.VehicleName
			, TripCarResponse.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
		FROM CarContent.dbo.CarCompanies WITH (NOLOCK) 
			INNER JOIN dbo.TripCarResponse WITH (NOLOCK) 
			INNER JOIN CarContent.dbo.SippCodes WITH (NOLOCK) ON dbo.TripCarResponse.carCategoryCode = CarContent.dbo.SippCodes.SippCodeCarType ON 
				CarContent.dbo.CarCompanies.CarCompanyCode = dbo.TripCarResponse.carVendorKey AND TripCarResponse.isDeleted = 0
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, AV.ALVehicleName
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, NV.ZLVehicleName
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, ZV.ZRVehicleName
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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

		SELECT trip.tripKey, trip.tripName, trip.userKey, TR.recordLocator
			, trip.endDate, trip.startDate, trip.tripStatusKey, TR.actualCarPrice
			, TR.actualCarTax, TR.carVendorKey, CarContent.dbo.CarCompanies.CarCompanyName
			, TR.carLocationCode, TR.PickUpdate, TR.dropOutDate
			, S.VehicleClass AS SippCodeClass, TR.carResponseKey
			, Trip.siteKey, trip.createdDate, trip.tripRequestKey, TV.ZTVEHICLENAME
			, TR.NoOfDays, '' As CityName, '' AS StateCode, '' AS CountryCode
			, '' As HotelRating, 0 AS DiscountFare
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
			siteKey, CreatedDate, tripRequestKey , VehicleCompanyName,  NoofDays, CountryCode, Rating, DiscountFare 
		FROM 
		(
			SELECT ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID ORDER BY SH.AddDate DESC) RN
				, dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
				, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
				, HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
				, HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
				, '' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare   
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
			siteKey, CreatedDate, tripRequestKey , VehicleCompanyName,  NoofDays, CountryCode, Rating, DiscountFare 
		FROM 
		(
			SELECT ROW_NUMBER() OVER(PARTITION BY SH.SupplierHotelID ORDER BY SH.AddDate DESC) RN
				, dbo.Trip.tripKey, dbo.Trip.tripName, dbo.Trip.userKey, HR.recordLocator
				, dbo.Trip.endDate, dbo.Trip.startDate, dbo.Trip.tripStatusKey, HR.actualHotelPrice, HR.actualHotelTax
				, HT.ChainCode, HT.HotelName, HT.CityName, HT.StateCode, HR.checkInDate, HR.checkOutDate, HT.RatingType
				, HR.hotelResponseKey, dbo.Trip.siteKey, dbo.Trip.CreatedDate, dbo.Trip.tripRequestKey
				, '' As VehicleCompanyName, 0 as NoofDays, HT.CountryCode, ISNULL(HT.Rating, 0) AS Rating, 0 as DiscountFare
			FROM HotelContent.dbo.Hotels AS HT WITH (NOLOCK) 
				INNER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK) 
				INNER JOIN dbo.TripHotelResponse AS HR WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey ON HT.HotelId = SH.HotelId 
					AND SH.SupplierFamily = HR.supplierId AND HR.isDeleted = 0 
				INNER JOIN dbo.Trip WITH (NOLOCK) ON HR.tripGUIDKey = dbo.Trip.tripPurchasedKey AND (hr.tripKey IS NULL OR hr.tripKey = 0) 
				INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
			WHERE (ISNULL(HR.isDeleted, 0) = 0) 
		) b WHERE b.RN = 1 
		
--SELECT 'DELETE_This' new, * FROM #tbl_vw_TripHotelResponse_tripaudit 
		
		INSERT INTO #tbl_vw_TripDetails_tripaudit 
		SELECT ROW_NUMBER() OVER (ORDER BY tripAirsegmentkey) segmentOrder, 'air' AS TYPE, trip.tripKey, trip.tripName
			, u.userFirstName, u.userLastName, u.userKey, 
			trip.recordLocator, trip.endDate, trip.startDate, trip.tripStatusKey, resp.actualAirPrice AS basecost, resp.actualAirTax AS tax
			, seg.airSegmentMarketingAirlineCode AS vendorcode, 
			vendor.ShortName AS VendorName, seg.airSegmentDepartureAirport, seg.airSegmentArrivalAirport
			, CONVERT(varchar(20), seg.airSegmentFlightNumber) AS flightNumber, 
			seg.airSegmentDepartureDate AS departuredate, seg.airSegmentArrivalDate AS arrivaldate, NULL AS carType
			, CONVERT(varchar(20), seg.airLegNumber) AS Ratingtype, 
			seg.airSegmentKey AS responseKey, seg.recordLocator AS vendorLocator,  Trip.siteKey, trip.createdDate, trip.tripRequestKey 
			, '' As VehicleCompanyName 
			,0 as NoofDays 
			,'' as CityName 
			,'' as StateCode 
			,'' as CountryCode 
			,'' as HotelRating 
			, ISNULL(resp.discountedBaseFare,0) as DiscountFare 
		FROM Trip WITH (NOLOCK) 
			INNER JOIN TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
			INNER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
			INNER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
			LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON trip.userKey = u.userKey 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = Trip.tripKey 
		WHERE ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   and Trip.tripStatusKey <> 17 

		UNION 

		SELECT ROW_NUMBER() OVER (ORDER BY carresponsekey), 'car' AS TYPE, t.tripKey, t.tripName, u.userFirstName, u.userLastName, u.userKey,
			t.recordLocator, t.endDate, t.startDate, t.tripStatusKey, actualCarPrice, actualCarTax, carVendorKey, 
			carCompanyName, carLocationCode, carLocationCode, NULL, PickUpdate, dropOutDate, 
			SippCodeClass, NULL AS Ratingtype, t .carResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey 
			, VehicleName As VehicleCompanyName 
			,t.NoofDays 
			,'' as CityName 
			,'' as StateCode 
			,'' as CountryCode 
			,'' as HotelRating 
			, 0 as  DiscountFare 
		FROM #tbl_vw_TRipCarResponse t WITH (NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey 

		UNION 

		SELECT ROW_NUMBER() OVER (ORDER BY hotelresponsekey), 'hotel' AS TYPE, t.tripkey, t.tripName, u.userFirstName, u.userLastName, u.userKey
			, t.recordLocator, t.endDate, t.startDate, t.tripStatusKey, actualHotelPrice, actualHotelTax, ChainCode
			, hotelname, cityname + ',' + StateCode, cityname + ',' + StateCode, NULL, checkindate, checkoutdate
			, NULL, Ratingtype, t .hotelResponseKey, t .recordLocator, t .siteKey, t .createdDate, t .tripRequestKey 
			, '' As VehicleCompanyName 
			,0 as NoofDays 
			,t.CityName  
			,t.StateCode 
			,t.CountryCode 
			,t.Rating as HotelRating 
			,0 as DiscountFare 
		FROM #tbl_vw_TripHotelResponse_tripaudit t WITH (NOLOCK) 
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = t.tripKey 
			LEFT OUTER JOIN Vault.dbo.[User] u WITH (NOLOCK) ON t .userKey = u.userKey

--SELECT GETDATE() AS [1.9] 
--SELECT * FROM #tmpTrip
--SELECT * FROM #tbl_vw_TripHotelResponse_tripaudit
--SELECT * FROM #tbl_vw_TripDetails_tripaudit

		SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,                      
			vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,                 
			vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator          
		FROM #tbl_vw_TripDetails_tripaudit vt WITH(NOLOCK)                       
			INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey          
			INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey          
			LEFT OUTER JOIN TripAirResponse TAR WITH (NOLOCK) ON tmp.tripPurchasedKey = TAR.tripGUIDKey  AND TAR.isDeleted = 0
			LEFT OUTER JOIN TripCarResponse TCR WITH (NOLOCK) ON tmp.tripPurchasedKey = TCR.tripGUIDKey  AND TCR.isDeleted = 0
			LEFT OUTER JOIN TripHotelResponse THR WITH (NOLOCK) ON tmp.tripPurchasedKey = THR.tripGUIDKey AND THR.isDeleted = 0 
			LEFT OUTER JOIN TripAirSegmentOptionalServices OPT WITH (NOLOCK) ON tmp.tripKey = OPT.tripKey AND OPT.isDeleted = 0 
		--WHERE THR.isDeleted = 0 AND OPT.isDeleted = 0 
		ORDER BY      -----Implemented sorting          
			case when @sortField = 'Traveler' and @sortDirection ='Descending' then    ltrim(tmp.userFirstName)     End   desc,               
			case when @sortField = 'Traveler' and @sortDirection ='Ascending' then    ltrim(tmp.userFirstName)  End   asc ,              
			case when @sortField = 'TripName' and @sortDirection ='Descending' then    tmp.TripName  End   desc,               
			case when @sortField = 'TripName' and @sortDirection ='Ascending' then    tmp.TripName  End   asc,            
			case when @sortField = 'Depart' and @sortDirection ='Descending' then    tmp.startDate  End   desc,               
			case when @sortField = 'Depart' and @sortDirection ='Ascending' then    tmp.startDate  End   asc,            
			case when @sortField = 'Return' and @sortDirection ='Descending' then    tmp.endDate  End   desc,               
			case when @sortField = 'Return' and @sortDirection ='Ascending' then    tmp.endDate  End   asc,            
			case when @sortField = 'Status' and @sortDirection ='Descending' then     S.tripStatusName  End   desc,               
			case when @sortField = 'Status' and @sortDirection ='Ascending' then     S.tripStatusName  End   asc,            
			case when @sortField = 'Amount' and @sortDirection ='Descending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   desc,               
			case when @sortField = 'Amount' and @sortDirection ='Ascending' then    isnull(TAR.actualAirPrice, 0) + isnull(TAR.actualAirTax, 0) + isnull(TCR.actualCarPrice, 0) + isnull(TCR.actualCarTax, 0) + isnull(THR.actualHotelPrice, 0) + isnull(THR.actualHotelTax, 0) + isnull(OPT.serviceAmount, 0)  End   asc          

		SELECT OPT.*                       
		FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK)                       
		INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0           

	----------------------------------------------------------------------------------------------------- 

	END         
                            
                               
    DROP TABLE #tmpTrip                        
    Drop Table #tblUser 
	DROP TABLE #tbl_vw_TRipCarResponse
	DROP TABLE #tbl_vw_TripDetails_tripaudit
	DROP TABLE #tbl_vw_TripHotelResponse_tripaudit

END
GO
