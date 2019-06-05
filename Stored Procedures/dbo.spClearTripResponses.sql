SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-----------------------------------------------------------------------------------
-- Author	: Gopal N
-- Date		: 25-JUN-2014
-- Desc		: To clear trip responses which is requested 1 hour before
-- Param	: siteKey as Integer
-- Exec		: EXEC spClearTripResponses 1 
-----------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[spClearTripResponses]
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
	SELECT tripRequestKey 
	FROM TripRequest 
	WHERE tripRequestCreated < DATEADD(hour, -1, GETDATE())
	
	--------------------------------------------------	AIR Part ----------------------------------------------------
PRINT 'DELETE AIRSEGMENTS'	
	DELETE A 
	FROM airSegments A
		INNER JOIN airResponse AR WITH (NOLOCK)ON A.airResponseKey = AR.airResponseKey 
		INNER JOIN airSubRequest ASR WITH (NOLOCK) ON AR.airSubRequestKey = ASR.airSubRequestKey
		INNER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	 WHERE airRequestCreated < DATEADD(hour, -1, GETDATE())
	 
PRINT 'DELETE AIRRESPONSE'	
	DELETE A 
	FROM airResponse A
		INNER JOIN airSubRequest ASR WITH (NOLOCK) ON a.airSubRequestKey = ASR.airSubRequestKey
		INNER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	 WHERE airRequestCreated < DATEADD(hour, -1, GETDATE())

PRINT 'DELETE NORMALIZEDAIRRESPONSE'
	DELETE A 
	FROM NormalizedAirResponses A
		INNER JOIN 	airSubRequest ASR WITH (NOLOCK)  ON A.airsubrequestkey = ASR.airSubRequestKey 
		INNER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	 WHERE airRequestCreated < DATEADD(hour, -1, GETDATE())
	

	--------------------------------------------------	Hotel Part ----------------------------------------------------
PRINT 'DELETE HOTELRESPONSEDETAIL'	
	DELETE A 
	FROM HotelResponseDetail A
		INNER JOIN HotelResponse AR ON A.hotelResponseKey = AR.hotelResponseKey
		INNER JOIN HotelRequest AQ ON AR.hotelRequestKey = AQ.hotelRequestKey
		INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 

PRINT 'DELETE HOTELRESPONSE'	
	DELETE A 
	FROM HotelResponse A
		INNER JOIN HotelRequest AQ ON A.hotelRequestKey = AQ.hotelRequestKey
		INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	

	--------------------------------------------------	Car Part ----------------------------------------------------
PRINT 'DELETE CARRESPONSEDETAIL'	
	DELETE A 
	FROM carResponseDetail A
		INNER JOIN carResponse AR ON AR.carResponseKey = A.carResponseKey
		INNER JOIN carRequest AQ ON AR.carRequestKey = AQ.carRequestKey
		INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 

PRINT 'DELETE CARRESPONSE'	
	DELETE A 
	FROM carResponse A
		INNER JOIN carRequest AQ ON AQ.carRequestKey = A.carRequestKey
		INNER JOIN TripRequest_car TRA ON AQ.carRequestKey = TRA.carRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	

	--------------------------------------------------	Cruise Part ----------------------------------------------------
PRINT 'DELETE CRUISERESPONSE'	
	DELETE A 
	FROM cruiseResponse A
		INNER JOIN cruiseRequest AQ ON AQ.CruiseRequestKey = A.cruiseRequestKey 
		INNER JOIN TripRequest_cruise TRA ON AQ.cruiseRequestKey = TRA.cruiseRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 

	
PRINT 'SHRINK TRIP LOG FILE'		
	ALTER DATABASE Trip
	SET RECOVERY SIMPLE
	DBCC SHRINKFILE (2, 1)  
	ALTER DATABASE Trip
	SET RECOVERY FULL
	
END
GO
