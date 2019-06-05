SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
EXEC [usp_GetFinanceDetailsForBookings] @FromDate = '2014-01-25', @ToDate = '2014-01-29'
*/

CREATE PROCEDURE [dbo].[usp_GetFinanceDetailsForBookings]                          
(                      
	@FromDate DATETIME  ,                        
	@ToDate DATETIME
)                      
AS 
BEGIN                        

	--SELECT @FromDate = '2014-01-25', @ToDate = '2014-01-29'

	DECLARE @tblTrip AS TABLE
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

	INSERT INTO @tblTrip(tripKey,IssueDate,CreationDate,TotalFare,BaseFare, TripRequestKey, TravelType, TripPurchaseKey, PassengerName, Udid, recordLocator)
	SELECT tripKey,  IssueDate, CreatedDate, triptotalbasecost+triptotaltaxcost, triptotalbasecost, TripRequestKey,
		CASE WHEN PurchaseComponentType = 1 THEN 'Air' 
			WHEN PurchaseComponentType = 2 THEN 'Car' 
			WHEN PurchaseComponentType = 4 THEN 'Hotel' 
			WHEN PurchaseComponentType = 3 THEN 'Air,Car' 
			WHEN PurchaseComponentType = 5 THEN 'Air,Hotel' 
			WHEN PurchaseComponentType = 6 THEN 'Car,Hotel' 
			WHEN PurchaseComponentType = 7 THEN 'Air,Car,Hotel' 
		END, TripPurchasedKey, [dbo].[fn_PassengerCSV](tripKey, 'Pass'), [dbo].[fn_PassengerCSV](tripKey, 'UDID'), RecordLocator
	FROM Trip WITH(NOLOCK)
	WHERE CreatedDate BETWEEN @FromDate AND @ToDate
		AND tripPurchasedKey IS NOT NULL
		AND tripStatusKey <> 17

	UPDATE T
		SET T.AirDepartureCity = TR.tripFrom1, 
			T.AirArrivalCity = TR.tripTo1, 
			T.AirDepartureDate = Tr.tripFromDate1, 
			T.AirReturnDate = TR.tripToDate1
	FROM @tblTrip T
		INNER JOIN TripRequest TR ON TR.tripRequestKey = T.tripRequestKey

	UPDATE T
		SET AirVendor = segments.airSegmentMarketingAirlineCode,
			AirGDS = G.GDSName
	FROM TripAirSegments  segments  WITH(NOLOCK)                         
	  INNER JOIN TripAirLegs legs  WITH(NOLOCK) on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                           
			and segments .airLegNumber = legs .airLegNumber )                          
	  INNER JOIN TripAirResponse   AirResp  WITH(NOLOCK) on segments .airResponseKey = AirResp .airResponseKey 
	  INNER JOIN @tblTrip T on AirResp.tripGUIDKey  = t.tripPurchaseKey 
	  INNER JOIN Vault.dbo.GDSSourceLookup G WITH(NOLOCK) on G.gdsSourceKey = legs.gdsSourceKey

	UPDATE T 
		SET AirTicketNumber = TP.TicketNumber,
		AirItineraryNumber = TP.InvoiceNumber
	FROM @tblTrip T   
	 INNER JOIN TripAirResponse TR WITH(NOLOCK) ON TR.tripGuidKey = T.tripPurchaseKey
	 INNER JOIN TripAirLegs TL WITH(NOLOCK) ON TL.airResponseKey = TR.airResponseKey
	 INNER JOIN TripAirLegPassengerInfo TP WITH(NOLOCK) ON  TL.tripAirLegsKey = TP.tripAirLegKey
	 INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TPI.TripPassengerInfoKey = TP.TripPassengerInfoKey     	

	UPDATE T
		SET GDSHotelId	= TH.supplierHotelKey,
			HotelName	= TH.HotelName,
			HotelGDS	= GL.GDSName,
			HotelCity	= HR.hotelCityCode,
			Commission	= (CASE WHEN GL.GDSName = 'Tourico' THEN ((TH.HotelTotalPrice * HR.NoofRooms) - (TH.OriginalHotelTotalPrice * HR.NoofRooms)) ELSE 0 END )
	FROM @tblTrip T 
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
	 INNER JOIN @tblTrip T ON TH.tripGUIDKey = T.tripPurchaseKey  
	 
	 UPDATE  T
	 Set CarVendor = TC.CarVendorKey, 
		CarGDS = TC.SupplierId, 
		CarPickupCity = CR.pickupCityCode, 
		CarDropOffCity = CR.dropoffCityCode,
		CarTicketNumber = TC.confirmationNumber,
		CarItineraryNumber = TC.InvoiceNumber
	From @tblTrip T 
	 INNER JOIN vw_TripCarResponseDetails TC WITH(NOLOCK) ON TC.tripGUIDKey = T.tripPurchaseKey  
	 Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TC.SupplierId                        
	INNER JOIN TripRequest_Car TR ON TR.tripRequestKey = T.tripRequestKey
	INNER JOIN CarRequest CR ON CR.CarRequestKey = TR.CarRequestKey

	Select * From @tblTrip 

       
END
                       
--DECLARE @tblTrip as table                        
--(                        
-- tripKey int,                        
-- RequestKey int,            
-- statusKey int                        
--)                        
                       
--INSERT INTO @tblTrip                        
--SELECT		tripKey, tripRequestKey, tripStatusKey  
--FROM		Trip WITH(NOLOCK) 
--WHERE		CreatedDate BETWEEN @FromDate AND @ToDate 
--AND			tripPurchasedKey IS NOT NULL 
--AND			tripStatusKey <>17  
----AND tt.statusKey = 12  (only exchange)       
          
--select 
--Trip.IssueDate,Trip.CreatedDate,
--TR.tripFrom1, TR.tripTo1,TR.tripFromDate1, TR.tripToDate1,* 
--FROM Trip                         
--INNER JOIN @tblTrip T on T.tripKey = Trip.tripKey
--INNER JOIN TripRequest TR ON TR.tripRequestKey = Trip.tripRequestKey

--SELECT          
--DISTINCT T.tripKey ,                        
--segments.tripAirSegmentKey,                  
--segments.airSegmentKey,                  
--segments.tripAirLegsKey,                  
--segments.airResponseKey,                  
--segments.airLegNumber,                  
--segments.airSegmentMarketingAirlineCode,                  
--segments.airSegmentOperatingAirlineCode,                  
--segments.airSegmentFlightNumber,                  
--segments.airSegmentDepartureDate,                  
--segments.airSegmentArrivalDate,                  
--segments.airSegmentDepartureAirport,                  
--segments.airSegmentArrivalAirport,                  
--segments.airSegmentResBookDesigCode,                  
--segments.ticketNumber,                  
--segments.airsegmentcabin,                  
--segments.recordLocator as SegRecordLocator,                     
--segments.airSegmentOperatingAirlineCompanyShortName    
--,legs.gdsSourceKey ,                          
--departureAirport.AirportName  as departureAirportName ,                          
--departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode                           
--,departureAirport.CountryCode as departureAirportCountryCode,                          
--arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,                          
--arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,                          
--legs.recordLocator , AirResp.actualAirPrice ,  AirResp.actualAirTax ,AirResp.airResponseKey ,ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode )                          
--as MarketingAirLine,airSegmentOperatingAirlineCode  ,  AirResp.CurrencyCodeKey as CurrencyCode,                        
--ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirLine,                          
--isnull(airSelectedSeatNumber,0)  as SeatNumber  , segments.ticketNumber as TicketNumber ,segments.airsegmentcabin as airsegmentcabin    ,AirResp.isExpenseAdded,                      
--ISNULL(t.deniedReason,'') as deniedReason, t.CreatedDate       , segments.airSegmentOperatingFlightNumber ,airresp.bookingcharges                  
--,ISNULL(seatMapStatus,'') AS seatMapStatus, AirResp.ValidatingCarrier,              
-- G.AgentURL     , AirResp.tripGUIDKey ,segments.RPH
-- ,segments.ArrivalTerminal,segments.DepartureTerminal      , G.GDSName
-- from TripAirSegments  segments  WITH(NOLOCK)                         
--  inner join TripAirLegs legs  WITH(NOLOCK)                         
--   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                           
--   and segments .airLegNumber = legs .airLegNumber )                          
--  inner join TripAirResponse   AirResp  WITH(NOLOCK)                         
--   on segments .airResponseKey = AirResp .airResponseKey                            
--  inner join Trip t WITH(NOLOCK) on AirResp.tripGUIDKey  = t.tripPurchasedKey                         
--Inner join @tblTrip tt on tt.tripKey = t.tripKey                         
--  left outer join AirVendorLookup airVen  WITH(NOLOCK)                         
--   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                           
--  left outer join AirVendorLookup airOperatingVen  WITH(NOLOCK)                          
--   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                           
--  left outer join AirportLookup departureAirport WITH(NOLOCK)                           
--   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                           
-- left outer join AirportLookup arrivalAirport WITH(NOLOCK)                          
--   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                           
--  inner join Vault.dbo.GDSSourceLookup G WITH(NOLOCK) on G.gdsSourceKey = legs.gdsSourceKey            
-- WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0  
-- AND ISNULL (AirResp.ISDELETED ,0) = 0                                    
-- ORDER BY T.tripKey ,segments.tripAirSegmentKey , segments .airSegmentDepartureDate                           
 
--/* trip Air pax info */          
--SELECT TP.*, TPI.* FROM
-- Trip T WITH(NOLOCK) 
-- INNER JOIN @tblTrip Tbl on T.tripKey = tbl.tripKey  
-- INNER JOIN TripAirResponse TR WITH(NOLOCK) ON TR.tripGuidKey = T.tripPurchasedKey
-- INNER JOIN TripAirLegs TL WITH(NOLOCK) ON TL.airResponseKey = TR.airResponseKey
-- INNER JOIN TripAirLegPassengerInfo TP WITH(NOLOCK) ON  TL.tripAirLegsKey = TP.tripAirLegKey
-- INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TPI.TripPassengerInfoKey = TP.TripPassengerInfoKey          
 
--select TH. HotelId, TH.SupplierId,TH.SupplierHotelKey, 
--(CASE WHEN GL.GDSName = 'Tourico' THEN ((TH.HotelTotalPrice * HR.NoofRooms) - (TH.OriginalHotelTotalPrice * HR.NoofRooms)) ELSE 0 END ) AS Commission,
--HR.hotelCityCode as HotelItinerary,Trip.*,
--TH.* 
--FROM Trip                         
--INNER JOIN @tblTrip T on T.tripKey = Trip.tripKey
--INNER JOIN vw_TripHotelResponseDetails TH WITH(NOLOCK) ON TH.tripGUIDKey = Trip.tripPurchasedKey  
--INNER JOIN vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TH.SupplierId          
--INNER JOIN TripRequest_Hotel TR ON TR.tripRequestKey = Trip.tripRequestKey
--INNER JOIN HotelRequest HR ON HR.HotelRequestKey = TR.HotelRequestKey

--/* trip hotel pax info */          
-- SELECT THP.* 
-- FROM TripHotelResponsePassengerInfo THP WITH(NOLOCK)          
-- INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TPI.TripPassengerInfoKey = THP.TripPassengerInfoKey          
-- INNER JOIN TripHotelResponse TH WITH(NOLOCK) ON TH.hotelResponseKey = THP.hotelResponseKey          
-- INNER JOIN Trip T WITH(NOLOCK) ON TH.tripGUIDKey = T.tripPurchasedKey  
-- INNER JOIN @tblTrip Tbl on T.tripKey = tbl.tripKey  
 
-- SELECT TC.CarVendorKey, TC.SupplierId, CR.pickupCityCode, CR.dropoffCityCode,
-- TC.* 
-- FROM Trip                         
-- INNER JOIN @tblTrip T on T.tripKey = Trip.tripKey
-- INNER JOIN vw_TripCarResponseDetails TC WITH(NOLOCK) ON TC.tripGUIDKey = Trip.tripPurchasedKey  
-- Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TC.SupplierId                        
--INNER JOIN TripRequest_Car TR ON TR.tripRequestKey = Trip.tripRequestKey
--INNER JOIN CarRequest CR ON CR.CarRequestKey = TR.CarRequestKey
   
         
----Passenger Info
--select TPI.* from TripPassengerInfo TPI WITH(NOLOCK)                         
--  Inner join @tblTrip tt on tt.tripKey = TPI.tripKey                          
--  WHERE    TPI.Active = 1                   
             
          
--/*Udid Info*/                  
--select TCVP.* from TripPassengerInfo TPI   WITH(NOLOCK)                  
--  INNER JOIN  TripPassengerUDIDInfo TCVP WITH(NOLOCK) ON TCVP.TripKey = TPI.TripKey                       
--   Inner join @tblTrip tt   on tt.tripKey = TPI.tripKey                  
--  WHERE   TCVP.Active=1                  
--  order by TPI.TripKey                    
                  
--    /***tripairleg pax info****/            
-- SELECT TLP.* ,TLA.tripAirLegsKey FROM TripAirLegPassengerInfo  TLP  WITH(NOLOCK) inner join              
-- TripAirLegs  TLA WITH(NOLOCK) ON Tlp.tripAirLegKey = TLA.tripAirLegsKey inner join              
--   TripAirResponse TA  WITH(NOLOCK) ON TLA.airResponseKey= TA.airResponseKey             
-- inner join Trip T WITH(NOLOCK) ON TA.tripGUIDKey = t.tripPurchasedKey 
-- inner join @tblTrip Tbl on t.tripKey = tbl.tripKey 
-- Where TLA.isDeleted = 0    
     
    
--END            


--GO
GO
