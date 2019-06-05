SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-----------------------------------------------------------------------------------
-- Author	: Gopal N
-- Date		: 10-JAN-2013
-- Desc		: To clear trip responses which is requested 1 hour before
-- Param	: siteKey as Integer
-- Exec		: EXEC spClearOneHrBeforeTripResponses 1 
-----------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[spClearOneHrBeforeTripResponses_20180504]
(
	@siteKey	INT
)	
AS 
BEGIN

	DECLARE @HrBeforeTripReqKey TABLE 
	(
		[tripRequestKey] [int] NULL
	)	

PRINT 'INSERT TRIPREQUEST'
	INSERT INTO @HrBeforeTripReqKey
	SELECT tripRequestKey FROM TripRequest WHERE tripRequestCreated Between DATEADD(MINUTE, -60, GETDATE())  and DATEADD(MINUTE, -30, GETDATE())
	
	--SELECT tripRequestKey FROM TripRequest WHERE tripRequestCreated < DATEADD(hour, -12, GETDATE())	
	--SELECT tripRequestKey FROM TripRequest WHERE tripRequestCreated < DATEADD(hour, (-667*24), GETDATE())	

	--SELECT COUNT(tripRequestKey) HrBeforeTripReqKey FROM @HrBeforeTripReqKey	
	--SELECT * FROM @HrBeforeTripReqKey
	
	--------------------------------------------------	AIR Part ----------------------------------------------------
PRINT 'DELETE AIRSEGMENTS'	
	DELETE A FROM airSegments A
	INNER JOIN airResponse AR WITH (NOLOCK)ON A.airResponseKey = AR.airResponseKey 
	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON AR.airSubRequestKey = ASR.airSubRequestKey
	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
	 WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	 

	-- START: DELETE AirSubRequest Data (Trip is not created)
	-- END: DELETE AirSubRequest Data
	 
	 PRINT 'DELETE AIRSEGMENTSMULTIBRAND'	
	DELETE A 
	--SELECT COUNT(1) 
	FROM AirSegmentsMultiBrand A
	LEFT OUTER JOIN airResponse AR WITH (NOLOCK)ON A.airResponseKey = AR.airResponseKey 
	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON AR.airSubRequestKey = ASR.airSubRequestKey
	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
	 WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	--DELETE A 
	--FROM airSegments A
	--INNER JOIN 
	--(
	--	SELECT AR.airResponseKey FROM airResponse AR
	--		LEFT OUTER JOIN airSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey
	--		LEFT OUTER JOIN airRequest AQ ON ASR.airRequestKey = AQ.airRequestKey
	--		INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
	--			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--) P ON A.airResponseKey = P.airResponseKey 

PRINT 'DELETE AIRRESPONSE'	
	DELETE A 
	FROM airResponse A
	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON a.airSubRequestKey = ASR.airSubRequestKey
	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
	 WHERE airRequestCreated IS NULL 
	 
	 PRINT 'DELETE AIRRESPONSEMULTIBRAND'	
	DELETE A 
	--SELECT COUNT(*) FROM1
	FROM AirResponseMultiBrand A
	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON a.airSubRequestKey = ASR.airSubRequestKey
	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
	 WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())

	--DELETE A 
	--FROM airResponse A	
	--INNER JOIN
	--(
	--	Select ASR.airSubRequestKey FROM airSubRequest ASR
	--		LEFT OUTER JOIN airRequest AQ ON ASR.airRequestKey = AQ.airRequestKey
	--		INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
	--			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--) B ON A.airSubRequestKey = B.airSubRequestKey
	
	
	PRINT 'DELETE NORMALIZEDAIRRESPONSE'
	
	
	 
	DELETE A 
	--SELECT COUNT(1)
	FROM NormalizedAirResponses A
	LEFT OUTER JOIN 	airSubRequest ASR WITH (NOLOCK)  ON A.airsubrequestkey = ASR.airSubRequestKey 
	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
	 WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	 
	 
	 PRINT 'DELETE NORMALIZEDAIRRESPONSEMULTIBRAND'
	
	
	 
	DELETE A 
	--SELECT COUNT(1)
	FROM NormalizedAirResponsesMultiBrand A
	LEFT OUTER JOIN 	airSubRequest ASR WITH (NOLOCK)  ON A.airsubrequestkey = ASR.airSubRequestKey 
	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
	 WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	 
	 
	 PRINT 'DELETE AIRRESPONSEALTERNATEDATE'
	
	
	 
	DELETE A 
	FROM AIRRESPONSEALTERNATEDATE A
	LEFT OUTER JOIN 	airSubRequest ASR WITH (NOLOCK)  ON A.airsubrequestkey = ASR.airSubRequestKey 
	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
	 WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	
--PRINT 'DELETE AIRSUBREQUEST'		
--	DELETE ASR 
--	FROM airSubRequest ASR WITH (NOLOCK) 
--	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
--	--INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
--		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
--	--INNER JOIN @HrBeforeTripReqKey H ON AQ.airRequestKey = H.tripRequestKey 
--	 WHERE airRequestCreated < DATEADD(hour, -12, GETDATE())


	--DELETE A 
	--FROM airSubRequest A
	--INNER JOIN 
	--(	
	--	SELECT AQ.airRequestKey FROM airRequest AQ 
	--	INNER JOIN TripRequest_air TRA ON AQ.airRequestKey = TRA.airRequestKey
	--		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)B ON A.airRequestKey = B.airRequestKey 

	--SELECT 'airRequest', AQ.* 
	--FROM airRequest AQ 
	--	INNER JOIN TripRequest_air TRA ON AQ.tripRequestKey = TRA.tripRequestKey
	--		AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

	BEGIN 
		SELECT DISTINCT ASR.airSubRequestKey INTO #AirSubRequest_Archive_20171124_DISTINCT  FROM TRIP T
		LEFT OUTER JOIN TripRequest_air TRA ON TRA.TripRequestKey = T.tripRequestKey
		LEFT OUTER JOIN AirRequest AR  ON TRA.airRequestKey = AR.airRequestKey
		LEFT OUTER JOIN AirSubRequest ASR ON AR.airRequestKey = ASR.airRequestKey
		WHERE ASR.airSubRequestKey  IS NOT NULL

		INSERT INTO #AirSubRequest_Archive_20171124_DISTINCT (airSubRequestKey)
		SELECT ASR.airSubRequestKey FROM AirSubRequest ASR
		LEFT OUTER JOIN AirRequest AR  ON AR.airRequestKey = ASR.airRequestKey
		LEFT OUTER JOIN TripRequest_air TRA ON TRA.airRequestKey = AR.airRequestKey
		LEFT OUTER JOIN TripRequest TR ON TR.tripRequestKey = TRA.tripRequestKey
		WHERE TR.tripRequestCreated  > DATEADD(MINUTE, -30, GETDATE())
		AND ISNULL(ASR.airSubRequestKey,0) NOT IN (SELECT  airSubRequestKey FROM #AirSubRequest_Archive_20171124_DISTINCT)

		--SELECT  COUNT(1) FROM AirSubRequest WHERE ISNULL(airSubRequestKey,0) IN (SELECT ISNULL(airSubRequestKey,0) 
		--FROM #AirSubRequest_Archive_20171124_DISTINCT) -- 219832
		
		DELETE FROM AirSubRequest WHERE ISNULL(airSubRequestKey,0) NOT IN (SELECT ISNULL(airSubRequestKey,0) FROM #AirSubRequest_Archive_20171124_DISTINCT)
		
		DROP TABLE #AirSubRequest_Archive_20171124_DISTINCT
	END

	--------------------------------------------------	Hotel Part ----------------------------------------------------
PRINT 'DELETE HOTELRESPONSEDETAIL'	
	--DELETE FROM HotelResponseDetail
	--WHERE hotelResponseKey IN
	--(
	--	SELECT AR.hotelResponseKey FROM HotelResponse AR
	--	LEFT OUTER JOIN HotelRequest AQ ON AR.hotelRequestKey = AQ.hotelRequestKey
	--	INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
	--		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)
	DELETE A 
	FROM HotelResponseDetail A
	INNER JOIN 
	(
		SELECT AR.hotelResponseKey FROM HotelResponse AR
		LEFT OUTER JOIN HotelRequest AQ ON AR.hotelRequestKey = AQ.hotelRequestKey
		INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	)B ON A.hotelResponseKey = B.hotelResponseKey

PRINT 'DELETE HOTELRESPONSE'	
	--DELETE FROM HotelResponse
	--WHERE hotelRequestKey IN 
	--(
	--	SELECT AQ.hotelRequestKey FROM HotelRequest AQ 
	--	INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
	--		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)
	DELETE A 
	FROM HotelResponse A
	INNER JOIN 
	(
		SELECT AQ.hotelRequestKey FROM HotelRequest AQ 
		INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	)B ON A.hotelRequestKey = B.hotelRequestKey 
	
	--DELETE FROM HotelRequest
	--WHERE hotelRequestKey IN 
	--(
	--	Select TRA.hotelRequestKey FROM TripRequest_hotel TRA 
	--		AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--)

	--------------------------------------------------	Car Part ----------------------------------------------------
PRINT 'DELETE CARRESPONSEDETAIL'	
	--DELETE FROM carResponseDetail 
	--WHERE carResponseKey IN 
	--(
	--	SELECT AR.carResponseKey FROM carResponse AR 
	--	LEFT OUTER JOIN carRequest AQ ON AR.carRequestKey = AQ.carRequestKey
	--	INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
	--		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)
	DELETE A 
	FROM carResponseDetail A
	INNER JOIN 
	(
		SELECT AR.carResponseKey FROM carResponse AR 
		LEFT OUTER JOIN carRequest AQ ON AR.carRequestKey = AQ.carRequestKey
		INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	)B ON A.carResponseKey = B.carResponseKey

PRINT 'DELETE CARRESPONSE'	
	--DELETE FROM carResponse 
	--WHERE carRequestKey IN
	--(
	--	SELECT AQ.carRequestKey FROM carRequest AQ 
	--	INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
	--		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)
	DELETE A 
	FROM carResponse A
	INNER JOIN 
	(
		SELECT AQ.carRequestKey FROM carRequest AQ 
		INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	)B ON A.carRequestKey = B.carRequestKey 
	
	--DELETE FROM carRequest
	--WHERE carRequestKey IN
	--(
	--	SELECT TRA.carRequestkey FROM TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
	--		AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--)

	--------------------------------------------------	Cruise Part ----------------------------------------------------
PRINT 'DELETE CRUISERESPONSE'	
	--DELETE FROM cruiseResponse
	--WHERE cruiseRequestKey IN 
	--(
	--	SELECT AQ.cruiseRequestKey FROM cruiseRequest AQ
	--	INNER JOIN TripRequest_cruise TRA ON AQ.cruiseRequestKey = TRA.cruiseRequestKey
	--		--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)
	DELETE A 
	FROM cruiseResponse A
	INNER JOIN 
	(
		SELECT AQ.cruiseRequestKey FROM cruiseRequest AQ
		INNER JOIN TripRequest_cruise TRA ON AQ.cruiseRequestKey = TRA.cruiseRequestKey
			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	)B ON A.CruiseRequestKey = B.cruiseRequestKey 
	
	--SELECT 'HotelRequest', AQ.* 
	--FROM cruiseRequest AQ 
	--	INNER JOIN TripRequest_cruise TRA ON AQ.cruiseRequestKey = TRA.cruiseRequestKey
	--		AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	
	
PRINT 'SHRINK TRIP LOG FILE'		
	--ALTER DATABASE Trip
	--SET RECOVERY SIMPLE
	----GO
	---- Shrink the truncated log file to 1 MB.
	--DBCC SHRINKFILE (2, 1)  
	---- here 2 is the file ID for trasaction log file,you can also mention the log file name (dbname_log)
	----GO
	---- Reset the database recovery model.
	--ALTER DATABASE Trip
	--SET RECOVERY FULL
	--GO
	
END	
	
	

--USE [Trip]
--GO
--/****** Object:  StoredProcedure [dbo].[spArchivePastData_AIR]    Script Date: 01/10/2013 17:18:09 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-------------------------------------------------------------------------------------
---- Author	: Gopal N
---- Date		: 10-JAN-2013
---- Desc		: To clear trip responses which is requested 1 hour before
---- Param	: siteKey as Integer
---- Exec		: EXEC spClearOneHrBeforeTripResponses 1 
-------------------------------------------------------------------------------------

--ALTER PROCEDURE [dbo].[spClearOneHrBeforeTripResponses]
--(
--	@siteKey	INT
--)	
--AS 
--BEGIN

--	DECLARE @HrBeforeTripReqKey TABLE 
--	(
--		[tripRequestKey] [int] NULL
--	)	

--	INSERT INTO @HrBeforeTripReqKey
--	SELECT tripRequestKey FROM TripRequest WHERE tripRequestCreated < DATEADD(hour, -1, GETDATE())

--	SELECT COUNT(tripRequestKey) HrBeforeTripReqKey FROM @HrBeforeTripReqKey
	
--	--SELECT * FROM @HrBeforeTripReqKey
	
--	--------------------------------------------------	AIR Part ----------------------------------------------------
--	SELECT 'AirSegments', AG.* 
--	FROM airSegments AG 
--		LEFT OUTER JOIN airResponse AR ON AG.airResponseKey = AR.airResponseKey
--		LEFT OUTER JOIN airSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey
--		LEFT OUTER JOIN airRequest AQ ON ASR.airRequestKey = AQ.airRequestKey
--		INNER JOIN TripRequest_air TRA ON AQ.tripRequestKey = TRA.tripRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--	SELECT 'airResponse', AR.* 
--	FROM airResponse AR 
--		LEFT OUTER JOIN airSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey
--		LEFT OUTER JOIN airRequest AQ ON ASR.airRequestKey = AQ.airRequestKey
--		INNER JOIN TripRequest_air TRA ON AQ.tripRequestKey = TRA.tripRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	
--	SELECT 'airSubRequest', ASR.* 
--	FROM airSubRequest ASR
--		LEFT OUTER JOIN airRequest AQ ON ASR.airRequestKey = AQ.airRequestKey
--		INNER JOIN TripRequest_air TRA ON AQ.tripRequestKey = TRA.tripRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--	SELECT 'airRequest', AQ.* 
--	FROM airRequest AQ 
--		INNER JOIN TripRequest_air TRA ON AQ.tripRequestKey = TRA.tripRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--	--------------------------------------------------	Hotel Part ----------------------------------------------------

--	SELECT 'HotelResponseDetail', AG.* 
--	FROM HotelResponseDetail AG 
--		LEFT OUTER JOIN HotelResponse AR ON AG.hotelResponseKey = AR.hotelResponseKey
--		LEFT OUTER JOIN HotelRequest AQ ON AR.hotelRequestKey = AQ.hotelRequestKey
--		INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--	SELECT 'HotelResponse', AR.* 
--	FROM HotelResponse AR
--		LEFT OUTER JOIN HotelRequest AQ ON AR.hotelRequestKey = AQ.hotelRequestKey
--		INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	
--	SELECT 'HotelRequest', AQ.* 
--	FROM HotelRequest AQ 
--		INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--	--------------------------------------------------	Car Part ----------------------------------------------------

--	SELECT 'carResponseDetail', AG.* 
--	FROM carResponseDetail AG 
--		LEFT OUTER JOIN carResponse AR ON AG.carResponseKey = AR.carResponseKey
--		LEFT OUTER JOIN carRequest AQ ON AR.carRequestKey = AQ.carRequestKey
--		INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--	SELECT 'carResponse', AR.* 
--	FROM carResponse AR 
--		LEFT OUTER JOIN carRequest AQ ON AR.carRequestKey = AQ.carRequestKey
--		INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	
--	SELECT 'carRequest', AQ.* 
--	FROM carRequest AQ 
--		INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--	--------------------------------------------------	Cruise Part ----------------------------------------------------

--	SELECT 'HotelResponse', AR.* 
--	FROM cruiseResponse AR 
--		LEFT OUTER JOIN cruiseRequest AQ ON AR.cruiseRequestKey = AQ.cruiseRequestKey
--		INNER JOIN TripRequest_cruise TRA ON AQ.cruiseRequestKey = TRA.cruiseRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
	
--	SELECT 'HotelRequest', AQ.* 
--	FROM cruiseRequest AQ 
--		INNER JOIN TripRequest_cruise TRA ON AQ.cruiseRequestKey = TRA.cruiseRequestKey
--			AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)

--END	
GO
