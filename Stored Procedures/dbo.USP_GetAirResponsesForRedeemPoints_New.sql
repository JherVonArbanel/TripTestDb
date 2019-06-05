SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec USP_GetAirResponsesForRedeemPoints @airSubRequestKey=3219988,@airRequestTypeKey=1,@SuperSetairLines=N'',@allowedOperatingAirlines=N'',@airLines=N'',@price=2147483647,@pageNo=0,@pageSize=30,@NoOfStops=N'-1',@drillDownLevel=N'0',@gdsSourcekey=2,@minTakeOffDate='2017-08-10 00:00:00',@maxTakeOffDate='2019-11-10 00:00:00',@minLandingDate='2017-08-10 00:00:00',@maxLandingDate='2019-11-10 00:00:00',@isIgnoreAirlineFilter=N'False',@isTotalPriceSort=N'True',@excludeAirline=N'WN',@IsLoginedAirlineList=N'WN',@siteKey=9,@matrixView=1,@maxNoofstops=2,@MaxDomesticFareTotal=0,@UserKey=0,@UserGroupKey=0,@CompanyKey=232,@CutOffSalesPriorDepartureInMinutes=35,@isMultiBrand=1

CREATE PROCEDURE [dbo].[USP_GetAirResponsesForRedeemPoints_New]
	(   
	@airSubRequestKey int,--38105 ,  
	@sortField varchar(50)='',  
	@airRequestTypeKey int ,      
	@pageNo int ,  
	@pageSize int ,  
	@airLines  varchar(200),  
	@points float ,  
	@NoOfSTOPs varchar (50)  ,  
	@SelectedResponseKey uniqueidentifier =null  ,   
	@minTakeOffDate Datetime ,  
	@maxTakeOffDate Datetime ,  
	@minLandingDate Datetime ,  
	@maxLandingDate Datetime ,  
	@drillDownLevel int = 0 ,  
	@gdssourcekey int = 0 ,  
	@SelectedFareType varchar(100) ='',   
	@superSetAirlines varchar(200)='',  
	@isIgnoreAirlineFilter bit = 0 ,  
	@isTotalPriceSort bit = 0 ,  
	@allowedOperatingAirlines varchar(500) =''  ,
	@excludeAirline varchar ( 500) = '',
	@excludedCountries varchar ( 500) = '',
	@siteKey int = 0,
	@matrixview  int = 0, ---0 for RT and 1 for legwise
	@MaxNoofstops INT = 1,
	@CutOffSalesPriorDepartureInMinutes INT = 35,
	@isMultiBrand bit = 0,
	@SelectedResponseMultiBrandKey uniqueidentifier = null,
	@IsLoginedAirlineList varchar ( 500) = '',
	@UserKey int =0,
	@CompanyKey int =0,
	@UserGroupKey int =0,
	@MaxPointsAllowed int =0,
	@IsBXBostonTransconIncluded bit = 0
	)  
	AS 
	BEGIN  
	SET NOCOUNT ON   
	DECLARE @FirstRec INT  
	DECLARE @LastRec INT  
	DECLARE @isExcludeAirlinesPresent BIT = 0 , @isExcludeCountryPresent BIT = 0, @isLoggedinAirlinesPresent BIT = 0, @isOutOfPolicyResultsPresent BIT = 0
	DECLARE @selectedLeg1RoundTripFare AS FLOAT 
	DECLARE @DepartureIsParent INT = 0
	DECLARE @ArrivalIsParent INT = 0
	DECLARE @policyCabin VARCHAR(100)
	DECLARE @isInternationalTrip BIT = 0
	DECLARE @IsREfundable BIT = 0
	DECLARE @airLegBrandName VARCHAR(100) = ''
	DECLARE @SelectedGDSSourceKey INT 
	DECLARE @HighestPrice INT
	--DECLARE @TransconAirports NVARCHAR(100)
	DECLARE @AwardCodeSearched NVARCHAR(50)
	DECLARE @ShuttleAirports NVARCHAR(100)
	DECLARE @isPartnerOverridesAA BIT = 0
	DECLARE @awardCodeBookingCode VARCHAR(5) = ''
	-- Airport Specific
	-- Not Available 
	-- Initialize variables.  
	--STEP1 -- get current page reecord indexes 
		SET @FirstRec = (@pageNo  - 1) * @PageSize  
		SET @LastRec = (@pageNo  * @PageSize + 1)  
	-- STEP2 -- Get other subrequest details from db based on @airSubRequestKey
	--SET @TransconAirports = 'LAX,JFK,SFO'
	SET @ShuttleAirports = 'DCA,LGA,BOS'
	DECLARE @airRequestKey AS int  
	Declare @airRequestType AS int 
	DECLARE @HighFareTotal AS FLOAT = 0, @LowFareThreshold AS FLOAT = 0, @IsLowFareThreshold AS BIT = 0, @LowestPrice AS FLOAT = 0, @IsHideFare AS BIT = 0;   
	DECLARE @uniqueCabinPresent AS nvarchar(200)
	DECLARE @tblBookingClass AS TABLE ( airLegBookingClass nvarchar(100))
    SET @airRequestKey =( SELECT TOP 1 airRequestKey  FROM AirSubRequest WITH(NOLOCK) WHERE airSubRequestKey = @airSubRequestKey )  
    SELECT * INTO #AirSubRequest FROM AirSubRequest WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM AirSubRequest WHERE airrequestKey = @airRequestKey AND airSubRequestLegIndex = @airRequestTypeKey)
	SELECT @isInternationalTrip = (SELECT isInternationalTrip FROM AirRequest where airRequestKey = @airRequestKey)
    SELECT * INTO #AirResponse FROM AirResponse WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM #AirSubRequest)
    SELECT * INTO #Airsegments FROM AirSegments WHERE airResponseKey in (SELECT airResponseKey FROM #AirResponse)
    SELECT * INTO #NormalizedAirResponses FROM NormalizedAirResponses WHERE airsubrequestkey IN (SELECT airSubRequestKey FROM #AirSubRequest)
	
	SELECT * INTO #AirResponseMultiBrand FROM AirResponseMultiBrand WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM #AirSubRequest)
	SELECT * INTO #AirSegmentsMultiBrand FROM AirSegmentsMultiBrand WHERE airResponseKey in (SELECT airResponseKey FROM #AirResponseMultiBrand)
	SELECT * INTO #NormalizedAirResponsesMultiBrand FROM NormalizedAirResponsesMultiBrand WHERE airsubrequestkey IN (SELECT airSubRequestKey FROM #AirSubRequest)

  	SET @airRequestType =( SELECT  airRequestTypeKey  FROM Airrequest WITH(NOLOCK) WHERE airRequestKey = @airRequestKey )  

	DECLARE @airFlight_ITARequest AS int   
	IF ( @airRequestType > 1) 
	BEGIN 
		if(@airRequestTypeKey =1)
		begin
			SET @airFlight_ITARequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1  AND groupKey = 6)
		end
		else
		begin
			SET @airFlight_ITARequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2 AND groupKey = 6)   
		end
	END 
	ELSE 
	BEGIN 
		SET @airFlight_ITARequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1 AND groupKey = 6) 
	END

	CREATE TABLE #RedeemRules      
	(  
	airOneIdent int identity (1,1),  
	airlineCode nvarchar(20) null ,   
	awardName nvarchar(20) null ,  
	awardCode nvarchar(20) NULL, 
	points int,
	bookingCode nvarchar(20) NULL, 
	awardType nvarchar(20) null,
	ticketDesignator nvarchar(50) NULL,
	isExcludeNonStop bit default 0, 
	noOfCabinMatched int NULL,
	BABookingCode nvarchar(20) NULL,
	IBBookingCode nvarchar(20) NULL,
	isExcludeConnectingFlights bit default 0
	)

	CREATE TABLE #RedeemRules_Mixed      
	(  
	airOneIdent int identity (1,1),  
	airlineCode nvarchar(20) null ,   
	awardName nvarchar(20) null ,  
	awardCode nvarchar(20) NULL, 
	points int,
	bookingCode nvarchar(20) NULL, 
	awardType nvarchar(20) null,
	ticketDesignator nvarchar(50) NULL,
	isExcludeNonStop bit default 0, 
	noOfCabinMatched int NULL,
	BABookingCode nvarchar(20) NULL,
	IBBookingCode nvarchar(20) NULL,
	isExcludeConnectingFlights bit default 0
	)

	DECLARE @awardRulesJson NVARCHAR(MAX)
	SELECT @awardRulesJson = redeemPoints FROM AirRequest where airRequestKey = @airRequestKey
	
	IF(ISJSON(@awardRulesJson)>0)
	BEGIN 
		INSERT INTO #RedeemRules(airlineCode,awardName,awardCode,points,bookingCode,awardType,ticketDesignator,isExcludeNonStop,isExcludeConnectingFlights)  
		SELECT 'AA','PlanAhead', 
		JSON_Value (p.value, '$.AwardCode') as AwardCode, 
		JSON_Value (p.value, '$.Points') as Points,
		JSON_Value (p.value, '$.BookingCode') as BookingCode, 
		JSON_Value (p.value, '$.AwardType') as AwardType,
		JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,
		(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END),
		(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'stopover' THEN 1 ELSE 0 END)
		FROM OPENJSON (@awardRulesJson) as c
		CROSS APPLY OPENJSON (c.value, '$.PlanAhead') as p
		UNION
		SELECT 'AA','Anytime', 
		JSON_Value (p.value, '$.AwardCode') as AwardCode, 
		JSON_Value (p.value, '$.Points') as Points,
		JSON_Value (p.value, '$.BookingCode') as BookingCode, 
		JSON_Value (p.value, '$.AwardType') as AwardType,
		JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,
		(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END),
		(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'stopover' THEN 1 ELSE 0 END)
		FROM OPENJSON (@awardRulesJson) as c
		CROSS APPLY OPENJSON (c.value, '$.Anytime') as p

		IF EXISTS(SELECT TOP 1 BookingCode From #RedeemRules WHERE bookingCode LIKE '%/%')
		BEGIN
			delete from #RedeemRules where bookingCode LIKE '%/%'
			
			INSERT INTO #RedeemRules(airlineCode,awardName,awardCode,points,bookingCode,awardType,ticketDesignator,noOfCabinMatched,isExcludeNonStop) 
			SELECT 'AA','PlanAhead',
			JSON_Value (p.value, '$.AwardCode') as AwardCode, 
			JSON_Value (p.value, '$.Points') as Points,
			JSON_Value (s.value, '$.BookingCode') as BookingCode,
			JSON_Value (p.value, '$.AwardType') as AwardType,
			JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,
			CASE WHEN JSON_Value (s.value, '$.CabinService') LIKE '%two%' THEN 2 ELSE 3 END as CabinService,
			(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END)
			FROM OPENJSON (@awardRulesJson) as c
			CROSS APPLY OPENJSON (c.value, '$.PlanAhead') as p
			CROSS APPLY OPENJSON (p.value,'$.Rule') as s
			UNION
			SELECT 'AA','Anytime',
			JSON_Value (p.value, '$.AwardCode') as AwardCode, 
			JSON_Value (p.value, '$.Points') as Points,
			JSON_Value (s.value, '$.BookingCode') as BookingCode,
			JSON_Value (p.value, '$.AwardType') as AwardType,
			JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,
			CASE WHEN JSON_Value (s.value, '$.CabinService') LIKE '%two%' THEN 2 ELSE 3 END as CabinService,
			(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END)
			FROM OPENJSON (@awardRulesJson) as c
			CROSS APPLY OPENJSON (c.value, '$.Anytime') as p
			CROSS APPLY OPENJSON (p.value,'$.Rule') as s

			INSERT INTO #RedeemRules(airlineCode,awardName,awardCode,points,bookingCode,awardType,ticketDesignator,noOfCabinMatched,isExcludeNonStop) 
			SELECT 'AA','PlanAhead',
			JSON_Value (p.value, '$.AwardCode') as AwardCode, 
			JSON_Value (p.value, '$.Points') as Points,
			JSON_Value (s.value, '$.BookingCode') as BookingCode,
			JSON_Value (p.value, '$.AwardType') as AwardType,
			JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,2 as CabinService,
			(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END)
			FROM OPENJSON (@awardRulesJson) as c
			CROSS APPLY OPENJSON (c.value, '$.PlanAhead') as p
			CROSS APPLY OPENJSON (p.value,'$.Rule') as s WHERE JSON_Value (s.value, '$.CabinService') LIKE '%three%'
			UNION
			SELECT 'AA','Anytime',
			JSON_Value (p.value, '$.AwardCode') as AwardCode, 
			JSON_Value (p.value, '$.Points') as Points,
			JSON_Value (s.value, '$.BookingCode') as BookingCode,
			JSON_Value (p.value, '$.AwardType') as AwardType,
			JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,2 as CabinService,
			(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END)
			FROM OPENJSON (@awardRulesJson) as c
			CROSS APPLY OPENJSON (c.value, '$.Anytime') as p
			CROSS APPLY OPENJSON (p.value,'$.Rule') as s WHERE JSON_Value (s.value, '$.CabinService') LIKE '%three%'

			--INSERT INTO #RedeemRules(airlineCode,awardName,awardCode,points,bookingCode,awardType,ticketDesignator,noOfCabinMatched,isExcludeNonStop) 
			--SELECT 'AA','PlanAhead',
			--JSON_Value (p.value, '$.AwardCode') as AwardCode, 
			--JSON_Value (p.value, '$.Points') as Points,
			--JSON_Value (s.value, '$.BookingCode') as BookingCode,
			--JSON_Value (p.value, '$.AwardType') as AwardType,
			--JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,1 as CabinService,
			--(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END)
			--FROM OPENJSON (@awardRulesJson) as c
			--CROSS APPLY OPENJSON (c.value, '$.PlanAhead') as p
			--CROSS APPLY OPENJSON (p.value,'$.Rule') as s WHERE JSON_Value (s.value, '$.CabinService') LIKE '%three%'
			--UNION
			--SELECT 'AA','Anytime',
			--JSON_Value (p.value, '$.AwardCode') as AwardCode, 
			--JSON_Value (p.value, '$.Points') as Points,
			--JSON_Value (s.value, '$.BookingCode') as BookingCode,
			--JSON_Value (p.value, '$.AwardType') as AwardType,
			--JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,1 as CabinService,
			--(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END)
			--FROM OPENJSON (@awardRulesJson) as c
			--CROSS APPLY OPENJSON (c.value, '$.Anytime') as p
			--CROSS APPLY OPENJSON (p.value,'$.Rule') as s WHERE JSON_Value (s.value, '$.CabinService') LIKE '%three%'
		END

		INSERT INTO #RedeemRules(airlineCode,awardName,awardCode,points,bookingCode,awardType,ticketDesignator,isExcludeNonStop,BABookingCode,IBBookingCode)  
		SELECT 'AA', 'Partner',
		JSON_Value (p.value, '$.AwardCode') as AwardCode, 
		JSON_Value (p.value, '$.Points') as Points,
		(Case WHEN Upper(JSON_Value (p.value, '$.AABookingCode')) = 'N/A' THEN 'NULL' ELSE (JSON_Value (p.value, '$.AABookingCode')) END) as AABookingCode, 
		JSON_Value (p.value, '$.AwardType') as AwardType,
		JSON_Value (p.value, '$.TicketDesignator') as TicketDesignator,
		(Case WHEN Upper(JSON_Value (c.value, '$.Excludes')) = 'NON-STOP' THEN 1 ELSE 0 END),
		(Case WHEN Upper(JSON_Value (p.value, '$.BABookingCode')) = 'N/A' THEN 'NULL' ELSE (JSON_Value (p.value, '$.BABookingCode')) END) as BABookingCode, 
		(Case WHEN Upper(JSON_Value (p.value, '$.IBBookingCode')) = 'N/A' THEN 'NULL' ELSE (JSON_Value (p.value, '$.IBBookingCode')) END) as IBBookingCode
		FROM OPENJSON (@awardRulesJson) as c
		CROSS APPLY OPENJSON (c.value, '$.Partner') as p

	END
	 
	DECLARE @startAirPort AS varchar(100)   
	DECLARE @endAirPort AS varchar(100) 
	IF(@airFlight_ITARequest > 0)
	BEGIN  
		SELECT  @startAirPort=  airRequestDepartureAirport ,@endAirPort=airRequestArrivalAirport FROM #AirSubRequest  WITH(NOLOCK) WHERE  airSubRequestKey = @airFlight_ITARequest   
	END
	ELSE
	BEGIN
		SELECT  @startAirPort=  airRequestDepartureAirport ,@endAirPort=airRequestArrivalAirport FROM #AirSubRequest  WITH(NOLOCK) WHERE  airSubRequestKey = @airSubRequestKey   
	END
	--CALCULATE DEPARTURE OFFSET AND Arrival offset     
	DECLARE @airResponseKey AS UNIQUEIDENTIFIER 
	DECLARE @departureOffset AS float
	DECLARE @arrivalOffset AS float  
	IF(@airFlight_ITARequest > 0)
	BEGIN
		SET @airResponseKey = (SELECT Top 1 airresponsekey FROM #AirResponse r WITH (NOLOCK)  WHERE  ( r.airSubRequestKey = @airFlight_ITARequest))
	END
	ELSE
	BEGIN
		SET @airResponseKey = (SELECT Top 1 airresponsekey FROM #AirResponse r WITH (NOLOCK)  WHERE  ( r.airSubRequestKey = @airSubRequestKey))
	END
	
 
	SELECT TOP 1 @departureOffset =airSegmentDepartureOffset FROM #AirSegments seg WITH (NOLOCK) WHERE airResponseKey = @airResponseKey and airLegNumber = @airRequestTypeKey  AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null ORDER by segmentOrder ASC 
	SELECT TOP 1 @arrivalOffset = airSegmentArrivalOffset  FROM #AirSegments seg WITH (NOLOCK) WHERE airResponseKey =@airResponseKey  AND airLegNumber = @airRequestTypeKey AND airSegmentArrivalAirport=@endAirPort AND airSegmentArrivalOffset is not null ORDER by segmentOrder DESC 


	/****time offset logic ends here ***/  
	DECLARE @tempResponseToRemove AS table ( airresponsekey uniqueidentifier )   
	DECLARE @isTransConSearch BIT 
	SET @isTransConSearch = 0
	DECLARE @isShuttleSearch BIT 
	SET @isShuttleSearch = 0
	DECLARE @tempResponseToRemove_MultiBrand AS table ( airresponseMultiBrandkey uniqueidentifier ) 
	
	-- declare Tables
	DECLARE @tblAirlinesGroup AS TABLE ( marketingAirline varchar(10),operatingAirline varchar(10), groupKey int)
	DECLARE @tblSuperAirlines AS TABLE ( marketingAirline varchar(10))
	DECLARE @tblOperatingAirlines AS TABLE ( operatingAirline VARCHAR(10))
	DECLARE @tblExcludedAirlines AS TABLE ( excludeAirline VARCHAR(10))
	DECLARE @tblLoggedinAirlines AS TABLE ( LoggedinAirline VARCHAR(10))
	DECLARE @tblExcludedCountries AS TABLE ( excludeCountry VARCHAR(10))	  	  
	DECLARE @tblExcludedAirport AS TABLE ( excludeAirport VARCHAR(10))	  
	DECLARE @tblExcludeNonDiscountedFareAirlines AS TABLE ( marketingAirline varchar(10))
	DECLARE @tblCabinGroup AS TABLE ( cabin VARCHAR(20))
	DECLARE @tblTransconGroup AS TABLE ( DepartureCode varchar(10),ArrivalCode varchar(10))
	DECLARE @tblTransonAirport AS TABLE ( AirportCode varchar(10))
	DECLARE @tblShuttleGroup AS TABLE ( DepartureCode varchar(10),ArrivalCode varchar(10))
	DECLARE @tblShuttleAirport AS TABLE ( AirportCode varchar(10))
	DECLARE @tblBXAffiliatesAirlines AS TABLE ( marketingAirline varchar(10),operatingAirline varchar(10))
	
	--DECLARE @tblGetPolicyDetailsForAir as Table      
	--(      
	--policyDetailKey int,      
	--policyKey int,    
	--policyName nvarchar(50),  
	--farePolicyAmt float,      
	--domFareTol varchar(10),
	--domHighFareTol varchar(10),
	--intlFareTol float,      
	--LowFareThreshold float,      
	--fareType varchar(100),      
	--reasonCode int,      
	--multiAirport int,      
	--serviceClass varchar(100),      
	--paymentForm int,      
	--isFarePolicyAmt bit,      
	--isIntlFareTol bit,      
	--isServiceClass bit,      
	--isPaymentForm bit,      
	--isLowFareThreshold bit,      
	--isDelete bit,      
	--policyTypeName nvarchar(50),      
	--IsInternational bit,      
	--IsMaxConnections bit,      
	--MaxConnections int,      
	--IsTimeBand bit,      
	--TimeBand int,    
	--IsApproveFarePolicyAmt bit,    
	--IsApproveInternationalFare bit,    
	--IsApproveLowFareThreshold bit,    
	--NoBusinessClass bit,    
	--isApproveBusinessClass bit,    
	--NoFirstClass bit,    
	--isApproveFirstClass bit,    
	--NoInternational bit,    
	--IsApproveNoInternational bit,    
	--AdvancePurchaseDays int,    
	--IsAdvancePurchase bit,    
	--IsApproveAdvancePurchase bit,    
	--ApproverEmailId VARCHAR(MAX),    
	--IsAllTravel BIT         
	--)  
	 
	--Start - Get Policy 
	--INSERT INTO @tblGetPolicyDetailsForAir 
	--SELECT policyDetailKey, policyKey, policyName, farePolicyAmt, domFareTol, domHighFareTol, intlFareTol, LowFareThreshold, fareType, reasonCode,      
	--	multiAirport, serviceClass, paymentForm, isFarePolicyAmt, isIntlFareTol, isServiceClass, isPaymentForm, isLowFareThreshold, isDelete,      
	--	policyTypeName, IsInternational, IsMaxConnections, MaxConnections, IsTimeBand, TimeBand, IsApproveFarePolicyAmt, IsApproveInternationalFare,    
	--	IsApproveLowFareThreshold, NoBusinessClass, isApproveBusinessClass, NoFirstClass, isApproveFirstClass, NoInternational, IsApproveNoInternational,    
	--	AdvancePurchaseDays, IsAdvancePurchase, IsApproveAdvancePurchase, ApproverEmailId, IsAllTravel 
 --   FROM vault.dbo.[udf_GetPolicyDetailsForAir] (@UserKey, @CompanyKey, 'CORPORATE',@isInternationalTrip,@UserGroupKey)
	--End - Get Policy 

	--Set Domestic Fare Total/ Intl Fare Total from Policy
	--IF (@isInternationalTrip = 0)
	--   SELECT TOP 1 @IsHideFare = isFarePolicyAmt,  @HighFareTotal = domHighFareTol,@LowFareThreshold = LowFareThreshold, @IsLowFareThreshold = isLowFareThreshold  FROM @tblGetPolicyDetailsForAir
	--ELSE
	--   SELECT TOP 1 @IsHideFare = isIntlFareTol FROM @tblGetPolicyDetailsForAir
		
		--INSERT @tblTransonAirport (AirportCode) SELECT * FROM vault .dbo.ufn_CSVToTable (@TransconAirports)	

		--INSERT INTO @tblTransconGroup(DepartureCode, ArrivalCode) 
		--SELECT A.AirportCode,B.AirportCode from @tblTransonAirport A 
		--CROSS JOIN @tblTransonAirport B 

		INSERT INTO @tblTransconGroup(DepartureCode, ArrivalCode)  
		SELECT DepartureCode, ArrivalCode FROM BXTranscon WITH (NOLOCK) where sitekey = @siteKey

		IF(@IsBXBostonTransconIncluded = 0)
		BEGIN
			DELETE FROM @tblTransconGroup WHERE DepartureCode = 'BOS' OR ArrivalCode = 'BOS'
		END
		
		-- Region @isTransConSearch Setting

		SELECT @AwardCodeSearched = RedeemAuthNumber FROM AirRequest where airRequestKey = @airRequestKey
		IF(@AwardCodeSearched IS NOT NULL AND @AwardCodeSearched <> '')
		BEGIN
			SET @AwardCodeSearched = SUBSTRING(@AwardCodeSearched,1,CHARINDEX('/', @AwardCodeSearched) - 1)
		END

		DECLARE @DepatureAirportSearched nvarchar(10)
		DECLARE @ArrivalAirportSearched nvarchar(10)

		SELECT @DepatureAirportSearched = AirRequestDepartureAirport from #AirSubRequest where airSubRequestKey = @airSubRequestKey
		SELECT @ArrivalAirportSearched = airRequestArrivalAirport from #AirSubRequest where airSubRequestKey = @airSubRequestKey

		IF EXISTS(SELECT TOP 1 DepartureCode FROM @tblTransconGroup WHERE UPPER(@DepatureAirportSearched) = UPPER(DepartureCode) AND UPPER(@ArrivalAirportSearched) = UPPER(ArrivalCode))
		BEGIN
			SET @isTransConSearch = 1
		END

		INSERT @tblShuttleAirport (AirportCode) SELECT * FROM vault .dbo.ufn_CSVToTable (@ShuttleAirports)	

		INSERT INTO @tblShuttleGroup(DepartureCode, ArrivalCode) 
		SELECT A.AirportCode,B.AirportCode from @tblShuttleAirport A 
		CROSS JOIN @tblShuttleAirport B 
		
		DELETE FROM @tblShuttleGroup WHERE DepartureCode = ArrivalCode
	
		-- Region @isTransConSearch Setting

		DECLARE @DepatureAirportSearched_Shuttle nvarchar(10)
		DECLARE @ArrivalAirportSearched_Shuttle nvarchar(10)

		SELECT @DepatureAirportSearched_Shuttle = AirRequestDepartureAirport from #AirSubRequest where airSubRequestKey = @airSubRequestKey
		SELECT @ArrivalAirportSearched_Shuttle = airRequestArrivalAirport from #AirSubRequest where airSubRequestKey = @airSubRequestKey

		IF EXISTS(SELECT TOP 1 DepartureCode FROM @tblShuttleGroup WHERE UPPER(@DepatureAirportSearched_Shuttle) = UPPER(DepartureCode))
		BEGIN
			IF EXISTS(SELECT TOP 1 ArrivalCode FROM @tblShuttleGroup WHERE UPPER(@ArrivalAirportSearched_Shuttle) = UPPER(ArrivalCode))
			BEGIN
				SET @isShuttleSearch = 1
			END
		END
	
		IF(@isTransConSearch = 0 AND @isShuttleSearch = 0)
		BEGIN
			IF(@AwardCodeSearched IS NOT NULL AND @AwardCodeSearched <> '')
			BEGIN
				DELETE FROM #RedeemRules 
				WHERE (UPPER(awardName) = 'PlanAhead' OR UPPER(awardName) = 'AnyTime')
				AND isExcludeNonStop NOT IN (SELECT isExcludeNonStop FROM #RedeemRules WHERE awardCode = @AwardCodeSearched)
			END
			ELSE
			BEGIN
				IF((SELECT COUNT(awardName) FROM #RedeemRules WHERE awardName = 'PlanAhead' And bookingCode = 'T') > 1)
				BEGIN
					DELETE FROM #RedeemRules 
					WHERE (UPPER(awardName) = 'PlanAhead' OR UPPER(awardName) = 'AnyTime')
					AND isExcludeNonStop = 0
				END 
			END
		END

		IF(@isTransConSearch = 1)
		BEGIN
			IF(@AwardCodeSearched IS NOT NULL AND @AwardCodeSearched <> '')
			BEGIN
				DELETE FROM #RedeemRules 
				WHERE (UPPER(awardName) = 'PlanAhead' OR UPPER(awardName) = 'AnyTime')
				AND isExcludeNonStop NOT IN (SELECT isExcludeNonStop FROM #RedeemRules WHERE awardCode = @AwardCodeSearched) 
			END
		END

		DECLARE @isValidShuttleAuthCode BIT = 0
		IF(@isShuttleSearch = 1)
		BEGIN
			IF(@AwardCodeSearched IS NOT NULL AND @AwardCodeSearched <> '')
			BEGIN
				IF ((SELECT TOP 1 isExcludeConnectingFlights FROM #RedeemRules WHERE awardCode = @AwardCodeSearched) = 1)
				BEGIN
					SET @isValidShuttleAuthCode = 1
					DELETE FROM #RedeemRules
					WHERE isExcludeConnectingFlights <> 1
				END
				ELSE
				BEGIN
					DELETE FROM #RedeemRules 
					WHERE (UPPER(awardName) = 'PlanAhead' OR UPPER(awardName) = 'AnyTime')
					AND isExcludeNonStop NOT IN (SELECT isExcludeNonStop FROM #RedeemRules WHERE awardCode = @AwardCodeSearched)
					OR isExcludeConnectingFlights = 1
				END
			END
			ELSE
			BEGIN
				IF((SELECT COUNT(awardName) FROM #RedeemRules WHERE awardName = 'PlanAhead' And bookingCode = 'T') > 1)
				BEGIN
					DELETE FROM #RedeemRules 
					WHERE (UPPER(awardName) = 'PlanAhead' OR UPPER(awardName) = 'AnyTime')
					AND isExcludeNonStop = 0 AND isExcludeConnectingFlights <> 1
				END 
			END
		END

	IF 	@superSetAirlines IS NOT NULL AND @superSetAirlines <> '' AND @allowedOperatingAirlines IS NOT NULL AND @allowedOperatingAirlines <> ''
	BEGIN
	-- insert data to airline tables
		IF NOT EXISTS(SELECT TOP 1 awardName From #RedeemRules WHERE awardName = 'Partner')
		BEGIN
			SET @superSetAirlines = 'AA'
			SET @allowedOperatingAirlines = 'AA'
		END

		INSERT @tblSuperAirlines (marketingAirline) SELECT * FROM vault .dbo.ufn_CSVToTable (@superSetAirlines)		
		INSERT @tblOperatingAirlines (operatingAirline) SELECT * FROM vault.dbo.ufn_CSVToTable (@allowedOperatingAirlines) 

		IF EXISTS(SELECT TOP 1 Affiliatekey From Vault..BXAffiliateAirlines WITH(NOLOCK) WHERE siteKey = @siteKey) 
		BEGIN
			INSERT INTO @tblBXAffiliatesAirlines(marketingAirline, operatingAirline) 
			SELECT AFF.marketingAirline,AFF.operatingAirline From Vault..BXAffiliateAirlines AFF WITH(NOLOCK)
			INNER JOIN @tblSuperAirlines S ON AFF.MarketingAirline = S.marketingAirline
			where sitekey = @siteKey
			ORDER BY marketingAirline	

			IF NOT EXISTS(SELECT TOP 1 awardName From #RedeemRules WHERE awardName = 'Partner')
			BEGIN
				DELETE FROM @tblBXAffiliatesAirlines 
				WHERE marketingAirline <> 'AA'
			END

			INSERT @tempResponseToRemove (airresponsekey)
			(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
			INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
			INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
			AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
			(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblBXAffiliatesAirlines AG))
			--select * from @tempResponseToRemove
			--INSERT @tempResponseToRemove (airresponsekey )
			--(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
			--INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
			--INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
			--AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
			--(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblBXAffiliatesAirlines AG))

		END
		-- gourpkey 1: Add data to @tblAirlinesGroup(combination) table from @tblSuperAirlines and @tblOperatingAirlines
		--INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 
		--SELECT A.marketingAirline,b.operatingAirline, 1 from @tblSuperAirlines A 
		--CROSS JOIN @tblOperatingAirlines B 	
		--ORDER BY A.marketingAirline,B.operatingAirline	

		--IF @airFlight_ITARequest > 0
		--BEGIN
		---- gourpkey 2: Add data to @tblAirlinesGroup(combination) table @tblOperatingAirlines  
		--INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 
		--SELECT A.operatingAirline,b.operatingAirline,6 from @tblOperatingAirlines A 
		--CROSS JOIN @tblOperatingAirlines B 	
		--ORDER BY A.operatingAirline,B.operatingAirline	
		--END	
	
		---- Add data to @tblAirlinesGroup(combination) table from affiliate airlines
		--IF @siteKey is not null AND @siteKey <> '' AND @siteKey > 0
		--BEGIN 	
		--IF (select COUNT(affiliateKey) from vault.dbo.affiliateAirlines where siteKey = @siteKey) > 0
		--BEGIN			
		--	INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 			
		--	SELECT AFF.MarketingAirline, AFF.OperatingAirline, 1 
		--	FROM vault.dbo.affiliateAirlines AFF
		--	INNER JOIN @tblSuperAirlines S ON AFF.MarketingAirline = S.marketingAirline
		--	WHERE AFF.SiteKey = @siteKey

		--END
		
		--Exclude Non Discounted Fare
  --  	IF (select COUNT(ExcludeNonDiscountedFareAirlinesKey) from vault.dbo.ExcludeNonDiscountedFareAirlines where siteKey = @siteKey) > 0
		--BEGIN			
		--	INSERT INTO @tblExcludeNonDiscountedFareAirlines(marketingAirline) 			
		--	SELECT NF.MarketingAirline
		--	FROM vault.dbo.ExcludeNonDiscountedFareAirlines NF
		--	INNER JOIN @tblSuperAirlines S ON NF.MarketingAirline = S.marketingAirline
		--	WHERE NF.SiteKey = @siteKey
		
		--	INSERT @tempResponseToRemove (airresponsekey )   
		--	(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
		--	INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		--	INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		--	WHERE airSegmentMarketingAirlineCode in (SELECT * FROM @tblExcludeNonDiscountedFareAirlines) 
		--	AND (resp.fareType is NULL OR ltrim(rtrim(resp.fareType))=''))
		--END
	--END
	
	-- Add all responsekey to @tempResponseToRemove EXCEPT combinations from @tblAirlinesGroup table
		--IF (SELECT COUNT(*) FROM @tblAirlinesGroup) > 0
		--BEGIN
		--	INSERT @tempResponseToRemove (airresponsekey )
		--	(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
		--	INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
		--	INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
		--	WHERE SUB.groupKey = 1
		--	AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
		--	(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 1))
			
		--	IF @airFlight_ITARequest > 0 -- For GroupKey 4(AgentWare WN Fares)
		--	BEGIN
		--		INSERT @tempResponseToRemove (airresponsekey )
		--		(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
		--		INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
		--		INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
		--		WHERE SUB.groupKey = 6
		--		AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
		--		(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 6))
		--	END	
							
		--END
	END	

	
	--select * from @tblBXAffiliatesAirlines
	--select * from @tempResponseToRemove
	--return
	-- Add responsekey to @tempResponseToRemove which contains excludes Airlines
	IF ( @excludeAirline  <> '' AND @excludeAirline IS NOT NULL )
	BEGIN 
		INSERT @tblExcludedAirlines (excludeAirline )   
		SELECT * FROM vault .dbo.ufn_CSVToTable (@excludeAirline)

		-- to exclude marketing airlines
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airSegmentMarketingAirlineCode IN (SELECT * FROM @tblExcludedAirlines)and subReq.groupKey<>4
		)
		
		IF((SELECT COUNT(DISTINCT s.airResponseKey) FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airSegmentMarketingAirlineCode IN (SELECT * FROM @tblExcludedAirlines) and subReq.groupKey<>4 
		)> 0)
		BEGIN
			SET @isExcludeAirlinesPresent =  1 
		END 
        
		-- to exclude operating airlines
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airSegmentOperatingAirlineCode in (SELECT * FROM @tblExcludedAirlines) and subReq.groupKey<>4
		)
		
		IF ( @isExcludeAirlinesPresent = 0 ) 
		BEGIN
			IF((SELECT COUNT(DISTINCT s.airResponseKey )FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airSegmentOperatingAirlineCode in (SELECT * FROM @tblExcludedAirlines) and subReq.groupKey<>4
		)>0) 
			BEGIN
				SET @isExcludeAirlinesPresent =  1 
			END 
		END
	END
	
	IF ( @IsLoginedAirlineList  <> '' AND @IsLoginedAirlineList IS NOT NULL )
	BEGIN 
		INSERT @tblLoggedinAirlines (LoggedinAirline )   
		SELECT * FROM vault .dbo.ufn_CSVToTable (@IsLoginedAirlineList)

		-- to exclude marketing airlines
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airRequestKey = @airRequestKey and airSegmentMarketingAirlineCode IN (SELECT * FROM @tblLoggedinAirlines)
		)
		
		IF((SELECT COUNT(DISTINCT s.airResponseKey) FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airSegmentMarketingAirlineCode IN (SELECT * FROM @tblLoggedinAirlines)
		)> 0)
		BEGIN
			SET @isLoggedinAirlinesPresent =  1 
		END 
        
		-- to exclude operating airlines
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airSegmentOperatingAirlineCode in (SELECT * FROM @tblLoggedinAirlines) 
		)
		
		IF ( @isLoggedinAirlinesPresent = 0 ) 
		BEGIN
			IF((SELECT COUNT(DISTINCT s.airResponseKey )FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airSegmentOperatingAirlineCode in (SELECT * FROM @tblLoggedinAirlines) 
		)>0) 
			BEGIN
				SET @isLoggedinAirlinesPresent =  1 
			END 
		END
	END
	
	--Exclude Airport
	IF ( @excludedCountries  <> '' AND @excludedCountries IS NOT NULL )
	BEGIN 
	
		INSERT @tblExcludedCountries(excludeCountry)   
		SELECT * FROM vault .dbo.ufn_CSVToTable(@excludedCountries)
		
		INSERT @tblExcludedAirport(excludeAirport)
		SELECT AirportCode 
		FROM AirportLookup A WITH (NOLOCK)
		INNER JOIN @tblExcludedCountries T ON A.CountryCode = T.excludeCountry
		
		-- to Exclude Airports
		INSERT @tempResponseToRemove (airresponsekey)   
		(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE ((S.airSegmentDepartureAirport IN (SELECT * FROM @tblExcludedAirport)) OR (S.airSegmentArrivalAirport IN (SELECT * FROM @tblExcludedAirport))))
		
		IF((SELECT COUNT(DISTINCT s.airResponseKey) FROM #AirSegments s WITH(NOLOCK) 
		INNER JOIN #AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE ((S.airSegmentDepartureAirport IN (SELECT * FROM @tblExcludedAirport)) OR (S.airSegmentArrivalAirport IN (SELECT * FROM @tblExcludedAirport))))> 0 ) 
		BEGIN
			SET @isExcludeCountryPresent =  1 
		END 
    END
	
	IF @airRequestType <> 1  -- if not oneWay request
	BEGIN 
	-- Remove oneway reponses of southwest(NW) airline, if its not ONEWAY  ***Bug:7431 Display only RT repponses for southwest
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT DISTINCT seg.airResponseKey from #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey =resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		WHERE airSubRequestLegIndex <> -1 and resp.gdsSourceKey = 2 and seg.airSegmentMarketingAirlineCode = 'WN')
	END

	IF ( @airRequestTypeKey = 1 AND @CutOffSalesPriorDepartureInMinutes IS NOT NULL) 
	BEGIN
		DECLARE @OriginGMTTime DATETIME, @FilterDateTime DATETIME
		DECLARE @departOffset AS float
		
		IF (@departureOffset IS NULL)
	    BEGIN
			SET @departureOffset =(  SELECT  TOP 1  airSegmentDepartureOffset FROM #AirSegments seg WITH (NOLOCK) INNER JOIN #AirResponse r WITH (NOLOCK) ON seg.airResponseKey =r.airResponseKey
			WHERE(  r.airSubRequestKey = @airSubRequestKey    OR r.airSubRequestKey = @airFlight_ITARequest  )
			AND airLegNumber =@airRequestTypeKey AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null ORDER by segmentOrder ASC  )
	    END
	    ELSE
	        SET @departOffset = @departureOffset
	
	    SET @OriginGMTTime = DATEADD(MINUTE, (60)*(@departOffset),GETUTCDATE())
		SET @FilterDateTime = DATEADD(MINUTE,@CutOffSalesPriorDepartureInMinutes,@OriginGMTTime)

		INSERT @tempResponseToRemove (airresponsekey ) 
		(SELECT DISTINCT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		WHERE segmentOrder = 1
		AND seg.airSegmentDepartureDate < @FilterDateTime)
	END
	
	IF(@isValidShuttleAuthCode = 1)
	BEGIN
		IF(@startAirPort = 'LGA' OR @startAirPort = 'DCA' OR @startAirPort = 'BOS')
		BEGIN
			INSERT @tempResponseToRemove (airresponsekey ) 
			(SELECT DISTINCT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
			INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
			INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
			WHERE segmentOrder = 1 AND subReq.airSubRequestLegIndex = @airRequestTypeKey
			AND UPPER(seg.airSegmentDepartureAirport) <> @startAirPort)
		END

		IF(@endAirPort = 'LGA' OR @endAirPort = 'DCA' OR @endAirPort = 'BOS')
		BEGIN
			INSERT @tempResponseToRemove (airresponsekey ) 
			(SELECT DISTINCT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
			INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
			INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
			WHERE segmentOrder = (SELECT COUNT(S.segmentOrder) FROM #Airsegments S WHERE airResponseKey = resp.airResponseKey AND s.airLegNumber = @airRequestTypeKey) 
			AND subReq.airSubRequestLegIndex = @airRequestTypeKey
			AND UPPER(seg.airSegmentArrivalAirport) <> @endAirPort)
		END

		
		--IF(@airRequestTypeKey = 1 AND (@startAirPort = 'LGA' OR @startAirPort = 'DCA' OR @startAirPort = 'BOS'))
		--BEGIN
		--	INSERT @tempResponseToRemove (airresponsekey ) 
		--	(SELECT DISTINCT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
		--	INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		--	INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		--	WHERE segmentOrder = 1 AND subReq.airSubRequestLegIndex = 1
		--	AND UPPER(seg.airSegmentDepartureAirport) <> @startAirPort)
		--END

		--IF(@airRequestTypeKey = 2 AND (@startAirPort = 'LGA' OR @startAirPort = 'DCA' OR @startAirPort = 'BOS'))
		--BEGIN
		--	INSERT @tempResponseToRemove (airresponsekey ) 
		--	(SELECT DISTINCT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
		--	INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		--	INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		--	WHERE segmentOrder = 1 AND subReq.airSubRequestLegIndex = 2
		--	AND UPPER(seg.airSegmentDepartureAirport) <> @endAirPort)
		--END
	END

 --   IF (@isMultiBrand=1)
	--BEGIN 
	--		IF EXISTS(SELECT TOP 1 isServiceClass FROM @tblGetPolicyDetailsForAir WHERE isServiceClass  = 1)
	--		BEGIN
	--				SELECT @policyCabin = serviceClass FROM @tblGetPolicyDetailsForAir WHERE isServiceClass  = 1
	--				IF(@policyCabin IS NOT NULL AND @policyCabin <> '0' AND UPPER(@policyCabin) <> 'UNKNOWN')
	--				BEGIN
	--					DECLARE @cabins AS table (cabinLevel int,cabin varchar(20))  
	--					INSERT @cabins VALUES(1,'Economy' ),(2,'Premium Economy'),(3,'Business'),(4,'First')  
						
	--					DECLARE @vcbLevel INT
	--					IF(UPPER(@policyCabin) = 'ECONOMYPREMIUM')
	--					BEGIN
	--						SELECT @vcbLevel = cabinLevel FROM @cabins WHERE cabin = 'Premium Economy'
	--					END
	--					ELSE
	--					BEGIN
	--						SELECT @vcbLevel = cabinLevel FROM @cabins WHERE UPPER(cabin) = UPPER(@policyCabin)
	--					END

	--					INSERT INTO @tblCabinGroup
	--					SELECT cabin From @cabins WHERE cabinLevel <= @vcbLevel
						
	--					DECLARE @tempResponseToRemoveBefore INT = 0
	--					DECLARE @tempResponseToRemoveAfter INT = 0
	--					SELECT @tempResponseToRemoveBefore = COUNT(airresponsekey) FROM @tempResponseToRemove

	--					INSERT @tempResponseToRemove (airresponsekey )   
	--					(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
	--					INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
	--					INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
	--					WHERE Upper(airsegmentCabin) NOT IN (SELECT UPPER(cabin) FROM @tblCabinGroup))
						
	--					SELECT @tempResponseToRemoveAfter = COUNT(airresponsekey) FROM @tempResponseToRemove

	--					IF(@tempResponseToRemoveBefore < @tempResponseToRemoveAfter)
	--					BEGIN
	--						SET @isOutOfPolicyResultsPresent = 1
	--					END
	--				END
	--		END
	--	--END
	--END
	

	/****logic for calculating price for higher legs *****/  

	DECLARE @tmpAirline  TABLE (airLineCode VARCHAR (200) )  

	IF @NoOfSTOPs = '-1' /*****Default view WHEN no of sTOPs not SELECTed *********/  
	BEGIN   
		SET @NoOfSTOPs = '0,1,2'  
	END   
	DECLARE @noSTOPs AS table ( stops int  )  
	INSERT @noSTOPs (stops )  
	SELECT * FROM vault.dbo.ufn_CSVToTable (@NoOfSTOPs)  
	
	--- Get filtered airlines in response
	IF @airLines <> '' and @isIgnoreAirlineFilter <> 1  
	BEGIN   
		INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )    
	END   
	ELSE       
	BEGIN   
		IF(@airFlight_ITARequest > 0)
		BEGIN
			INSERT into @tmpAirline(airlineCode)  SELECT DISTINCT seg1.airSegmentMarketingAirlineCode FROM #AirSegments seg1  WITH (NOLOCK) INNER JOIN #AirResponse resp  WITH (NOLOCK) ON seg1.airResponseKey = resp.airResponseKey WHERE ( resp.airSubRequestKey = @airSubRequestKey OR resp.airSubRequestKey = @airFlight_ITARequest)  
		END
		ELSE
		BEGIN
			INSERT into @tmpAirline(airlineCode)  SELECT DISTINCT seg1.airSegmentMarketingAirlineCode FROM #AirSegments seg1  WITH (NOLOCK) INNER JOIN #AirResponse resp  WITH (NOLOCK) ON seg1.airResponseKey = resp.airResponseKey WHERE ( resp.airSubRequestKey = @airSubRequestKey)  
		END
		INSERT into @tmpAirline (airLineCode ) VALUES  ('Multiple Airlines')  
	END   
	
	DECLARE  @selectedDate AS DATETIME
		/**airLEg > 1 **/  
			DECLARE @SELECTedResponse as  table  
			(  
			legIndex int   identity ( 1,1) ,  
			responsekey uniqueidentifier ,  
			fareType varchar(100)  
			)  
			IF   @SelectedResponseKey  IS NOT NULL AND @SelectedResponseKey <> '{00000000-0000-0000-0000-000000000000}'    
			BEGIN  
				IF (( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKey ) = @airSubRequestKey OR ( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKey ) = @airFlight_ITARequest)
				BEGIN
					INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKey ,@SELECTedFareType)
				END   
				SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM #AirSegments WITH (NOLOCK)WHERE airResponseKey = @SELECTedResponseKey AND airLegNumber =(@airRequestTypeKey-1) )  
			END 			 

			DECLARE @SELECTedFareTypeTable as table (  
			fareLegIndex int identity (1,1),  
			fareType varchar(20)  
			)  
			INSERT @SELECTedFareTypeTable ( fareType )(SELECT * FROM vault.dbo.ufn_CSVToTable ( @SELECTedFareType ) )  

			UPDATE @SELECTedResponse SET fareType = fare.fareType FROM @SELECTedResponse sResponse  INNER JOIN 
			@SELECTedFareTypeTable fare on sResponse .legIndex =fare.fareLegIndex   


			--vaibhav changes -  to allowed only the combinable classes
	declare @SelectedLeg1BookingClass nvarchar(10)
	declare @SelectedLeg1Airline nvarchar(10)
	declare @count int
	create table #BookingClassAllowed(bookingcode nvarchar(10), airline nvarchar(10))

	if(@airRequestTypeKey=2 and @SelectedResponseMultiBrandKey = '00000000-0000-0000-0000-000000000000')
	begin
	  select @SelectedLeg1BookingClass = airSegmentResBookDesigCode, @SelectedLeg1Airline = airsegmentmarketingairlinecode from trip..AirSegments with (NOLOCK) where airResponseKey = @SelectedResponseKey
	end
	else
	begin
		select @SelectedLeg1BookingClass = asm.airSegmentResBookDesigCode, 
		@SelectedLeg1Airline = aseg.airsegmentmarketingairlinecode 
		from trip..AirSegmentsMultiBrand asm WITH (NOLOCK) 
		inner join trip..airsegments aseg WITH (NOLOCK)  on asm.airsegmentkey = aseg.airsegmentkey
		where airResponseMultiBrandKey = @SelectedResponseMultiBrandKey
	end
	--select @SelectedLeg1BookingClass
    --select @SelectedLeg1Airline
	

		IF(@AwardCodeSearched IS NOT NULL AND @AwardCodeSearched <> '')
		BEGIN
			IF EXISTS(SELECT TOP 1 awardName From #RedeemRules WHERE awardName = 'Partner' and awardCode = @AwardCodeSearched)
			BEGIN
				SET @isPartnerOverridesAA = 1
				SELECT @awardCodeBookingCode = BABookingCode from #RedeemRules WHERE awardName = 'Partner' and awardCode = @AwardCodeSearched
			END
		END
		ELSE IF(@airRequestTypeKey = 2)
		BEGIN
			IF((SELECT gdsSourceKey FROM Trip..AirResponse WITh (NOLOCK) WHERE airResponseKey = @SelectedResponseKey) = 2)
			BEGIN
				SET @isPartnerOverridesAA = 1
			END
		END
	
	-- allowed booking classes for AA, BA and IB
		--select *from #RedeemRules
		if(@airRequestTypeKey=2 and @SelectedLeg1Airline='AA')
		begin
			Insert into #BookingClassAllowed select bookingcode,'AA' from  #RedeemRules where awardname!='partner'
			select @count = count(*) from  #RedeemRules where awardname='partner' and bookingcode=@SelectedLeg1BookingClass
			if(ISNULL(@count,0)>0)
			begin
			Insert  into #BookingClassAllowed select BAbookingcode,'BA' from  #RedeemRules where awardname='partner' 
			Insert  into #BookingClassAllowed select IBbookingcode,'IB' from  #RedeemRules where awardname='partner'  
			end
			--select *from #BookingClassAllowed
		end
		else if(@airRequestTypeKey=2)
		begin
			Insert into #BookingClassAllowed select bookingcode,'AA' from  #RedeemRules where awardname='partner'
			Insert  into #BookingClassAllowed select BAbookingcode,'BA' from  #RedeemRules where awardname='partner' 
			Insert  into #BookingClassAllowed select IBbookingcode,'IB' from  #RedeemRules where awardname='partner'  
			--select *from #BookingClassAllowed
		end


    --end vaibhav changes


	/**pricing logic ends here .**/  
	/**** flitering logic start **/  
	---creating table variable for container for flitered result ..  
	CREATE TABLE #airResponseResultset  
	(  
	airSegmentKey uniqueidentifier,  
	airResponseKey uniqueidentifier ,  
	airLegNumber int,  
	airSegmentMarketingAirlineCode varchar(10) ,  
	airSegmentFlightNumber varchar(50),   
	airSegmentDuration time ,   
	airSegmentEquipment varchar(50) ,   
	airSegmentMiles int  ,   
	airSegmentDepartureDate datetime  ,  
	airSegmentArrivalDate datetime ,   
	airSegmentDepartureAirport  varchar(50),    
	airSegmentArrivalAirport  varchar(50),        
	airRequestKey int,  
	gdsSourceKey int ,      
	MarketingAirlineName  varchar(50),  
	NoOfSTOPs int ,  
	actualTakeOffDateForLeg datetime ,  
	actualLandingDateForLeg datetime ,  
	airSegmentOperatingAirlineCode varchar(10),  
	airSegmentResBookDesigCode varchar(3),  
	noofAirlines int ,  
	airlineName varchar(50),  
	airsegmentDepartureOffset float ,  
	airSegmentArrivalOffset float,  
	airSegmentSeatRemaining int ,        
	airPriceClassSELECTed   varchar (50) NULL ,  
	isRefundable bit ,  
	isBrandedFare bit ,  
	cabinClass varchar(50),  
	fareType varchar(20),segmentOrder int ,  
	airsegmentCabin varchar (20),  
	airSegmentOperatingFlightNumber int,
	airSegmentOperatingAirlineCompanyShortName VARCHAR(100) ,
	airRowNum int identity (1,1) ,
	legDuration int ,
	legConnections Varchar(100),actualNoOFStops INT ,
	isSameAirlinesItin bit,
	isLowestJourneyTime bit default 0, 
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airsegmentPricingKey nvarchar(10),
	airSegmentFareCategory nvarchar(50),
	airLegBrandName nvarchar(200),
	airSegmentBrandName nvarchar(200),
	airSegmentBrandID nvarchar(200),
	airSegmentBaggage nvarchar(200),
	airSegmentMealCode nvarchar(200),
	multiBrandFaresInfo xml Null,
	awardName nvarchar(50),
	points int,
	awardType nvarchar(50),
	awardCode nvarchar(50),
	isAvailable bit default 1,
	ticketDesignator nvarchar(50),
	airResponseMultiBrandkey uniqueidentifier null,
	isDisable bit default 1
	--ReasonCode NVARCHAR(10) DEFAULT 'NONE'
	)  


	  
	--CREATE TABLE #AllOneWayResponses_Avail      
	--(  
	--airOneIdent int identity (1,1),  
	--airOneResponsekey uniqueidentifier , 
	--airOneSegmentKey uniqueidentifier,  
	--airOnePlanAheadPoints float ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--airSegmentOperatingAirlineCode varchar(100), 
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBookingClasses varchar(20) NULL,
	--airLegBrandName nvarchar(200) NULL,
	--planType varchar(20) NULL,
	--segmentOrder int,
	--airOneAnytimePoints float ,
	--isNonStopFlight bit default 0,
	--airOnePlanAheadCabinCount int default 0,
	--airOneAnytimeCabinCount int default 0,
	--gdsSourceKey int,
	--isAvailable bit default 1,
	--airGroupId int, 
	--legWiseFlightCombination nvarchar(100),
	--legWiseAirlineCombination nvarchar(100),
	--legWiseOperatingAirlineCombination nvarchar(100),
	--mergedColumn nvarchar(50),
	--airSegmentSeatRemaining int,
	--awardName nvarchar(20) NULL ,
	--awardType nvarchar(20) NULL,
	--awardCode nvarchar(20) NULL,
	--ticketDesignator nvarchar(50) NULL,
	--isPureAACombination bit default 0,
	--airOnePartnerPoints float
	--)   
	--CREATE TABLE #AllOneWayResponses_Avail_Temp      
	--(  
	--airOneIdent int,  
	--airOneResponsekey uniqueidentifier , 
	--airOneSegmentKey uniqueidentifier,  
	--airOnePlanAheadPoints float ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--airSegmentOperatingAirlineCode varchar(100), 
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBookingClasses varchar(20) NULL,
	--airLegBrandName nvarchar(200) NULL,
	--planType varchar(20) NULL,
	--segmentOrder int,
	--airOneAnytimePoints float ,
	--isNonStopFlight bit default 0,
	--airOnePlanAheadCabinCount int default 0,
	--airOneAnytimeCabinCount int default 0,
	--gdsSourceKey int,
	--isAvailable bit default 1,
	--airGroupId int, 
	--legWiseFlightCombination nvarchar(100),
	--legWiseAirlineCombination nvarchar(100),
	--legWiseOperatingAirlineCombination nvarchar(100),
	--mergedColumn nvarchar(50),
	--airSegmentSeatRemaining int,
	--awardName nvarchar(20) NULL ,
	--awardType nvarchar(20) NULL,
	--awardCode nvarchar(20) NULL,
	--ticketDesignator nvarchar(50) NULL,
	--isPureAACombination bit default 0,
	--airOnePartnerPoints float
	--)  

	--CREATE TABLE #AllOneWayResponses_Avail_Temp1      
	--(  
	--airOneIdent int,  
	--airOneResponsekey uniqueidentifier , 
	--airOneSegmentKey uniqueidentifier,  
	--airOnePlanAheadPoints float ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--airSegmentOperatingAirlineCode varchar(100), 
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBookingClasses varchar(20) NULL,
	--airLegBrandName nvarchar(200) NULL,
	--planType varchar(20) NULL,
	--segmentOrder int,
	--airOneAnytimePoints float ,
	--isNonStopFlight bit default 0,
	--airOnePlanAheadCabinCount int default 0,
	--airOneAnytimeCabinCount int default 0,
	--gdsSourceKey int,
	--isAvailable bit default 1,
	--airGroupId int, 
	--legWiseFlightCombination nvarchar(100),
	--legWiseAirlineCombination nvarchar(100),
	--legWiseOperatingAirlineCombination nvarchar(100),
	--mergedColumn nvarchar(50),
	--airSegmentSeatRemaining int,
	--awardName nvarchar(20) NULL ,
	--awardType nvarchar(20) NULL,
	--awardCode nvarchar(20) NULL,
	--ticketDesignator nvarchar(50) NULL,
	--isPureAACombination bit default 0,
	--airOnePartnerPoints float
	--)  
	--CREATE TABLE #Temp_Group
	--(
	--airOneResponsekey uniqueidentifier , 
	--GroupId int
	--)

	--CREATE TABLE #Temp_AllOneWayResponses_Avail      
	--(  
	--airGroupId int,  
	--airOneIdent int identity (1,1), 
	--airOneResponsekey uniqueidentifier , 
	--airOneSegmentKey uniqueidentifier,  
	--airOnePlanAheadPoints float ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--legWiseFlightCombination nvarchar(100),
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBookingClasses varchar(20) NULL,
	--airLegBrandName nvarchar(200) NULL,
	--planType varchar(20) NULL,
	--segmentOrder int,
	--airOneAnytimePoints float ,
	--isNonStopFlight bit default 0,
	--airOnePlanAheadCabinCount int default 0,
	--airOneAnytimeCabinCount int default 0,
	--gdsSourceKey int,
	--isAvailable bit default 1,
	--mergedColumn nvarchar(50),
	--airSegmentSeatRemaining int
	--)     


	CREATE TABLE #AllOneWayResponses    
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,   
	cabinclass varchar(50),
	legConnections Varchar(100),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	awardName nvarchar(50),
	points int,
	awardType nvarchar(50),
	awardCode nvarchar(50),
	isAvailable bit default 1,
	ticketDesignator nvarchar(50),
	airGroupId int,
	isNonStopFlight bit default 0,
	airOnePlanAheadCabinCount int default 0,
	airOneAnytimeCabinCount int default 0 
	)

	CREATE TABLE #AllOneWayResponses_Temp    
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,   
	cabinclass varchar(50),
	legConnections Varchar(100),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	awardName nvarchar(50),
	points int,
	awardType nvarchar(50),
	awardCode nvarchar(50),
	isAvailable bit default 1,
	ticketDesignator nvarchar(50),
	airGroupId int,
	isNonStopFlight bit default 0,
	airOnePlanAheadCabinCount int default 0,
	airOneAnytimeCabinCount int default 0
	)

	
	CREATE TABLE #AllOneWayResponses_Partner    
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,   
	cabinclass varchar(50),
	legConnections Varchar(100),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	awardName nvarchar(50),
	points int,
	awardType nvarchar(50),
	awardCode nvarchar(50),
	isAvailable bit default 1,
	ticketDesignator nvarchar(50),
	airGroupId int,
	isNonStopFlight bit default 0,
	airOnePlanAheadCabinCount int default 0,
	airOneAnytimeCabinCount int default 0 
	)

	CREATE TABLE #AllOneWayResponses_Temp_Partner    
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,   
	cabinclass varchar(50),
	legConnections Varchar(100),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	awardName nvarchar(50),
	points int,
	awardType nvarchar(50),
	awardCode nvarchar(50),
	isAvailable bit default 1,
	ticketDesignator nvarchar(50),
	airGroupId int,
	isNonStopFlight bit default 0,
	airOnePlanAheadCabinCount int default 0,
	airOneAnytimeCabinCount int default 0
	)

	--CREATE TABLE #AllOneWayResponses_Temp_1    
	--(  
	--airOneIdent int identity (1,1),  
	--airOneResponsekey uniqueidentifier ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBrandName nvarchar(200) NULL,
	--airLegBookingClasses varchar(20) NULL,
	--gdsSourceKey int ,
	--awardName nvarchar(50),
	--points int,
	--awardType nvarchar(50),
	--awardCode nvarchar(50),
	--isAvailable bit default 1,
	--ticketDesignator nvarchar(50),
	--airGroupId int,
	--isNonStopFlight bit default 0
	--)

	--CREATE TABLE #AllOneWayResponses_Temp_Partner_NS   
	--(  
	--airOneIdent int identity (1,1),  
	--airOneResponsekey uniqueidentifier ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBrandName nvarchar(200) NULL,
	--airLegBookingClasses varchar(20) NULL,
	--gdsSourceKey int ,
	--awardName nvarchar(50),
	--points int,
	--awardType nvarchar(50),
	--awardCode nvarchar(50),
	--isAvailable bit default 1,
	--ticketDesignator nvarchar(50),
	--airGroupId int,
	--isNonStopFlight bit default 0
	--)

	--CREATE TABLE #AllOneWayResponses_Temp_Partner_NS_PE   
	--(  
	--airOneIdent int identity (1,1),  
	--airOneResponsekey uniqueidentifier ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBrandName nvarchar(200) NULL,
	--airLegBookingClasses varchar(20) NULL,
	--gdsSourceKey int ,
	--awardName nvarchar(50),
	--points int,
	--awardType nvarchar(50),
	--awardCode nvarchar(50),
	--isAvailable bit default 1,
	--ticketDesignator nvarchar(50),
	--airGroupId int,
	--isNonStopFlight bit default 0
	--)

	--CREATE TABLE #AllOneWayResponses_Temp_1    
	--(  
	--airOneIdent int identity (1,1),  
	--airOneResponsekey uniqueidentifier ,   
	--airSegmentFlightNumber varchar(100),  
	--airSegmentMarketingAirlineCode varchar(100),  
	--airsubRequestkey int ,   
	--cabinclass varchar(50),
	--legConnections Varchar(100),
	--airLegBrandName nvarchar(200) NULL,
	--airLegBookingClasses varchar(20) NULL,
	--gdsSourceKey int ,
	--awardName nvarchar(50),
	--points int,
	--awardType nvarchar(50),
	--awardCode nvarchar(50),
	--isAvailable bit default 1,
	--ticketDesignator nvarchar(50),
	--airGroupId int
	--)

	--INSERT #AllOneWayResponses_Avail(airOneResponsekey,airOneSegmentKey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,cabinclass,airLegBookingClasses,segmentOrder,gdsSourceKey,airSegmentSeatRemaining,airSegmentOperatingAirlineCode)
	--SELECT resp.airResponseKey,segment.airSegmentKey,segment.airSegmentFlightNumber,segment.airSegmentMarketingAirlineCode,resp.airSubRequestKey,segment.airsegmentCabin,avail.resBookDesignCode,segment.segmentOrder,resp.gdsSourceKey,avail.noofseatsremaining,segment.airSegmentOperatingAirlineCode
	--FROM #AirResponse resp  WITH (NOLOCK)
	--INNER JOIN #Airsegments segment  WITH (NOLOCK) ON resp.airResponseKey = segment.airResponseKey
	--LEFT OUTER JOIN AirBookingClassAvailInfo avail WITH (NOLOCK) on segment.airSegmentKey = avail.airSegmentKey
	--where resp.airResponseKey not in (select airresponsekey from @tempResponseToRemove)  
	----------------------------------- ITA Region -----------------------------
	IF(@airFlight_ITARequest > 0)
	BEGIN

		INSERT #AllOneWayResponses (airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey ,cabinclass  ,legConnections,  airLegBrandName,airLegBookingClasses,gdsSourceKey,isAvailable,isMultiBrandFare,childResponsekey)  
		SELECT resp.airresponsekey,flightNumber,airlines,resp .airSubRequestKey ,n.cabinclass    ,n.airLegConnections ,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2) ,resp.isAvailable,0,resp.airResponseKey
		FROM #NormalizedAirResponses n  WITH (NOLOCK) inner join #AirResponse resp  WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airFlight_ITARequest and airlegnumber = @airRequestTypeKey    
		AND ISNULL(resp.gdsSourceKey,13) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,13) ELSE 13 END ) 

		INSERT #AllOneWayResponses (airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey ,cabinclass  ,legConnections,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isAvailable)  
		SELECT resp.airresponsekey,flightNumber,airlines,resp .airSubRequestKey  ,n.cabinclass    ,n.airLegConnections ,n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.isAvailable
		From #NormalizedAirResponsesMultiBrand n  WITH (NOLOCK) inner join #AirResponseMultiBrand resp  WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey =@airFlight_ITARequest      and airlegnumber = @airRequestTypeKey    
		and ISNULL(resp.gdsSourceKey,13) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,13) ELSE 13 END )
	--select * from #AllOneWayResponses
		Delete P  
		FROM #AllOneWayResponses  P  
		INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey  

		Delete P  
		FROM #AllOneWayResponses  P  
		INNER JOIN @tempResponseToRemove_MultiBrand T  ON P.airResponseMultiBrandKey = T.airresponseMultiBrandkey 
		where P.airResponseMultiBrandKey IS NOT NULL AND P.isMultiBrandFare = 1

		UPDATE #AllOneWayResponses
		SET isNonStopFlight = 1
		WHERE airSegmentFlightNumber NOT LIKE '%,%'

		IF (@isValidShuttleAuthCode = 1)
		BEGIN
			Delete P  
			FROM #AllOneWayResponses  P  
			WHERE isNonStopFlight = 0
		END
		
		delete #AllOneWayResponses 
		FROM #AllOneWayResponses t,  
		(  
		SELECT MIN(airOneIdent )  AS minIdent,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,legConnections   
		FROM #AllOneWayResponses m 
		GROUP BY airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,legConnections
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode
		 AND t.airLegBookingClasses =derived .airLegBookingClasses AND t.legConnections = derived.legConnections
		AND airOneIdent > minIdent	

		--select '1',* from #AllOneWayResponses

		--select * into Temp_AshimaResponses from #AllOneWayResponses
	
		select awardname, bookingcode into #RedeemRules_1 from ( select ROW_NUMBER()over(partition by bookingcode order by bookingcode) RN,* from #RedeemRules where awardName <> 'Partner') tmp where tmp.RN=1

		SELECT DISTINCT 
		T.aironeresponsekey, 
		AnyTime=count(R.awardname) OVER (PARTITION BY R.awardname,T.aironeresponsekey ORDER BY R.awardname)
		INTO #AllOneWayResponses_AnyTime
		FROM #AllOneWayResponses T
		INNER JOIN #RedeemRules_1 R ON substring(T.airLegBookingClasses,1,1)=R.bookingcode and R.awardname='Anytime'
		where airSegmentMarketingAirlineCode Like '%AA%'
		ORDER BY T.aironeresponsekey

		SELECT DISTINCT T.aironeresponsekey, 
		PlanAhead=count(R.awardname) OVER (PARTITION BY R.awardname,T.aironeresponsekey ORDER BY R.awardname)
		INTO #AllOneWayResponses_PlanAhead
		FROM #AllOneWayResponses T
		INNER JOIN #RedeemRules_1 R ON substring(T.airLegBookingClasses,1,1)=R.bookingcode and R.awardname='PlanAhead'
		where airSegmentMarketingAirlineCode Like '%AA%'
		ORDER BY T.aironeresponsekey
		
		UPDATE R 
		SET R.airOneAnytimeCabinCount=A.Anytime
		FROM #AllOneWayResponses R
		INNER JOIN #AllOneWayResponses_AnyTime A ON A.aironeresponsekey=R.aironeresponsekey

		UPDATE R 
		SET R.airOnePlanAheadCabinCount=P.PlanAhead
		FROM #AllOneWayResponses R
		INNER JOIN #AllOneWayResponses_PlanAhead P ON P.aironeresponsekey=R.aironeresponsekey

		--select * from #AllOneWayResponses
		
		---- Only AA Section end (Very Imp Remaining)
		--DECLARE @isIncludeNonStop bit 
		--SELECT @isIncludeNonStop = COUNT(airOneIdent) From #RedeemRules WHERE isExcludeNonStop = 0

		--IF EXISTS(SELECT TOP 1 isExcludeNonStop From #RedeemRules WHERE isExcludeNonStop = 1) 
		--BEGIN
		--	IF (@isIncludeNonStop = 0)
		--	BEGIN
		--		DELETE FROM #AllOneWayResponses
		--		WHERE isNonStopFlight = 1
		--	END
		--END  

		--select * from #RedeemRules order by awardCode
	
	IF(@isTransConSearch = 1)
	BEGIN
		------------------ Step 1 First NonStop Flight Plan Ahead Brand where Cabin No is specified
		UPDATE #AllOneWayResponses 
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 0 AND
			resp.isNonStopFlight = 1 AND resp.points is NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass
		--------------------- Step 2 First NonStop Flight Plan Ahead Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 0 AND
			resp.isNonStopFlight = 1 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		------------------ Step 3 Connecting Flight Plan Ahead Brand where Cabin No is specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		---- Step 4 Connecting Flight Plan Ahead Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode --AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		------------------ Step 5 First NonStop Flight AnyTime Brand where Cabin No is specified
		UPDATE #AllOneWayResponses 
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOneAnytimeCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 0 AND
			resp.isNonStopFlight = 1 AND resp.points is NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		--------------------- Step 6 First NonStop Flight AnyTime Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 0 AND
			resp.isNonStopFlight = 1 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		------------------ Step 7 Connecting Flight Anytime Brand where Cabin No is specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOneAnytimeCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		---- Step 8 Connecting Flight AnyTime Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode --AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass
		--select '2',points,isAvailable,* from #AllOneWayResponses
	END
	ELSE IF(@isShuttleSearch = 1 AND (@AwardCodeSearched IS NULL OR @AwardCodeSearched = ''))
	BEGIN
		------------------ Step 1 First NonStop Flight Plan Ahead Brand where Cabin No is specified
		--SELECT '1111'
		UPDATE #AllOneWayResponses 
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 0 
			AND redeem.isExcludeConnectingFlights = 1 AND
			resp.isNonStopFlight = 1 AND resp.points is NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass
		--------------------- Step 2 First NonStop Flight Plan Ahead Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 0
			AND redeem.isExcludeConnectingFlights = 1 AND
			resp.isNonStopFlight = 1 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		------------------ Step 3 Connecting Flight Plan Ahead Brand where Cabin No is specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		---- Step 4 Connecting Flight Plan Ahead Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode --AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		------------------ Step 5 First NonStop Flight AnyTime Brand where Cabin No is specified
		UPDATE #AllOneWayResponses 
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOneAnytimeCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 0 
			AND redeem.isExcludeConnectingFlights = 1 
			AND resp.isNonStopFlight = 1 AND resp.points is NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		--------------------- Step 6 First NonStop Flight AnyTime Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 0 
			AND redeem.isExcludeConnectingFlights = 1
			AND resp.isNonStopFlight = 1 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		------------------ Step 7 Connecting Flight Anytime Brand where Cabin No is specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOneAnytimeCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		---- Step 8 Connecting Flight AnyTime Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode --AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND redeem.isExcludeNonStop = 1 AND
			resp.isNonStopFlight = 0 AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass
		--select '2',points,isAvailable,* from #AllOneWayResponses
	END
	ELSE
	BEGIN
		UPDATE #AllOneWayResponses 
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOnePlanAheadCabinCount = noOfCabinMatched
			WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND resp.points is NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass
		--------------------- Step 2 First NonStop Flight Plan Ahead Brand where Cabin No is not specified
		UPDATE #AllOneWayResponses
		SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
			FROM #AllOneWayResponses resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
			WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PLANAHEAD' AND resp.points IS NULL
		) A
		where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		IF(@isPartnerOverridesAA = 0)
		BEGIN
			UPDATE #AllOneWayResponses 
			SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
			FROM
			(
				SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
				FROM #AllOneWayResponses resp
				INNER JOIN #RedeemRules redeem
				ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode AND resp.airOneAnytimeCabinCount = noOfCabinMatched
				WHERE redeem.noOfCabinMatched IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND resp.points is NULL
			) A
			where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass
			--------------------- Step 2 First NonStop Flight Plan Ahead Brand where Cabin No is not specified
			UPDATE #AllOneWayResponses
			SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
			FROM
			(
				SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
				FROM #AllOneWayResponses resp
				INNER JOIN #RedeemRules redeem
				ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
				WHERE redeem.noOfCabinMatched IS NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'ANYTIME' AND resp.points IS NULL
			) A
			where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass
		END
		ELSE
		BEGIN
			--IF((SELECT bookingCode from #RedeemRules where UPPER(awardName) = 'PARTNER' and UPPER(awardType) = 'PREMIUM ECONOMY') = 'Y')
			--BEGIN
	
				IF(@SelectedLeg1BookingClass = 'T' OR @awardCodeBookingCode = 'T')
				BEGIN
					INSERT INTO #RedeemRules_Mixed
					SELECT airlineCode,'Anytime',awardCode,points,bookingCode,awardType, ticketDesignator,isExcludeNonStop, noOfCabinMatched,BABookingCode,IBBookingCode,isExcludeConnectingFlights FROM #RedeemRules where UPPER(awardName) = 'PARTNER' and UPPER(awardType) <> 'COACH' 
				END
				ELSE
				BEGIN
					INSERT INTO #RedeemRules_Mixed
					SELECT airlineCode,'Anytime',awardCode,points,bookingCode,awardType, ticketDesignator,isExcludeNonStop, noOfCabinMatched,BABookingCode,IBBookingCode,isExcludeConnectingFlights FROM #RedeemRules where UPPER(awardName) = 'PARTNER' and UPPER(awardType) <> 'PREMIUM ECONOMY' 
				END
			--END 
			--ELSE
			--BEGIN
				--INSERT INTO #RedeemRules_Mixed
				--SELECT airlineCode,'Anytime',awardCode,points,bookingCode,awardType, ticketDesignator,isExcludeNonStop, noOfCabinMatched,BABookingCode,IBBookingCode,isExcludeConnectingFlights FROM #RedeemRules where UPPER(awardName) = 'PARTNER' 
			--END

			UPDATE #AllOneWayResponses
			SET points = A.points,awardCode = A.awardCode,ticketDesignator = A.ticketDesignator,awardName = A.awardName--,airLegBrandName = CASE WHEN UPPER(A.awardType) = 'ECONOMY' THEN 'Main' ELSE (CASE WHEN UPPER(A.awardType) = 'BUSINESS/FIRST' THEN 'Bus/First' ELSE A.awardType END) END
			FROM
			(
				SELECT redeem.points,redeem.awardName,redeem.AwardType,redeem.awardCode,airLegBookingClasses as bookingClass,resp.airOneResponsekey,redeem.ticketDesignator
				FROM #AllOneWayResponses resp
				INNER JOIN #RedeemRules_Mixed redeem
				ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
				WHERE resp.airLegBookingClasses IS NOT NULL AND resp.points IS NULL
			) A
			where #AllOneWayResponses.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses.airLegBookingClasses = A.bookingClass

		END

	END
		-- Need to work on Null Points Coming to be mapped with Proper 
		-- Temporarily until remove all where points are null

	delete from #AllOneWayResponses
	where points is null or isAvailable = 0

	--select '3',* from #AllOneWayResponses where points is null

	--select '4',* from #AllOneWayResponses where isAvailable = 0

	--select * from #AllOneWayResponses
	--return

		---------------------- Step 1 After Null, Unique Value Fetch ------------------------------				
	delete #AllOneWayResponses  
	FROM #AllOneWayResponses t,  
	(  
	SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses ,legConnections 
	FROM #AllOneWayResponses m  
	GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses  ,legConnections
	having count(1) > 1  
	) AS derived  
	WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived .airLegBookingClasses 
	AND t.legConnections = derived.legConnections
	AND points > minPoints

	delete #AllOneWayResponses  
	FROM #AllOneWayResponses t,  
	(  
	SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses ,legConnections 
	FROM #AllOneWayResponses m  
	GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses  ,legConnections
	having count(1) > 1  
	) AS derived  
	WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived .airLegBookingClasses 
	AND t.legConnections = derived.legConnections
	AND airOneIdent > minIdent

	--select resp.points,resp.awardCode,resp.ticketDesignator,* from AirResponse resp
	--inner join #AllOneWayResponses tt
	--on resp.airResponseKey = tt.airOneResponsekey

	UPDATE AirResponse SET AirResponse.points = fare.points ,  AirResponse.awardCode = fare.awardCode , AirResponse.ticketDesignator = fare.ticketDesignator 
	FROM AirResponse sResponse  INNER JOIN 
	#AllOneWayResponses fare on sResponse.airResponseKey = fare.airOneResponsekey
	where fare.airResponseMultiBrandKey Is Null 

	UPDATE AirResponseMultiBrand SET AirResponseMultiBrand.points = fare.points ,  AirResponseMultiBrand.awardCode = fare.awardCode , AirResponseMultiBrand.ticketDesignator = fare.ticketDesignator 
	FROM AirResponseMultiBrand sResponse  INNER JOIN 
	#AllOneWayResponses fare on sResponse.airResponseMultiBrandKey = fare.airResponseMultiBrandKey
	where fare.airResponseMultiBrandKey Is NOT Null 

	--select points,awardCode,ticketDesignator,* from AirResponse resp
	--inner join #AllOneWayResponses tt
	--on resp.airResponseKey = tt.airOneResponsekey

	--UPDATE AirResponseMultiBrand SET points = fare.points,awardCode = awardCode , ticketDesignator = ticketDesignator
	--FROM AirResponseMultiBrand sResponse  INNER JOIN 
	--#AllOneWayResponses fare on sResponse.airResponseMultiBrandKey = fare.airResponseMultiBrandkey
	--where fare.airResponseMultiBrandKey Is NOT Null 

	INSERT INTO #AllOneWayResponses_Temp(airOneResponsekey ,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey ,cabinclass  ,legConnections,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,points,awardCode,awardName,isAvailable)
	SELECT t.airOneResponsekey, t.airSegmentFlightNumber,t.airSegmentMarketingAirlineCode,t.airsubRequestkey ,t.cabinclass  ,t.legConnections,  t.airLegBrandName,t.airLegBookingClasses,t.airResponseMultiBrandkey,t.isMultiBrandFare,t.gdsSourceKey,t.childResponsekey,t.points,t.awardCode,t.awardName,t.isAvailable
	FROM #AllOneWayResponses t,
	(
	SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections
	FROM #AllOneWayResponses m  
	GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections  
	having count(1) > 1  
	) AS derived 
	WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode
	AND t.legConnections = derived.legConnections
	AND points >  minPoints 


	delete #AllOneWayResponses  
	FROM #AllOneWayResponses t,  
	(  
	SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections  
	FROM #AllOneWayResponses m  
	GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode ,legConnections   
	having count(1) > 1  
	) AS derived  
	WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
	AND t.legConnections = derived.legConnections
	AND (points) >  minPoints

	delete #AllOneWayResponses  
	FROM #AllOneWayResponses t,  
	(  
	SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections  
	FROM #AllOneWayResponses m  
	GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode ,legConnections   
	having count(1) > 1  
	) AS derived  
	WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
	AND t.legConnections = derived.legConnections
	AND (airOneIdent) >  minIdent

	--INSERT INTO @Temp_AllOneWayResponses(airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)
			--SELECT derived.airOneResponsekey, t.airOnePriceBase ,t.airOnePriceBaseSenior,t.airOnePriceTaxSenior, t.airOnePriceBaseChildren ,t.airOnePriceTaxChildren ,t.airOnePriceBaseInfant, t.airOnePriceTaxInfant,t.airOnePriceBaseYouth, t.airOnePriceTaxYouth, t.airOnePriceBaseTotal, t.airOnePriceTaxTotal,t.airOnePriceBaseDisplay, t.airOnePriceTaxDisplay,t.airSegmentFlightNumber,t.airSegmentMarketingAirlineCode,t.airsubRequestkey,t.airOnePriceTax ,t.airpriceTotal ,t.cabinclass  ,t.legConnections,t.airOnePriceBaseInfantWithSeat, t.airOnePriceTaxInfantWithSeat,  t.airLegBrandName,t.airLegBookingClasses,t.airResponseMultiBrandkey,t.isMultiBrandFare,t.gdsSourceKey,t.childResponsekey,t.isRefundable
			--FROM #AllOneWayResponses t,
			--(
			--SELECT m.airOneResponsekey, m.airOnePriceBase ,m.airOnePriceBaseSenior,m.airOnePriceTaxSenior, m.airOnePriceBaseChildren ,m.airOnePriceTaxChildren ,m.airOnePriceBaseInfant, m.airOnePriceTaxInfant,m.airOnePriceBaseYouth, m.airOnePriceTaxYouth, m.airOnePriceBaseTotal, m.airOnePriceTaxTotal,m.airOnePriceBaseDisplay, m.airOnePriceTaxDisplay,m.airSegmentFlightNumber,m.airSegmentMarketingAirlineCode,m.airsubRequestkey,m.airOnePriceTax ,m.airpriceTotal ,m.cabinclass  ,m.legConnections,m.airOnePriceBaseInfantWithSeat, m.airOnePriceTaxInfantWithSeat,  m.airLegBrandName,m.airLegBookingClasses,m.airResponseMultiBrandkey,m.isMultiBrandFare,m.gdsSourceKey,m.childResponsekey,m.isRefundable
			--FROM #AllOneWayResponses m  
			--where m.isMultiBrandFare = 0 AND (m.airsubRequestkey = @airBundledRequest OR m.airsubRequestkey = @airPublishedFareRequest OR m.airsubRequestkey = @airSubRequestKey OR m.airsubRequestkey = @airMultiCabinRequest OR m.airsubRequestkey = @airMultiCabinBundledRequest)
			--) AS derived 
			--WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode
			--AND t.isMultiBrandFare = 1 
	END	

	IF EXISTS(SELECT TOP 1 airResponseKey FROM #AirResponse WHERE airSubRequestKey = @airSubRequestKey)
	BEGIN

		INSERT #AllOneWayResponses_Partner (airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey ,cabinclass  ,legConnections,  airLegBrandName,airLegBookingClasses,gdsSourceKey,isAvailable,isMultiBrandFare,childResponsekey)  
		SELECT resp.airresponsekey,flightNumber,airlines,resp .airSubRequestKey ,n.cabinclass    ,n.airLegConnections ,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2) ,resp.isAvailable,0,resp.airResponseKey
		FROM #NormalizedAirResponses n  WITH (NOLOCK) inner join #AirResponse resp  WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey and airlegnumber = @airRequestTypeKey    
		AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) 
		
		INSERT #AllOneWayResponses_Partner (airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey ,cabinclass  ,legConnections,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isAvailable)  
		SELECT resp.airresponsekey,flightNumber,airlines,resp .airSubRequestKey  ,n.cabinclass    ,n.airLegConnections ,n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.isAvailable
		From #NormalizedAirResponsesMultiBrand n  WITH (NOLOCK) inner join #AirResponseMultiBrand resp  WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey =@airSubRequestKey      and airlegnumber = @airRequestTypeKey    
		and ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )

		Delete P  
		FROM #AllOneWayResponses_Partner  P  
		INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey  

		Delete P  
		FROM #AllOneWayResponses_Partner  P  
		INNER JOIN @tempResponseToRemove_MultiBrand T  ON P.airResponseMultiBrandKey = T.airresponseMultiBrandkey 
		where P.airResponseMultiBrandKey IS NOT NULL AND P.isMultiBrandFare = 1

		UPDATE #AllOneWayResponses_Partner
		SET isNonStopFlight = 1
		WHERE airSegmentFlightNumber NOT LIKE '%,%'

		delete #AllOneWayResponses_Partner 
		FROM #AllOneWayResponses_Partner t,  
		(  
		SELECT MIN(airOneIdent )  AS minIdent,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,legConnections   
		FROM #AllOneWayResponses_Partner m 
		GROUP BY airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,legConnections
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode
		 AND t.airLegBookingClasses =derived .airLegBookingClasses AND t.legConnections = derived.legConnections
		AND airOneIdent > minIdent	

		--SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
		--	FROM #AllOneWayResponses_Partner resp
		--	INNER JOIN #RedeemRules redeem
		--	ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.bookingCode
			--WHERE resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode LIKE '%BA%'

		UPDATE #AllOneWayResponses_Partner 
		SET points = A.points,awardCode = A.awardCode,awardName = A.awardName,ticketDesignator = A.ticketDesignator,cabinclass = CASE WHEN (UPPER(A.awardType) = 'COACH') THEN 'Economy' ELSE A.awardType END,airLegBrandName = CASE WHEN (UPPER(A.awardType) = 'COACH') THEN 'Main' ELSE (CASE WHEN (UPPER(A.awardType) = 'PREMIUM ECONOMY') THEN 'Select' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
			FROM #AllOneWayResponses_Partner resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.BookingCode
			WHERE resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode LIKE '%AA%'
		) A
		where #AllOneWayResponses_Partner.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses_Partner.airLegBookingClasses = A.bookingClass and 
		#AllOneWayResponses_Partner.airSegmentMarketingAirlineCode = marketingCode

		UPDATE #AllOneWayResponses_Partner 
		SET points = A.points,awardCode = A.awardCode,awardName = A.awardName,ticketDesignator = A.ticketDesignator,cabinclass = CASE WHEN (UPPER(A.awardType) = 'COACH') THEN 'Economy' ELSE A.awardType END,airLegBrandName = CASE WHEN (UPPER(A.awardType) = 'COACH') THEN 'Main' ELSE (CASE WHEN (UPPER(A.awardType) = 'PREMIUM ECONOMY') THEN 'Select' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
			FROM #AllOneWayResponses_Partner resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.BABookingCode
			WHERE resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode LIKE '%BA%'
		) A
		where #AllOneWayResponses_Partner.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses_Partner.airLegBookingClasses = A.bookingClass and 
		#AllOneWayResponses_Partner.airSegmentMarketingAirlineCode = marketingCode

		UPDATE #AllOneWayResponses_Partner 
		SET points = A.points,awardCode = A.awardCode,awardName = A.awardName,ticketDesignator = A.ticketDesignator,cabinclass = CASE WHEN (UPPER(A.awardType) = 'COACH') THEN 'Economy' ELSE A.awardType END,airLegBrandName = CASE WHEN (UPPER(A.awardType) = 'COACH') THEN 'Main' ELSE (CASE WHEN (UPPER(A.awardType) = 'PREMIUM ECONOMY') THEN 'Select' ELSE A.awardType END) END
		FROM
		(
			SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
			FROM #AllOneWayResponses_Partner resp
			INNER JOIN #RedeemRules redeem
			ON SUBSTRING(resp.airLegBookingClasses,1,1) = redeem.IBBookingCode
			WHERE resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode LIKE '%IB%'
		) A
		where #AllOneWayResponses_Partner.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses_Partner.airLegBookingClasses = A.bookingClass and 
		#AllOneWayResponses_Partner.airSegmentMarketingAirlineCode = marketingCode


		delete from #AllOneWayResponses_Partner
		where points is null or isAvailable = 0

		-- isAvailable bit pending

		delete #AllOneWayResponses_Partner  
		FROM #AllOneWayResponses_Partner t,  
		(  
		SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses ,legConnections 
		FROM #AllOneWayResponses_Partner m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses  ,legConnections
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived .airLegBookingClasses 
		AND t.legConnections = derived.legConnections
		AND points > minPoints

		delete #AllOneWayResponses_Partner  
		FROM #AllOneWayResponses_Partner t,  
		(  
		SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses ,legConnections 
		FROM #AllOneWayResponses_Partner m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses  ,legConnections
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived .airLegBookingClasses 
		AND t.legConnections = derived.legConnections
		AND airOneIdent > minIdent

		UPDATE AirResponse SET AirResponse.points = fare.points ,  AirResponse.awardCode = fare.awardCode , AirResponse.ticketDesignator = fare.ticketDesignator,AirResponse.cabinClass = fare.cabinclass  
		FROM AirResponse sResponse  INNER JOIN 
		#AllOneWayResponses_Partner fare on sResponse.airResponseKey = fare.airOneResponsekey
		where fare.airResponseMultiBrandKey Is Null 

		UPDATE AirResponseMultiBrand SET AirResponseMultiBrand.points = fare.points ,  AirResponseMultiBrand.awardCode = fare.awardCode , AirResponseMultiBrand.ticketDesignator = fare.ticketDesignator ,AirResponseMultiBrand.cabinClass = fare.cabinclass 
		FROM AirResponseMultiBrand sResponse  INNER JOIN 
		#AllOneWayResponses_Partner fare on sResponse.airResponseMultiBrandKey = fare.airResponseMultiBrandKey
		where fare.airResponseMultiBrandKey Is NOT Null 

		UPDATE AirSegments SET AirSegments.airsegmentCabin = fare.cabinclass 
		FROM AirSegments sSegments  INNER JOIN 
		#AllOneWayResponses_Partner fare on sSegments.airResponseKey = fare.airOneResponsekey
		where fare.airResponseMultiBrandKey Is Null 

		UPDATE AirSegmentsMultiBrand SET AirSegmentsMultiBrand.airsegmentCabin = fare.cabinclass  
		FROM AirSegmentsMultiBrand sSegments  INNER JOIN 
		#AllOneWayResponses_Partner fare on sSegments.airResponseMultiBrandKey = fare.airResponseMultiBrandKey
		where fare.airResponseMultiBrandKey Is NOT Null 

		--UPDATE AirSegments SET AirSegments.airsegmentCabin = fare.cabinclass,  AirSegments.airSegmentBrandName = fare.airLegBrandName 
		--FROM AirSegments sResponse  INNER JOIN 
		--#AllOneWayResponses_Partner fare on sResponse.airResponseKey = fare.airOneResponsekey
		--where fare.airResponseMultiBrandKey Is Null 

		--UPDATE AirSegmentsMultiBrand SET AirSegmentsMultiBrand.airsegmentCabin = fare.cabinclass,  AirSegmentsMultiBrand.airSegmentBrandName = fare.airLegBrandName
		--FROM AirResponseMultiBrand sResponse  INNER JOIN 
		--#AllOneWayResponses_Partner fare on sResponse.airResponseMultiBrandKey = fare.airResponseMultiBrandKey
		--where fare.airResponseMultiBrandKey Is NOT Null 

		--DROP TABLE #Airsegments

		--SELECT * INTO #Airsegments FROM AirSegments WHERE airResponseKey in (SELECT airResponseKey FROM #AirResponse)

		---- Ashima May be we need to update cabin class and segmnet level brand name too
		
		INSERT INTO #AllOneWayResponses_Temp_Partner(airOneResponsekey ,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey ,cabinclass  ,legConnections,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,points,awardCode,awardName,isAvailable)
		SELECT t.airOneResponsekey, t.airSegmentFlightNumber,t.airSegmentMarketingAirlineCode,t.airsubRequestkey ,t.cabinclass  ,t.legConnections,  t.airLegBrandName,t.airLegBookingClasses,t.airResponseMultiBrandkey,t.isMultiBrandFare,t.gdsSourceKey,t.childResponsekey,t.points,t.awardCode,t.awardName,t.isAvailable
		FROM #AllOneWayResponses_Partner t,
		(
		SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections
		FROM #AllOneWayResponses_Partner m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections  
		having count(1) > 1  
		) AS derived 
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode
		AND t.legConnections = derived.legConnections
		AND points >  minPoints 


		delete #AllOneWayResponses_Partner  
		FROM #AllOneWayResponses_Partner t,  
		(  
		SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections  
		FROM #AllOneWayResponses_Partner m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode ,legConnections   
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
		AND t.legConnections = derived.legConnections
		AND (points) >  minPoints

		delete #AllOneWayResponses_Partner  
		FROM #AllOneWayResponses_Partner t,  
		(  
		SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,legConnections  
		FROM #AllOneWayResponses_Partner m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode ,legConnections   
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
		AND t.legConnections = derived.legConnections
		AND (airOneIdent) >  minIdent

	END

		/****STEP 6: KEEP ALL OW Upsell into @Temp_AllOneWayResponses ****/
			
	
			--/****UPDATE Main Table with the Same Set of Data From @Temp_AllOneWayResponses ****/
			--UPDATE #AllOneWayResponses  SET airOneResponsekey = T.airOneResponsekey
			--FROM @Temp_AllOneWayResponses T 
			--Where #AllOneWayResponses.airOneResponsekey = T.childResponsekey


			

	 
	-- Remaining Uniqueness of flights for IB,BA Criteria
	-- Only AA Section Begins

	---------------- Step 1 Null Combinations Removal --------------------------

	--CREATE TABLE #AdditionalFares 
	--( 
	--airOneIdent int identity(1,1),
	--airresponsekey varchar(200) , 
	--airLegBrandName varchar(200) ,
	--TotalPointsToDisplay int,
	--isAvailable bit,
	--awardType nvarchar(50),
	--awardCode nvarchar(20),
	--awardName nvarchar(20),
	--ticketDesignator nvarchar(50),
	--bookingCode nvarchar(10)
	----ReasonCode NVARCHAR(10) DEFAULT 'NONE'
	--)

	CREATE TABLE #AdditionalFares 
	( 
	airOneIdent int identity(1,1),
	airresponsekey varchar(200) , 
	airresponseMultiBrandkey varchar(200) ,
	airLegBrandName varchar(200) ,
	airBookingClassName varchar(200),
	airResBookDesigCode varchar(10),
	TotalPointsToDisplay int,
	isAvailable bit,
	awardType nvarchar(50),
	awardCode nvarchar(20),
	awardName nvarchar(20),
	ticketDesignator nvarchar(50),
	bookingCode nvarchar(10),
    isDisabled bit default 0
	--ReasonCode NVARCHAR(10) DEFAULT 'NONE'
	)

	DECLARE @rowIndex AS INT =0 
	CREATE table #normalizedResultSet       
	(  
	airresponsekey uniqueidentifier ,  
	noOFSTOPs int ,  
	gdssourcekey int ,  
	noOfAirlines int ,  
	takeoffdate datetime ,  
	landingdate datetime ,   
	airlineCode varchar(60),  
	airsubrequetkey int  ,  
	cabinclass varchar(20),
	otherlegAirlines varchar(40),
	noOfOtherlegairlines int ,
	legconnections varchar(100),actualNoOFStops INT,
	legDurationInMinutes INT ,
	legDuration INT ,
	startingFlightNumber Varchar(10),
	startingFlightAirline Varchar(20),
	rowNumber INT,
	isSameAirlinesItin bit default 0 ,
	isLowestJourneyTime bit default 0,  
	lastFlightNumber Varchar(10),
	lastFlightAirline Varchar(20) ,
	airLegBrandName varchar(200),
	awardName nvarchar(20),
	points int,
	awardType nvarchar(50),
	awardCode nvarchar(20),
	isAvailable bit,
	ticketDesignator nvarchar(50),
	airlegBookingClass nvarchar(20),
	airresponseMultiBrandkey uniqueidentifier NULL ,
	)   

	--IF(@airFlight_ITARequest > 0)
	--BEGIN
	--INSERT INTO #AdditionalFares(airResponseKey,airLegBrandName,TotalPointsToDisplay,isAvailable,awardType,awardCode,awardName,ticketDesignator,bookingCode)
	--SELECT t.airOneResponsekey,t.airLegBrandName,t.points,t.isAvailable,t.awardType,t.awardCode,t.awardName,t.ticketDesignator,t.airLegBookingClasses
	--From #AllOneWayResponses_Temp t 
	--ORDER BY t.airOneResponsekey,(t.points)

	INSERT INTO #AdditionalFares(airResponseKey,airresponseMultiBrandkey,TotalPointsToDisplay,airLegBrandName, airBookingClassName, airResBookDesigCode,isAvailable,awardCode,awardName)
	SELECT TM.airOneResponsekey,TM.airResponseMultiBrandKey,(TM.points),TM.airLegBrandName, TM.cabinclass, TM.airLegBookingClasses,TM.isAvailable,TM.awardCode,TM.awardName
	From #AllOneWayResponses t
	INNER JOIN #AllOneWayResponses_Temp TM
	ON t.airOneResponsekey = TM.airOneResponsekey 
	ORDER BY TM.airOneResponsekey,(TM.points)
	

	INSERT  #normalizedResultSet (airresponsekey ,noOFSTOPs ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey  ,airsubrequetkey ,cabinclass  ,legConnections,actualNoOFStops,isSameAirlinesItin,points,airlegBookingClass,awardName,awardCode,isAvailable,airLegBrandName,airresponseMultiBrandkey)  
	(  
	SELECT seg.airresponsekey ,CASE WHEN resp.gdsSourceKey = 12 THEN seg.airSegmentStops  ELSE (CASE WHEN COUNT(seg.airresponsekey )-1  > 1 THEN (CASE WHEN @MaxNoofstops=2 THEN 2 ELSE 1 END) ELSE  COUNT(seg.airresponsekey )-1 END) END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ), 

	CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
	resp.gdsSourceKey ,result.airsubRequestkey  ,result.cabinclass    ,result.legConnections,COUNT(seg.airresponsekey )-1,0,result.points,result.airLegBookingClasses,result.awardname,result.awardCode,result.isAvailable,result.airLegBrandName,result.airResponseMultiBrandKey
	FROM   
	#AllOneWayResponses result  INNER JOIN   
	#AirResponse resp  WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey   
	INNER JOIN  
	#AirSegments seg WITH(NOLOCK) ON result .airOneResponsekey = seg.airResponseKey   
	WHERE airLegNumber = @airRequestTypeKey
	GROUP BY seg.airResponseKey ,resp.gdsSourceKey  , result.airsubRequestkey  ,result.cabinclass   ,legConnections ,result.points,result.airLegBookingClasses,result.awardname,result.awardCode,result.isAvailable,result.airLegBrandName,result.airResponseMultiBrandKey,airSegmentStops)

	INSERT INTO #AdditionalFares(airResponseKey,airresponseMultiBrandkey,TotalPointsToDisplay,airLegBrandName, airBookingClassName, airResBookDesigCode,isAvailable,awardCode,awardName)
	SELECT TM.airOneResponsekey,TM.airResponseMultiBrandKey,(TM.points),TM.airLegBrandName, TM.cabinclass, TM.airLegBookingClasses,TM.isAvailable,TM.awardCode,TM.awardName
	From #AllOneWayResponses_Partner t
	INNER JOIN #AllOneWayResponses_Temp_Partner TM
	ON t.airOneResponsekey = TM.airOneResponsekey 
	ORDER BY TM.airOneResponsekey,(TM.points)
	

	INSERT  #normalizedResultSet (airresponsekey ,noOFSTOPs ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey  ,airsubrequetkey ,cabinclass  ,legConnections,actualNoOFStops,isSameAirlinesItin,points,airlegBookingClass,awardName,awardCode,isAvailable,airLegBrandName,airresponseMultiBrandkey)  
	(  
	SELECT seg.airresponsekey ,CASE WHEN resp.gdsSourceKey = 12 THEN seg.airSegmentStops  ELSE (CASE WHEN COUNT(seg.airresponsekey )-1  > 1 THEN (CASE WHEN @MaxNoofstops=2 THEN 2 ELSE 1 END) ELSE  COUNT(seg.airresponsekey )-1 END) END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ), 

	CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
	resp.gdsSourceKey ,result.airsubRequestkey  ,result.cabinclass    ,result.legConnections,COUNT(seg.airresponsekey )-1,0,result.points,result.airLegBookingClasses,result.awardname,result.awardCode,result.isAvailable,result.airLegBrandName,result.airResponseMultiBrandKey
	FROM   
	#AllOneWayResponses_Partner result  INNER JOIN   
	#AirResponse resp  WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey   
	INNER JOIN  
	#AirSegments seg WITH(NOLOCK) ON result .airOneResponsekey = seg.airResponseKey   
	WHERE airLegNumber = @airRequestTypeKey
	GROUP BY seg.airResponseKey ,resp.gdsSourceKey  , result.airsubRequestkey  ,result.cabinclass   ,legConnections ,result.points,result.airLegBookingClasses,result.awardname,result.awardCode,result.isAvailable,result.airLegBrandName,result.airResponseMultiBrandKey,airSegmentStops)



	

	--END


	--INSERT  #normalizedResultSet (airresponsekey ,noOFSTOPs ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey  ,airsubrequetkey ,cabinclass  ,legConnections,actualNoOFStops,isSameAirlinesItin,points,airlegBookingClass,awardName,awardType,awardCode,isAvailable,ticketDesignator,airLegBrandName)  
	--(  
	--SELECT seg.airresponsekey ,CASE WHEN resp.gdsSourceKey = 12 THEN seg.airSegmentStops  ELSE (CASE WHEN COUNT(seg.airresponsekey )-1  > 1 THEN (CASE WHEN @MaxNoofstops=2 THEN 2 ELSE 1 END) ELSE  COUNT(seg.airresponsekey )-1 END) END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ), 

	--CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
	--resp.gdsSourceKey ,result.airsubRequestkey  ,result.cabinclass    ,result.legConnections,COUNT(seg.airresponsekey )-1,0,result.points,result.airLegBookingClasses,result.awardname,result.awardType,result.awardCode,result.isAvailable,result.ticketDesignator,result.airLegBrandName
	--FROM   
	--#AllOneWayResponses result  INNER JOIN   
	--#AirResponse resp  WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey   
	--INNER JOIN  
	--#AirSegments seg WITH(NOLOCK) ON result .airOneResponsekey = seg.airResponseKey   
	--WHERE airLegNumber = @airRequestTypeKey
	--GROUP BY seg.airResponseKey ,resp.gdsSourceKey  , result.airsubRequestkey  ,result.cabinclass   ,legConnections ,result.points,result.airLegBookingClasses,result.awardname,result.awardType,result.awardCode,result.isAvailable,result.ticketDesignator,result.airLegBrandName,airSegmentStops)


	-- Now section for BA,IB Begins For NonStop Flights
	--IF EXISTS(SELECT TOP 1 airOneSegmentKey From #AllOneWayResponses_Avail_Temp)
	--BEGIN
		
	--insert into #AllOneWayResponses_Avail_Temp1(airOneIdent,airOneResponsekey,airOneSegmentKey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,cabinclass,airLegBookingClasses,segmentOrder,gdsSourceKey,airSegmentSeatRemaining,airSegmentOperatingAirlineCode,isNonStopFlight,
	--legWiseFlightCombination,legWiseAirlineCombination,legWiseOperatingAirlineCombination,airGroupId)
	--SELECT airOneIdent,airOneResponsekey,airOneSegmentKey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,cabinclass,airLegBookingClasses,segmentOrder,gdsSourceKey,airSegmentSeatRemaining,airSegmentOperatingAirlineCode,isNonStopFlight,
	--legWiseFlightCombination,legWiseAirlineCombination,legWiseOperatingAirlineCombination,airGroupId
	--from #AllOneWayResponses_Avail_Temp
	--where isNonStopFlight = 0

	--delete from #AllOneWayResponses_Avail_Temp 
	--where isNonStopFlight = 0

	----select '1 stop IB,BA',* from #AllOneWayResponses_Avail_Temp

	----Now finding the Uniquenesss
	--delete #AllOneWayResponses_Avail_Temp  
	--FROM #AllOneWayResponses_Avail_Temp t,  
	--(  
	--SELECT MIN(airOneIdent )  AS minIdent,airGroupId,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses   
	--FROM #AllOneWayResponses_Avail_Temp m 
	--GROUP BY   airGroupId,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses
	--having count(1) > 1  
	--) AS derived  
	--WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode
	-- AND t.airLegBookingClasses =derived .airLegBookingClasses AND t.airGroupId = derived.airGroupId
	--AND airOneIdent > minIdent

	--UPDATE #AllOneWayResponses_Avail_Temp 
	--SET isAvailable = 0
	--WHERE airLegBookingClasses is NULL

	--UPDATE #AllOneWayResponses_Avail_Temp 
	--SET airOnePartnerPoints = A.points,awardCode = A.awardCode,awardName = A.awardName,awardType = A.awardType,ticketDesignator = A.ticketDesignator
	--FROM
	--(
	--	SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
	--	FROM #AllOneWayResponses_Avail_Temp resp
	--	INNER JOIN #RedeemRules redeem
	--	ON resp.airLegBookingClasses = redeem.bookingCode 
	--	WHERE resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode = 'AA'
	--) A
	--where #AllOneWayResponses_Avail_TEmp.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses_Avail_Temp.airLegBookingClasses = A.bookingClass and 
	--#AllOneWayResponses_Avail_Temp.airSegmentMarketingAirlineCode = marketingCode


	--UPDATE #AllOneWayResponses_Avail_Temp 
	--SET airOnePartnerPoints = A.points,awardCode = A.awardCode,awardName = A.awardName,awardType = A.awardType,ticketDesignator = A.ticketDesignator
	--FROM
	--(
	--	SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
	--	FROM #AllOneWayResponses_Avail_Temp resp
	--	INNER JOIN #RedeemRules redeem
	--	ON resp.airLegBookingClasses = redeem.BABookingCode 
	--	WHERE resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode = 'BA'
	--) A
	--where #AllOneWayResponses_Avail_TEmp.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses_Avail_Temp.airLegBookingClasses = A.bookingClass and 
	--#AllOneWayResponses_Avail_Temp.airSegmentMarketingAirlineCode = marketingCode

	--UPDATE #AllOneWayResponses_Avail_Temp 
	--SET airOnePartnerPoints = A.points,awardCode = A.awardCode,awardName = A.awardName,awardType = A.awardType,ticketDesignator = A.ticketDesignator
	--FROM
	--(
	--	SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
	--	FROM #AllOneWayResponses_Avail_Temp resp
	--	INNER JOIN #RedeemRules redeem
	--	ON resp.airLegBookingClasses = redeem.IBBookingCode 
	--	WHERE redeem.IBBookingCode IS NOT NULL AND resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode = 'IB'
	--) A
	--where #AllOneWayResponses_Avail_TEmp.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses_Avail_Temp.airLegBookingClasses = A.bookingClass and 
	--#AllOneWayResponses_Avail_Temp.airSegmentMarketingAirlineCode = marketingCode


	--SELECT @uniqueCabinPresent = COALESCE(@uniqueCabinPresent+',' ,'') + airLegBookingClasses 
	--FROM (SELECT DISTINCT airLegBookingClasses FROM #AllOneWayResponses_Avail_Temp) d

	--INSERT @tblBookingClass (airLegBookingClass) SELECT * FROM vault .dbo.ufn_CSVToTable (@uniqueCabinPresent)	

	--INSERT INTO #AllOneWayResponses_Temp_1(airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airLegBookingClasses,legConnections,isAvailable,airGroupId,gdsSourceKey)
	--SELECT Avail.airOneResponsekey,NAR.flightNumber,NAR.airlines,NAR.airSubRequestKey,bookClass.airLegBookingClass,NAR.airLegConnections,Avail.isAvailable,Avail.airGroupId,Avail.gdsSourceKey
	--FROM #AllOneWayResponses_Avail_Temp Avail
	--INNER JOIN #NormalizedAirResponses NAR
	--On Avail.airOneResponsekey = NAR.airResponseKey
	--CROSS JOIN @tblBookingClass bookClass 

	----SET points = A.points,awardCode = A.awardCode,awardType = A.awardType,awardName = A.awardName, ticketDesignator = A.ticketDesignator,cabinclass = A.awardType,airLegBrandName = CASE WHEN (UPPER(A.awardType) = 'COACH' OR UPPER(A.awardType) = 'PREMIUMECONOMY') THEN 'Main' ELSE A.awardType END
	--UPDATE #AllOneWayResponses_Temp_1 
	--SET points = A.points,awardCode = A.awardCode,awardType = A.awardType,awardName = A.awardName, ticketDesignator = A.ticketDesignator,cabinclass = A.awardType,airLegBrandName = CASE WHEN (UPPER(A.awardType) = 'COACH') THEN 'Main' ELSE (CASE WHEN (UPPER(A.awardType) = 'PREMIUM ECONOMY') THEN 'Select' ELSE A.awardType END) END
	--FROM
	--(
	--	SELECT airOnePartnerPoints as points,airLegBookingClasses as bookingClass,airOneResponsekey,awardType,awardName,ticketDesignator,awardCode
	--	FROM #AllOneWayResponses_Avail_Temp resp
	--) A
	--WHERE bookingClass = airLegBookingClasses AND #AllOneWayResponses_Temp_1.airOneResponsekey = A.airOneResponsekey


	------------------ Step 1 Null Combinations Removal --------------------------
	--delete #AllOneWayResponses_Temp_1  
	--FROM #AllOneWayResponses_Temp_1 t,  
	--(  
	--SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses   
	--FROM #AllOneWayResponses_Temp_1 m 
	--GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses
	--having count(1) > 1  and min(Points) is not null
	--) AS derived  
	--WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived .airLegBookingClasses 
	--AND points > minPoints or points is null
			
	------------------------ Step 2 After Null, Unique Value Fetch ------------------------------				
	--delete #AllOneWayResponses_Temp_1  
	--FROM #AllOneWayResponses_Temp_1 t,  
	--(  
	--SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses  
	--FROM #AllOneWayResponses_Temp_1 m  
	--GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses  
	--having count(1) > 1  
	--) AS derived  
	--WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived .airLegBookingClasses 
	--AND airOneIdent > minIdent 

	--INSERT INTO #AllOneWayResponses_Temp_Partner_NS_PE(airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,cabinclass,legConnections,airLegBrandName,airLegBookingClasses,gdsSourceKey,awardName,awardType,awardCode,isAvailable,ticketDesignator,points,airGroupId)
	--SELECT t.airOneResponsekey,t.airSegmentFlightNumber,t.airSegmentMarketingAirlineCode,t.airsubRequestkey ,t.cabinclass  ,t.legConnections,  t.airLegBrandName,t.airLegBookingClasses,t.gdsSourceKey,t.awardName,t.awardType,t.awardCode,t.isAvailable,t.ticketDesignator,t.points,t.airGroupId
	--FROM #AllOneWayResponses_Temp_1 t
	--WHERE airSegmentMarketingAirlineCode = 'AA' and airLegBookingClasses = 'Y'
	
	--UPDATE #AllOneWayResponses_Temp_Partner_NS_PE 
	--SET points = A.points,awardCode = A.awardCode,awardName = A.awardName,awardType = A.awardType,ticketDesignator = A.ticketDesignator,cabinclass = 'Premium Economy',airLegBrandName = 'Select'
	--FROM
	--(
	--	SELECT redeem.points,redeem.awardName,redeem.awardType,redeem.awardCode,redeem.ticketDesignator,airLegBookingClasses as bookingClass,resp.airOneResponsekey,airSegmentMarketingAirlineCode as marketingCode
	--	FROM #AllOneWayResponses_Avail_Temp resp
	--	INNER JOIN #RedeemRules redeem
	--	ON resp.airLegBookingClasses = redeem.bookingCode 
	--	WHERE resp.airLegBookingClasses IS NOT NULL AND UPPER(redeem.awardName) = 'PARTNER' AND resp.airSegmentMarketingAirlineCode = 'AA' AND redeem.awardType = 'Premium Economy'
	--) A
	--where #AllOneWayResponses_Temp_Partner_NS_PE.airOneResponsekey = A.airOneResponsekey and #AllOneWayResponses_Temp_Partner_NS_PE.airLegBookingClasses = A.bookingClass and 
	--#AllOneWayResponses_Temp_Partner_NS_PE.airSegmentMarketingAirlineCode = marketingCode

	--INSERT INTO #AllOneWayResponses_Temp_Partner_NS(airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,cabinclass,legConnections,airLegBrandName,airLegBookingClasses,gdsSourceKey,awardName,awardType,awardCode,isAvailable,ticketDesignator,points,airGroupId)
	--SELECT airOneResponsekey,t.airSegmentFlightNumber,t.airSegmentMarketingAirlineCode,t.airsubRequestkey ,t.cabinclass  ,t.legConnections,  t.airLegBrandName,t.airLegBookingClasses,t.gdsSourceKey,t.awardName,t.awardType,t.awardCode,t.isAvailable,t.ticketDesignator,t.points,t.airGroupId
	--FROM #AllOneWayResponses_Temp_1 t,
	--(
	--SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,MIN(airGroupId) as GroupId
	--FROM #AllOneWayResponses_Temp_1 m  
	--GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode    
	--having count(1) > 1  
	--) AS derived 
	--WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
	--AND points >  minPoints 

	--INSERT INTO #AllOneWayResponses_Temp_Partner_NS(airOneResponsekey,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,cabinclass,legConnections,airLegBrandName,airLegBookingClasses,gdsSourceKey,awardName,awardType,awardCode,isAvailable,ticketDesignator,points,airGroupId)
	--SELECT t.airOneResponsekey,t.airSegmentFlightNumber,t.airSegmentMarketingAirlineCode,t.airsubRequestkey ,t.cabinclass  ,t.legConnections,  t.airLegBrandName,t.airLegBookingClasses,t.gdsSourceKey,t.awardName,t.awardType,t.awardCode,t.isAvailable,t.ticketDesignator,t.points,t.airGroupId
	--FROM #AllOneWayResponses_Temp_Partner_NS_PE t

	--delete #AllOneWayResponses_Temp_1  
	--FROM #AllOneWayResponses_Temp_1 t,  
	--(  
	--SELECT min(points) AS minPoints,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode    
	--FROM #AllOneWayResponses_Temp_1 m  
	--GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode    
	--having count(1) > 1  
	--) AS derived  
	--WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
	--AND points >  minPoints

	--update #AllOneWayResponses_Temp_Partner_NS
	--set airOneResponsekey = #AllOneWayResponses_Temp_1.airOneResponsekey
	--FROM #AllOneWayResponses_Temp_1
	--where #AllOneWayResponses_Temp_Partner_NS.airGroupId = #AllOneWayResponses_Temp_1.airGroupId

	--INSERT INTO #AdditionalFares(airResponseKey,airLegBrandName,TotalPointsToDisplay,isAvailable,awardType,awardCode,awardName,ticketDesignator,bookingCode)
	--SELECT t.airOneResponsekey,t.airLegBrandName,t.points,t.isAvailable,t.awardType,t.awardCode,t.awardName,t.ticketDesignator,t.airLegBookingClasses
	--From #AllOneWayResponses_Temp_Partner_NS t 
	--ORDER BY t.airOneResponsekey,(t.points)

	--INSERT  #normalizedResultSet (airresponsekey ,noOFSTOPs ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey  ,airsubrequetkey ,cabinclass  ,legConnections,actualNoOFStops,isSameAirlinesItin,points,airlegBookingClass,awardName,awardType,awardCode,isAvailable,ticketDesignator,airLegBrandName)  
	--(  
	--SELECT seg.airresponsekey ,CASE WHEN resp.gdsSourceKey = 12 THEN seg.airSegmentStops  ELSE (CASE WHEN COUNT(seg.airresponsekey )-1  > 1 THEN (CASE WHEN @MaxNoofstops=2 THEN 2 ELSE 1 END) ELSE  COUNT(seg.airresponsekey )-1 END) END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ), 

	--CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
	--resp.gdsSourceKey ,result.airsubRequestkey  ,result.cabinclass    ,result.legConnections,COUNT(seg.airresponsekey )-1,0,result.points,result.airLegBookingClasses,result.awardname,result.awardType,result.awardCode,result.isAvailable,result.ticketDesignator,result.airLegBrandName
	--FROM   
	--#AllOneWayResponses_Temp_1 result  INNER JOIN   
	--#AirResponse resp  WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey   
	--INNER JOIN  
	--#AirSegments seg WITH(NOLOCK) ON result .airOneResponsekey = seg.airResponseKey   
	--WHERE airLegNumber = @airRequestTypeKey
	--GROUP BY seg.airResponseKey ,resp.gdsSourceKey  , result.airsubRequestkey  ,result.cabinclass   ,legConnections ,result.points,result.airLegBookingClasses,result.awardname,result.awardType,result.awardCode,result.isAvailable,result.ticketDesignator,result.airLegBrandName,airSegmentStops)
	--END
	/****Logic for lower connection point display Rick's recommendation point#9 ******/


	UPDATE  N SET takeoffdate = airSegmentDepartureDate  , startingFlightAirline = airSegmentMarketingAirlineCode , startingFlightNumber = airSegmentFlightNumber   FROM #normalizedResultSet N inner join
	#AirSegments seg  WITH (NOLOCK) ON N.airresponsekey = seg.airResponseKey  and seg.airLegNumber =@airRequestTypeKey and segmentOrder = 1 

	UPDATE  N SET landingdate  = airSegmentArrivalDate ,lastFlightAirline = airSegmentMarketingAirlineCode , lastFlightNumber = airSegmentFlightNumber    FROM #normalizedResultSet N inner join
	#AirSegments seg  WITH (NOLOCK) ON N.airresponsekey = seg.airResponseKey  and seg.airLegNumber =@airRequestTypeKey and segmentOrder = (n.actualNoOFStops + 1) 
		
	UPDATE  N SET legDurationInMinutes = DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),N.takeoffdate ), DATEADD( MINUTE, (@arrivalOffset*-1), N.landingdate) ),
	legDuration  = DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),N.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), N.landingdate) )
	FROM #normalizedResultSet N 

	;WITH tbl AS (
	SELECT *, ROW_NUMBER() OVER(ORDER BY legDurationInMinutes) AS RowNo FROM #normalizedResultSet
	)
	UPDATE #normalizedResultSet SET RowNumber = RowNo 
	FROM #normalizedResultSet N inner join tbl on n.airresponsekey = tbl.airresponsekey 

	UPDATE N SET isLowestJourneyTime = 1 FROM #normalizedResultSet N  WHERE noOFSTOPs = 0  

	SELECT * INTO #tmpDeparturesLowest 
	FROM 
	(SELECT  MIN(rowNumber) minRowIndex ,MAX(rowNumber) maxRowIndex, MIN(N.legDurationInMinutes) durationInMinutes,MAX(N.legDurationInMinutes) maximumDuration,COUNT(*) totalRecords ,noOFSTOPs ,startingFlightAirline ,startingFlightNumber, points FROM #normalizedResultSet N 
	GROUP BY noOFSTOPs ,startingFlightAirline ,startingFlightNumber , points--,N.legConnections
	) T 


	SELECT * INTO #tmpArrivalLowest 
	FROM 
	(
	SELECT MIN(rowNumber) minRowIndex ,MAX(rowNumber) maxRowIndex, MIN(N1.legDurationInMinutes) durationInMinutes,MAX(N1.legDurationInMinutes) maximumDuration,COUNT(*) totalRecords ,n1.noOFSTOPs ,n1.lastFlightAirline ,n1.lastFlightNumber ,n1.points 
	FROM #normalizedResultSet N1 
	INNER JOIN #tmpDeparturesLowest T1 ON N1.rowNumber = T1.minRowIndex 
	GROUP BY n1.noOFSTOPs ,n1.lastFlightAirline ,n1.lastFlightNumber  , N1.points--,N1.legConnections
	)T

	UPDATE  N1 SET isLowestJourneyTime = 1 FROM #normalizedResultSet N1 
	INNER JOIN #tmpArrivalLowest arrival 
	ON N1.rowNumber = arrival.minRowIndex

	UPDATE #normalizedResultSet SET isSameAirlinesItin = 1 WHERE (airlineCode = otherlegAirlines ) 
	and airlineCode <> 'Multiple Airlines' AND otherlegAirlines <> 'Multiple Airlines'


	UPDATE #normalizedResultSet SET isSameAirlinesItin = 1 WHERE  airlineCode = 'Multiple Airlines' 

	IF ( @airRequestType = 1) 
	BEGIN 
	UPDATE #normalizedResultSet SET isSameAirlinesItin = 1
	END
	
	/****Logic for lower connection point display Rick's recommendation point#9 END HERE ******/

	INSERT into #airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,

	airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,

	airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,

	MarketingAirlineName,NoOfSTOPs ,actualTakeOffDateForLeg,actualLandingDateForLeg ,

	airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , 

	gdsSourceKey  ,airRequestKey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,

	airSegmentSeatRemaining,airPriceClassSELECTed ,isRefundable ,isBrandedFare,

	cabinClass ,fareType ,segmentOrder ,airsegmentCabin,

	airSegmentOperatingFlightNumber,airSegmentOperatingAirlineCompanyShortName,legConnections ,legDuration,

	actualNoOFStops ,isSameAirlinesItin ,isLowestJourneyTime,agentwareQueryID,

	agentwareItineraryID,airsegmentPricingKey,airSegmentFareCategory,airLegBrandName,

	airSegmentBrandName,airSegmentBrandID,airSegmentBaggage,airSegmentMealCode,
	
	awardName,points,awardCode,
	isAvailable,airResponseMultiBrandkey
	)  

	SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,

	seg. airSegmentFlightNumber, seg.airSegmentDuration , (case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment , seg.airSegmentMiles ,

	seg.airSegmentDepartureDate ,  seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport ,

	airVendor.ShortName AS MarketingAirlineName ,noOFSTOPs  ,  takeoffdate  , landingdate ,

	airSegmentOperatingAirlineCode ,seg.airSegmentResBookDesigCode,noOfAirlines ,normalized .airlineCode ,

	ISNULL(normalized.gdssourcekey,2)   ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,

	airSegmentSeatRemaining,  airPriceClassSELECTed  ,refundable ,isBrandedFare ,

	normalized. cabinClass ,resp.faretype,seg.segmentOrder ,seg.airsegmentCabin,

	seg.airSegmentOperatingFlightNumber ,Replace(airSegmentOperatingAirlineCompanyShortName,'OPERATED BY','')  ,legconnections,DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),normalized.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), normalized.landingdate) ) ,

	actualNoOFStops ,isSameAirlinesItin,isLowestJourneyTime,agentwareQueryID,

	agentwareItineraryID,airsegmentPricingKey,airSegmentFareCategory,ISNULL(normalized.airLegBrandName,normalized.cabinclass),

	seg.airSegmentBrandName,seg.airSegmentBrandID,seg.airSegmentBaggage,seg.airSegmentMealCode,

	normalized.awardName as awardName,normalized .points AS points,normalized .awardCode AS awardCode,

	normalized.isAvailable as isAvailable,normalized.airresponseMultiBrandkey

	FROM #AirSegments seg  WITH (NOLOCK)   
	INNER JOIN #normalizedResultSet normalized ON seg.airresponsekey = normalized .airresponsekey   
	INNER JOIN #AirResponse resp WITH (NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noSTOPs nSTOP ON normalized .noOFSTOPs = nSTOP .sTOPs   
	INNER JOIN  AirVendorLookup airVendor WITH (NOLOCK)   ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode    
	LEFT OUTER JOIN AircraftsLookup WITH(NOLOCK) on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)  
	WHERE normalized.points  <=    @points and airLegNumber = @airRequestTypeKey 
	AND ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )  
	AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )   
	AND normalized.airresponseMultiBrandkey IS NULL

	--select '1',* from #airResponseResultset order by airSegmentFlightNumber

	INSERT into #airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,

	airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,

	airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,

	MarketingAirlineName,NoOfSTOPs ,actualTakeOffDateForLeg,actualLandingDateForLeg ,

	airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , 

	gdsSourceKey  ,airRequestKey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,

	airSegmentSeatRemaining,airPriceClassSELECTed ,isRefundable ,isBrandedFare,

	cabinClass ,fareType ,segmentOrder ,airsegmentCabin,

	airSegmentOperatingFlightNumber,airSegmentOperatingAirlineCompanyShortName,legConnections ,legDuration,

	actualNoOFStops ,isSameAirlinesItin ,isLowestJourneyTime,agentwareQueryID,

	agentwareItineraryID,airsegmentPricingKey,airSegmentFareCategory,airLegBrandName,

	airSegmentBrandName,airSegmentBrandID,airSegmentBaggage,airSegmentMealCode,
	
	awardName,points,awardCode,
	isAvailable,airResponseMultiBrandkey
	)  

	SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,

	seg. airSegmentFlightNumber, seg.airSegmentDuration , (case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment , seg.airSegmentMiles ,

	seg.airSegmentDepartureDate ,  seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport ,

	airVendor.ShortName AS MarketingAirlineName ,noOFSTOPs  ,  takeoffdate  , landingdate ,

	airSegmentOperatingAirlineCode ,segMulti.airSegmentResBookDesigCode,noOfAirlines ,normalized .airlineCode ,

	ISNULL(normalized.gdssourcekey,2)   ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,

	segMulti.airSegmentSeatRemaining,  respMulti.airPriceClassSELECTed  ,respMulti.refundable ,isBrandedFare ,

	normalized. cabinClass ,resp.faretype,seg.segmentOrder ,segMulti.airsegmentCabin,

	seg.airSegmentOperatingFlightNumber ,Replace(airSegmentOperatingAirlineCompanyShortName,'OPERATED BY','')  ,legconnections,DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),normalized.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), normalized.landingdate) ) ,

	actualNoOFStops ,isSameAirlinesItin,isLowestJourneyTime,agentwareQueryID,

	agentwareItineraryID,segMulti.airSegmentPricingKey,airSegmentFareCategory,ISNULL(normalized.airLegBrandName,normalized.cabinclass),

	segMulti.airSegmentBrandName,segMulti.airSegmentBrandID,segMulti.airSegmentBaggage,segMulti.airSegmentMealCode,

	normalized.awardName as awardName,normalized .points AS points,normalized .awardCode AS awardCode,

	normalized.isAvailable as isAvailable,normalized.airresponseMultiBrandkey

	FROM #AirSegments seg  WITH (NOLOCK)   
	INNER JOIN #normalizedResultSet normalized ON seg.airresponsekey = normalized .airresponsekey   
	INNER JOIN #AirResponse resp WITH (NOLOCK) ON seg .airresponsekey = resp.airResponseKey 
	INNER JOIN #AirResponseMultiBrand respMulti WITH (NOLOCK) on normalized.airresponseMultiBrandkey = respMulti.airResponseMultiBrandKey 
	INNER JOIN #AirSegmentsMultiBrand segMulti WITH (NOLOCK) on respMulti.airResponseMultiBrandKey = segMulti.airResponseMultiBrandKey
	INNER JOIN @noSTOPs nSTOP ON normalized .noOFSTOPs = nSTOP .sTOPs   
	INNER JOIN  AirVendorLookup airVendor WITH (NOLOCK)   ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode    
	LEFT OUTER JOIN AircraftsLookup WITH(NOLOCK) on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)  
	WHERE normalized.points  <=    @points and seg.airLegNumber = @airRequestTypeKey and segMulti.airLegNumber = @airRequestTypeKey
	AND ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )  
	AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )   
	AND normalized.airresponseMultiBrandkey IS NOT NULL

	delete #airResponseResultset  
	FROM #airResponseResultset t,  
	(  
	SELECT MIN(airRowNum )  AS minIdent,   airSegmentkey
	FROM #airResponseResultset m  
	GROUP BY   airSegmentKey
	having count(1) > 1  
	) AS derived  
	WHERE t.airSegmentKey = derived.airSegmentKey
	AND airRowNum > minIdent

	--return
	--INSERT into #airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,

	--airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,

	--airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,

	--MarketingAirlineName,NoOfSTOPs ,actualTakeOffDateForLeg,actualLandingDateForLeg ,

	--airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , 

	--gdsSourceKey  ,airRequestKey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,

	--airSegmentSeatRemaining,airPriceClassSELECTed ,isRefundable ,isBrandedFare,

	--cabinClass ,fareType ,segmentOrder ,airsegmentCabin,

	--airSegmentOperatingFlightNumber,airSegmentOperatingAirlineCompanyShortName,legConnections ,legDuration,

	--actualNoOFStops ,isSameAirlinesItin ,isLowestJourneyTime,agentwareQueryID,

	--agentwareItineraryID,airsegmentPricingKey,airSegmentFareCategory,airLegBrandName,

	--airSegmentBrandName,airSegmentBrandID,airSegmentBaggage,airSegmentMealCode,
	
	--awardName,points, awardType,awardCode,
	--isAvailable,ticketDesignator
	--)  

	--SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,

	--seg. airSegmentFlightNumber, seg.airSegmentDuration , (case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment , seg.airSegmentMiles ,

	--seg.airSegmentDepartureDate ,  seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport ,

	--airVendor.ShortName AS MarketingAirlineName ,noOFSTOPs  ,  takeoffdate  , landingdate ,

	--airSegmentOperatingAirlineCode ,normalized.airlegBookingClass,noOfAirlines ,normalized .airlineCode ,

	--ISNULL(normalized.gdssourcekey,2)   ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,

	--airSegmentSeatRemaining,  airPriceClassSELECTed  ,refundable ,isBrandedFare ,

	--normalized. cabinClass ,resp.faretype,seg.segmentOrder ,normalized.cabinclass,

	--seg.airSegmentOperatingFlightNumber ,airSegmentOperatingAirlineCompanyShortName  ,legconnections,DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),normalized.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), normalized.landingdate) ) ,

	--actualNoOFStops ,isSameAirlinesItin,isLowestJourneyTime,agentwareQueryID,

	--agentwareItineraryID,airsegmentPricingKey,airSegmentFareCategory,ISNULL(normalized.airLegBrandName,normalized.cabinclass),

	--ISNULL(normalized.airLegBrandName,normalized.cabinclass),seg.airSegmentBrandID,seg.airSegmentBaggage,seg.airSegmentMealCode,

	--normalized.awardName as awardName,normalized .points AS points,normalized .awardType AS awardType,normalized .awardCode AS awardCode,

	--normalized.isAvailable as isAvailable, normalized.ticketDesignator as ticketDesignator

	--FROM #AirSegments seg  WITH (NOLOCK)   
	--INNER JOIN #normalizedResultSet normalized ON seg.airresponsekey = normalized .airresponsekey   
	--INNER JOIN #AirResponse resp WITH (NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	--INNER JOIN @noSTOPs nSTOP ON normalized .noOFSTOPs = nSTOP .sTOPs   
	--INNER JOIN  AirVendorLookup airVendor WITH (NOLOCK)   ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode    
	--LEFT OUTER JOIN AircraftsLookup WITH(NOLOCK) on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)  
	--WHERE normalized.points  <=    @points and airLegNumber = @airRequestTypeKey 
	--AND ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )  
	--AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )  


--IF ((@MaxPointsAllowed != 0) and (@IsHideFare = 1))
--BEGIN
--	IF EXISTS(SELECT 1 FROM #airResponseResultset WHERE airresponsekey IN (SELECT A.airResponseKey from #airResponseResultset A WHERE A.totalCost > @MaxPointsAllowed))
--	BEGIN
--	SET @isOutOfPolicyResultsPresent = 1
--	END
--	DELETE FROM #airResponseResultset 
--	WHERE airresponsekey IN (SELECT A.airResponseKey from #airResponseResultset A WHERE ROUND(A.totalCost,2) > ROUND(@MaxPointsAllowed,2))
--  END

--IF (( @IsLowFareThreshold =1) AND (@LowFareThreshold > 0))
--BEGIN
--	SELECT @LowestPrice = (CASE WHEN @isTotalPriceSort = 0 THEN (MIN (airPrice)) ELSE  min(totalcost) end ) FROM #airResponseResultset

--	if (@HighFareTotal != 0) 
--	BEGIN
--		UPDATE #airResponseResultset 
--		SET ReasonCode = 'OOP' 
--		WHERE airResponsekey IN (SELECT A.airResponseKey 
--									FROM #airResponseResultset A 
--									WHERE ROUND(A.totalCost,2) > ROUND((@LowestPrice + @LowFareThreshold),2)
--									AND ROUND(A.totalCost,2) <= ROUND(@HighFareTotal,2))
--	END
--	ELSE
--	BEGIN
--		UPDATE #airResponseResultset 
--		SET ReasonCode = 'OOP' 
--		WHERE airResponsekey IN (SELECT A.airResponseKey 
--									FROM #airResponseResultset A 
--									WHERE ROUND(A.totalCost,2) > ROUND((@LowestPrice + @LowFareThreshold),2))
--	END
--END

--IF(@isMultiBrand = 1)
--BEGIN
--	IF ((@MaxPointsAllowed != 0) and (@IsHideFare = 1))
--	BEGIN
--		DELETE FROM #AdditionalFares 
--		WHERE airresponseMultiBrandkey IN (SELECT A.airResponseMultiBrandkey from #AdditionalFares A WHERE Round((A.TotalPriceToDisplay),2) > Round((@MaxPointsAllowed),2))
--	END

--	IF (( @IsLowFareThreshold =1) AND (@LowFareThreshold > 0))
--	BEGIN
		
--		SELECT @LowestPrice = (CASE WHEN @isTotalPriceSort = 0 THEN (MIN (airPrice)) ELSE  min(totalcost) end ) FROM #airResponseResultset
--		IF (@HighFareTotal != 0)
--		BEGIN
--			UPDATE #AdditionalFares 
--			SET ReasonCode = 'OOP' 
--			WHERE airresponseMultiBrandkey IN (SELECT A.airresponseMultiBrandkey 
--									 FROM #AdditionalFares A 
--									 WHERE ROUND(A.TotalPriceToDisplay,2) > ROUND((@LowestPrice + @LowFareThreshold),2)
--									 AND ROUND(A.TotalPriceToDisplay,2) <= ROUND(@HighFareTotal,2))

--		END
--		ELSE
--		BEGIN
--			UPDATE #AdditionalFares 
--			SET ReasonCode = 'OOP' 
--			WHERE airresponseMultiBrandkey IN (SELECT A.airresponseMultiBrandkey 
--									 FROM #AdditionalFares A 
--									 WHERE ROUND(A.TotalPriceToDisplay,2) > ROUND((@LowestPrice + @LowFareThreshold),2))
--		END
--	END
--END

if(@airRequestTypeKey=2)
	begin
	update #airResponseResultset
	SET multiBrandFaresInfo = (
	SELECT airresponsekey,airLegBrandName,airBookingClassName,airResBookDesigCode,TotalPointsToDisplay,isAvailable,awardType,awardCode,awardName,ticketDesignator,A.bookingCode,airresponseMultiBrandkey,
	case when b.[data]=c.bookingcode then 0 else 1 end as IsDisable
	FROM #AdditionalFares A
	outer apply Vault.dbo.UFn_StringSplit(airResBookDesigCode,',') as B
	left outer join #BookingClassAllowed c on c.bookingcode =b.[data] and airline = #airResponseResultset.airSegmentMarketingAirlineCode
	where A.airresponsekey = #airResponseResultset.airResponseKey
	group by airresponsekey,airLegBrandName,airBookingClassName,B.[Data],airResBookDesigCode ,TotalPointsToDisplay,isAvailable,awardType,awardCode,awardName,ticketDesignator,A.bookingCode,airresponseMultiBrandkey,airOneIdent,
	c.bookingcode
	order by airOneIdent
	FOR XML PATH('AdditionalFare'), ROOT('AdditionalFaresInfo')
	)
	end
	else
	begin
		update #airResponseResultset
	SET multiBrandFaresInfo = (
	SELECT airresponsekey,airLegBrandName,airBookingClassName,airResBookDesigCode,TotalPointsToDisplay,isAvailable,awardType,awardCode,awardName,ticketDesignator,A.bookingCode,airresponseMultiBrandkey,
	cast(0 as bit) as isDisable FROM #AdditionalFares A
	where A.airresponsekey = #airResponseResultset.airResponseKey
	order by airOneIdent
	FOR XML PATH('AdditionalFare'), ROOT('AdditionalFaresInfo')
	)
	end
	--vaibhav changes

	if(@airRequestTypeKey=2)
	begin
		Update t 
		SET 
			   t.isDisable= 0
		FROM 
			   #airResponseResultset t 
		inner join #BookingClassAllowed c on c.bookingcode =t.airSegmentResBookDesigCode
		 and airline = t.airSegmentMarketingAirlineCode
	end
	else
	begin
		Update t 
		SET 
			   t.isDisable= 0
		FROM 
			   #airResponseResultset t 
	end
	

	CREATE TABLE #pagingResultSet     
	(  
	rowNum int IDENTITY(1,1) NOT NULL,     
	airResponseKey uniqueidentifier  ,  
	airlineName varchar(100),   
	airPoints int ,   
	actualTakeOffDateForLeg datetime,
	isSmartFare bit default 0    
	)     

	IF @sortField <> ''  
	BEGIN  
		INSERT into #pagingResultSet (airResponseKey,airPoints ,actualTakeOffDateForLeg ,airlineName    )  
		SELECT    air.airResponseKey ,MIN(air.points) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air   
		INNER JOIN #normalizedResultSet normalized on air.airresponsekey = normalized .airresponsekey   
		INNER  JOIN @tmpAirline airline on (normalized .airlineCode  = airline.airLineCode   )   
		INNER JOIN @noSTOPs nSTOP ON normalized .noOFSTOPs = nSTOP .sTOPs   
		AND ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )  
		AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )  
		GROUP BY air.airResponseKey,airlineName ,normalized.legDurationInMinutes   order by   
		CASE WHEN @sortField  = 'Points'      THEN MIN(air.NoOfSTOPs) END  ,    
		CASE WHEN @sortField  = 'Airline' THEN  MIN(MarketingAirlineName)         END   ,   
		CASE WHEN @sortField  ='Departure' THEN MIN( actualTakeOffDateForLeg) END   ,   
		CASE WHEN @sortField  ='' THEN MIN( air.points)  END   ,
		normalized.legDurationInMinutes 
	END   
	ELSE   
	BEGIN   
		INSERT into #pagingResultSet (airResponseKey,airPoints ,actualTakeOffDateForLeg ,airlineName    )  
		SELECT    air.airResponseKey ,MIN(air.points) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air   
		INNER JOIN #normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey   
		INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   )   
		GROUP BY air.airResponseKey,airlineName ,normalized.legDurationInMinutes  order by 
		MIN(air.points), normalized.legDurationInMinutes  ,MIN(MarketingAirlineName) , min(normalized.noOFSTOPs ),MIN( actualTakeOffDateForLeg) ,MIN( actualLandingDateForLeg )  
	END   

	DECLARE @firstRoundTripResponse as int 
	DECLARE @firstRoundTripResponsePrice as decimal (12,2) 

	SELECT top 1    @firstRoundTripResponse = rowNum ,@firstRoundTripResponsePrice= points  from #pagingResultSet P inner join #airResponseResultset A on p.airResponseKey = a.airResponseKey 

	where noofAirlines =1   order by rownum  

	IF ( @airRequestTypeKey =1 ) 
	BEGIN
	UPDATE P  SET isSmartFare = 1 from #pagingResultSet P inner join #airResponseResultset A on P.airResponseKey = A.airResponseKey  
	where rowNum < @firstRoundTripResponse  and  P.airPoints < @firstRoundTripResponsePrice and noofAirlines =1  
	END

	/****MAIN RESULTSET FOR LIST ****STARTS HERE *****/  

	SELECT rowNum,air.*, airSegmentArrivalOffset,departureAirport .CityName AS DepartureAirPortCityName ,departureAirport.StateCode AS DepartureAirportStateCode ,departureAirport .AirportName AS DepartureAirportName , departureAirport.CountryCode AS DepartureAirportCountryCode,   
	arrivalAirport .CItyName AS ArrivalAirPortCityName ,arrivalAirport .StateCode AS ArrivalAirportStateCode , arrivalAirport .AirportName AS ArrivalAirportName ,arrivalAirport .CountryCode  AS ArrivalAirportCountryCode,  
	operatingAirline .ShortName AS OperatingAirlineName  ,isRefundable ,isBrandedFare ,cabinClass,
	CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName,isSmartFare , legDuration
	FROM #airResponseResultset air INNER JOIN #pagingResultSet  paging ON air.airResponseKey = paging.airResponseKey  
	LEFT OUTER JOIN AirVendorLookup operatingAirline WITH (NOLOCK)   ON air .airSegmentOperatingAirlineCode = operatingAirline .AirlineCode   
	LEFT OUTER JOIN AirportLookup departureAirport  WITH (NOLOCK)   ON air .airSegmentDepartureAirport = departureAirport .AirportCode   
	LEFT OUTER JOIN AirportLookup arrivalAirport  WITH (NOLOCK)    ON air .airSegmentArrivalAirport = arrivalAirport.AirportCode   
	LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode
	LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode
	WHERE ---rowNum > @FirstRec  AND rowNum< @LastRec   AND  
	airLegNumber = CASE WHEN @airRequestTypeKey > -1 THEN @airRequestTypeKey ELSE airLegNumber END  
	order by rowNum ,airlegnumber ,segmentOrder, airSegmentDepartureDate

	
	/****MAIN RESULTSET FOR LIST ****END HERE *****/  
	IF EXISTS(SELECT TOP 1 TotalPointsToDisplay FROM #AdditionalFares)
	BEGIN
		SELECT @HighestPrice = MAX(TotalPointsToDisplay) from #AdditionalFares AF
		Inner JOIN #airResponseResultset ARSP
		on AF.airresponsekey = ARSP.airResponseKey
	END
	ELSE
	BEGIN
		SELECT @HighestPrice = MAX(points)
		From #airResponseResultset
	END
	/******MIN -MAX PRICE FOR FILTERS START HERE ***/  
	--IF ( @gdssourcekey =9 ) AND @airRequestTypeKey = 2   
	--BEGIN  
 --   	SELECT MIN(points) AS LowestPrice , MAX(points) AS HighestPrice FROM #airResponseResultset  result1    

	--END   
	--ELSE   
	--BEGIN   
		SELECT MIN(points) AS LowestPrice , @HighestPrice as HighestPrice FROM #airResponseResultset  result1    
	--END   
	/******MIN -MAX PRICE FOR FILTERS END HERE ***/  

	/***LANDING & TAKEOFF TIME STARTS HERE *****/  
	SELECT distinct  MIN (actualTakeOffDateForLeg ) AS MinDepartureTakeOffDate,  MAX (actualTakeOffDateForLeg) AS MaxDepartureTakeOffDate, MIN (actualLandingDateForLeg) AS MinDepartureLandingDate,  MAX (actualLandingDateForLeg) AS MaxDepartureLandingDate, 
	cast(CAST(CONVERT(DATE, MAX (actualLandingDateForLeg)) AS VARCHAR(20)) +' '+Replace(Min(Replace(LEFT(CONVERT(TIME(0),actualLandingDateForLeg) ,5),':','.')),'.',':') +':00' as datetime) as MinDepartureLandingTime ,
	cast(CAST(CONVERT(DATE, MAX (actualLandingDateForLeg)) AS VARCHAR(20)) +' '+Replace(Max(Replace(LEFT(CONVERT(TIME(0),actualLandingDateForLeg) ,5),':','.')),'.',':') +':00' as datetime) as MaxDepartureLandingTime
	FROM #airResponseResultset    
	/***LANDING & TAKEOFF TIME ENDS HERE *****/  

	/* STOPs for Slider END */  
	SELECT distinct NoOfSTOPs AS NoOfSTOPs  FROM #airResponseResultset   
	/* STOPs for Slider END*/  

	/*****TOTAL RECORD FOUND *****/  
	SELECT COUNT(*) AS [TotalCount] FROM #pagingResultSet  
	
	IF EXISTS(SELECT 1 FROM #pagingResultSet)
    BEGIN
       SET @isOutOfPolicyResultsPresent = 0
    END
    
	/*****TOTAL RECORD FOUND *****/  

	IF @airLines <> '' and @isIgnoreAirlineFilter = 1    
	BEGIN  
		delete from @tmpAirline    
		INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )    
	END  

	/**** MATRIX SUMMARY STARTES HERE *****/  
	IF ( SELECT COUNT (*) FROM @tmpAirline) > 0
	BEGIN   
		SELECT MIN(air.points) AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode From #airResponseResultset air  
		INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
		INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode   
		LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode  
		GROUP BY airlineName ,ShortName   
	END   
	ELSE   
	BEGIN    
		IF ( @gdssourcekey =9 ) AND @airRequestTypeKey = 2   
		BEGIN  
			SELECT MIN(air.points) AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode From #airResponseResultset air  
			INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
			INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode   
			LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor.AirlineCode  
			GROUP BY airlineName ,ShortName   
		END   
		ELSE   
		BEGIN    
			SELECT MIN(air.points) AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode From #airResponseResultset air  
			INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
			LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode   
			GROUP BY airlineName ,ShortName   
		END   
	END   

	DECLARE @markettingAirline AS varchar(100)   
	DECLARE @noOFDrillDownCount as int    
	IF @airRequestTypeKey > 1   
	BEGIN   

	IF (SELECT count(distinct (airSegmentMarketingAirlineCode ))  FROM AirSegments seg  WITH (NOLOCK) INNER JOIN @SELECTedResponse SELECTed ON seg.airResponseKey = SELECTed .responsekey ) = 1   
	BEGIN  
		IF   (SELECT COUNT(*) FROM @tmpAirline) > 1
		BEGIN  
			SET @markettingAirline  =(SELECT   distinct (airSegmentMarketingAirlineCode )   FROM #AirSegments seg WITH (NOLOCK)   INNER JOIN @SELECTedResponse SELECTed ON seg.airResponseKey = SELECTed .responsekey )    
		END  
		ELSE   
		BEGIN  
			SET @markettingAirline= @airLines       
		END  
	END   
	ELSE  
	BEGIN   
		IF ( SELECT airRequestTypeKey  FROM AirRequest WITH (NOLOCK) WHERE airRequestKey = @airRequestKey ) >= 2   
		BEGIN  
			IF (SELECT count(distinct (airSegmentMarketingAirlineCode ))  FROM #AirSegments seg WITH (NOLOCK)  WHERE airResponseKey = @SELECTedResponseKey   ) = 1   
			BEGIN  
				IF   (SELECT COUNT(*) FROM @tmpAirline) > 1
				BEGIN  
					SET @markettingAirline  =(SELECT   distinct (airSegmentMarketingAirlineCode )   FROM #AirSegments seg WITH (NOLOCK)   WHERE airResponseKey = @SELECTedResponseKey  )            
				END  
				ELSE   
				BEGIN  
					SET @markettingAirline= @airLines          
				END  
			END  
			ELSE IF  (@airLines <> '') -- AND (select COUNT(*) from @tmpAirline ) = 1)  
			BEGIN   
				SET @markettingAirline= @airLines          
			END  
		END   
	END   
	IF  @markettingAirline =''   
	BEGIN   
		SET @markettingAirline='Multiple Airlines'  
	END   

	END   
	ELSE   
	BEGIN  
		IF   (SELECT COUNT(*) FROM @tmpAirline) = 1   
		BEGIN  
			SET @markettingAirline = @airlines   
		END   
		ELSE   
		BEGIN   
		SET @markettingAirline = ''   
		END   
	END   

	IF @markettingAirline <> 'Multiple Airlines' AND @markettingAirline <> ''   
	BEGIN   
		SET @noOFDrillDownCount = ( SELECT top 1 COUNT(*)   FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = @markettingAirline  )  
	END   
	ELSE   
	BEGIN   
		SET @noOFDrillDownCount = (SELECT top 1 COUNT(*)  FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = 'Multiple Airlines')  
	END   

	IF ( @drillDownLevel = 1 )   
	BEGIN   
		IF ( @noOFDrillDownCount = 0 ) --WHEN NO RESULT FOUND FOR LEVEL 1   
		BEGIN   
		SET  @drillDownLevel =0  
		END   
		ELSE   
		BEGIN   
		SET @drillDownLevel =1  
		END   
	END   

	SELECT @drillDownLevel    
	IF ( @drillDownLevel =0 )   
	BEGIN  
		IF ( @matrixview = 0 AND @airRequestTypeKey = 1 )    
		BEGIN  
			DECLARE @seconSubRequestKey AS int   
			SET @seconSubRequestKey =( SELECT airSubRequestKey  FROM #AirSubRequest  WITH (NOLOCK)  WHERE airSubRequestLegIndex = 2 AND groupKey=1)  

			DECLARE @tmpSecondLowestPrice AS table   
			(  
			legPrice float ,  
			airline varchar(100)   
			)  
			INSERT @tmpSecondLowestPrice (legPrice ,airline   )  
			SELECT (case when @isTotalPriceSort = 0 then MIN(airPriceBAse ) else min(airPriceBase+ airpriceTax) end )  AS secondLegPrice,airSegmentMarketingAirlineCode FROM #AirResponse ar   
			INNER JOIN   
			(  
			SELECT A.* FROM #AirSegments A WITH (NOLOCK)
			Except   
			SELECT A.* FROM #AirSegments A WITH (NOLOCK)INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey  
			) Tmp  
			ON ar.airResponseKey = Tmp.airResponseKey   
			WHERE airSubRequestKey = @seconSubRequestKey GROUP BY  airSegmentMarketingAirlineCode  

			 if ( select COUNT (*) from @tmpSecondLowestPrice ) = 0   
			 begin  
				 INSERT @tmpSecondLowestPrice (legPrice ,airline   )  
				 select 0 , t.airLineCode  from @tmpAirline  t  
			 end  
		               
			DECLARE @thirdSubRequestKey AS int   
			SET @thirdSubRequestKey =( SELECT airSubRequestKey  FROM #AirSubRequest  WITH (NOLOCK)  WHERE airSubRequestLegIndex =3 )  

			IF(@superSetAirlines != '' AND @superSetAirlines is not null)  
			BEGIN
				SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights ,convert(bit,1) as isSameAirlinesItin  FROM   
				(  
				SELECT min ((case when @isTotalPriceSort = 0 then r.airPriceBase else (r.airpricebase + r.airPricetax) end )
				+ISNULL( legPrice,0) --+ ISNULL (thirdlegPrice ,0)  + ISNULL (fourthlegPrice ,0) + ISNULL (fifthlegPrice ,0)   

				) AS LowestPrice  
				,t.noOFSTOPs AS NoOFSegments,t.airlineCode  AS airSegmentMarketingAirlineCode,COUNT(distinct r.airResponseKey ) noOFFLights    
				From   
				#normalizedResultSet   t INNER JOIN   
				(  
				SELECT A.* FROM #AirResponse A  WITH (NOLOCK)     
				Except   
				SELECT A.* FROM #AirResponse A  WITH (NOLOCK)  INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) r   
				ON t.airresponsekey = r.airResponseKey   
				INNER JOIN @tmpAirline air ON t.airlineCode = air.airLineCode   
				InNER JOIN @tmpSecondLowestPrice s ON s.airline = t.airlineCode    
				--InNER   JOIN  @tmpThirdLowestPrice third ON t.airlineCode = third.airline   
				--InNER   JOIN @tmpFourthLowestPrice fourth ON t.airlineCode = fourth .airline   
				--InNER   JOIN @tmpFifthLowestPrice fifth ON t.airlineCode = fifth .airline   
				WHERE (t.airsubrequetkey  = @airSubRequestKey OR t.airsubrequetkey = @airFlight_ITARequest) AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT (MIN(points)), t.noOFSTOPs,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights       
				From #normalizedResultSet   t    INNER JOIN   
				(SELECT A.* FROM #AirResponse A  WITH (NOLOCK) 
				Except   
				SELECT A.* FROM #AirResponse A  WITH (NOLOCK)  INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) r   
				ON t.airresponsekey = r.airResponseKey   
				WHERE (t.airsubrequetkey  <> @airSubRequestKey AND t.airsubrequetkey <> @airFlight_ITARequest)  AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT MIN(points), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights     From #normalizedResultSet   t    
				INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
				GROUP BY  t.noOFSTOPs   
				union   
				SELECT MIN(points)    AS LowestPrice,m.noOFSTOPs AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  From #normalizedResultSet   m INNER JOIN #AirResponse r  WITH (NOLOCK) 
				ON m.airresponsekey =r.airResponseKey  WHERE m.airlineCode ='Multiple Airlines'   GROUP BY m.airlineCode ,noOFSTOPs   
				) summary1   
				LEFT OUTER  JOIN AirVendorLookup airvend  WITH (NOLOCK)  ON summary1 .airSegmentMarketingAirlineCode = airvend .AirlineCode   
				GROUP BY airvend .ShortName,airSegmentMarketingAirlineCode ,NoOFSegments   
			END  
			ELSE  
			BEGIN
				SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights ,convert(bit,1) as isSameAirlinesItin  FROM   
				(  
				SELECT min ((case when @isTotalPriceSort = 0 then r.airPriceBase else (r.airpricebase + r.airPricetax) end )   
				+ISNULL( legPrice,0) 
				-- + ISNULL (thirdlegPrice ,0) + ISNULL (fourthlegPrice ,0) + ISNULL (fifthlegPrice ,0)   
				) AS LowestPrice  
				,t.noOFSTOPs AS NoOFSegments,t.airlineCode  AS airSegmentMarketingAirlineCode,COUNT(distinct r.airResponseKey ) noOFFLights   From #normalizedResultSet   t INNER JOIN #AirResponse r ON t.airresponsekey =r.airResponseKey   
				INNER JOIN @tmpAirline air ON t.airlineCode = air.airLineCode   
				InNER JOIN @tmpSecondLowestPrice s ON s.airline = t.airlineCode    
				--InNER JOIN @tmpThirdLowestPrice third ON t.airlineCode = third.airline   
				--InNER JOIN @tmpFourthLowestPrice fourth ON t.airlineCode = fourth .airline   
				--InNER JOIN @tmpFifthLowestPrice fifth ON t.airlineCode = fifth .airline   
				WHERE (t.airsubrequetkey  = @airSubRequestKey OR t.airsubrequetkey = @airFlight_ITARequest) AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT MIN(points) , t.noOFSTOPs,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights     From #normalizedResultSet   t    WHERE (t.airsubrequetkey <> @airSubRequestKey  AND t.airsubrequetkey <> @airFlight_ITARequest)
				AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT MIN(points) , t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights     From #normalizedResultSet   t    
				INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
				GROUP BY  t.noOFSTOPs   
				union   
				SELECT MIN(points)     AS LowestPrice,m.noOFSTOPs AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  
				From #normalizedResultSet   m INNER JOIN #AirResponse r  WITH (NOLOCK)ON m.airresponsekey =r.airResponseKey  WHERE m.airlineCode ='Multiple Airlines'   GROUP BY m.airlineCode ,noOFSTOPs   
				)   
				summary1   
				LEFT OUTER  JOIN AirVendorLookup airvend  WITH (NOLOCK)  ON summary1 .airSegmentMarketingAirlineCode = airvend .AirlineCode 
				GROUP BY airvend .ShortName,airSegmentMarketingAirlineCode ,NoOFSegments   
			END  
		END   
		ELSE  
		BEGIN  
	
		DECLARE @MatrixResult AS TABLE
		(
		LowestPrice float,
		NoOFSegments int,
		airSegmentMarketingAirlineCode varchar(50),
		noOFFLights INT,
		MarketingAirlineName varchar(50),
		isSameAirlinesItin bit default 0 
		)

		IF ( SELECT COUNT (*) FROM @tmpAirline) > 0
		BEGIN
			INSERT INTO @MatrixResult (LowestPrice,NoOFSegments,airSegmentMarketingAirlineCode,noOFFLights,MarketingAirlineName)   
			SELECT MIN(points) AS LowestPrice ,NoOfSTOPs AS NoOFSegments ,airlineName AS airSegmentMarketingAirlineCode,COUNT(distinct air.airResponseKey ) noOFFLights ,
			ISNULL (ShortName,airlineName)AS MarketingAirlineName From #airResponseResultset air  
			LEFT OUTER JOIN AirVendorLookup vendor  WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode   
			INNER JOIN @tmpAirline tmp ON vendor.airLineCode = tmp.airLineCode  
			GROUP BY airlineName ,ShortName ,NoOfSTOPs   
			union   
			SELECT MIN(points), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights ,'all'    From #normalizedResultSet t     
			INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
			GROUP BY t.noOFSTOPs   
			order by MarketingAirlineName  
		END
		ELSE
		BEGIN
			INSERT INTO @MatrixResult (LowestPrice,NoOFSegments,airSegmentMarketingAirlineCode,noOFFLights,MarketingAirlineName)   
			SELECT MIN(points) AS LowestPrice ,NoOfSTOPs AS NoOFSegments ,airlineName AS airSegmentMarketingAirlineCode,COUNT(distinct air.airResponseKey ) noOFFLights ,
			ISNULL (ShortName,airlineName)AS MarketingAirlineName From #airResponseResultset air  
			LEFT OUTER JOIN AirVendorLookup vendor  WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode 
			GROUP BY airlineName ,ShortName ,NoOfSTOPs   
			union   
			SELECT MIN(points), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights ,'all'    From #normalizedResultSet t     
			INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
			GROUP BY t.noOFSTOPs   
			order by MarketingAirlineName  
		END
	
		
		IF ( @isTotalPriceSort = 0 ) 
		BEGIN
		UPDATE T SET isSameAirlinesItin = 1 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode =A.airlineName AND T.LowestPrice = A.points  
		WHERE airlineName <> 'Multiple Airlines' 

		UPDATE T SET isSameAirlinesItin = 0 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode = A.airlineName AND T.LowestPrice = A.points  
		WHERE T.isSameAirlinesItin = 0 --and airlineName <> 'Multiple Airlines' AND otherlegAirlines <> 'Multiple Airlines' 
		END  
		ELSE 
		BEGIN 
		UPDATE T SET isSameAirlinesItin = 1 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode =A.airlineName AND T.LowestPrice =points
		WHERE airlineName <> 'Multiple Airlines' 

		UPDATE T SET isSameAirlinesItin = 0 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode = A.airlineName AND T.LowestPrice = points
		WHERE T.isSameAirlinesItin = 0 
		
	END

	UPDATE T SET isSameAirlinesItin = 1 FROM  @MatrixResult T  WHERE  
	airSegmentMarketingAirlineCode = 'Multiple Airlines'

	IF ( @airrequestType = 1 ) 
	BEGIN 
		UPDATE T SET isSameAirlinesItin = 1 FROM  @MatrixResult T
		END
			SELECT * FROM @MatrixResult 
		END 
	END   
	ELSE   
	BEGIN   
		IF @markettingAirline <> 'Multiple Airlines' AND @markettingAirline <> ''   
		BEGIN   
		PRINT ('1')
		PRINT @markettingAirline
		SELECT MIn(points) AS LowestPrice ,NoofsTOPs AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,air.MarketingAirlineName  ,0 AS start , 6  AS endTime ,COUNT(
		distinct air.airResponseKey ) noOFFLights   FROM #airResponseResultset  air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  AND air.airlineName = @markettingAirline 
		AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)  
		GROUP BY air.NoOfSTOPs ,air.airlineName  ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air  
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '08:00:00.0000000' AND '09:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(points),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = @markettingAirline 
		AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT MIn(air.points),air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset air  
		INNER JOIN #normalizedResultSet page ON air.airResponseKey=page.airResponseKey WHERE    page.airlineCode = @markettingAirline AND air.gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN air.gdsSourceKey ELSE @gdssourcekey END )      
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		--SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset   air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE    airSegmentMarketingAirlineCode = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		--order by endTime ,start    
		END   
		ELSE   
		BEGIN   
			PRINT ('2')
			SELECT MIn(points) AS LowestPrice ,NoofsTOPs AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,'Multiple Airlines' AS MarketingAirlineName  ,0 AS start , 6
			AS endTime ,COUNT(distinct air.airResponseKey ) noOFFLights   FROM #airResponseResultset  air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  
			AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)  
			GROUP BY air.NoOfSTOPs ,air.airlineName     
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0
			THEN gdsSourceKey ELSE @gdssourcekey END)  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '08:00:00.0000000' AND '09:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0
			THEN gdsSourceKey ELSE @gdssourcekey END)  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union       
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 
			THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName   
			union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName   
			Union   
			SELECT MIn(points),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,01 , 23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName   
			-- select 0 , 0 ,  'Multiple Airlines' ,'Multiple Airlines' ,01 ,23 ,0 --for non stop   
			--union   
			-- SELECT MIN (air.airPrice ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset   air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE airSegmentMarketingAirlineCode = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,'Multiple Airlines' ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset   air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE     gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs  order by endTime ,start   
		END   
	END   

	--SELECT * FROM #AllOneWayResponses 
	-- SELECT * FROM #airResponseResultset where noofAirlines = 1 and noOfOtherlegairlines  =1 and airSegmentMarketingAirlineCode <> otherlegAirlines 

	DECLARE @normalAirlines AS TABLE 
	(
	airlegConnections varchar(100), airlines varchar(100)
	)

	INSERT @normalAirlines 
	Select DISTINCT  airLegConnections,
	(Select DISTINCT  airSegmentMarketingAirlineCode + ',' AS [text()]
	   FROM #airResponseResultset Seg2
	Where A.airSegmentKey  = Seg2.airSegmentKey 
	 
	For XML PATH ('')) [Airlines]
	FROM #airResponseResultset A  
	inner join #NormalizedAirResponses N WITH (NOLOCK)
	on A.airResponseKey = N.airresponsekey and N.airLegNumber = @airRequestTypeKey   and a.airLegNumber =@airRequestTypeKey  



	DECLARE @cityPairAirlines AS TABLE 
	(
	airlegConnections varchar(100), airlines varchar(100)
	)

	INSERT @cityPairAirlines
	SELECT DISTINCT airLegConnections  , stuff(
	(
	select DISTINCT  ',' + [Airlines] from @normalAirlines  T2  where t2.airLegConnections = t.airLegConnections for XML path('')
	),1,1,'') 

	FROM  (SELECT *FROM @normalAirlines ) T
	-- Map Related Information Subsided as Currently BX Does not need it
	DECLARE @NormalMap as Table 
	( 
	rowId int Identity (1,1),
	airLegConnections varchar(100),

	airresponsekey varchar(200) , 
	NoOfStops int , 

	MinimumTotalCost int ,
	MaximumTotalCost int ,
	Minimumduration INT ,
	MaximumDuration INT  ,
	Airlines varchar(500),
	tripType  varchar(20),
	NoOfFlights INT

	)

	INSERT @NormalMap( airLegConnections,NoOfFlights,airresponsekey,NoOfStops,MinimumTotalCost,MaximumTotalCost ,Minimumduration ,MaximumDuration,tripType ,Airlines )

	SELECT DISTINCT A.legConnections,COUNT(DISTINCT Airresponsekey), MIN(CAST( A.airResponseKey AS varchar(200))) ,A.NoOfSTOPs ,  MIN( points),MAX(points) ,   MIN(legDuration)  ,MAX(legDuration)  ,
	( CASE  WHEN @airRequestType = 1 then 'OneWay' 
	WHEN @airRequestType = 2 then 'RoundTrip' 
	WHEN @airRequestType =3 then 'MultiCity' END) ,  replace( NA.airlines ,',,',',')
	FROM #airResponseResultset A inner join  
	@cityPairAirlines NA on A.legConnections= NA.airLegConnections 
	GROUP BY A.legConnections,A.NoOfSTOPs,NA.airlines 


	--SELECT * FROM @NormalMap AirLeg   
	--INNER JOIN #airResponseResultset AirSegment On AirSegment.airResponseKey = CAST (Airleg.airresponsekey AS uniqueidentifier)
	--FOR XML AUTO, ELEMENTS, ROOT('AirMap') 

	SELECT
	-- Map columns to XML attributes/elements with XPath selectors.
	TripType AS [Type],AirLeg.MinimumTotalCost,AirLeg.MaximumTotalCost,airleg.NoOfStops ,
	Substring(Airleg.Airlines,1, LEN(AirLeg.Airlines)-1) As Airlines ,Airleg.NoOfFlights ,Airleg.Minimumduration, Airleg.MaximumDuration ,
	(
	-- Use a sub query for child elements.
	SELECT ROW_NUMBER()  over ( order by segmentOrder)RowID,
	 depart.CityName DepartCityName ,CAST (depart.Latitude as VARCHAR(200)) "DepartAirport/@Lattitude" ,CAST (depart.Longitude as VARCHAR(200))"DepartAirport/@Longitude"  ,CAST (depart.StateCode as VARCHAR(2))"DepartAirport/@StateCode" ,DEPART.AirportCode as DepartAirport  ,
	 
	 arrival.CityName ArrivalCityName ,
	 CAST (arrival.Latitude as VARCHAR(200)) "ArrivalAirport/@Lattitude" ,CAST (Arrival.Longitude as VARCHAR(200))"ArrivalAirport/@Longitude"  ,CAST (Arrival.StateCode as VARCHAR(2))"ArrivalAirport/@StateCode",Arrival.AirportCode as ArrivalAirport  
	 
	FROM
	#airResponseResultset result  LEFT OUTER JOIN AirportLookup  depart WITH (NOLOCK) on result.airSegmentDepartureAirport = depart.AirportCode 
	LEFT OUTER JOIN AirportLookup  arrival WITH (NOLOCK) on result.airSegmentArrivalAirport  = arrival.AirportCode 
	WHERE
	airResponseKey = CAST (Airleg.airresponsekey AS uniqueidentifier)
	FOR
	XML PATH('AirSegment') , -- The element name for each row.
	TYPE  -- Column is typed so it nests as XML, not text.
	    
	) AS 'AirSegments' -- The root element name for this child collection.
	FROM
	@NormalMap AirLeg 
	FOR
	XML PATH('AirLeg'), -- The element name for each row.
	ROOT('AirMap')     -- The root element name for this result set.
	
	SELECT @isExcludeAirlinesPresent AS IsExcludeAirlinesAvailable
	SELECT @isLoggedinAirlinesPresent AS IsLoggedinAirlinesAvailable
	SELECT @isExcludeCountryPresent AS IsExcludeCountryAvailable
	SELECT @isOutOfPolicyResultsPresent	AS IsOutOfPolicyResultsPresent
 	DROP TABLE #tmpDeparturesLowest 
	DROP TABLE #tmpArrivalLowest  
	DROP TABLE #airResponseResultset
	DROP TABLE #RedeemRules
	DROP TABLE #RedeemRules_Mixed
	--DROP TABLE #AllOneWayResponses_Avail
	--DROP TABLE #AllOneWayResponses_Avail_Temp
	--DROP TABLE #AllOneWayResponses_Avail_Temp1
	DROP TABLE #AllOneWayResponses
	DROP TABLE #AllOneWayResponses_Temp
	DROP TABLE #AllOneWayResponses_Partner
	DROP TABLE #AllOneWayResponses_Temp_Partner
	--DROP TABLE #AllOneWayResponses_Temp_1
	DROP TABLE #normalizedResultSet
	DROP TABLE #pagingResultSet
	--DROp TABLE #Temp_Group
	--DROP TABLE #RedeemRules_1
	--DROP TABLE #AllOneWayResponses_Temp_Partner_NS
	--DROP TABLE #AllOneWayResponses_Temp_Partner_NS_PE
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses_AnyTime') IS NOT NULL
		DROP TABLE #AllOneWayResponses_AnyTime
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses_PlanAhead') IS NOT NULL
		DROP TABLE #AllOneWayResponses_PlanAhead
	IF OBJECT_ID('TEMPDB..#pagingResultSetTemp') IS NOT NULL
		DROP TABLE #pagingResultSetTemp
		IF OBJECT_ID('TEMPDB..#AdditionalFares') IS NOT NULL
		DROP TABLE #AdditionalFares
	--DROP TABLE #ruleData
	END
GO
