SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_isTripDuplicate] 
(
--Declare
	@TripRequestKey BIGINT
)
AS
BEGIN

		SET NOCOUNT ON
		DECLARE @IsDuplicateTrip BIT=0

		IF OBJECT_ID('tempdb..#FlightDetails') IS NOT NULL
		DROP TABLE #FlightDetails

		CREATE TABLE #FlightDetails
		(
			TripRequestKey INT,
			PassengerEmailID VARCHAR(150),
			tripFrom1 VARCHAR(50),
			tripTo1	VARCHAR(50),
			tripFromDate1 Datetime,
			tripToDate1 Datetime,
			FlightNumber INT,
			airLegNumber INT,
			OperatingAirline varchar(150),
			MarketingAirline varchar(150)
		)

		DECLARE @json NVARCHAR(max)
		DECLARE @jsonPax NVARCHAR(max)
		DECLARE @tripFrom1 VARCHAR(50),@tripTo1	VARCHAR(50),@tripFromDate1 Datetime,@tripToDate1 Datetime

		SELECT 
				@tripFrom1=tripFrom1,
				@tripTo1=tripTo1,
				@tripFromDate1=tripFromDate1,
				@tripToDate1=tripToDate1 
		FROM trip..TripRequest
		WHERE tripRequestKey=@TripRequestKey

		SELECT TOP 1 @json=CONVERT(NVARCHAR(MAX),selecteddata) 
		FROM trip..TripTrail
		WHERE tripRequestKey=@TripRequestKey and Page='ClickPassengerDetails' 
		ORDER BY tripTrailKey DESC 

		INSERT INTO #FlightDetails
		(TripRequestKey,PassengerEmailID,tripFrom1,tripTo1,tripFromDate1,tripToDate1,FlightNumber
		,airLegNumber,OperatingAirline,MarketingAirline) 
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[0].AirSegments[0].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[0].AirSegments[0].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[0].AirSegments[0].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[0].AirSegments[0].LegNumber'
	  
		) AS Orders
		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[0].AirSegments[1].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[0].AirSegments[1].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[0].AirSegments[1].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[0].AirSegments[1].LegNumber'
		) AS Orders
		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[0].AirSegments[2].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[0].AirSegments[2].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[0].AirSegments[2].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[0].AirSegments[2].LegNumber'
		) AS Orders
		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[1].AirSegments[0].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[1].AirSegments[0].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[1].AirSegments[0].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[1].AirSegments[0].LegNumber'
	  
		) AS Orders
		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[1].AirSegments[1].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[1].AirSegments[1].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[1].AirSegments[1].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[1].AirSegments[1].LegNumber'
		) AS Orders
		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[1].AirSegments[2].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[1].AirSegments[2].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[1].AirSegments[2].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[1].AirSegments[2].LegNumber'
		) AS Orders


		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[2].AirSegments[0].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[2].AirSegments[0].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[2].AirSegments[0].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[2].AirSegments[0].LegNumber'
	  
		) AS Orders
		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[2].AirSegments[1].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[2].AirSegments[1].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[2].AirSegments[1].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[2].AirSegments[1].LegNumber'
		) AS Orders
		UNION ALL
		SELECT 
			@TripRequestKey,
			NULL PassengerEmailID,
			@tripFrom1,
			@tripTo1,
			@tripFromDate1,
			@tripToDate1,
			FlightNumber,
			LegNumber,
			OperatingAirline,
			MarketingAirline
		FROM OPENJSON (@json,'$.TravelComponents') 
		WITH (
			  FlightNumber varchar(150) '$.AirLegs[2].AirSegments[2].FlightNumber',
			  OperatingAirline varchar(150) '$.AirLegs[2].AirSegments[2].OperatingAirline.Name',
			  MarketingAirline varchar(150) '$.AirLegs[2].AirSegments[2].MarketingAirline.Name',
			  LegNumber INT '$.AirLegs[2].AirSegments[2].LegNumber'
		) AS Orders

		SELECT TOP 1 @jsonPax=Convert(NVARCHAR(max),selecteddata) 
		FROM trip..TripTrail
		WHERE tripRequestKey=@TripRequestKey and Page='ClickPassengerDetails-PaxInfo' 
		ORDER BY tripTrailKey DESC 

		IF OBJECT_ID('tempdb..#PassengerDetails') IS NOT NULL
		DROP TABLE #PassengerDetails

		CREATE TABLE #PassengerDetails
		(
			TripRequestKey BIGINT,
			EmailAddress  varchar(150)
		)

		INSERT INTO #PassengerDetails(TripRequestKey,EmailAddress)
		SELECT 
			@TripRequestKey,
			EmailAddress
		FROM OPENJSON (@jsonPax) 
		WITH (
			EmailAddress varchar(150)
		) AS Orders


		IF OBJECT_ID('tempdb..#FlightDetailsFinal') IS NOT NULL
		DROp TABLE #FlightDetailsFinal

		CREATE TABLE #FlightDetailsFinal
		(
			TripRequestKey INT,
			PassengerEmailID VARCHAR(150),
			tripFrom1 VARCHAR(50),
			tripTo1	VARCHAR(50),
			tripFromDate1 Datetime,
			tripToDate1 Datetime,
			FlightNumber INT,
			airLegNumber INT,
			OperatingAirline varchar(150),
			MarketingAirline varchar(150)
		)

		INSERT INTO #FlightDetailsFinal
		(TripRequestKey,PassengerEmailID,tripFrom1,tripTo1,tripFromDate1,tripToDate1,FlightNumber,airLegNumber,OperatingAirline,MarketingAirline)
		select F.TripRequestKey,P.EmailAddress,F.tripFrom1,F.tripTo1,F.tripFromDate1,F.tripToDate1,F.FlightNumber,F.airLegNumber,F.OperatingAirline,F.MarketingAirline
		FROM #FlightDetails F
		INNER JOIN  #PassengerDetails P ON F.TripRequestKey=P.TripRequestKey
		WHERE (F.FlightNumber IS NOT NULL OR F.OperatingAirline IS NOT NULL OR F.MarketingAirline  IS NOT NULL OR  F.airLegNumber IS NOT NULL)
		--SELECT * FROM #FlightDetails
		--WHERE (FlightNumber IS NOT NULL OR OperatingAirline IS NOT NULL OR MarketingAirline  IS NOT NULL OR  airLegNumber IS NOT NULL)

		--select * from #FlightDetailsFinal
		IF OBJECT_ID('tempdb..#MessageToDisplay') IS NOT NULL
		DROP TABLE #MessageToDisplay

		SELECT DISTINCT P.PassengerEmailID,TR.tripFrom1,TR.tripTo1,TR.tripFromDate1,TR.tripToDate1
		, CONVERT(varchar(20), seg.airSegmentFlightNumber) FlightNumber,
		 leg.airLegNumber
		INTO #MessageToDisplay
		FROM	TripRequest TR
				LEFT OUTER JOIN Trip WITH (NOLOCK) ON trip.tripRequestKey=TR.tripRequestKey
				LEFT OUTER JOIN TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
				LEFT OUTER JOIN TripAirLegs leg WITH (NOLOCK) ON resp.airResponseKey = leg.airResponseKey 
				LEFT OUTER JOIN TripAirSegments seg WITH (NOLOCK) ON leg.tripAirLegsKey = seg.tripAirLegsKey AND leg.airLegNumber = seg.airLegNumber 
				LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON seg.airSegmentMarketingAirlineCode = vendor .AirlineCode 
				LEFT OUTER JOIN trip..TripPassengerInfo P WITH (NOLOCK) ON trip.tripKey = P.TripKey
				INNER JOIN #FlightDetailsFinal F ON 
				P.PassengerEmailID=F.PassengerEmailID 
				AND TR.tripFrom1=F.tripFrom1 
				AND TR.tripTo1=F.tripTo1
				AND Convert(varchar(8),TR.tripFromDate1,112)=Convert(varchar(8),F.tripFromDate1,112)
				AND Convert(varchar(8),TR.tripToDate1,112)=Convert(varchar(8),F.tripToDate1,112)
				AND Leg.airLegNumber=F.airLegNumber
				AND Seg.airSegmentFlightNumber=F.FlightNumber
		WHERE ISNULL(seg.ISDELETED, 0) = 0 AND ISNULL(leg.ISDELETED, 0) = 0   and Trip.dbo.Trip.tripStatusKey <> 17 

	IF EXISTS(SELECT 1 FROM #MessageToDisplay)	
	BEGIN

		IF OBJECT_ID('tempdb..#MessageToDisplay_SingleLine') IS NOT NULL
		DROP TABLE #MessageToDisplay_SingleLine

		SET @IsDuplicateTrip=1
		SELECT DISTINCT 
		 @IsDuplicateTrip As IsDuplicateTrip, 'Leg' + convert(varchar,B.airLegNumber) 
		+ '-TripFrom:' +  B.tripFrom1  + ' TripTo:' +  B.tripTo1 
		+ ' FromDate:' +   convert(varchar,B.tripFromDate1,20)  
		+ ' ToDate:' +  convert(varchar,B.tripToDate1,20)
		
		+ ' FlightNumber:'+ STUFF((SELECT DISTINCT + ',' + convert(varchar,A.FlightNumber)
							FROM #MessageToDisplay A  
							WHERE A.airLegNumber=B.airLegNumber   
							FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)') 
							,1,1,'')
			+ ' PassengerEmail:'+ STUFF((SELECT DISTINCT + ',' + convert(varchar,C.PassengerEmailID)
								  FROM #MessageToDisplay C  
								  WHERE C.airLegNumber=B.airLegNumber   
								  FOR XML PATH(''), TYPE
								  ).value('.', 'NVARCHAR(MAX)') 
								 ,1,1,'') AS MessageDisplay
		INTO #MessageToDisplay_SingleLine
		FROM #MessageToDisplay B --WHERE recordLocator IN ('VFEFYI') 


		DECLARE @SingleLineMessage VARCHAR(MAX)

		SELECT  @SingleLineMessage = COALESCE(@SingleLineMessage + ' | ', '') + CAST(MessageDisplay AS VARCHAR(MAX)) 
		FROM   #MessageToDisplay_SingleLine

		set @SingleLineMessage='Duplicate booking found. Do you want to continue with this booking?'

		SELECT @IsDuplicateTrip As IsDuplicate,@SingleLineMessage as outputMsg
	END

	SET NOCOUNT OFF
END
GO
