SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- SELECT [dbo].[fn_GetInOutboundAirlines]('E4A02019-BAFE-47F0-9A21-52078DB15298', 'DEP','2014-11-01','2015-01-31', 2)
--6SELECT [dbo].[fn_GetInOutboundAirlines]('9C077987-684B-4E1D-8A6D-D62CAE5E9483', 'DEP','2014-11-01','2015-01-31', 2)
CREATE function [dbo].[fn_GetInOutboundAirlines]
( 
	@airresponsekey AS UNIQUEIDENTIFIER
	, @Dep_Arr VARCHAR(15)
	, @tripStartDate datetime 
	, @tripEndDate datetime 
	, @meetingCodeKey INT
)  
RETURNS VARCHAR (4000)   
AS BEGIN
	 DECLARE @Results VARCHAR(MAX)  , @TripDest VARCHAR (MAX)
	 SELECT @Results = ''  , @TripDest = '' 
	 
	 DECLARE @tmp AS TABLE (RN INT,airSegmentMarketingAirlineCode VARCHAR(3), airSegmentFlightNumber VARCHAR(6),airSegmentArrivalAirport VARCHAR(3))
	 DECLARE @RN_MIN INT
	 DECLARE @RN_MAX INT
	 
	 
 INSERT INTO @tmp
	SELECT ROW_NUMBER() OVER (PARTITION BY TAS.airResponseKey ORDER BY tripAirSegmentKey) rn, 
		  TAS.airSegmentMarketingAirlineCode,TAS.airSegmentFlightNumber,TAS.airSegmentArrivalAirport
	FROM TripAirSegments TAS
		INNER JOIN TripAirLegs legs ON (TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
			AND TAS.airLegNumber = legs.airLegNumber)
	WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
		AND airSegmentDepartureDate BETWEEN @tripStartDate AND @tripEndDate AND airSegmentArrivalDate BETWEEN @tripStartDate AND @tripEndDate
	ORDER BY tripAirSegmentKey
	
	DECLARE @airRequestTypeKey INT					---Get airRequestTypeKey to identify which type of Trip is it
	SELECT @airRequestTypeKey = AR.airRequestTypeKey  
	FROM AirRequest AR
		INNER JOIN TripRequest_air TRA ON AR.airRequestKey = TRA.airRequestKey 
		INNER JOIN Trip T ON TRA.tripRequestKey = T.tripRequestKey 
		INNER JOIN TripAirResponse TAR ON T.tripPurchasedKey = TAR.tripGUIDKey AND TAR.airResponseKey = @airresponsekey
	SELECT @TripDest = meetingAirportCd FROM vault..Meeting	WHERE meetingCodeKey = @meetingCodeKey

	SELECT @RN_MIN = MIN(RN) FROM @tmp WHERE airSegmentArrivalAirport IN (SELECT * FROM ufn_DelimiterToTable(@TripDest, ','))
	SELECT @RN_MAX = MAX(RN) FROM @tmp WHERE airSegmentArrivalAirport IN (SELECT * FROM ufn_DelimiterToTable(@TripDest, ','))

	IF @Dep_Arr = 'DEP'										---Outbound Airlines
	IF @airRequestTypeKey = 3								--Show results for Multicity Trip
		BEGIN
		SELECT @Results = @Results + inQ.airSegmentMarketingAirlineCode + (CONVERT(VARCHAR,inQ.airSegmentFlightNumber))+ ', '
					FROM 
					(
					  SELECT rn, airSegmentMarketingAirlineCode , airSegmentFlightNumber 
					  FROM @tmp 
						)inQ WHERE rn<=@RN_MIN
						
		END
		ELSE
	BEGIN
		SELECT @Results = @Results + TAS.airSegmentMarketingAirlineCode + (CONVERT(VARCHAR,TAS.airSegmentFlightNumber))+ ', '
			--, @DepDate = MAX(TAS.airSegmentDepartureDate) 
		FROM TripAirSegments  TAS
			INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
				   AND TAS.airLegNumber = legs.airLegNumber  )
		WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
			AND TAS.airLegNumber = 1
			--ORDER BY airSegmentDepartureDate
		--SET @Results = @Results + '#' + @DepDate 
	END
	ELSE													---Inbound Airlines
	
	IF @airRequestTypeKey = 3								---Multicity Trip
	
	BEGIN
	SELECT @Results = @Results + inQ.airSegmentMarketingAirlineCode + (CONVERT(VARCHAR,inQ.airSegmentFlightNumber))+ ', '
					FROM 
					(SELECT rn, airSegmentMarketingAirlineCode,airSegmentFlightNumber
					  FROM @tmp
						)inQ WHERE rn>@RN_MIN
	END
	
	ELSE
	
	BEGIN
		SELECT @Results = @Results + TAS.airSegmentMarketingAirlineCode + CONVERT(VARCHAR, TAS.airSegmentFlightNumber) + ', '
			--, @ArrDate = MIN(TAS.airSegmentArrivalDate)
		FROM TripAirSegments  TAS
			INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
				   AND TAS.airLegNumber = legs.airLegNumber  )
		WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
			AND TAS.airLegNumber = 2
			--ORDER BY airSegmentDepartureDate
		--SET @Results = @Results + '#' + @ArrDate 
	END

	IF LEN(@Results) > 0
		SET @Results =  SUBSTRING(@Results,1, LEN(@Results)-1)  
	ELSE
		SET @Results = ''


	RETURN(@Results)
	
END

GO
