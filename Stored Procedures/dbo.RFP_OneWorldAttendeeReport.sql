SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RFP_OneWorldAttendeeReport] -- 940, '', Select convert(datetime,'01-01-1753 00:00:00'), convert(datetime,'31-12-9999 00:00:00'),0, 39                    
(                        
 @userKey int,                    
 @currency varchar(5),                    
 @meetingCode int,                      
 @filter varchar(10),                    
 @tripStartDate datetime,             
 @tripEndDate datetime,                      
 @arrivals int,                
 @SiteKey int                   
)                        
AS                        
BEGIN    

	DECLARE @tmpOneWayRoundTrip AS TABLE (tripKey int, airResponseKey UNIQUEIDENTIFIER, airLegNumber INT, airSegmentDepartureDate DATETIME
		, airSegmentDepartureTime NVARCHAR(20), airSegmentArrDate DATETIME, airSegmentArrTime NVARCHAR(20), OutboundFlightNumber NVARCHAR(1000)
		, InboundFlightNumber NVARCHAR(1000), TripFrom1 NVARCHAR(1000),TripTo1 NVARCHAR(1000), RN_MAX INT, RN_ArrMAX INT, recordLocator NVARCHAR(50),
		AirSegmentMarketingAirlineCode VARCHAR(2))

	DECLARE @tmpMultyArrDate AS TABLE (tripKey int, airResponseKey UNIQUEIDENTIFIER, RN INT, airSegmentDepartureDate DATETIME
		, airSegmentDepartureTime NVARCHAR(20), airSegmentArrDate DATETIME, airSegmentArrTime NVARCHAR(20), OutboundFlightNumber NVARCHAR(1000)
		, InboundFlightNumber NVARCHAR(1000), TripFrom1 NVARCHAR(1000),TripTo1 NVARCHAR(1000), RN_MAX INT
		, AirSegmentMarketingAirlineCode VARCHAR(2), recordLocator NVARCHAR(50))

	DECLARE @tmp AS TABLE 
	(
		tripKey int, tripAirSegmentKey INT, airResponseKey UNIQUEIDENTIFIER, airLegNumber INT, RN INT, airSegmentDepartureDate DATETIME, airSegmentArrivalDate DATETIME, 
		airSegmentDepartureAirport VARCHAR(3), airSegmentArrivalAirport VARCHAR(3), airRequestTypeKey INT, RN_MAX INT, 
		AirSegmentMarketingAirlineCode VARCHAR(2), airSegmentFlightNumber INT, recordLocator NVARCHAR(50), tripPurchasedKey UNIQUEIDENTIFIER, 
		meetingCodeKey NVARCHAR(50)
	)

	DECLARE @Results VARCHAR(MAX),  @TripDest VARCHAR (MAX)
	DECLARE @tblTripDest AS TABLE 
	(
		AirportCode VARCHAR(3)
	)

--PRINT '1' + GETDATE()

	INSERT INTO @tmp (tripKey, recordLocator, tripPurchasedKey, meetingCodeKey, tripAirSegmentKey, airResponseKey, airLegNumber, RN
		, airSegmentDepartureDate, airSegmentArrivalDate, airSegmentDepartureAirport, airSegmentArrivalAirport, AirSegmentMarketingAirlineCode
		, airSegmentFlightNumber, airRequestTypeKey)
	SELECT T.TripKey, T.recordLocator, T.tripPurchasedKey, T.meetingCodeKey, TAS.tripAirSegmentKey, TAS.airResponseKey, TAS.airLegNumber
		, ROW_NUMBER() OVER (PARTITION BY TAS.airResponseKey ORDER BY tripAirSegmentKey) rn, TAS.airSegmentDepartureDate, TAS.airSegmentArrivalDate
		, TAS.airSegmentDepartureAirport, TAS.airSegmentArrivalAirport, AirSegmentMarketingAirlineCode, airSegmentFlightNumber, AR.airRequestTypeKey 
	FROM TripAirSegments TAS
		INNER JOIN TripAirLegs legs ON (TAS.tripAirLegsKey = legs.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
			AND TAS.airLegNumber = legs.airLegNumber)
		INNER JOIN TripAirResponse TAR ON TAS.airResponseKey = TAR.airResponseKey 
		INNER JOIN Trip T ON TAR.tripGUIDKey = T.tripPurchasedKey
		INNER JOIN Vault.dbo.Meeting M on T.meetingCodeKey = M.meetingCode and M.meetingCodeKey = @meetingCode 
		INNER JOIN TripRequest_air TRA ON T.tripRequestKey = TRA.tripRequestKey 
		INNER JOIN AirRequest AR ON TRA.airRequestKey = AR.airRequestKey 
	WHERE T.tripStatusKey in (2,12,3) and M.siteKey = @SiteKey and T.siteKey = @SiteKey AND ISNULL(TAS.ISDELETED,0) = 0 AND ISNULL(legs.ISDELETED,0) = 0 
			AND airSegmentDepartureDate BETWEEN @tripStartDate AND @tripEndDate AND airSegmentArrivalDate BETWEEN @tripStartDate AND @tripEndDate
			AND AR.airRequestTypeKey < 3
	GROUP BY T.TripKey, T.recordLocator, T.tripPurchasedKey, T.meetingCodeKey, TAS.tripAirSegmentKey, TAS.airResponseKey
		, TAS.airLegNumber, airSegmentDepartureDate, TAS.airSegmentArrivalDate, airSegmentDepartureAirport, airSegmentArrivalAirport
		, AirSegmentMarketingAirlineCode, airSegmentFlightNumber, AR.airRequestTypeKey 	
	ORDER BY tripAirSegmentKey

--PRINT '2' + GETDATE()

	SELECT @TripDest = meetingAirportCd FROM vault..Meeting	WHERE meetingCodeKey = @meetingCode

--PRINT '3' + GETDATE()

	--INSERT INTO @tblTripDest
	--SELECT * FROM ufn_DelimiterToTable(@TripDest, ',')

	DECLARE @Names VARCHAR(8000)  
	SELECT @Names = COALESCE(@Names + ', ', '') + AllAirportCode FROM [dbo].[AllAirportCodeLookup] where  [AirportCode] IN (SELECT * FROM ufn_DelimiterToTable(@TripDest, ','))
	--SELECT @Names

	INSERT INTO @tblTripDest
	SELECT * FROM ufn_DelimiterToTable(@TripDest, ',')
	UNION
	SELECT * FROM ufn_DelimiterToTable(@Names, ',')

--PRINT '4' + GETDATE()

	INSERT INTO @tmpOneWayRoundTrip (tripKey, recordLocator, airResponseKey, airLegNumber, airSegmentDepartureDate, airSegmentDepartureTime)
	SELECT T.tripKey, T.recordLocator, T.airResponseKey, T.airLegNumber, CONVERT(DATE, MAX(T.airSegmentDepartureDate), 103)
		, CONVERT(TIME, MAX(T.airSegmentArrivalDate), 103)
	FROM @tmp T 
	WHERE T.airLegNumber = 1
	GROUP BY T.tripKey, T.recordLocator, T.airResponseKey, T.airLegNumber

--PRINT '5' + GETDATE()

	UPDATE OWR SET AirSegmentMarketingAirlineCode = t.AirSegmentMarketingAirlineCode 
	FROM @tmpOneWayRoundTrip OWR
		INNER JOIN
		(
			SELECT airResponseKey, MIN(tripAirSegmentKey) MinAirSegmentKey, AirSegmentMarketingAirlineCode 
			FROM @tmp 
			GROUP BY airResponseKey, AirSegmentMarketingAirlineCode 
		) t ON OWR.airResponseKey = t.airResponseKey 

	UPDATE OWR SET RN_MAX = t.RN
	FROM @tmpOneWayRoundTrip OWR
		INNER JOIN 
		(
			SELECT airResponseKey, MAX(RN) RN
			FROM @tmp t
			WHERE t.airLegNumber = 1 
			GROUP BY airResponseKey
		)  t ON OWR.airResponseKey = t.airResponseKey

--PRINT '6' + GETDATE()

	UPDATE OWR SET RN_ArrMAX = t.RN
	FROM @tmpOneWayRoundTrip OWR
		INNER JOIN 
		(
			SELECT airResponseKey, MAX(RN) RN
			FROM @tmp t
			WHERE t.airLegNumber = 2 
			GROUP BY airResponseKey
		)  t ON OWR.airResponseKey = t.airResponseKey

--PRINT '7' + GETDATE()

	UPDATE OWR 
	SET OWR.airSegmentArrDate = dt, OWR.airSegmentArrTime = tm
	FROM @tmpOneWayRoundTrip OWR
		INNER JOIN 
		(
			SELECT airResponseKey, CONVERT(DATE, MIN(airSegmentDepartureDate), 103) dt, CONVERT(TIME, MIN(airSegmentDepartureDate), 103) tm 
			FROM @tmp 
			WHERE airLegNumber = 2 GROUP BY airResponseKey 
		) t ON OWR.airResponseKey = t.airResponseKey 
	
--PRINT '8' + GETDATE()
	
	UPDATE OWR
	SET OWR.TripFrom1 = t.TripFrom1 + '-' + tmp.airSegmentArrivalAirport 
	FROM @tmpOneWayRoundTrip OWR
		INNER JOIN 
		(
			SELECT DISTINCT airResponseKey, 
				STUFF(
						(SELECT '-' + airSegmentDepartureAirport
					  FROM @tmp t2
					  WHERE airResponseKey = t1.airResponseKey AND airLegNumber = 1
					  ORDER BY tripAirSegmentKey
					  FOR XML PATH (''))
					  , 1, 1, '')  AS TripFrom1
			FROM @tmpOneWayRoundTrip t1
		) t ON OWR.airResponseKey = t.airResponseKey AND airLegNumber = 1
		INNER JOIN @tmp tmp ON OWR.airResponseKey = tmp.airResponseKey AND tmp.RN = OWR.RN_MAX  
	
--PRINT '9' + GETDATE()

		UPDATE OWR
		SET OWR.TripTo1 = tbl.TripTo1 + '-' + ISNULL(tbl.airSegmentArrivalAirport, 0)
		FROM @tmpOneWayRoundTrip OWR
		INNER JOIN
		(
			SELECT t.airResponseKey, t.TripTo1, tmp.airSegmentArrivalAirport, tmp.RN  
			FROM 
			(
				SELECT DISTINCT t1.airResponseKey, --ISNULL(t1.airSegmentArrivalAirport, 0),
					STUFF(
							(SELECT '-' + ISNULL(t2.airSegmentDepartureAirport, 0)  
						  FROM @tmp t2
						  WHERE airResponseKey = t1.airResponseKey AND t2.airLegNumber = 2
						  ORDER BY tripAirSegmentKey
						  FOR XML PATH (''))
						  , 1, 1, '')  AS TripTo1 --, t1.airSegmentArrivalAirport
				FROM @tmpOneWayRoundTrip t1
			) t 
			INNER JOIN @tmp tmp ON t.airResponseKey = tmp.airResponseKey -- AND tmp.RN = t1.RN_ArrMAX 
		) tbl ON OWR.airResponseKey = tbl.airResponseKey AND OWR.RN_ArrMAX = tbl.RN 		
		
--PRINT '10' + GETDATE()

	UPDATE TMA SET TMA.OutboundFlightNumber = t.OutboundFlightNumber, TMA.InboundFlightNumber = u.InboundFlightNumber 
	FROM @tmpOneWayRoundTrip TMA
		INNER JOIN 
		(
			SELECT DISTINCT airResponseKey, 
				STUFF(
					 (SELECT ', ' + airSegmentMarketingAirlineCode + CONVERT(VARCHAR, airSegmentFlightNumber)
					  FROM @tmp t2
					  WHERE airResponseKey = t1.airResponseKey AND t2.airLegNumber = 1
					  FOR XML PATH (''))
					  , 1, 1, '')  AS OutboundFlightNumber
			FROM @tmpOneWayRoundTrip t1
		) t ON TMA.airResponseKey = t.airResponseKey 
		INNER JOIN 
		(
			SELECT DISTINCT airResponseKey, 
				STUFF(
					 (SELECT ', ' + airSegmentMarketingAirlineCode + CONVERT(VARCHAR, airSegmentFlightNumber)
					  FROM @tmp t4
					  WHERE airResponseKey = t3.airResponseKey AND t4.airLegNumber = 2 
					  FOR XML PATH (''))
					  , 1, 1, '')  AS InboundFlightNumber
			FROM @tmpOneWayRoundTrip t3
		) u ON TMA.airResponseKey = u.airResponseKey 

	DELETE FROM @tmp
	
	INSERT INTO @tmp (tripKey, recordLocator, tripPurchasedKey, meetingCodeKey, tripAirSegmentKey, airResponseKey, RN
		, airSegmentDepartureDate, airSegmentArrivalDate, airSegmentDepartureAirport, airSegmentArrivalAirport
		, AirSegmentMarketingAirlineCode, airSegmentFlightNumber, airRequestTypeKey)
	SELECT T.TripKey, T.recordLocator, T.tripPurchasedKey, T.meetingCodeKey, TAS.tripAirSegmentKey, TAS.airResponseKey
		, ROW_NUMBER() OVER (PARTITION BY TAS.airResponseKey ORDER BY tripAirSegmentKey) rn, TAS.airSegmentDepartureDate
		, TAS.airSegmentArrivalDate, TAS.airSegmentDepartureAirport, TAS.airSegmentArrivalAirport, AirSegmentMarketingAirlineCode
		, airSegmentFlightNumber, AR.airRequestTypeKey 
	FROM TripAirSegments TAS
		INNER JOIN TripAirLegs legs ON (TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
			AND TAS.airLegNumber = legs.airLegNumber)
		INNER JOIN TripAirResponse TAR ON TAS.airResponseKey = TAR.airResponseKey 
		INNER JOIN Trip T ON TAR.tripGUIDKey = T.tripPurchasedKey 
		INNER JOIN Vault.dbo.Meeting M on T.meetingCodeKey = M.meetingCode and M.meetingCodeKey = @meetingCode
		INNER JOIN TripRequest_air TRA ON T.tripRequestKey = TRA.tripRequestKey 
		INNER JOIN AirRequest AR ON TRA.airRequestKey = AR.airRequestKey 
	WHERE T.tripStatusKey in (2,12,3) and M.siteKey = @SiteKey and T.siteKey = @SiteKey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
			AND airSegmentDepartureDate BETWEEN @tripStartDate AND @tripEndDate AND airSegmentArrivalDate BETWEEN @tripStartDate AND @tripEndDate
			AND AR.airRequestTypeKey = 3
	GROUP BY T.TripKey, T.recordLocator, T.tripPurchasedKey, T.meetingCodeKey, TAS.tripAirSegmentKey, TAS.airResponseKey
		, airSegmentDepartureDate, TAS.airSegmentArrivalDate, airSegmentDepartureAirport, airSegmentArrivalAirport
		, AirSegmentMarketingAirlineCode, airSegmentFlightNumber, AR.airRequestTypeKey 	
	ORDER BY tripAirSegmentKey

	INSERT INTO @tmpMultyArrDate(airResponseKey, airSegmentDepartureDate, tripKey, recordLocator)--, airSegmentArrDate)
	SELECT airResponseKey, MIN(airSegmentDepartureDate), tripKey, recordLocator   
	FROM 
	(
		SELECT t.airResponseKey, t.airSegmentDepartureDate, t.tripKey, t.recordLocator  
		FROM @tmp t
			INNER JOIN @tblTripDest tbl ON t.airSegmentArrivalAirport = tbl.AirportCode 
		WHERE t.airRequestTypeKey = 3   
	)A GROUP BY airResponseKey, tripKey, recordLocator


--PRINT '4' + GETDATE()
	
	UPDATE TMA SET AirSegmentMarketingAirlineCode = t.AirSegmentMarketingAirlineCode 
	FROM @tmpMultyArrDate TMA
		INNER JOIN
		(
			SELECT airResponseKey, MIN(tripAirSegmentKey) MinAirSegmentKey, AirSegmentMarketingAirlineCode 
			FROM @tmp 
			GROUP BY airResponseKey, AirSegmentMarketingAirlineCode 
		) t ON TMA.airResponseKey = t.airResponseKey 

	
	UPDATE TMA SET RN = a.RN
	FROM @tmpMultyArrDate TMA
		INNER JOIN 
		( 
			SELECT RN, t.airResponseKey, t.airSegmentDepartureDate 
			FROM @tmp t
			WHERE t.airRequestTypeKey = 3
		) A ON TMA.airResponseKey = A.airResponseKey AND TMA.airSegmentDepartureDate = A.airSegmentDepartureDate 
	
--PRINT '5' + GETDATE()

	UPDATE TMA SET RN_MAX = t.RN
	FROM @tmpMultyArrDate TMA
		INNER JOIN 
		(
			SELECT airResponseKey, MAX(RN) RN
			FROM @tmp t
			WHERE t.airRequestTypeKey = 3 
			GROUP BY airResponseKey
		)  t ON TMA.airResponseKey=t.airResponseKey
		
--PRINT '6' + GETDATE()
	
	UPDATE TMA SET TMA.airSegmentDepartureTime = CONVERT(TIME, t.airSegmentArrivalDate, 103) 
	FROM @tmpMultyArrDate TMA
		INNER JOIN @tmp t ON TMA.airResponseKey = t.airResponseKey AND TMA.RN = t.RN 

--PRINT '7' + GETDATE()

	--UPDATE TMA SET TMA.airSegmentArrDate = CONVERT(DATE, A.airSegmentDepartureDate,103), 
	--	TMA.airSegmentArrTime = CONVERT(TIME, A.airSegmentDepartureDate, 103)
	--FROM @tmpMultyArrDate TMA
	--	INNER JOIN 
	--	( 
	--		SELECT RN, t.airResponseKey, t.airSegmentDepartureDate 
	--		FROM @tmp t
	--			INNER JOIN @tblTripDest tbl ON t.airSegmentDepartureAirport = tbl.AirportCode 
	--		WHERE t.airRequestTypeKey = 3
	--	) A ON TMA.airResponseKey = A.airResponseKey 
	--WHERE A.RN = TMA.RN + 1

	UPDATE TMA SET TMA.airSegmentArrDate = CONVERT(DATE, b.airSegmentDepartureDate,103), 
		TMA.airSegmentArrTime = CONVERT(TIME, b.airSegmentDepartureDate, 103)
	FROM @tmpMultyArrDate TMA
		INNER JOIN 
		( 
			SELECT RN, t.airResponseKey, t.airSegmentDepartureDate 
			FROM @tmp t
				INNER JOIN @tblTripDest tbl ON t.airSegmentArrivalAirport = tbl.AirportCode 
			WHERE t.airRequestTypeKey = 3
		) A ON TMA.airResponseKey = A.airResponseKey 
		INNER JOIN @tmp b ON A.airResponseKey = b.airResponseKey AND b.RN = (a.RN + 1)

--PRINT '8' + GETDATE()
	
	UPDATE TMA SET TMA.OutboundFlightNumber = t.OutboundFlightNumber, TMA.InboundFlightNumber = u.InboundFlightNumber 
	FROM @tmpMultyArrDate TMA
		INNER JOIN 
		(
			SELECT DISTINCT airResponseKey, 
				STUFF(
					 (SELECT ', ' + airSegmentMarketingAirlineCode + CONVERT(VARCHAR, airSegmentFlightNumber)
					  FROM @tmp t2
					  WHERE airResponseKey = t1.airResponseKey AND RN <= t1.RN 
					  FOR XML PATH (''))
					  , 1, 1, '')  AS OutboundFlightNumber
			FROM @tmpMultyArrDate t1
		) t ON TMA.airResponseKey = t.airResponseKey 
		INNER JOIN 
		(
			SELECT DISTINCT airResponseKey, 
				STUFF(
					 (SELECT ', ' + airSegmentMarketingAirlineCode + CONVERT(VARCHAR, airSegmentFlightNumber)
					  FROM @tmp t4
					  WHERE airResponseKey = t3.airResponseKey AND RN > t3.RN 
					  FOR XML PATH (''))
					  , 1, 1, '')  AS InboundFlightNumber
			FROM @tmpMultyArrDate t3
		) u ON TMA.airResponseKey = u.airResponseKey 

--PRINT '10' + GETDATE()

	UPDATE TMA SET TMA.TripFrom1 = tmp1.airSegmentDepartureAirport + '-' + t.TripFrom1 + '-' + tmp.airSegmentArrivalAirport 
	FROM @tmpMultyArrDate TMA
		INNER JOIN 
		(
			SELECT DISTINCT airResponseKey, 
				STUFF((
						SELECT CASE WHEN t3.airSegmentArrivalAirport = t2.airSegmentDepartureAirport THEN '-' + t2.airSegmentDepartureAirport 
								ELSE '-' + t3.airSegmentArrivalAirport + '//' + t2.airSegmentDepartureAirport END
						FROM @tmp t2 
							INNER JOIN @tmp t3 ON t3.airResponseKey = t2.airResponseKey AND t3.RN = (t2.RN - 1) 
						WHERE t2.airResponseKey = t1.airResponseKey AND t2.RN <= t1.RN 
					  FOR XML PATH (''))
					  , 1, 1, '')  AS TripFrom1
			FROM @tmpMultyArrDate t1
		) t ON TMA.airResponseKey = t.airResponseKey 
		INNER JOIN @tmp tmp ON TMA.airResponseKey = tmp.airResponseKey and TMA.RN = tmp.RN 		
		INNER JOIN @tmp tmp1 ON TMA.airResponseKey = tmp1.airResponseKey and tmp1.RN = 1

	--UPDATE TMA SET TMA.TripFrom1 = tmp1.airSegmentDepartureAirport + '-' + t.TripFrom1 + '-' + tmp.airSegmentArrivalAirport 
	--FROM @tmpMultyArrDate TMA
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT airResponseKey, 
	--			STUFF((
	--					SELECT '-' + 
	--						CASE WHEN t3.airSegmentArrivalAirport = t2.airSegmentDepartureAirport THEN t2.airSegmentDepartureAirport 
	--							ELSE t3.airSegmentArrivalAirport END
	--					FROM @tmp t2 
	--						INNER JOIN @tmp t3 ON t3.airResponseKey = t2.airResponseKey AND t3.RN = (t2.RN - 1) 
	--					WHERE t2.airResponseKey = t1.airResponseKey AND t2.RN <= t1.RN 
	--				  FOR XML PATH (''))
	--				  , 1, 1, '')  AS TripFrom1
	--		FROM @tmpMultyArrDate t1
	--	) t ON TMA.airResponseKey = t.airResponseKey 
	--	INNER JOIN @tmp tmp ON TMA.airResponseKey = tmp.airResponseKey and TMA.RN = tmp.RN 		
	--	INNER JOIN @tmp tmp1 ON TMA.airResponseKey = tmp1.airResponseKey and tmp1.RN = 1

	--UPDATE TMA SET TMA.TripFrom1 = t.TripFrom1 + '-' + tmp.airSegmentArrivalAirport 
	--FROM @tmpMultyArrDate TMA
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT airResponseKey, 
	--			STUFF(
	--					(SELECT '-' + airSegmentDepartureAirport
	--				  FROM @tmp t2
	--				  WHERE airResponseKey = t1.airResponseKey AND RN <= t1.RN 
	--				  FOR XML PATH (''))
	--				  , 1, 1, '')  AS TripFrom1
	--		FROM @tmpMultyArrDate t1
	--	) t ON TMA.airResponseKey = t.airResponseKey 
	--	INNER JOIN @tmp tmp ON TMA.airResponseKey = tmp.airResponseKey and TMA.RN = tmp.RN 		

--PRINT '11' + GETDATE()

	UPDATE TMA SET TMA.TripTo1 = tmp1.airSegmentDepartureAirport + '-' + t.TripTo1 + '-' + tmp.airSegmentArrivalAirport 
	FROM @tmpMultyArrDate TMA
		INNER JOIN 
		(
			SELECT DISTINCT airResponseKey, 
				STUFF(
						(SELECT CASE WHEN t3.airSegmentArrivalAirport = t2.airSegmentDepartureAirport THEN '-' + t2.airSegmentDepartureAirport
								ELSE '-' + t3.airSegmentArrivalAirport + '//' + t2.airSegmentDepartureAirport END 
								--ELSE t3.airSegmentArrivalAirport  END
					  FROM @tmp t2
						INNER JOIN @tmp t3 ON t3.airResponseKey = t2.airResponseKey AND t3.RN = (t2.RN - 1) AND t3.RN > t1.RN 
					  WHERE t2.airResponseKey = t1.airResponseKey AND t2.RN > t1.RN 
					  FOR XML PATH (''))
					  , 1, 1, '')  AS TripTo1
			FROM @tmpMultyArrDate t1
		) t ON TMA.airResponseKey = t.airResponseKey 
		INNER JOIN @tmp tmp ON TMA.airResponseKey = tmp.airResponseKey AND TMA.RN_MAX = tmp.RN 		
		INNER JOIN @tmp tmp1 ON TMA.airResponseKey = tmp1.airResponseKey and tmp1.RN = TMA.RN + 1

	--UPDATE TMA SET TMA.TripTo1 = tmp1.airSegmentDepartureAirport + '-' + t.TripTo1 + '-' + tmp.airSegmentArrivalAirport 
	--FROM @tmpMultyArrDate TMA
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT airResponseKey, 
	--			STUFF(
	--					(SELECT '-' + --airSegmentDepartureAirport
	--						CASE WHEN t3.airSegmentArrivalAirport = t2.airSegmentDepartureAirport THEN t2.airSegmentDepartureAirport 
	--							ELSE t3.airSegmentArrivalAirport  END
	--				  FROM @tmp t2
	--					INNER JOIN @tmp t3 ON t3.airResponseKey = t2.airResponseKey AND t3.RN = (t2.RN - 1) AND t3.RN > t1.RN 
	--				  WHERE t2.airResponseKey = t1.airResponseKey AND t2.RN > t1.RN 
	--				  FOR XML PATH (''))
	--				  , 1, 1, '')  AS TripTo1
	--		FROM @tmpMultyArrDate t1
	--	) t ON TMA.airResponseKey = t.airResponseKey 
	--	INNER JOIN @tmp tmp ON TMA.airResponseKey = tmp.airResponseKey AND TMA.RN_MAX = tmp.RN 		
	--	INNER JOIN @tmp tmp1 ON TMA.airResponseKey = tmp1.airResponseKey and tmp1.RN = TMA.RN + 1

	--UPDATE TMA SET TMA.TripTo1 = t.TripTo1 + '-' + tmp.airSegmentArrivalAirport 
	--FROM @tmpMultyArrDate TMA
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT airResponseKey, 
	--			STUFF(
	--					(SELECT '-' + airSegmentDepartureAirport
	--				  FROM @tmp t2
	--				  WHERE airResponseKey = t1.airResponseKey AND RN > t1.RN 
	--				  FOR XML PATH (''))
	--				  , 1, 1, '')  AS TripTo1
	--		FROM @tmpMultyArrDate t1
	--	) t ON TMA.airResponseKey = t.airResponseKey 
	--	INNER JOIN @tmp tmp ON TMA.airResponseKey = tmp.airResponseKey AND TMA.RN_MAX = tmp.RN 		

--PRINT '12' + GETDATE()

	SELECT Trip.tripKey, (PassengerFirstName + ' ' + PassengerLastName) AS PassengerName, Trip.airSegmentDepartureDate FromDate,
		Trip.airSegmentDepartureTime FromTime, Trip.TripFrom1, Trip.TripTo1, Trip.airSegmentArrDate ToDate, Trip.airSegmentArrTime ToTime, 
		Trip.airSegmentMarketingAirlineCode Airline, Trip.OutboundFlightNumber, Trip.InboundFlightNumber, Trip.recordLocator
	FROM @tmpMultyArrDate Trip
		LEFT JOIN TripPassengerInfo on Trip.tripKey = TripPassengerInfo.TripKey 
	WHERE ((PassengerFirstName + ' ' + PassengerLastName) like '%' + @filter + '%') 
		
	UNION 
	
	SELECT Trip.tripKey, (PassengerFirstName + ' ' + PassengerLastName) AS PassengerName, Trip.airSegmentDepartureDate FromDate,
		Trip.airSegmentDepartureTime FromTime, Trip.TripFrom1, Trip.TripTo1, Trip.airSegmentArrDate ToDate, Trip.airSegmentArrTime ToTime, 
		Trip.airSegmentMarketingAirlineCode Airline, Trip.OutboundFlightNumber, Trip.InboundFlightNumber, Trip.recordLocator
	FROM @tmpOneWayRoundTrip Trip
		LEFT JOIN TripPassengerInfo on Trip.tripKey = TripPassengerInfo.TripKey 
	WHERE ((PassengerFirstName + ' ' + PassengerLastName) like '%' + @filter + '%') 

END
GO
