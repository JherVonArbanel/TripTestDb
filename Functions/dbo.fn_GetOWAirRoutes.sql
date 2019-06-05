SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Select * From TripAirResponse Where airResponseKey = '9C077987-684B-4E1D-8A6D-D62CAE5E9483'
--Select * From Trip Where tripPurchasedKey = 'D9B0CDC9-EA7F-441A-B94C-C388F8F01C64'
--Select * From TripRequest Where tripRequestKey = 262741
--Select * From TripRequest_air Where tripRequestKey = 262741
--Select * From AirRequest Where airRequestKey = 212505
--Select * From AirRequestTypeLookup 

--update TripAirSegments set airSegmentDepartureAirport='SFO' where tripAirSegmentKey=411806
--select * from TripAirSegments order by 1 desc
--SELECT [dbo].[fn_GetOWAirRoutes]('9C077987-684B-4E1D-8A6D-D62CAE5E9483', 'DEP','2014-11-01','2015-01-31', 2)
--SELECT [dbo].[fn_GetOWAirRoutes]('E48E6FF3-F1C5-47E5-BFA1-B67077DBF259', 'DEP','2014-11-01','2015-01-31', 1050)
--SELECT [dbo].[fn_GetOWAirRoutes]('9C077987-684B-4E1D-8A6D-D62CAE5E9483', 'ARR','2014-11-01','2015-01-31', 2)
--SELECT [dbo].[fn_GetOWAirRoutes]('E48E6FF3-F1C5-47E5-BFA1-B67077DBF259', 'ARR','2014-11-01','2015-01-31', 1050)

CREATE function [dbo].[fn_GetOWAirRoutes]
( 
	@airresponsekey AS UNIQUEIDENTIFIER
	, @Dep_Arr VARCHAR(15)
	, @tripStartDate datetime 
	, @tripEndDate datetime 
	, @meetingCodeKey INT
)  
RETURNS VARCHAR (4000)   
AS BEGIN

-- SELECT @airresponsekey = '9C077987-684B-4E1D-8A6D-D62CAE5E9483', @Dep_Arr = 'DEP', @tripStartDate = '2014-11-01', @tripEndDate = '2015-01-31', @meetingCodeKey = 2
	
	DECLARE @Results VARCHAR(MAX), @other VARCHAR(10), @TripDest VARCHAR (MAX)
	SELECT @Results = '', @other = '', @TripDest = '' 

	DECLARE @tmp AS TABLE (RN INT, airSegmentDepartureAirport VARCHAR(3), airSegmentArrivalAirport VARCHAR(3))
	DECLARE @RN INT
	
	INSERT INTO @tmp
	SELECT ROW_NUMBER() OVER (PARTITION BY TAS.airResponseKey ORDER BY tripAirSegmentKey) rn, 
		TAS.airSegmentDepartureAirport, TAS.airSegmentArrivalAirport 
	FROM TripAirSegments TAS
		INNER JOIN TripAirLegs legs ON (TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
			AND TAS.airLegNumber = legs.airLegNumber)
	WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
		AND airSegmentDepartureDate BETWEEN @tripStartDate AND @tripEndDate AND airSegmentArrivalDate BETWEEN @tripStartDate AND @tripEndDate
	ORDER BY tripAirSegmentKey
	
	DECLARE @airRequestTypeKey INT
	SELECT @airRequestTypeKey = AR.airRequestTypeKey  
	FROM AirRequest AR
		INNER JOIN TripRequest_air TRA ON AR.airRequestKey = TRA.airRequestKey 
		INNER JOIN Trip T ON TRA.tripRequestKey = T.tripRequestKey 
		INNER JOIN TripAirResponse TAR ON T.tripPurchasedKey = TAR.tripGUIDKey AND TAR.airResponseKey = @airresponsekey

--PRINT '@airRequestTypeKey --> ' + Convert(VARCHAR, @airRequestTypeKey)

	SELECT @TripDest = meetingAirportCd FROM vault..Meeting	WHERE meetingCodeKey = @meetingCodeKey

	SELECT @RN = MIN(RN) FROM @tmp WHERE airSegmentArrivalAirport IN (SELECT * FROM ufn_DelimiterToTable(@TripDest, ','))
--PRINT '@RN --> ' + Convert(VARCHAR, @RN)

--PRINT '@TripDest --> ' + Convert(VARCHAR, @TripDest)

	IF @Dep_Arr = 'DEP'											-- Outbound Route
	BEGIN
--PRINT 'Inside IF @Dep_Arr = DEP '
		IF @airRequestTypeKey = 3								--Show results for Multicity Trip
		BEGIN
		
--PRINT 'IF @airRequestTypeKey = 3'
			SELECT @Results = @Results + inQ.airSegmentDepartureAirport + '-', @other = inQ.airSegmentArrivalAirport 
			FROM 
			( 
				SELECT rn, airSegmentDepartureAirport, airSegmentArrivalAirport 
				FROM @tmp 
			) inQ WHERE rn <= @RN 

		END
		ELSE													-- Show results for OneWay & Round Trip
		BEGIN
			SELECT @Results = @Results + TAS.airSegmentDepartureAirport + '-' 
				, @other = TAS.airSegmentArrivalAirport 
			FROM TripAirSegments  TAS
				INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
					   AND TAS.airLegNumber = legs.airLegNumber  )
			WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
				AND TAS.airLegNumber = 1
			ORDER BY tripAirSegmentKey
		END
	END	
	ELSE														-- Inbound Route
	BEGIN
		IF @airRequestTypeKey = 3
		BEGIN
		
			SELECT @Results = @Results + inQ.airSegmentDepartureAirport + '-', @other = inQ.airSegmentArrivalAirport  
			FROM 
			(
				SELECT  rn, airSegmentDepartureAirport, airSegmentArrivalAirport 
				FROM @tmp
			) inQ WHERE rn >@RN

		END
		ELSE 
		BEGIN
		
			SELECT @Results = @Results + TAS.airSegmentDepartureAirport + '-' 
				, @other = TAS.airSegmentArrivalAirport 
			FROM TripAirSegments  TAS
				INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
					   AND TAS.airLegNumber = legs.airLegNumber  )
			WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
				AND TAS.airLegNumber = 2
			ORDER BY tripAirSegmentKey
			
		END
	END
	

	
	--IF @Results IS NOT NULL OR @Results <> ''
		--RETURN( SUBSTRING(@Results,1, LEN(@Results)-1)  )
		RETURN ( @Results + @other )
		--RETURN (@Result_Multicity + @other_Multicity)
 
END
GO
