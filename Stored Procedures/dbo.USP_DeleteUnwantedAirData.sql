SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	--TRUNCATE TABLE AirSegmentOptionalServices
	--TRUNCATE TABLE AirSegments
	--TRUNCATE TABLE AirResponse
	--TRUNCATE TABLE NormalizedAirResponses
	--TRUNCATE TABLE AirSubRequest
	--TRUNCATE TABLE AirRequest

CREATE PROCEDURE [dbo].[USP_DeleteUnwantedAirData]
AS 
BEGIN

	DECLARE @airResNOTEXIST	TABLE(airRequestKey INT, airSubRequestKey INT, airResponseKey UNIQUEIDENTIFIER)
	
	--DECLARE @DisconnectedSubRequest	TABLE(airSubRequestKey INT)
	--DECLARE @DisconnectedRequest	TABLE(airRequestKey INT)
	--DECLARE @DisconnectedResponse	TABLE(airResponseKey UNIQUEIDENTIFIER)

	DECLARE @TodaysDate DATE
	SET	@TodaysDate = CONVERT(DATE, GETDATE(), 103)

	--INSERT INTO @DisconnectedRequest
	--SELECT airRequestKey FROM airRequest WHERE airRequestKey NOT IN (SELECT DISTINCT airRequestKey FROM AirSubRequest)

	BEGIN TRY
		
		BEGIN TRANSACTION
		
		--DELETE AR 
		--FROM AirRequest AR 
		--	INNER JOIN @DisconnectedRequest tmp ON AR.airRequestKey = tmp.airRequestKey


		INSERT INTO @airResNOTEXIST
		SELECT DISTINCT ASR.airRequestKey, ASR.airSubRequestKey, AR.airResponseKey
		FROM AirSubRequest ASR 
			INNER JOIN 
			(
				SELECT airRequestKey, MAX(airrequestDepartureDate) airrequestDepartureDate
				FROM AirSubRequest ASR 
				GROUP BY airRequestKey	
			) A ON ASR.airRequestKey = A.airRequestKey AND CONVERT(DATE, A.airRequestDepartureDate, 103) < @TodaysDate
			LEFT OUTER JOIN AirResponse AR ON ASR.airSubRequestKey = AR.airSubRequestKey 


		DELETE ASeg -- STEP 2 : Delete AirSegments Records which is related to not exist
		FROM AirSegments ASeg
			INNER JOIN (SELECT DISTINCT airResponseKey FROM @airResNOTEXIST) notExist ON ASeg.airResponseKey = notExist.airResponseKey

		INSERT INTO [log]..[Log] (logSourceKey, logMessage, logLevelKey, logCreateDate)
		VALUES (1, 'SQL JOB: [AirSegments Count] --> ' + CONVERT(VARCHAR, @@ROWCOUNT), 2, getdate()) 
						
		DELETE AR -- STEP 3 : Delete AirResponse Records which is related to not exist
		FROM AirResponse AR
			INNER JOIN (SELECT DISTINCT airResponseKey FROM @airResNOTEXIST) notExist ON AR.airResponseKey = notExist.airResponseKey

		INSERT INTO [log]..[Log] (logSourceKey, logMessage, logLevelKey, logCreateDate)
		VALUES (1, 'SQL JOB: [AirResponse Count] --> ' + CONVERT(VARCHAR, @@ROWCOUNT), 2, getdate()) 

		DELETE NAR -- STEP 4 : Delete NormalizedAirResponses Records which is related to not exist
		FROM NormalizedAirResponses NAR
			INNER JOIN (SELECT DISTINCT airSubRequestKey FROM @airResNOTEXIST) notExist ON NAR.airSubRequestKey = notExist.airSubRequestKey

		INSERT INTO [log]..[Log] (logSourceKey, logMessage, logLevelKey, logCreateDate)
		VALUES (1, 'SQL JOB: [NormalizedAirResponses Count] --> ' + CONVERT(VARCHAR, @@ROWCOUNT), 2, getdate()) 
		
		--DELETE ASR -- STEP 5 : Delete AirSubRequest Records which is related to not exist
		--FROM AirSubRequest ASR 
		--	INNER JOIN @airResNOTEXIST notExist ON ASR.airRequestKey = notExist.airRequestKey

		--DELETE ARQ -- STEP 6 : Delete AirRequest Records which is related to not exist
		--FROM AirRequest ARQ 
		--	INNER JOIN @airResNOTEXIST notExist ON ARQ.airRequestKey = notExist.airRequestKey

		COMMIT TRANSACTION
		
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
			
	END CATCH
	
END	



--USE TRIP
--GO

--	DECLARE @airResNOTEXIST			TABLE(airRequestKey INT)

--	DECLARE @TodaysDate DATE
--	SET	@TodaysDate = CONVERT(DATE, GETDATE(), 103)

--	INSERT INTO @airResNOTEXIST
--	SELECT DISTINCT ASR.airRequestKey
--	FROM AirSubRequest ASR 
--		INNER JOIN 
--		(
--			SELECT airRequestKey, MAX(airrequestDepartureDate) airrequestDepartureDate
--			FROM AirSubRequest ASR 
--			GROUP BY airRequestKey	
--		) A ON ASR.airRequestKey = A.airRequestKey AND CONVERT(DATE, A.airRequestDepartureDate, 103) < @TodaysDate
--		LEFT OUTER JOIN AirResponse AR ON ASR.airSubRequestKey = AR.airSubRequestKey 


--	SELECT 'AirSubRequest Count' AS TBL, Count(*) FROM @airResNOTEXIST
	
--	UNION ALL
	
--	SELECT 'AirSegments Count' AS TBL, COUNT(*) CNT
--	FROM AirSegments ASeg
--		INNER JOIN AirResponse AR ON ASeg.airResponseKey = AR.airResponseKey
--		INNER JOIN AirSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey
--		INNER JOIN @airResNOTEXIST notExist ON ASR.airRequestKey = notExist.airRequestKey

--	UNION ALL
	
--	SELECT 'AirResponse Count' AS TBL, COUNT(*) CNT
--	FROM AirResponse AR
--		INNER JOIN AirSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey
--		INNER JOIN @airResNOTEXIST notExist ON ASR.airRequestKey = notExist.airRequestKey
	
--	UNION ALL
	
--	SELECT 'NormalizedAirResponses Count' AS TBL, COUNT(*) CNT
--	FROM NormalizedAirResponses NAR
--		INNER JOIN AirSubRequest ASR ON NAR.airsubrequestkey = ASR.airsubrequestkey
--		INNER JOIN @airResNOTEXIST notExist ON ASR.airRequestKey = notExist.airRequestKey

GO
