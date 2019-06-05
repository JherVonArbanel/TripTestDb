SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec USP_GetAirResponsesForDomesticSearch @airSubRequestKey=3219988,@airRequestTypeKey=1,@SuperSetairLines=N'',@allowedOperatingAirlines=N'',@airLines=N'',@price=2147483647,@pageNo=0,@pageSize=30,@NoOfStops=N'-1',@drillDownLevel=N'0',@gdsSourcekey=2,@minTakeOffDate='2017-08-10 00:00:00',@maxTakeOffDate='2019-11-10 00:00:00',@minLandingDate='2017-08-10 00:00:00',@maxLandingDate='2019-11-10 00:00:00',@isIgnoreAirlineFilter=N'False',@isTotalPriceSort=N'True',@excludeAirline=N'WN',@IsLoginedAirlineList=N'WN',@siteKey=9,@matrixView=1,@maxNoofstops=2,@MaxDomesticFareTotal=0,@UserKey=0,@UserGroupKey=0,@CompanyKey=232,@CutOffSalesPriorDepartureInMinutes=35,@isMultiBrand=1
CREATE PROCEDURE [dbo].[USP_GetAirResponsesForDomesticSearch_Ravi](  
	@airSubRequestKey int ,  
	@sortField varchar(50)='',  
	@airRequestTypeKey int ,      
	@pageNo int ,  
	@pageSize int ,  
	@airLines  varchar(200),  
	@price float ,  
	@NoOfSTOPs varchar (50)  ,  
	@SelectedResponseKey uniqueidentifier =null  ,  
	@SelectedResponseKeySecond uniqueidentifier =null  ,  
	@SelectedResponseKeyThird uniqueidentifier =null  ,  
	@SelectedResponseKeyFourth uniqueidentifier =null  ,  
	@SelectedResponseKeyFifth uniqueidentifier =null  ,  
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
	@MaxFareTotal FLOAT = 0,
	@MaxDomesticFareTotal FLOAT = 0,
	@CutOffSalesPriorDepartureInMinutes INT = 35,
	@isMultiBrand bit = 0,
	@SelectedResponseMultiBrandKey uniqueidentifier = null,
	@IsLoginedAirlineList varchar ( 500) = '',
	@UserKey int =0,
	@CompanyKey int =0,
	@UserGroupKey int =0,
	@isCabinUniquification bit = 0,
	@EventId int = 0,
	@changeOverTimeinMinutes int = 60,
	@IsDomesticRegionTravel bit =0,
	@IsSameDayReturnOWAllowed bit = 0,
	@changeOverTimeinMinutes_AlternateAirport int = 180,
	@LowestPrice FLOAT = 0,
	@SelectedResponseMultiBrandKeySecond uniqueidentifier =null  ,  
	@SelectedResponseMultiBrandKeyThird uniqueidentifier =null  ,  
	@SelectedResponseMultiBrandKeyFourth uniqueidentifier =null  ,  
	@SelectedResponseMultiBrandKeyFifth uniqueidentifier =null  
	) AS  
	SET NOCOUNT ON   
	DECLARE @FirstRec INT  
	DECLARE @LastRec INT  
	DECLARE @isExcludeAirlinesPresent BIT = 0 , @isExcludeCountryPresent BIT = 0, @isLoggedinAirlinesPresent BIT = 0, @isOutOfPolicyResultsPresent BIT = 0
	DECLARE @legTwoLowestFare AS FLOAT = 0
	DECLARE @selectedRoundTripFare AS FLOAT 
	DECLARE @isMultiBrandSelectedOnPreviousLeg BIT =0
	DECLARE @DepartureIsParent INT = 0
	DECLARE @ArrivalIsParent INT = 0
	DECLARE @policyCabin VARCHAR(100)
	DECLARE @isInternationalTrip BIT = 0
	DECLARE @IsREfundable BIT = 0
	DECLARE @airLegBrandName VARCHAR(100) = ''
	DECLARE @selectedAirline VARCHAR(20) = ''
	DECLARE @SelectedGDSSourceKey INT 
	DECLARE @SelectedResponseArrivalAirport NVARCHAR(100) = ''
	DECLARE @SelectedResponseArrivalAirportDate DATETIME
	DECLARE @isAdvancePurchase bit = 0,		@IsNotifyAdvancePurchase bit=0, @IsApproveAdvancePurchase bit = 0,	@IsflagAdvancePurchase bit =0,				@AdvancePurchaseDays int,	@AdvancePurchasePrice float,
	    	@IsBasicUnselectable BIT = 0,	@ApplyBasicUnselectable BIT =0,	@IsFlagBasicUnselectable BIT = 0,	@IsSuppressAirline bit = 0,					@policyKey int,
			@IsBussinessClassAllowed BIT=0,	@BusinessClassOverHrs INT=0 ,	@IsFlagBusinessClassOverHrs BIT=0,	@IsBusinessLongFlightsUnselectable BIT=0,
			@IsFirstClassAllowed BIT=0,		@FirstClassOverHrs INT=0,		@IsFlagFirstClassOverHrs BIT=0,		@IsFirstLongFlightsUnselectable BIT=0
	-- Initialize variables.  
	--STEP1 -- get current page reecord indexes 
		SET @FirstRec = (@pageNo  - 1) * @PageSize  
		SET @LastRec = (@pageNo  * @PageSize + 1)  
	-- STEP2 -- Get other subrequest details from db based on @airSubRequestKey
	DECLARE @airRequestKey AS int  
	DECLARE @airRequestType AS int 
	DECLARe @airSubRequestLeg2 AS INT
	DECLARE @HighFareTotal AS FLOAT = 0, @LowFareThreshold AS FLOAT = 0, @IsLowFareThreshold AS BIT = 0, @IsHideFare AS BIT = 0, @isAirlineUniquification AS BIT = 0,@IsHighFareTotal AS BIT = 0;
	DECLARE @isSameDayReturnOWLogicToApply AS BIT =0, @IsPolicyApplicable BIT=0
	DECLARE @isSameDaySearch AS BIT = 0
	DECLARE @TripFromDate DATETIME  
	DECLARE @airLegBrandName_Second VARCHAR(100) = ''
	DECLARE @airLegBrandName_Third VARCHAR(100) = ''
	DECLARE @airLegBrandName_Fourth VARCHAR(100) = ''
	DECLARE @airLegBrandName_Fifth VARCHAR(100) = ''
	DECLARE @isMultiBrandSelectedOnPreviousLeg_Second BIT =0
	DECLARE @isMultiBrandSelectedOnPreviousLeg_Third BIT =0
	DECLARE @isMultiBrandSelectedOnPreviousLeg_Fourth BIT =0
	DECLARE @isMultiBrandSelectedOnPreviousLeg_Fifth BIT =0
	DECLARE @selectedBrandName AS VARCHAR(20) = ''
	DECLARE @selectedFlightNumber AS VARCHAR(20) = ''
	DECLARE @selectedAirlines AS VARCHAR(20) = ''
	DECLARE @airLegBrandName_CurrentLeg VARCHAR(100) = ''
	DECLARE @IsREfundable_CurrentLeg VARCHAR(100) = ''

	CREATE TABLE #AirSubRequest
	(
		[airSubRequestKey] [int] NOT NULL,
		[airRequestKey] [int],
		[airRequestDateTypeKey] [int],
		[airRequestDepartureAirport] [varchar](50),
		[airRequestArrivalAirport] [varchar](50),
		[airRequestDepartureDate] [datetime],
		[airRequestDepartureDateVariance] [int],
		[airRequestArrivalDate] [datetime],
		[airRequestArrivalDateVariance] [int],
		[airRequestCalendarMonth] [datetime],
		[airRequestCalendarMinDays] [int],
		[airRequestCalendarMaxDays] [int],
		[airSubRequestLegIndex] [int],
		[airSpecificDepartTime] [int],
		[groupKey] [int],
		[CalendarRequest] [varchar](500),
		[IsSubRequestCompleted] [bit],
		[ThirdPartySessionId] [nvarchar](200)
	) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX [IDX_tempAirSubRequestKey] ON #AirSubRequest([airSubRequestKey]) 

	CREATE TABLE #AirResponse
	(
		[airResponseKey] [uniqueidentifier] ,
		[airSubRequestKey] [int] ,
		[airPriceBase] [float],
		[airPriceTax] [float],
		[gdsSourceKey] [int],
		[refundable] [bit],
		[airClass] [varbinary](50),
		[priceClassCommentsSuperSaver] [varchar](500),
		[priceClassCommentsEconSaver] [varchar](500),
		[priceClassCommentsFirstFlex] [varchar](500),
		[priceClassCommentsCorporate] [varchar](500),
		[priceClassCommentsEconFlex] [varchar](500),
		[priceClassCommentsEconUpgrade] [varchar](500),
		[airSuperSaverPrice] [float],
		[airEconSaverPrice] [float],
		[airFirstFlexPrice] [float],
		[airCorporatePrice] [float],
		[airEconFlexPrice] [float],
		[airEconUpgradePrice] [float],
		[airClassSuperSaver] [varchar](50),
		[airClassEconSaver] [varchar](50),
		[airClassFirstFlex] [varchar](50),
		[airClassCorporate] [varchar](50),
		[airClassEconFlex] [varchar](50),
		[airClassEconUpgrade] [varchar](50),
		[airSuperSaverSeatRemaining] [int],
		[airEconSaverSeatRemaining] [int],
		[airFirstFlexSeatRemaining] [int],
		[airCorporateSeatRemaining] [int],
		[airEconFlexSeatRemaining] [int],
		[airEconUpgradeSeatRemaining] [int],
		[airSuperSaverFareReferenceKey] [varchar](1000),
		[airEconSaverFareReferenceKey] [varchar](1000),
		[airFirstFlexFareReferenceKey] [varchar](1000),
		[airCorporateFareReferenceKey] [varchar](1000),
		[airEconFlexFareReferenceKey] [varchar](1000),
		[airEconUpgradeFareReferenceKey] [varchar](1000),
		[airPriceClassSelected] [varchar](1000),
		[airSuperSaverTax] [float],
		[airEconSaverTax] [float],
		[airEconFlexTax] [float],
		[airCorporateTax] [float],
		[airEconUpgradetax] [float],
		[airFirstFlexTax] [float],
		[airSuperSaverFareBasisCode] [varchar](50),
		[airEconSaverFareBasisCode] [varchar](50),
		[airFirstFlexFareBasisCode] [varchar](50),
		[airCorporateFareBasisCode] [varchar](50),
		[airEconFlexFareBasisCode] [varchar](50),
		[airEconUpgradeFareBasisCode] [varchar](50),
		[isBrandedFare] [bit],
		[cabinClass] [varchar](20),
		[fareType] [varchar](20),
		[isGeneratedBundle] [bit],
		[ValidatingCarrier] [varchar](3),
		[contractCode] [varchar](50),
		[airPriceBaseSenior] [float],
		[airPriceTaxSenior] [float],
		[airPriceBaseChildren] [float],
		[airPriceTaxChildren] [float],
		[airPriceBaseInfant] [float],
		[airPriceTaxInfant] [float],
		[airPriceBaseDisplay] [float],
		[airPriceTaxDisplay] [float],
		[airPriceBaseTotal] [float],
		[airPriceTaxTotal] [float],
		[airPriceBaseYouth] [float],
		[airPriceTaxYouth] [float],
		[airCurrencyCode] [varchar](10),
		[airResponseId] [bigint] NOT NULL,
		[airPriceBaseInfantWithSeat] [float],
		[airPriceTaxInfantWithSeat] [float],
		[agentwareQueryID] [nvarchar](30),
		[agentwareItineraryID] [nvarchar](30),
		[Points] [int],
		[ticketDesignator] [nvarchar](10),
		[awardCode] [nvarchar](6),
		[ITAQueryId] [nvarchar](100),
		[ITAItineraryId] [nvarchar](100),
		[isAvailable] [bit],
		[isReturnFare] [bit] NULL
	) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX [IDX_airResponseID] ON #AirResponse([airResponseID]) 

	CREATE NONCLUSTERED INDEX [IDX_airSubRequestKey] ON #AirResponse([airResponseKey]) INCLUDE ([airSubRequestKey])
	CREATE NONCLUSTERED INDEX [IDX_gdsSourceKey_airResponseKey_airSubRequestKey] ON #AirResponse ([gdsSourceKey]) 
			INCLUDE ([airResponseKey],[airSubRequestKey])
	CREATE NONCLUSTERED INDEX [IDX_airResonseKey_lots] ON #AirResponse ([airResponseKey])
			INCLUDE ([airPriceBase],[airPriceTax],[airSuperSaverPrice],[airEconSaverPrice],[airFirstFlexPrice],[airCorporatePrice],[airEconFlexPrice],[airEconUpgradePrice],[airSuperSaverTax],[airEconSaverTax],[airEconFlexTax],[airCorporateTax],[airEconUpgradetax],[airFirstFlexTax],[airPriceBaseSenior],[airPriceTaxSenior],[airPriceBaseChildren],[airPriceTaxChildren],[airPriceBaseInfant],[airPriceTaxInfant],[airPriceBaseTotal],[airPriceTaxTotal],[airPriceBaseYouth],[airPriceTaxYouth],[airPriceBaseInfantWithSeat],[airPriceTaxInfantWithSeat])
	CREATE NONCLUSTERED INDEX [IDX_SubReqKey_RespKey] ON #AirResponse ([airSubRequestKey]) 
			INCLUDE ([airResponseKey])
	CREATE NONCLUSTERED INDEX [IDX_airSubRequestKey_gdsSourceKey] ON #AirResponse ([airSubRequestKey],[gdsSourceKey])
			INCLUDE ([airResponseKey])

	CREATE TABLE #AirSegments
	(
		[airSegmentKey] [uniqueidentifier] NOT NULL,
		[airResponseKey] [uniqueidentifier],
		[airLegNumber] [int],
		[airSegmentMarketingAirlineCode] [varchar](2),
		[airSegmentOperatingAirlineCode] [varchar](2),
		[airSegmentFlightNumber] [int],
		[airSegmentDuration] [time](7),
		[airSegmentEquipment] [nvarchar](50),
		[airSegmentMiles] [int],
		[airSegmentDepartureDate] [datetime],
		[airSegmentArrivalDate] [datetime],
		[airSegmentDepartureAirport] [varchar](50),
		[airSegmentArrivalAirport] [varchar](50),
		[airSegmentResBookDesigCode] [varchar](3),
		[airSegmentDepartureOffset] [float],
		[airSegmentArrivalOffset] [float],
		[airSegmentSeatRemaining] [int],
		[airSegmentMarriageGrp] [char](10),
		[airFareBasisCode] [varchar](50),
		[airFareReferenceKey] [varchar](400),
		[airSegmentOperatingFlightNumber] [int],
		[airsegmentCabin] [varchar](20),
		[segmentOrder] [int],
		[amadeusSNDIndicator] [varchar](3),
		[airSegmentOperatingAirlineCompanyShortName] [varchar](100),
		[OriginalairsegmentCabin] [varchar](20),
		[airSegmentId] [bigint],
		[airSuperSaverFareBasisCode] [varchar](50),
		[airEconSaverFareBasisCode] [varchar](50),
		[airFirstFlexFareBasisCode] [varchar](50),
		[airCorporateFareBasisCode] [varchar](50),
		[airEconFlexFareBasisCode] [varchar](50),
		[airEconUpgradeFareBasisCode] [varchar](50),
		[airSuperSaverFareReferenceKey] [varchar](1000),
		[airEconSaverFareReferenceKey] [varchar](1000),
		[airFirstFlexFareReferenceKey] [varchar](1000),
		[airCorporateFareReferenceKey] [varchar](1000),
		[airEconFlexFareReferenceKey] [varchar](1000),
		[airEconUpgradeFareReferenceKey] [varchar](1000),
		[airSegmentClassSuperSaver] [varchar](10),
		[airSegmentClassEconSaver] [varchar](10),
		[airSegmentClassFirstFlex] [varchar](10),
		[airSegmentClassEconFlex] [varchar](10),
		[airsegmentPricingKey] [nvarchar](50),
		[airsegmentFareCategory] [nvarchar](100),
		[airSegmentBrandName] [nvarchar](100),
		[airSegmentBrandID] [nvarchar](100),
		[airSegmentBaggage] [nvarchar](100),
		[airSegmentMealCode] [nvarchar](100),
		[airSegmentStops] [int],
		[ProgramCode] [varchar](20),
		[isReturnFare] [bit] NULL
	) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX [IDX_airSegmentId]	ON #Airsegments ([airSegmentId]) 

	CREATE NONCLUSTERED INDEX [IDX_airLegNumber_SegmentOrder_DepartureAirport] ON #Airsegments ([airLegNumber],[segmentOrder],[airSegmentDepartureAirport]) 
			INCLUDE ([airResponseKey])
	CREATE NONCLUSTERED INDEX [IDX_airLegNumber_SegmentOrder_ArrivalAirport] ON #Airsegments ([airLegNumber]) 
			INCLUDE ([airResponseKey],[airSegmentArrivalAirport],[segmentOrder]) 
	CREATE NONCLUSTERED INDEX [IDX_airResponseKey]	ON #Airsegments ([airResponseKey],[airLegNumber])
	CREATE NONCLUSTERED INDEX [IDX_airResponse]		ON #Airsegments ([airResponseKey])
	CREATE NONCLUSTERED INDEX [IDX_airLegNumber]	ON #Airsegments ([airLegNumber]) 
			INCLUDE ([airResponseKey],[airSegmentMarketingAirlineCode])
	CREATE NONCLUSTERED INDEX [IDX_MarketingAirlineCode] ON #Airsegments ([airSegmentMarketingAirlineCode])
			INCLUDE ([airResponseKey])

	CREATE TABLE #AirSegmentsMultiBrand(
		[airSegmentMultiBrandKey] [uniqueidentifier] NOT NULL,
		[airSegmentKey] [uniqueidentifier] NOT NULL,
		[airResponseMultiBrandKey] [uniqueidentifier] NOT NULL,
		[airResponseKey] [uniqueidentifier] NOT NULL,
		[airLegNumber] [int] NOT NULL,
		[airSegmentResBookDesigCode] [varchar](3) NULL,
		[airSegmentSeatRemaining] [int] NULL,
		[airSegmentFareBasisCode] [varchar](50) NULL,
		[airSegmentFareReferenceKey] [varchar](400) NULL,
		[airSegmentCabin] [varchar](20) NULL,
		[segmentOrder] [int] NULL,
		[airSegmentPricingKey] [nvarchar](50) NULL,
		[airSegmentBrandName] [nvarchar](100) NULL,
		[airSegmentBrandID] [nvarchar](100) NULL,
		[airSegmentBaggage] [nvarchar](100) NULL,
		[airSegmentMealCode] [nvarchar](100) NULL,
		[isReturnFare] [bit] NULL
	) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [IX_airSegmentMultiBrandKey] ON #AirSegmentsMultiBrand(airSegmentMultiBrandKey)
	CREATE NONCLUSTERED INDEX [IDX_airResponseKey_SegmentOrder_airLegNumber] ON #AirSegmentsMultiBrand ([airResponseKey])
		INCLUDE ([segmentOrder], [airLegNumber]) 
	CREATE NONCLUSTERED INDEX [IX_airResponseMultiBrandKey] ON #AirSegmentsMultiBrand([airResponseMultiBrandKey] ASC)

	SELECT @airRequestKey = airRequestKey FROM AirSubRequest WITH(NOLOCK) WHERE airSubRequestKey = @airSubRequestKey
 
	INSERT INTO #AirSubRequest 
    SELECT * FROM AirSubRequest WHERE  airrequestKey = @airRequestKey

	SELECT @isInternationalTrip = isInternationalTrip, @airRequestType = airRequestTypeKey FROM AirRequest WITH(NOLOCK) where airRequestKey = @airRequestKey
	SELECT @airSubRequestLeg2 = AirSubRequestkey FROM #AirSubRequest where groupKey = 1 and airSubRequestLegIndex = 2

	INSERT INTO #AirResponse
	SELECT [airResponseKey]
      ,[airSubRequestKey]
      ,[airPriceBase]
      ,[airPriceTax]
      ,[gdsSourceKey]
      ,[refundable]
      ,[airClass]
      ,[priceClassCommentsSuperSaver]
      ,[priceClassCommentsEconSaver]
      ,[priceClassCommentsFirstFlex]
      ,[priceClassCommentsCorporate]
      ,[priceClassCommentsEconFlex]
      ,[priceClassCommentsEconUpgrade]
      ,[airSuperSaverPrice]
      ,[airEconSaverPrice]
      ,[airFirstFlexPrice]
      ,[airCorporatePrice]
      ,[airEconFlexPrice]
      ,[airEconUpgradePrice]
      ,[airClassSuperSaver]
      ,[airClassEconSaver]
      ,[airClassFirstFlex]
      ,[airClassCorporate]
      ,[airClassEconFlex]
      ,[airClassEconUpgrade]
      ,[airSuperSaverSeatRemaining]
      ,[airEconSaverSeatRemaining]
      ,[airFirstFlexSeatRemaining]
      ,[airCorporateSeatRemaining]
      ,[airEconFlexSeatRemaining]
      ,[airEconUpgradeSeatRemaining]
      ,[airSuperSaverFareReferenceKey]
      ,[airEconSaverFareReferenceKey]
      ,[airFirstFlexFareReferenceKey]
      ,[airCorporateFareReferenceKey]
      ,[airEconFlexFareReferenceKey]
      ,[airEconUpgradeFareReferenceKey]
      ,[airPriceClassSelected]
      ,[airSuperSaverTax]
      ,[airEconSaverTax]
      ,[airEconFlexTax]
      ,[airCorporateTax]
      ,[airEconUpgradetax]
      ,[airFirstFlexTax]
      ,[airSuperSaverFareBasisCode]
      ,[airEconSaverFareBasisCode]
      ,[airFirstFlexFareBasisCode]
      ,[airCorporateFareBasisCode]
      ,[airEconFlexFareBasisCode]
      ,[airEconUpgradeFareBasisCode]
      ,[isBrandedFare]
      ,[cabinClass]
      ,[fareType]
      ,[isGeneratedBundle]
      ,[ValidatingCarrier]
      ,[contractCode]
      ,[airPriceBaseSenior]
      ,[airPriceTaxSenior]
      ,[airPriceBaseChildren]
      ,[airPriceTaxChildren]
      ,[airPriceBaseInfant]
      ,[airPriceTaxInfant]
      ,[airPriceBaseDisplay]
      ,[airPriceTaxDisplay]
      ,[airPriceBaseTotal]
      ,[airPriceTaxTotal]
      ,[airPriceBaseYouth]
      ,[airPriceTaxYouth]
      ,[airCurrencyCode]
      ,[airResponseId]
      ,[airPriceBaseInfantWithSeat]
      ,[airPriceTaxInfantWithSeat]
      ,[agentwareQueryID]
      ,[agentwareItineraryID]
      ,[Points]
      ,[ticketDesignator]
      ,[awardCode]
      ,[ITAQueryId]
      ,[ITAItineraryId]
      ,[isAvailable]
      ,[isReturnFare] 
		FROM AirResponse WITH(NOLOCK) WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM #AirSubRequest)

	INSERT INTO #Airsegments
	SELECT [airSegmentKey]
      ,[airResponseKey]
      ,[airLegNumber]
      ,[airSegmentMarketingAirlineCode]
      ,[airSegmentOperatingAirlineCode]
      ,[airSegmentFlightNumber]
      ,[airSegmentDuration]
      ,[airSegmentEquipment]
      ,[airSegmentMiles]
      ,[airSegmentDepartureDate]
      ,[airSegmentArrivalDate]
      ,[airSegmentDepartureAirport]
      ,[airSegmentArrivalAirport]
      ,[airSegmentResBookDesigCode]
      ,[airSegmentDepartureOffset]
      ,[airSegmentArrivalOffset]
      ,[airSegmentSeatRemaining]
      ,[airSegmentMarriageGrp]
      ,[airFareBasisCode]
      ,[airFareReferenceKey]
      ,[airSegmentOperatingFlightNumber]
      ,[airsegmentCabin]
      ,[segmentOrder]
      ,[amadeusSNDIndicator]
      ,[airSegmentOperatingAirlineCompanyShortName]
      ,[OriginalairsegmentCabin]
      ,[airSegmentId]
      ,[airSuperSaverFareBasisCode]
      ,[airEconSaverFareBasisCode]
      ,[airFirstFlexFareBasisCode]
      ,[airCorporateFareBasisCode]
      ,[airEconFlexFareBasisCode]
      ,[airEconUpgradeFareBasisCode]
      ,[airSuperSaverFareReferenceKey]
      ,[airEconSaverFareReferenceKey]
      ,[airFirstFlexFareReferenceKey]
      ,[airCorporateFareReferenceKey]
      ,[airEconFlexFareReferenceKey]
      ,[airEconUpgradeFareReferenceKey]
      ,[airSegmentClassSuperSaver]
      ,[airSegmentClassEconSaver]
      ,[airSegmentClassFirstFlex]
      ,[airSegmentClassEconFlex]
      ,[airsegmentPricingKey]
      ,[airsegmentFareCategory]
      ,[airSegmentBrandName]
      ,[airSegmentBrandID]
      ,[airSegmentBaggage]
      ,[airSegmentMealCode]
      ,[airSegmentStops]
      ,[ProgramCode]
      ,[isReturnFare]
		 FROM AirSegments WITH(NOLOCK) WHERE airResponseKey in (SELECT airResponseKey FROM #AirResponse)

    SELECT *,CONVERT(VARCHAR(20), '') AS airlineCode INTO #NormalizedAirResponses FROM NormalizedAirResponses WHERE airsubrequestkey IN (SELECT airSubRequestKey FROM #AirSubRequest)
	 
    IF (@isMultiBrand=1)
    BEGIN

		SELECT * INTO #AirResponseMultiBrand FROM AirResponseMultiBrand WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM #AirSubRequest)
		INSERT INTO #AirSegmentsMultiBrand
		SELECT ASMB.* FROM AirSegmentsMultiBrand ASMB WITH(NOLOCK) 
			INNER JOIN #AirResponseMultiBrand t ON ASMB.airResponseKey = t.airResponseKey 
		SELECT *,CONVERT(VARCHAR(20), '') AS airlineCode INTO #NormalizedAirResponsesMultiBrand FROM NormalizedAirResponsesMultiBrand WITH(NOLOCK) WHERE airsubrequestkey IN (SELECT airSubRequestKey FROM #AirSubRequest)

ALTER TABLE #AirResponseMultiBrand ADD PRIMARY KEY (airresponseMultiBrandkey)
CREATE NONCLUSTERED INDEX [IDX_airResponseMultiBrandKey] ON #NormalizedAirResponsesMultiBrand ([airresponseMultiBrandkey])
CREATE NONCLUSTERED INDEX [IDX_gdsSourceKey_refundable] ON #AirResponseMultiBrand ([gdsSourceKey],[refundable])
		INCLUDE ([airResponseMultiBrandKey],[airPriceBase],[airPriceTax],[airPriceBaseDisplay],[airPriceTaxDisplay])
CREATE NONCLUSTERED INDEX [IDX_airResponseKey] ON #NormalizedAirResponsesMultiBrand ([airresponsekey],[airLegNumber])
		INCLUDE ([airresponseMultiBrandkey],[airLegBrandName])
CREATE NONCLUSTERED INDEX [IDX_airResponseKeyAndOther] ON #AirResponseMultiBrand ([airResponseMultiBrandKey])
		INCLUDE ([airResponseKey],[airSubRequestKey],[airPriceBase],[airPriceTax],[gdsSourceKey],[refundable],[airPriceBaseSenior],[airPriceTaxSenior],[airPriceBaseChildren],[airPriceTaxChildren],[airPriceBaseInfant],[airPriceTaxInfant],[airPriceBaseDisplay],[airPriceTaxDisplay],[airPriceBaseTotal],[airPriceTaxTotal],[airPriceBaseYouth],[airPriceTaxYouth],[airPriceBaseInfantWithSeat],[airPriceTaxInfantWithSeat])
CREATE NONCLUSTERED INDEX [IDX_airResponseMultiBrandKey_airResponseKey] ON #NormalizedAirResponsesMultiBrand ([airresponseMultiBrandkey])
		INCLUDE ([airResponseKey])
    END

	SELECT @TripFromDate = tripFromDate1 FROM TripRequest WHERE tripRequestKey  = (SELECT tripRequestKey FROM TripRequest_air WHERE airRequestKey = @airRequestKey)
    
    IF EXISTS(SELECT 1 FROM TripRequest WHERE tripRequestKey  = (SELECT tripRequestKey FROM TripRequest_air WITH(NOLOCK) WHERE airRequestKey = @airRequestKey) AND DepartureIsParent = 1 AND DepartureRegionId <> 0)
    BEGIN
       SET @DepartureIsParent = 1
    END
    
    IF EXISTS(SELECT 1 FROM TripRequest WHERE tripRequestKey  = (SELECT tripRequestKey FROM TripRequest_air WITH(NOLOCK) WHERE airRequestKey = @airRequestKey) AND ArrivalIsParent = 1 AND ArrivalRegionId <> 0)
    BEGIN
       SET @ArrivalIsParent = 1
    END

	DECLARE @airBundledRequest AS int   
	SET @airBundledRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = -1 AND groupKey =1)   

	-- Default Value of @airBundledRequest when Not Set
	-- Only Process when RoundTrip
	IF(@airRequestType = 2)
	BEGIN
		IF(@airBundledRequest <> 0 AND @airBundledRequest IS NOT NULL)
			SELECT @isSameDaySearch = CASE WHEN DATEDIFF(DD,CONVERT(date,airRequestDepartureDate)
				,CONVERT(date,airRequestArrivalDate)) = 0 THEN 1 ELSE 0 END 
			FROM #AirSubRequest WITH(NOLOCK) where airSubRequestKey = @airBundledRequest
        
		IF(@isSameDaySearch = 0 AND @IsDomesticRegionTravel = 0)
		BEGIN
			SELECT @isSameDaySearch = CASE WHEN DATEDIFF(DD,CONVERT(date,airRequestDepartureDate)
				,CONVERT(date,airRequestArrivalDate)) <= 2 THEN 1 ELSE 0 END 
			FROM #AirSubRequest WITH(NOLOCK) where airSubRequestKey = @airBundledRequest
		END

		IF((@IsSameDayReturnOWAllowed = 1 AND @IsDomesticRegionTravel = 1 AND @isSameDaySearch = 1) OR (@IsSameDayReturnOWAllowed = 1 AND @IsDomesticRegionTravel = 0 AND @isSameDaySearch = 1))
		BEGIN
			SET @isSameDayReturnOWLogicToApply = 1
		END
	END

	IF (@SelectedResponseMultiBrandKey  IS NOT NULL AND @SelectedResponseMultiBrandKey <> '{00000000-0000-0000-0000-000000000000}')
	BEGIN
		SET @isMultiBrandSelectedOnPreviousLeg = 1
	END
	
	IF (@SelectedResponseMultiBrandKeySecond  IS NOT NULL AND @SelectedResponseMultiBrandKeySecond <> '{00000000-0000-0000-0000-000000000000}')
	BEGIN
		SET @isMultiBrandSelectedOnPreviousLeg_Second = 1
	END

	IF (@SelectedResponseMultiBrandKeyThird  IS NOT NULL AND @SelectedResponseMultiBrandKeyThird <> '{00000000-0000-0000-0000-000000000000}')
	BEGIN
		SET @isMultiBrandSelectedOnPreviousLeg_Third = 1
	END

	IF (@SelectedResponseMultiBrandKeyFourth  IS NOT NULL AND @SelectedResponseMultiBrandKeyFourth <> '{00000000-0000-0000-0000-000000000000}')
	BEGIN
		SET @isMultiBrandSelectedOnPreviousLeg_Fourth = 1
	END

	IF (@SelectedResponseMultiBrandKeyFifth  IS NOT NULL AND @SelectedResponseMultiBrandKeyFifth <> '{00000000-0000-0000-0000-000000000000}')
	BEGIN
		SET @isMultiBrandSelectedOnPreviousLeg_Fifth = 1
	END

	DECLARE @airPublishedFareRequest AS int   
	IF ( @airRequestType > 1) 
	BEGIN 
		SET @airPublishedFareRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = -1 AND groupKey =2)   
	END 
	ELSE 
	BEGIN 
		SET @airPublishedFareRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE groupKey =2)   
	END 
	
	DECLARE @airAgentWareWNRequest AS int 
	DECLARE @airAgentWareWNRequest_Leg2 AS int  
	IF(@airRequestType <> 3)
	BEGIN 
		IF ( @airRequestType > 1) 
		BEGIN 
			if(@airRequestTypeKey =1)
			begin
				SET @airAgentWareWNRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1  AND groupKey = 4)
				SET @airAgentWareWNRequest_Leg2 = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2  AND groupKey = 4)
			end
			else
			begin
				SET @airAgentWareWNRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2 AND groupKey = 4)   
			end
		END 
		ELSE 
		BEGIN 
		SET @airAgentWareWNRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1 AND groupKey = 4) 
	END
	END

	DECLARE @airTravelfusionRequest AS int 
	DECLARE @airTravelfusionRequest_Leg2 AS int  
	IF(@airRequestType <> 3)
	BEGIN 
		IF ( @airRequestType > 1) 
		BEGIN 
			if(@airRequestTypeKey =1)
			begin
				SET @airTravelfusionRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1  AND groupKey = 7)
				SET @airTravelfusionRequest_Leg2 = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2  AND groupKey = 7)
			end
			else
			begin
				SET @airTravelfusionRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2 AND groupKey = 7)   
			end
		END 
		ELSE 
		BEGIN 
			SET @airTravelfusionRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1 AND groupKey = 7) 
		END
	END

	DECLARE @airSubRequestKey_Leg2 AS INT = 0

	DECLARE @airMultiCabinRequest AS INT
	DECLARE @airMultiCabinRequest_Leg2 AS INT = 0
	DECLARE @airMultiCabinBundledRequest INT = 0
	IF(@isMultiBrand = 1)
	BEGIN
		IF ( @airRequestType > 1) 
		BEGIN 
			IF(@airRequestTypeKey =1)
			BEGIN
				IF EXISTS(SELECT 1 FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1  AND groupKey = 5 )
				BEGIN
					SET @airMultiCabinRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1  AND groupKey = 5)
					SET @airMultiCabinRequest_leg2 = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2  AND groupKey = 5)
				END
				IF EXISTS(SELECT 1 FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1  AND groupKey = 1 )
				BEGIN
					SET @airSubRequestKey_Leg2 = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2  AND groupKey = 1)
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT 1 FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 2  AND groupKey = 5 )
				SET @airMultiCabinRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE  airSubRequestLegIndex = 2 AND groupKey = 5)   
			END
		END 
		ELSE 
		BEGIN 
			IF EXISTS(SELECT 1 FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1  AND groupKey = 5 )
			SET @airMultiCabinRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = 1 AND groupKey = 5) 
		END
		IF EXISTS(SELECT 1 FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = -1  AND groupKey = 5 )
			SET @airMultiCabinBundledRequest = (SELECT TOP 1 AirSubRequestKey FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex = -1 AND groupKey = 5)   
	END
	
	DECLARE @startAirPort AS varchar(100)   
	DECLARE @endAirPort AS varchar(100)   
	SELECT  @startAirPort=  airRequestDepartureAirport ,@endAirPort=airRequestArrivalAirport FROM #AirSubRequest  WITH(NOLOCK) WHERE  airSubRequestKey = @airSubRequestKey   
	--CALCULATE DEPARTURE OFFSET AND Arrival offset     
	DECLARE @airResponseKey AS UNIQUEIDENTIFIER 
	DECLARE @departureOffset AS float
	DECLARE @arrivalOffset AS float  
	SET @airResponseKey = (SELECT Top 1 airresponsekey FROM #AirResponse r WITH (NOLOCK)  WHERE  (r.airSubRequestKey = @airBundledRequest or  r.airSubRequestKey = @airSubRequestKey or r.airSubRequestKey = @airMultiCabinRequest OR r.airSubRequestKey = @airMultiCabinBundledRequest))
	DECLARE @meetingArrivalDate DATETIME, @meetingDepartureDate DATETIME
 
	SELECT TOP 1 @departureOffset =airSegmentDepartureOffset FROM #AirSegments seg WITH (NOLOCK) WHERE airResponseKey = @airResponseKey and airLegNumber = @airRequestTypeKey  AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null ORDER by segmentOrder ASC 
	SELECT TOP 1 @arrivalOffset = airSegmentArrivalOffset  FROM #AirSegments seg WITH (NOLOCK) WHERE airResponseKey =@airResponseKey  AND airLegNumber = @airRequestTypeKey AND airSegmentArrivalAirport=@endAirPort AND airSegmentArrivalOffset is not null ORDER by segmentOrder DESC 

	/****time offset logic ends here ***/  
	DECLARE @tempResponseToRemove AS table ( airresponsekey uniqueidentifier )   
	
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
		
	DECLARE @tblGetPolicyDetailsForAir as Table      
	(      
	policyDetailKey int,      
	policyKey int,    
	policyName nvarchar(50),  
	farePolicyAmt float,      
	domFareTol varchar(10),
	domHighFareTol varchar(10),
	intlFareTol float,      
	LowFareThreshold float,      
	fareType varchar(100),      
	reasonCode int,      
	multiAirport int,      
	serviceClass varchar(100),      
	paymentForm int,      
	isFarePolicyAmt bit,      
	isIntlFareTol bit,      
	isServiceClass bit,      
	isPaymentForm bit,      
	isLowFareThreshold bit,      
	isDelete bit,      
	policyTypeName nvarchar(50),      
	IsInternational bit,      
	IsMaxConnections bit,      
	MaxConnections int,      
	IsTimeBand bit,      
	TimeBand int,    
	IsApproveFarePolicyAmt bit,    
	IsApproveInternationalFare bit,    
	IsApproveLowFareThreshold bit,    
	NoBusinessClass bit,    
	isApproveBusinessClass bit,    
	NoFirstClass bit,    
	isApproveFirstClass bit,    
	NoInternational bit,    
	IsApproveNoInternational bit,    
	AdvancePurchaseDays int,    
	IsAdvancePurchase bit,    
	IsApproveAdvancePurchase bit,    
	ApproverEmailId VARCHAR(MAX),    
	IsAllTravel BIT,
	LowFareThresholdInternational float,
	IsLowFareThresholdInternational bit,
	InternationalHighFareTol float,
	IsInternationalHighFareTol bit,
	IsDomesticHighFareTol bit,
	IsNotifyAdvancePurchase bit, 
	IsflagAdvancePurchase bit,
	AdvancePurchasePrice float,
	IsBasicUnselectable BIT,
	ApplyBasicUnselectable BIT,
	IsFlagBasicUnselectable BIT,
	IsSuppressAirline BIT,
	IsBussinessClassAllowed BIT,
	BusinessClassOverHrs INT,
	IsFlagBusinessClassOverHrs BIT,
	IsBusinessLongFlightsUnselectable BIT,
	IsFirstClassAllowed BIT,
	FirstClassOverHrs INT,
	IsFlagFirstClassOverHrs BIT,
	IsFirstLongFlightsUnselectable BIT
	)  
	 
	IF (@siteKey = 0)
	BEGIN
		IF (@UserKey <> 0)
		BEGIN
		   SELECT @siteKey = siteKey FROM Vault..[User] WHERE userkey = @UserKey
		END
	END

	SELECT @IsPolicyApplicable = ISNULL(data.value('(/Site/UI/IsPolicyApplicable/node())[1]', 'BIT'),0)
	FROM	Vault..SiteConfiguration 
	WHERE siteKey = @SiteKey

	IF (@IsPolicyApplicable = 1)
	BEGIN
		--Start - Get Policy 
		INSERT INTO @tblGetPolicyDetailsForAir 
		SELECT policyDetailKey,			policyKey,					policyName,							farePolicyAmt, 					domFareTol,							domHighFareTol, 
			   intlFareTol,				LowFareThreshold,			fareType,							reasonCode,      				multiAirport,						serviceClass, 
			   paymentForm,				isFarePolicyAmt,			isIntlFareTol,						isServiceClass,					isPaymentForm,						isLowFareThreshold, 
			   isDelete,      			policyTypeName,				IsInternational,					IsMaxConnections,				MaxConnections,						IsTimeBand, 
			   TimeBand,				IsApproveFarePolicyAmt,		IsApproveInternationalFare,			IsApproveLowFareThreshold,		NoBusinessClass,					isApproveBusinessClass, 
			   NoFirstClass,			isApproveFirstClass,		NoInternational,					IsApproveNoInternational,		AdvancePurchaseDays,				IsAdvancePurchase, 
			   IsApproveAdvancePurchase,							ApproverEmailId,					IsAllTravel,					LowFareThresholdInternational,		IsLowFareThresholdInternational,
			   InternationalHighFareTol,							IsInternationalHighFareTol,			IsDomesticHighFareTol,			IsNotifyAdvancePurchase,			IsflagAdvancePurchase, 
			   AdvancePurchasePrice,	IsBasicUnselectable,		ApplyBasicUnselectable ,			IsFlagBasicUnselectable,		IsSuppressAirline ,					IsBussinessClassAllowed,
			   BusinessClassOverHrs,	IsFlagBusinessClassOverHrs,	IsBusinessLongFlightsUnselectable,	IsFirstClassAllowed,			FirstClassOverHrs,					IsFlagFirstClassOverHrs ,	
			   IsFirstLongFlightsUnselectable
		FROM vault.dbo.[udf_GetPolicyDetailsForAir] (@UserKey, @CompanyKey, 'CORPORATE',@isInternationalTrip,@UserGroupKey)
		--End - Get Policy 
	
		--Set Domestic Fare Total/ Intl Fare Total from Policy
		IF (@isInternationalTrip = 0)
		   SELECT TOP 1 @MaxFareTotal = domFareTol, @IsHideFare = isFarePolicyAmt,  @HighFareTotal = domHighFareTol,@LowFareThreshold = LowFareThreshold, @IsLowFareThreshold = isLowFareThreshold,@IsHighFareTotal = IsDomesticHighFareTol FROM @tblGetPolicyDetailsForAir
		ELSE
		   SELECT TOP 1 @MaxFareTotal = intlFareTol, @IsHideFare = isIntlFareTol,@HighFareTotal = InternationalHighFareTol,@LowFareThreshold = LowFareThresholdInternational, @IsLowFareThreshold = IsLowFareThresholdInternational,@IsHighFareTotal = IsInternationalHighFareTol FROM @tblGetPolicyDetailsForAir

		SELECT TOP 1 @isAdvancePurchase = isAdvancePurchase,				@IsNotifyAdvancePurchase = IsNotifyAdvancePurchase, @IsApproveAdvancePurchase = IsApproveAdvancePurchase,		@IsflagAdvancePurchase=IsflagAdvancePurchase,	@AdvancePurchaseDays = AdvancePurchaseDays, @AdvancePurchasePrice = AdvancePurchasePrice, 
					 @IsBasicUnselectable = IsBasicUnselectable,			@ApplyBasicUnselectable = ApplyBasicUnselectable ,	@IsFlagBasicUnselectable  = IsFlagBasicUnselectable ,		@IsSuppressAirline = IsSuppressAirline,			@PolicyKey = policyKey,
					 @IsBussinessClassAllowed = IsBussinessClassAllowed,	@BusinessClassOverHrs=BusinessClassOverHrs,			@IsFlagBusinessClassOverHrs = IsFlagBusinessClassOverHrs,	@IsBusinessLongFlightsUnselectable = IsBusinessLongFlightsUnselectable,	
					 @IsFirstClassAllowed=IsFirstClassAllowed,				@FirstClassOverHrs = FirstClassOverHrs,				@IsFlagFirstClassOverHrs =	IsFlagFirstClassOverHrs,	    @IsFirstLongFlightsUnselectable = IsFirstLongFlightsUnselectable

		FROM @tblGetPolicyDetailsForAir
	END

	--Event Id
	IF (@EventId <> 0)
	BEGIN
		select @meetingArrivalDate = meetingArrivalDate, @meetingDepartureDate = meetingDepartureDate from vault..Meeting where meetingCodeKey = @EventId
	END

	IF 	@superSetAirlines IS NOT NULL AND @superSetAirlines <> '' AND @allowedOperatingAirlines IS NOT NULL AND @allowedOperatingAirlines <> ''
	BEGIN
	-- insert data to airline tables
		INSERT @tblSuperAirlines (marketingAirline) SELECT * FROM vault .dbo.ufn_CSVToTable (@superSetAirlines)		
		INSERT @tblOperatingAirlines (operatingAirline) SELECT * FROM vault.dbo.ufn_CSVToTable (@allowedOperatingAirlines) 

		-- gourpkey 1: Add data to @tblAirlinesGroup(combination) table from @tblSuperAirlines and @tblOperatingAirlines
		INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 
		SELECT A.marketingAirline,b.operatingAirline, 1 from @tblSuperAirlines A 
		CROSS JOIN @tblOperatingAirlines B 	
		ORDER BY A.marketingAirline,B.operatingAirline	

		IF @airPublishedFareRequest > 0
		BEGIN
		-- gourpkey 2: Add data to @tblAirlinesGroup(combination) table @tblOperatingAirlines  
		INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 
		SELECT A.operatingAirline,b.operatingAirline, 2 from @tblOperatingAirlines A 
		CROSS JOIN @tblOperatingAirlines B 	
		ORDER BY A.operatingAirline,B.operatingAirline	
		END		
		
		IF @airAgentWareWNRequest > 0
		BEGIN
		-- gourpkey 4: Add data to @tblAirlinesGroup(combination) table @tblOperatingAirlines  
		INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 
		SELECT A.operatingAirline,b.operatingAirline,4 from @tblOperatingAirlines A 
		CROSS JOIN @tblOperatingAirlines B 	
		ORDER BY A.operatingAirline,B.operatingAirline	
		END		

		IF @airTravelfusionRequest > 0
		BEGIN
		-- gourpkey 7: Add data to @tblAirlinesGroup(combination) table @tblOperatingAirlines  
		INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 
		SELECT A.operatingAirline,b.operatingAirline,7 from @tblOperatingAirlines A 
		CROSS JOIN @tblOperatingAirlines B 	
		ORDER BY A.operatingAirline,B.operatingAirline	
		END

		---- Add data to @tblAirlinesGroup(combination) table from affiliate airlines
		IF @siteKey is not null AND @siteKey <> '' AND @siteKey > 0
		BEGIN 	
		IF (select COUNT(affiliateKey) from vault.dbo.affiliateAirlines where siteKey = @siteKey) > 0
		BEGIN			
			INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 			
			SELECT AFF.MarketingAirline, AFF.OperatingAirline, 1 
			FROM vault.dbo.affiliateAirlines AFF
			INNER JOIN @tblSuperAirlines S ON AFF.MarketingAirline = S.marketingAirline
			WHERE AFF.SiteKey = @siteKey
			
			IF @airPublishedFareRequest > 0 -- For GroupKey 2(Publish fares)
			BEGIN						
				INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 			
				SELECT AFF.MarketingAirline, AFF.OperatingAirline, 2 from vault.dbo.affiliateAirlines AFF
				WHERE AFF.SiteKey = @siteKey
			END
			
			IF @airAgentWareWNRequest > 0 -- For GroupKey 4(AgentWare WN Fares)
			BEGIN						
				INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 			
				SELECT AFF.MarketingAirline, AFF.OperatingAirline, 4 from vault.dbo.affiliateAirlines AFF
				WHERE AFF.SiteKey = @siteKey
			END

			IF @airTravelfusionRequest > 0 -- For GroupKey 7(Travelfusion Fares)
			BEGIN						
				INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 			
				SELECT AFF.MarketingAirline, AFF.OperatingAirline, 7 from vault.dbo.affiliateAirlines AFF
				WHERE AFF.SiteKey = @siteKey
			END
		END
		
		--Exclude Non Discounted Fare
    	IF (select COUNT(ExcludeNonDiscountedFareAirlinesKey) from vault.dbo.ExcludeNonDiscountedFareAirlines where siteKey = @siteKey) > 0
		BEGIN			
			INSERT INTO @tblExcludeNonDiscountedFareAirlines(marketingAirline) 			
			SELECT NF.MarketingAirline
			FROM vault.dbo.ExcludeNonDiscountedFareAirlines NF
			INNER JOIN @tblSuperAirlines S ON NF.MarketingAirline = S.marketingAirline
			WHERE NF.SiteKey = @siteKey
		
			INSERT @tempResponseToRemove (airresponsekey )   
			(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
			INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
			INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
			WHERE airSegmentMarketingAirlineCode in (SELECT * FROM @tblExcludeNonDiscountedFareAirlines) 
			AND (resp.fareType is NULL OR ltrim(rtrim(resp.fareType))=''))
		END
	END
	
	-- Add all responsekey to @tempResponseToRemove EXCEPT combinations from @tblAirlinesGroup table
		IF (SELECT COUNT(*) FROM @tblAirlinesGroup) > 0
		BEGIN
			INSERT @tempResponseToRemove (airresponsekey )
			(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
			INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
			INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
			WHERE SUB.groupKey = 1
			AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
			(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 1))

			IF @airPublishedFareRequest > 0 -- For GroupKey 2(Publish fares)
			BEGIN
				INSERT @tempResponseToRemove (airresponsekey )
				(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
				INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
				INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
				WHERE SUB.groupKey = 2
				AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
				(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 2))
			END			
			
			IF @airAgentWareWNRequest > 0 -- For GroupKey 4(AgentWare WN Fares)
			BEGIN
				INSERT @tempResponseToRemove (airresponsekey )
				(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
				INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
				INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
				WHERE SUB.groupKey = 12
				AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
				(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 4))
			END
			
			IF @airTravelfusionRequest > 0 -- For GroupKey 7(Travelfusion Fares)
			BEGIN
				INSERT @tempResponseToRemove (airresponsekey )
				(SELECT DISTINCT S.airresponsekey FROM #AirSegments S WITH(NOLOCK) 
				INNER JOIN #AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
				INNER JOIN #AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
				WHERE SUB.groupKey = 19
				AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
				(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 7))
			END			
		END
	END	

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
			WHERE(  r.airSubRequestKey = @airSubRequestKey      )
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
	
	--Removning responses when specific airport is selected for AgentWare
	IF (@DepartureIsParent=0 AND @airAgentWareWNRequest > 0)
	BEGIN
		INSERT @tempResponseToRemove (airresponsekey) 
		(SELECT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey AND subReq.groupKey=4
		WHERE airLegNumber =@airRequestTypeKey AND segmentOrder = 1 
		AND airSegmentDepartureAirport <> @startAirPort)
	END    
	               
	IF (@ArrivalIsParent=0 AND @airAgentWareWNRequest > 0)
	BEGIN
	
	    INSERT @tempResponseToRemove (airresponsekey) 
		(SELECT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey AND subReq.groupKey=4
		WHERE airLegNumber = @airRequestTypeKey 
		AND LTRIM(RTRIM(airSegmentArrivalAirport)) <> LTRIM(RTRIM(@endAirPort))
		AND segmentOrder = (SELECT COUNT(S.segmentOrder) FROM #Airsegments S WHERE airResponseKey = resp.airResponseKey AND s.airLegNumber = @airRequestTypeKey))
	END
	
	--Removing responses when specific airport is selected for Travelfusion
	IF (@DepartureIsParent=0 AND @airTravelfusionRequest > 0)
	BEGIN 
		INSERT @tempResponseToRemove (airresponsekey) 
		(SELECT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey AND subReq.groupKey=7
		WHERE airLegNumber =@airRequestTypeKey AND segmentOrder = 1 
		AND airSegmentDepartureAirport <> @startAirPort)
	END 

	IF (@ArrivalIsParent=0 AND @airTravelfusionRequest > 0)
	BEGIN
	
	    INSERT @tempResponseToRemove (airresponsekey) 
		(SELECT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey AND subReq.groupKey=7
		WHERE airLegNumber = @airRequestTypeKey 
		AND LTRIM(RTRIM(airSegmentArrivalAirport)) <> LTRIM(RTRIM(@endAirPort))
		AND segmentOrder = (SELECT COUNT(S.segmentOrder) FROM #Airsegments S WHERE airResponseKey = resp.airResponseKey AND s.airLegNumber = @airRequestTypeKey))
	END

    IF (@isMultiBrand=1)
	BEGIN 
			IF (@IsPolicyApplicable = 1)
			BEGIN
				IF EXISTS(SELECT TOP 1 isServiceClass FROM @tblGetPolicyDetailsForAir WHERE isServiceClass  = 1)
			BEGIN
					SELECT @policyCabin = serviceClass FROM @tblGetPolicyDetailsForAir WHERE isServiceClass  = 1
					IF(@policyCabin IS NOT NULL AND @policyCabin <> '0' AND UPPER(@policyCabin) <> 'UNKNOWN')
					BEGIN
						DECLARE @cabins AS table (cabinLevel int,cabin varchar(20))  
						INSERT @cabins VALUES(1,'Economy' ),(2,'Premium Economy'),(3,'Business'),(4,'First')  
						
						DECLARE @vcbLevel INT
						IF(UPPER(@policyCabin) = 'ECONOMYPREMIUM')
						BEGIN
							SELECT @vcbLevel = cabinLevel FROM @cabins WHERE cabin = 'Premium Economy'
						END
						ELSE
						BEGIN
							SELECT @vcbLevel = cabinLevel FROM @cabins WHERE UPPER(cabin) = UPPER(@policyCabin)
						END

						INSERT INTO @tblCabinGroup
						SELECT cabin From @cabins WHERE cabinLevel <= @vcbLevel


						-- new policy integration to not hide the cabin class, first and business
						IF (@IsBussinessClassAllowed=1)
						BEGIN
							IF NOT EXISTS(SELECT cabin FROM @tblCabinGroup WHERE cabin='Business')
							BEGIN
								INSERT INTO @tblCabinGroup VALUES('Business')
								
							END
						END
						IF(@IsFirstClassAllowed=1)
						BEGIN
							IF NOT EXISTS(SELECT cabin FROM @tblCabinGroup WHERE cabin='First')
							BEGIN
								INSERT INTO @tblCabinGroup VALUES('First')
								
							END
						END

						DECLARE @tempResponseToRemoveBefore INT = 0
						DECLARE @tempResponseToRemoveAfter INT = 0
						SELECT @tempResponseToRemoveBefore = COUNT(airresponsekey) FROM @tempResponseToRemove

						INSERT @tempResponseToRemove (airresponsekey )   
						(SELECT DISTINCT s.airResponseKey FROM #AirSegments s WITH(NOLOCK) 
						INNER JOIN #AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
						INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
						WHERE Upper(airsegmentCabin) NOT IN (SELECT UPPER(cabin) FROM @tblCabinGroup))
						
						SELECT @tempResponseToRemoveAfter = COUNT(airresponsekey) FROM @tempResponseToRemove

						IF(@tempResponseToRemoveBefore < @tempResponseToRemoveAfter)
						BEGIN
							SET @isOutOfPolicyResultsPresent = 1
						END

						INSERT @tempResponseToRemove_MultiBrand (airresponseMultiBrandkey )   
						(SELECT DISTINCT s.airResponseMultiBrandKey FROM #AirSegmentsMultiBrand s WITH(NOLOCK) 
						INNER JOIN #AirResponseMultiBrand resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
						INNER JOIN #AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
						WHERE UPPER(airsegmentCabin) NOT IN (SELECT UPPER(cabin) FROM @tblCabinGroup))
					END
			END
			END
	END
	
	-- exclude responses not between MeetingArrivalDate & meetingDepartureDate
	IF (@EventId <> 0)
	BEGIN
	    IF (@meetingArrivalDate IS NOT NULL)
		BEGIN
			INSERT @tempResponseToRemove (airresponsekey) 
			(SELECT DISTINCT seg.airResponseKey  FROM #AirSegments seg WITH(NOLOCK) 
			INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
			INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
			WHERE seg.airLegNumber = 1 
			AND segmentOrder = (select max(segmentOrder) from #AirSegments A WHERE A.airResponseKey = resp.airResponseKey AND A.airLegNumber = 1)
			AND seg.airSegmentArrivalDate > @meetingArrivalDate)
		END

		IF (@meetingDepartureDate IS NOT NULL)
		BEGIN
			INSERT @tempResponseToRemove (airresponsekey ) 
			(SELECT DISTINCT seg.airResponseKey FROM #AirSegments seg WITH(NOLOCK) 
			INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
			INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
			WHERE seg.airLegNumber = 2 AND segmentOrder = 1
			AND seg.airSegmentDepartureDate < @meetingDepartureDate)
		END
   END

  IF(@isSameDayReturnOWLogicToApply = 1 AND @airRequestTypeKey = 2)
  BEGIN
		SELECT @SelectedResponseArrivalAirport = airSegmentarrivalairport, @SelectedResponseArrivalAirportDate= airSegmentArrivalDate FROm #AirSegments AirSegment WITH(NOLOCK) where airResponseKey = @SelectedResponseKey 
		AND segmentOrder = (select max(segmentOrder) from #AirSegments A WHERE A.airResponseKey = @SelectedResponseKey AND A.airLegNumber = 1) and AirSegment.airLegNumber = 1

		INSERT @tempResponseToRemove (airresponsekey) 
		(SELECT DISTINCT seg.airResponseKey  FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		WHERE seg.airLegNumber = 2 
		AND segmentOrder = 1
		AND airSegmentDepartureDate < @SelectedResponseArrivalAirportDate
		AND subreq.airSubRequestKey IN (@airSubRequestLeg2,@airMultiCabinRequest))

		INSERT @tempResponseToRemove (airresponsekey) 
		(SELECT DISTINCT seg.airResponseKey  FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		WHERE seg.airLegNumber = 2 
		AND segmentOrder = 1
		AND Datediff(minute,@SelectedResponseArrivalAirportDate,seg.airSegmentDepartureDate) <= @changeOverTimeinMinutes AND seg.airSegmentDepartureAirport = @SelectedResponseArrivalAirport
		AND subreq.airSubRequestKey IN (@airSubRequestLeg2,@airMultiCabinRequest))

		INSERT @tempResponseToRemove (airresponsekey) 
		(SELECT DISTINCT seg.airResponseKey  FROM #AirSegments seg WITH(NOLOCK) 
		INNER JOIN #AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN #AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		WHERE seg.airLegNumber = 2 
		AND segmentOrder = 1
		AND Datediff(minute,@SelectedResponseArrivalAirportDate,seg.airSegmentDepartureDate) <= @changeOverTimeinMinutes_AlternateAirport AND seg.airSegmentDepartureAirport <> @SelectedResponseArrivalAirport
		AND subreq.airSubRequestKey IN (@airSubRequestLeg2,@airMultiCabinRequest))
  END

	/****logic for calculating price for higher legs *****/  
	DECLARE @airPriceForAnotherLeg AS FLOAT = 0 
	DECLARE @airPriceTaxForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceSeniorForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceTaxSeniorForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceChildrenForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceTaxChildrenForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceInfantForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceTaxInfantForAnotherLeg AS FLOAT= 0 
	DECLARE @airPriceYouthForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceTaxYouthForAnotherLeg AS FLOAT= 0 
	DECLARE @airPriceTotalForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceTaxTotalForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceDisplayForAnotherLeg AS FLOAT  = 0 
	DECLARE @airPriceTaxDisplayForAnotherLeg AS FLOAT   = 0 
	DECLARE @airPriceInfantWithSeatForAnotherLeg AS FLOAT= 0 
	DECLARE @airPriceTaxInfantWithSeatForAnotherLeg AS FLOAT= 0 
	DECLARE @anotherLegAirlines as varchar(50)
	DECLARE @anotherLegAirlinesCount AS INT

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
		INSERT into @tmpAirline(airlineCode)  SELECT DISTINCT seg1.airSegmentMarketingAirlineCode FROM #AirSegments seg1  WITH (NOLOCK) INNER JOIN #AirResponse resp  WITH (NOLOCK) ON seg1.airResponseKey = resp.airResponseKey WHERE ( resp.airSubRequestKey = @airSubRequestKey or resp .airSubRequestKey = @airBundledRequest or resp .airSubRequestKey = @airPublishedFareRequest or resp.airSubRequestKey = @airAgentWareWNRequest or resp.airSubRequestKey = @airTravelfusionRequest or resp.airSubRequestKey = @airMultiCabinRequest OR resp.airSubRequestKey = @airMultiCabinBundledRequest )  
		INSERT into @tmpAirline (airLineCode ) VALUES  ('Multiple Airlines')  
	END     

	DECLARE  @selectedDate AS DATETIME
	
	DECLARE @cabinUniq AS TABLE   
	(  
	gdsSourceKey int,
	airLegBrandName VARCHAR(20),
	isRefundable BIT
	) 
	
	DECLARE @airlineCabinUniq AS TABLE   
	(  
		gdsSourceKey int,
		airLegBrandName VARCHAR(20),
		isRefundable BIT,
		airlineCode VARCHAR(20) DEFAULT ''
	) 

	INSERT INTO @cabinUniq VALUES(2,'BASIC',0)--BASIC non refundable
								,(2,'MAIN',0)--main non refundable
								,(2,'MAIN',1)--main refundable
								,(2,'FIRST',0)--first non refundable
								,(2,'FIRST',1)--first refundable
								,(2,'BUSINESS',0)--business non refundable
								,(2,'BUSINESS',1)--business refundable
								,(2,'SELECT',0)--Premium economy non refundable
								,(2,'SELECT',1)--premium economy refundable
								,(12,'BASIC',0)-- AgentWare wanna get away fare (non refundable)
								,(12,'MAIN',1)--AgentWare Anytime Fare (refundable)
								,(12,'SELECT',1)--AgentWare select business (refundable)
								,(19,'BASIC',0)--Travelfusion Economy with restriction (non refundable)
								,(19,'MAIN',0)--Travelfusion Economy with/ without restriction (non refundable)
								,(19,'MAIN',1)--Travelfusion Economy with/ without restriction (refundable)
								,(19,'BUSINESS',0)--Travelfusion business (non refundable)
								,(19,'BUSINESS',1)--Travelfusion business (refundable)
								,(19,'FIRST',0)--Travelfusion first (non refundable)
								,(19,'FIRST',1)--Travelfusion first (refundable)

	IF (@airLines <> '' and @isIgnoreAirlineFilter <> 1 AND @isMultiBrand = 1 AND @isCabinUniquification = 1)
	BEGIN

	  INSERT INTO @airlineCabinUniq SELECT gdsSourceKey, airLegBrandName ,isRefundable ,airlineCode 
	  FROM @cabinUniq CROSS JOIN @tmpAirline 
	  WHERE gdsSourceKey = 2
	  
	  IF EXISTS( SELECT 1 FROM @tmpAirline WHERE airLineCode = 'WN')
	  BEGIN
		  INSERT INTO @airlineCabinUniq SELECT gdsSourceKey, airLegBrandName ,isRefundable ,'WN' 
		  FROM @cabinUniq 
		  WHERE gdsSourceKey =12
	  END
	  
	  INSERT INTO @airlineCabinUniq SELECT gdsSourceKey, airLegBrandName ,isRefundable ,airlineCode 
	  FROM @cabinUniq CROSS JOIN @tmpAirline 
	  WHERE gdsSourceKey = 19

      UPDATE #NormalizedAirResponses 
	  SET airlineCode =	A.airlineCode
	  FROM
	  (
		  SELECT (CASE WHEN (COUNT(DISTINCT seg.airSegmentMarketingAirlineCode))> 1 THEN 'Multiple Airlines' ELSE MIN (seg.airSegmentMarketingAirlineCode ) END ) AS airlineCode,
				  resp.airresponsekey AS airResponseKey1
		  FROM #AirResponse  resp 
		  INNER JOIN #Airsegments seg on resp.airResponseKey = seg.airResponseKey AND seg.airLegNumber = 1
		  GROUP BY resp.airresponsekey
	  ) A
	  WHERE airResponsekey = A.airResponsekey1 AND airLegNumber = 1

	  
	  UPDATE #NormalizedAirResponses 
	  SET airlineCode =	A.airlineCode
	  FROM
	  (
		  SELECT (CASE WHEN (COUNT(DISTINCT seg.airSegmentMarketingAirlineCode))> 1 THEN 'Multiple Airlines' ELSE MIN (seg.airSegmentMarketingAirlineCode ) END ) AS airlineCode,
				  resp.airresponsekey AS airResponseKey1
		  FROM #AirResponse  resp 
		  INNER JOIN #Airsegments seg on resp.airResponseKey = seg.airResponseKey AND seg.airLegNumber = 2
		  GROUP BY resp.airresponsekey
	  ) A
	  WHERE airResponsekey = A.airResponsekey1 AND airLegNumber = 2


	  
	  UPDATE #NormalizedAirResponsesMultiBrand 
	  SET airlineCode =	A.airlineCode
	  FROM
	  (
		  SELECT (CASE WHEN (COUNT(DISTINCT seg.airSegmentMarketingAirlineCode))> 1 THEN 'Multiple Airlines' ELSE MIN (seg.airSegmentMarketingAirlineCode ) END ) AS airlineCode,
				  resp.airresponsekey AS airResponseKey1
		  FROM #AirResponseMultiBrand  resp  
		  INNER JOIN #AirSegmentsMultiBrand SM on resp.airResponseMultiBrandKey = SM.airResponseMultiBrandKey
		  INNER JOIN #Airsegments seg on resp.airResponseKey = seg.airResponseKey AND seg.airLegNumber = 1
		  GROUP BY resp.airresponsekey
	  ) A
	  WHERE airResponsekey = A.airResponsekey1 AND airLegNumber = 1

	  UPDATE #NormalizedAirResponsesMultiBrand 
	  SET airlineCode =	A.airlineCode
	  FROM
	  (
		  SELECT (CASE WHEN (COUNT(DISTINCT seg.airSegmentMarketingAirlineCode))> 1 THEN 'Multiple Airlines' ELSE MIN (seg.airSegmentMarketingAirlineCode ) END ) AS airlineCode,
				  resp.airresponsekey AS airResponseKey1
		  FROM #AirResponseMultiBrand  resp  
		  INNER JOIN #AirSegmentsMultiBrand SM on resp.airResponseMultiBrandKey = SM.airResponseMultiBrandKey
		  INNER JOIN #Airsegments seg on resp.airResponseKey = seg.airResponseKey AND seg.airLegNumber = 2
		  GROUP BY resp.airresponsekey
	  ) A
	  WHERE airResponsekey = A.airResponsekey1 AND airLegNumber = 2

      SET @isAirlineUniquification = 1;
	END


	DECLARE @multiLegPrice AS TABLE   
	(  
	gdsSourceKey int,
	airPriceBase float ,  
	airPriceTax float,   
	airPriceBaseSenior float,
	airPriceTaxSenior float,
	airPriceBaseChildren float,
	airPriceTaxChildren float,
	airPriceBaseInfant float,
	airPriceTaxInfant float,
	airPriceBaseYouth float,
	airPriceTaxYouth float,
	AirPriceBaseTotal float,
	AirPriceTaxTotal float,
	airPriceBaseDisplay float,
	airPriceTaxDisplay float,
	airresponsekey uniqueidentifier ,
	airPriceBaseInfantWithSeat float,
	airPriceTaxInfantWithSeat float,
	airLegBrandName VARCHAR(20),
	isRefundable BIT,
	airlineCode VARCHAR(20) DEFAULT ''
	) 
	DECLARE @upSellLegPrice AS TABLE   
	(  
	airPriceBase float ,  
	airPriceTax float,   
	airPriceBaseSenior float,
	airPriceTaxSenior float,
	airPriceBaseChildren float,
	airPriceTaxChildren float,
	airPriceBaseInfant float,
	airPriceTaxInfant float,
	airPriceBaseYouth float,
	airPriceTaxYouth float,
	AirPriceBaseTotal float,
	AirPriceTaxTotal float,
	airPriceBaseDisplay float,
	airPriceTaxDisplay float,
	airresponsekey uniqueidentifier ,
	airPriceBaseInfantWithSeat float,
	airPriceTaxInfantWithSeat float
	) 
	IF ( @airRequestTypeKey = 1 AND @isSameDayReturnOWLogicToApply = 0 )   
	BEGIN   
			IF ( @airLines = '' OR (@airLines = 'Multiple Airlines' AND @isAirlineUniquification = 0))   
				BEGIN    
				   IF (@isCabinUniquification = 0)
				       BEGIN
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						select top 1 gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName  
						from #AirResponse  Resp WITH (NOLOCK)
						inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
						WHERE airSubRequestLegIndex = 2 and 
						ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
						and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
						order by (resp.airPriceBase + resp.airPriceTax)asc
						
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						select top 1 12, airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
						from #AirResponse  Resp WITH (NOLOCK)
						inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
						WHERE airSubRequestLegIndex = 2 and resp.gdsSourceKey = 12  
						and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
						order by (resp.airPriceBase + resp.airPriceTax)asc

						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						select top 1 19, airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
						from #AirResponse  Resp WITH (NOLOCK)
						inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
						WHERE airSubRequestLegIndex = 2 and resp.gdsSourceKey = 19  
						and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
						order by (resp.airPriceBase + resp.airPriceTax)asc
				   END
				   ELSE
					   BEGIN
					   		INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
							select TOP 1 gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName  
							from #AirResponse  Resp WITH (NOLOCK)
							inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
							WHERE airSubRequestLegIndex = 2 and 
							ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
							and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
							order by (resp.airPriceBase + resp.airPriceTax)asc
							
							INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
							select top 1 12, airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
							from #AirResponse  Resp WITH (NOLOCK)
							inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
							WHERE airSubRequestLegIndex = 2 and resp.gdsSourceKey = 12  
							and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
							order by (resp.airPriceBase + resp.airPriceTax)asc

							INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
							select top 1 19, airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
							from #AirResponse  Resp WITH (NOLOCK)
							inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
							WHERE airSubRequestLegIndex = 2 and resp.gdsSourceKey = 19  
							and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
							order by (resp.airPriceBase + resp.airPriceTax)asc

							SELECT 
								Row_number() over(partition by airLegBrandName, refundable,gdsSourceKey  order by airpriceBase + airPriceTax ASC) Row_Num
							,gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
							,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
							,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
							,airPriceTaxInfantWithSeat,airLegBrandName,refundable
							 into #Final FROM
							(
							SELECT 
							gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
							FROM #NormalizedAirResponses N 
							INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
							INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
							WHERE airSubRequestLegIndex = 2 
							AND NOT EXISTS (SELECT airresponsekey FROM @tempResponseToRemove WHERE airresponsekey=N.airResponseKey) 
							AND EXISTS(SELECT 1 FROM @cabinUniq WHERE airLegBrandName = N.airLegBrandName AND isRefundable = resp.refundable AND gdsSourceKey = resp.gdsSourceKey)
							UNION ALL
							SELECT 
							gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
							FROM #NormalizedAirResponsesMultiBrand N 
							INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
							INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
							WHERE airSubRequestLegIndex = 2 
							and NOT EXISTS (SELECT airresponsekey FROM @tempResponseToRemove WHERE airresponsekey=N.airResponseKey ) 
							AND EXISTS(SELECT 1 FROM @cabinUniq WHERE airLegBrandName = N.airLegBrandName 
							AND isRefundable = resp.refundable AND gdsSourceKey = resp.gdsSourceKey)
							) A
												
							MERGE #Final F
							USING (SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
							,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
							,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
							,airPriceTaxInfantWithSeat,airLegBrandName,refundable from #Final where refundable=1 and row_num=1 and lower(airLegBrandName) <>'basic' ) C
							ON (f.airLegBrandName=c.airLegBrandName and f.gdsSourceKey=2 and f.refundable=0 and f.row_num=1)
							WHEN NOT MATCHED THEN
							INSERT  
							(row_num,gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
							,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
							,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
							,airPriceTaxInfantWithSeat,airLegBrandName,refundable) 
							VALUES
							(1,c.gdsSourceKey,c.airPriceBAse,c.airPriceTax,c.airPriceBaseSenior,c.airPriceTaxSenior,c.airPriceBaseChildren,c.airPriceTaxChildren 
							,c.airPriceBaseInfant,c.airPriceTaxInfant,c.airPriceBaseYouth ,c.airPriceTaxYouth ,c.AirPriceBaseTotal,c.AirPriceTaxTotal
							,c.airPriceBaseDisplay,c.airPriceTaxDisplay,c.airResponseKey,c.airPriceBaseInfantWithSeat
							,c.airPriceTaxInfantWithSeat,c.airLegBrandName,0);

							INSERT INTO @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName, isRefundable)  
							SELECT gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName,Refundable
							FROM #Final WHERE Row_Num=1 ORDER BY airpriceBase + airPriceTax ASC
							
					END
				END   
				ELSE   
				BEGIN  
				  IF (@isCabinUniquification = 0)
				  BEGIN
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey, airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						SELECT  TOP 1  gdsSourceKey,  airpricebase ,airpricetax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat, '' AS airLegBrandName
						FROM #AirResponse resp  WITH (NOLOCK)  
						inner join #AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey = subReq.airSubRequestKey   
						inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
						inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
						WHERE airSubRequestLegIndex = 2 and  
						ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  and resp.airResponseKey not in ( select airresponsekey from @tempResponseToRemove )   
						order by (airPriceBase + airPriceTax)asc 
						
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey, airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						SELECT  TOP 1  12,  airpricebase ,airpricetax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
						FROM #AirResponse resp  WITH (NOLOCK)  
						inner join #AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey = subReq.airSubRequestKey   
						inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
						inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
						WHERE airSubRequestLegIndex = 2  and  
						resp.gdsSourceKey = 12 and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
						order by  (airPriceBase + airPriceTax)asc
						
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey, airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						SELECT  TOP 1  19,  airpricebase ,airpricetax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
						FROM #AirResponse resp  WITH (NOLOCK)  
						inner join #AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey = subReq.airSubRequestKey   
						inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
						inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
						WHERE airSubRequestLegIndex = 2  and  
						resp.gdsSourceKey = 19 and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
						order by  (airPriceBase + airPriceTax)asc 						
				  END
	    		  ELSE
				  BEGIN
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey, airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						SELECT  TOP 1  gdsSourceKey,  airpricebase ,airpricetax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat, '' AS airLegBrandName
						FROM #AirResponse resp  WITH (NOLOCK)  
						inner join #AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey = subReq.airSubRequestKey   
						inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
						inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
						WHERE airSubRequestLegIndex = 2  and  
						ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  and resp.airResponseKey not in ( select airresponsekey from @tempResponseToRemove )   
						order by (airPriceBase + airPriceTax)asc 
						
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey, airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						SELECT  TOP 1  12,  airpricebase ,airpricetax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
						FROM #AirResponse resp  WITH (NOLOCK)  
						inner join #AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey = subReq.airSubRequestKey   
						inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
						inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
						WHERE airSubRequestLegIndex = 2  and  
						resp.gdsSourceKey = 12 and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
						order by  (airPriceBase + airPriceTax)asc
						
						INSERT @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey, airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
						SELECT  TOP 1  19,  airpricebase ,airpricetax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,'' AS airLegBrandName 
						FROM #AirResponse resp  WITH (NOLOCK)  
						inner join #AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey = subReq.airSubRequestKey   
						inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
						inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
						WHERE airSubRequestLegIndex = 2  and  
						resp.gdsSourceKey = 19 and resp.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
						order by  (airPriceBase + airPriceTax)asc 						
						
						SELECT 
							Row_number() over(partition by airLegBrandName, refundable,gdsSourceKey  order by airpriceBase + airPriceTax ASC) Row_Num
							,gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
							,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
							,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
							,airPriceTaxInfantWithSeat,airLegBrandName,refundable
						INTO #Final1 FROM
						(
						SELECT 
						gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
						FROM #NormalizedAirResponses N 
						INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
						INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
						WHERE airSubRequestLegIndex = 2 
						AND NOT EXISTS (SELECT airresponsekey FROM @tempResponseToRemove WHERE airresponsekey=N.airResponseKey)
						AND EXISTS(SELECT 1 FROM @cabinUniq WHERE airLegBrandName = N.airLegBrandName AND isRefundable = resp.refundable AND gdsSourceKey = resp.gdsSourceKey)
						UNION ALL
						SELECT 
						gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
						FROM #NormalizedAirResponsesMultiBrand N 
						INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
						INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
						WHERE airSubRequestLegIndex = 2
						AND NOT EXISTS (SELECT airresponsekey FROM @tempResponseToRemove WHERE airresponsekey=N.airResponseKey )
						AND EXISTS(SELECT 1 FROM @cabinUniq WHERE airLegBrandName = N.airLegBrandName 
						AND isRefundable = resp.refundable AND gdsSourceKey = resp.gdsSourceKey)
						) A
												
						MERGE #Final1 F
						USING (SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
						,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
						,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
						,airPriceTaxInfantWithSeat,airLegBrandName,refundable from #Final1 where refundable=1 and row_num=1 and lower(airLegBrandName) <>'basic' ) C
						ON (f.airLegBrandName=c.airLegBrandName and f.gdsSourceKey=2 and f.refundable=0 and f.row_num=1)
						WHEN NOT MATCHED THEN
						INSERT  
						(row_num,gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
						,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
						,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
						,airPriceTaxInfantWithSeat,airLegBrandName,refundable) 
						VALUES
						(1,c.gdsSourceKey,c.airPriceBAse,c.airPriceTax,c.airPriceBaseSenior,c.airPriceTaxSenior,c.airPriceBaseChildren,c.airPriceTaxChildren 
						,c.airPriceBaseInfant,c.airPriceTaxInfant,c.airPriceBaseYouth ,c.airPriceTaxYouth ,c.AirPriceBaseTotal,c.AirPriceTaxTotal
						,c.airPriceBaseDisplay,c.airPriceTaxDisplay,c.airResponseKey,c.airPriceBaseInfantWithSeat
						,c.airPriceTaxInfantWithSeat,c.airLegBrandName,0);

						INSERT INTO @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName, isRefundable)  
						SELECT gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName,Refundable
						FROM #Final1 WHERE Row_Num=1 ORDER BY airpriceBase + airPriceTax ASC

						SELECT 
							 Row_number() over(partition by airLegBrandName, refundable,gdsSourceKey,airlineCode  order by airpriceBase + airPriceTax ASC) Row_Num
							,gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
							,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
							,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
							,airPriceTaxInfantWithSeat,airLegBrandName,refundable , airlineCode
						INTO #airlineFinal 
						FROM
						(
							SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable,	N.airlineCode 
							FROM #NormalizedAirResponses N 
							INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
							INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
							WHERE airSubRequestLegIndex = 2 
							AND NOT EXISTS (select airresponsekey from @tempResponseToRemove WHERE airresponsekey=N.airResponseKey) 
							AND EXISTS(SELECT 1 FROM @airlineCabinUniq WHERE airLegBrandName = N.airLegBrandName 
							AND isRefundable = resp.refundable AND gdsSourceKey = resp.gdsSourceKey AND airlineCode = N.airlineCode)
							UNION ALL
							SELECT 	gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable,N.airlineCode
							FROM #NormalizedAirResponsesMultiBrand N 
							INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
							INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
							WHERE airSubRequestLegIndex = 2 
							AND NOT EXISTS (select airresponsekey  from @tempResponseToRemove WHERE airresponsekey=N.airResponseKey) 
							AND EXISTS(SELECT 1 FROM @airlineCabinUniq WHERE airLegBrandName = N.airLegBrandName 
							AND isRefundable = resp.refundable AND gdsSourceKey = resp.gdsSourceKey AND airlineCode = N.airlineCode)
						) A
						
						
						MERGE #airlineFinal F
						USING (SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
						,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
						,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
						,airPriceTaxInfantWithSeat,airLegBrandName,refundable,airlineCode from #airlineFinal where refundable=1 and row_num=1 and lower(airLegBrandName) <>'basic' AND gdsSourceKey<>12) C
						ON (lower(f.airLegBrandName)=lower(c.airLegBrandName) and f.gdsSourceKey=2 and f.refundable=0 AND f.airlineCode = c.airlineCode and f.row_num=1)
						WHEN NOT MATCHED THEN
						INSERT  
						(row_num,gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren 
						,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal
						,airPriceBaseDisplay,airPriceTaxDisplay,airResponseKey,airPriceBaseInfantWithSeat
						,airPriceTaxInfantWithSeat,airLegBrandName,refundable,airlineCode) 
						VALUES
						(1,c.gdsSourceKey,c.airPriceBAse,c.airPriceTax,c.airPriceBaseSenior,c.airPriceTaxSenior,c.airPriceBaseChildren,c.airPriceTaxChildren 
						,c.airPriceBaseInfant,c.airPriceTaxInfant,c.airPriceBaseYouth ,c.airPriceTaxYouth ,c.AirPriceBaseTotal,c.AirPriceTaxTotal
						,c.airPriceBaseDisplay,c.airPriceTaxDisplay,c.airResponseKey,c.airPriceBaseInfantWithSeat
						,c.airPriceTaxInfantWithSeat,c.airLegBrandName,0,airlineCode);

						INSERT INTO @multiLegPrice (gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName, isRefundable, airlineCode)  
						SELECT gdsSourceKey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,airresponsekey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName,Refundable, airlineCode
						FROM #airlineFinal WHERE Row_Num=1 ORDER BY airpriceBase + airPriceTax ASC
				  END 
				END   
						
				SET @airPriceForAnotherLeg = ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 2 ),0)  
				SET @airPriceTaxForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceTax FROM @multiLegPrice where gdsSourceKey = 2 ) ,0)  
				SET @airPriceSeniorForAnotherLeg =  ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 2 ) ,0)  
				SET @airPriceTaxSeniorForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceChildrenForAnotherLeg =  ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceTaxChildrenForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceInfantForAnotherLeg =  ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceTaxInfantForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceYouthForAnotherLeg =  ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceTaxYouthForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 2 ),0) 
				SET @airPriceTotalForAnotherLeg =  ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceTaxTotalForAnotherLeg = ISNULL( (SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceDisplayForAnotherLeg = ISNULL( (SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceTaxDisplayForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 2 ),0) 
				SET @airPriceInfantWithSeatForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 2 )  ,0) 
				SET @airPriceTaxInfantWithSeatForAnotherLeg =  ISNULL((SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 2 ),0) 

				DECLARE @secondLegRequestKey  AS INT = (SELECT top 1 airsubrequestkey from #AirResponse R WITH(NOLOCK) Inner join @multiLegPrice M on R.airResponseKey = M.airresponsekey ) 
				DECLARE @SecondLegs_CTE  AS TABLE(noofairlines INT , airPrice DECIMAL (12,2), airlineName VARCHAR(40),#AirResponse UNIQUEIDENTIFIER)

				INSERT INTO @SecondLegs_CTE 	  
				SELECT COUNT(DISTINCT airSegmentMarketingAirlineCode) , (airPriceBaseDisplay + airPriceTaxDisplay  ),
				( CASE WHEN (COUNT(DISTINCT airSegmentMarketingAirlineCode))> 1 THEN 'Multiple' ELSE 
				MIN (airSegmentMarketingAirlineCode ) END ) ,seg.airResponseKey  From #AirSegments seg WITH (NOLOCK) INNER JOIN #AirResponse r WITH (NOLOCK)
				ON seg.airResponseKey = r.airResponseKey 
				WHERE AIRSUbrequestKEy = @secondLegRequestKey   
				AND Convert(DECIMAL (12,2),(airPriceBaseDisplay + airPriceTaxDisplay  )) = Convert (DECIMAL(12,2), (@airPriceTaxDisplayForAnotherLeg + @airPriceDisplayForAnotherLeg) )
				group by seg.airResponseKey ,airPriceBaseDisplay , airPriceTaxDisplay  ,seg.airResponseKey 

				SELECT @anotherLegAirlinesCount = noofairlines , @anotherLegAirlines = airlineName  from @SecondLegs_CTE where noofairlines = 1  
				IF ( @anotherLegAirlines IS NULL OR @anotherLegAirlines  = '' ) 
				BEGIN
					SELECT @anotherLegAirlinesCount =  COUNT(distinct airSegmentMarketingAirlineCode) , @anotherLegAirlines = ( CASE WHEN (COUNT(distinct airSegmentMarketingAirlineCode))> 1 THEN 'Multiple' ELSE 
					MIN (airSegmentMarketingAirlineCode ) END ) From #AirSegments seg WITH (NOLOCK)
					INNER JOIN #AirResponse r WITH (NOLOCK) on seg.airResponseKey = r.airResponseKey
					INNER JOIN @multiLegPrice V on r.airResponseKey = v.airResponsekey 
					GROUP BY seg.airResponseKey 
				END 

				
			END  
	ELSE   
	BEGIN  
		/**airLEg > 1 **/  
			DECLARE @SELECTedResponse as  table  
			(  
			legIndex int   identity ( 1,1) ,  
			responsekey uniqueidentifier ,  
			fareType varchar(100)  
			)  
			DECLARE @SELECTedResponseMultiBrand as  table  
			(  
			legIndex int   identity ( 1,1) ,  
			responseMultiBrandkey uniqueidentifier ,  
			fareType varchar(100)  
			) 
			IF   @SelectedResponseKey  IS NOT NULL AND @SelectedResponseKey <> '{00000000-0000-0000-0000-000000000000}'    
			BEGIN  
				IF (( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKey ) <> @airBundledRequest AND ( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKey ) <> @airMultiCabinBundledRequest)
				BEGIN
					INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKey ,@SELECTedFareType)

					If(@isMultiBrand = 1)  
						BEGIN
							IF (@isMultiBrandSelectedOnPreviousLeg = 1)
							BEGIN
								INSERT @upSellLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
								SELECT airpriceBase  ,    
								airPriceTax ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,
								 airPriceBaseDisplay  ,    
								airPriceTaxDisplay  ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
								FROM #AirResponseMultiBrand resp   WITH (NOLOCK)
								WHERE resp.airResponseMultiBrandKey = @SelectedResponseMultiBrandKey
							END
							-- Calculating Lowest Leg2 OW Fare which was used in Leg 1
							If (@isCabinUniquification=0)
							BEGIN
								IF ( @airLines = '' or @airLines = 'Multiple Airlines' )   
								BEGIN   
									select top 1 @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
									from #AirResponse  Resp WITH (NOLOCK)
									inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
									WHERE airSubRequestLegIndex = 2 and 
									ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
									and airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
									order by Resp. AirSubRequestkey , (airPriceBase + airPriceTax)asc 
									
								END   
								ELSE   
								BEGIN  
									select TOP 1 @legTwoLowestFare =   (airPriceBaseDisplay + airPriceTaxDisplay) 
									FROM #AirResponse resp  WITH (NOLOCK)  
									inner join #AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey = subReq.airSubRequestKey   
									inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
									inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
									WHERE airSubRequestLegIndex = 2  and  ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  and resp.airResponseKey not in ( select airresponsekey  
									from @tempResponseToRemove )   
									order by  (airPriceBase + airPriceTax)asc 
								END 
							END
							ELSE
							BEGIN
							IF (@isMultiBrandSelectedOnPreviousLeg = 1)
							BEGIN
							    SELECT @airLegBrandName = N.airLegBrandName, @IsREfundable = A.refundable, @SelectedGDSSourceKey = A.gdsSourceKey, @selectedAirline = N.airlineCode,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
							    FROM #AirResponseMultiBrand A 
							    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
							    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKey
							END
							ELSE
							BEGIN
								SELECT @airLegBrandName = N.airLegBrandName, @IsREfundable = A.refundable, @SelectedGDSSourceKey = A.gdsSourceKey, @selectedAirline = N.airlineCode,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
							    FROM #AirResponse A 
							    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
							    WHERE A.airResponseKey = @SelectedResponseKey
							END
							IF ( @airLines = '' OR (@airLines = 'Multiple Airlines' AND @isAirlineUniquification = 0))   
								BEGIN   
									IF (@SelectedGDSSourceKey = 12)
									BEGIN
										SELECT TOP 1  @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
										FROM
										(
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponses N 
										INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										WHERE airSubRequestLegIndex = 2 
										AND resp.gdsSourceKey = 12
										AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName
										UNION ALL
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponsesMultiBrand N 
										INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										WHERE airSubRequestLegIndex = 2  
										AND resp.gdsSourceKey = 12
										and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName ) A
										ORDER BY airpriceBase + airPriceTax ASC
									END
									ELSE IF (@SelectedGDSSourceKey = 19)
									BEGIN
										SELECT TOP 1  @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
										FROM
										(
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponses N 
										INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										WHERE airSubRequestLegIndex = 2 
										AND resp.gdsSourceKey = 19
										AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName
										UNION ALL
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponsesMultiBrand N 
										INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										WHERE airSubRequestLegIndex = 2  
										AND resp.gdsSourceKey = 19
										and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName ) A
										ORDER BY airpriceBase + airPriceTax ASC
									END
									ELSE
									BEGIN
											SELECT TOP 1 @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
											FROM
											(
											SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
											FROM #NormalizedAirResponses N 
											INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
											INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
											WHERE airSubRequestLegIndex = 2 
											AND resp.gdsSourceKey = 2
											AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
											AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName
											UNION ALL
											SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,refundable
											FROM #NormalizedAirResponsesMultiBrand N 
											INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
											INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
											WHERE airSubRequestLegIndex = 2  
											AND resp.gdsSourceKey = 2
											and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
											AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName ) A
											ORDER BY airpriceBase + airPriceTax ASC
											
											IF (@legTwoLowestFare=0 AND @IsREfundable=0)
											BEGIN
												SELECT TOP 1 @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
												FROM
												(
												SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
												FROM #NormalizedAirResponses N 
												INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
												INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
												WHERE airSubRequestLegIndex = 2 
												AND resp.gdsSourceKey = 2
												AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
												AND resp.refundable = 1 AND lower(N.airLegBrandName) = @airLegBrandName
												UNION ALL
												SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,refundable
												FROM #NormalizedAirResponsesMultiBrand N 
												INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
												INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
												WHERE airSubRequestLegIndex = 2  
												AND resp.gdsSourceKey = 2
												and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
												AND resp.refundable = 1 AND lower(N.airLegBrandName) = @airLegBrandName ) A
												ORDER BY airpriceBase + airPriceTax ASC
											END
									END   
								END
							ELSE   
								BEGIN  
								IF (@SelectedGDSSourceKey = 12)
									BEGIN
										SELECT TOP 1  @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
										FROM
										(
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponses N 
										INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										INNER JOIN #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
										INNER JOIN @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
										WHERE airSubRequestLegIndex = 2 
										AND resp.gdsSourceKey = 12
										AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName
										UNION ALL
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponsesMultiBrand N 
										INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										INNER JOIN #AirSegmentsMultiBrand SM ON SM.airResponseMultiBrandKey = resp.airResponseMultiBrandKey
										INNER JOIN #AirSegments seg on resp.airResponseKey = seg.airResponseKey    
										INNER JOIN @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
										WHERE airSubRequestLegIndex = 2  
										AND resp.gdsSourceKey = 12
										and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName ) A
										ORDER BY airpriceBase + airPriceTax ASC
									END
									ELSE IF (@SelectedGDSSourceKey = 19)
									BEGIN
										SELECT TOP 1  @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
										FROM
										(
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponses N 
										INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										INNER JOIN #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
										INNER JOIN @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
										WHERE airSubRequestLegIndex > 1 
										AND resp.gdsSourceKey = 19
										AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName
										UNION ALL
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
										FROM #NormalizedAirResponsesMultiBrand N 
										INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey  
										INNER JOIN #AirSegmentsMultiBrand SM ON SM.airResponseMultiBrandKey = resp.airResponseMultiBrandKey
										INNER JOIN #AirSegments seg on resp.airResponseKey = seg.airResponseKey    
										INNER JOIN @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
										WHERE airSubRequestLegIndex = 2  
										AND resp.gdsSourceKey = 19
										and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName ) A
										ORDER BY airpriceBase + airPriceTax ASC
									END
									ELSE
									BEGIN
										SELECT TOP 1 @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
										FROM
										(
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable, n.airlineCode
										FROM #NormalizedAirResponses N 
										INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey
										inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
										inner join @tmpAirline air on seg.airSegmentMarketingAirlineCode = air.airLineCode 
										WHERE airSubRequestLegIndex = 2 
										AND resp.gdsSourceKey = 2
										AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName
										AND n.airlineCode = @selectedAirline
										UNION ALL
										SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,refundable, n.airlineCode
										FROM #NormalizedAirResponsesMultiBrand N 
										INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
										INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey
										INNER JOIN #AirSegmentsMultiBrand SM ON SM.airResponseMultiBrandKey = resp.airResponseMultiBrandKey
										INNER JOIN #AirSegments seg on resp.airResponseKey = seg.airResponseKey    
										INNER JOIN @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
										WHERE airSubRequestLegIndex = 2  
										AND resp.gdsSourceKey = 2
										and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
										AND resp.refundable = @IsREfundable AND lower(N.airLegBrandName) = @airLegBrandName AND n.airlineCode = @selectedAirline) A
										ORDER BY airpriceBase + airPriceTax ASC
										
										IF (@legTwoLowestFare=0 AND @IsREfundable=0)
										BEGIN
											SELECT TOP 1 @legTwoLowestFare = (airPriceBaseDisplay + airPriceTaxDisplay )
											FROM
											(
											SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,resp.refundable
											FROM #NormalizedAirResponses N 
											INNER JOIN #AirResponse  resp  ON N.airresponsekey = resp.airResponseKey
											INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey
											inner join #AirSegments seg  WITH (NOLOCK)on resp.airResponseKey = seg.airResponseKey    
											inner join @tmpAirline air on seg.airSegmentMarketingAirlineCode = air.airLineCode   
											WHERE airSubRequestLegIndex = 2 
											AND resp.gdsSourceKey = 2
											AND N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
											AND resp.refundable = 1 AND lower(N.airLegBrandName) = @airLegBrandName AND N.airLineCode = @selectedAirline
											UNION ALL
											SELECT gdsSourceKey,airPriceBAse,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren ,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth ,airPriceTaxYouth ,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay        ,resp.airResponseKey,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,N.airLegBrandName,refundable
											FROM #NormalizedAirResponsesMultiBrand N 
											INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) ON N.airresponseMultiBrandkey = resp.airresponseMultiBrandKey
											INNER JOIN #AirSubRequest subReq WITH(NOLOCK) on N.airSubRequestKey = subReq.airSubRequestKey
											INNER JOIN #AirSegmentsMultiBrand SM ON SM.airResponseMultiBrandKey = resp.airResponseMultiBrandKey
											INNER JOIN #AirSegments seg on resp.airResponseKey = seg.airResponseKey    
											INNER JOIN @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
											WHERE airSubRequestLegIndex = 2  
											AND resp.gdsSourceKey = 2
											and N.airResponseKey not in ( select airresponsekey  from @tempResponseToRemove ) 
											AND resp.refundable = 1 AND lower(N.airLegBrandName) = @airLegBrandName AND N.airLineCode = @selectedAirline) A
											ORDER BY airpriceBase + airPriceTax ASC
										END
									--END
									END
								END 
							END
							IF (@isMultiBrandSelectedOnPreviousLeg = 1)
							BEGIN
								SELECT TOP 1 @selectedRoundTripFare = ((airPriceBaseDisplay + airPriceTaxDisplay) + @legTwoLowestFare) 
								FROM @upSellLegPrice
							END
							ELSE
							BEGIN
								SELECT TOP 1 @selectedRoundTripFare = ((airPriceBaseDisplay + airPriceTaxDisplay) + @legTwoLowestFare)				
								FROM #AirResponse resp   WITH (NOLOCK)
								WHERE resp.airResponseKey = @SelectedResponseKey
							END
						END	
				END  
				ELSE   
				BEGIN 
					IF(@isMultiBrand = 1)
					BEGIN
						IF((SELECT refundable FROM AirResponse where airResponseKey = @SelectedResponseKey) = 0)
						BEGIN
							INSERT @SELECTedResponse (responsekey,fareType)  
							(SELECT TOP 1  n.airresponsekey,@SELECTedFareType  FROM  #NormalizedAirResponses n WITH(NOLOCK)
							inner join #AirSubRequest r WITH(NOLOCK) on n.airsubrequestkey = r.airSubRequestKey 
							inner join #AirResponse AR WITH(NOLOCK) on n.airresponsekey = AR.airResponseKey
							 WHERE airlegnumber =1
							and  airSubRequestLegIndex = 1 and flightNumber =(SELECT flightnumber FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey  and airLegNumber =1 
							)  AND AIRLINES = (SELECT airlines FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey and airLegNumber =1 ) AND UPPER(airLegBrandName) = (SELECT UPPER(airLegBrandName) FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey and airLegNumber =1) AND N.airsubrequestkey <> @airBundledRequest AND N.airsubrequestkey <> @airMultiCabinBundledRequest ) 
							order by (airPriceBaseDisplay + airPriceTaxDisplay) asc
						END
						ELSE
						BEGIN
							INSERT @SELECTedResponse (responsekey,fareType)  
							(SELECT TOP 1  n.airresponsekey,@SELECTedFareType  FROM  #NormalizedAirResponses n WITH(NOLOCK)
							inner join #AirSubRequest r WITH(NOLOCK) on n.airsubrequestkey = r.airSubRequestKey 
							inner join #AirResponse AR WITH(NOLOCK) on n.airresponsekey = AR.airResponseKey
							 WHERE airlegnumber =1
							and  airSubRequestLegIndex = 1 and flightNumber =(SELECT flightnumber FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey  and airLegNumber =1 
							)  AND AIRLINES = (SELECT airlines FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey and airLegNumber =1 ) AND UPPER(airLegBrandName) = (SELECT UPPER(airLegBrandName) FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey and airLegNumber =1) AND N.airsubrequestkey <> @airBundledRequest AND N.airsubrequestkey <> @airMultiCabinBundledRequest
							AND AR.refundable = 1  ) 
							order by (airPriceBaseDisplay + airPriceTaxDisplay) asc
						END	
					END
					ELSE
					BEGIN
						INSERT @SELECTedResponse (responsekey,fareType)  
						(SELECT TOP 1  n.airresponsekey,@SELECTedFareType  FROM  #NormalizedAirResponses n WITH(NOLOCK)
						inner join #AirSubRequest r WITH(NOLOCK) on n.airsubrequestkey = r.airSubRequestKey 
						inner join #AirResponse AR WITH(NOLOCK) on n.airresponsekey = AR.airResponseKey
						 WHERE airlegnumber =1
						and  airSubRequestLegIndex = 1 and flightNumber =(SELECT flightnumber FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey  and airLegNumber =1 
						)  AND AIRLINES = (SELECT airlines FROM #NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey and airLegNumber =1 ) AND N.airsubrequestkey <> @airBundledRequest AND N.airsubrequestkey <> @airMultiCabinBundledRequest ) 
						order by (airPriceBaseDisplay + airPriceTaxDisplay) asc
					END
					
					If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg = 1)  
					BEGIN
					SELECT @selectedBrandName = airLegBrandName,@selectedFlightNumber = flightNumber,@selectedAirlines = airlines FROM #NormalizedAirResponsesMultiBrand WHERE airresponseMultiBrandkey = @SelectedResponseMultiBrandKey and airLegNumber =1
						--/****** Ashima: Getting Corresponding OW For Upsell Selected *******************/

						IF((SELECT refundable FROM AirResponseMultiBrand where airResponseMultiBrandKey = @SelectedResponseMultiBrandKey) = 0)
						BEGIN
							INSERT @SELECTedResponseMultiBrand (responseMultiBrandkey,fareType)
							(SELECT TOP 1 n.airResponseMultiBrandKey,@SELECTedFareType  FROM  #NormalizedAirResponsesMultiBrand n WITH(NOLOCK)
							inner join #AirSubRequest r WITH(NOLOCK) on n.airsubrequestkey = r.airSubRequestKey 
							inner join #AirResponseMultiBrand AR WITH(NOLOCK) on n.AirResponseMultiBrandKey = AR.airResponseMultiBrandKey
							 WHERE airlegnumber =1
							and  airSubRequestLegIndex = 1 and flightNumber = @selectedFlightNumber AND AIRLINES = @selectedAirlines
							AND airLegBrandName = @selectedBrandName
							AND N.airsubrequestkey <> @airBundledRequest AND N.airsubrequestkey <> @airMultiCabinBundledRequest)
							order by (airPriceBaseDisplay + airPriceTaxDisplay) asc
						END
						ELSE
						BEGIN
							INSERT @SELECTedResponseMultiBrand (responseMultiBrandkey,fareType)
							(SELECT TOP 1 n.airResponseMultiBrandKey,@SELECTedFareType  FROM  #NormalizedAirResponsesMultiBrand n WITH(NOLOCK)
							inner join #AirSubRequest r WITH(NOLOCK) on n.airsubrequestkey = r.airSubRequestKey 
							inner join #AirResponseMultiBrand AR WITH(NOLOCK) on n.airresponseMultiBrandkey = AR.airresponseMultiBrandkey
							 WHERE airlegnumber =1
							and  airSubRequestLegIndex = 1 and flightNumber = @selectedFlightNumber AND AIRLINES = @selectedAirlines
							AND airLegBrandName = @selectedBrandName
							AND N.airsubrequestkey <> @airBundledRequest AND N.airsubrequestkey <> @airMultiCabinBundledRequest AND AR.refundable = 1)
							order by (airPriceBaseDisplay + airPriceTaxDisplay) asc
						END
						
						IF NOT EXISTS(SELECT 1 FROM @SELECTedResponseMultiBrand)
						BEGIN
							IF((SELECT refundable FROM AirResponseMultiBrand where airResponseMultiBrandKey = @SelectedResponseMultiBrandKey) = 0)
							BEGIN
								INSERT @SELECTedResponseMultiBrand (responseMultiBrandkey,fareType)  
								(SELECT TOP 1  n.airresponsekey,@SELECTedFareType  FROM  #NormalizedAirResponses n WITH(NOLOCK)
								inner join #AirSubRequest r WITH(NOLOCK) on n.airsubrequestkey = r.airSubRequestKey 
								inner join #AirResponse AR WITH(NOLOCK) on n.airresponsekey = AR.airResponseKey
								 WHERE airlegnumber =1
								and  airSubRequestLegIndex = 1 and flightNumber = @selectedFlightNumber  AND AIRLINES = @selectedAirlines
								 AND UPPER(airLegBrandName) = @selectedBrandName
								 AND N.airsubrequestkey <> @airBundledRequest AND N.airsubrequestkey <> @airMultiCabinBundledRequest ) 
								order by (airPriceBaseDisplay + airPriceTaxDisplay) asc
							END
							ELSE
							BEGIN
								INSERT @SELECTedResponseMultiBrand (responseMultiBrandkey,fareType)  
								(SELECT TOP 1  n.airresponsekey,@SELECTedFareType  FROM  #NormalizedAirResponses n WITH(NOLOCK)
								inner join #AirSubRequest r WITH(NOLOCK) on n.airsubrequestkey = r.airSubRequestKey 
								inner join #AirResponse AR WITH(NOLOCK) on n.airresponsekey = AR.airResponseKey
								 WHERE airlegnumber =1
								and  airSubRequestLegIndex = 1 and flightNumber = @selectedFlightNumber  AND AIRLINES = @selectedAirlines
								 AND UPPER(airLegBrandName) = @selectedBrandName
								 AND N.airsubrequestkey <> @airBundledRequest AND N.airsubrequestkey <> @airMultiCabinBundledRequest
								AND AR.refundable = 1  ) 
								order by (airPriceBaseDisplay + airPriceTaxDisplay) asc
							END	
											
							INSERT @upSellLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
							SELECT airpriceBase  ,    
							airPriceTax ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,
							 airPriceBaseDisplay  ,    
							airPriceTaxDisplay  ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
							FROM #AirResponse resp   WITH (NOLOCK)
							inner join @SELECTedResponseMultiBrand SELECTed   
							on resp .airResponseKey = SELECTed.responseMultiBrandkey 

							IF EXISTS(SELECT 1 FROM @SELECTedResponseMultiBrand)
							BEGIN
								IF NOT EXISTS(SELECT 1 FROM @SELECTedResponse)
								BEGIN
									INSERT @SELECTedResponse (responsekey,fareType) 
									SELECT responseMultiBrandkey, fareType FROM @SELECTedResponseMultiBrand

								END
							END

						END
						ELSE
						BEGIN
							/****** Ashima: Setting Fare of Corresponsing OW *******************/
							INSERT @upSellLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
							SELECT airpriceBase  ,    
							airPriceTax ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,
							 airPriceBaseDisplay  ,    
							airPriceTaxDisplay  ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
							FROM #AirResponseMultiBrand resp   WITH (NOLOCK)
							inner join @SELECTedResponseMultiBrand SELECTed   
							on resp .airResponseMultiBrandKey = SELECTed.responseMultiBrandkey 

							IF EXISTS(SELECT 1 FROM @SELECTedResponseMultiBrand)
							BEGIN
								IF NOT EXISTS(SELECT 1 FROM @SELECTedResponse)
								BEGIN
									INSERT @SELECTedResponse (responsekey,fareType) 
									SELECT top 1 airResponseKey, SELECTED.fareType FROM #AirResponseMultiBrand AR With (NOLOCK)
									INNER JOIN @SELECTedResponseMultiBrand SELECTED ON SELECTED.responseMultiBrandkey = AR.airResponseMultiBrandKey
								END
							END
						END
						
						-- Getting RoundTrip Fare of RT Bundle which was shown on Leg 1 and which was selected also
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponseMultiBrand where airResponseMultiBrandKey = @SelectedResponseMultiBrandKey
						
						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName = N.airLegBrandName, @IsREfundable = A.refundable, @SelectedGDSSourceKey = A.gdsSourceKey,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKey and airLegNumber = 1
						END
						
					END
					ELSE
					BEGIN
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponse where airResponseKey = @SelectedResponseKey
						
						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName = N.airLegBrandName, @IsREfundable = A.refundable, @SelectedGDSSourceKey = A.gdsSourceKey,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKey and airLegNumber = 1
						END
					END
 				END   
				SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM #AirSegments WITH (NOLOCK)WHERE airResponseKey = @SELECTedResponseKey AND airLegNumber =(@airRequestTypeKey-1) )  
			END
			IF(@airRequestType = 3 AND @SelectedResponseKey  IS NOT NULL AND @SelectedResponseKey <> '{00000000-0000-0000-0000-000000000000}' AND @airRequestTypeKey > 2)
			BEGIN
				IF @SELECTedResponseKeyFifth is null or @SELECTedResponseKeyFifth ='{00000000-0000-0000-0000-000000000000}'    
				BEGIN  
					SET  @SelectedResponseKeyFifth  = @SELECTedResponseKey   
				END   
				IF @SELECTedResponseKeyFourth is null or @SELECTedResponseKeyFourth ='{00000000-0000-0000-0000-000000000000}'    
				BEGIN  
					SET  @SELECTedResponseKeyFourth = @SELECTedResponseKey   
				END  
				IF @SELECTedResponseKeyThird is null or @SELECTedResponseKeyThird ='{00000000-0000-0000-0000-000000000000}'    
				BEGIN  
					SET  @SELECTedResponseKeyThird = @SELECTedResponseKey   
				END   
				IF @SELECTedResponseKeySecond is null or @SELECTedResponseKeySecond ='{00000000-0000-0000-0000-000000000000}'    
				BEGIN  
					SET  @SELECTedResponseKeySecond = @SELECTedResponseKey   
				END  
			END
  
			IF  @airRequestTypeKey = 3 AND @SELECTedResponseKeySecond IS NOT NULL AND @SELECTedResponseKeySecond <> '{00000000-0000-0000-0000-000000000000}'    
			BEGIN  
			    IF (( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeySecond ) <> @airBundledRequest AND ( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeySecond ) <> @airMultiCabinBundledRequest)
				BEGIN   
					INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKeySecond ,@SELECTedFareType)  
				END   
				ELSE   
				BEGIN
					If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Second = 1)  
					BEGIN
						-- Getting RoundTrip Fare of RT Bundle which was shown on Leg 1 and which was selected also
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponseMultiBrand where airResponseMultiBrandKey = @SelectedResponseMultiBrandKeySecond

						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Second = N.airLegBrandName, @SelectedGDSSourceKey = A.gdsSourceKey, @airLegBrandName_CurrentLeg= N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeySecond and airLegNumber = 2
							-- ReSetting 
							SELECT @airLegBrandName = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeySecond and airLegNumber = 1
						END
						
					END
					ELSE
					BEGIN
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponse where airResponseKey = @SelectedResponseKeySecond
						
						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Second = N.airLegBrandName ,@SelectedGDSSourceKey = A.gdsSourceKey,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeySecond and airLegNumber = 2

							SELECT @airLegBrandName = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeySecond and airLegNumber = 1
						END
					END

				END   
				SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM #AirSegments  WITH (NOLOCK) WHERE airResponseKey = @SELECTedResponseKeySecond AND airLegNumber =(@airRequestTypeKey-1) )  
			END   
 
			IF  @airRequestTypeKey = 4 AND @SELECTedResponseKeyThird  is not null and @SELECTedResponseKeyThird <> '{00000000-0000-0000-0000-000000000000}'    
			BEGIN  
			    IF (( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeyThird ) <> @airBundledRequest AND ( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeyThird ) <> @airMultiCabinBundledRequest)
				BEGIN   
					INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKeyThird ,@SELECTedFareType)  
				END   
				ELSE   
				BEGIN 
					If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Third = 1)  
					BEGIN
						-- Getting RoundTrip Fare of RT Bundle which was shown on Leg 1 and which was selected also
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponseMultiBrand where airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyThird
						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Third = N.airLegBrandName,@SelectedGDSSourceKey = A.gdsSourceKey, @airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyThird and airLegNumber = 3

							SELECT @airLegBrandName_Second = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyThird and airLegNumber = 2

							SELECT @airLegBrandName= N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyThird and airLegNumber = 1
						END
						
					END
					ELSE
					BEGIN
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponse where airResponseKey = @SelectedResponseKeyThird
						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Third = N.airLegBrandName, @SelectedGDSSourceKey = A.gdsSourceKey,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyThird and airLegNumber = 3

							SELECT @airLegBrandName_Second = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyThird and airLegNumber = 2

							SELECT @airLegBrandName = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyThird and airLegNumber = 1
						END
					END

					-- Commenting it as the selected would have proper combination
					--If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Second = 1)  
					--BEGIN
					--	IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Second = N.airLegBrandName
					--	    FROM #AirResponseMultiBrand A 
					--	    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
					--	    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeySecond and airLegNumber = 2
					--	END
					--END
					--ELSE
					--BEGIN
					--IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Second = N.airLegBrandName
					--	    FROM #AirResponse A 
					--	    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
					--	    WHERE A.airResponseKey = @SelectedResponseKeySecond and airLegNumber = 2
					--	END
					--END

				END   
				SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM #AirSegments  WITH (NOLOCK) WHERE airResponseKey = @SELECTedResponseKeyThird AND airLegNumber =(@airRequestTypeKey-1) )  
			END     
			
			IF @airRequestTypeKey = 5 AND @SELECTedResponseKeyFourth is not null and @SELECTedResponseKeyFourth  <> '{00000000-0000-0000-0000-000000000000}'    
			BEGIN  
		    IF (( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeyFourth ) <> @airBundledRequest AND ( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeyFourth ) <> @airMultiCabinBundledRequest)
				BEGIN   
					INSERT @SELECTedResponse (responsekey,fareType  ) values (@SelectedResponseKeyFourth ,@SELECTedFareType)  
				END   
				ELSE   
				BEGIN 

					If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Fourth = 1)  
					BEGIN
						-- Getting RoundTrip Fare of RT Bundle which was shown on Leg 1 and which was selected also
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponseMultiBrand where airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFourth

						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Fourth = N.airLegBrandName, @SelectedGDSSourceKey = A.gdsSourceKey,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFourth and airLegNumber = 4

							SELECT @airLegBrandName_Third = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFourth and airLegNumber = 3

							SELECT @airLegBrandName_Second = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFourth and airLegNumber = 2

							SELECT @airLegBrandName = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFourth and airLegNumber = 1
						END		
					END
					ELSE
					BEGIN
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponse where airResponseKey = @SelectedResponseKeyFourth

						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Fourth = N.airLegBrandName,@SelectedGDSSourceKey = A.gdsSourceKey, @airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFourth and airLegNumber = 4

							SELECT @airLegBrandName_Third = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFourth and airLegNumber = 3

							SELECT @airLegBrandName_Second = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFourth and airLegNumber = 2

							SELECT @airLegBrandName = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFourth and airLegNumber = 1
						END
					END

					-- Commenting it as the selected would have proper combination
					--If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Second = 1)  
					--BEGIN
					--	IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Second = N.airLegBrandName
					--	    FROM #AirResponseMultiBrand A 
					--	    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
					--	    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeySecond and airLegNumber = 2
					--	END
					--END
					--ELSE
					--BEGIN
					--IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Second = N.airLegBrandName
					--	    FROM #AirResponse A 
					--	    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
					--	    WHERE A.airResponseKey = @SelectedResponseKeySecond and airLegNumber = 2
					--	END
					--END

					-- Commenting it as the selected would have proper combination
					--If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Third = 1)  
					--BEGIN
					--	IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Third = N.airLegBrandName
					--	    FROM #AirResponseMultiBrand A 
					--	    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
					--	    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyThird and airLegNumber = 3
					--	END
					--END
					--ELSE
					--BEGIN
					--IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Third = N.airLegBrandName
					--	    FROM #AirResponse A 
					--	    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
					--	    WHERE A.airResponseKey = @SelectedResponseKeyThird and airLegNumber = 3
					--	END
					--END

				END   
				SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM #AirSegments  WITH (NOLOCK) WHERE airResponseKey = @SELECTedResponseKeyFourth AND airLegNumber =(@airRequestTypeKey-1) )  
			END   
 			
			IF  @airRequestTypeKey = 6  AND @SELECTedResponseKeyFifth is not null and @SELECTedResponseKeyFifth  <> '{00000000-0000-0000-0000-000000000000}'    
			BEGIN  
				IF (( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeyFifth ) <> @airBundledRequest AND ( SELECT AirSubRequestKey FROM AirResponse WITH(NOLOCK) WHERE  airResponseKey = @SELECTedResponseKeyFifth ) <> @airMultiCabinBundledRequest)
				BEGIN   
					INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKeyFifth ,@SELECTedFareType)  
				END   
				ELSE   
				BEGIN 
					If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Fifth = 1)  
					BEGIN
						-- Getting RoundTrip Fare of RT Bundle which was shown on Leg 1 and which was selected also
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponseMultiBrand where airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFifth
					
						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Fifth = N.airLegBrandName, @SelectedGDSSourceKey = A.gdsSourceKey,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFifth and airLegNumber = 5

							SELECT @airLegBrandName_Fourth = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFifth and airLegNumber = 4

							SELECT @airLegBrandName_Third = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFifth and airLegNumber = 3

							SELECT @airLegBrandName_Second = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFifth and airLegNumber = 2

							SELECT @airLegBrandName = N.airLegBrandName
						    FROM #AirResponseMultiBrand A 
						    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
						    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFifth and airLegNumber = 1
						END
						
					END
					ELSE
					BEGIN
						SELECT TOP 1 @selectedRoundTripFare = (airPriceBaseDisplay + airPriceTaxDisplay) 
						FROM #AirResponse where airResponseKey = @SelectedResponseKeyFifth						
						
						IF(@isCabinUniquification = 1)
						BEGIN
						    SELECT @airLegBrandName_Fifth = N.airLegBrandName, @SelectedGDSSourceKey = A.gdsSourceKey,@airLegBrandName_CurrentLeg = N.airLegBrandName,@IsREfundable_CurrentLeg = A.refundable
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFifth and airLegNumber = 5

							SELECT @airLegBrandName_Fourth = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFifth and airLegNumber = 4

							SELECT @airLegBrandName_Third = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFifth and airLegNumber = 3

							SELECT @airLegBrandName_Second = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFifth and airLegNumber = 2

							SELECT @airLegBrandName = N.airLegBrandName
						    FROM #AirResponse A 
						    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
						    WHERE A.airResponseKey = @SelectedResponseKeyFifth and airLegNumber = 1

						END
					END
					-- Commenting it as the selected would have proper combination
					--If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Second = 1)  
					--BEGIN
					--	IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Second = N.airLegBrandName
					--	    FROM #AirResponseMultiBrand A 
					--	    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
					--	    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeySecond and airLegNumber = 2
					--	END
					--END
					--ELSE
					--BEGIN
					--IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Second = N.airLegBrandName
					--	    FROM #AirResponse A 
					--	    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
					--	    WHERE A.airResponseKey = @SelectedResponseKeySecond and airLegNumber = 2
					--	END
					--END

					-- Commenting it as the selected would have proper combination
					--If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Third = 1)  
					--BEGIN
					--	IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Third = N.airLegBrandName
					--	    FROM #AirResponseMultiBrand A 
					--	    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
					--	    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyThird and airLegNumber = 3
					--	END
					--END
					--ELSE
					--BEGIN
					--IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Third = N.airLegBrandName
					--	    FROM #AirResponse A 
					--	    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
					--	    WHERE A.airResponseKey = @SelectedResponseKeyThird and airLegNumber = 3
					--	END
					--END
					-- Commenting it as the selected would have proper combination
					--If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg_Fourth = 1)  
					--BEGIN
					--	IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Fourth = N.airLegBrandName
					--	    FROM #AirResponseMultiBrand A 
					--	    INNER JOIN #NormalizedAirResponsesMultiBrand N ON A.airResponseMultiBrandKey = N.airResponseMultiBrandKey
					--	    WHERE A.airResponseMultiBrandKey = @SelectedResponseMultiBrandKeyFourth and airLegNumber = 4
					--	END
					--END
					--ELSE
					--BEGIN
					--IF(@isCabinUniquification = 1)
					--	BEGIN
					--	    SELECT @airLegBrandName_Fourth = N.airLegBrandName
					--	    FROM #AirResponse A 
					--	    INNER JOIN #NormalizedAirResponses N ON A.airResponseKey = N.airResponseKey
					--	    WHERE A.airResponseKey = @SelectedResponseKeyFourth and airLegNumber = 4
					--	END
					--END

				END   
				SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM #AirSegments  WITH (NOLOCK) WHERE airResponseKey = @SELECTedResponseKeyFifth AND airLegNumber =(@airRequestTypeKey-1) )  
			END  			 

			DECLARE @SELECTedFareTypeTable as table (  
			fareLegIndex int identity (1,1),  
			fareType varchar(20)  
			)  
			INSERT @SELECTedFareTypeTable ( fareType )(SELECT * FROM vault.dbo.ufn_CSVToTable ( @SELECTedFareType ) )  

			UPDATE @SELECTedResponse SET fareType = fare.fareType FROM @SELECTedResponse sResponse  INNER JOIN 
			@SELECTedFareTypeTable fare on sResponse .legIndex =fare.fareLegIndex   

			IF ( @airLines = '' OR (@airLines = 'Multiple Airlines' AND @isCabinUniquification=0))   
			BEGIN   
				If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg = 1)  
				BEGIN 
					IF EXISTS(SELECT 1 FROM @upSellLegPrice)
					BEGIN
						INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
						SELECT    ( MIN(airPriceBase  )), (SELECT MIN ( airpriceTax) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse)),
						( MIN(airPriceBaseSenior  )), (SELECT MIN ( airpriceTaxSenior) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseSenior =  MIN(resp.airPriceBaseSenior)),
						( MIN(airPriceBaseChildren  )), (SELECT MIN ( airpriceTaxChildren)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseChildren =  MIN(resp.airpriceBaseChildren)) ,
						( MIN(airPriceBaseInfant  )), (SELECT MIN ( airpriceTaxInfant)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfant =  MIN(resp.airPriceBAseInfant ) ) ,
						( MIN(airPriceBaseYouth  )), (SELECT MIN ( airpriceTaxYouth)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseYouth =  MIN(resp.airPriceBAseyouth ) ) ,
						( MIN(AirPriceBaseTotal  )), (SELECT MIN ( AirPriceTaxTotal) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and AirPriceBaseTotal =  MIN(resp.AirPriceBaseTotal ) ),
						( MIN(airPriceBaseDisplay  )), (SELECT MIN ( airpriceTaxDisplay) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseDisplay =  MIN(resp.airpriceBaseDisplay ) ),
						( MIN(airPriceBaseInfantWithSeat  )), (SELECT MIN ( airpriceTaxInfantWithSeat)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfantWithSeat =  MIN(resp.airPriceBaseInfantWithSeat ) ) 
						FROM #AirResponse resp    WITH (NOLOCK)
						inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey  
						WHERE airSubRequestLegIndex > @airRequestTypeKey  
						and     ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
						GROUP BY resp.airSubRequestKey   
						UNION ALL   
						SELECT  ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverPrice   
						WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverPrice   
						WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexPrice   
						WHEN SELECTed.fareType =   'Corporate' THEN   airCorporatePrice    
						WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexPrice    
						WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradePrice   
						ELSE airpriceBase END   
						) ,airpriceBase)as airpriceBase  ,  

						ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverTax    
						WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverTax   
						WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexTax   
						WHEN SELECTed.fareType =   'Corporate' THEN   airCorporateTax    
						WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexTax   
						WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradetax   
						ELSE airPriceTax END   
						) ,airPriceTax)as   
						airPriceTax ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,

						ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverPrice   
						WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverPrice   
						WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexPrice   
						WHEN SELECTed.fareType =   'Corporate' THEN   airCorporatePrice    
						WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexPrice    
						WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradePrice   
						ELSE airpriceBase END   
						) ,airpriceBase)as airPriceBaseDisplay  ,  

						ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverTax    
						WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverTax   
						WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexTax   
						WHEN SELECTed.fareType =   'Corporate' THEN   airCorporateTax    
						WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexTax   
						WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradetax   
						ELSE airPriceTax END   
						) ,airPriceTax)as   
						airPriceTaxDisplay  ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
						FROM #AirResponse resp   WITH (NOLOCK)
						inner join @SELECTedResponse SELECTed   
						on resp .airResponseKey = SELECTed .responsekey   

						UPDATE @multiLegPrice
						SET airPriceBase = NM.airPriceBase,
						airPriceTax  = NM.airPriceTax,airPriceBaseSenior = NM.airPriceBaseSenior,
						airPriceTaxSenior = NM.airPriceTaxSenior,airPriceBaseChildren = NM.airPriceBaseChildren,airPriceTaxChildren = NM.airPriceTaxChildren,
						airPriceBaseInfant = NM.airPriceBaseInfant,airPriceTaxInfant = NM.airPriceTaxInfant,airPriceBaseYouth = NM.airPriceBaseYouth,
						airPriceTaxYouth = NM.airPriceTaxYouth,AirPriceBaseTotal = NM.airPriceBaseTotal,AirPriceTaxTotal = NM.airPriceTaxTotal ,
						airPriceBaseDisplay = NM.airPriceBaseDisplay,airPriceTaxDisplay = NM.airPriceTaxDisplay,airPriceBaseInfantWithSeat = NM.airPriceBaseInfantWithSeat,
						airPriceTaxInfantWithSeat = NM.airPriceTaxInfantWithSeat
						FROM @upSellLegPrice NM

					END
				END
				ELSE
				BEGIN 
					INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
					SELECT    ( MIN(airPriceBase  )), (SELECT MIN ( airpriceTax) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse)),
					( MIN(airPriceBaseSenior  )), (SELECT MIN ( airpriceTaxSenior) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseSenior =  MIN(resp.airPriceBaseSenior)),
					( MIN(airPriceBaseChildren  )), (SELECT MIN ( airpriceTaxChildren)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseChildren =  MIN(resp.airpriceBaseChildren)) ,
					( MIN(airPriceBaseInfant  )), (SELECT MIN ( airpriceTaxInfant)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfant =  MIN(resp.airPriceBAseInfant ) ) ,
					( MIN(airPriceBaseYouth  )), (SELECT MIN ( airpriceTaxYouth)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseYouth =  MIN(resp.airPriceBAseyouth ) ) ,
					( MIN(AirPriceBaseTotal  )), (SELECT MIN ( AirPriceTaxTotal) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and AirPriceBaseTotal =  MIN(resp.AirPriceBaseTotal ) ),
					( MIN(airPriceBaseDisplay  )), (SELECT MIN ( airpriceTaxDisplay) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseDisplay =  MIN(resp.airpriceBaseDisplay ) ),
					( MIN(airPriceBaseInfantWithSeat  )), (SELECT MIN ( airpriceTaxInfantWithSeat)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfantWithSeat =  MIN(resp.airPriceBaseInfantWithSeat ) ) 
					FROM #AirResponse resp    WITH (NOLOCK)
					inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey  
					WHERE airSubRequestLegIndex > @airRequestTypeKey  
					and     ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
					GROUP BY resp.airSubRequestKey   
					UNION ALL   
					SELECT  ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverPrice   
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverPrice   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexPrice   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporatePrice    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexPrice    
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradePrice   
					ELSE airpriceBase END   
					) ,airpriceBase)as airpriceBase  ,  

					ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverTax    
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverTax   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexTax   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporateTax    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexTax   
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradetax   
					ELSE airPriceTax END   
					) ,airPriceTax)as   
					airPriceTax ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,

					ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverPrice   
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverPrice   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexPrice   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporatePrice    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexPrice    
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradePrice   
					ELSE airpriceBase END   
					) ,airpriceBase)as airPriceBaseDisplay  ,  

					ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverTax    
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverTax   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexTax   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporateTax    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexTax   
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradetax   
					ELSE airPriceTax END   
					) ,airPriceTax)as   
					airPriceTaxDisplay  ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
					FROM #AirResponse resp   WITH (NOLOCK)
					inner join @SELECTedResponse SELECTed   
					on resp .airResponseKey = SELECTed .responsekey   
				END
			END   
			ELSE   
			BEGIN  
				If(@isMultiBrand = 1 AND @isMultiBrandSelectedOnPreviousLeg = 1)  
				BEGIN
					INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
					SELECT    ( MIN(airPriceBase  )), (SELECT MIN ( airpriceTax) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse)),
					( MIN(airPriceBaseSenior  )), (SELECT MIN ( airpriceTaxSenior) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseSenior =  MIN(resp.airPriceBaseSenior)),
					( MIN(airPriceBaseChildren  )), (SELECT MIN ( airpriceTaxChildren)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseChildren =  MIN(resp.airpriceBaseChildren)) ,
					( MIN(airPriceBaseInfant  )), (SELECT MIN ( airpriceTaxInfant)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfant =  MIN(resp.airPriceBAseInfant ) ) ,
					( MIN(airPriceBaseYouth  )), (SELECT MIN ( airpriceTaxYouth)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseYouth =  MIN(resp.airPriceBAseyouth ) ) ,
					( MIN(AirPriceBaseTotal  )), (SELECT MIN ( AirPriceTaxTotal) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and AirPriceBaseTotal =  MIN(resp.AirPriceBaseTotal ) ),
					( MIN(airPriceBaseDisplay  )), (SELECT MIN ( airpriceTaxDisplay) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseDisplay =  MIN(resp.airpriceBaseDisplay ) ),
					( MIN(airPriceBaseInfantWithSeat  )), (SELECT MIN ( airpriceTaxInfantWithSeat)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfantWithSeat =  MIN(resp.airPriceBAseInfantWithSeat ) ) 
					FROM #AirResponse resp    WITH (NOLOCK)
					inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
					inner join #AirSegments seg WITH(NOLOCK) on resp.airResponseKey = seg.airResponseKey    
					WHERE airSubRequestLegIndex > @airRequestTypeKey and seg.airSegmentMarketingAirlineCode =@airLines   
					and  
					ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
					group by resp.airSubRequestKey  ,seg.airSegmentMarketingAirlineCode    
					union ALL   
					SELECT  ISNULL( (case WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverPrice   
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverPrice   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexPrice   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporatePrice    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexPrice    
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradePrice   
					ELSE airpriceBase  END ) ,airpriceBase)as airpriceBase  ,  
					ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverTax    
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverTax   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexTax   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporateTax    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexTax   
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradetax   
					ELSE airPriceTax END   
					) ,airPriceTax)as   
					airPriceTax   ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
					FROM #AirResponse resp  WITH(NOLOCK)
					inner join @SELECTedResponse SELECTed   
					on resp .airResponseKey = SELECTed .responsekey

					UPDATE @multiLegPrice
					SET airPriceBase = NM.airPriceBase,
					airPriceTax  = NM.airPriceTax,airPriceBaseSenior = NM.airPriceBaseSenior,
					airPriceTaxSenior = NM.airPriceTaxSenior,airPriceBaseChildren = NM.airPriceBaseChildren,airPriceTaxChildren = NM.airPriceTaxChildren,
					airPriceBaseInfant = NM.airPriceBaseInfant,airPriceTaxInfant = NM.airPriceTaxInfant,airPriceBaseYouth = NM.airPriceBaseYouth,
					airPriceTaxYouth = NM.airPriceTaxYouth,AirPriceBaseTotal = NM.airPriceBaseTotal,AirPriceTaxTotal = NM.airPriceTaxTotal ,
					airPriceBaseDisplay = NM.airPriceBaseDisplay,airPriceTaxDisplay = NM.airPriceTaxDisplay,airPriceBaseInfantWithSeat = NM.airPriceBaseInfantWithSeat,
					airPriceTaxInfantWithSeat = NM.airPriceTaxInfantWithSeat
					FROM @upSellLegPrice NM 
				END
				ELSE
				BEGIN
					INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
					SELECT    ( MIN(airPriceBase  )), (SELECT MIN ( airpriceTax) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse)),
					( MIN(airPriceBaseSenior  )), (SELECT MIN ( airpriceTaxSenior) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseSenior =  MIN(resp.airPriceBaseSenior)),
					( MIN(airPriceBaseChildren  )), (SELECT MIN ( airpriceTaxChildren)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseChildren =  MIN(resp.airpriceBaseChildren)) ,
					( MIN(airPriceBaseInfant  )), (SELECT MIN ( airpriceTaxInfant)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfant =  MIN(resp.airPriceBAseInfant ) ) ,
					( MIN(airPriceBaseYouth  )), (SELECT MIN ( airpriceTaxYouth)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseYouth =  MIN(resp.airPriceBAseyouth ) ) ,
					( MIN(AirPriceBaseTotal  )), (SELECT MIN ( AirPriceTaxTotal) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and AirPriceBaseTotal =  MIN(resp.AirPriceBaseTotal ) ),
					( MIN(airPriceBaseDisplay  )), (SELECT MIN ( airpriceTaxDisplay) FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseDisplay =  MIN(resp.airpriceBaseDisplay ) ),
					( MIN(airPriceBaseInfantWithSeat  )), (SELECT MIN ( airpriceTaxInfantWithSeat)FROM #AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfantWithSeat =  MIN(resp.airPriceBAseInfantWithSeat ) ) 
					FROM #AirResponse resp    WITH (NOLOCK)
					inner join #AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey = subReq.airSubRequestKey   
					inner join #AirSegments seg WITH(NOLOCK) on resp.airResponseKey = seg.airResponseKey    
					WHERE airSubRequestLegIndex > @airRequestTypeKey and seg.airSegmentMarketingAirlineCode =@airLines   
					and  
					ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
					group by resp.airSubRequestKey  ,seg.airSegmentMarketingAirlineCode    
					union ALL   
					SELECT  ISNULL( (case WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverPrice   
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverPrice   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexPrice   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporatePrice    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexPrice    
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradePrice   
					ELSE airpriceBase  END ) ,airpriceBase)as airpriceBase  ,  
					ISNULL( (CASE WHEN  SELECTed.fareType =   'Super Saver' THEN   airSuperSaverTax    
					WHEN SELECTed.fareType =   'Econ Saver' THEN   airEconSaverTax   
					WHEN SELECTed.fareType =   'First Flex' THEN   airFirstFlexTax   
					WHEN SELECTed.fareType =   'Corporate' THEN   airCorporateTax    
					WHEN SELECTed.fareType =   'Econ Flex' THEN   airEconFlexTax   
					WHEN SELECTed.fareType =  'Instant Upgrade' THEN   airEconUpgradetax   
					ELSE airPriceTax END   
					) ,airPriceTax)as   
					airPriceTax   ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
					FROM #AirResponse resp  WITH(NOLOCK)
					inner join @SELECTedResponse SELECTed   
					on resp .airResponseKey = SELECTed .responsekey
					END			
			END
			
			SET @airPriceForAnotherLeg = (SELECT SUM(Airpricebase) FROM @multiLegPrice )  
			SET @airPriceTaxForAnotherLeg = ( SELECT SUM(airpriceTax ) FROM @multiLegPrice )  
			SET @airPriceSeniorForAnotherLeg = (SELECT SUM(AirpricebaseSenior) FROM @multiLegPrice )  
			SET @airPriceTaxSeniorForAnotherLeg = (SELECT SUM(airPriceTaxSenior) FROM @multiLegPrice )  
			SET @airPriceChildrenForAnotherLeg = (SELECT SUM(AirpricebaseChildren) FROM @multiLegPrice )  
			SET @airPriceTaxChildrenForAnotherLeg = (SELECT SUM(airPriceTaxChildren) FROM @multiLegPrice )  
			SET @airPriceInfantForAnotherLeg = (SELECT SUM(AirpricebaseInfant) FROM @multiLegPrice )  
			SET @airPriceTaxInfantForAnotherLeg = (SELECT SUM(airPriceTaxInfant) FROM @multiLegPrice )  
			SET @airPriceYouthForAnotherLeg = (SELECT SUM(AirpricebaseYouth) FROM @multiLegPrice )  
			SET @airPriceTaxYouthForAnotherLeg = (SELECT SUM(airPriceTaxYouth) FROM @multiLegPrice )  
			SET @airPriceTotalForAnotherLeg = (SELECT SUM(AirPriceBaseTotal) FROM @multiLegPrice )  
			SET @airPriceTaxTotalForAnotherLeg = (SELECT SUM(AirPriceTaxTotal) FROM @multiLegPrice )  
			SET @airPriceDisplayForAnotherLeg = (SELECT SUM(AirpricebaseDisplay) FROM @multiLegPrice )  
			SET @airPriceTaxDisplayForAnotherLeg = (SELECT SUM(airPriceTaxDisplay) FROM @multiLegPrice )   
			SET @airPriceInfantWithSeatForAnotherLeg = (SELECT SUM(airPriceBaseInfantWithSeat) FROM @multiLegPrice )  
			SET @airPriceTaxInfantWithSeatForAnotherLeg = (SELECT SUM(airPriceTaxInfantWithSeat) FROM @multiLegPrice )

			select @anotherLegAirlinesCount = COUNT(distinct airSegmentMarketingAirlineCode) , 
			@anotherLegAirlines = ( CASE WHEN (COUNT(distinct airSegmentMarketingAirlineCode))> 1 then 'Multiple' else 
			MIN (airSegmentMarketingAirlineCode ) END ) From #AirSegments seg  WITH (NOLOCK)
			where airresponsekey = @SelectedResponseKey 
			group by seg.airResponseKey 
	END   


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
	airPrice float ,  
	airPriceTax float ,  
	airPriceBaseSenior float,
	airPriceTaxSenior float,
	airPriceBaseChildren float,
	airPriceTaxChildren float,
	airPriceBaseInfant float,
	airPriceTaxInfant float,
	airPriceBaseYouth float,
	airPriceTaxYouth float,
	AirPriceBaseTotal float,
	AirPriceTaxTotal float,
	airPriceBaseDisplay float,
	airPriceTaxDisplay float,
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
	priceClassCommentsSuperSaver varchar(500),  
	priceClassCommentsEconSaver varchar(500),  
	priceClassCommentsFirstFlex varchar(500),  
	priceClassCommentsCorporate varchar(500),  
	priceClassCommentsEconFlex varchar(500),  
	priceClassCommentsEconUpgrade varchar(500),        
	airSuperSaverPrice float ,  
	airEconSaverPrice float ,  
	airFirstFlexPrice  float ,  
	airCorporatePrice  float ,  
	airEconFlexPrice float       ,  
	airEconUpgradePrice float ,  
	airClassSuperSaver   varchar (50) NULL,  
	airClassEconSaver    varchar (50) NULL,  
	airClassFirstFlex    varchar (50) NULL,  
	airClassCorporate    varchar (50) NULL,  
	airClassEconFlex    varchar (50) NULL,  
	airClassEconUpgrade   varchar (50) NULL,  
	airSuperSaverSeatRemaining   int  NULL,  
	airEconSaverSeatRemaining   int  NULL,  
	airFirstFlexSeatRemaining   int  NULL,  
	airCorporateSeatRemaining   int  NULL,  
	airEconFlexSeatRemaining   int  NULL,  
	airEconUpgradeSeatRemaining   int  NULL,  
	airSuperSaverFareReferenceKey   varchar (50) NULL,  
	airEconSaverFareReferenceKey   varchar (50) NULL,  
	airFirstFlexFareReferenceKey   varchar (50) NULL,  
	airCorporateFareReferenceKey   varchar (50) NULL,  
	airEconFlexFareReferenceKey   varchar (50) NULL,  
	airEconUpgradeFareReferenceKey   varchar (50) NULL,  
	airPriceClassSELECTed   varchar (50) NULL ,  
	otherLegPrice float ,  
	isRefundable bit ,  
	isBrandedFare bit ,  
	cabinClass varchar(50),  
	fareType varchar(20),segmentOrder int ,  
	airsegmentCabin varchar (20),  
	totalCost float ,
	airSegmentOperatingFlightNumber int,
	otherlegtax float,
	airSegmentOperatingAirlineCompanyShortName VARCHAR(100) ,
	otherlegAirlines varchar(100) ,
	noOfOtherlegairlines int ,
	airRowNum int identity (1,1) ,
	legDuration int ,
	legConnections Varchar(100),actualNoOFStops INT ,
	isSameAirlinesItin bit,
	isLowestJourneyTime bit default 0, 
    airSuperSaverTax float ,  
	airEconSaverTax float ,  
	airFirstFlexTax  float ,  
	airCorporateTax  float ,  
	airEconFlexTax float   ,  
	airEconUpgradeTax float ,
	airPriceBaseInfantWithSeat float,
	airPriceTaxInfantWithSeat float,
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airsegmentPricingKey nvarchar(50),
	airSegmentFareCategory nvarchar(50),
	airLegBrandName nvarchar(200),
	airSegmentBrandName nvarchar(200),
	airSegmentBrandID nvarchar(200),
	airSegmentBaggage nvarchar(200),
	airSegmentMealCode nvarchar(200),
	multiBrandFaresInfo xml Null,
	airResponseMultiBrandkey uniqueidentifier null,
	ReasonCode NVARCHAR(10) DEFAULT 'NONE',
	ProgramCode NVARCHAR(10),
	IsSuppressed BIT DEFAULT 0,
	IsSuppressAirline BIT DEFAULT 0
	)  
	CREATE NONCLUSTERED INDEX [IDX_airlineName_airResponse_airPrice] ON #airResponseResultset ([airlineName])
		INCLUDE ([airResponseKey],[airPrice],[airPriceTax],[NoOfSTOPs])
	CREATE NONCLUSTERED INDEX [IDX_airResponseKey_airPrice] ON #airResponseResultset ([airResponseKey])
		INCLUDE ([airPrice],[airlineName],[totalCost])
	CREATE NONCLUSTERED INDEX [IDX_NoOfAirlines] ON #airResponseResultset ([noofAirlines],[noOfOtherlegairlines])
		INCLUDE ([airResponseKey],[airSegmentMarketingAirlineCode],[airPrice],[totalCost],[otherlegAirlines])
	CREATE NONCLUSTERED INDEX [IDX_airResponseKey_MarketingAirline] ON #airResponseResultset ([airResponseKey])
		INCLUDE ([airPrice],[MarketingAirlineName],[actualTakeOffDateForLeg],[airlineName],[totalCost])
	CREATE NONCLUSTERED INDEX [IDX_Arrival] ON #airResponseResultset ([airSegmentArrivalOffset])
		INCLUDE ([airSegmentArrivalAirport])
	CREATE NONCLUSTERED INDEX [IDX_Departure] ON #airResponseResultset ([airsegmentDepartureOffset])
		INCLUDE ([airSegmentDepartureAirport])
	CREATE NONCLUSTERED INDEX [IDX_MultiBrandKey_airSegmentKey] ON #airResponseResultset ([airResponseMultiBrandkey])
		INCLUDE ([airSegmentKey])
	CREATE NONCLUSTERED INDEX [IDX_MultiBrand_airLegNumber] ON #AirSegmentsMultiBrand ([airResponseMultiBrandKey],[airLegNumber])
		INCLUDE ([airSegmentKey],[airResponseKey],[airSegmentResBookDesigCode],[airSegmentCabin],[airSegmentBrandName],[airSegmentBrandID],[airSegmentBaggage],[airSegmentMealCode])

	CREATE TABLE #airSegmentMultiBrandResultset  
	(  
	airSegmentKey uniqueidentifier,  
	airResponseKey uniqueidentifier , 
	airResponseMultiBrandKey uniqueidentifier ,      
	airSegmentResBookDesigCode varchar(3),  
	isRefundable bit ,  
	airsegmentCabin varchar (20),  
	airSegmentBrandName nvarchar(200),
	airSegmentBrandID nvarchar(200),
	airSegmentBaggage nvarchar(200),
	airSegmentMealCode nvarchar(200),
	)  

	CREATE TABLE #AllOneWayResponses      
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airOnePriceBase float ,  
	airOnePriceTax float,  
	airOnePriceBaseSenior float,
	airOnePriceTaxSenior float,
	airOnePriceBaseChildren float,
	airOnePriceTaxChildren float,
	airOnePriceBaseInfant float,
	airOnePriceTaxInfant float,
	airOnePriceBaseYouth float,
	airOnePriceTaxYouth float,
	airOnePriceBaseTotal float,
	airOnePriceTaxTotal float,
	airOnePriceBaseDisplay float,
	airOnePriceTaxDisplay float,
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,  
	airpriceTotal float ,   
	otherLegprice float , 
	cabinclass varchar(50),
	otherlegtax float ,
	otherlegAirlines varchar(100) ,
	noOfOtherlegairlines int    ,
	legConnections Varchar(100),
	airOnePriceBaseInfantWithSeat float,
	airOnePriceTaxInfantWithSeat float,
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	isMultiCabinFare bit default 0,
	isRefundable bit default 0,
	isValid bit default 1
	)   
	CREATE NONCLUSTERED INDEX [IDX_MultiBrandFare] ON #AllOneWayResponses ([isMultiBrandFare],[airResponseMultiBrandKey])
	CREATE NONCLUSTERED INDEX [IDX_subRequestKey_other] ON #AllOneWayResponses ([airsubRequestkey])
		INCLUDE ([airOnePriceBase],[airOnePriceTax],[airSegmentFlightNumber],[airSegmentMarketingAirlineCode],[airLegBookingClasses])
	CREATE NONCLUSTERED INDEX [IDX_MultiBrandKey] ON #AllOneWayResponses ([airResponseMultiBrandKey])
	CREATE NONCLUSTERED INDEX [IDX_airOneResponseKey] ON #AllOneWayResponses ([airOneResponsekey])

	CREATE TABLE #Temp_Group
	(
	airOneResponsekey uniqueidentifier , 
	GroupId int
	)
	
	CREATE TABLE #AllOneWayResponses_Leg1      
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airOnePriceBase float ,  
	airOnePriceTax float,  
	airOnePriceBaseSenior float,
	airOnePriceTaxSenior float,
	airOnePriceBaseChildren float,
	airOnePriceTaxChildren float,
	airOnePriceBaseInfant float,
	airOnePriceTaxInfant float,
	airOnePriceBaseYouth float,
	airOnePriceTaxYouth float,
	airOnePriceBaseTotal float,
	airOnePriceTaxTotal float,
	airOnePriceBaseDisplay float,
	airOnePriceTaxDisplay float,
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,  
	airpriceTotal float ,   
	otherLegprice float , 
	cabinclass varchar(50),
	otherlegtax float ,
	otherlegAirlines varchar(100) ,
	noOfOtherlegairlines int    ,
	legConnections Varchar(100),
	airOnePriceBaseInfantWithSeat float,
	airOnePriceTaxInfantWithSeat float,
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	isMultiCabinFare bit default 0,
	isRefundable bit default 0,
	legDateTime DATETIME,
	airGroupId BIGINT,
	airLegNumber INT,
	airPriceLowest_Basic  FLOAT default 0,
	airPriceTaxLowest_Basic  FLOAT default 0,
	airPriceLowest_Main_L  FLOAT default 0,
	airPriceTaxLowest_Main_L  FLOAT   default 0,
	airPriceLowest_Main_R  FLOAT  default 0,
	airPriceTaxLowest_Main_R  FLOAT   default 0,
	airPriceLowest_Business_L  FLOAT default 0,
	airPriceTaxLowest_Business_L  FLOAT   default 0,
	airPriceLowest_Business_R  FLOAT default 0,
	airPriceTaxLowest_Business_R  FLOAT   default 0,
	airPriceLowest_Select_L  FLOAT default 0,
	airPriceTaxLowest_Select_L  FLOAT   default 0,
	airPriceLowest_Select_R  FLOAT default 0,
	airPriceTaxLowest_Select_R  FLOAT   default 0,
	airPriceLowest_First_L  FLOAT default 0,
	airPriceTaxLowest_First_L  FLOAT   default 0,
	airPriceLowest_First_R  FLOAT default 0,
	airPriceTaxLowest_First_R  FLOAT default 0,
	legAirport nvarchar(20)
	)    

	CREATE TABLE #AllOneWayResponses_Leg2     
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airOnePriceBase float ,  
	airOnePriceTax float,  
	airOnePriceBaseSenior float,
	airOnePriceTaxSenior float,
	airOnePriceBaseChildren float,
	airOnePriceTaxChildren float,
	airOnePriceBaseInfant float,
	airOnePriceTaxInfant float,
	airOnePriceBaseYouth float,
	airOnePriceTaxYouth float,
	airOnePriceBaseTotal float,
	airOnePriceTaxTotal float,
	airOnePriceBaseDisplay float,
	airOnePriceTaxDisplay float,
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,  
	airpriceTotal float ,   
	otherLegprice float , 
	cabinclass varchar(50),
	otherlegtax float ,
	otherlegAirlines varchar(100) ,
	noOfOtherlegairlines int    ,
	legConnections Varchar(100),
	airOnePriceBaseInfantWithSeat float,
	airOnePriceTaxInfantWithSeat float,
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	isMultiCabinFare bit default 0,
	isRefundable bit default 0,
	legDateTime DATETIME,
	airGroupId BIGINT,
	airLegNumber INT,
	airPriceLowest_Basic  FLOAT default 0,
	airPriceTaxLowest_Basic  FLOAT default 0,
	airPriceLowest_Main_L  FLOAT default 0,
	airPriceTaxLowest_Main_L  FLOAT   default 0,
	airPriceLowest_Main_R  FLOAT  default 0,
	airPriceTaxLowest_Main_R  FLOAT   default 0,
	airPriceLowest_Business_L  FLOAT default 0,
	airPriceTaxLowest_Business_L  FLOAT   default 0,
	airPriceLowest_Business_R  FLOAT default 0,
	airPriceTaxLowest_Business_R  FLOAT   default 0,
	airPriceLowest_Select_L  FLOAT default 0,
	airPriceTaxLowest_Select_L  FLOAT   default 0,
	airPriceLowest_Select_R  FLOAT default 0,
	airPriceTaxLowest_Select_R  FLOAT   default 0,
	airPriceLowest_First_L  FLOAT default 0,
	airPriceTaxLowest_First_L  FLOAT   default 0,
	airPriceLowest_First_R  FLOAT default 0,
	airPriceTaxLowest_First_R  FLOAT default 0,
	legAirport nvarchar(20)
	) 
	
	CREATE TABLE #AllOneWayResponses_Legs_Merge_tmp     
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airOnePriceBase float ,  
	airOnePriceTax float,  
	airOnePriceBaseSenior float,
	airOnePriceTaxSenior float,
	airOnePriceBaseChildren float,
	airOnePriceTaxChildren float,
	airOnePriceBaseInfant float,
	airOnePriceTaxInfant float,
	airOnePriceBaseYouth float,
	airOnePriceTaxYouth float,
	airOnePriceBaseTotal float,
	airOnePriceTaxTotal float,
	airOnePriceBaseDisplay float,
	airOnePriceTaxDisplay float,
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,  
	airpriceTotal float ,   
	otherLegprice float , 
	cabinclass varchar(50),
	otherlegtax float ,
	otherlegAirlines varchar(100) ,
	noOfOtherlegairlines int    ,
	legConnections Varchar(100),
	airOnePriceBaseInfantWithSeat float,
	airOnePriceTaxInfantWithSeat float,
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	isMultiCabinFare bit default 0,
	isRefundable bit default 0,
	legDateTime DATETIME,
	airGroupId BIGINT,
	airLegNumber INT,
	airPriceLowest_Basic  FLOAT default 0,
	airPriceTaxLowest_Basic  FLOAT default 0,
	airPriceLowest_Main_L  FLOAT default 0,
	airPriceTaxLowest_Main_L  FLOAT   default 0,
	airPriceLowest_Main_R  FLOAT  default 0,
	airPriceTaxLowest_Main_R  FLOAT   default 0,
	airPriceLowest_Business_L  FLOAT default 0,
	airPriceTaxLowest_Business_L  FLOAT   default 0,
	airPriceLowest_Business_R  FLOAT default 0,
	airPriceTaxLowest_Business_R  FLOAT   default 0,
	airPriceLowest_Select_L  FLOAT default 0,
	airPriceTaxLowest_Select_L  FLOAT   default 0,
	airPriceLowest_Select_R  FLOAT default 0,
	airPriceTaxLowest_Select_R  FLOAT   default 0,
	airPriceLowest_First_L  FLOAT default 0,
	airPriceTaxLowest_First_L  FLOAT   default 0,
	airPriceLowest_First_R  FLOAT default 0,
	airPriceTaxLowest_First_R  FLOAT default 0,
	legAirport nvarchar(20)
	) 

	CREATE TABLE #AllOneWayResponses_Legs_Merge     
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airOnePriceBase float ,  
	airOnePriceTax float,  
	airOnePriceBaseSenior float,
	airOnePriceTaxSenior float,
	airOnePriceBaseChildren float,
	airOnePriceTaxChildren float,
	airOnePriceBaseInfant float,
	airOnePriceTaxInfant float,
	airOnePriceBaseYouth float,
	airOnePriceTaxYouth float,
	airOnePriceBaseTotal float,
	airOnePriceTaxTotal float,
	airOnePriceBaseDisplay float,
	airOnePriceTaxDisplay float,
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,  
	airpriceTotal float ,   
	otherLegprice float default 0, 
	cabinclass varchar(50),
	otherlegtax float default 0 ,
	otherlegAirlines varchar(100) ,
	noOfOtherlegairlines int    ,
	legConnections Varchar(100),
	airOnePriceBaseInfantWithSeat float,
	airOnePriceTaxInfantWithSeat float,
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	isMultiCabinFare bit default 0,
	isRefundable bit default 0,
	legDateTime DATETIME,
	airGroupId BIGINT,
	airLegNumber INT,
	airPriceLowest_Basic  FLOAT default 0,
	airPriceTaxLowest_Basic  FLOAT default 0,
	airPriceLowest_Main_L  FLOAT default 0,
	airPriceTaxLowest_Main_L  FLOAT   default 0,
	airPriceLowest_Main_R  FLOAT  default 0,
	airPriceTaxLowest_Main_R  FLOAT   default 0,
	airPriceLowest_Business_L  FLOAT default 0,
	airPriceTaxLowest_Business_L  FLOAT   default 0,
	airPriceLowest_Business_R  FLOAT default 0,
	airPriceTaxLowest_Business_R  FLOAT   default 0,
	airPriceLowest_Select_L  FLOAT default 0,
	airPriceTaxLowest_Select_L  FLOAT   default 0,
	airPriceLowest_Select_R  FLOAT default 0,
	airPriceTaxLowest_Select_R  FLOAT   default 0,
	airPriceLowest_First_L  FLOAT default 0,
	airPriceTaxLowest_First_L  FLOAT   default 0,
	airPriceLowest_First_R  FLOAT default 0,
	airPriceTaxLowest_First_R  FLOAT default 0,
	isValid bit default 0,
	legAirport nvarchar(20)
	) 

	CREATE TABLE #AllOneWaywithAdditional
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier 
	)      
	
	DECLARE @Temp_AllOneWayResponses AS TABLE     
	(  
	airOneIdent int identity (1,1),  
	airOneResponsekey uniqueidentifier ,   
	airOnePriceBase float ,  
	airOnePriceTax float,  
	airOnePriceBaseSenior float,
	airOnePriceTaxSenior float,
	airOnePriceBaseChildren float,
	airOnePriceTaxChildren float,
	airOnePriceBaseInfant float,
	airOnePriceTaxInfant float,
	airOnePriceBaseYouth float,
	airOnePriceTaxYouth float,
	airOnePriceBaseTotal float,
	airOnePriceTaxTotal float,
	airOnePriceBaseDisplay float,
	airOnePriceTaxDisplay float,
	airSegmentFlightNumber varchar(100),  
	airSegmentMarketingAirlineCode varchar(100),  
	airsubRequestkey int ,  
	airpriceTotal float ,   
	otherLegprice float , 
	cabinclass varchar(50),
	otherlegtax float ,
	otherlegAirlines varchar(100) ,
	noOfOtherlegairlines int    ,
	legConnections Varchar(100),
	airOnePriceBaseInfantWithSeat float,
	airOnePriceTaxInfantWithSeat float,
	agentwareQueryID nvarchar(30),
	agentwareItineraryID nvarchar(30),
	airLegBrandName nvarchar(200) NULL,
	airLegBookingClasses varchar(20) NULL,
	airResponseMultiBrandKey uniqueidentifier NULL,
	isMultiBrandFare bit default 0,
	gdsSourceKey int ,
	childResponsekey uniqueidentifier NULL,
	isMultiCabinFare bit default 0,
	isRefundable bit default 0,
	isValid bit default 1
	) 

	DECLARE @secondLegDetails as TABLE 
	(
	otherLegAirlines varchar(40) , 
	responsekey uniqueidentifier , 
	otherlegsAirlinesCount int 
	)
	IF(@isSameDayReturnOWLogicToApply = 1 AND @airRequestTypeKey = 1)
	BEGIN
		-- Leg 1 Normal
		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 1 AND n.airsubrequestkey = @airSubRequestKey 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 
				
		-- Leg 1 Multicabin
		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,1
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 1 AND n.airsubrequestkey = @airMultiCabinRequest 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 

		-- Leg 1 Agentware Response
		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 1 AND n.airsubrequestkey = @airAgentWareWNRequest 
		and ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END ) 

		-- Leg 1 Travelfusion Response
		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 1 AND n.airsubrequestkey = @airTravelfusionRequest 
		and ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END ) 

		-- Leg 1 MultiBrand
		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,airResponseMultiBrandKey,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,resp.airResponseMultiBrandKey,1
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE n.airlegNumber = 1 AND n.airsubrequestkey = @airSubRequestKey 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 

		-- Leg 1 MultiBrand Multicabin
		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,isMultiCabinFare,airResponseMultiBrandKey,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,1,resp.airResponseMultiBrandKey,1
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE n.airlegNumber = 1 AND n.airsubrequestkey = @airMultiCabinRequest 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )

		-- Leg 1 MultiBrand Agentware
		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,airResponseMultiBrandKey,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (resp.airPriceBase  ),
		(resp.airPriceBaseSenior  ),(resp.airPriceTaxSenior ),
		(resp.airPriceBaseChildren  ),(resp.airPriceTaxChildren),
		(resp.airPriceBaseInfant  ),(resp.airPriceTaxInfant ),
		(resp.airPriceBaseYouth  ),(resp.airPriceTaxYouth),
		(resp.AirPriceBaseTotal   ),(resp.AirPriceTaxTotal ),
		(resp.airPriceBaseDisplay   ),(resp.airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax),(resp.airPriceBase   )+(resp.airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(resp.airPriceBaseInfantWithSeat  ),(resp.airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,resp.airResponseMultiBrandKey,1,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
		inner join #AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
		AND n.airlegNumber = @airRequestTypekey
		WHERE resp.airSubRequestKey = @airAgentWareWNRequest and airlegnumber = @airRequestTypeKey
		AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )

		-- Leg 1 MultiBrand Travelfusion

		INSERT #AllOneWayResponses_Leg1 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,airResponseMultiBrandKey,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (resp.airPriceBase  ),
		(resp.airPriceBaseSenior  ),(resp.airPriceTaxSenior ),
		(resp.airPriceBaseChildren  ),(resp.airPriceTaxChildren),
		(resp.airPriceBaseInfant  ),(resp.airPriceTaxInfant ),
		(resp.airPriceBaseYouth  ),(resp.airPriceTaxYouth),
		(resp.AirPriceBaseTotal   ),(resp.AirPriceTaxTotal ),
		(resp.airPriceBaseDisplay   ),(resp.airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax),(resp.airPriceBase   )+(resp.airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(resp.airPriceBaseInfantWithSeat  ),(resp.airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,resp.airResponseMultiBrandKey,1,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
		inner join #AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
		AND n.airlegNumber = @airRequestTypekey
		WHERE resp.airSubRequestKey = @airTravelfusionRequest and airlegnumber = @airRequestTypeKey
		AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
				
		-- Leg 2 Normal
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,2
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 2 AND n.airsubrequestkey = @airSubRequestKey_Leg2 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 

		-- Leg 2 Multicabin
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,2
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 2 AND n.airsubrequestkey = @airMultiCabinRequest_Leg2 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 

		-- Leg 2 Agentware Response
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,2,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 2 AND n.airsubrequestkey = @airAgentWareWNRequest_Leg2 
		and ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END ) 

		-- Leg 2 Travelfusion Response
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,2,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE n.airlegNumber = 2 AND n.airsubrequestkey = @airTravelfusionRequest_Leg2 
		and ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )

		-- Leg 2 MultiBrand
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,airResponseMultiBrandKey,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,resp.airResponseMultiBrandKey,2
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airresponseMultiBrandkey WHERE n.airlegNumber = 2 AND n.airsubrequestkey = @airSubRequestKey_Leg2 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 

		-- Leg 2 MultiBrand Multicabin
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,isMultiCabinFare,airResponseMultiBrandKey,airLegNumber)  
		SELECT resp.airresponsekey, (airPriceBase  ),
		(airPriceBaseSenior  ),(airPriceTaxSenior ),
		(airPriceBaseChildren  ),(airPriceTaxChildren),
		(airPriceBaseInfant  ),(airPriceTaxInfant ),
		(airPriceBaseYouth  ),(airPriceTaxYouth),
		(AirPriceBaseTotal   ),(AirPriceTaxTotal ),
		(airPriceBaseDisplay   ),(airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax),(airPriceBase   )+(airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(airPriceBaseInfantWithSeat  ),(airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,1,resp.airResponseMultiBrandKey,2
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airresponseMultiBrandkey WHERE n.airlegNumber = 2 AND n.airsubrequestkey = @airMultiCabinRequest_Leg2 
		and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )

		-- Leg 2 MultiBrand Agentware
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,airResponseMultiBrandKey,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (resp.airPriceBase  ),
		(resp.airPriceBaseSenior  ),(resp.airPriceTaxSenior ),
		(resp.airPriceBaseChildren  ),(resp.airPriceTaxChildren),
		(resp.airPriceBaseInfant  ),(resp.airPriceTaxInfant ),
		(resp.airPriceBaseYouth  ),(resp.airPriceTaxYouth),
		(resp.AirPriceBaseTotal   ),(resp.AirPriceTaxTotal ),
		(resp.airPriceBaseDisplay   ),(resp.airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax),(resp.airPriceBase   )+(resp.airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(resp.airPriceBaseInfantWithSeat  ),(resp.airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,resp.airResponseMultiBrandKey,2,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
		inner join #AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
		AND n.airlegNumber = 2
		WHERE resp.airSubRequestKey = @airAgentWareWNRequest_Leg2 and airlegnumber = 2
		AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )

		-- Leg 2 MultiBrand Travelfusion
		INSERT #AllOneWayResponses_Leg2 (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiBrandFare,airResponseMultiBrandKey,airLegNumber,agentwareQueryID,agentwareItineraryID)  
		SELECT resp.airresponsekey, (resp.airPriceBase  ),
		(resp.airPriceBaseSenior  ),(resp.airPriceTaxSenior ),
		(resp.airPriceBaseChildren  ),(resp.airPriceTaxChildren),
		(resp.airPriceBaseInfant  ),(resp.airPriceTaxInfant ),
		(resp.airPriceBaseYouth  ),(resp.airPriceTaxYouth),
		(resp.AirPriceBaseTotal   ),(resp.AirPriceTaxTotal ),
		(resp.airPriceBaseDisplay   ),(resp.airPriceTaxDisplay),
		flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax),(resp.airPriceBase   )+(resp.airPriceTax), 0 ,N.cabinclass ,0  ,n.airLegConnections,
		(resp.airPriceBaseInfantWithSeat  ),(resp.airPriceTaxInfantWithSeat ),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable,1,resp.airResponseMultiBrandKey,2,agentwareQueryID,agentwareItineraryID
		From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
		inner join #AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
		AND n.airlegNumber = 2
		WHERE resp.airSubRequestKey = @airTravelfusionRequest_Leg2 and airlegnumber = 2
		AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )

		Delete P  
		FROM #AllOneWayResponses_Leg1  P  
		INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey 
		
		Delete P  
		FROM #AllOneWayResponses_Leg2  P  
		INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey  

		IF(@isMultiBrand = 1)
		BEGIN
			Delete P  
			FROM #AllOneWayResponses_Leg1  P  
			INNER JOIN @tempResponseToRemove_MultiBrand T  ON P.airResponseMultiBrandKey = T.airresponseMultiBrandkey 
			where P.airResponseMultiBrandKey IS NOT NULL AND P.isMultiBrandFare = 1

			Delete P  
			FROM #AllOneWayResponses_Leg2  P  
			INNER JOIN @tempResponseToRemove_MultiBrand T  ON P.airResponseMultiBrandKey = T.airresponseMultiBrandkey 
			where P.airResponseMultiBrandKey IS NOT NULL AND P.isMultiBrandFare = 1
		END

		-- Step 1 For Leg 1 
		delete #AllOneWayResponses_Leg1  
		FROM #AllOneWayResponses_Leg1 t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice, MIN(airOneIdent )  AS minIdent,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,isRefundable  
		FROM #AllOneWayResponses_Leg1 m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,isRefundable
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses = derived.airLegBookingClasses 
		AND t.isRefundable = derived.isRefundable
		AND (airOnePriceBase + airOnePriceTax) >  minPrice --AND airOneIdent > minIdent 
		and (t.airsubRequestkey = @airMultiCabinRequest OR t.airsubRequestkey = @airMultiCabinBundledRequest )
				
		delete #AllOneWayResponses_Leg1  
		FROM #AllOneWayResponses_leg1 t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable   
		FROM #AllOneWayResponses_Leg1 m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable 
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
		AND t.airLegBrandName = derived.airLegBrandName AND t.isRefundable = derived.isRefundable
		AND (airOnePriceBase + airOnePriceTax) >  minPrice

		delete #AllOneWayResponses_Leg1  
		FROM #AllOneWayResponses_Leg1 t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable   
		FROM #AllOneWayResponses_Leg1 m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable 
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
		AND t.airLegBrandName = derived.airLegBrandName AND t.isRefundable = derived.isRefundable
		AND airOneIdent > minIdent

		delete #AllOneWayResponses_Leg2  
		FROM #AllOneWayResponses_Leg2 t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice, MIN(airOneIdent )  AS minIdent,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,isRefundable  
		FROM #AllOneWayResponses_Leg2 m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,isRefundable
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses = derived.airLegBookingClasses 
		AND t.isRefundable = derived.isRefundable
		AND (airOnePriceBase + airOnePriceTax) >  minPrice --AND airOneIdent > minIdent 
		and (t.airsubRequestkey = @airMultiCabinRequest_Leg2 OR t.airsubRequestkey = @airMultiCabinBundledRequest )


		delete #AllOneWayResponses_Leg2  
		FROM #AllOneWayResponses_leg2 t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable   
		FROM #AllOneWayResponses_Leg2 m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable 
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
		AND t.airLegBrandName = derived.airLegBrandName AND t.isRefundable = derived.isRefundable
		AND (airOnePriceBase + airOnePriceTax) >  minPrice

		delete #AllOneWayResponses_Leg2  
		FROM #AllOneWayResponses_Leg2 t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable   
		FROM #AllOneWayResponses_Leg2 m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable 
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
		AND t.airLegBrandName = derived.airLegBrandName AND t.isRefundable = derived.isRefundable
		AND airOneIdent > minIdent
		
		UPDATE #AllOneWayResponses_Leg1 
		SET legDateTime = airSegmentArrivalDate,legAirport = airSegmentArrivalAirport
		FROM #AirResponse resp inner join 
		#Airsegments seg on resp.airResponseKey = seg.airResponseKey
		inner join  #AllOneWayResponses_Leg1 leg1 on resp.airResponseKey = leg1.airOneResponsekey
		where seg.airLegNumber = 1 AND segmentOrder = (select max(segmentOrder) from #AirSegments A WHERE A.airResponseKey = resp.airResponseKey AND A.airLegNumber = 1)
		
		UPDATE #AllOneWayResponses_Leg2
		SET legDateTime = airSegmentDepartureDate,legAirport = airSegmentDepartureAirport
		FROM #AirResponse resp inner join 
		#Airsegments seg on resp.airResponseKey = seg.airResponseKey
		inner join  #AllOneWayResponses_Leg2 leg2 on resp.airResponseKey = leg2.airOneResponsekey
		where seg.airLegNumber = 2 AND segmentOrder = 1

		INSERT INTO #Temp_Group
		SELECT airOneResponsekey,  DENSE_RANK() OVER(ORDER BY airSegmentFlightNumber,airSegmentMarketingAirlineCode) GroupId
		FROM #AllOneWayResponses_Leg1

		UPDATE #AllOneWayResponses_Leg1 
		SET airGroupId = #Temp_Group.GroupId
		FROM #Temp_Group  inner join 
		#AllOneWayResponses_Leg1 ON #AllOneWayResponses_Leg1.airOneResponsekey = #Temp_Group.airOneResponsekey
						
		truncate table #Temp_Group

		INSERT INTO #Temp_Group
		SELECT airOneResponsekey,  DENSE_RANK() OVER(ORDER BY legDateTime desc ,airSegmentFlightNumber,airSegmentMarketingAirlineCode ) GroupId
		FROM #AllOneWayResponses_Leg2

		UPDATE #AllOneWayResponses_Leg2
		SET airGroupId = #Temp_Group.GroupId
		FROM #Temp_Group  inner join 
		#AllOneWayResponses_Leg2 ON #AllOneWayResponses_Leg2.airOneResponsekey = #Temp_Group.airOneResponsekey

		DECLARE @airPriceForAnotherLeg_Basic AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Basic AS FLOAT   = 0 

		DECLARE @airPriceForAnotherLeg_Main_L AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Main_L AS FLOAT   = 0 
		DECLARE @airPriceForAnotherLeg_Main_R AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Main_R AS FLOAT   = 0 

		DECLARE @airPriceForAnotherLeg_Business_L AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Business_L AS FLOAT   = 0 
		DECLARE @airPriceForAnotherLeg_Business_R AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Business_R AS FLOAT   = 0 

		DECLARE @airPriceForAnotherLeg_Select_L AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Select_L AS FLOAT   = 0 
		DECLARE @airPriceForAnotherLeg_Select_R AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Select_R AS FLOAT   = 0 

		DECLARE @airPriceForAnotherLeg_First_L AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_First_L AS FLOAT   = 0 
		DECLARE @airPriceForAnotherLeg_First_R AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_First_R AS FLOAT   = 0 

		DECLARE @airPriceForAnotherLeg_Basic_AW AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Basic_AW AS FLOAT   = 0 

		DECLARE @airPriceForAnotherLeg_Main_R_AW AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Main_R_AW AS FLOAT   = 0 

		DECLARE @airPriceForAnotherLeg_Select_R_AW AS FLOAT = 0 
		DECLARE @airPriceTaxForAnotherLeg_Select_R_AW AS FLOAT   = 0 

		SELECT ROW_NUMBER() over(order by airGroupId) ID_Loop,*
		INTO #AllOneWayResponses_Leg2_1
		from #AllOneWayResponses_Leg2 
		order by airGroupId asc

		DECLARE @ID_Loop int=(select max(ID_Loop) from #AllOneWayResponses_Leg2_1)
		Declare @START_LOOP int=1
		Declare @Start_GruopId int
		Declare @airLegBrandName_loop varchar(10)
		Declare @isRefundable_loop int
		DECLARE @airOnePriceBase float
		DECLARE @airOnePriceTax float
		DECLARE @airGroupId bigint
		Declare @gdsSourceKey_Loop int
		WHILE @START_LOOP<=@ID_Loop
		BEGIN
		SELECT 
		@airLegBrandName_loop=UPPER(airLegBrandName), @isRefundable_loop=isRefundable,
		@airOnePriceBase  = airOnePriceBase , @airOnePriceTax = airOnePriceTax , @airGroupId = airGroupId, @gdsSourceKey_Loop = gdsSourceKey
		FROM #AllOneWayResponses_Leg2_1 
		where ID_Loop=@START_LOOP

		IF(@gdsSourceKey_Loop = 12)
		BEGIN
			IF @airLegBrandName_loop='BASIC' and @isRefundable_loop=0
			AND ((@airPriceForAnotherLeg_Basic_AW + @airPriceTaxForAnotherLeg_Basic_AW) = 0 
			OR 
			(@airPriceForAnotherLeg_Basic_AW + @airPriceTaxForAnotherLeg_Basic_AW) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Basic_AW  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Basic_AW = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Basic = @airPriceForAnotherLeg_Basic_AW,airPriceTaxLowest_Basic= @airPriceTaxForAnotherLeg_Basic_AW 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='BASIC' and @isRefundable_loop=0 AND 
			(@airPriceForAnotherLeg_Basic_AW + @airPriceTaxForAnotherLeg_Basic_AW) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Basic= @airPriceForAnotherLeg_Basic_AW,airPriceTaxLowest_Basic = @airPriceTaxForAnotherLeg_Basic_AW 
				where airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='MAIN' and @isRefundable_loop=1
			AND ((@airPriceForAnotherLeg_Main_R_AW + @airPriceTaxForAnotherLeg_Main_R_AW) = 0 
			OR 
			(@airPriceForAnotherLeg_Main_R_AW + @airPriceTaxForAnotherLeg_Main_R_AW) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Main_R_AW  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Main_R_AW = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Main_R= @airPriceForAnotherLeg_Main_R_AW,airPriceTaxLowest_Main_R= @airPriceTaxForAnotherLeg_Main_R_AW 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='MAIN' and @isRefundable_loop=1 AND 
			(@airPriceForAnotherLeg_Main_R_AW + @airPriceTaxForAnotherLeg_Main_R_AW) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Main_R= @airPriceForAnotherLeg_Main_R_AW,airPriceTaxLowest_Main_R= @airPriceTaxForAnotherLeg_Main_R_AW 
				where airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='SELECT' and @isRefundable_loop=1
			AND ((@airPriceForAnotherLeg_Select_R_AW + @airPriceTaxForAnotherLeg_Select_R_AW) = 0 
			OR 
			(@airPriceForAnotherLeg_Select_R_AW + @airPriceTaxForAnotherLeg_Select_R_AW) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Select_R_AW  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Select_R_AW = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Select_R= @airPriceForAnotherLeg_Select_R_AW,airPriceTaxLowest_Select_R= @airPriceTaxForAnotherLeg_Select_R_AW 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='SELECT' and @isRefundable_loop=1 AND 
			(@airPriceForAnotherLeg_Select_R_AW + @airPriceTaxForAnotherLeg_Select_R_AW) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Select_R= @airPriceForAnotherLeg_Select_R_AW,airPriceTaxLowest_Select_R= @airPriceTaxForAnotherLeg_Select_R_AW 
				where airGroupId = @airGroupId
			END

			IF(@airPriceForAnotherLeg_Basic_AW + @airPriceTaxForAnotherLeg_Basic_AW <> 0 AND (SELECT airPriceLowest_Basic + airPriceTaxLowest_Basic FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Basic = @airPriceForAnotherLeg_Basic_AW,
			airPriceTaxLowest_Basic = @airPriceTaxForAnotherLeg_Basic_AW where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Main_R_AW + @airPriceTaxForAnotherLeg_Main_R_AW <> 0 AND (SELECT airPriceLowest_Main_R + airPriceTaxLowest_Main_R FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Main_R = @airPriceForAnotherLeg_Main_R_AW,
			airPriceTaxLowest_Main_R = @airPriceTaxForAnotherLeg_Main_R_AW where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Select_R_AW + @airPriceTaxForAnotherLeg_Select_R_AW <> 0 AND (SELECT airPriceLowest_Select_R + airPriceTaxLowest_Select_R FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Select_R = @airPriceForAnotherLeg_Select_R_AW,
			airPriceTaxLowest_Select_R = @airPriceTaxForAnotherLeg_Select_R_AW where ID_Loop = @START_LOOP
			END
		END
		ELSE
		BEGIN
			------------------ Basic ---------------------
			IF @airLegBrandName_loop='BASIC' and @isRefundable_loop=0
			AND ((@airPriceForAnotherLeg_Basic + @airPriceTaxForAnotherLeg_Basic) = 0 
			OR 
			(@airPriceForAnotherLeg_Basic + @airPriceTaxForAnotherLeg_Basic) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Basic  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Basic = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Basic = @airPriceForAnotherLeg_Basic,airPriceTaxLowest_Basic= @airPriceTaxForAnotherLeg_Basic 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='BASIC' and @isRefundable_loop=0 AND 
			(@airPriceForAnotherLeg_Basic + @airPriceTaxForAnotherLeg_Basic) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Basic= @airPriceForAnotherLeg_Basic,airPriceTaxLowest_Basic = @airPriceTaxForAnotherLeg_Basic 
				where airGroupId = @airGroupId
			END
			------------------ Main Lowest ----------------------
			ELSE IF @airLegBrandName_loop='MAIN' and @isRefundable_loop=0
			AND ((@airPriceForAnotherLeg_Main_L + @airPriceTaxForAnotherLeg_Main_L) = 0 
			OR 
			(@airPriceForAnotherLeg_Main_L + @airPriceTaxForAnotherLeg_Main_L) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Main_L  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Main_L = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Main_L= @airPriceForAnotherLeg_Main_L,airPriceTaxLowest_Main_L= @airPriceTaxForAnotherLeg_Main_L 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='MAIN' and @isRefundable_loop=0 AND 
			(@airPriceForAnotherLeg_Main_L + @airPriceTaxForAnotherLeg_Main_L) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Main_L= @airPriceForAnotherLeg_Main_L,airPriceTaxLowest_Main_L= @airPriceTaxForAnotherLeg_Main_L 
				where airGroupId = @airGroupId 
			END
			-------------------- Main Refundable -------------------
			ELSE IF @airLegBrandName_loop='MAIN' and @isRefundable_loop=1
			AND ((@airPriceForAnotherLeg_Main_R + @airPriceTaxForAnotherLeg_Main_R) = 0 
			OR 
			(@airPriceForAnotherLeg_Main_R + @airPriceTaxForAnotherLeg_Main_R) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Main_R  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Main_R = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Main_R= @airPriceForAnotherLeg_Main_R,airPriceTaxLowest_Main_R= @airPriceTaxForAnotherLeg_Main_R 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='MAIN' and @isRefundable_loop=1 AND 
			(@airPriceForAnotherLeg_Main_R + @airPriceTaxForAnotherLeg_Main_R) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Main_R= @airPriceForAnotherLeg_Main_R,airPriceTaxLowest_Main_R= @airPriceTaxForAnotherLeg_Main_R 
				where airGroupId = @airGroupId
			END
			----------------- First lowest ----------------------
			ELSE IF @airLegBrandName_loop='FIRST' and @isRefundable_loop=0
			AND ((@airPriceForAnotherLeg_First_L + @airPriceTaxForAnotherLeg_First_L) = 0 
			OR 
			(@airPriceForAnotherLeg_First_L + @airPriceTaxForAnotherLeg_First_L) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_First_L  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_First_L = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_First_L= @airPriceForAnotherLeg_First_L,airPriceTaxLowest_First_L= @airPriceTaxForAnotherLeg_First_L 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='FIRST' and @isRefundable_loop=0 AND 
			(@airPriceForAnotherLeg_First_L + @airPriceTaxForAnotherLeg_First_L) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_First_L= @airPriceForAnotherLeg_First_L,airPriceTaxLowest_First_L= @airPriceTaxForAnotherLeg_First_L 
				where airGroupId = @airGroupId
			END
			----------------- First refundable ------------------------
			ELSE IF @airLegBrandName_loop='FIRST' and @isRefundable_loop=1
			AND ((@airPriceForAnotherLeg_First_R + @airPriceTaxForAnotherLeg_First_R) = 0 
			OR 
			(@airPriceForAnotherLeg_First_R + @airPriceTaxForAnotherLeg_First_R) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_First_R  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_First_R = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_First_R= @airPriceForAnotherLeg_First_R,airPriceTaxLowest_First_R= @airPriceTaxForAnotherLeg_First_R 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='FIRST' and @isRefundable_loop=1 AND 
			(@airPriceForAnotherLeg_First_R + @airPriceTaxForAnotherLeg_First_R) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_First_R= @airPriceForAnotherLeg_First_R,airPriceTaxLowest_First_R = @airPriceTaxForAnotherLeg_First_R 
				where airGroupId = @airGroupId
			END
			-------------------- Business Lowest ---------------------
			ELSE IF @airLegBrandName_loop='BUSINESS' and @isRefundable_loop=0
			AND ((@airPriceForAnotherLeg_Business_L + @airPriceTaxForAnotherLeg_Business_L) = 0 
			OR 
			(@airPriceForAnotherLeg_Business_L + @airPriceTaxForAnotherLeg_Business_L) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Business_L  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Business_L = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Business_L= @airPriceForAnotherLeg_Business_L,airPriceTaxLowest_Business_L= @airPriceTaxForAnotherLeg_Business_L 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='BUSINESS' and @isRefundable_loop=0 AND 
			(@airPriceForAnotherLeg_Business_L + @airPriceTaxForAnotherLeg_Business_L) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Business_L= @airPriceForAnotherLeg_Business_L,airPriceTaxLowest_Business_L= @airPriceTaxForAnotherLeg_Business_L 
				where airGroupId = @airGroupId
			END
			------------------ Business refundable -------------------------------
			ELSE IF @airLegBrandName_loop='BUSINESS' and @isRefundable_loop=1
			AND ((@airPriceForAnotherLeg_Business_R + @airPriceTaxForAnotherLeg_Business_R) = 0 
			OR 
			(@airPriceForAnotherLeg_Business_R + @airPriceTaxForAnotherLeg_Business_R) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Business_R  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Business_R = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Business_R= @airPriceForAnotherLeg_Business_R,airPriceTaxLowest_Business_R= @airPriceTaxForAnotherLeg_Business_R
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='BUSINESS' and @isRefundable_loop=1 AND 
			(@airPriceForAnotherLeg_Business_R + @airPriceTaxForAnotherLeg_Business_R) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Business_R= @airPriceForAnotherLeg_Business_R,airPriceTaxLowest_Business_R= @airPriceTaxForAnotherLeg_Business_R 
				where airGroupId = @airGroupId
			END
			-------------------- Select Lowest ---------------------
			ELSE IF @airLegBrandName_loop='SELECT' and @isRefundable_loop=0
			AND ((@airPriceForAnotherLeg_Select_L + @airPriceTaxForAnotherLeg_Select_L) = 0 
			OR 
			(@airPriceForAnotherLeg_Select_L + @airPriceTaxForAnotherLeg_Select_L) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Select_L  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Select_L = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Select_L= @airPriceForAnotherLeg_Select_L,airPriceTaxLowest_Select_L= @airPriceTaxForAnotherLeg_Select_L 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='SELECT' and @isRefundable_loop=0 AND 
			(@airPriceForAnotherLeg_Select_L + @airPriceTaxForAnotherLeg_Select_L) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Select_L= @airPriceForAnotherLeg_Select_L,airPriceTaxLowest_Select_L= @airPriceTaxForAnotherLeg_Select_L 
				where airGroupId = @airGroupId
			END
			---------------------- Select Refundable ---------------------
			ELSE IF @airLegBrandName_loop='SELECT' and @isRefundable_loop=1
			AND ((@airPriceForAnotherLeg_Select_R + @airPriceTaxForAnotherLeg_Select_R) = 0 
			OR 
			(@airPriceForAnotherLeg_Select_R + @airPriceTaxForAnotherLeg_Select_R) >= (@airOnePriceBase +@airOnePriceTax))
			BEGIN
				SET @airPriceForAnotherLeg_Select_R  = @airOnePriceBase 
				SET @airPriceTaxForAnotherLeg_Select_R = @airOnePriceTax
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Select_R= @airPriceForAnotherLeg_Select_R,airPriceTaxLowest_Select_R= @airPriceTaxForAnotherLeg_Select_R 
				WHERE airGroupId = @airGroupId
			END
			ELSE IF @airLegBrandName_loop='SELECT' and @isRefundable_loop=1 AND 
			(@airPriceForAnotherLeg_Select_R + @airPriceTaxForAnotherLeg_Select_R) <= (@airOnePriceBase +@airOnePriceTax)
			BEGIN
				UPDATE #AllOneWayResponses_Leg2_1 
				SET airPriceLowest_Select_R= @airPriceForAnotherLeg_Select_R,airPriceTaxLowest_Select_R= @airPriceTaxForAnotherLeg_Select_R 
				where airGroupId = @airGroupId
			END

			-- Blanket update
			IF(@airPriceForAnotherLeg_Basic + @airPriceTaxForAnotherLeg_Basic <> 0 AND (SELECT airPriceLowest_Basic + airPriceTaxLowest_Basic FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Basic = @airPriceForAnotherLeg_Basic,
			airPriceTaxLowest_Basic = @airPriceTaxForAnotherLeg_Basic where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Main_L + @airPriceTaxForAnotherLeg_Main_L <> 0 AND (SELECT airPriceLowest_Main_L + airPriceTaxLowest_Main_L FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Main_L = @airPriceForAnotherLeg_Main_L,
			airPriceTaxLowest_Main_L = @airPriceTaxForAnotherLeg_Main_L where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Main_R + @airPriceTaxForAnotherLeg_Main_R <> 0 AND (SELECT airPriceLowest_Main_R + airPriceTaxLowest_Main_R FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Main_R = @airPriceForAnotherLeg_Main_R,
			airPriceTaxLowest_Main_R = @airPriceTaxForAnotherLeg_Main_R where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_First_L + @airPriceTaxForAnotherLeg_First_L <> 0 AND (SELECT airPriceLowest_First_L + airPriceTaxLowest_First_L FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_First_L = @airPriceForAnotherLeg_First_L,
			airPriceTaxLowest_First_L = @airPriceTaxForAnotherLeg_First_L where ID_Loop = @START_LOOP
			END
		
			IF(@airPriceForAnotherLeg_First_R + @airPriceTaxForAnotherLeg_First_R <> 0 AND (SELECT airPriceLowest_First_R + airPriceTaxLowest_First_R FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_First_R = @airPriceForAnotherLeg_First_R,
			airPriceTaxLowest_First_R = @airPriceTaxForAnotherLeg_First_R where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Business_L + @airPriceTaxForAnotherLeg_Business_L <> 0 AND (SELECT airPriceLowest_Business_L + airPriceTaxLowest_Business_L FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Business_L = @airPriceForAnotherLeg_Business_L,
			airPriceTaxLowest_Business_L = @airPriceTaxForAnotherLeg_Business_L where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Business_R + @airPriceTaxForAnotherLeg_Business_R <> 0 AND (SELECT airPriceLowest_Business_R + airPriceTaxLowest_Business_R FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Business_R = @airPriceForAnotherLeg_Business_R,
			airPriceTaxLowest_Business_R = @airPriceTaxForAnotherLeg_Business_R where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Select_L + @airPriceTaxForAnotherLeg_Select_L <> 0 AND (SELECT airPriceLowest_Select_L + airPriceTaxLowest_Select_L FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Select_L = @airPriceForAnotherLeg_Select_L,
			airPriceTaxLowest_Select_L = @airPriceTaxForAnotherLeg_Select_L where ID_Loop = @START_LOOP
			END

			IF(@airPriceForAnotherLeg_Select_R + @airPriceTaxForAnotherLeg_Select_R <> 0 AND (SELECT airPriceLowest_Select_R + airPriceTaxLowest_Select_R FROM #AllOneWayResponses_Leg2_1 where ID_loop = @START_LOOP) = 0)
			BEGIN
			UPDATE #AllOneWayResponses_Leg2_1 SET airPriceLowest_Select_R = @airPriceForAnotherLeg_Select_R,
			airPriceTaxLowest_Select_R = @airPriceTaxForAnotherLeg_Select_R where ID_Loop = @START_LOOP
			END
		END

		SET @START_LOOP=@START_LOOP+1
		END

		INSERT INTO #AllOneWayResponses_Legs_Merge_tmp (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare,legDateTime,
		airGroupId,airLegNumber,airPriceLowest_Basic,airPriceTaxLowest_Basic,airPriceLowest_Main_L,airPriceTaxLowest_Main_L,airPriceLowest_Main_R,airPriceTaxLowest_Main_R,airPriceLowest_Business_L,
		airPriceTaxLowest_Business_L,airPriceLowest_Business_R,airPriceTaxLowest_Business_R,airPriceLowest_Select_L,airPriceTaxLowest_Select_L,airPriceLowest_Select_R,airPriceTaxLowest_Select_R,
		airPriceLowest_First_L,airPriceTaxLowest_First_L,airPriceLowest_First_R,airPriceTaxLowest_First_R,legAirport)
		(SELECT airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare,legDateTime,
		airGroupId,airLegNumber,airPriceLowest_Basic,airPriceTaxLowest_Basic,airPriceLowest_Main_L,airPriceTaxLowest_Main_L,airPriceLowest_Main_R,airPriceTaxLowest_Main_R,airPriceLowest_Business_L,
		airPriceTaxLowest_Business_L,airPriceLowest_Business_R,airPriceTaxLowest_Business_R,airPriceLowest_Select_L,airPriceTaxLowest_Select_L,airPriceLowest_Select_R,airPriceTaxLowest_Select_R,
		airPriceLowest_First_L,airPriceTaxLowest_First_L,airPriceLowest_First_R,airPriceTaxLowest_First_R,legAirport
		FROM #AllOneWayResponses_Leg1
		UNION 
		SELECT airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare,legDateTime,
		airGroupId,airLegNumber,airPriceLowest_Basic,airPriceTaxLowest_Basic,airPriceLowest_Main_L,airPriceTaxLowest_Main_L,airPriceLowest_Main_R,airPriceTaxLowest_Main_R,airPriceLowest_Business_L,
		airPriceTaxLowest_Business_L,airPriceLowest_Business_R,airPriceTaxLowest_Business_R,airPriceLowest_Select_L,airPriceTaxLowest_Select_L,airPriceLowest_Select_R,airPriceTaxLowest_Select_R,
		airPriceLowest_First_L,airPriceTaxLowest_First_L,airPriceLowest_First_R,airPriceTaxLowest_First_R,legAirport
		FROM #AllOneWayResponses_Leg2_1) 

		INSERT INTO #AllOneWayResponses_Legs_Merge (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare,legDateTime,
		airGroupId,airLegNumber,airPriceLowest_Basic,airPriceTaxLowest_Basic,airPriceLowest_Main_L,airPriceTaxLowest_Main_L,airPriceLowest_Main_R,airPriceTaxLowest_Main_R,airPriceLowest_Business_L,
		airPriceTaxLowest_Business_L,airPriceLowest_Business_R,airPriceTaxLowest_Business_R,airPriceLowest_Select_L,airPriceTaxLowest_Select_L,airPriceLowest_Select_R,airPriceTaxLowest_Select_R,
		airPriceLowest_First_L,airPriceTaxLowest_First_L,airPriceLowest_First_R,airPriceTaxLowest_First_R,legAirport)
		SELECT airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare,legDateTime,
		airGroupId,airLegNumber,airPriceLowest_Basic,airPriceTaxLowest_Basic,airPriceLowest_Main_L,airPriceTaxLowest_Main_L,airPriceLowest_Main_R,airPriceTaxLowest_Main_R,airPriceLowest_Business_L,
		airPriceTaxLowest_Business_L,airPriceLowest_Business_R,airPriceTaxLowest_Business_R,airPriceLowest_Select_L,airPriceTaxLowest_Select_L,airPriceLowest_Select_R,airPriceTaxLowest_Select_R,
		airPriceLowest_First_L,airPriceTaxLowest_First_L,airPriceLowest_First_R,airPriceTaxLowest_First_R,legAirport
		FROM #AllOneWayResponses_Legs_Merge_tmp
		order by legDateTime asc

		-- Delete Leg 2 which are not valid at all for Leg 1
		delete #AllOneWayResponses_Legs_Merge  
		FROM #AllOneWayResponses_Legs_Merge t,  
		(  
		SELECT  MIN(airOneIdent )  AS minIdent
		FROM #AllOneWayResponses_Legs_Merge m  
		where airLegNumber = 1
		) AS derived  
		WHERE t.airOneIdent < minIdent

		Create table #DataProcess
		(
			Row_id bigint identity(1,1),
			airOneIdent Bigint,
			airLegBrandName Varchar(25),
			isRefundable bit
		)

		Insert into #DataProcess(airOneIdent,airLegBrandName,isRefundable)

		select airOneIdent,airLegBrandName,isRefundable from #AllOneWayResponses_Legs_Merge
		where airlegnumber=1 

		Declare @airOneIdent bigint
		Declare @airPriceLowest Float 
		Declare @airPriceTaxLowest float
		Declare @Loop_Count_Merge Bigint =(Select Count(1) from #DataProcess)
		Declare @START_LOOP_Merge Bigint=1
		Declare @airLegBrandName_Merge Varchar(25)
		Declare @isRefundable_Merge bit 

		
		WHILE @START_LOOP_Merge<=@Loop_Count_Merge
		BEGIN
		Select @airOneIdent=airOneIdent,@airLegBrandName=airLegBrandName,@isRefundable=isRefundable , @airLegBrandName_CurrentLeg = airLegBrandName,@IsREfundable_CurrentLeg = isRefundable
		from #DataProcess where Row_id=@START_LOOP_Merge

		set @airPriceLowest=NUll
		SET @airPriceTaxLowest=NULL


		SELECT TOP 1 
		@airPriceLowest=CASE 
		WHEN leg1.airLegBrandName='Basic' and leg1.isRefundable=0 THEN
		 Leg2.airPriceLowest_Basic
		WHEN leg1.airLegBrandName='Main' and leg1.isRefundable=0 THEN
		Leg2.airPriceLowest_Main_L
		WHEN leg1.airLegBrandName='Main' and leg1.isRefundable=1 THEN
		Leg2.airPriceLowest_Main_R
		WHEN leg1.airLegBrandName='First' and leg1.isRefundable=0 THEN
		Leg2.airPriceLowest_First_L
		WHEN leg1.airLegBrandName='First' and leg1.isRefundable=1 THEN
		Leg2.airPriceLowest_First_R
		WHEN leg1.airLegBrandName='Select' and leg1.isRefundable=0 THEN
		Leg2.airPriceLowest_Select_L
		WHEN leg1.airLegBrandName='Select' and leg1.isRefundable=1 THEN
		Leg2.airPriceLowest_Select_R
		WHEN leg1.airLegBrandName='Business' and leg1.isRefundable=0 THEN
		Leg2.airPriceLowest_Business_L
		WHEN leg1.airLegBrandName='Business' and leg1.isRefundable=1 THEN
		Leg2.airPriceLowest_Business_R
		END,
		@airPriceTaxLowest=CASE 
		WHEN leg1.airLegBrandName='Basic' and leg1.isRefundable=0 THEN
		 Leg2.airPriceTaxLowest_Basic
		WHEN leg1.airLegBrandName='Main' and leg1.isRefundable=0 THEN
		Leg2.airPriceTaxLowest_Main_L
		WHEN leg1.airLegBrandName='Main' and leg1.isRefundable=1 THEN
		Leg2.airPriceTaxLowest_Main_R
		WHEN leg1.airLegBrandName='First' and leg1.isRefundable=0 THEN
		Leg2.airPriceTaxLowest_First_L
		WHEN leg1.airLegBrandName='First' and leg1.isRefundable=1 THEN
		Leg2.airPriceTaxLowest_First_R
		WHEN leg1.airLegBrandName='Select' and leg1.isRefundable=0 THEN
		Leg2.airPriceTaxLowest_Select_L
		WHEN leg1.airLegBrandName='Select' and leg1.isRefundable=1 THEN
		Leg2.airPriceTaxLowest_Select_R
		WHEN leg1.airLegBrandName='Business' and leg1.isRefundable=0 THEN
		Leg2.airPriceTaxLowest_Business_L
		WHEN leg1.airLegBrandName='Business' and leg1.isRefundable=1 THEN
		Leg2.airPriceTaxLowest_Business_R
		END
		from #AllOneWayResponses_Legs_Merge Leg1
		INNER JOIN #AllOneWayResponses_Legs_Merge Leg2
		ON  Leg1.gdsSourceKey=Leg2.gdsSourceKey and  Leg2.airOneIdent>@airOneIdent 
		and Datediff(minute,Leg1.legDateTime,Leg2.legDateTime) >=Case when Leg1.legAirport=Leg2.legAirport 
		THEN  @changeOverTimeinMinutes ELSE @changeOverTimeinMinutes_AlternateAirport END
		and leg2.airlegnumber=2 and Leg1.airlegnumber=1 
		where   Leg1.airOneIdent=@airOneIdent
		order by Leg2.airOneIdent

		IF (@airPriceLowest IS NOT NULL and @airPriceTaxLowest IS NOT NULL AND (@airPriceLowest + @airPriceTaxLowest <> 0))
		BEGIN
		update #AllOneWayResponses_Legs_Merge
		Set airOnePriceBase=@airPriceLowest + airOnePriceBase ,
			airOnePriceTax=@airPriceTaxLowest + airOnePriceTax,
			airOnePriceBaseDisplay = @airPriceLowest + airOnePriceBaseDisplay,
			airOnePriceTaxDisplay = @airPriceTaxLowest + airOnePriceTaxDisplay,
			airpriceTotal = @airPriceLowest + airOnePriceBase + @airPriceTaxLowest + airOnePriceTax,
			airOnePriceBaseTotal = @airPriceLowest + airOnePriceBaseTotal,
			airOnePriceTaxTotal = @airPriceTaxLowest + airOnePriceTaxTotal,
			otherLegprice = case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceLowest,0) else( isnull(@airPriceLowest ,0) + isnull(@airPriceTaxLowest,0) ) END,
			otherlegtax = @airPriceTaxLowest,
			isvalid=1
		Where airOneIdent=@airOneIdent
		END
		SET @START_LOOP_Merge=@START_LOOP_Merge+1

		END

		DELETE FROM #AllOneWayResponses_Legs_Merge
		where isValid = 0

	END

	IF ( @airRequestTypeKey = 1)   
	BEGIN   
		IF(@isMultiBrand = 1)
		BEGIN
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax ),n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
			FROM #NormalizedAirResponses n  WITH (NOLOCK) inner join #AirResponse resp  WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey =@airBundledRequest      and airlegnumber = @airRequestTypeKey    
			AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
			
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare)  
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax) ,n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable,1
			FROM #NormalizedAirResponses n  WITH (NOLOCK) inner join #AirResponse resp  WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey =@airMultiCabinBundledRequest      and airlegnumber = @airRequestTypeKey    
			AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
		
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax) ,n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
			From #NormalizedAirResponsesMultiBrand n  WITH (NOLOCK) inner join #AirResponseMultiBrand resp  WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey =@airBundledRequest      and airlegnumber = @airRequestTypeKey    
			and ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )
				
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable,isMultiCabinFare)  
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax) ,n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable,1
			From #NormalizedAirResponsesMultiBrand n  WITH (NOLOCK) inner join #AirResponseMultiBrand resp  WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey =@airMultiCabinBundledRequest      and airlegnumber = @airRequestTypeKey    
			and ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )

		END
		ELSE
		BEGIN
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName)  
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax) ,n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName
			From #NormalizedAirResponses n  WITH (NOLOCK) inner join #AirResponse resp  WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey =@airBundledRequest      and airlegnumber = @airRequestTypeKey    
			AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) 
		END
		
		--Published Fare
	    IF(@isMultiBrand = 1)
		BEGIN
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat, airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable ) 
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax) ,n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
			From #NormalizedAirResponses n  WITH (NOLOCK) inner join #AirResponse resp  WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey =@airPublishedFareRequest      and airlegnumber = @airRequestTypeKey    
			and ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) 
		
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat, airLegBrandName, airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable) 
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax) ,n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey, resp.refundable
			From #NormalizedAirResponsesMultiBrand n  WITH (NOLOCK) inner join #AirResponseMultiBrand resp  WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey =@airPublishedFareRequest      and airlegnumber = @airRequestTypeKey    
			and ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
		END
		ELSE
		BEGIN
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat, airLegBrandName ) 
			SELECT resp.airresponsekey, (airPriceBase   ),
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,(airPriceBase + airPriceTax) ,n.cabinclass    ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName
			From #NormalizedAirResponses n  WITH (NOLOCK) inner join #AirResponse resp  WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey =@airPublishedFareRequest      and airlegnumber = @airRequestTypeKey    
			and ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) 
		END
				
		--AgentWare Responses for WN
		IF(@airRequestType <> 1 AND @airRequestTypeKey != @isSameDayReturnOWLogicToApply AND @airRequestType <> 3)
		BEGIN
			IF (@isCabinUniquification = 0)
			BEGIN
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
				(airPriceBaseSenior + ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 12),0) ),
				(airPriceTaxSenior + ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 12),0)),
				(airPriceBaseChildren + ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 12),0) ),
				(airPriceTaxChildren + ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 12),0)),
				(airPriceBaseInfant + ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 12),0) ),
				(airPriceTaxInfant + ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 12),0)),
				(airPriceBaseYouth + ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 12),0) ),
				(airPriceTaxYouth + ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 12),0)),
				(AirPriceBaseTotal + ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 12),0) ),
				(AirPriceTaxTotal + ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 12),0)),
				(airPriceBaseDisplay + ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 12),0) ),
				(airPriceTaxDisplay + ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 12),0)),
				flightNumber,airlines,resp .airSubRequestKey ,
				(airPriceTax + ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 12),0)),
				(airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0)  )+(airPriceTax + ISNULL(( SELECT SUM(airpriceTax ) FROM @multiLegPrice where gdsSourceKey = 12),0)), 
				case when @isTotalPriceSort = 0 THEN  ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0) else( isnull((SELECT SUM(Airpricebase) FROM @multiLegPrice where gdsSourceKey = 12) ,0) + isnull(( SELECT SUM(airpriceTax ) FROM @multiLegPrice where gdsSourceKey = 12),0) ) END ,
				N.cabinclass ,isnull(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 12),0)  ,
				n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL((SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
				(airPriceTaxInfantWithSeat + ISNULL((SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12),0)),
				agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
				From NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey
				
				WHERE resp.airSubRequestKey = @airAgentWareWNRequest  and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )
				IF(@isMultiBrand = 1)
				BEGIN
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.airPriceBaseSenior + ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.airPriceTaxSenior + ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 12),0)),
					(resp.airPriceBaseChildren + ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.airPriceTaxChildren + ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 12),0)),
					(resp.airPriceBaseInfant + ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.airPriceTaxInfant + ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 12),0)),
					(resp.airPriceBaseYouth + ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.airPriceTaxYouth + ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 12),0)),
					(resp.AirPriceBaseTotal + ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.AirPriceTaxTotal + ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 12),0)),
					(resp.airPriceBaseDisplay + ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.airPriceTaxDisplay + ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 12),0)),
					flightNumber,airlines,resp .airSubRequestKey ,
					(resp.airPriceTax + ISNULL((SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0)),
					(resp.airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0)  )+(resp.airPriceTax + ISNULL	((SELECT SUM(airpriceTax ) FROM @multiLegPrice where gdsSourceKey = 12),0)), 
					case when @isTotalPriceSort = 0 THEN  ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0) 
						else( isnull((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12) ,0) + isnull(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0) ) END ,
					N.cabinclass ,	isnull(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0)  ,
					n.airLegConnections,
					(resp.airPriceBaseInfantWithSeat + ISNULL((SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12),0)  ),
					(resp.airPriceTaxInfantWithSeat + ISNULL((SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12),0)),
					AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					inner join AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					WHERE resp.airSubRequestKey = @airAgentWareWNRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )
				END
			END
			ELSE
			BEGIN
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey,(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				flightNumber,airlines,resp .airSubRequestKey ,
				(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
				(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0))  )+(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 12),0)) ),
				case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0)) else( isnull(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0)) + isnull(M.airPriceTax,ISNULL( (SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0)) ) END ,
				N.cabinclass ,isnull(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 12),0) ) ,
				n.airLegConnections,
				(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,(SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12))  ),
				(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,(SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12))),
				agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
				From NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey
				INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey =12 
				WHERE resp.airSubRequestKey = @airAgentWareWNRequest  and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )
				
				IF(@isMultiBrand = 1)
				BEGIN
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey,(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
					(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
					(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 12),0))),
					(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
					(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 12),0))),
					(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
					(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 12),0))),
					(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
					(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 12),0))),
					(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
					(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 12),0))),
					(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 12),0))  ),
					(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 12),0))),
					flightNumber,airlines,resp .airSubRequestKey ,
					(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL((SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0))),
					(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0))  )+(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL((SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0))), 
					case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0)) 
					else( isnull(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 12),0) ) + isnull(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0)) ) END ,
					N.cabinclass ,	ISNULL(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 12),0))  ,
					n.airLegConnections,
					(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,ISNULL((SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12),0))),
					(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,ISNULL((SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 12),0))),
					AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)
					inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					inner join AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 12 
					WHERE resp.airSubRequestKey = @airAgentWareWNRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )
				END
			END			
		END	
		
		--Travelfusion Responses
		IF(@airRequestType <> 1 AND @airRequestTypeKey != @isSameDayReturnOWLogicToApply AND @airRequestType <> 3)
		BEGIN
			IF (@isCabinUniquification = 0)
			BEGIN
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
				(airPriceBaseSenior + ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 19),0) ),
				(airPriceTaxSenior + ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 19),0)),
				(airPriceBaseChildren + ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 19),0) ),
				(airPriceTaxChildren + ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 19),0)),
				(airPriceBaseInfant + ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 19),0) ),
				(airPriceTaxInfant + ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 19),0)),
				(airPriceBaseYouth + ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 19),0) ),
				(airPriceTaxYouth + ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 19),0)),
				(AirPriceBaseTotal + ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 19),0) ),
				(AirPriceTaxTotal + ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 19),0)),
				(airPriceBaseDisplay + ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 19),0) ),
				(airPriceTaxDisplay + ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 19),0)),
				flightNumber,airlines,resp .airSubRequestKey ,
				(airPriceTax + ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 19),0)),
				(airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0)  )+(airPriceTax + ISNULL(( SELECT SUM(airpriceTax ) FROM @multiLegPrice where gdsSourceKey = 19),0)), 
				case when @isTotalPriceSort = 0 THEN  ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0) else( isnull((SELECT SUM(Airpricebase) FROM @multiLegPrice where gdsSourceKey = 19) ,0) + isnull(( SELECT SUM(airpriceTax ) FROM @multiLegPrice where gdsSourceKey = 19),0) ) END ,
				N.cabinclass ,isnull(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 19),0)  ,
				n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL((SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
				(airPriceTaxInfantWithSeat + ISNULL((SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19),0)),
				agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
				From NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey
				
				WHERE resp.airSubRequestKey = @airTravelfusionRequest  and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
				IF(@isMultiBrand = 1)
				BEGIN
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.airPriceBaseSenior + ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.airPriceTaxSenior + ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 19),0)),
					(resp.airPriceBaseChildren + ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.airPriceTaxChildren + ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 19),0)),
					(resp.airPriceBaseInfant + ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.airPriceTaxInfant + ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 19),0)),
					(resp.airPriceBaseYouth + ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.airPriceTaxYouth + ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 19),0)),
					(resp.AirPriceBaseTotal + ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.AirPriceTaxTotal + ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 19),0)),
					(resp.airPriceBaseDisplay + ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.airPriceTaxDisplay + ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 19),0)),
					flightNumber,airlines,resp .airSubRequestKey ,
					(resp.airPriceTax + ISNULL((SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0)),
					(resp.airPriceBase + ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0)  )+(resp.airPriceTax + ISNULL	((SELECT SUM(airpriceTax ) FROM @multiLegPrice where gdsSourceKey = 19),0)), 
					case when @isTotalPriceSort = 0 THEN  ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0) 
						else( isnull((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19) ,0) + isnull(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0) ) END ,
					N.cabinclass ,	isnull(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0)  ,
					n.airLegConnections,
					(resp.airPriceBaseInfantWithSeat + ISNULL((SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19),0)  ),
					(resp.airPriceTaxInfantWithSeat + ISNULL((SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19),0)),
					AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					inner join AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					WHERE resp.airSubRequestKey = @airTravelfusionRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
				END
			END
			ELSE
			BEGIN
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey,(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				flightNumber,airlines,resp .airSubRequestKey ,
				(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
				(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0))  )+(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 19),0)) ),
				case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0)) else( isnull(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0)) + isnull(M.airPriceTax,ISNULL( (SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0)) ) END ,
				N.cabinclass ,isnull(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax  FROM @multiLegPrice where gdsSourceKey = 19),0) ) ,
				n.airLegConnections,
				(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,(SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19))  ),
				(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,(SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19))),
				agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
				From NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey
				INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey =19 
				WHERE resp.airSubRequestKey = @airTravelfusionRequest  and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
								
				IF(@isMultiBrand = 1)
				BEGIN
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey,(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
					(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,ISNULL((SELECT TOP 1 AirpricebaseSenior FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
					(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,ISNULL((SELECT TOP 1 airPriceTaxSenior FROM @multiLegPrice where gdsSourceKey = 19),0))),
					(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,ISNULL((SELECT TOP 1 AirpricebaseChildren FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
					(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,ISNULL((SELECT TOP 1 airPriceTaxChildren FROM @multiLegPrice where gdsSourceKey = 19),0))),
					(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,ISNULL((SELECT TOP 1 AirpricebaseInfant FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
					(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,ISNULL((SELECT TOP 1 airPriceTaxInfant FROM @multiLegPrice where gdsSourceKey = 19),0))),
					(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,ISNULL((SELECT TOP 1 AirpricebaseYouth FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
					(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,ISNULL((SELECT TOP 1 airPriceTaxYouth FROM @multiLegPrice where gdsSourceKey = 19),0))),
					(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,ISNULL((SELECT TOP 1 AirPriceBaseTotal FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
					(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,ISNULL((SELECT TOP 1 AirPriceTaxTotal FROM @multiLegPrice where gdsSourceKey = 19),0))),
					(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,ISNULL((SELECT TOP 1 AirpricebaseDisplay FROM @multiLegPrice where gdsSourceKey = 19),0))  ),
					(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,ISNULL((SELECT TOP 1 airPriceTaxDisplay FROM @multiLegPrice where gdsSourceKey = 19),0))),
					flightNumber,airlines,resp .airSubRequestKey ,
					(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL((SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0))),
					(resp.airPriceBase + ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0))  )+(resp.airPriceTax + ISNULL(M.airPriceTax,ISNULL((SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0))), 
					case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0)) 
					else( isnull(M.airPriceBase,ISNULL((SELECT TOP 1 Airpricebase FROM @multiLegPrice where gdsSourceKey = 19),0) ) + isnull(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0)) ) END ,
					N.cabinclass ,	ISNULL(M.airPriceTax,ISNULL(( SELECT TOP 1 airpriceTax FROM @multiLegPrice where gdsSourceKey = 19),0))  ,
					n.airLegConnections,
					(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,ISNULL((SELECT TOP 1 airPriceBaseInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19),0))),
					(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,ISNULL((SELECT TOP 1 airPriceTaxInfantWithSeat FROM @multiLegPrice where gdsSourceKey = 19),0))),
					AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2) ,resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)
					inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					inner join AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 19 
					WHERE resp.airSubRequestKey = @airTravelfusionRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
				END
			END			
		END

		/***Delete responses which are not available in respective one way responses AS fare buckets are applicable for one way logic  **/   
		--IF ( @airBundledRequest is not null )   
		--BEGIN   
		--IF (SELECT COUNT(*)   From #NormalizedAirResponses  WITH (NOLOCK) WHERE airsubrequestkey = @airSubRequestKey ) > 0   
		--	delete FROM #AllOneWayResponses WHERE airOneResponsekey in (  
		--	SELECT n.airresponsekey From #NormalizedAirResponses n  WITH (NOLOCK) 
		--	INNER JOIN #AirResponse resp  WITH (NOLOCK) ON n.airresponsekey =resp.airResponseKey   
		--	WHERE resp.airsubrequestkey = @airBundledRequest AND resp.gdsSourceKey = 2  AND airLegNumber =@airRequestTypeKey AND flightNumber not in (  
		--	SELECT flightNumber From #NormalizedAirResponses WITH (NOLOCK)WHERE airsubrequestkey = @airSubRequestKey))   
		--END   
	/***Delete all other airlines other than filter airlines**/ 
	 
		IF @gdssourcekey = 9   
		BEGIN   
		IF(@airLines <> 'Multiple Airlines')  
		BEGIN  
			DELETE FROM #AllOneWayResponses WHERE airOneResponsekey in (  
			SELECT DISTINCT seg.airResponseKey   FROM #AirSegments seg  WITH (NOLOCK) INNER JOIN #AirResponse  resp  WITH (NOLOCK) ON seg .airResponseKey = resp.airresponsekey   
			INNER JOIN #AirSubRequest subrequest  WITH (NOLOCK) ON resp.airSubRequestKey = subrequest .airSubRequestKey and seg.airSegmentMarketingAirlineCode not in (select * From @tmpAirline )   
			WHERE gdsSourceKey = @gdssourcekey  AND airLegNumber =@airRequestTypeKey)   
		END  
		END   

		INSERT @secondLegDetails ( otherlegsAirlinesCount ,responsekey ,otherLegAirlines )
		SELECT COUNT(DISTINCT airSegmentMarketingAirlineCode) , seg.airResponseKey ,
		( CASE WHEN (COUNT(DISTINCT airSegmentMarketingAirlineCode))> 1 THEN 'Multiple Airlines' ELSE 
		MIN (airSegmentMarketingAirlineCode ) END ) From #AirSegments seg WITH (NOLOCK)  INNER JOIN #AirResponse r WITH ( NOLOCK)
		ON seg.airResponseKey = r.airResponseKey where ( airSubRequestKey =@airBundledRequest OR airSubRequestKey =@airPublishedFareRequest OR airSubRequestKey =@airAgentWareWNRequest OR airSubRequestKey =@airTravelfusionRequest OR airSubRequestKey = @airMultiCabinBundledRequest  )  and airLegNumber = 2
		GROUP BY seg.airResponseKey 

	END   
	ELSE  
	BEGIN    
	DECLARE @isPure AS int   
	SET  @isPure =(SELECT count(distinct airSegmentMarketingAirlineCode) FROM #AirSegments WITH (NOLOCK) WHERE airresponsekey =@SELECTedResponseKey)   
	DECLARE @valid AS TABLE ( airResponsekey uniqueidentifier )   
	DECLARE @tmp_Valid AS TABLE ( airResponsekey uniqueidentifier )
	DECLARE @tmp_Valid_MultiBrand AS TABLE ( airResponseMultiBrandkey uniqueidentifier )
	DECLARE @valid_Merged AS TABLE ( airResponsekey uniqueidentifier )  
	
	SET @gdssourcekey = ( SELECT distinct gdssourcekey FROM #AirResponse  WITH (NOLOCK)WHERE airResponseKey = @SELECTedResponseKey )           

    IF (SELECT COUNT(responsekey) FROM @SELECTedResponse SELECTed INNER JOIN #AirResponse resp  WITH (NOLOCK) ON SELECTed .responsekey = resp.airResponseKey WHERE gdsSourceKey = 9 )   = 0   
	BEGIN  
	IF ( @SELECTedFareType = '') /*No bucket SELECTed */  
	BEGIN  
	INSERT @valid ( airResponsekey ) 
	( SELECT * FROM ufn_GetValidResponsesForMultiCity  (@airRequestTypeKey  ,@airBundledRequest   , @SELECTedResponseKey   ,@SELECTedResponseKeySecond   ,@SELECTedResponseKeyThird   ,@SELECTedResponseKeyFourth ,@SelectedResponseKeyFifth  ))  
	END   
	END 
		IF(@isMultiBrand = 1)
		BEGIN
			/****** Ashima: Delete From @valid whose RT fare is less than Selected Upsell Fare *******************/
			IF(@isCabinUniquification = 0)
			BEGIN
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass ,legConnections ,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.AirResponsekey, (airPriceBase    ) ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,N.flightNumber ,N.airlines,resp.airSubRequestKey,airPriceTax ,airPriceBase + airPriceTax ,n.cabinclass ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
				FROM #AirResponse resp  WITH (NOLOCK) 
				INNER JOIN #NormalizedAirResponses n  WITH (NOLOCK) ON resp.airresponsekey = n.airresponsekey  
				INNER JOIN @valid valid ON resp.airResponseKey = valid .airResponsekey  
				AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) AND N .airLegNumber = @airRequestTypeKey  
	
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass ,legConnections ,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.AirResponsekey, (airPriceBase    ) ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,N.flightNumber ,N.airlines,resp.airSubRequestKey,airPriceTax ,airPriceBase + airPriceTax ,n.cabinclass ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,resp.airresponseMultiBrandkey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
				FROM #AirResponseMultiBrand resp  WITH (NOLOCK) 
				INNER JOIN #NormalizedAirResponsesMultiBrand n  WITH (NOLOCK) ON resp.airResponseMultiBrandKey = n.airresponseMultiBrandkey  
				INNER JOIN @valid valid ON resp.airResponseKey = valid .airResponsekey  
				AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) AND N .airLegNumber = @airRequestTypeKey  
					
				INSERT @secondLegDetails ( otherlegsAirlinesCount ,responsekey ,otherLegAirlines )
				select COUNT(distinct airSegmentMarketingAirlineCode) , seg.airResponseKey ,
				( CASE WHEN (COUNT(distinct airSegmentMarketingAirlineCode))> 1 then 'Multiple Airlines' else 
				MIN (airSegmentMarketingAirlineCode ) END ) From #AirSegments seg WITH (NOLOCK) inner join #AirResponse r WITH (NOLOCK) on seg.airResponseKey = r.airResponseKey
				INNER JOIN @valid V on r.airResponseKey = v.airResponsekey     WHERE airLegNumber = 1
				group by seg.airResponseKey
			END
			ELSE
			BEGIN
				IF(@airRequestTypeKey = 2)
				BEGIN
					 INSERT @tmp_Valid(airResponsekey)
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 
					 INSERT @tmp_Valid_MultiBrand(airResponseMultiBrandkey)
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
				END
				IF(@airRequestTypeKey = 3)
				BEGIN
				
					INSERT @tmp_Valid(airResponsekey)
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)

					 INSERT @tmp_Valid_MultiBrand(airResponseMultiBrandkey)
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)
				END

				IF(@airRequestTypeKey = 4)
				BEGIN
					INSERT @tmp_Valid(airResponsekey)
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 3 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Third)


					 INSERT @tmp_Valid_MultiBrand(airResponseMultiBrandkey)
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 3 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Third)

				END

				IF(@airRequestTypeKey = 5)
				BEGIN
					INSERT @tmp_Valid(airResponsekey)
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 3 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Third)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 4 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Fourth)

					 INSERT @tmp_Valid_MultiBrand(airResponseMultiBrandkey)
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 3 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Third)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 4 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Fourth)

				END
				
				IF(@airRequestTypeKey = 6)
				BEGIN
					INSERT @tmp_Valid(airResponsekey)
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 3 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Third)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 4 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Fourth)
					 INTERSECT
					 SELECT valid.airResponsekey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponses NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 5 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Fifth)

					 INSERT @tmp_Valid_MultiBrand(airResponseMultiBrandkey)
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 1 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 2 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Second)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 3 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Third)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 4 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Fourth)
					 INTERSECT
					 SELECT NAR.airresponseMultiBrandkey 
					 from @valid valid
					 INNER JOIN #NormalizedAirResponsesMultiBrand NAR
					 ON valid.airResponsekey = NAR.airresponsekey
					 WHERE NAR.airLegNumber = 5 AND LOWER(NAR.airLegBrandName) = LOWER(@airLegBrandName_Fifth)
				END 

				IF(@IsREfundable_CurrentLeg = 1)
				BEGIN
					DELETE M
					FROM @tmp_Valid M 
					INNER JOIN #AirResponse T on M.airResponsekey = T.airResponseKey
					where T.refundable = 0

					DELETE M
					FROM @tmp_Valid_MultiBrand M 
					INNER JOIN #AirResponseMultiBrand T on M.airResponseMultiBrandkey = T.airresponsemultibrandkey
					where T.refundable = 0
				END
				
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass ,legConnections ,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.AirResponsekey, (airPriceBase    ) ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,N.flightNumber ,N.airlines,resp.airSubRequestKey,airPriceTax ,airPriceBase + airPriceTax ,n.cabinclass ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
				FROM #AirResponse resp  WITH (NOLOCK) 
				INNER JOIN #NormalizedAirResponses n  WITH (NOLOCK) ON resp.airresponsekey = n.airresponsekey  
				INNER JOIN @tmp_Valid valid ON resp.airResponseKey = valid .airResponsekey  
				AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) AND N .airLegNumber = @airRequestTypeKey  

				
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass ,legConnections ,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.AirResponsekey, (airPriceBase    ) ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,N.flightNumber ,N.airlines,resp.airSubRequestKey,airPriceTax ,airPriceBase + airPriceTax ,n.cabinclass ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName,n.airLegBookingClasses,resp.airresponseMultiBrandkey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
				FROM #AirResponseMultiBrand resp  WITH (NOLOCK) 
				INNER JOIN #NormalizedAirResponsesMultiBrand n  WITH (NOLOCK) ON resp.airResponseMultiBrandKey = n.airresponseMultiBrandkey  
				INNER JOIN @tmp_Valid_MultiBrand valid ON resp.airResponseMultiBrandKey = valid .airResponseMultiBrandkey  
				AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) AND N .airLegNumber = @airRequestTypeKey  


				INSERT INTO @valid_Merged
				SELECT airResponsekey
				FROM
				(
				SELECT airResponsekey FROM @tmp_Valid
				UNIOn ALL
				SELECT DISTINCT(AMR.airResponseKey)
				FROM @tmp_Valid_MultiBrand TM
				INNER JOIN #AirResponseMultiBrand AMR
				ON TM.airResponseMultiBrandkey = AMR.airResponseMultiBrandKey
				) A	
							
				INSERT @secondLegDetails ( otherlegsAirlinesCount ,responsekey ,otherLegAirlines )
				select COUNT(distinct airSegmentMarketingAirlineCode) , seg.airResponseKey ,
				( CASE WHEN (COUNT(distinct airSegmentMarketingAirlineCode))> 1 then 'Multiple Airlines' else 
				MIN (airSegmentMarketingAirlineCode ) END ) From #AirSegments seg WITH (NOLOCK) inner join #AirResponse r WITH (NOLOCK) on seg.airResponseKey = r.airResponseKey
				INNER JOIN @valid_Merged V on r.airResponseKey = v.airResponsekey     WHERE airLegNumber = 1
				group by seg.airResponseKey

			END
		END
		ELSE
		BEGIN 
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass ,legConnections ,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName)  
			SELECT distinct resp.AirResponsekey, (airPriceBase    ) ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,N.flightNumber ,N.airlines,resp.airSubRequestKey,airPriceTax ,airPriceBase + airPriceTax ,n.cabinclass ,n.airLegConnections ,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,n.airLegBrandName
			FROM #AirResponse resp  WITH (NOLOCK) 
			INNER JOIN #NormalizedAirResponses n  WITH (NOLOCK) ON resp.airresponsekey = n.airresponsekey  
			INNER JOIN @valid valid ON resp.airResponseKey = valid .airResponsekey  
			AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) AND N .airLegNumber = @airRequestTypeKey  
			
			INSERT @secondLegDetails ( otherlegsAirlinesCount ,responsekey ,otherLegAirlines )
		select COUNT(distinct airSegmentMarketingAirlineCode) , seg.airResponseKey ,
		( CASE WHEN (COUNT(distinct airSegmentMarketingAirlineCode))> 1 then 'Multiple Airlines' else 
		MIN (airSegmentMarketingAirlineCode ) END ) From #AirSegments seg WITH (NOLOCK) inner join #AirResponse r WITH (NOLOCK) on seg.airResponseKey = r.airResponseKey
		INNER JOIN @valid V on r.airResponseKey = v.airResponsekey     WHERE airLegNumber = 1
		group by seg.airResponseKey
		END

	END   

	/***getting valid one ways ***/  
	DECLARE @noOfLegsForRequest AS int   
	SET @noOfLegsForRequest =( SELECT COUNT(*) FROM #AirSubRequest WITH(NOLOCK) WHERE airSubRequestLegIndex > 0 )   

	DECLARE @validOneWays AS bit = 1   

	IF  @noOfLegsForRequest > 1   
	BEGIN  
	IF ( @airRequestTypeKey > 1 )  
	BEGIN    
	IF ( SELECT COUNT (*) FROM @SELECTedResponse ) = @airRequestTypeKey -1   
	BEGIN   
	SET @validOneWays = 1  
	END   
	ELSE    
	BEGIN  
	SET @validOneWays = 0   
	END   
	END   
	END   
	
	/***END  valid one ways ***/  
	DECLARE @selectedgroupKey AS INT 
	SELECT @selectedgroupKey= groupKey  FROM #AirSubRequest Sub WITH (NOLOCK) INNER JOIN #AirResponse AR WITH (NOLOCK) on sub.airSubRequestKey = AR.airSubRequestKey WHERE AR.airResponseKey = @SelectedResponseKey  

	IF ( @validOneWays =1 AND @airRequestType <> 3) /**checking for all leg one way prices are available*/  
	BEGIN   
	IF ( @airRequestTypeKey = 1 )   
	BEGIN
	     IF (@isCabinUniquification = 0 OR @airRequestType = 1)
	     BEGIN
			IF(@isMultiBrand = 1)
				BEGIN 
					-- OW fares with Imput Paramter in  AirSubRequestKey
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
					(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
					(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
					(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
					(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
					(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
					(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
					flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
					(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
					(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
					From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   
					and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
					
					-- OW fares with Imput Paramter in  AirSubRequestKey MultiBrandFares
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
					(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
					(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
					(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
					(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
					(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
					(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
					flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
					(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
					(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
					From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey = @airSubRequestKey   
					and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
					
					-- OW fares with Imput Paramter in MC Request
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
					SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
					(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
					(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
					(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
					(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
					(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
					(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
					flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
					(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
					(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,1,resp.refundable
					From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airMultiCabinRequest   
					and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
					
				    -- OW fares with Imput Paramter in MC Request MultiBrandFares
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
					SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
					(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
					(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
					(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
					(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
					(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
					(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
					flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
					(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
					(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,1 ,resp.refundable
					From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey = @airMultiCabinRequest   
					and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
				END
				ELSE
				BEGIN 
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName)  
					SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
					(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
					(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
					(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
					(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
					(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
					(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
					flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
					(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
					(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName
					From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   
					and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
				END
			IF ( @airRequestType =1  ) 
			BEGIN
			IF(@isMultiBrand = 1)
			BEGIN 
			-- Published Fare Normal Fares
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
				(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airPublishedFareRequest    
				and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
				
				-- Published Fare MultiBrand Fares
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
				(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey = @airPublishedFareRequest    
				and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
			END
			ELSE
			BEGIN 
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
				(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName
				From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airPublishedFareRequest    
				and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 
			END
		    END     
		  --Insert Responses for AgentWare
		    IF ( @airRequestType =1  ) 
	  		BEGIN 
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
				(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey
				WHERE resp.airSubRequestKey = @airAgentWareWNRequest and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )
				
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
				(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey
				WHERE resp.airSubRequestKey = @airTravelfusionRequest and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
					
				IF(@isMultiBrand = 1)
				BEGIN 
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
					(resp.airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(resp.airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
					(resp.airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(resp.airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
					(resp.airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(resp.airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
					(resp.airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(resp.airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
					(resp.AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(resp.AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
					(resp.airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(resp.airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
					flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(resp.airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(resp.airPriceTax + ISNULL
					(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
					(resp.airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					inner join AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					WHERE resp.airSubRequestKey = @airAgentWareWNRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )
					
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
					(resp.airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(resp.airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
					(resp.airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(resp.airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
					(resp.airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(resp.airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
					(resp.airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(resp.airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
					(resp.AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(resp.AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
					(resp.airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(resp.airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
					flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(resp.airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(resp.airPriceTax + ISNULL
					(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
					(resp.airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					inner join AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					WHERE resp.airSubRequestKey = @airTravelfusionRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
				END
			END		     
		 END	
	     ELSE
	     BEGIN
         --OW Insert 
	        IF(@isMultiBrand = 1 AND @isSameDayReturnOWLogicToApply = 0)
				BEGIN 
					IF (@isAirlineUniquification = 0)
					BEGIN
						INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
						SELECT resp.airresponsekey, 
						(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)),
						(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)  ),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
						(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg) ),(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
						(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg) ),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
						(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg) ),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
						(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)  ),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
						(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg) ),(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
						flightNumber,airlines,resp.airSubRequestKey,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)+resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( isnull(M.airPriceBase ,@airPriceForAnotherLeg) + isnull(M.airPriceTax,@airPriceTaxForAnotherLeg) ) END ,N.cabinclass ,isnull(M.airPriceTax,@airPriceTaxForAnotherLeg)  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)),
						(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,0)),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
						From #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
						WHERE resp.airSubRequestKey = @airSubRequestKey   
						AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
					END
					ELSE
					BEGIN
					  INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
						SELECT resp.airresponsekey, 
						(resp.airPriceBase + M.airPriceBase),
						(resp.airPriceBaseSenior + M.airPriceBaseSenior),(resp.airPriceTaxSenior + M.airPriceTaxSenior),
						(resp.airPriceBaseChildren + M.airPriceBaseChildren),(resp.airPriceTaxChildren + M.airPriceTaxChildren),
						(resp.airPriceBaseInfant + M.airPriceBaseInfant),(resp.airPriceTaxInfant + M.airPriceTaxInfant),
						(resp.airPriceBaseYouth + M.airPriceBaseYouth),(resp.airPriceTaxYouth + M.airPriceTaxYouth),
						(resp.AirPriceBaseTotal + M.AirPriceBaseTotal ),(resp.AirPriceTaxTotal + M.AirPriceTaxTotal),
						(resp.airPriceBaseDisplay + M.airPriceBaseDisplay),(resp.airPriceTaxDisplay + M.airPriceTaxDisplay),
						flightNumber,airlines,resp.airSubRequestKey,(resp.airPriceTax + M.airPriceTax),(resp.airPriceBase + M.airPriceBase + resp.airPriceTax + M.airPriceTax), 
						case when @isTotalPriceSort = 0 THEN  M.airPriceBase else ( M.airPriceBase  + M.airPriceTax ) END ,N.cabinclass , M.airPriceTax  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + M.airPriceBaseInfantWithSeat),
						(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,0)),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
						From #NormalizedAirResponses n WITH (NOLOCK)
						INNER JOIN #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 AND M.airlineCode = n.airlineCode
						WHERE resp.airSubRequestKey = @airSubRequestKey   
						AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )

					END
                    
             		IF (@isAirlineUniquification = 0)
					BEGIN
						INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
						SELECT resp.airresponsekey, (resp.airPriceBase + M.airPriceBase),
						(resp.airPriceBaseSenior + M.airPriceBaseSenior),(resp.airPriceTaxSenior + M.airPriceTaxSenior),
						(resp.airPriceBaseChildren + M.airPriceBaseChildren),(resp.airPriceTaxChildren + M.airPriceTaxChildren),
						(resp.airPriceBaseInfant + M.airPriceBaseInfant),(resp.airPriceTaxInfant + M.airPriceTaxInfant),
						(resp.airPriceBaseYouth + M.airPriceBaseYouth),(resp.airPriceTaxYouth + M.airPriceTaxYouth),
						(resp.AirPriceBaseTotal + M.AirPriceBaseTotal),(resp.AirPriceTaxTotal + M.AirPriceTaxTotal),
						(resp.airPriceBaseDisplay + M.airPriceBaseDisplay),(resp.airPriceTaxDisplay + M.airPriceTaxDisplay),
						flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + M.airPriceTax),(resp.airPriceBase + M.airPriceBase)+(resp.airPriceTax + M.airPriceTax), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( isnull(M.airPriceBase,@airPriceForAnotherLeg) + isnull(M.airPriceTax,@airPriceTaxForAnotherLeg)) END ,N.cabinclass ,M.airPriceTax  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + M.airPriceBaseInfantWithSeat),(resp.airPriceTaxInfantWithSeat + M.airPriceTaxInfantWithSeat),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
						FROM #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)
						INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
						WHERE resp.airSubRequestKey = @airSubRequestKey AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
					END
					ELSE
					BEGIN
						INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
						SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)),
						(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
						(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg)),(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
						(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg)),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
						(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg)),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
						(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
						(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg)),(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
						flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  )+(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( isnull(M.airPriceBase,@airPriceForAnotherLeg) + isnull(M.airPriceTax,@airPriceTaxForAnotherLeg)) END ,N.cabinclass ,isnull(M.airPriceTax,@airPriceTaxForAnotherLeg)  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,@airPriceTaxInfantWithSeatForAnotherLeg)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,resp.refundable
						FROM #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)
						INNER JOIN #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 AND M.airlineCode = n.airlineCode
						WHERE resp.airSubRequestKey = @airSubRequestKey AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
					END

					IF (@isAirlineUniquification = 0)
					BEGIN
						INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
						SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)),
						(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)  ),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
						(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg)  ),(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
						(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg)  ),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
						(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg)  ),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
						(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)  ),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
						(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg)  ),(resp.airPriceTaxDisplay + ISNULL(M.airpricetaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
						flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceTax + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  )+(resp.airPriceTax + ISNULL
						(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( isnull(M.airPriceBase,@airPriceForAnotherLeg) + isnull(M.airPriceTax,@airPriceTaxForAnotherLeg) ) END ,N.cabinclass ,isnull(M.airPriceTax,@airPriceTaxForAnotherLeg)  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,@airPriceTaxInfantWithSeatForAnotherLeg)),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,1,resp.refundable
						FROM #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
						WHERE resp.airSubRequestKey = @airMultiCabinRequest   
						AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
					END
					ELSE
					BEGIN
						INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
						SELECT resp.airresponsekey, (resp.airPriceBase + M.airPriceBase),
						(resp.airPriceBaseSenior + M.airPriceBaseSenior),(resp.airPriceTaxSenior + M.airPriceTaxSenior),
						(resp.airPriceBaseChildren + M.airPriceBaseChildren),(resp.airPriceTaxChildren + M.airPriceTaxChildren),
						(resp.airPriceBaseInfant + M.airPriceBaseInfant),(resp.airPriceTaxInfant + M.airPriceTaxInfant),
						(resp.airPriceBaseYouth + M.airPriceBaseYouth),(resp.airPriceTaxYouth + M.airPriceTaxYouth),
						(resp.AirPriceBaseTotal + M.AirPriceBaseTotal),(resp.AirPriceTaxTotal + M.AirPriceTaxTotal),
						(resp.airPriceBaseDisplay + M.airPriceBaseDisplay),(resp.airPriceTaxDisplay + M.airpricetaxDisplay),
						flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + M.airPriceTax),(resp.airPriceTax + M.airPriceBase)+(resp.airPriceTax +
						M.airPriceTax), case when @isTotalPriceSort = 0 THEN  M.airPriceBase else ( M.airPriceBase + M.airPriceTax) END ,N.cabinclass ,M.airPriceTax  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + M.airPriceBaseInfantWithSeat),(resp.airPriceTaxInfantWithSeat + M.airPriceTaxInfantWithSeat),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,1,resp.refundable
						FROM #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 AND M.airlineCode = n.airlineCode
						WHERE resp.airSubRequestKey = @airMultiCabinRequest   
						AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
					END

					IF (@isAirlineUniquification = 0)
					BEGIN
						INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
						SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  ),
						(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)  ),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
						(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg)  ),(resp.airPriceTaxChildren + ISNULL(M. airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
						(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg)  ),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
						(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg)  ),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
						(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)  ),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
						(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg)  ),(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
						flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  )+(resp.airPriceTax + ISNULL
						(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( isnull(M.airPriceBase,@airPriceForAnotherLeg) + isnull(M.airPriceTax,@airPriceTaxForAnotherLeg) ) END ,N.cabinclass ,ISNULL(M.airPriceTax, @airPriceTaxForAnotherLeg)  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,@airPriceTaxInfantWithSeatForAnotherLeg)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,1 ,resp.refundable
						FROM #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
						WHERE resp.airSubRequestKey = @airMultiCabinRequest   
						AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
					END
					ELSE
					BEGIN
						INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
						SELECT resp.airresponsekey, (resp.airPriceBase + M.airPriceBase),
						(resp.airPriceBaseSenior + M.airPriceBaseSenior),(resp.airPriceTaxSenior + M.airPriceTaxSenior),
						(resp.airPriceBaseChildren + M.airPriceBaseChildren),(resp.airPriceTaxChildren + M.airPriceTaxChildren),
						(resp.airPriceBaseInfant + M.airPriceBaseInfant),(resp.airPriceTaxInfant + M.airPriceTaxInfant),
						(resp.airPriceBaseYouth + M.airPriceBaseYouth),(resp.airPriceTaxYouth + M.airPriceTaxYouth),
						(resp.AirPriceBaseTotal + M.AirPriceBaseTotal),(resp.AirPriceTaxTotal + M.AirPriceTaxTotal),
						(resp.airPriceBaseDisplay + M.airPriceBaseDisplay),(resp.airPriceTaxDisplay + M.airPriceTaxDisplay),
						flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + M.airPriceTax),(resp.airPriceBase + M.airPriceBase )+(resp.airPriceTax + 
						M.airPriceTax), case when @isTotalPriceSort = 0 THEN  M.airPriceBase else ( M.airPriceBase + M.airPriceTax) END ,N.cabinclass ,M.airPriceTax  ,n.airLegConnections,
						(resp.airPriceBaseInfantWithSeat + M.airPriceBaseInfantWithSeat),(resp.airPriceTaxInfantWithSeat + M.airPriceTaxInfantWithSeat),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.AirResponsekey,1 ,resp.refundable
						FROM #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
						INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 AND M.airlineCode = n.airlineCode
						WHERE resp.airSubRequestKey = @airMultiCabinRequest   
						AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
					END
				END
				ELSE IF (@isMultiBrand = 1 AND @isSameDayReturnOWLogicToApply = 1)
				BEGIN
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airResponseMultiBrandkey,isMultiBrandFare,isMultiCabinFare,isValid) 
					SELECT airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass,otherlegtax,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable,airResponseMultiBrandKey,isMultiBrandFare,isMultiCabinFare,isValid
					FROM #AllOneWayResponses_Legs_Merge
					WHERE airLegNumber = 1
				END
				ELSE
				BEGIN 
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName)  
					SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  ),
					(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)  ),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
					(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg)  ),(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
					(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg)  ),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
					(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg)  ),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
					(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)  ),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
					(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg)  ),(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
					flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  )+(resp.airPriceTax + ISNULL
					(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( ISNULL(M.airPriceBase,@airPriceForAnotherLeg) + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg) ) END ,N.cabinclass ,isnull(M.airPriceTax,@airPriceTaxForAnotherLeg)  ,n.airLegConnections,
					(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,@airPriceTaxInfantWithSeatForAnotherLeg)),n.airLegBrandName
					FROM #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
					INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
					WHERE resp.airSubRequestKey = @airSubRequestKey   
					and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
				END
			IF ( @airRequestType =1  ) 
			BEGIN
			IF(@isMultiBrand = 1)
			BEGIN 
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  ),
				(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)  ),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
				(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg)  ),(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
				(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg)  ),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
				(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg)  ),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
				(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)  ),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
				(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg)  ),(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
				flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  )+(resp.airPriceTax + ISNULL
				(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( ISNULL(M.airPriceBase,@airPriceForAnotherLeg ) + ISNULL(M.airPriceTax, @airPriceTaxForAnotherLeg) ) END ,N.cabinclass ,ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)  ,n.airLegConnections,
				(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,@airPriceTaxInfantWithSeatForAnotherLeg)),n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				FROM #NormalizedAirResponses n WITH (NOLOCK)inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
				WHERE resp.airSubRequestKey = @airPublishedFareRequest    
				AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )
			
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  ),
				(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)  ),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
				(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg)  ),(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
				(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg)  ),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
				(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg)  ),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
				(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)  ),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
				(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg)  ),(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
				flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  )+(resp.airPriceTax + ISNULL
				(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase, @airPriceForAnotherLeg) else( ISNULL(M.airPriceBase,@airPriceForAnotherLeg) + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg) ) END ,N.cabinclass ,ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)  ,n.airLegConnections,
				(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,@airPriceTaxInfantWithSeatForAnotherLeg)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				FROM #NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
				INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
				WHERE resp.airSubRequestKey = @airPublishedFareRequest    
				AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
			END
			ELSE
			BEGIN 
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,airLegBrandName)  
				SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  ),
				(resp.airPriceBaseSenior + ISNULL(M.airPriceBaseSenior,@airPriceSeniorForAnotherLeg)  ),(resp.airPriceTaxSenior + ISNULL(M.airPriceTaxSenior,@airPriceTaxSeniorForAnotherLeg)),
				(resp.airPriceBaseChildren + ISNULL(M.airPriceBaseChildren,@airPriceChildrenForAnotherLeg)  ),(resp.airPriceTaxChildren + ISNULL(M.airPriceTaxChildren,@airPriceTaxChildrenForAnotherLeg)),
				(resp.airPriceBaseInfant + ISNULL(M.airPriceBaseInfant,@airPriceInfantForAnotherLeg)  ),(resp.airPriceTaxInfant + ISNULL(M.airPriceTaxInfant,@airPriceTaxInfantForAnotherLeg)),
				(resp.airPriceBaseYouth + ISNULL(M.airPriceBaseYouth,@airPriceYouthForAnotherLeg)  ),(resp.airPriceTaxYouth + ISNULL(M.airPriceTaxYouth,@airPriceTaxYouthForAnotherLeg)),
				(resp.AirPriceBaseTotal + ISNULL(M.AirPriceBaseTotal,@airPriceTotalForAnotherLeg)  ),(resp.AirPriceTaxTotal + ISNULL(M.AirPriceTaxTotal,@airPriceTaxTotalForAnotherLeg)),
				(resp.airPriceBaseDisplay + ISNULL(M.airPriceBaseDisplay,@airPriceDisplayForAnotherLeg)  ),(resp.airPriceTaxDisplay + ISNULL(M.airPriceTaxDisplay,@airPriceTaxDisplayForAnotherLeg)),
				flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)),(resp.airPriceBase + ISNULL(M.airPriceBase,@airPriceForAnotherLeg)  )+(resp.airPriceTax + ISNULL
				(M.airPriceTax,@airPriceTaxForAnotherLeg)), case when @isTotalPriceSort = 0 THEN  ISNULL(M.airPriceBase,@airPriceForAnotherLeg) else( ISNULL(M.airPriceBase,@airPriceForAnotherLeg) + ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg) ) END ,N.cabinclass ,ISNULL(M.airPriceTax,@airPriceTaxForAnotherLeg)  ,n.airLegConnections,
				(resp.airPriceBaseInfantWithSeat + ISNULL(M.airPriceBaseInfantWithSeat,@airPriceInfantWithSeatForAnotherLeg)  ),(resp.airPriceTaxInfantWithSeat + ISNULL(M.airPriceTaxInfantWithSeat,@airPriceTaxInfantWithSeatForAnotherLeg)),n.airLegBrandName
				FROM #NormalizedAirResponses n WITH (NOLOCK)
				INNER JOIN #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 2 
				WHERE resp.airSubRequestKey = @airPublishedFareRequest    
				AND ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) 
			END
		    END     
		  --Insert Responses for AgentWare
				
            IF ( @airRequestType =1  )
	  		BEGIN 
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, resp.airPriceBase ,
				resp.airPriceBaseSenior, resp.airPriceTaxSenior ,
				resp.airPriceBaseChildren ,resp.airPriceTaxChildren ,
				resp.airPriceBaseInfant ,resp.airPriceTaxInfant ,
				resp.airPriceBaseYouth ,resp.airPriceTaxYouth ,
				resp.AirPriceBaseTotal ,resp.AirPriceTaxTotal,
				resp.airPriceBaseDisplay,resp.airPriceTaxDisplay ,
				flightNumber,airlines,resp .airSubRequestKey ,resp.airPriceTax ,resp.airPriceBase +resp.airPriceTax , 
				0 ,N.cabinclass ,
				resp.airPriceTax  ,n.airLegConnections,
				resp.airPriceBaseInfantWithSeat ,resp.airPriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				FROM NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey
				WHERE resp.airSubRequestKey = @airAgentWareWNRequest and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )
				
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, resp.airPriceBase ,
				resp.airPriceBaseSenior, resp.airPriceTaxSenior ,
				resp.airPriceBaseChildren ,resp.airPriceTaxChildren ,
				resp.airPriceBaseInfant ,resp.airPriceTaxInfant ,
				resp.airPriceBaseYouth ,resp.airPriceTaxYouth ,
				resp.AirPriceBaseTotal ,resp.AirPriceTaxTotal,
				resp.airPriceBaseDisplay,resp.airPriceTaxDisplay ,
				flightNumber,airlines,resp .airSubRequestKey ,resp.airPriceTax ,resp.airPriceBase +resp.airPriceTax , 
				0 ,N.cabinclass ,
				resp.airPriceTax  ,n.airLegConnections,
				resp.airPriceBaseInfantWithSeat ,resp.airPriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,n.airLegBrandName,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				FROM NormalizedAirResponses n WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey 
				AND n.airlegNumber = @airRequestTypekey 
				WHERE resp.airSubRequestKey = @airTravelfusionRequest and airlegnumber = @airRequestTypeKey
				AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )

				IF(@isMultiBrand = 1)
				BEGIN 
					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, resp.airPriceBase,
					resp.airPriceBaseSenior ,resp.airPriceTaxSenior ,
					resp.airPriceBaseChildren ,resp.airPriceTaxChildren,
					resp.airPriceBaseInfant,resp.airPriceTaxInfant ,
					resp.airPriceBaseYouth,resp.airPriceTaxYouth,
					resp.AirPriceBaseTotal ,resp.AirPriceTaxTotal ,
					resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,
					flightNumber,airlines,resp .airSubRequestKey ,resp.airPriceTax ,(resp.airPriceBase + resp.airPriceTax) , 
					0,N.cabinclass ,0  ,n.airLegConnections,
					resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat,AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					INNER JOIN AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 12 
					WHERE resp.airSubRequestKey = @airAgentWareWNRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,12) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,12) ELSE 12 END )

					INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax ,legConnections ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName, airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
					SELECT resp.airresponsekey, resp.airPriceBase,
					resp.airPriceBaseSenior ,resp.airPriceTaxSenior ,
					resp.airPriceBaseChildren ,resp.airPriceTaxChildren,
					resp.airPriceBaseInfant,resp.airPriceTaxInfant ,
					resp.airPriceBaseYouth,resp.airPriceTaxYouth,
					resp.AirPriceBaseTotal ,resp.AirPriceTaxTotal ,
					resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,
					flightNumber,airlines,resp .airSubRequestKey ,resp.airPriceTax ,(resp.airPriceBase + resp.airPriceTax) ,
					0,N.cabinclass ,0  ,n.airLegConnections,
					resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat,AirRes.agentwareQueryID,AirRes.agentwareItineraryID,n.airLegBrandName, n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
					From NormalizedAirResponsesMultiBrand n WITH (NOLOCK)inner join AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey 
					INNER JOIN AirResponse AirRes  WITH (NOLOCK) on AirRes.airresponsekey = resp.airResponseKey
					AND n.airlegNumber = @airRequestTypekey
					INNER JOIN @multiLegPrice M ON M.airLegBrandName = n.airLegBrandName AND M.isRefundable = resp.refundable  AND M.gdsSourceKey = 19 
					WHERE resp.airSubRequestKey = @airTravelfusionRequest and airlegnumber = @airRequestTypeKey
					AND ISNULL(resp.gdsSourceKey,19) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,19) ELSE 19 END )
				END
			END		
	     END	
	END   
	ELSE   
	BEGIN   
		IF ( @airPriceForAnotherLeg is not null AND @airPriceForAnotherLeg > 0 AND (@airRequestType >= 2 )    )   
		BEGIN  
		update #AllOneWayResponses SET otherLegprice = case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,otherlegtax =isnull(@airPriceTaxForAnotherLeg,0
		)
		IF(@selectedgroupKey = 1 OR @selectedgroupKey = 5) 
		BEGIN
			IF(@isMultiBrand = 1)
			BEGIN 
			    -- Normal OW Fare
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
				airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
				(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
				(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
				(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
				(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
				(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
				(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
				(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From #NormalizedAirResponses n WITH (NOLOCK) inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   

				--MultiBrand OW Fare
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
				airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
				(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
				(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
				(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
				(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
				(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
				(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
				(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK) inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey = @airSubRequestKey 
				
				-- Normal MultiCabin Fare
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
				airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
				(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
				(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
				(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
				(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
				(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
				(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
				(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,1,resp.refundable
				From #NormalizedAirResponses n WITH (NOLOCK) inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airMultiCabinRequest   
				
				-- MultiBrand MultiCabin Fare
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
				airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isMultiCabinFare,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
				(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
				(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
				(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
				(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
				(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
				(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
				(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,1,resp.refundable
				From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK) inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey = @airMultiCabinRequest 

			END
			ELSE
			BEGIN 
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
				airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
				(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
				(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
				(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
				(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
				(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
				(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
				(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName
				From #NormalizedAirResponses n WITH (NOLOCK) inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   
			END

		END
		ELSE IF(@selectedgroupKey = 4) 
		BEGIN
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
			airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
			SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
			(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
			(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
			(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
			(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
			(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
			(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
			(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
			(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
			(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
			(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
			(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
			(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
			flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
			(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
			(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
			From #NormalizedAirResponses n WITH (NOLOCK) inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airAgentWareWNRequest   
			
			IF(@isMultiBrand = 1)
			BEGIN
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
				airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
				(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
				(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
				(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
				(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
				(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
				(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
				(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK) inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey = @airAgentWareWNRequest 

			END
		END
		ELSE IF(@selectedgroupKey = 7) 
		BEGIN
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
			airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName,airLegBookingClasses,gdsSourceKey,childResponsekey,isRefundable)  
			SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
			(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
			(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
			(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
			(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
			(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
			(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
			(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
			(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
			(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
			(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
			(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
			(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
			flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
			(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
			(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName,n.airLegBookingClasses,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
			From #NormalizedAirResponses n WITH (NOLOCK) inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airTravelfusionRequest   
			
			IF(@isMultiBrand = 1)
			BEGIN
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
				airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,airLegBrandName,airLegBookingClasses,airResponseMultiBrandKey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)  
				SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
				(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
				(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
				(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
				(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
				(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
				(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
				(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
				(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
				(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
				(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
				(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
				(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
				flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  ,n.airLegConnections,
				(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
				(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),n.airLegBrandName,n.airLegBookingClasses,resp.airResponseMultiBrandKey,1,ISNULL(resp.gdsSourceKey,2),resp.airresponsekey,resp.refundable
				From #NormalizedAirResponsesMultiBrand n WITH (NOLOCK) inner join #AirResponseMultiBrand resp WITH (NOLOCK) on n.airresponseMultiBrandkey = resp.airResponseMultiBrandKey WHERE resp.airSubRequestKey = @airTravelfusionRequest 
			
			END
		END
		END  
		ELSE IF    (@airRequestType=1  )  
		BEGIN   
		--------------- Ashima :Left this block for Basic Economy as Don't know how it will come to this point in Leg2
		update #AllOneWayResponses SET otherLegprice = case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,otherlegtax =isnull(@airPriceTaxForAnotherLeg,0)

		INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
		airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airLegBrandName )  
		SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ), 
		(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),
		(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
		(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),
		(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
		(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),
		(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
		(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),
		(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
		(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),
		(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)), 
		(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),
		(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
		flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0) ,n.airLegConnections ,
		(airPriceBaseInfantWithSeat + ISNULL(@airPriceInfantWithSeatForAnotherLeg,0)  ),
		(airPriceTaxInfantWithSeat + ISNULL(@airPriceTaxInfantWithSeatForAnotherLeg,0)),agentwareQueryID,agentwareItineraryID,n.airLegBrandName
		From #NormalizedAirResponses n WITH (NOLOCK) inner join #AirResponse resp WITH (NOLOCK) on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   
		END  
	END   
	END   
	IF @airRequestTypeKey > 1
	BEGIN 
		IF ( select COUNT (*) from  #AirSegments seg WITH (NOLOCK) inner join @SELECTedResponse s on seg.airResponseKey =s.responsekey and airSegmentMarketingAirlineCode ='WN' ) > 0    
		BEGIN   
			DELETE FROM #AllOneWayResponses WHERE airOneResponsekey in (Select distinct airresponsekey from  #AirSegments seg WITH (NOLOCK) inner join #AllOneWayResponses res on res.airOneResponsekey = seg.airResponseKey where seg.airSegmentMarketingAirlineCode <> 'WN')
		END   
		ELSE   
		BEGIN   
			IF (@SelectedResponseKey  IS NOT NULL AND @SelectedResponseKey <> '{00000000-0000-0000-0000-000000000000}')
			BEGIN  
				IF (SELECT COUNT(*) FROM #AirSegments S WITH (NOLOCK) INNER JOIN #AirResponse A on A.airResponseKey = S.airResponseKey AND A.airResponseKey = @SelectedResponseKey AND airSegmentMarketingAirlineCode ='WN' ) < 0
				BEGIN
					DELETE FROM #AllOneWayResponses WHERE airOneResponsekey in (Select distinct airresponsekey from  #AirSegments seg WITH (NOLOCK) inner join #AllOneWayResponses res on res.airOneResponsekey = seg.airResponseKey where seg.airSegmentMarketingAirlineCode = 'WN')
				END
			END				  
		END
	END	
	
 
	Delete P  
	FROM #AllOneWayResponses  P  
	INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey  
	
	IF(@isMultiBrand = 1)
	BEGIN
		Delete P  
		FROM #AllOneWayResponses  P  
		INNER JOIN @tempResponseToRemove_MultiBrand T  ON P.airResponseMultiBrandKey = T.airresponseMultiBrandkey 
		where P.airResponseMultiBrandKey IS NOT NULL AND P.isMultiBrandFare = 1
	END

	IF(@airrequesttype <> 3)
	BEGIN
		IF(@isMultiBrand = 1 AND @isCabinUniquification = 1)
		BEGIN
		-- Both the legs should have the same cabin
			DELETE #AllOneWayResponses  
			FROM #AllOneWayResponses t,
			(
			SELECT resp.airResponseKey
			FROM #NormalizedAirResponses resp
			WHERE resp.airresponsekey = (SELECT airresponsekey 
									  FROM NormalizedAirResponses N 
									  WHERE N.airresponsekey = resp.airresponsekey 
									  AND  N.airLegNumber = 2 
									  AND airsubrequestkey = @airBundledRequest 
									  AND resp.airLegBrandName <> N.airLegBrandName)
			AND resp.airLegNumber = 1
			AND resp.airsubrequestkey = @airBundledRequest 
			) AS derived
			WHERE t.airOneResponsekey = derived.airresponsekey
	
			-- Both the legs should have the same cabin
			DELETE #AllOneWayResponses  
			FROM #AllOneWayResponses t,
			(
			SELECT resp.airresponseMultiBrandkey
			FROM #NormalizedAirResponsesMultiBrand resp
			WHERE resp.airresponseMultiBrandkey = (SELECT airresponseMultiBrandkey 
									  FROM NormalizedAirResponsesMultiBrand N 
									  WHERE N.airresponseMultiBrandkey = resp.airresponseMultiBrandkey 
									  AND  N.airLegNumber = 2 
									  AND airsubrequestkey = @airBundledRequest 
									  AND resp.airLegBrandName <> N.airLegBrandName)
			AND resp.airLegNumber = 1
			AND resp.airsubrequestkey = @airBundledRequest 
			) AS derived
			WHERE t.airresponseMultiBrandkey = derived.airresponseMultiBrandkey
		
		END
	END

	IF (@isAirlineUniquification = 1 AND @airLines = 'Multiple Airlines' AND @airRequestTypeKey = 1)
		BEGIN

		DELETE #AllOneWayResponses  
		FROM #AllOneWayResponses t,
		(
		SELECT resp.airResponseKey
		FROM #NormalizedAirResponses resp
		WHERE resp.airresponsekey = (SELECT airresponsekey 
		                          FROM #NormalizedAirResponses N 
		                          WHERE N.airresponsekey = resp.airresponsekey 
		                          AND  N.airLegNumber = 2 
		                          AND (airsubrequestkey = @airBundledRequest OR airsubRequestkey = @airMultiCabinBundledRequest)
		                          AND N.airlineCode <> 'Multiple Airlines')
		AND resp.airLegNumber = 1
		AND (airsubrequestkey = @airBundledRequest OR airsubRequestkey = @airMultiCabinBundledRequest)
		) AS derived
		WHERE t.airOneResponsekey = derived.airresponsekey
		
		DELETE #AllOneWayResponses  
		FROM #AllOneWayResponses t,
		(
		SELECT resp.airresponseMultiBrandkey
		FROM #NormalizedAirResponsesMultiBrand resp
		WHERE resp.airresponseMultiBrandkey = (SELECT airresponseMultiBrandkey 
		                          FROM #NormalizedAirResponsesMultiBrand N 
		                          WHERE N.airresponseMultiBrandkey = resp.airresponseMultiBrandkey 
		                          AND  N.airLegNumber = 2 
		                          AND (airsubrequestkey = @airBundledRequest OR airsubRequestkey = @airMultiCabinBundledRequest)
		                          AND N.airlineCode <> 'Multiple Airlines')
		AND resp.airLegNumber = 1
		AND (airsubrequestkey = @airBundledRequest OR airsubRequestkey = @airMultiCabinBundledRequest)
		) AS derived
		WHERE t.airresponseMultiBrandkey = derived.airresponseMultiBrandkey
END

--Uniquification Logic start here

IF(@isMultiBrand = 1)
	BEGIN
		    IF (@airRequestTypeKey = 2 AND @isCabinUniquification = 0)
		    BEGIN
				DELETE P
				FROM #AllOneWayResponses P   
				WHERE (Round((airOnePriceBaseDisplay + airOnePriceTaxDisplay),2) < Round(@selectedRoundTripFare,2))
			END
			ELSE IF(@airRequestTypeKey = 2 AND @isCabinUniquification = 1)
			BEGIN
				DELETE P
				FROM #AllOneWayResponses P   
				WHERE (Round((airOnePriceBaseDisplay + airOnePriceTaxDisplay),2) < Round(@selectedRoundTripFare,2))
				AND P.airLegBrandName = @airLegBrandName_CurrentLeg
			END

			
			/****STEP 1 : BY ASHIMA : REMOVE DUPLICATION OF NORMAL FARES W.R.T MULTICABIN ****/
			DELETE #AllOneWayResponses  
			FROM #AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice, MIN(airOneIdent )  AS minIdent,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,airLegBrandName,isRefundable
			FROM #AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,airLegBrandName, isRefundable
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses = derived.airLegBookingClasses 
			AND (airOnePriceBase + airOnePriceTax) >  minPrice --AND airOneIdent > minIdent 
			and (t.airsubRequestkey = @airMultiCabinRequest OR t.airsubRequestkey = @airMultiCabinBundledRequest)

			delete #AllOneWayResponses  
			FROM #AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode ,airLegBrandName,airLegBookingClasses,isRefundable    
			FROM #AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode  , airLegBookingClasses,isRefundable   ,airLegBrandName
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses = derived.airLegBookingClasses
			AND t.isRefundable = derived.isRefundable AND t.airLegBrandName = derived.airLegBrandName
			AND (airOnePriceBase + airOnePriceTax) >  minPrice


			INSERT INTO @Temp_AllOneWayResponses(airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  ,legConnections,airOnePriceBaseInfantWithSeat, airOnePriceTaxInfantWithSeat,  airLegBrandName,airLegBookingClasses,airResponseMultiBrandkey,isMultiBrandFare,gdsSourceKey,childResponsekey,isRefundable)
			SELECT t.airOneResponsekey, t.airOnePriceBase ,t.airOnePriceBaseSenior,t.airOnePriceTaxSenior, t.airOnePriceBaseChildren ,t.airOnePriceTaxChildren ,t.airOnePriceBaseInfant, t.airOnePriceTaxInfant,t.airOnePriceBaseYouth, t.airOnePriceTaxYouth, t.airOnePriceBaseTotal, t.airOnePriceTaxTotal,t.airOnePriceBaseDisplay, t.airOnePriceTaxDisplay,t.airSegmentFlightNumber,t.airSegmentMarketingAirlineCode,t.airsubRequestkey,t.airOnePriceTax ,t.airpriceTotal ,t.cabinclass  ,t.legConnections,t.airOnePriceBaseInfantWithSeat, t.airOnePriceTaxInfantWithSeat,  t.airLegBrandName,t.airLegBookingClasses,t.airResponseMultiBrandkey,t.isMultiBrandFare,t.gdsSourceKey,t.childResponsekey,t.isRefundable
			FROM #AllOneWayResponses t,
			(
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode
			FROM #AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode   
			having count(1) > 1  
			) AS derived 
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode
			AND (airOnePriceBase + airOnePriceTax) >  minPrice order by t.airOneIdent


			/****KEEP ALL DUPLICATE WITH LOWEST PRICE AND DELETE HIGHER PRICE ****/
			delete #AllOneWayResponses  
			FROM #AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  --,airLegBookingClasses,isRefundable    
			FROM #AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode  --, airLegBookingClasses,isRefundable   
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
			AND (airOnePriceBase + airOnePriceTax) >  minPrice

			/****KEEP ONLY ONE LOWEST PRICE ,REMOVE ALL OTHER WITH SAME PRICE ****/
			delete #AllOneWayResponses  
			FROM #AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName  --,isRefundable    
			FROM #AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName  --,isRefundable    
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
			AND airOneIdent > minIdent
			
			UPDATE @Temp_AllOneWayResponses   
			SET airOneResponsekey = S.airOneResponsekey 
			FROM #AllOneWayResponses S 
			LEFT OUTER JOIN @Temp_AllOneWayResponses Temp
			ON Temp.airSegmentFlightNumber = S.airSegmentFlightNumber and Temp.airSegmentMarketingAirlineCode = S.airSegmentMarketingAirlineCode
			WHERE (S.airsubRequestkey = @airBundledRequest OR S.airsubRequestkey = @airPublishedFareRequest OR S.airsubRequestkey = @airSubRequestKey OR S.airsubRequestkey = @airMultiCabinRequest OR S.airsubRequestkey = @airMultiCabinBundledRequest)

			delete @Temp_AllOneWayResponses  
			FROM @Temp_AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses,isRefundable    
			FROM @Temp_AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses ,isRefundable   
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived.airLegBookingClasses AND t.isRefundable =derived.isRefundable
			AND (airOnePriceBase + airOnePriceTax) >  minPrice
			and t.gdsSourceKey = 2

			delete @Temp_AllOneWayResponses  
			FROM @Temp_AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses, isRefundable   
			FROM @Temp_AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBookingClasses, isRefundable    
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND t.airLegBookingClasses =derived.airLegBookingClasses AND t.isRefundable =derived.isRefundable
			AND airOneIdent > minIdent
			and t.gdsSourceKey = 2

			delete @Temp_AllOneWayResponses  
			FROM @Temp_AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable   
			FROM @Temp_AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable 
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
			AND t.airLegBrandName = derived.airLegBrandName AND t.isRefundable = derived.isRefundable
			AND (airOnePriceBase + airOnePriceTax) >  minPrice

			delete @Temp_AllOneWayResponses  
			FROM @Temp_AllOneWayResponses t,  
			(  
			SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable   
			FROM @Temp_AllOneWayResponses m  
			GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode,airLegBrandName,isRefundable 
			having count(1) > 1  
			) AS derived  
			WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode 
			AND t.airLegBrandName = derived.airLegBrandName AND t.isRefundable = derived.isRefundable
			AND airOneIdent > minIdent
	END
	ELSE
	BEGIN

		/****KEEP ALL DUPLICATE WITH LOWEST PRICE AND DELETE HIGHER PRICE ****/
		delete #AllOneWayResponses  
		FROM #AllOneWayResponses t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,cabinclass   
		FROM #AllOneWayResponses m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,cabinclass   
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND isnull(t.cabinclass,'') =isnull(derived .cabinclass ,'')  
		AND (airOnePriceBase + airOnePriceTax) >  minPrice  --AND airOneIdent >= minIdent 
		
		/****KEEP ONLY ONE LOWEST PRICE ,REMOVE ALL OTHER WITH SAME PRICE ****/
		delete #AllOneWayResponses  
		FROM #AllOneWayResponses t,  
		(  
		SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,cabinclass   
		FROM #AllOneWayResponses m  
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,cabinclass   
		having count(1) > 1  
		) AS derived  
		WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND isnull(t.cabinclass,'') =isnull(derived .cabinclass ,'')  
		AND airOneIdent > minIdent
		 
	END
	
	UPDATE  A  SET otherlegAirlines = case when a.gdsSourceKey = 12 then 'WN' else S.otherLegAirlines end ,--S.otherLegAirlines  
			noOfOtherlegairlines = otherlegsAirlinesCount  FROM #AllOneWayResponses A inner join @secondLegDetails S on A.airOneResponsekey = S.responsekey and (airsubRequestkey = @airBundledRequest OR airsubRequestkey = @airMultiCabinBundledRequest)

	UPDATE #AllOneWayResponses   SET otherlegAirlines = case when gdsSourceKey = 12 then 'WN' else @anotherLegAirlines end,--@anotherLegAirlines, 
	noOfOtherlegairlines = @anotherLegAirlinesCount   
	FROM #AllOneWayResponses WHERE  otherlegAirlines is null or noOfOtherlegairlines is null 

	CREATE TABLE #AdditionalFares 
	( 
	airresponsekey varchar(200) , 
	airresponseMultiBrandkey varchar(200) ,
	airLegBrandName varchar(200) ,
	TotalPriceToDisplay decimal(12,2),
	TotalAllPaxPriceToDisplay decimal(12,2),
	childresponsekey varchar(200),
	isRefundable bit,
	ReasonCode NVARCHAR(10) DEFAULT 'NONE',
	airResBookDesigCode varchar(10) default '',
	IsSuppressed BIT DEFAULT 0,
	airRequestKey int 
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
	otherlegprice float ,
	cabinclass varchar(20),
	otherlegtax float,
	airPriceBase float ,  
	airpriceTax float ,  
	airPriceBaseSenior float,
	airPriceTaxSenior float,
	airPriceBaseChildren float,
	airPriceTaxChildren float,
	airPriceBaseInfant float,
	airPriceTaxInfant float,
	airPriceBaseYouth float,
	airPriceTaxYouth float,
	airPriceBaseTotal float,
	airPriceTaxTotal float,
	airPriceBaseDisplay float,
	airPriceTaxDisplay float  ,
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
	airPriceBaseInfantWithSeat float,
	airPriceTaxInfantWithSeat float,
	airLegBrandName varchar(200),
	airresponseMultiBrandkey uniqueidentifier NULL ,
	)   
	IF(@isMultiBrand = 1)
	BEGIN	
		INSERT INTO #AdditionalFares(airResponseKey,airresponseMultiBrandkey,TotalPriceToDisplay,airLegBrandName,TotalAllPaxPriceToDisplay,childresponsekey,isRefundable,airResBookDesigCode,airRequestKey)
		SELECT TM.airOneResponsekey,TM.airResponseMultiBrandKey,(TM.airOnePriceBaseDisplay + TM.airOnePriceTaxDisplay),TM.airLegBrandName,(TM.airOnePriceBaseTotal + TM.airOnePriceTaxTotal),TM.childResponsekey,TM.isRefundable,tm.airLegBookingClasses,TM.airsubRequestkey
		From #AllOneWayResponses t
		INNER JOIN @Temp_AllOneWayResponses TM
		ON t.airOneResponsekey = TM.airOneResponsekey 
		WHERE (TM.airsubRequestkey = @airBundledRequest OR TM.airsubRequestkey = @airSubRequestKey OR TM.airsubRequestkey = @airPublishedFareRequest OR TM.airsubRequestkey = @airAgentWareWNRequest OR TM.airsubRequestkey = @airTravelfusionRequest OR TM.airsubRequestkey = @airMultiCabinRequest OR TM.airsubRequestkey = @airMultiCabinBundledRequest)
		AND (TM.airLegBrandName <> t.airLegBrandName OR TM.isRefundable <> t.isRefundable)
		ORDER BY TM.airOneResponsekey,(TM.airOnePriceBaseDisplay + TM.airOnePriceTaxDisplay)
			
		INSERT  #normalizedResultSet (airresponsekey ,airPriceBase,noOFSTOPs ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey ,airpricetax ,airsubrequetkey ,otherlegprice,cabinclass,otherlegtax ,  airPriceBaseSenior, airPriceTaxSenior, airPriceBaseChildren,airPriceTaxChildren, airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth, airPriceTaxYouth, airPriceBaseTotal,airPriceTaxTotal, airPriceBaseDisplay,airPriceTaxDisplay,noOfOtherlegairlines ,otherlegAirlines,legConnections,actualNoOFStops,isSameAirlinesItin,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName,airresponseMultiBrandkey)  
		(  
		SELECT seg.airresponsekey,result.airOnePriceBaseDisplay ,CASE WHEN resp.gdsSourceKey = 12 THEN seg.airSegmentStops  ELSE (CASE WHEN COUNT(seg.airresponsekey )-1  > 1 THEN (CASE WHEN @MaxNoofstops=2 THEN 2 ELSE 1 END) ELSE  COUNT(seg.airresponsekey )-1 END) END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ), 

		CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
		resp.gdsSourceKey, result.airOnePriceTaxDisplay ,result.airsubRequestkey ,otherlegprice ,result.cabinclass ,otherlegtax , result.airOnePriceBaseSenior, result.airOnePriceTaxSenior, result.airOnePriceBaseChildren,result.airOnePriceTaxChildren, result.airOnePriceBaseInfant,result.airOnePriceTaxInfant,result.airOnePriceBaseYouth, result.airOnePriceTaxYouth, result.airOnePriceBaseTotal,result.airOnePriceTaxTotal, result.airOnePriceBaseDisplay,result.airOnePriceTaxDisplay  ,result.noOfOtherlegairlines ,result.otherlegAirlines ,result.legConnections,COUNT(seg.airresponsekey )-1,0,
		result.airOnePriceBaseInfantWithSeat,result.airOnePriceTaxInfantWithSeat,result.airLegBrandName,result.airResponseMultiBrandKey
		FROM   
		#AllOneWayResponses result  INNER JOIN   
		#AirResponse resp  WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey   
		INNER JOIN  
		#AirSegments seg WITH(NOLOCK) ON result .airOneResponsekey = seg.airResponseKey   
		WHERE airLegNumber = @airRequestTypeKey
		GROUP BY seg.airResponseKey,result.airOnePriceBaseDisplay ,resp.gdsSourceKey  ,result .airOnePriceTaxDisplay , result.airsubRequestkey ,otherlegprice ,result.cabinclass ,otherlegtax,result.airOnePriceBaseSenior, result.airOnePriceTaxSenior, result.airOnePriceBaseChildren,result.airOnePriceTaxChildren, result.airOnePriceBaseInfant,result.airOnePriceTaxInfant,result.airOnePriceBaseYouth, result.airOnePriceTaxYouth, result.airOnePriceBaseTotal,result.airOnePriceTaxTotal, result.airOnePriceBaseDisplay,result.airOnePriceTaxDisplay,result.noOfOtherlegairlines ,result.otherlegAirlines ,legConnections,result.airOnePriceBaseInfantWithSeat ,result.airOnePriceTaxInfantWithSeat,result.airLegBrandName,result.airResponseMultiBrandKey,airSegmentStops
		--Removed as restricted one way call from front end for Same Day Return for Domestic Trip
		--  having MIN(airSegmentDepartureDate ) > ISNULL ( DATEADD (HH,1, @selectedDate ) , DATEADD(D, -1,GETDATE() ))  
		)
	END
	ELSE
	BEGIN
		INSERT  #normalizedResultSet (airresponsekey ,airPriceBase,noOFSTOPs ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey ,airpricetax ,airsubrequetkey ,otherlegprice,cabinclass,otherlegtax ,  airPriceBaseSenior, airPriceTaxSenior, airPriceBaseChildren,airPriceTaxChildren, airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth, airPriceTaxYouth, airPriceBaseTotal,airPriceTaxTotal, airPriceBaseDisplay,airPriceTaxDisplay,noOfOtherlegairlines ,otherlegAirlines,legConnections,actualNoOFStops,isSameAirlinesItin,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airLegBrandName)  
		(  
		SELECT seg.airresponsekey,result.airOnePriceBaseDisplay ,CASE WHEN resp.gdsSourceKey = 12 THEN seg.airSegmentStops ELSE (CASE WHEN COUNT(seg.airresponsekey )-1  > 1 THEN (CASE WHEN @MaxNoofstops=2 THEN 2 ELSE 1 END) ELSE  COUNT(seg.airresponsekey )-1 END) END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ), 

		CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
		resp.gdsSourceKey, result.airOnePriceTaxDisplay ,result.airsubRequestkey ,otherlegprice ,result.cabinclass ,otherlegtax , result.airOnePriceBaseSenior, result.airOnePriceTaxSenior, result.airOnePriceBaseChildren,result.airOnePriceTaxChildren, result.airOnePriceBaseInfant,result.airOnePriceTaxInfant,result.airOnePriceBaseYouth, result.airOnePriceTaxYouth, result.airOnePriceBaseTotal,result.airOnePriceTaxTotal, result.airOnePriceBaseDisplay,result.airOnePriceTaxDisplay  ,result.noOfOtherlegairlines ,result.otherlegAirlines ,result.legConnections,COUNT(seg.airresponsekey )-1,0,
		result.airOnePriceBaseInfantWithSeat,result.airOnePriceTaxInfantWithSeat,result.airLegBrandName
		FROM   
		#AllOneWayResponses result  INNER JOIN   
		#AirResponse resp  WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey   
		INNER JOIN  
		#AirSegments seg WITH(NOLOCK) ON result .airOneResponsekey = seg.airResponseKey   
		WHERE airLegNumber = @airRequestTypeKey  
		GROUP BY seg.airResponseKey,result.airOnePriceBaseDisplay ,resp.gdsSourceKey  ,result .airOnePriceTaxDisplay , result.airsubRequestkey ,otherlegprice ,result.cabinclass ,otherlegtax,result.airOnePriceBaseSenior, result.airOnePriceTaxSenior, result.airOnePriceBaseChildren,result.airOnePriceTaxChildren, result.airOnePriceBaseInfant,result.airOnePriceTaxInfant,result.airOnePriceBaseYouth, result.airOnePriceTaxYouth, result.airOnePriceBaseTotal,result.airOnePriceTaxTotal, result.airOnePriceBaseDisplay,result.airOnePriceTaxDisplay,result.noOfOtherlegairlines ,result.otherlegAirlines ,legConnections,result.airOnePriceBaseInfantWithSeat ,result.airOnePriceTaxInfantWithSeat,result.airLegBrandName,airSegmentStops
		--Removed as restricted one way call from front end for Same Day Return for Domestic Trip
		--  having MIN(airSegmentDepartureDate ) > ISNULL ( DATEADD (HH,1, @selectedDate ) , DATEADD(D, -1,GETDATE() ))  
		)  
	END
	
	/****Logic for lower connection point display Rick's recommendation point#9 ******/
	UPDATE  N SET takeoffdate = airSegmentDepartureDate  , startingFlightAirline = airSegmentMarketingAirlineCode , startingFlightNumber = airSegmentFlightNumber   FROM #normalizedResultSet N inner join
	#AirSegments seg  WITH (NOLOCK) ON N.airresponsekey = seg.airResponseKey  and seg.airLegNumber =@airRequestTypeKey and segmentOrder = 1 

	UPDATE  N SET landingdate  = airSegmentArrivalDate ,lastFlightAirline = airSegmentMarketingAirlineCode , lastFlightNumber = airSegmentFlightNumber    FROM #normalizedResultSet N inner join
	#AirSegments seg  WITH (NOLOCK) ON N.airresponsekey = seg.airResponseKey  and seg.airLegNumber =@airRequestTypeKey and segmentOrder = (n.actualNoOFStops + 1) 
		
	UPDATE  N SET legDurationInMinutes = DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),N.takeoffdate ), DATEADD( MINUTE, (@arrivalOffset*-1), N.landingdate) ),
	legDuration  = DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),N.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), N.landingdate) )
	FROM #normalizedResultSet N --where N.airsubrequetkey <> @airAgentWareWNRequest

	;WITH tbl AS (
	SELECT *, ROW_NUMBER() OVER(ORDER BY legDurationInMinutes) AS RowNo FROM #normalizedResultSet
	)
	UPDATE #normalizedResultSet SET RowNumber = RowNo 
	FROM #normalizedResultSet N inner join tbl on n.airresponsekey = tbl.airresponsekey 

	UPDATE N SET isLowestJourneyTime = 1 FROM #normalizedResultSet N  WHERE noOFSTOPs = 0  

	SELECT * INTO #tmpDeparturesLowest 
	FROM 
	(SELECT  MIN(rowNumber) minRowIndex ,MAX(rowNumber) maxRowIndex, MIN(N.legDurationInMinutes) durationInMinutes,MAX(N.legDurationInMinutes) maximumDuration,COUNT(*) totalRecords ,noOFSTOPs ,startingFlightAirline ,startingFlightNumber,( airPriceBase  + airpriceTax ) Price  FROM #normalizedResultSet N 
	GROUP BY noOFSTOPs ,startingFlightAirline ,startingFlightNumber , ( airPriceBase  + airpriceTax )--,N.legConnections
	) T 

	SELECT * INTO #tmpArrivalLowest 
	FROM 
	(
	SELECT MIN(rowNumber) minRowIndex ,MAX(rowNumber) maxRowIndex, MIN(N1.legDurationInMinutes) durationInMinutes,MAX(N1.legDurationInMinutes) maximumDuration,COUNT(*) totalRecords ,n1.noOFSTOPs ,n1.lastFlightAirline ,n1.lastFlightNumber ,( airPriceBase  + airpriceTax ) Price 
	FROM #normalizedResultSet N1 
	INNER JOIN #tmpDeparturesLowest T1 ON N1.rowNumber = T1.minRowIndex 
	GROUP BY n1.noOFSTOPs ,n1.lastFlightAirline ,n1.lastFlightNumber  , ( airPriceBase  + airpriceTax )--,N1.legConnections
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

	INSERT into #airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,
	airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfSTOPs ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey ,
	airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, 
	airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,
	airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSELECTed,otherLegPrice ,isRefundable ,isBrandedFare,cabinClass ,fareType ,segmentOrder ,airsegmentCabin,totalCost,
	airSegmentOperatingFlightNumber,otherlegtax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant, airPriceTaxInfant,airPriceBaseYouth, airPriceTaxYouth,
	AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airSegmentOperatingAirlineCompanyShortName,otherlegAirlines ,noOfOtherlegairlines,legConnections ,legDuration,actualNoOFStops ,isSameAirlinesItin ,isLowestJourneyTime
	,airSuperSaverTax,airEconSaverTax,airFirstFlexTax,airCorporateTax,airEconFlexTax,airEconUpgradeTax,airPriceBaseInfantWithSeat, airPriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airsegmentPricingKey,airSegmentFareCategory,airLegBrandName,airSegmentBrandName,airSegmentBrandID,airSegmentBaggage,airSegmentMealCode,airResponseMultiBrandkey,ProgramCode)  
	SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , (case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate ,  
	seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport ,normalized .airPriceBase AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,noOFSTOPs  ,  takeoffdate  , landingdate ,airSegmentOperatingAirlineCode ,
	seg.airSegmentResBookDesigCode,noOfAirlines ,normalized .airlineCode ,ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver , 
	priceClassCommentsEconSaver,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice ,airEconFlexPrice,airEconUpgradePrice,  
	airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining,  
	airPriceClassSELECTed ,otherlegprice ,refundable ,isBrandedFare ,normalized. cabinClass ,resp.faretype,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized .airPriceBase,0)+ isnull(normalized.airpriceTax,0)),seg.airSegmentOperatingFlightNumber,otherlegtax ,
	normalized.airPriceBaseSenior,normalized.airPriceTaxSenior,normalized.airPriceBaseChildren,normalized.airPriceTaxChildren,normalized.airPriceBaseInfant, normalized.airPriceTaxInfant,normalized.airPriceBaseYouth, normalized.airPriceTaxYouth,normalized.AirPriceBaseTotal,normalized.AirPriceTaxTotal,normalized.airPriceBaseDisplay, normalized.airPriceTaxDisplay,airSegmentOperatingAirlineCompanyShortName  ,normalized.otherlegAirlines ,normalized.noOfOtherlegairlines ,legconnections,DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),normalized.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), normalized.landingdate) ) ,actualNoOFStops ,isSameAirlinesItin,isLowestJourneyTime
	,airSuperSaverTax,airEconSaverTax,airFirstFlexTax,airCorporateTax,airEconFlexTax,airEconUpgradetax,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat,agentwareQueryID,agentwareItineraryID,airsegmentPricingKey,airSegmentFareCategory,ISNULL(normalized.airLegBrandName,normalized.cabinclass),seg.airSegmentBrandName,seg.airSegmentBrandID,seg.airSegmentBaggage,seg.airSegmentMealCode,normalized.airresponseMultiBrandkey,seg.ProgramCode
	FROM #AirSegments seg  WITH (NOLOCK)   
	INNER JOIN #normalizedResultSet normalized ON seg.airresponsekey = normalized .airresponsekey   
	INNER JOIN #AirResponse resp WITH (NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noSTOPs nSTOP ON normalized .noOFSTOPs = nSTOP .sTOPs   
	INNER JOIN  AirVendorLookup airVendor WITH (NOLOCK)   ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode    
	LEFT OUTER JOIN AircraftsLookup WITH(NOLOCK) on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)  
	WHERE normalized.airPriceBase  <=    @price and airLegNumber = @airRequestTypeKey 
	AND ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )  
	AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )  

	IF(@isMultiBrand = 1)
	BEGIN
		IF((SELECT COUNT(1) FROM #airResponseResultset where airResponseMultiBrandkey IS NOT NULL) > 0)
		BEGIN
			INSERT INTO #airSegmentMultiBrandResultset(airSegmentKey,airResponseKey,airResponseMultiBrandKey,airSegmentResBookDesigCode,airsegmentCabin,airSegmentBrandName,airSegmentBrandID,airSegmentBaggage,airSegmentMealCode,isRefundable)
			SELECT ASMB.airSegmentKey,ASMB.airResponseKey,ASMB.airResponseMultiBrandKey,airSegmentResBookDesigCode,airsegmentCabin,airSegmentBrandName,airSegmentBrandID,airSegmentBaggage,airSegmentMealCode,ARMB.refundable
			FROM #AirSegmentsMultiBrand ASMB
			INNER JOIN #AirResponseMultiBrand ARMB
			ON ASMB.airResponseMultiBrandKey = ARMB.airResponseMultiBrandKey
			WHERE airLegNumber = @airRequestTypeKey AND (ARMB.airSubRequestKey = @airBundledRequest OR ARMB.airSubRequestKey = @airSubRequestKey OR ARMB.airSubRequestKey = @airPublishedFareRequest OR ARMB.airSubRequestKey = @airMultiCabinRequest OR ARMB.airSubRequestKey = @airAgentWareWNRequest OR ARMB.airSubRequestKey = @airTravelfusionRequest OR ARMB.airSubRequestKey = @airMultiCabinBundledRequest)
			
			UPDATE P SET P.airsegmentCabin = A.airSegmentCabin,P.airSegmentResBookDesigCode = A.airSegmentResBookDesigCode,P.airSegmentBrandName = A.airSegmentBrandName,P.airSegmentBrandID = A.airSegmentBrandID,P.airSegmentBaggage = A.airSegmentBaggage,P.airSegmentMealCode = A.airSegmentMealCode,P.isRefundable = A.isRefundable
			from #airResponseResultset P inner join #airSegmentMultiBrandResultset A on P.airresponseMultiBrandkey = A.airresponseMultiBrandkey
			and P.airSegmentKey = A.airSegmentKey
			where P.airResponseMultiBrandkey is Not null		
		END
	END

	--Policy Implementation - start
IF (@IsPolicyApplicable = 1)
BEGIN
	IF (@airRequestTypeKey = 1 OR @LowestPrice= 0)
	BEGIN
		SELECT @LowestPrice = (CASE WHEN @isTotalPriceSort = 0 THEN (MIN (airPrice)) ELSE  min(totalcost) end ) FROM  #airResponseResultset
	END

	--Hide
	IF ((@MaxFareTotal != 0) and (@IsHideFare = 1))
	BEGIN
		IF EXISTS(SELECT 1 FROM #airResponseResultset WHERE airresponsekey IN (SELECT A.airResponseKey from #airResponseResultset A WHERE A.totalCost > @MaxFareTotal))
		BEGIN
		SET @isOutOfPolicyResultsPresent = 1
		END
		DELETE FROM #airResponseResultset 
		WHERE airresponsekey IN (SELECT A.airResponseKey from #airResponseResultset A WHERE ROUND(A.totalCost,2) > ROUND(@MaxFareTotal,2))
	END

	--Basic Economy
	IF (@ApplyBasicUnselectable = 1 AND @IsBasicUnselectable = 1)
	BEGIN

	print @ApplyBasicUnselectable
	print @IsBasicUnselectable
		UPDATE #airResponseResultset 
		SET IsSuppressed = 1
		WHERE airResponsekey IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									WHERE LOWER(A.airLegBrandName) like '%basic%' OR LOWER(A.airLegBrandName) like '%wanna get away%')
	END
	ELSE IF (@ApplyBasicUnselectable = 1 AND @IsBasicUnselectable = 0)
	BEGIN
		UPDATE #airResponseResultset 
		SET ReasonCode = 'OOP' 
		WHERE airResponsekey IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									WHERE LOWER(A.airLegBrandName) like '%basic%' OR LOWER(A.airLegBrandName) like '%wanna get away%')
	END

	--Suppress Airline
	
	IF (@IsSuppressAirline = 1) 
	BEGIN
	    DECLARE @SuppressedAirline  TABLE (airlineCode VARCHAR (5) )  
		INSERT INTO @SuppressedAirline(airlineCode)  SELECT S.SuppressedAirlineCode FROM vault..SuppressedAirlinePolicyMapping S WHERE S.policyKey = @PolicyKey

		DELETE FROM #airResponseResultset 
		WHERE airResponsekey IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									WHERE LTRIM(RTRIM(A.airSegmentMarketingAirlineCode)) IN (SELECT airlineCode FROM @SuppressedAirline))
	END

	
	--Allow Business on long flights
	IF (@IsBussinessClassAllowed = 1 AND @IsBusinessLongFlightsUnselectable = 1)
	BEGIN
		UPDATE #airResponseResultset 
		SET IsSuppressed = 1
		WHERE airResponseKey NOT IN ( SELECT A.airResponseKey 
									 FROM #airResponseResultset A 
  									WHERE lower(A.airLegBrandName) = 'business' 
									--WHERE lower(A.airsegmentCabin) = 'business' 
									--AND  DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),A.airSegmentDepartureDate ), DATEADD( MINUTE, (@arrivalOffset*-1), A.airSegmentArrivalDate)) > (@BusinessClassOverHrs * (60))
									  AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (A.airsegmentDepartureOffset *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (A.airSegmentArrivalOffset *-1), A.airSegmentArrivalDate))) > (@BusinessClassOverHrs* (60) )
									)
    	AND lower(airLegBrandName) = 'business'
	END
	ELSE IF(@IsBussinessClassAllowed = 1 AND @IsBusinessLongFlightsUnselectable = 0)
	BEGIN
		UPDATE #airResponseResultset 
		SET ReasonCode = 'OOP' 
		WHERE airResponseKey NOT IN ( SELECT A.airResponseKey 
									 FROM #airResponseResultset A 
  									WHERE lower(A.airLegBrandName) = 'business' 
									--WHERE lower(A.airsegmentCabin) = 'business' 
									--AND  DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),A.airSegmentDepartureDate ), DATEADD( MINUTE, (@arrivalOffset*-1), A.airSegmentArrivalDate)) > (@BusinessClassOverHrs * (60))
									AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (A.airsegmentDepartureOffset *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (A.airSegmentArrivalOffset *-1), A.airSegmentArrivalDate))) > (@BusinessClassOverHrs* (60) )
									)
    	AND lower(airLegBrandName) = 'business'
	END

	
	--Allow First on long flights
	IF (@IsFirstClassAllowed = 1 AND @IsFirstLongFlightsUnselectable = 1)
	BEGIN
		UPDATE #airResponseResultset 
		SET IsSuppressed = 1
		WHERE airResponsekey NOT IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									--WHERE lower(A.airsegmentCabin) = 'first' 
									WHERE lower(A.airLegBrandName) = 'first' 
									--AND DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),A.airSegmentDepartureDate ), DATEADD( MINUTE, (@arrivalOffset*-1), A.airSegmentArrivalDate)) > (@FirstClassOverHrs * (60))
									AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (A.airsegmentDepartureOffset *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (A.airSegmentArrivalOffset *-1), A.airSegmentArrivalDate))) > (@FirstClassOverHrs * (60) )
									)
	  AND lower(airLegBrandName) = 'first'
	END
	ELSE IF(@IsFirstClassAllowed = 1 AND @IsFirstLongFlightsUnselectable = 0)
	BEGIN
		UPDATE #airResponseResultset 
		SET ReasonCode = 'OOP' 
		WHERE airResponsekey NOT IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									--WHERE lower(A.airsegmentCabin) = 'first' 
									WHERE lower(A.airLegBrandName) = 'first' 
									--AND DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),A.airSegmentDepartureDate ), DATEADD( MINUTE, (@arrivalOffset*-1), A.airSegmentArrivalDate)) > (@FirstClassOverHrs * (60))
									AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (A.airsegmentDepartureOffset *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (A.airSegmentArrivalOffset *-1), A.airSegmentArrivalDate))) > (@FirstClassOverHrs * (60))
									)
	 AND lower(airLegBrandName) = 'first'
	END

	--High
	IF (@HighFareTotal != 0 AND @IsHighFareTotal = 1)
	BEGIN
	IF (@MaxFareTotal !=0)
	BEGIN
		UPDATE #airResponseResultset 
		SET ReasonCode = 'High' 
		WHERE airResponsekey IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									WHERE ROUND(A.totalCost,2) > ROUND(@HighFareTotal,2)
									AND ROUND(A.totalCost,2) <=  ROUND(@MaxFareTotal,2))
	END
	ELSE
	BEGIN
		UPDATE #airResponseResultset 
		SET ReasonCode = 'High' 
		WHERE airResponsekey IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									WHERE ROUND(A.totalCost,2) > ROUND(@HighFareTotal,2))
	END
END
    --OOP
	IF (( @IsLowFareThreshold =1) AND (@LowFareThreshold > 0))
	BEGIN
		if (@HighFareTotal != 0) 
		BEGIN
			UPDATE #airResponseResultset 
			SET ReasonCode = 'OOP' 
			WHERE airResponsekey IN (SELECT A.airResponseKey 
										FROM #airResponseResultset A 
										WHERE ROUND(A.totalCost,2) > ROUND((@LowestPrice + @LowFareThreshold),2)
										AND ROUND(A.totalCost,2) <= ROUND(@HighFareTotal,2))
		END
		ELSE
		BEGIN
			UPDATE #airResponseResultset 
			SET ReasonCode = 'OOP' 
			WHERE airResponsekey IN (SELECT A.airResponseKey 
										FROM #airResponseResultset A 
										WHERE ROUND(A.totalCost,2) > ROUND((@LowestPrice + @LowFareThreshold),2))
		END
	END
		
	--Advance Purchase
	IF (( @isAdvancePurchase =1 AND @IsflagAdvancePurchase = 1) AND (@AdvancePurchaseDays > 0 AND @AdvancePurchasePrice !=0))
	BEGIN
	
		UPDATE #airResponseResultset 
		SET ReasonCode = 'OOP' 
		WHERE airResponsekey IN (SELECT A.airResponseKey 
									FROM #airResponseResultset A 
									WHERE ROUND(A.totalCost,2) >= ROUND(@AdvancePurchasePrice,2)
									AND DATEDIFF(dd,getdate(),@TripFromDate) < ROUND(@AdvancePurchaseDays,2))
	END

	IF(@isMultiBrand = 1)
	BEGIN
		IF ((@MaxFareTotal != 0) and (@IsHideFare = 1))
		BEGIN
			DELETE FROM #AdditionalFares 
			WHERE Round((TotalPriceToDisplay),2) > Round((@MaxFareTotal),2)
		END
		
		IF (@ApplyBasicUnselectable = 1 AND @IsBasicUnselectable = 1)
		BEGIN
			UPDATE #AdditionalFares 
			SET IsSuppressed = 1
			WHERE (LOWER(airLegBrandName) like '%basic%' OR LOWER(airLegBrandName) like '%wanna get away%')
		END
		ELSE IF (@ApplyBasicUnselectable = 1 AND @IsBasicUnselectable = 0)
		BEGIN
			UPDATE #AdditionalFares 
			SET ReasonCode = 'OOP' 
			WHERE (LOWER(airLegBrandName) like '%basic%' OR LOWER(airLegBrandName) like '%wanna get away%')
		END
	
		--Allow Business on long flights
	IF (@IsBussinessClassAllowed = 1 AND @IsBusinessLongFlightsUnselectable = 1)
	BEGIN
			UPDATE #AdditionalFares 
			SET IsSuppressed = 1
			WHERE airResponseKey not in ( SELECT airResponseKey 
									FROM #airResponseResultset A 
									WHERE (A.airResponseKey = airResponseKey 
									--AND  ABS(DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (@arrivalOffset*-1), A.airSegmentArrivalDate))) > (@BusinessClassOverHrs ))
									AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (ISNULL(A.airSegmentDepartureOffset,@departureOffset) *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (ISNULL(A.airSegmentArrivalOffset,@arrivalOffset) *-1), A.airSegmentArrivalDate))) > (@BusinessClassOverHrs * (60) ))
									)
			AND (lower(airLegBrandName) = 'business' OR lower(airLegBrandName) = 'select')

	END
	ELSE IF(@IsBussinessClassAllowed = 1 AND @IsBusinessLongFlightsUnselectable = 0)
	BEGIN
			UPDATE #AdditionalFares 
			SET ReasonCode = 'OOP' 
			WHERE airResponseKey not in ( SELECT airResponseKey 
									FROM #airResponseResultset A 
									WHERE (A.airResponseKey = airResponseKey 
									AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (ISNULL(A.airSegmentDepartureOffset,@departureOffset) *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (ISNULL(A.airSegmentArrivalOffset,@arrivalOffset) *-1), A.airSegmentArrivalDate))) > (@BusinessClassOverHrs * (60) ))
									)
			AND (lower(airLegBrandName) = 'business' OR lower(airLegBrandName) = 'select')

	END

	----Allow First on long flights
	IF (@IsFirstClassAllowed = 1 AND @IsFirstLongFlightsUnselectable = 1)
	BEGIN
			UPDATE #AdditionalFares 
			SET IsSuppressed = 1
			WHERE airResponseKey not in ( SELECT airResponseKey 
									FROM #airResponseResultset A 
									WHERE (A.airResponseKey = airResponseKey 
									--AND  DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),A.airSegmentDepartureDate ), DATEADD( MINUTE, (@arrivalOffset*-1), A.airSegmentArrivalDate)) > (@FirstClassOverHrs * (60)))
									AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (ISNULL(A.airSegmentDepartureOffset,@departureOffset) *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (ISNULL(A.airSegmentArrivalOffset,@arrivalOffset) *-1), A.airSegmentArrivalDate))) > (@FirstClassOverHrs * (60) ))
									)
			AND (lower(airLegBrandName) = 'first')

	END
	ELSE IF(@IsFirstClassAllowed = 1 AND @IsFirstLongFlightsUnselectable = 0)
	BEGIN
			UPDATE #AdditionalFares 
			SET ReasonCode = 'OOP' 
			WHERE airResponseKey not in ( SELECT airResponseKey 
									FROM #airResponseResultset A 
									WHERE (A.airResponseKey = airResponseKey 
									--AND  DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),A.airSegmentDepartureDate ), DATEADD( MINUTE, (@arrivalOffset*-1), A.airSegmentArrivalDate)) > (@FirstClassOverHrs * (60)))
									AND  ABS(DATEDIFF( MINUTE , DATEADD( HOUR, (ISNULL(A.airSegmentDepartureOffset,@departureOffset) *-1),A.airSegmentDepartureDate ), DATEADD( HOUR, (ISNULL(A.airSegmentArrivalOffset,@arrivalOffset) *-1), A.airSegmentArrivalDate))) > (@FirstClassOverHrs * (60) ))
									)
			AND (lower(airLegBrandName) = 'first' )

	END

		IF (@HighFareTotal != 0 AND @IsHighFareTotal = 1 )
		BEGIN
			IF (@MaxFareTotal !=0)
			BEGIN
				UPDATE #AdditionalFares 
				SET ReasonCode = 'High' 
				WHERE (ROUND(TotalPriceToDisplay,2) > ROUND(@HighFareTotal,2)  
				AND ROUND(TotalPriceToDisplay,2) <= ROUND(@MaxFareTotal,2))
			END
			ELSE
			BEGIN
				UPDATE #AdditionalFares 
				SET ReasonCode = 'High' 
				WHERE (ROUND(TotalPriceToDisplay,2) > ROUND(@HighFareTotal,2))
			END
		END

		IF (( @IsLowFareThreshold =1) AND (@LowFareThreshold > 0))
		BEGIN
			IF (@HighFareTotal != 0)
			BEGIN
				UPDATE #AdditionalFares 
				SET ReasonCode = 'OOP' 
				WHERE (ROUND(TotalPriceToDisplay,2) > ROUND((@LowestPrice + @LowFareThreshold),2)
				AND ROUND(TotalPriceToDisplay,2) <= ROUND(@HighFareTotal,2))

			END
			ELSE
			BEGIN
				UPDATE #AdditionalFares 
				SET ReasonCode = 'OOP' 
				WHERE (ROUND(TotalPriceToDisplay,2) > ROUND((@LowestPrice + @LowFareThreshold),2))
			END
		END

		IF (( @isAdvancePurchase =1 AND @IsflagAdvancePurchase = 1) AND (@AdvancePurchaseDays > 0 AND @AdvancePurchasePrice !=0))
		BEGIN

		UPDATE #AdditionalFares 
		SET ReasonCode = 'OOP' 
		WHERE (ROUND(TotalPriceToDisplay,2) > ROUND(@AdvancePurchasePrice,2)
									AND DATEDIFF(dd,getdate(),@TripFromDate) < ROUND(@AdvancePurchaseDays,2))
		END
	END
END
	--Policy Implementation - end

	If(@isMultiBrand = 1)
	BEGIN
	update #airResponseResultset
	SET multiBrandFaresInfo = (
	SELECT airresponseMultiBrandkey,airLegBrandName,TotalPriceToDisplay,childresponsekey,isRefundable,ReasonCode,airResBookDesigCode, IsSuppressed,airRequestKey
	FROM #AdditionalFares A
	where A.airresponsekey = #airResponseResultset.airResponseKey
	FOR XML PATH('AdditionalFare'), ROOT('AdditionalFaresInfo')
	)
	
	END
	
	--Update DepartureOffset, ArrivalOffset for AgentWare WN 
	IF @airAgentWareWNRequest > 0
	BEGIN
		-----------------Update from Current #airResponseResultset Table---------------------------------
		UPDATE a
			SET a.airsegmentDepartureOffset = ISNULL(b.airsegmentDepartureOffset, '')
		From #airResponseResultset a
		JOIN (SELECT distinct airsegmentDepartureOffset, airSegmentDepartureAirport FROM #airResponseResultset WHERE airsegmentDepartureOffset <> '') b 
			ON a.airSegmentDepartureAirport = b.airSegmentDepartureAirport and a.airsegmentDepartureOffset IS NULL
		-----------------Update from Current #airResponseResultset Table---------------------------------
		-----------------Update from Current AirportLookup Table---------------------------------	
		UPDATE a
			SET a.airsegmentDepartureOffset = ISNULL(b.DST_offset, '')
		From #airResponseResultset a
		JOIN (SELECT distinct DST_offset, AirportCode FROM AirportLookup WHERE DST_offset <> '') b 
			ON a.airSegmentDepartureAirport = b.AirportCode and a.airsegmentDepartureOffset IS NULL	
		-----------------Update from Current AirportLookup Table---------------------------------
		-----------------Update from default variable---------------------------------			
		UPDATE #airResponseResultset  SET airsegmentDepartureOffset =@departureOffset WHERE airsegmentDepartureOffset IS NULL
		-----------------Update from default variable---------------------------------
		
		-----------------Update from Current #airResponseResultset Table---------------------------------
		UPDATE a
			SET a.airSegmentArrivalOffset = ISNULL(b.airSegmentArrivalOffset, '')
		From #airResponseResultset a
		JOIN (SELECT distinct airSegmentArrivalOffset, airSegmentArrivalAirport FROM #airResponseResultset WHERE airSegmentArrivalOffset <> '') b 
			ON a.airSegmentArrivalAirport = b.airSegmentArrivalAirport and a.airSegmentArrivalOffset IS NULL
		-----------------Update from Current #airResponseResultset Table---------------------------------
		-----------------Update from Current AirportLookup Table---------------------------------	
		UPDATE a
			SET a.airSegmentArrivalOffset = ISNULL(b.DST_offset, '')
		From #airResponseResultset a
		JOIN (SELECT distinct DST_offset, AirportCode FROM AirportLookup WHERE DST_offset <> '') b 
			ON a.airSegmentArrivalAirport = b.AirportCode and a.airSegmentArrivalOffset IS NULL	
		-----------------Update from Current AirportLookup Table---------------------------------
		-----------------Update from default variable---------------------------------
		UPDATE #airResponseResultset  SET airSegmentArrivalOffset = @arrivalOffset WHERE airSegmentArrivalOffset IS NULL
		-----------------Update from default variable---------------------------------
	END

	CREATE TABLE #pagingResultSet     
	(  
	rowNum int IDENTITY(1,1) NOT NULL,     
	airResponseKey uniqueidentifier  ,  
	airlineName varchar(100),   
	airPrice decimal (12,2) ,   
	actualTakeOffDateForLeg datetime,
	isSmartFare bit default 0    
	)   
	
	CREATE TABLE #pagingResultSetTemp
	(  
	rowNum int ,
	airResponseKey uniqueidentifier ,  
	airlineName varchar(100),   
	airPrice decimal (12,2) ,   
	actualTakeOffDateForLeg datetime,
	isSmartFare bit default 0    
	)   

	IF @sortField <> ''  
	BEGIN  
		INSERT into #pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )  
		SELECT    air.airResponseKey ,( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air   
		INNER JOIN #normalizedResultSet normalized on air.airresponsekey = normalized .airresponsekey   
		INNER  JOIN @tmpAirline airline on (normalized .airlineCode  = airline.airLineCode   )   
		INNER JOIN @noSTOPs nSTOP ON normalized .noOFSTOPs = nSTOP .sTOPs   
		AND ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )  
		AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )  


		GROUP BY air.airResponseKey,airlineName ,normalized.legDurationInMinutes   order by   
		CASE WHEN @sortField  = 'Price'      THEN ( case When @isTotalPriceSort = 0  then ROUND(MIN( airPrice),0)  else ROUND(MIN(totalCost ),0) END  ) END  ,    
		CASE WHEN @sortField  = 'Airline' THEN  MIN(MarketingAirlineName)         END   ,   
		CASE WHEN @sortField  ='Departure' THEN MIN( actualTakeOffDateForLeg) END   ,    
		CASE WHEN @sortField  ='' THEN ROUND(MIN( airPrice),0)  END   ,
		normalized.legDurationInMinutes 
	END   
	ELSE   
	BEGIN   
		IF (@isCabinUniquification = 1 AND @isMultiBrand = 1 AND @airRequestTypeKey <> 1)
		BEGIN
			INSERT into #pagingResultSetTemp (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )  
			SELECT    air.airResponseKey ,( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air   
			INNER JOIN #normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey   
			INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   )   
			GROUP BY air.airResponseKey,airlineName ,normalized.legDurationInMinutes  
			order by 
			( case When @isTotalPriceSort = 0  then ROUND(MIN( airPrice),0)  else ROUND(MIN(totalCost ),0) END) , normalized.legDurationInMinutes  ,MIN(MarketingAirlineName) , min(normalized.noOFSTOPs ),MIN( actualTakeOffDateForLeg) ,MIN( actualLandingDateForLeg )  

			INSERT INTO #AllOneWaywithAdditional(airOneResponsekey)  
			SELECT airOneResponsekey
			FROM
			(	
			   SELECT airOneResponsekey,airOnePriceBaseDisplay,airOnePriceTaxDisplay
			   FROM #AllOneWayResponses
			   WHERE airLegBrandName = @airLegBrandName_CurrentLeg
			   UNION ALL
			   SELECT airOneResponsekey,airOnePriceBaseDisplay,airOnePriceTaxDisplay
			   FROM @Temp_AllOneWayResponses
	        	WHERE airLegBrandName = @airLegBrandName_CurrentLeg
			) DERIVED
			ORDER BY (DERIVED.airOnePriceBaseDisplay + DERIVED.airOnePriceTaxDisplay) 

			INSERT INTO #AllOneWaywithAdditional(airOneResponsekey)  
			SELECT airOneResponsekey
			FROM
			(
			   SELECT airOneResponsekey,airOnePriceBaseDisplay,airOnePriceTaxDisplay
			   FROM #AllOneWayResponses
			   WHERE airLegBrandName <> @airLegBrandName_CurrentLeg
			   UNION
			   SELECT airOneResponsekey,airOnePriceBaseDisplay,airOnePriceTaxDisplay
			   FROM @Temp_AllOneWayResponses
			   WHERE airLegBrandName <> @airLegBrandName_CurrentLeg
			) DERIVED
			ORDER BY (DERIVED.airOnePriceBaseDisplay + DERIVED.airOnePriceTaxDisplay) 

			UPDATE #pagingResultSetTemp
			SET rowNum = D.MinIndent
			FROM #AllOneWaywithAdditional S 
			INNER JOIN
			(
			SELECT MIN(A.airOneIdent) AS MinIndent,airOneResponsekey
			FROM #AllOneWaywithAdditional A
			GROUP BY A.airOneResponsekey
			) D
			ON D.airOneResponsekey = S.airOneResponsekey
       	    WHERE airresponsekey = D.airOneResponsekey
       		INSERT INTO #pagingResultSet(airResponseKey , airlineName ,  airPrice  , actualTakeOffDateForLeg,isSmartFare )
       		SELECT airResponseKey , airlineName ,  airPrice  , actualTakeOffDateForLeg,isSmartFare FROM #pagingResultSetTemp
       		ORDER BY rowNum
		END
		ELSE
		BEGIN
		INSERT into #pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )  
			SELECT    air.airResponseKey ,( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air   
			INNER JOIN #normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey   
			INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   )   
			GROUP BY air.airResponseKey,airlineName ,normalized.legDurationInMinutes  order by 
			( case When @isTotalPriceSort = 0  then ROUND(MIN( airPrice),0)  else ROUND(MIN(totalCost ),0) END) , normalized.legDurationInMinutes  ,MIN(MarketingAirlineName) , min(normalized.noOFSTOPs ),MIN( actualTakeOffDateForLeg) ,MIN( actualLandingDateForLeg )  
		END
	END   

	DECLARE @firstRoundTripResponse as int 
	DECLARE @firstRoundTripResponsePrice as decimal (12,2) 

	/****Old smart fare logic ****/
	--SELECT top 1    @firstRoundTripResponse = rowNum ,@firstRoundTripResponsePrice= ( case When @isTotalPriceSort = 0  then  ( a.airPrice)  else  (totalCost ) END)  from #pagingResultSet P inner join #airResponseResultset A on p.airResponseKey = a.airResponseKey 

	-- where airRequestKey   = @airBundledRequest order by rownum  

	--UPDATE #pagingResultSet SET isSmartFare = 1 where rowNum < @firstRoundTripResponse  and  airPrice < @firstRoundTripResponsePrice 
	/***Old smart fare logic ends here **/

	SELECT top 1    @firstRoundTripResponse = rowNum ,@firstRoundTripResponsePrice= ( case When @isTotalPriceSort = 0  then  ( a.airPrice)  else  (totalCost ) END)  from #pagingResultSet P inner join #airResponseResultset A on p.airResponseKey = a.airResponseKey 

	where noofAirlines =1 and noOfOtherlegairlines  =1 and airSegmentMarketingAirlineCode = otherlegAirlines  order by rownum  

	IF ( @airRequestTypeKey =1 ) 
	BEGIN
	UPDATE P  SET isSmartFare = 1 from #pagingResultSet P inner join #airResponseResultset A on P.airResponseKey = A.airResponseKey  
	where rowNum < @firstRoundTripResponse  and  P.airPrice < @firstRoundTripResponsePrice and noofAirlines =1 and noOfOtherlegairlines = 1 and airSegmentMarketingAirlineCode <> otherlegAirlines 
	END
	/****MAIN RESULTSET FOR LIST ****STARTS HERE *****/  
	
	SELECT rowNum,air.*, airSegmentArrivalOffset,departureAirport .CityName AS DepartureAirPortCityName ,departureAirport.StateCode AS DepartureAirportStateCode ,departureAirport .AirportName AS DepartureAirportName , departureAirport.CountryCode AS DepartureAirportCountryCode,   
	arrivalAirport .CItyName AS ArrivalAirPortCityName ,arrivalAirport .StateCode AS ArrivalAirportStateCode , arrivalAirport .AirportName AS ArrivalAirportName ,arrivalAirport .CountryCode  AS ArrivalAirportCountryCode,  
	operatingAirline .ShortName AS OperatingAirlineName  ,isRefundable ,isBrandedFare ,cabinClass,
	CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName,isSmartFare , legDuration,ReasonCode
	FROM #airResponseResultset air INNER JOIN #pagingResultSet  paging ON air.airResponseKey = paging.airResponseKey  
	LEFT OUTER JOIN AirVendorLookup operatingAirline WITH (NOLOCK)   ON air .airSegmentOperatingAirlineCode = operatingAirline .AirlineCode   
	LEFT OUTER JOIN AirportLookup departureAirport  WITH (NOLOCK)   ON air .airSegmentDepartureAirport = departureAirport .AirportCode   
	LEFT OUTER JOIN AirportLookup arrivalAirport  WITH (NOLOCK)    ON air .airSegmentArrivalAirport = arrivalAirport.AirportCode   
	LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode
	LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode
	WHERE   
	airLegNumber = CASE WHEN @airRequestTypeKey > -1 THEN @airRequestTypeKey ELSE airLegNumber END    
	order by rowNum ,airlegnumber ,segmentOrder, airSegmentDepartureDate

	/****MAIN RESULTSET FOR LIST ****END HERE *****/  

	/******MIN -MAX PRICE FOR FILTERS START HERE ***/  
	IF ( @gdssourcekey =9 ) AND @airRequestTypeKey = 2   
	BEGIN  
    	SELECT (case when @isTotalPriceSort= 0 then( MIN (airPrice) ) else  min (totalcost) end ) AS LowestPrice , (case when @isTotalPriceSort= 0 then MAX(airPrice ) else max(totalcost) end ) AS HighestPrice FROM #airResponseResultset  result1      
	END   
	ELSE   
	BEGIN   
		SELECT (case when @isTotalPriceSort= 0 then( MIN (airPrice) ) else  min (totalcost) end ) AS LowestPrice , (case when @isTotalPriceSort= 0 then MAX(airPrice ) else max(totalcost) end ) AS HighestPrice FROM #airResponseResultset  result1    
	END   
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
		SELECT (case when @isTotalPriceSort = 0 then MIN(airPrice ) else min(totalcost) end ) AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode,vendor.IsSeatChooseAvailable From #airResponseResultset air  
		INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
		INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode   
		LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode   
		GROUP BY airlineName ,ShortName ,IsSeatChooseAvailable  
	END   
	ELSE   
	BEGIN    
		IF ( @gdssourcekey =9 ) AND @airRequestTypeKey = 2   
		BEGIN  
			SELECT (case when @isTotalPriceSort = 0 then MIN(airPrice ) else min(totalcost) end )AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode,vendor.IsSeatChooseAvailable From #airResponseResultset air  
			INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
			INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode   
			LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor.AirlineCode   
			GROUP BY airlineName ,ShortName ,IsSeatChooseAvailable  
		END   
		ELSE   
		BEGIN    
			SELECT (case when @isTotalPriceSort = 0 then MIN(airPrice ) else min(totalcost) end ) AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode,vendor.IsSeatChooseAvailable From #airResponseResultset air  
			INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
			LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode   
			GROUP BY airlineName ,ShortName , IsSeatChooseAvailable 
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
			ELSE IF  (@airLines <> '') 
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
				+ISNULL( legPrice,0)  

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
				WHERE t.airsubrequetkey  = @airSubRequestKey AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT (case when @isTotalPriceSort = 0  Then MIN(t.airPriceBase ) else   MIN(t.airPriceBase +t.airPriceTax) end), t.noOFSTOPs,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights       
				From #normalizedResultSet   t    INNER JOIN   
				(SELECT A.* FROM #AirResponse A  WITH (NOLOCK) 
				Except   
				SELECT A.* FROM #AirResponse A  WITH (NOLOCK)  INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) r   
				ON t.airresponsekey = r.airResponseKey   
				WHERE t.airsubrequetkey  <> @airSubRequestKey  AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT (case when @isTotalPriceSort = 0  Then MIN( airPriceBase ) else   MIN( airPriceBase + airPriceTax) end), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights     From #normalizedResultSet   t    
				INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
				GROUP BY  t.noOFSTOPs   
				union   
				SELECT (case when @isTotalPriceSort = 0  Then MIN( m.airPriceBase  ) else   MIN( m.airPriceBase + m.airPriceTax) end)     AS LowestPrice,m.noOFSTOPs AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  From #normalizedResultSet   m INNER JOIN #AirResponse r  WITH (NOLOCK) 
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
				) AS LowestPrice  
				,t.noOFSTOPs AS NoOFSegments,t.airlineCode  AS airSegmentMarketingAirlineCode,COUNT(distinct r.airResponseKey ) noOFFLights   From #normalizedResultSet   t INNER JOIN #AirResponse r ON t.airresponsekey =r.airResponseKey   
				INNER JOIN @tmpAirline air ON t.airlineCode = air.airLineCode   
				InNER JOIN @tmpSecondLowestPrice s ON s.airline = t.airlineCode    
				WHERE t.airsubrequetkey  = @airSubRequestKey AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT (case when @isTotalPriceSort = 0  Then MIN(t.airPriceBase ) else   MIN(t.airPriceBase +t.airPriceTax) end), t.noOFSTOPs,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights     From #normalizedResultSet   t    WHERE t.airsubrequetkey <> @airSubRequestKey  
				AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFSTOPs   
				union   
				SELECT (case when @isTotalPriceSort = 0  Then MIN(t.airPriceBase ) else   MIN(t.airPriceBase +t.airPriceTax) end), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights     From #normalizedResultSet   t    
				INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
				GROUP BY  t.noOFSTOPs   
				union   
				SELECT (case when @isTotalPriceSort = 0  Then MIN(m.airPriceBase ) else   MIN(m.airPriceBase +m.airPriceTax) end)     AS LowestPrice,m.noOFSTOPs AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  
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
			SELECT ( case when @isTotalPriceSort = 0 then  MIN(airPrice ) else min ( airprice + airpricetax) end )AS LowestPrice ,NoOfSTOPs AS NoOFSegments ,airlineName AS airSegmentMarketingAirlineCode,COUNT(distinct air.airResponseKey ) noOFFLights ,
			ISNULL (ShortName,airlineName)AS MarketingAirlineName From #airResponseResultset air  
			LEFT OUTER JOIN AirVendorLookup vendor  WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode   
			INNER JOIN @tmpAirline tmp ON air.airlineName = tmp.airLineCode   
			GROUP BY airlineName ,ShortName ,NoOfSTOPs   
			union   
			SELECT ( case when @isTotalPriceSort = 0 then  MIN(airPriceBASe ) else min ( airPriceBASe + airpricetax) end ), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights ,'all'    From #normalizedResultSet t     
			INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
			GROUP BY t.noOFSTOPs   
			order by MarketingAirlineName  
		END
		ELSE
		BEGIN
			INSERT INTO @MatrixResult (LowestPrice,NoOFSegments,airSegmentMarketingAirlineCode,noOFFLights,MarketingAirlineName)   
			SELECT ( case when @isTotalPriceSort = 0 then  MIN(airPrice ) else min ( airprice + airpricetax) end )AS LowestPrice ,NoOfSTOPs AS NoOFSegments ,airlineName AS airSegmentMarketingAirlineCode,COUNT(distinct air.airResponseKey ) noOFFLights ,
			ISNULL (ShortName,airlineName)AS MarketingAirlineName From #airResponseResultset air  
			LEFT OUTER JOIN AirVendorLookup vendor  WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode   
			GROUP BY airlineName ,ShortName ,NoOfSTOPs   
			union   
			SELECT ( case when @isTotalPriceSort = 0 then  MIN(airPriceBASe ) else min ( airPriceBASe + airpricetax) end ), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights ,'all'    From #normalizedResultSet t     
			INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
			GROUP BY t.noOFSTOPs   
			order by MarketingAirlineName  
		END
	
		
		IF ( @isTotalPriceSort = 0 ) 
		BEGIN
		UPDATE T SET isSameAirlinesItin = 1 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode =A.airlineName AND T.LowestPrice = A.airprice  
		WHERE A.airlineName =A.otherlegAirlines AND noOfOtherlegairlines = 1 and airlineName <> 'Multiple Airlines' AND otherlegAirlines <> 'Multiple Airlines' 

		UPDATE T SET isSameAirlinesItin = 0 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode = A.airlineName AND T.LowestPrice = A.airprice  
		WHERE A.airlineName <> A.otherlegAirlines AND T.isSameAirlinesItin = 0 --and airlineName <> 'Multiple Airlines' AND otherlegAirlines <> 'Multiple Airlines' 
		END  
		ELSE 
		BEGIN 
		UPDATE T SET isSameAirlinesItin = 1 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode =A.airlineName AND T.LowestPrice =(airprice + airpricetax)
		WHERE A.airlineName =A.otherlegAirlines AND noOfOtherlegairlines = 1 and airlineName <> 'Multiple Airlines' AND otherlegAirlines <> 'Multiple Airlines' 

		UPDATE T SET isSameAirlinesItin = 0 FROM  @MatrixResult T Inner join #airResponseResultset A
		ON t.airSegmentMarketingAirlineCode = A.airlineName AND T.LowestPrice =(airprice + airpricetax)
		WHERE A.airlineName <> A.otherlegAirlines AND T.isSameAirlinesItin = 0 
		
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
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end )AS LowestPrice ,NoofsTOPs AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,air.MarketingAirlineName  ,0 AS start , 6  AS endTime ,COUNT(
		distinct air.airResponseKey ) noOFFLights   FROM #airResponseResultset  air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  AND air.airlineName = @markettingAirline 
		AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)  
		GROUP BY air.NoOfSTOPs ,air.airlineName  ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air  
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '08:00:00.0000000' AND '09:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
		INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = @markettingAirline 
		AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
		union   
		SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset air  
		INNER JOIN #normalizedResultSet page ON air.airResponseKey=page.airResponseKey WHERE    page.airlineCode = @markettingAirline AND air.gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN air.gdsSourceKey ELSE @gdssourcekey END )      
		GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName     
		END   
		ELSE   
		BEGIN   
			PRINT ('2')
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ) AS LowestPrice ,NoofsTOPs AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,'Multiple Airlines' AS MarketingAirlineName  ,0 AS start , 6
			AS endTime ,COUNT(distinct air.airResponseKey ) noOFFLights   FROM #airResponseResultset  air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  
			AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)  
			GROUP BY air.NoOfSTOPs ,air.airlineName     
			union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0
			THEN gdsSourceKey ELSE @gdssourcekey END)  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '08:00:00.0000000' AND '09:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0
			THEN gdsSourceKey ELSE @gdssourcekey END)  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union       
			SELECT(case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 
			THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT(case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName    
			union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air 
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName   
			union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName   
			Union   
			SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,01 , 23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  
			INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE air.airlineName = 'Multiple Airlines' 
			AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
			GROUP BY air.NoOfSTOPs ,air.airlineName   
		END   
	END   

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

	DECLARE @NormalMap as Table 
	( 
	rowId int Identity (1,1),
	airLegConnections varchar(100),

	airresponsekey varchar(200) , 
	NoOfStops int , 

	MinimumTotalCost decimal (12,2) ,
	MaximumTotalCost decimal (12,2) ,
	Minimumduration INT ,
	MaximumDuration INT  ,
	Airlines varchar(500),
	tripType  varchar(20),
	NoOfFlights INT

	)

	INSERT @NormalMap( airLegConnections,NoOfFlights,airresponsekey,NoOfStops,MinimumTotalCost,MaximumTotalCost ,Minimumduration ,MaximumDuration,tripType ,Airlines )

	SELECT DISTINCT A.legConnections,COUNT(DISTINCT Airresponsekey), MIN(CAST( A.airResponseKey AS varchar(200))) ,A.NoOfSTOPs ,  MIN( totalCost),MAX(totalCost) ,   MIN(legDuration)  ,MAX(legDuration)  ,
	( CASE  WHEN @airRequestType = 1 then 'OneWay' 
	WHEN @airRequestType = 2 then 'RoundTrip' 
	WHEN @airRequestType =3 then 'MultiCity' END) ,  replace( NA.airlines ,',,',',')
	FROM #airResponseResultset A inner join  
	@cityPairAirlines NA on A.legConnections= NA.airLegConnections 
	GROUP BY A.legConnections,A.NoOfSTOPs,NA.airlines 

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
	IF OBJECT_ID('TEMPDB..#tmpDeparturesLowest') IS NOT NULL
 	DROP TABLE #tmpDeparturesLowest 
	IF OBJECT_ID('TEMPDB..#tmpArrivalLowest') IS NOT NULL
	DROP TABLE #tmpArrivalLowest  
	IF OBJECT_ID('TEMPDB..#airResponseResultset') IS NOT NULL
	DROP TABLE #airResponseResultset
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses') IS NOT NULL
	DROP TABLE #AllOneWayResponses
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses_Leg1') IS NOT NULL
	DROP TABLE #AllOneWayResponses_Leg1
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses_Leg2') IS NOT NULL
	DROP TABLE #AllOneWayResponses_Leg2
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses_Legs_Merge') IS NOT NULL
	DROP TABLE #AllOneWayResponses_Legs_Merge
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses_Legs_Merge_tmp') IS NOT NULL
	DROP TABLE #AllOneWayResponses_Legs_Merge_tmp
	IF OBJECT_ID('TEMPDB..#normalizedResultSet') IS NOT NULL
	DROP TABLE #normalizedResultSet
	IF OBJECT_ID('TEMPDB..#pagingResultSet') IS NOT NULL
	DROP TABLE #pagingResultSet
	IF OBJECT_ID('TEMPDB..#pagingResultSetTemp') IS NOT NULL
	DROP TABLE #pagingResultSetTemp
	IF OBJECT_ID('TEMPDB..#AllOneWaywithAdditional') IS NOT NULL
	DROP TABLE #AllOneWaywithAdditional
	IF OBJECT_ID('TEMPDB..#AdditionalFares') IS NOT NULL
	DROP TABLE #AdditionalFares
	IF OBJECT_ID('TEMPDB..#Temp_Group') IS NOT NULL
	DROP TABLE #Temp_Group
	IF OBJECT_ID('TEMPDB..#temp') IS NOT NULL
		DROP TABLE #temp
	IF OBJECT_ID('TEMPDB..#AllOneWayResponses_Leg2_1') IS NOT NULL
		DROP TABLE #AllOneWayResponses_Leg2_1
	IF OBJECT_ID('TEMPDB..#DataProcess') IS NOT NULL
	DROP TABLE #DataProcess
	IF OBJECT_ID('TEMPDB..#AirResponse') IS NOT NULL
		DROP TABLE #AirResponse
	IF OBJECT_ID('TEMPDB..#Airsegments') IS NOT NULL
		DROP TABLE #Airsegments
	IF OBJECT_ID('TEMPDB..#NormalizedAirResponses') IS NOT NULL
		DROP TABLE #NormalizedAirResponses
	IF OBJECT_ID('TEMPDB..#AirResponseMultiBrand') IS NOT NULL
		DROP TABLE #AirResponseMultiBrand
	IF OBJECT_ID('TEMPDB..#AirSegmentsMultiBrand') IS NOT NULL
		DROP TABLE #AirSegmentsMultiBrand
	IF OBJECT_ID('TEMPDB..#airSegmentMultiBrandResultset') IS NOT NULL
		DROP TABLE #airSegmentMultiBrandResultset
	IF OBJECT_ID('TEMPDB..#AirSubRequest') IS NOT NULL
		DROP TABLE #AirSubRequest
	IF OBJECT_ID('TEMPDB..#NormalizedAirResponsesMultiBrand') IS NOT NULL
		DROP TABLE #NormalizedAirResponsesMultiBrand
	IF OBJECT_ID('TEMPDB..#AirSegmentsMultiBrand') IS NOT NULL
		DROP TABLE #AirSegmentsMultiBrand
	IF OBJECT_ID('TEMPDB..#Final') IS NOT NULL
		DROP TABLE #Final

GO
