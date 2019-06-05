SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
EXEC [usp_GetFinanceDetailsForBookings] @FromDate = '2015-11-23 00:00:00.000', @ToDate = '2015-11-29 23:59:59.000'
--EXEC [usp_GetFinanceDetailsForBookings] @FromDate = '2015-11-09', @ToDate = '2015-11-15'
EXEC Trip..[usp_GetFinanceDetailsForBookings]  '2016-11-21 00:00:00.000', '2016-11-27 23:59:59.000' 
*/

CREATE PROCEDURE [dbo].[usp_GetFinanceDetailsForBookings_Automated]                          
(                      
	@FromDate DATETIME  ,                        
	@ToDate DATETIME
)                      
AS 
BEGIN                        

	--SELECT @FromDate = '2014-01-25', @ToDate = '2014-01-29'
	--IF OBJECT_ID('tempdb..#FinanceDetails') IS NOT NULL
 --   DROP TABLE #FinanceDetails

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FinanceDetails]') AND type in (N'U'))
	DROP TABLE [dbo].[FinanceDetails]

	CREATE TABLE [FinanceDetails]
	(		
		tripKey				INT,
		IssueDate			DATETIME,
		CreationDate		DATETIME,
		PassengerName		VARCHAR(MAX),
		AirVendor			VARCHAR(4000),
		AirGDS				VARCHAR(20),
		GDSHotelId			VARCHAR(4000),
		HotelName			VARCHAR(500),
		HotelGDS			VARCHAR(20),
		CarVendor			VARCHAR(4000),
		CarGDS				VARCHAR(20),
		TotalFare			FLOAT,
		BaseFare			FLOAT,
		Commission			FLOAT,
		AirDepartureCity	VARCHAR(10),
		AirArrivalCity		VARCHAR(10),
		AirDepartureDate	DATETIME, 
		AirReturnDate		DATETIME,
		HotelCity			VARCHAR(10),
		CarPickupCity		VARCHAR(10),
		CarDropoffCity		VARCHAR(10),
		recordLocator		VARCHAR(20),
		AirTicketNumber		VARCHAR(4000),
		AirItineraryNumber	VARCHAR(4000),
		HotelTicketNumber	VARCHAR(4000),
		HotelItineraryNumber VARCHAR(4000),
		CarTicketNumber		VARCHAR(4000),
		CarItineraryNumber	VARCHAR(4000),
		TravelType			VARCHAR(25),
		Udid				VARCHAR(4000),
		TripRequestKey		INT,
		TripPurchaseKey		UNIQUEIDENTIFIER 
	)

	INSERT INTO [FinanceDetails](tripKey, IssueDate, CreationDate, TotalFare, BaseFare, TripRequestKey
		, TravelType, TripPurchaseKey, PassengerName, Udid, recordLocator)
	SELECT tripKey,  IssueDate, CreatedDate, triptotalbasecost+triptotaltaxcost, triptotalbasecost, TripRequestKey,
		CASE WHEN TripComponentType = 1 THEN 'Air' 
			WHEN TripComponentType = 2 THEN 'Car' 
			WHEN TripComponentType = 4 THEN 'Hotel' 
			WHEN TripComponentType = 3 THEN 'Air,Car' 
			WHEN TripComponentType = 5 THEN 'Air,Hotel' 
			WHEN TripComponentType = 6 THEN 'Car,Hotel' 
			WHEN TripComponentType = 7 THEN 'Air,Car,Hotel' 
		END TravelType
		, TripPurchasedKey, [dbo].[fn_PassengerCSV](tripKey, 'Pass'), [dbo].[fn_PassengerCSV](tripKey, 'UDID'), RecordLocator
	FROM Trip WITH(NOLOCK)
	WHERE CreatedDate BETWEEN @FromDate AND @ToDate
		AND tripPurchasedKey IS NOT NULL
		AND tripStatusKey <> 17

	UPDATE T
	SET T.AirDepartureCity = TR.tripFrom1, 
		T.AirArrivalCity = TR.tripTo1, 
		T.AirDepartureDate = Tr.tripFromDate1, 
		T.AirReturnDate = CASE WHEN AR.airRequestTypeKey = 1 THEN NULL ELSE TR.tripToDate1 END
	FROM [FinanceDetails] T
		INNER JOIN TripRequest TR ON TR.tripRequestKey = T.tripRequestKey
		LEFT OUTER JOIN TripRequest_air TRA ON TRA.tripRequestKey = TR.tripRequestKey 
		LEFT OUTER JOIN AirRequest AR ON TRA.airRequestKey = AR.airRequestKey 

	UPDATE T
	SET AirVendor = segments.airSegmentMarketingAirlineCode,
		AirGDS = G.GDSName
	FROM TripAirSegments  segments  WITH(NOLOCK)                         
	  INNER JOIN TripAirLegs legs  WITH(NOLOCK) on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                           
			and segments .airLegNumber = legs .airLegNumber )                          
	  INNER JOIN TripAirResponse   AirResp  WITH(NOLOCK) on segments .airResponseKey = AirResp .airResponseKey 
	  INNER JOIN [FinanceDetails] T on AirResp.tripGUIDKey  = t.tripPurchaseKey 
	  INNER JOIN Vault.dbo.GDSSourceLookup G WITH(NOLOCK) on G.gdsSourceKey = legs.gdsSourceKey

	UPDATE T 
	SET AirTicketNumber = TP.TicketNumber,
		AirItineraryNumber = TP.InvoiceNumber
	FROM [FinanceDetails] T   
	 INNER JOIN TripAirResponse TR WITH(NOLOCK) ON TR.tripGuidKey = T.tripPurchaseKey
	 INNER JOIN TripAirLegs TL WITH(NOLOCK) ON TL.airResponseKey = TR.airResponseKey
	 INNER JOIN TripAirLegPassengerInfo TP WITH(NOLOCK) ON  TL.tripAirLegsKey = TP.tripAirLegKey
	 INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TPI.TripPassengerInfoKey = TP.TripPassengerInfoKey     	

	UPDATE T
	SET GDSHotelId	= TH.supplierHotelKey,
		HotelName	= TH.HotelName,
		HotelGDS	= GL.GDSName,
		HotelCity	= HR.hotelCityCode,
		TotalFare	= actualHotelPrice * HR.NoofRooms,
		BaseFare	= (actualHotelPrice - actualHotelTax) * HR.NoofRooms,
		Commission	= (CASE WHEN GL.GDSName = 'Tourico' THEN ((TH.HotelTotalPrice * HR.NoofRooms) - (TH.OriginalHotelTotalPrice * HR.NoofRooms)) ELSE 0 END )
	FROM [FinanceDetails] T 
		INNER JOIN vw_TripHotelResponseDetails TH WITH(NOLOCK) ON TH.tripGUIDKey = T.tripPurchaseKey  
		INNER JOIN vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TH.SupplierId          
		INNER JOIN TripRequest_Hotel TR ON TR.tripRequestKey = T.tripRequestKey
		INNER JOIN HotelRequest HR ON HR.HotelRequestKey = TR.HotelRequestKey


	UPDATE T
	SET HotelTicketNumber   = THP.ConfirmationNumber ,
		HotelItineraryNumber = THP.ItineraryNumber
	FROM TripHotelResponsePassengerInfo THP
		INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TPI.TripPassengerInfoKey = THP.TripPassengerInfoKey          
		INNER JOIN TripHotelResponse TH WITH(NOLOCK) ON TH.hotelResponseKey = THP.hotelResponseKey          
		INNER JOIN [FinanceDetails] T ON TH.tripGUIDKey = T.tripPurchaseKey  
	 
	 UPDATE  T
	 SET CarVendor = TC.CarVendorKey, 
		CarGDS = TC.SupplierId, 
		CarPickupCity = CR.pickupCityCode, 
		CarDropOffCity = CR.dropoffCityCode,
		CarTicketNumber = TC.confirmationNumber,
		CarItineraryNumber = TC.InvoiceNumber
	From [FinanceDetails] T 
		INNER JOIN vw_TripCarResponseDetails TC WITH(NOLOCK) ON TC.tripGUIDKey = T.tripPurchaseKey  
		Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TC.SupplierId                        
		INNER JOIN TripRequest_Car TR ON TR.tripRequestKey = T.tripRequestKey
		INNER JOIN CarRequest CR ON CR.CarRequestKey = TR.CarRequestKey

	--Select * From @tblTrip 

-------------------------------------- Automation Part started here --------------------------------------------------------------------

	DECLARE @xmlFinance NVARCHAR(MAX)
	DECLARE @bodyFinance NVARCHAR(MAX)

	SET @xmlFinance = CAST(( 
				SELECT tripKey AS 'td',''
				,ISNULL(IssueDate, '') AS 'td',''
				,ISNULL(CreationDate, '') AS 'td',''
				,ISNULL(PassengerName, 'NULL') AS 'td',''
				,ISNULL(AirVendor, 'NULL') AS 'td',''
				,ISNULL(AirGDS, 'NULL') AS 'td',''
				,ISNULL(GDSHotelId, 0) AS 'td',''
				,ISNULL(HotelName, 'NULL') AS 'td',''
				,ISNULL(HotelGDS, 'NULL') AS 'td',''
				,ISNULL(CarVendor, 'NULL') AS 'td',''
				,ISNULL(CarGDS, 'NULL') AS 'td',''
				,ISNULL(TotalFare, 0) AS 'td',''
				,ISNULL(BaseFare, 0) AS 'td',''
				,ISNULL(Commission, 0) AS 'td',''
				,ISNULL(AirDepartureCity, '') AS 'td',''
				,ISNULL(AirArrivalCity, '') AS 'td',''
				,ISNULL(AirDepartureDate, '') AS 'td',''
				,ISNULL(AirReturnDate, '') AS 'td',''
				,ISNULL(HotelCity, '') AS 'td',''
				,ISNULL(CarPickupCity, '') AS 'td',''
				,ISNULL(CarDropoffCity, '') AS 'td',''
				,ISNULL(recordLocator, '') AS 'td',''
				,ISNULL(AirTicketNumber, '') AS 'td',''
				,ISNULL(AirItineraryNumber, '') AS 'td',''
				,ISNULL(HotelTicketNumber, '') AS 'td',''
				,ISNULL(HotelItineraryNumber, '') AS 'td',''
				,ISNULL(CarTicketNumber, '') AS 'td',''
				,ISNULL(CarItineraryNumber, '') AS 'td',''
				,ISNULL(TravelType, '') AS 'td',''
				,ISNULL(Udid, '') AS 'td',''
				,ISNULL(TripRequestKey, 0) AS 'td',''
				,TripPurchaseKey AS 'td',''
	FROM  [FinanceDetails] 
	FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

	SET @bodyFinance = '<html><body><H3>Automated Finance Report</H3>
					<table border = 1> 
						<tr>
							<th> tripKey </th>
							<th> IssueDate </th> 
							<th> CreationDate </th> 
							<th> PassengerName </th> 
							<th> AirVendor </th> 
							<th> AirGDS </th> 
							<th> GDSHotelId </th> 
							<th> HotelName </th> 
							<th> HotelGDS </th> 
							<th> CarVendor </th> 
							<th> CarGDS </th> 
							<th> TotalFare </th> 
							<th> BaseFare </th> 
							<th> Commission </th> 
							<th> AirDepartureCity </th> 
							<th> AirArrivalCity </th> 
							<th> AirDepartureDate </th> 
							<th> AirReturnDate </th> 
							<th> HotelCity </th> 
							<th> CarPickupCity </th> 
							<th> CarDropoffCity </th> 
							<th> recordLocator </th> 
							<th> AirTicketNumber </th> 
							<th> AirItineraryNumber </th> 
							<th> HotelTicketNumber </th> 
							<th> HotelItineraryNumber </th> 
							<th> CarTicketNumber </th> 
							<th> CarItineraryNumber </th> 
							<th> TravelType </th> 
							<th> Udid </th> 
							<th> TripRequestKey </th> 
							<th> TripPurchaseKey </th> 
						</tr>'

	SET @bodyFinance = @bodyFinance + @xmlFinance + '</table></body></html>'

--PRINT @body

	--EXEC msdb.dbo.sp_send_dbmail
	--	@profile_name = 'GKProfile', -- replace with your SQL Database Mail Profile 
	--	@body = @body,
	--	@body_format ='HTML',
	--	@recipients = 'ngopal@rinira.com', -- replace with your email address
	--	@subject = 'Finance Report - Automated' ;


       
END
GO
