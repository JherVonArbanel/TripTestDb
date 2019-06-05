SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   proc  [dbo].[spClearOneHrBeforeTripResponses]
@siteKey	INT
AS
BEGIN

	DECLARE @HrBeforeTripReqKey TABLE 
	(
		[tripRequestKey] [int] NULL
	)	

	DECLARE @tblAirRequest TABLE 
	(
		airRequestKey [int] 
	)	

	DECLARE @tblAirSubRequest TABLE
	(
		airSubRequestKey INT
	)

	DECLARE @tblAirResponse TABLE
	(
		airResponseKey UNIQUEIDENTIFIER
	)

PRINT 'INSERT TRIPREQUEST'
	
	DECLARE @Curr_DateTime DATETIME=CONVERT(DATETIME,GETDATE(),103)
	DECLARE @Row_Count BIGINT
	DECLARE @Latest_Date DATETIME=(SELECT MAX(airRequestCreated) FROM airRequest)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Gathering Data Start'  ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=N'',@SingleBookThreadId=N'',@GroupBookThreadId=N''

	INSERT INTO @HrBeforeTripReqKey
	SELECT tripRequestKey FROM TripRequest WITH (NOLOCK) WHERE tripRequestCreated < DATEADD(MINUTE, -1440, GETDATE())
	
	INSERT INTO @tblAirRequest 
	SELECT airRequestKey FROM airRequest WITH (NOLOCK) WHERE airRequestCreated < DATEADD(MINUTE, -1440, @Latest_Date)

	INSERT INTO @tblAirSubRequest
	SELECT AirSubRequestKey FROM AirSubRequest ASR WITH (NOLOCK)
		INNER JOIN @tblAirRequest AQ ON ASR.airRequestKey = AQ.airRequestKey

	INSERT INTO @tblAirResponse
	SELECT AirResponseKey FROM AirResponse AR WITH (NOLOCK)
		INNER JOIN @tblAirSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Gathering Data Complete'  ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''
	--------------------------------------------------	AIR Part ----------------------------------------------------
PRINT 'DELETE AIRSEGMENTS'	
	
	
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete airSegments Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A FROM airSegments A
		INNER JOIN @tblAirResponse AR ON A.airResponseKey = AR.airResponseKey 
	--	INNER JOIN airResponse AR WITH (NOLOCK)ON A.airResponseKey = AR.airResponseKey 
	--	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON AR.airSubRequestKey = ASR.airSubRequestKey
	--	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	 
	 SET @Row_Count=@@ROWCOUNT
	 SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete airSegments End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	-- START: DELETE AirSubRequest Data (Trip is not created)
	-- END: DELETE AirSubRequest Data
	 
	 PRINT 'DELETE AIRSEGMENTSMULTIBRAND'
	 
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRSEGMENTSMULTIBRAND Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''
		
	

	DELETE A FROM AirSegmentsMultiBrand A
		INNER JOIN @tblAirResponse AR ON A.airResponseKey = AR.airResponseKey 
	--	LEFT OUTER JOIN airResponse AR WITH (NOLOCK)ON A.airResponseKey = AR.airResponseKey 
	--	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON AR.airSubRequestKey = ASR.airSubRequestKey
	--	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())

	SET @Row_Count=@@ROWCOUNT

	DELETE FROM AirSegmentsMultiBrand WHERE airResponseMultiBrandKey NOT IN (SELECT airResponseMultiBrandKey FROM AirResponseMultiBrand)

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRSEGMENTSMULTIBRAND End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

PRINT 'DELETE AIRRESPONSE'
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSE Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''
	
	

	DELETE A FROM airResponse A
		LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON a.airSubRequestKey = ASR.airSubRequestKey
		LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	WHERE airRequestCreated IS NULL 
	SET @Row_Count=@@ROWCOUNT

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSE End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSE_1 Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A 
	FROM airResponse A
		INNER JOIN @tblAirResponse AR ON A.airResponseKey = AR.airResponseKey
	--	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK) ON a.airSubRequestKey = ASR.airSubRequestKey
	--	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE()) 

	SET @Row_Count=@@ROWCOUNT
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSE_1 End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''
	 
	 PRINT 'DELETE AIRRESPONSEMULTIBRAND'
	 
	 SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSEMULTIBRAND Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''
	
	

	DELETE A FROM AirResponseMultiBrand A
		INNER JOIN @tblAirSubRequest ASR ON a.airSubRequestKey = ASR.airSubRequestKey

	SET @Row_Count=@@ROWCOUNT

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSEMULTIBRAND End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	PRINT 'DELETE NORMALIZEDAIRRESPONSE'

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete NormalizedAirResponses Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A FROM NormalizedAirResponses A
		INNER JOIN @tblAirSubRequest ASR ON A.airsubrequestkey = ASR.airSubRequestKey 
		--LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK)  ON A.airsubrequestkey = ASR.airSubRequestKey 
		--LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	 SET @Row_Count=@@ROWCOUNT

	 SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete NormalizedAirResponses End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''
	 
	 DELETE FROM NormalizedAirResponses WHERE airsubrequestkey = 0

	PRINT 'DELETE NORMALIZEDAIRRESPONSEMULTIBRAND'
	
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete NORMALIZEDAIRRESPONSEMULTIBRAND Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A FROM NormalizedAirResponsesMultiBrand A
		INNER JOIN @tblAirSubRequest ASR ON A.airsubrequestkey = ASR.airSubRequestKey 
	--	LEFT OUTER JOIN 	airSubRequest ASR WITH (NOLOCK)  ON A.airsubrequestkey = ASR.airSubRequestKey 
	--	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	 SET @Row_Count=@@ROWCOUNT

	 SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete NORMALIZEDAIRRESPONSEMULTIBRAND End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	DELETE FROM NormalizedAirResponsesMultiBrand WHERE airsubrequestkey = 0

	PRINT 'DELETE AIRRESPONSEALTERNATEDATE'
	
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSEALTERNATEDATE Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A FROM AIRRESPONSEALTERNATEDATE A
		INNER JOIN @tblAirSubRequest ASR ON A.airsubrequestkey = ASR.airSubRequestKey 
	--	LEFT OUTER JOIN airSubRequest ASR WITH (NOLOCK)  ON A.airsubrequestkey = ASR.airSubRequestKey 
	--	LEFT OUTER JOIN airRequest AQ WITH (NOLOCK) ON ASR.airRequestKey = AQ.airRequestKey
	--WHERE airRequestCreated < DATEADD(MINUTE, -30, GETDATE())
	
	SET @Row_Count=@@ROWCOUNT
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AIRRESPONSEALTERNATEDATE End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	BEGIN 
		SELECT DISTINCT ASR.airSubRequestKey INTO #AirSubRequest_Archive_20171124_FULL  FROM TRIP T
		LEFT OUTER JOIN TripRequest_air TRA ON TRA.TripRequestKey = T.tripRequestKey
		LEFT OUTER JOIN AirRequest AR  ON TRA.airRequestKey = AR.airRequestKey
		LEFT OUTER JOIN AirSubRequest ASR ON AR.airRequestKey = ASR.airRequestKey
		WHERE ASR.airSubRequestKey  IS NOT NULL

		--INSERT INTO #AirSubRequest_Archive_20171124_DISTINCT (airSubRequestKey)
		SELECT ASR.airSubRequestKey INTO #AirSubRequest_Archive_20171124_Latest 
		FROM AirSubRequest ASR
		LEFT OUTER JOIN AirRequest AR  ON AR.airRequestKey = ASR.airRequestKey
		LEFT OUTER JOIN TripRequest_air TRA ON TRA.airRequestKey = AR.airRequestKey
		LEFT OUTER JOIN TripRequest TR ON TR.tripRequestKey = TRA.tripRequestKey
		WHERE TR.tripRequestCreated  > DATEADD(MINUTE, -30, @Latest_Date)
		--AND ISNULL(ASR.airSubRequestKey,0) NOT IN (SELECT  airSubRequestKey FROM #AirSubRequest_Archive_20171124_DISTINCT)

		--SELECT  COUNT(1) FROM AirSubRequest WHERE ISNULL(airSubRequestKey,0) IN (SELECT ISNULL(airSubRequestKey,0) 
		--FROM #AirSubRequest_Archive_20171124_DISTINCT) -- 219832
		SELECT airSubRequestKey INTO #AirSubRequest_Archive_20171124_ToDelete
		FROM #AirSubRequest_Archive_20171124_FULL 
		WHERE airSubRequestKey NOT IN (SELECT airSubRequestKey FROM #AirSubRequest_Archive_20171124_Latest)

		--DELETE FROM AirSubRequest WHERE ISNULL(airSubRequestKey,0) NOT IN (SELECT ISNULL(airSubRequestKey,0) FROM #AirSubRequest_Archive_20171124_DISTINCT)

		SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AirSubRequest Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

		

		DELETE FROM AirSubRequest 
		WHERE ISNULL(airSubRequestKey,0) IN (SELECT ISNULL(airSubRequestKey,0) FROM #AirSubRequest_Archive_20171124_ToDelete)

		SET @Row_Count=@@ROWCOUNT
			SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete AirSubRequest End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

		DROP TABLE #AirSubRequest_Archive_20171124_FULL
		DROP TABLE #AirSubRequest_Archive_20171124_Latest
		DROP TABLE #AirSubRequest_Archive_20171124_ToDelete
	END

	-- comment 20180828 
	--------------------------------------------------	Hotel Part ----------------------------------------------------
	CREATE TABLE #tblHotel 
	( 
		hotelResponseKey UNIQUEIDENTIFIER NULL 
	) 

	CREATE TABLE #tblHotelReq 
	( 
		hotelRequestKey INT NULL 
	) 

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Gathering Hotel Data Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	INSERT INTO #tblHotel 
	SELECT AR.hotelResponseKey FROM HotelResponse AR WITH (NOLOCK)
		LEFT OUTER JOIN HotelRequest AQ WITH (NOLOCK) ON AR.hotelRequestKey = AQ.hotelRequestKey
		INNER JOIN TripRequest_hotel TRA WITH (NOLOCK) ON AQ.hotelRequestKey = TRA.hotelRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 

		SET @Row_Count=@@ROWCOUNT
		exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Gathering Hotel Data End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

PRINT 'DELETE HOTELRESPONSEDETAIL'	
	
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete HotelResponseDetail Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A FROM HotelResponseDetail A
		INNER JOIN #tblHotel B ON A.hotelResponseKey = B.hotelResponseKey
	
	SET @Row_Count=@@ROWCOUNT
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete HotelResponseDetail End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''
	--DELETE A 
	--FROM HotelResponseDetail A
	--INNER JOIN 
	--(
	--	SELECT AR.hotelResponseKey FROM HotelResponse AR
	--	LEFT OUTER JOIN HotelRequest AQ ON AR.hotelRequestKey = AQ.hotelRequestKey
	--	INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)B ON A.hotelResponseKey = B.hotelResponseKey

PRINT 'DELETE HOTELRESPONSE'	

SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Gathering HOTELRESPONSE data Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	INSERT INTO #tblHotelReq 
	SELECT AQ.hotelRequestKey FROM HotelRequest AQ WITH (NOLOCK)
		INNER JOIN TripRequest_hotel TRA WITH (NOLOCK) ON AQ.hotelRequestKey = TRA.hotelRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 

SET @Row_Count=@@ROWCOUNT
		SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Gathering HOTELRESPONSE data End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''


	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete HotelResponse data Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A FROM HotelResponse A
	INNER JOIN #tblHotelReq B ON A.hotelRequestKey = B.hotelRequestKey 

	SET @Row_Count=@@ROWCOUNT
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete HotelResponse data End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''
	--DELETE A 
	--FROM HotelResponse A
	--INNER JOIN 
	--(
	--	SELECT AQ.hotelRequestKey FROM HotelRequest AQ 
	--	INNER JOIN TripRequest_hotel TRA ON AQ.hotelRequestKey = TRA.hotelRequestKey
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)B ON A.hotelRequestKey = B.hotelRequestKey 
	
PRINT 'DELETE CARRESPONSEDETAIL'	

SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete carResponseDetail data Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	--DELETE A 
	--FROM carResponseDetail A
	--INNER JOIN 
	--(
	--	SELECT AR.carResponseKey FROM carResponse AR WITH (NOLOCK)
	--	LEFT OUTER JOIN carRequest AQ WITH (NOLOCK) ON AR.carRequestKey = AQ.carRequestKey
	--	INNER JOIN TripRequest_car TRA WITH (NOLOCK) ON AQ.carRequestKey = TRA.carRequestKey
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)B ON A.carResponseKey = B.carResponseKey
	
		
SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete carResponseDetail data Start - Delete carResponseDetail'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	DELETE CD FROM carResponseDetail CD WITH (NOLOCK)
		INNER JOIN carResponse AR WITH (NOLOCK) ON AR.carResponseKey=CD.carResponseKey
		--LEFT OUTER JOIN carRequest AQ WITH (NOLOCK) ON AR.carRequestKey = AQ.carRequestKey
		INNER JOIN TripRequest_car TRA WITH (NOLOCK) ON AR.carRequestKey = TRA.carRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 

	SET @Row_Count=@@ROWCOUNT
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete carResponseDetail data End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

PRINT 'DELETE CARRESPONSE'	


	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete carResponse data Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	--DELETE A 
	--FROM carResponse A
	--INNER JOIN 
	--(
	--	SELECT AQ.carRequestKey FROM carRequest AQ WITH (NOLOCK)
	--	INNER JOIN TripRequest_car TRA WITH (NOLOCK) ON AQ.carRequestKey = TRA.carRequestKey
	--	INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	--)B ON A.carRequestKey = B.carRequestKey 
	

	DELETE AR FROM carResponse AR WITH (NOLOCK) 
		--LEFT OUTER JOIN carRequest AQ WITH (NOLOCK) ON AR.carRequestKey = AQ.carRequestKey
		INNER JOIN TripRequest_car TRA WITH (NOLOCK) ON AR.carRequestKey = TRA.carRequestKey
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey
	
	SET @Row_Count=@@ROWCOUNT
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete carResponse data End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

DROP TABLE #tblHotel
DROP TABLE #tblHotelReq
	
	--------------------------------------------------	Cruise Part ----------------------------------------------------
PRINT 'DELETE CRUISERESPONSE'	
	
	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete cruiseResponse data Start'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=0,@SingleBookThreadId=N'',@GroupBookThreadId=N''

	

	DELETE A FROM cruiseResponse A
	INNER JOIN 
	(
		SELECT AQ.cruiseRequestKey FROM cruiseRequest AQ WITH (NOLOCK)
		INNER JOIN TripRequest_cruise TRA WITH (NOLOCK) ON AQ.cruiseRequestKey = TRA.cruiseRequestKey
			--AND TRA.tripRequestKey IN (SELECT tripRequestKey FROM @HrBeforeTripReqKey)
		INNER JOIN @HrBeforeTripReqKey H ON TRA.tripRequestKey = H.tripRequestKey 
	)B ON A.CruiseRequestKey = B.cruiseRequestKey 

	SET @Row_Count=@@ROWCOUNT

	SET @Curr_DateTime=CONVERT(DATETIME,GETDATE(),103)
	exec Log..USP_InsertLogs 
	@Userkey=0,@SessionId=N'',@TripRequestkey=0,@Type=N'CleanupJob',@WSName=N'CleanupJob',@XmlData=Null
	,@Event=@Curr_DateTime,@Details=N'Delete cruiseResponse data End'   ,@ExceptionMessage=N'',@StackTrace=N''
	,@LoglevelKey=15,@Comment=@Row_Count,@SingleBookThreadId=N'',@GroupBookThreadId=N''

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
GO
