SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec USP_GetAirResponsesForDomesticSearch @airSubRequestKey=3219988,@airRequestTypeKey=1,@SuperSetairLines=N'',@allowedOperatingAirlines=N'',@airLines=N'',@price=2147483647,@pageNo=0,@pageSize=30,@NoOfStops=N'-1',@drillDownLevel=N'0',@gdsSourcekey=2,@minTakeOffDate='2017-08-10 00:00:00',@maxTakeOffDate='2019-11-10 00:00:00',@minLandingDate='2017-08-10 00:00:00',@maxLandingDate='2019-11-10 00:00:00',@isIgnoreAirlineFilter=N'False',@isTotalPriceSort=N'True',@excludeAirline=N'WN',@IsLoginedAirlineList=N'WN',@siteKey=9,@matrixView=1,@maxNoofstops=2,@MaxDomesticFareTotal=0,@UserKey=0,@UserGroupKey=0,@CompanyKey=232,@CutOffSalesPriorDepartureInMinutes=35,@isMultiBrand=1

CREATE PROCEDURE [dbo].[USP_GetAirResponsesForDomesticSearch_org](  
--DECLARE
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
	@changeOverTimeinMinutes_AlternateAirport int = 180
	) AS  

-- SELECT @airSubRequestKey=194536,@airRequestTypeKey=1,@SuperSetairLines=N'',@allowedOperatingAirlines=N'',@airLines=N'',@price=2147483647,@pageNo=0,@pageSize=30,@NoOfStops=N'-1',@drillDownLevel=N'0',@gdsSourcekey=2,@minTakeOffDate='2018-08-09 00:00:00',@maxTakeOffDate='2020-11-09 00:00:00',@minLandingDate='2018-08-09 00:00:00',@maxLandingDate='2020-11-09 00:00:00',@isIgnoreAirlineFilter=N'False',@isTotalPriceSort=N'True',@excludeAirline=N'WN',@siteKey=9,@matrixView=1,@maxNoofstops=2,@MaxFareTotal=0,@UserKey=739,@UserGroupKey=234,@CompanyKey=335,@CutOffSalesPriorDepartureInMinutes=35,@isMultiBrand=1,@isCabinUniquification=1,@EventId=0,@changeOverTimeinMinutes=60,@changeOverTimeinMinutes_AlternateAirport=180,@IsDomesticRegionTravel=1,@IsSameDayReturnOWAllowed=1
DECLARE @AuditPerformance_STARDATETIME DATETIME=GETDATE()
	SET NOCOUNT ON   
	DECLARE @FirstRec INT  
	DECLARE @LastRec INT  
	DECLARE @isExcludeAirlinesPresent BIT = 0 , @isExcludeCountryPresent BIT = 0, @isLoggedinAirlinesPresent BIT = 0, @isOutOfPolicyResultsPresent BIT = 0
	DECLARE @legTwoLowestFare AS FLOAT = 0
	DECLARE @selectedLeg1RoundTripFare AS FLOAT 
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
	--DECLARE @isOWCallsExecuted BIT = 0
	DECLARe @airSubRequestLeg2 AS INT
	DECLARE @HighFareTotal AS FLOAT = 0, @LowFareThreshold AS FLOAT = 0, @IsLowFareThreshold AS BIT = 0, @LowestPrice AS FLOAT = 0, @IsHideFare AS BIT = 0, @isAirlineUniquification AS BIT = 0,@IsHighFareTotal AS BIT = 0;
	DECLARE @isSameDayReturnOWLogicToApply AS BIT =0, @IsPolicyApplicable BIT=0
	DECLARE @isSameDaySearch AS BIT = 0
	DECLARE @TripFromDate DATETIME
	--DECLARE @leg2ResultCame BIT = 0   

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
	--,CONSTRAINT [PK1_tempAirSubRequest_1] PRIMARY KEY CLUSTERED 
	--(
	--	[airSubRequestKey] 
	--)
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
	--, CONSTRAINT [PK_AirResponse_1] PRIMARY KEY CLUSTERED
	-- (
	--	[airResponseID] 
	-- )
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
		[airsegmentPricingKey] [nvarchar](20),
		[airsegmentFareCategory] [nvarchar](100),
		[airSegmentBrandName] [nvarchar](100),
		[airSegmentBrandID] [nvarchar](100),
		[airSegmentBaggage] [nvarchar](100),
		[airSegmentMealCode] [nvarchar](100),
		[airSegmentStops] [int],
		[ProgramCode] [varchar](20),
		[isReturnFare] [bit] NULL
	--, CONSTRAINT [PK_AirSegments_1] PRIMARY KEY CLUSTERED 
	--(
	--	[airSegmentId] 
	--)
	) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX [IDX_airSegmentId]	ON #Airsegments ([airSegmentId]) 

	CREATE NONCLUSTERED INDEX [IDX_airLegNumber_SegmentOrder_DepartureAirport] ON #Airsegments ([airLegNumber],[segmentOrder],[airSegmentDepartureAirport]) 
			INCLUDE ([airResponseKey],[airSegmentArrivalOffset],[airSegmentDepartureOffset])
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
		[airSegmentPricingKey] [nvarchar](10) NULL,
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

    --SET @airRequestKey =( SELECT TOP 1 airRequestKey  FROM AirSubRequest WITH(NOLOCK) WHERE airSubRequestKey = @airSubRequestKey )  
    --SELECT * INTO #AirSubRequest FROM AirSubRequest WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM AirSubRequest WHERE airrequestKey = @airRequestKey)
	INSERT INTO #AirSubRequest 
    SELECT * FROM AirSubRequest WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM AirSubRequest WITH(NOLOCK) WHERE airrequestKey = @airRequestKey)

	--SELECT @isInternationalTrip = (SELECT isInternationalTrip FROM AirRequest WITH(NOLOCK) where airRequestKey = @airRequestKey)
	--SELECT @airSubRequestLeg2 = (SELECT AirSubRequestkey FROM #AirSubRequest where groupKey = 1 and airSubRequestLegIndex > 1)

	SELECT @isInternationalTrip = isInternationalTrip FROM AirRequest WITH(NOLOCK) where airRequestKey = @airRequestKey
	SELECT @airSubRequestLeg2 = AirSubRequestkey FROM #AirSubRequest where groupKey = 1 and airSubRequestLegIndex > 1

    --SELECT * INTO #AirResponse FROM AirResponse WHERE airSubRequestKey IN (SELECT airSubRequestKey FROM #AirSubRequest)
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

    --SELECT * INTO #Airsegments FROM AirSegments WHERE airResponseKey in (SELECT airResponseKey FROM #AirResponse)
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
		
		
		INSERT INTO log..AuditPerformance( TripRequestkey, CreateDate, SLACategory, SLASubCategory, [Page], APIName, StartDate, EndDate, Connector, ResponseTime)
		SELECT         TripRequestkey=(SELECT tripRequestKey FROM TripRequest_air WHERE airRequestKey = @airRequestKey)
		, CreateDate=GETDATE(), SLACategory='Shopping', SLASubCategory='Air', [Page]='List', APIName='USP_GetAirResponsesForDomesticSearch'
		, StartDate=@AuditPerformance_STARDATETIME, EndDate=GETDATE(), Connector='DB'
		, ResponseTime= DATEDIFF(ms, @AuditPerformance_STARDATETIME,GETDATE())
		--@AuditPerformance_STARDATETIME
GO
