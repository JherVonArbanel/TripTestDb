SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

CREATE PROCEDURE [dbo].[USP_GetBundledAirResponsesMultiCityMultiLeg]
(  
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
   @allowedOperatingAirlines varchar(400)=''    ,
   @excludeAirline varchar ( 500) = '',
   @excludedCountries varchar ( 500) = '',
   @siteKey int = 0,
   @CutOffSalesPriorDepartureInMinutes INT = 35,
   @OWFareReplace bit = 0,
   @isDomestic bit = 0,
   @MaxFareTotal FLOAT = 0
 )  
  AS   
 SET NOCOUNT ON   
 DECLARE @FirstRec INT  
 DECLARE @LastRec INT  
 DECLARE @isExcludeAirlinesPresent BIT = 0  ,@isExcludeCountryPresent BIT = 0 
 -- Initialize variables. 
 ---STEP1 - GET PAGE VARIABLES . NOT USED IN ANY OF PROJECTS 
 SET @FirstRec = (@pageNo  - 1) * @PageSize  
 SET @LastRec = (@pageNo  * @PageSize + 1)  
  
  -- print (cast(getdate() AS time))  
   ---STEP2 -GET ALL BUNDLED SUBREQUESTKEYS (NORMAL & PUBLISHED)
 DECLARE @airRequestKey AS int   
 SET @airRequestKey =( SELECT TOP 1 airRequestKey  FROM AirSubRequest WHERE airSubRequestKey = @airSubRequestKey )  
  
 DECLARE @airBundledRequest AS int   
 SET @airBundledRequest = (SELECT TOP 1 AirSubRequestKey FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = -1 And groupKey = 1 )   
    
 DECLARE @airPublishedFareRequest AS int   
 SET @airPublishedFareRequest = (SELECT TOP 1 AirSubRequestKey FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = -1 And groupKey = 2 )   

    
  /******/  
--  STEP3-CREATE TEMP VARIABLE FOR AirSegments 
 DECLARE @AirSegments AS  TABLE    
 (  
 airSegmentKey uniqueidentifier ,  
 airResponseKey uniqueidentifier   ,  
 airLegNumber int NOT NULL,  
 airSegmentMarketingAirlineCode varchar(2)  ,  
 airSegmentOperatingAirlineCode varchar(2)  ,  
 airSegmentFlightNumber int  ,  
 airSegmentDuration time(7)  ,  
 airSegmentEquipment nvarchar(50)  ,  
 airSegmentMiles int  ,  
 airSegmentDepartureDate datetime  ,  
 airSegmentArrivalDate datetime  ,  
 airSegmentDepartureAirport varchar(50)  ,  
 airSegmentArrivalAirport varchar(50)  ,  
 airSegmentResBookDesigCode varchar(50)  ,  
 airSegmentDepartureOffset float  ,  
 airSegmentArrivalOffset float   ,  
 airSegmentSeatRemaining  int ,  
 airSegmentMarriageGrp char(10),  
 airFareBasisCode varchar(50) ,  
 airFareReferenceKey varchar(400),  
 airSegmentOperatingFlightNumber int ,  
 airsegmentCabin varchar (20) ,
 segmentOrder int,
 airSegmentOperatingAirlineCompanyShortName VARCHAR(100),
 airSubRequestkey int
 )  
 
	 INSERT into @AirSegments ( airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate
	,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin ,segmentOrder,airSegmentOperatingAirlineCompanyShortName,airSubRequestkey)  
	 (SELECT airSegmentKey,SEG.airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,(case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,
	airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,airSegmentOperatingAirlineCompanyShortName,resp.airSubRequestKey
	  From AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey    
	 INNER JOIN AirSubRequest sub on sub.airSubRequestKey = resp.airSubRequestKey   
	  LEFT OUTER JOIN AircraftsLookup on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)  
	 WHERE  airRequestKey = @airRequestKey 
	 AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) ) 
	 --select 'AirSegments' 
	  --select 'AirSegments',* from @AirSegments
	  --return
	  --select DISTINCT(AirResponsekey)
	  --FROM @AirSegments
	 --return
	 
DECLARE @NormalizedAirResponses AS TABLE(
[airresponsekey] [uniqueidentifier] NULL,
	[flightNumber] [varchar](100) NULL,
	[airlines] [varchar](100) NULL,
	[airsubrequestkey] [int] NULL,
	[airLegNumber] [int] NULL,
	[airLegBookingClasses] [varchar](50) NULL,
	[operatingAirlines] [varchar](200) NULL,
	[airLegConnections] [varchar](200) NULL
)	
INSERT INTO @NormalizedAirResponses (airresponsekey,flightNumber,airlines,airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections) 
(SELECT airresponsekey,flightNumber,airlines,NR.airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections 
From NormalizedAirResponses NR INNER JOIN AirSubRequest sub 
ON NR.airsubrequestkey = sub.airSubRequestKey
WHERE airRequestKey = @airRequestKey AND (sub.airSubRequestKey ! = @airBundledRequest or sub.airSubRequestKey ! = @airBundledRequest))
 
 --select 'normalizedairResponses',* from @NormalizedAirResponses
 --return 
	--  STEP4-GET START & END AIRPORT
	   /***code for date time offset ****/  
	 DECLARE @startAirPort AS varchar(100)   
	 DECLARE @endAirPort AS varchar(100)   
	 SELECT  @startAirPort=  airRequestDepartureAirport ,@endAirPort=airRequestArrivalAirport FROM AirSubRequest WHERE  airSubRequestKey = @airSubRequestKey   
	  
	 
	DECLARE @tempResponseToRemove AS table ( airresponsekey uniqueidentifier )   

	-- declare Tables
	DECLARE @tblAirlinesGroup AS TABLE ( marketingAirline varchar(10),operatingAirline varchar(10), groupKey int)
	DECLARE @tblSuperAirlines AS TABLE ( marketingAirline varchar(10))
	DECLARE @tblOperatingAirlines AS TABLE ( operatingAirline VARCHAR(10))
	DECLARE @tblExcludedAirlines AS TABLE ( excludeAirline VARCHAR(10))	  
	DECLARE @tblExcludedCountries AS TABLE ( excludeCountry VARCHAR(10))	  	  
	DECLARE @tblExcludedAirport AS TABLE ( excludeAirport VARCHAR(10))	  
	DECLARE @tblExcludeNonDiscountedFareAirlines AS TABLE ( marketingAirline varchar(10))	
	
--SETP5 :GET ALL RESPONSES TO REMOVE BASED ON FILTERS 
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
				(SELECT DISTINCT s.airResponseKey FROM AirSegments s WITH(NOLOCK) 
				INNER JOIN AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
				INNER JOIN AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
				WHERE airRequestKey = @airRequestKey 
				AND airSegmentMarketingAirlineCode in (SELECT * FROM @tblExcludeNonDiscountedFareAirlines) 
				AND (resp.fareType is NULL OR ltrim(rtrim(resp.fareType))=''))
			END	
		END
					
		-- Add all responsekey to @tempResponseToRemove EXCEPT combinations from @tblAirlinesGroup table
		IF (SELECT COUNT(*) FROM @tblAirlinesGroup) > 0
		BEGIN
			INSERT @tempResponseToRemove (airresponsekey )
			(SELECT DISTINCT S.airresponsekey FROM AirSegments S WITH(NOLOCK) 
			INNER JOIN AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
			INNER JOIN AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
			WHERE airRequestKey = @airRequestKey AND SUB.groupKey = 1
			AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
			(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 1))
			
			IF @airPublishedFareRequest > 0 -- For GroupKey 2(Publish fares)
			BEGIN
				INSERT @tempResponseToRemove (airresponsekey )
				(SELECT DISTINCT S.airresponsekey FROM AirSegments S WITH(NOLOCK) 
				INNER JOIN AirResponse AR WITH(NOLOCK)  ON S.airResponseKey = Ar.airResponseKey 
				INNER JOIN AirSubRequest SUB WITH(NOLOCK) ON Ar.airSubRequestKey = SUB.airSubRequestKey 		
				WHERE airRequestKey = @airRequestKey AND SUB.groupKey = 2
				AND S.airSegmentMarketingAirlineCode + S.airSegmentOperatingAirlineCode NOT IN 
				(SELECT AG.marketingAirline + AG.operatingAirline FROM @tblAirlinesGroup AG WHERE AG.groupKey = 2))
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
		(SELECT DISTINCT s.airResponseKey FROM AirSegments s WITH(NOLOCK) 
		INNER JOIN AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		INNER JOIN AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airRequestKey = @airRequestKey and airSegmentMarketingAirlineCode IN (SELECT * FROM @tblExcludedAirlines))

	  IF((SELECT COUNT(DISTINCT s.airResponseKey) FROM AirSegments s WITH(NOLOCK) 
	  INNER JOIN AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
	  INNER JOIN AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
	  WHERE airRequestKey = @airRequestKey and airSegmentMarketingAirlineCode IN (SELECT * FROM @tblExcludedAirlines) )> 0 ) 
	  BEGIN
		SET @isExcludeAirlinesPresent =  1 
	  END 

		-- to exclude operating airlines
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT DISTINCT s.airResponseKey FROM AirSegments s WITH(NOLOCK) 
		INNER JOIN AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		INNER JOIN AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airRequestKey = @airRequestKey and airSegmentOperatingAirlineCode in (SELECT * FROM @tblExcludedAirlines))

  		IF ( @isExcludeAirlinesPresent = 0 ) 
		BEGIN
			IF((SELECT COUNT(DISTINCT s.airResponseKey )FROM AirSegments s WITH(NOLOCK) 
		INNER JOIN AirResponse resp WITH(NOLOCK) ON s.airResponseKey =resp.airResponseKey   
		INNER JOIN AirSubRequest subReq WITH(NOLOCK) ON resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airRequestKey = @airRequestKey and airSegmentOperatingAirlineCode in (SELECT * FROM @tblExcludedAirlines))>0) 
			BEGIN
				SET @isExcludeAirlinesPresent =  1 
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
		FROM AirportLookup A
		INNER JOIN @tblExcludedCountries T ON A.CountryCode = T.excludeCountry
		
		-- to Exclude Airports
		INSERT @tempResponseToRemove (airresponsekey)   
		(SELECT DISTINCT s.airResponseKey FROM AirSegments s WITH(NOLOCK) 
		INNER JOIN AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airRequestKey = @airRequestKey 
		AND ((S.airSegmentDepartureAirport IN (SELECT * FROM @tblExcludedAirport)) OR (S.airSegmentArrivalAirport IN (SELECT * FROM @tblExcludedAirport))))
		
		IF((SELECT COUNT(DISTINCT s.airResponseKey) FROM AirSegments s WITH(NOLOCK) 
		INNER JOIN AirResponse resp WITH(NOLOCK) on s.airResponseKey =resp.airResponseKey   
		INNER JOIN AirSubRequest subReq WITH(NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  
		WHERE airRequestKey = @airRequestKey 
		AND ((S.airSegmentDepartureAirport IN (SELECT * FROM @tblExcludedAirport)) OR (S.airSegmentArrivalAirport IN (SELECT * FROM @tblExcludedAirport))))> 0 ) 
		BEGIN
			SET @isExcludeCountryPresent =  1 
		END 
    END
  
 ---STEP 6 CALCULATE DEPARTURE OFFSET   AND ARRIVAL OFFSET   
 DECLARE @departureOffset AS float   
 SET @departureOffset =(  SELECT distinct  TOP 1  airSegmentDepartureOffset FROM AirSegments seg INNER JOIN AirResponse r ON seg.airResponseKey =r.airResponseKey  
  WHERE(  r.airSubRequestKey = @airSubRequestKey     )  AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null  )  
 ---CALCULATE ARRIVAL OFFSET   
 DECLARE @arrivalOffset AS float   
 SET @arrivalOffset = (SELECT distinct TOP 1 airSegmentArrivalOffset  FROM AirSegments seg INNER JOIN AirResponse r ON seg.airResponseKey =r.airResponseKey  
 WHERE(  r.airSubRequestKey = @airSubRequestKey    )  AND airSegmentArrivalAirport=@endAirPort AND airSegmentArrivalOffset is not null )  
  
  
  IF ( @airRequestTypeKey = 1 AND @CutOffSalesPriorDepartureInMinutes IS NOT NULL) 
	BEGIN
		DECLARE @departOffset AS float
	    IF (@departureOffset IS NULL)
	    BEGIN
			SET @departOffset =(  SELECT  TOP 1  airSegmentDepartureOffset FROM AirSegments seg WITH (NOLOCK) INNER JOIN AirResponse r WITH (NOLOCK) ON seg.airResponseKey =r.airResponseKey
			WHERE(  r.airSubRequestKey = @airBundledRequest  )
			AND airLegNumber =@airRequestTypeKey AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null ORDER by segmentOrder ASC )
	    END
	    ELSE
	     SET @departOffset = @departureOffset
	
        DECLARE @OriginGMTTime DATETIME, @FilterDateTime DATETIME	
		SET @OriginGMTTime = DATEADD(MINUTE, (60)*(@departOffset),GETUTCDATE())
		SET @FilterDateTime = DATEADD(MINUTE,@CutOffSalesPriorDepartureInMinutes,@OriginGMTTime)
    
		--SELECT GETUTCDATE()
		--SELECT @departOffset
		--SELECT @OriginGMTTime
		--SELECT @FilterDateTime
	
		--SELECT DISTINCT seg.airResponseKey, airSegmentDepartureDate,@OriginGMTTime,@FilterDateTime from AirSegments seg WITH(NOLOCK) 
		--INNER JOIN AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		--INNER JOIN AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		--WHERE airRequestKey = @airRequestKey AND segmentOrder = 1
		----AND seg.airSegmentDepartureDate  BETWEEN  @FilterDateTime AND  seg.airSegmentDepartureDate)
		----AND DATEDIFF(MINUTE, @OriginGMTTime,seg.airSegmentDepartureDate) < (-1)*@CutOffSalesPriorDepartureInMinutes)
		----AND DATEDIFF(MINUTE,seg.airSegmentDepartureDate,@FilterDateTime) < @OriginGMTTime)
		----AND (seg.airSegmentDepartureDate > @FilterDateTime AND seg.airSegmentDepartureDate < @OriginGMTTime)
		--AND seg.airSegmentDepartureDate BETWEEN @OriginGMTTime AND @FilterDateTime
		--RETURN
	
		INSERT @tempResponseToRemove (airresponsekey ) 
		(SELECT DISTINCT seg.airResponseKey FROM AirSegments seg WITH(NOLOCK) 
		INNER JOIN AirResponse resp ON seg.airResponseKey = resp.airResponseKey   
		INNER JOIN AirSubRequest subReq ON resp.airSubRequestKey =subReq.airSubRequestKey
		WHERE airRequestKey = @airRequestKey AND segmentOrder = 1
		AND seg.airSegmentDepartureDate < @FilterDateTime)

	END
  
  
/****time offset logic ends here ***/  
  
/****logic for calculating price for higher legs *****/  
 DECLARE @airPriceForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxForAnotherLeg AS FLOAT   
 DECLARE @airPriceSeniorForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxSeniorForAnotherLeg AS FLOAT   
 DECLARE @airPriceChildrenForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxChildrenForAnotherLeg AS FLOAT   
 DECLARE @airPriceInfantForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxInfantForAnotherLeg AS FLOAT   
 DECLARE @airPriceTotalForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxTotalForAnotherLeg AS FLOAT   
 DECLARE @airPriceDisplayForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxDisplayForAnotherLeg AS FLOAT   
 DECLARE @airPriceYouthForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxYouthForAnotherLeg AS FLOAT
 DECLARE @airPriceInfantWithSeatForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxInfantWithSeatForAnotherLeg AS FLOAT
 
 DECLARE @tmpAirline  TABLE   
  (  
  airLineCode VARCHAR (200)   
  )  
    --STEP 7: CREATE @NoOfSTOPs AND @tmpAirline TABLES
	IF @NoOfSTOPs = '-1' /*****Default view WHEN no of sTOPs not SELECTed *********/  
	BEGIN   
		SET @NoOfSTOPs = '0,1,2'  
	END   

	DECLARE @noSTOPs AS table ( stops int  )  
	INSERT @noSTOPs (stops )  
	SELECT * FROM vault.dbo.ufn_CSVToTable (@NoOfSTOPs)  

	IF (SELECT gdsSourceKey  From AirResponse WHERE airResponseKey = @SELECTedResponseKey)  =  9    
	BEGIN   
		SET @airLines = (SELECT  DISTINCT TOP 1 airSegmentMarketingAirlineCode FROM AirSegments WHERE airResponseKey = @SELECTedResponseKey )  
	END   
	IF @airLines <> '' and @isIgnoreAirlineFilter <> 1    -- AND @airLines <> 'Multiple Airlines'  -- AND not exists(  SELECT @airLines WHERE @airLines like '%Multiple Airlines%')  
	BEGIN   
		INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )    
	END   
	ELSE       
	BEGIN   
		INSERT into @tmpAirline(airlineCode)  SELECT DISTINCT seg1.airSegmentMarketingAirlineCode FROM AirSegments seg1
		INNER JOIN AirResponse resp  ON seg1.airResponseKey = resp.airResponseKey WHERE 
		( resp.airSubRequestKey = @airSubRequestKey or resp .airSubRequestKey = @airBundledRequest   ) 
		
		INSERT into @tmpAirline(airlineCode)  SELECT DISTINCT seg1.airSegmentMarketingAirlineCode FROM AirSegments seg1
		INNER JOIN AirResponse resp  ON seg1.airResponseKey = resp.airResponseKey WHERE 
		(   resp .airSubRequestKey = @airPublishedFareRequest    ) 

		INSERT into @tmpAirline (airLineCode ) VALUES  ('Multiple Airlines')  
	END     

	DECLARE  @selectedDate AS DATETIME   
    
---creating TABLE variable for container for flitered result ..  
 DECLARE @airResponseResultset TABLE   
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
  NoOfStops int ,  
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
  airPriceClassSelected   varchar (50) NULL ,  
  otherLegPrice float ,  
  isRefundable bit ,  
  isbrandedFare bit ,  
  cabinClass varchar(20) ,  
  fareType varchar (20),segmentOrder int ,airsegmentCabin varchar (20),  
  totalCost float ,airSegmentOperatingFlightNumber int, otherlegtax float ,  
  isgeneratedBundle bit,
  airSegmentOperatingAirlineCompanyShortName VARCHAR(100)  ,
  airPriceBaseInfantWithSeat float,
  airPriceTaxInfantWithSeat float
 )  
  
  
 print('uniquifying started ..')  
 print (cast(getdate() AS time))  
  --STEP 8  ADD ALL LEG DETAILS IN  tempOneWayResponses
  
 DECLARE @tempOneWayResponses AS TABLE   
 (  
  airOneIdent int identity (1,1),  
  airOneResponsekey uniqueidentifier ,   
  airOnePriceBase float ,  
  airOnePriceTax float,  
  airOneBaseSenior float,
  airOneTaxSenior float,
  airOneBaseChildren float,
  airOneTaxChildren float,
  airOneBaseInfant float,
  airOneTaxInfant float,
  airOneBaseYouth float,
  airOneTaxYouth float,
  airOneBaseTotal float,
  airOneTaxTotal float,
  airOneBaseDisplay float,
  airOneTaxDisplay float,
  airSegmentFlightNumber varchar(100),  
  airSegmentMarketingAirlineCode varchar(100),  
  airsubRequestkey int   
  ,airLegConnections varchar(200),  
  airLegBookingClasses varchar(50),  
  otherLegPrice float ,  
  otherLegTax float  ,  
  cabinClass varchar(20) ,
  airlegnumber int,
  airOnePriceBaseInfantWithSeat float,
  airOnePriceTaxInfantWithSeat float
 )  
    
	INSERT @tempOneWayResponses (airOneResponsekey,airOnePriceBase,airOneBaseSenior ,airOneTaxSenior, airOneBaseChildren ,airOneTaxChildren ,airOneBaseInfant, airOneTaxInfant,airOneBaseYouth, airOneTaxYouth, airOneBaseTotal, airOneTaxTotal, airOneBaseDisplay, airOneTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax   ,cabinClass ,otherLegPrice  ,airlegnumber ,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)  
	       
	SELECT resp.AirResponsekey, airPriceBase ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay,nresp.flightNumber ,nresp.airlines,nresp.airSubRequestKey,airPriceTax ,nresp.cabinclass,(case when @isTotalPriceSort = 0 then isnull(@airPriceForAnotherLeg,0)else ( isnull(@airPriceForAnotherLeg,0) + isnull(@airPriceTaxForAnotherLeg,0))  end),nresp.airLegNumber,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
	FROM AirResponse resp  INNER JOIN NormalizedAirResponses nresp ON resp.airResponseKey = nresp .airresponsekey   
	inner join AirSubRequest sub on sub.airSubRequestKey =resp.airSubRequestKey where (resp.airSubRequestKey  = @airBundledRequest   OR resp.airSubRequestKey =@airPublishedFareRequest) AND ISNULL(resp.gdsSourceKey,2) =( CASE WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
 	  
	 --select '@tempOneWayResponses',* from @tempOneWayResponses
	 --return
	--SELECT p1.airresponsekey ,airpricebase ,  
	--( SELECT flightNumber  + ',' FROM NormalizedAirResponses p2 WHERE p2.airresponsekey = p1.airresponsekey   
	--ORDER BY airLegNumber FOR XML PATH('') ) AS flightnumber ,  
	--( SELECT airlines   + ',' FROM NormalizedAirResponses p2 WHERE p2.airresponsekey = p1.airresponsekey   
	--ORDER BY airLegNumber FOR XML PATH('') ) AS airlines ,  
	--p1.airsubrequestkey ,airPriceTax ,p1.cabinclass ,(case when @isTotalPriceSort = 0 then isnull(@airPriceForAnotherLeg,0)else ( isnull(@airPriceForAnotherLeg,0) + isnull(@airPriceTaxForAnotherLeg,0))  end)   
	--FROM NormalizedAirResponses  p1 inner join AirResponse resp on p1.airresponsekey = resp.airResponseKey   
	--inner join AirSubRequest sub on sub.airSubRequestKey =resp.airSubRequestKey where airRequestKey =@airRequestKey    
	--AND ISNULL(resp.gdsSourceKey,2) =( CASE WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )    
	--GROUP BY p1.airresponsekey  ,airpricebase ,airPriceTax,p1.cabinClass ,p1.airsubrequestkey   

   
	DECLARE @noOfLegsForRequest AS int   
	SET @noOfLegsForRequest =( SELECT COUNT(*) FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex > 0 )   

	IF @gdssourcekey = 9   
	BEGIN  
		IF ( @airLines <> 'Multiple Airlines')  
		BEGIN   
			delete from @tempOneWayResponses where airOneResponsekey in (  
			select distinct seg.airResponseKey   FROM AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey   
			INNER JOIN AirSubRequest subrequest ON resp.airSubRequestKey = subrequest .airSubRequestKey 
			and seg.airSegmentMarketingAirlineCode not in (select * From @tmpAirline )   
			WHERE   airrequestKey = @airRequestKey    AND gdsSourceKey = @gdssourcekey)  
		END  
	END   
  
	 --DELETE @tempOneWayResponses  
	 --FROM @tempOneWayResponses t,  
	 --(  
	 -- SELECT min(airOnePriceBase) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,isnull(cabinClass ,'') cabinClass  
	 -- FROM @tempOneWayResponses m  
	 -- GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode   ,isnull(cabinClass ,'')  fffffffffff
	 -- having count(1) > 1  
	 --) AS derived  
	 --WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode  AND isnull(t.cabinclass,'') =isnull(derived .cabinclass,'')   
	 --AND airOnePriceBase >= minPrice  AND airOneIdent > minIdent  
	  
	 -- print (cast(getdate() AS time))  
	 -- print('uniquifying ended ..')  
	   
	   
--STEP 9 CREATE NORMAL TABLE WITH ALL LEG DETAILS IN DENORMALIZED FORM SORTED BY PRICE ASC
IF OBJECT_ID('tempdb..#normal') IS NOT NULL  
		DROP TABLE #normal
CREATE TABLE #normal
(
id int identity (1,1),
airresponsekey uniqueidentifier,
airsubrequestkey INT ,
leg1FlightNumber varchar(100), 
leg1Airlines varchar(100),
leg1Connection varchar(100),
leg2FlightNumber varchar(100), 
leg2Airlines varchar(100),
leg2Connection varchar(100),

leg3FlightNumber varchar(100), 
leg3Airlines varchar(100),
leg3Connection varchar(100),

leg4FlightNumber varchar(100), 
leg4Airlines varchar(100),
leg4Connection varchar(100),

leg5FlightNumber varchar(100), 
leg5Airlines varchar(100),
leg5Connection varchar(100),

leg6FlightNumber varchar(100), 
leg6Airlines varchar(100),
leg6Connection varchar(100),
airPriceTotal float,
isNeedtoUpdate INT ,
leg1airResponsekey uniqueidentifier,
leg2airResponsekey uniqueidentifier,
leg3airResponsekey uniqueidentifier,
leg4airResponsekey uniqueidentifier,
leg5airResponsekey uniqueidentifier,
leg6airResponsekey uniqueidentifier,
airOnePriceBase float ,  
airOnePriceTax float,  
airOneBaseSenior float,
airOneTaxSenior float,
airOneBaseChildren float,
airOneTaxChildren float,
airOneBaseInfant float,
airOneTaxInfant float,
airOneBaseYouth float,
airOneTaxYouth float,
airOneBaseTotal float,
airOneTaxTotal float,
airOneBaseDisplay float,
airOneTaxDisplay float,   
airOnePriceBaseInfantWithSeat float,
airOnePriceTaxInfantWithSeat float


)
 INSERT INTO #normal (airresponsekey,airsubrequestkey,leg1flightnumber,leg1airlines,leg1Connection,airPriceTotal)

 SELECT  n1.airresponsekey,n1.airsubrequestkey,n1.flightNumber , n1.airlines,n1.airLegConnections ,A.airpricebaseTotal + A.airpriceTaxTotal
 --,n3.flightNumber , n3.airlines,n3.airLegConnections 
 FROM NormalizedAirResponses N1 WITH (NOLOCK) INNER JOIN AirResponse A WITH (NOLOCK) on N1.airresponsekey = A.airresponsekey
WHERE (n1.airsubrequestkey =@airBundledRequest or n1.airSubrequestkey = @airPublishedFareRequest) and airlegnumber =1 
ORDER BY (A.airpricebaseTotal + A.airpriceTaxTotal) ASC , N1.airsubrequestkey,N1.airresponsekey
---Leg2
UPDATE  N SET leg2flightNUMBER = flightNumber , leg2Airlines = N1.airlines, leg2Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK)ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 2 
UPDATE  N SET leg3flightNUMBER = flightNumber , leg3Airlines = N1.airlines, leg3Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 3 
UPDATE  N SET leg4flightNUMBER = flightNumber , leg4Airlines = N1.airlines, leg4Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 4 

UPDATE  N SET leg5flightNUMBER = flightNumber , leg5Airlines = N1.airlines, leg5Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 5 
--leg6
UPDATE  N SET leg6flightNUMBER = flightNumber , leg6Airlines = N1.airlines, leg6Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 6 
 
 --STEP 10 DELETE DUPLICATE KEEPING UNIQUES OPTIONS 
DELETE FROM #Normal 
WHERE ID not in 
(
SELECT min(ID)  FROM #normal 
group by leg1FlightNumber,leg1Airlines,leg1Connection ,leg2FlightNumber,leg2Airlines,leg2Connection,leg3FlightNumber,leg3Airlines,leg3Connection ,leg4FlightNumber,leg4Airlines,leg4Connection,leg5FlightNumber,leg5Airlines,leg5Connection,leg6FlightNumber,leg6Airlines,leg6Connection
 )
 
 Delete P    
FROM #Normal P    
INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey 

 --SELECT 'normal',* FROM #normal 
 
 IF OBJECT_ID('tempdb..#LegwiseUniqueCombination') IS NOT NULL  
		DROP TABLE #LegwiseUniqueCombination

 CREATE TABLE #LegwiseUniqueCombination  
(  
	id int identity (1,1),
	airlegnumber int ,
	legFlightNumber varchar(100), 
	legAirlines varchar(100),
	legConnection varchar(100), 
	owAirresponsekey uniqueidentifier NULL,  
	TotalOWFareToCompare float, 
	airsubrequestkey int
 )
 insert into #LegwiseUniqueCombination(airlegnumber,legFlightNumber,legAirlines,legConnection,airsubrequestkey)
 (SELECT 1,leg1FlightNumber,leg1Airlines,leg1Connection,airsubrequestkey
 FROM #normal
 group by leg1FlightNumber,leg1Airlines,leg1Connection,airsubrequestkey)
 UNION
  (SELECT 2,leg2FlightNumber,leg2Airlines,leg2Connection,airsubrequestkey
 FROM #normal
 group by leg2FlightNumber,leg2Airlines,leg2Connection,airsubrequestkey)
 UNION
  (SELECT 3,leg3FlightNumber,leg3Airlines,leg3Connection,airsubrequestkey
 FROM #normal
 group by leg3FlightNumber,leg3Airlines,leg3Connection,airsubrequestkey)
 UNION
  (SELECT 4,leg4FlightNumber,leg4Airlines,leg4Connection,airsubrequestkey
 FROM #normal
 group by leg4FlightNumber,leg4Airlines,leg4Connection,airsubrequestkey)
 UNION
  (SELECT 5,leg5FlightNumber,leg5Airlines,leg5Connection,airsubrequestkey
 FROM #normal
 group by leg5FlightNumber,leg5Airlines,leg5Connection,airsubrequestkey)
 UNION
 ( SELECT 6,leg6FlightNumber,leg6Airlines,leg6Connection,airsubrequestkey
 FROM #normal
 group by leg6FlightNumber,leg6Airlines,leg6Connection,airsubrequestkey)
 
 --select 'Legwise',* from #LegwiseUniqueCombination
 
  IF OBJECT_ID('tempdb..#UniqueLegAirResponse') IS NOT NULL  
		DROP TABLE #UniqueLegAirResponse
		
CREATE TABLE #UniqueLegAirResponse 
(
UniqueCombinationID int,
OWAirResponseKey uniqueidentifier ,
OWPrice float
)
INSERT INTO #UniqueLegAirResponse(UniqueCombinationID,OWAirResponseKey,OWPrice)
(SELECT LU.id,NR.airresponsekey,(AR.airPriceBaseTotal + AR.airPriceTaxTotal)
From #LegwiseUniqueCombination LU INNER JOIN @NormalizedAirResponses NR
ON LU.legFlightNumber = NR.flightNumber AND LU.legAirlines = NR.airlines AND LU.legConnection = NR.airLegConnections AND LU.airlegnumber = NR.airLegNumber
INNER JOIN AirResponse AR ON NR.airresponsekey = AR.airResponseKey)

--select 'Unique',* from #UniqueLegAirResponse

IF OBJECT_ID('tempdb..#FinalUniqueLegAR') IS NOT NULL  
		DROP TABLE #FinalUniqueLegAR

CREATE TABLE #FinalUniqueLegAR 
(
	ID INT
	, AirResponseKey UNIQUEIDENTIFIER
	, Price FLOAT
)

INSERT INTO #FinalUniqueLegAR
SELECT UniqueCombinationID, OWAirResponseKey, OWPrice 
FROM
(
	SELECT ROW_NUMBER() OVER(PARTITION BY UniqueCombinationID ORDER BY OWPrice ) AS RN, UniqueCombinationID, OWAirResponseKey, OWPrice 
	FROM #UniqueLegAirResponse
)t WHERE RN = 1


UPDATE CE
SET owAirresponsekey = FU.AirResponseKey,
TotalOWFareToCompare = Price
FROM #LegwiseUniqueCombination CE 
    INNER JOIN #FinalUniqueLegAR As FU
        ON CE.id = FU.ID 

IF OBJECT_ID('tempdb..#airResponseCombination') IS NOT NULL  
		DROP TABLE #airResponseCombination
CREATE TABLE #airResponseCombination
(
id int identity (1,1),
-- Need to map this also many temp will work simultaneously airsubrequestkey INT 
leg1FlightNumber varchar(100), 
leg1Airlines varchar(100),
leg1Connection varchar(100),
leg2FlightNumber varchar(100), 
leg2Airlines varchar(100),
leg2Connection varchar(100),

leg3FlightNumber varchar(100), 
leg3Airlines varchar(100),
leg3Connection varchar(100),

leg4FlightNumber varchar(100), 
leg4Airlines varchar(100),
leg4Connection varchar(100),

leg5FlightNumber varchar(100), 
leg5Airlines varchar(100),
leg5Connection varchar(100),

leg6FlightNumber varchar(100), 
leg6Airlines varchar(100),
leg6Connection varchar(100),
leg1OWPrice float,
leg2OWPrice float,
leg3OWPrice float,
leg4OWPrice float,
leg5OWPrice float,
leg6OWPrice float,
leg1airResponsekey uniqueidentifier,
leg2airResponsekey uniqueidentifier,
leg3airResponsekey uniqueidentifier,
leg4airResponsekey uniqueidentifier,
leg5airResponsekey uniqueidentifier,
leg6airResponsekey uniqueidentifier,
)
--select 'cross join'    
INSERT INTO #airResponseCombination(leg1FlightNumber,leg1Airlines,leg1Connection,leg1airResponsekey,leg1OWPrice,leg2FlightNumber,leg2Airlines,leg2Connection,leg2airResponsekey,leg2OWPrice,leg3FlightNumber,leg3Airlines,leg3Connection,leg3airResponsekey,leg3OWPrice,leg4FlightNumber,leg4Airlines,leg4Connection,leg4airResponsekey,leg4OWPrice,leg5FlightNumber,leg5Airlines,leg5Connection,leg5airResponsekey,leg5OWPrice,leg6FlightNumber,leg6Airlines,leg6Connection,leg6airResponsekey,leg6OWPrice)
   
(SELECT leg1.legFlightNumber AS leg1FlightNumber,leg1.legAirlines AS leg1Airlines,leg1.legConnection AS leg1Connection,leg1.owAirresponsekey AS leg1airResponseKey, leg1.TotalOWFareToCompare AS leg1OWPrice ,
leg2.legFlightNumber AS leg2FlightNumber,leg2.legAirlines AS leg2Airlines,leg2.legConnection AS leg2Connection,leg2.owAirresponsekey AS leg2airResponseKey, leg2.TotalOWFareToCompare AS leg2OWPrice,
leg3.legFlightNumber AS leg3FlightNumber,leg3.legAirlines AS leg3Airlines,leg3.legConnection AS leg3Connection,leg3.owAirresponsekey AS leg3airResponseKey, leg3.TotalOWFareToCompare AS leg3OWPrice,
leg4.legFlightNumber AS leg4FlightNumber,leg4.legAirlines AS leg4Airlines,leg4.legConnection AS leg4Connection,leg4.owAirresponsekey AS leg4airResponseKey, leg4.TotalOWFareToCompare AS leg4OWPrice,
leg5.legFlightNumber AS leg5FlightNumber,leg5.legAirlines AS leg5Airlines,leg5.legConnection AS leg5Connection,leg5.owAirresponsekey AS leg5airResponseKey, leg5.TotalOWFareToCompare AS leg5OWPrice,
leg6.legFlightNumber AS leg6FlightNumber,leg6.legAirlines AS leg6Airlines,leg6.legConnection AS leg6Connection,leg6.owAirresponsekey AS leg6airResponseKey, leg6.TotalOWFareToCompare AS leg6OWPrice
 from 
#LegwiseUniqueCombination leg1
CROSS JOIN
#LegwiseUniqueCombination leg2
CROSS JOIN
#LegwiseUniqueCombination leg3
CROSS JOIN
#LegwiseUniqueCombination leg4
CROSS JOIN
#LegwiseUniqueCombination leg5
CROSS JOIN
#LegwiseUniqueCombination leg6
where leg1.airlegnumber = 1 AND leg2.airlegnumber = 2
AND leg3.airlegnumber = 3 AND leg4.airlegnumber = 4
AND leg5.airlegnumber = 5 AND leg6.airlegnumber = 6)

--select 'AirResponseCombination',* from #airResponseCombination

update #normal
set isNeedtoUpdate = 1,
leg1airResponsekey = AR.leg1airResponsekey,leg2airResponsekey = AR.leg2airResponsekey,leg3airResponsekey = AR.leg3airResponsekey,
leg4airResponsekey = AR.leg4airResponsekey,leg5airResponsekey = AR.leg5airResponsekey,leg6airResponsekey = AR.leg6airResponsekey
FROM #normal NN
	INNER JOIN #airResponseCombination AR
		ON NN.leg1FlightNumber = AR.leg1FlightNumber AND NN.leg1Airlines = AR.leg1Airlines AND NN.leg1Connection = AR.leg1Connection AND
		NN.leg2FlightNumber = AR.leg2FlightNumber AND NN.leg2Airlines = AR.leg2Airlines AND NN.leg2Connection = AR.leg2Connection AND
		NN.leg3FlightNumber = AR.leg3FlightNumber AND NN.leg3Airlines = AR.leg3Airlines AND NN.leg3Connection = AR.leg3Connection AND
		ISNULL(NN.leg4FlightNumber,'') = ISNULL(AR.leg4FlightNumber,'') AND ISNULL(NN.leg4Airlines,'') = ISNULL(AR.leg4Airlines,'') AND 
		ISNULL(NN.leg4Connection,'') = ISNULL(AR.leg4Connection,'') AND
		ISNULL(NN.leg5FlightNumber,'') = ISNULL(AR.leg5FlightNumber,'') AND ISNULL(NN.leg5Airlines,'') = ISNULL(AR.leg5Airlines,'') AND 
		ISNULL(NN.leg5Connection,'') = ISNULL(AR.leg5Connection,'') AND
		ISNULL(NN.leg6FlightNumber,'') = ISNULL(AR.leg6FlightNumber,'') AND ISNULL(NN.leg6Airlines,'') = ISNULL(AR.leg6Airlines,'') AND 
		ISNULL(NN.leg6Connection,'') = ISNULL(AR.leg6Connection,'')
		WHERE NN.airPriceTotal > (AR.leg1OWPrice + AR.leg2OWPrice + AR.leg3OWPrice + ISNULL(AR.leg4OWPrice,0) + ISNULL(AR.leg5OWPrice,0)
		+ ISNULL(AR.leg6OWPrice,0))
		
If(@noOfLegsForRequest = 3)
BEGIN
	UPDATE #normal
	SET isNeedtoUpdate = 0
	FROM #normal NN
	WHERE ((NN.leg1airResponsekey IS NULL) OR (NN.leg2airResponsekey IS NULL) OR (NN.leg3airResponsekey IS NULL))
END
ELSE IF (@noOfLegsForRequest = 4)	
BEGIN
	UPDATE #normal
	SET isNeedtoUpdate = 0
	FROM #normal NN
	WHERE ((NN.leg1airResponsekey IS NULL) OR (NN.leg2airResponsekey IS NULL) OR (NN.leg3airResponsekey IS NULL) OR (NN.leg4airResponsekey IS NULL))
END
ELSE IF (@noOfLegsForRequest = 5)
BEGIN
	UPDATE #normal
	SET isNeedtoUpdate = 0
	FROM #normal NN
	WHERE ((NN.leg1airResponsekey IS NULL) OR (NN.leg2airResponsekey IS NULL) OR (NN.leg3airResponsekey IS NULL) OR (NN.leg4airResponsekey IS NULL) OR 
	(NN.leg5airResponsekey IS NULL))
END
ELSE IF(@noOfLegsForRequest = 6)
BEGIN
	UPDATE #normal
	SET isNeedtoUpdate = 0
	FROM #normal NN
	WHERE ((NN.leg1airResponsekey IS NULL) OR (NN.leg2airResponsekey IS NULL) OR (NN.leg3airResponsekey IS NULL) OR (NN.leg4airResponsekey IS NULL) OR 
	(NN.leg5airResponsekey IS NULL) OR (NN.leg6airResponsekey IS NULL))
END
	
--SELECT 'NORMAL After Update',* FROM #NORMAL
IF OBJECT_ID('tempdb..#tempOneWayResponses_TEMP') IS NOT NULL  
		DROP TABLE #tempOneWayResponses_TEMP
 CREATE TABLE #tempOneWayResponses_TEMP  
 (  
  airOneIdent int identity (1,1),
  airOneResponsekey uniqueidentifier ,   
  airOnePriceBase float ,  
  airOnePriceTax float,  
  airOneBaseSenior float,
  airOneTaxSenior float,
  airOneBaseChildren float,
  airOneTaxChildren float,
  airOneBaseInfant float,
  airOneTaxInfant float,
  airOneBaseYouth float,
  airOneTaxYouth float,
  airOneBaseTotal float,
  airOneTaxTotal float,
  airOneBaseDisplay float,
  airOneTaxDisplay float,  
  airOnePriceBaseInfantWithSeat float,
  airOnePriceTaxInfantWithSeat float
 ) 
 
 INSERT #tempOneWayResponses_TEMP (airOneResponsekey,airOnePriceBase,airOnePriceTax,airOneBaseSenior ,airOneTaxSenior, airOneBaseChildren ,airOneTaxChildren ,airOneBaseInfant, airOneTaxInfant,airOneBaseYouth, airOneTaxYouth, airOneBaseTotal, airOneTaxTotal, airOneBaseDisplay, airOneTaxDisplay,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)  
	       
	(SELECT NN.airresponsekey,resp.airPriceBase ,resp.airPriceTax,resp.airPriceBaseSenior,resp.airPriceTaxSenior,resp.airPriceBaseChildren,resp.airPriceTaxChildren,resp.airPriceBaseInfant,resp.airPriceTaxInfant,resp.airPriceBaseYouth,resp.airPriceTaxYouth,resp.airPriceBaseTotal,resp.airPriceTaxTotal,resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
	FROM AirResponse resp  INNER JOIN #normal NN on resp.airResponseKey = NN.leg1airResponsekey  
	where NN.isNeedtoUpdate = 1)
	UNION ALL
	(SELECT NN.airresponsekey,resp.airPriceBase ,resp.airPriceTax,resp.airPriceBaseSenior,resp.airPriceTaxSenior,resp.airPriceBaseChildren,resp.airPriceTaxChildren,resp.airPriceBaseInfant,resp.airPriceTaxInfant,resp.airPriceBaseYouth,resp.airPriceTaxYouth,resp.airPriceBaseTotal,resp.airPriceTaxTotal,resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
	FROM AirResponse resp  INNER JOIN #normal NN on resp.airResponseKey = NN.leg2airResponsekey  
	where NN.isNeedtoUpdate = 1) 
	UNION ALL
	(SELECT NN.airresponsekey,resp.airPriceBase ,resp.airPriceTax,resp.airPriceBaseSenior,resp.airPriceTaxSenior,resp.airPriceBaseChildren,resp.airPriceTaxChildren,resp.airPriceBaseInfant,resp.airPriceTaxInfant,resp.airPriceBaseYouth,resp.airPriceTaxYouth,resp.airPriceBaseTotal,resp.airPriceTaxTotal,resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
	FROM AirResponse resp  INNER JOIN #normal NN on resp.airResponseKey = NN.leg3airResponsekey  
	where NN.isNeedtoUpdate = 1) 
	UNION ALL
	(SELECT NN.airresponsekey,resp.airPriceBase ,resp.airPriceTax,resp.airPriceBaseSenior,resp.airPriceTaxSenior,resp.airPriceBaseChildren,resp.airPriceTaxChildren,resp.airPriceBaseInfant,resp.airPriceTaxInfant,resp.airPriceBaseYouth,resp.airPriceTaxYouth,resp.airPriceBaseTotal,resp.airPriceTaxTotal,resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
	FROM AirResponse resp  INNER JOIN #normal NN on resp.airResponseKey = NN.leg4airResponsekey  
	where NN.isNeedtoUpdate = 1) 
	UNION ALL
	(SELECT NN.airresponsekey,resp.airPriceBase ,resp.airPriceTax,resp.airPriceBaseSenior,resp.airPriceTaxSenior,resp.airPriceBaseChildren,resp.airPriceTaxChildren,resp.airPriceBaseInfant,resp.airPriceTaxInfant,resp.airPriceBaseYouth,resp.airPriceTaxYouth,resp.airPriceBaseTotal,resp.airPriceTaxTotal,resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
	FROM AirResponse resp  INNER JOIN #normal NN on resp.airResponseKey = NN.leg5airResponsekey  
	where NN.isNeedtoUpdate = 1) 
	UNION ALL
	(SELECT NN.airresponsekey,resp.airPriceBase ,resp.airPriceTax,resp.airPriceBaseSenior,resp.airPriceTaxSenior,resp.airPriceBaseChildren,resp.airPriceTaxChildren,resp.airPriceBaseInfant,resp.airPriceTaxInfant,resp.airPriceBaseYouth,resp.airPriceTaxYouth,resp.airPriceBaseTotal,resp.airPriceTaxTotal,resp.airPriceBaseDisplay,resp.airPriceTaxDisplay,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
	FROM AirResponse resp  INNER JOIN #normal NN on resp.airResponseKey = NN.leg6airResponsekey  
	where NN.isNeedtoUpdate = 1) 
--SELECT '#tempOneWayResponses_TEMP' ,* FROM #tempOneWayResponses_TEMP
--RETURN
IF OBJECT_ID('tempdb..#tempOneWayResponses_GROUPED') IS NOT NULL  
		DROP TABLE #tempOneWayResponses_GROUPED
 CREATE TABLE #tempOneWayResponses_GROUPED  
 (  
  airOneIdent int identity (1,1),
  airOneResponsekey uniqueidentifier ,   
  airOnePriceBase float ,  
  airOnePriceTax float,  
  airOneBaseSenior float,
  airOneTaxSenior float,
  airOneBaseChildren float,
  airOneTaxChildren float,
  airOneBaseInfant float,
  airOneTaxInfant float,
  airOneBaseYouth float,
  airOneTaxYouth float,
  airOneBaseTotal float,
  airOneTaxTotal float,
  airOneBaseDisplay float,
  airOneTaxDisplay float,  
  airOnePriceBaseInfantWithSeat float,
  airOnePriceTaxInfantWithSeat float
 )
 
  INSERT #tempOneWayResponses_GROUPED (airOneResponsekey,airOnePriceBase,airOnePriceTax,airOneBaseSenior ,airOneTaxSenior, airOneBaseChildren ,airOneTaxChildren ,airOneBaseInfant, airOneTaxInfant,airOneBaseYouth, airOneTaxYouth, airOneBaseTotal, airOneTaxTotal, airOneBaseDisplay, airOneTaxDisplay,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)  
	       
	SELECT airOneResponsekey,SUM(airOnePriceBase),SUM(airOnePriceTax),SUM(airOneBaseSenior) ,SUM(airOneTaxSenior), SUM(airOneBaseChildren) ,SUM(airOneTaxChildren) ,SUM(airOneBaseInfant), SUM(airOneTaxInfant),SUM(airOneBaseYouth), SUM(airOneTaxYouth), SUM(airOneBaseTotal), SUM(airOneTaxTotal), SUM(airOneBaseDisplay), SUM(airOneTaxDisplay),SUM(airOnePriceBaseInfantWithSeat),SUM(airOnePriceTaxInfantWithSeat)
	FROM #tempOneWayResponses_TEMP 
	GROUP BY airOneResponsekey
--SELECT '##tempOneWayResponses_GROUPED' ,* FROM #tempOneWayResponses_GROUPED	
IF OBJECT_ID('tempdb..#tempOneWayResponses_OW') IS NOT NULL  
		DROP TABLE #tempOneWayResponses_OW
 CREATE TABLE #tempOneWayResponses_OW  
 (  
  airOneIdent int identity (1,1),
  airOneResponsekey uniqueidentifier ,   
  airOnePriceBase float ,  
  airOnePriceTax float,  
  airOneBaseSenior float,
  airOneTaxSenior float,
  airOneBaseChildren float,
  airOneTaxChildren float,
  airOneBaseInfant float,
  airOneTaxInfant float,
  airOneBaseYouth float,
  airOneTaxYouth float,
  airOneBaseTotal float,
  airOneTaxTotal float,
  airOneBaseDisplay float,
  airOneTaxDisplay float, 
  airSegmentFlightNumber varchar(100),  
  airSegmentMarketingAirlineCode varchar(100),  
  airsubRequestkey int,   
  airLegConnections varchar(200),  
  airLegBookingClasses varchar(50),  
  otherLegPrice float ,  
  otherLegTax float  ,  
  cabinClass varchar(20) ,
  airlegnumber int,  
  airOnePriceBaseInfantWithSeat float,
  airOnePriceTaxInfantWithSeat float
 ) 
 	INSERT #tempOneWayResponses_OW (airOneResponsekey,airOnePriceBase,airOnePriceTax,airOneBaseSenior ,airOneTaxSenior, airOneBaseChildren ,airOneTaxChildren ,airOneBaseInfant, airOneTaxInfant,airOneBaseYouth, airOneTaxYouth, airOneBaseTotal, airOneTaxTotal, airOneBaseDisplay, airOneTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,  otherLegPrice  , cabinClass,airlegnumber,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)  
	       
	SELECT TM.airOneResponsekey , TM.airOnePriceBase ,TM.airOnePriceTax,TM.airOneBaseSenior,TM.airOneTaxSenior,TM.airOneBaseChildren,TM.airOneTaxChildren,TM.airOneBaseInfant,TM.airOneTaxInfant,TM.airOneBaseYouth,TM.airOneTaxYouth,TM.airOneBaseTotal,TM.airOneTaxTotal,TM.airOneBaseDisplay,TM.airOneTaxDisplay,nresp.flightNumber ,nresp.airlines,nresp.airSubRequestKey,(case when @isTotalPriceSort = 0 then isnull(@airPriceForAnotherLeg,0)else ( isnull(@airPriceForAnotherLeg,0) + isnull(@airPriceTaxForAnotherLeg,0))  end),nresp.cabinclass,nresp.airLegNumber,TM.airOnePriceBaseInfantWithSeat,TM.airOnePriceTaxInfantWithSeat
	FROM NormalizedAirResponses nresp 
	INNER JOIN #tempOneWayResponses_GROUPED TM ON NRESP.airresponsekey = TM.airOneResponsekey 
	
	--SELECT 'tempOneWayResponses_OW',* FROM #tempOneWayResponses_OW
	delete t1 FROM @tempOneWayResponses t1
		INNER JOIN #tempOneWayResponses_OW t2 ON t1.airOneResponsekey = t2.airOneResponsekey
		--SELECT 'AFTER DELETE @tempOneWayResponses',* FROM @tempOneWayResponses
		--SELECT '_OW',* FROM #tempOneWayResponses_OW
	INSERT INTO @tempOneWayResponses(airOneResponsekey,airOnePriceBase,airOnePriceTax,airOneBaseSenior ,airOneTaxSenior, airOneBaseChildren ,airOneTaxChildren ,airOneBaseInfant, airOneTaxInfant,airOneBaseYouth, airOneTaxYouth, airOneBaseTotal, airOneTaxTotal, airOneBaseDisplay, airOneTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,  otherLegPrice  , cabinClass,airlegnumber,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)
	SELECT airOneResponsekey,airOnePriceBase,airOnePriceTax,airOneBaseSenior ,airOneTaxSenior, airOneBaseChildren ,airOneTaxChildren ,airOneBaseInfant, airOneTaxInfant,airOneBaseYouth, airOneTaxYouth, airOneBaseTotal, airOneTaxTotal, airOneBaseDisplay, airOneTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,  otherLegPrice  , cabinClass,airlegnumber,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat FROM #tempOneWayResponses_OW
	
	--SELECT 'AFTER INSERT @tempOneWayResponses',* FROM @tempOneWayResponses
	--return
	--RETURN
	
  --SELECT * FROM #tempOneWayResponses_OW
--RETURN
--SELECT * FROM #tempOneWayResponses_OW


--SELECT * FROM #normal

--Return
        
--SELECT * FROM #airResponseCombination
--SELECT * FROM #normal
--RETURN

 --STEP11 GET ALL LEGS AIRLINES COUNT IN @normalizedResultSet
DECLARE @normalizedResultSet   AS TABLE   
(  
  airresponsekey uniqueidentifier ,  
  noOFStops int ,  
  airPriceBase float ,  
  gdssourcekey int ,  
  noOfAirlines int ,  
  takeoffdate datetime ,  
  landingdate datetime ,   
  airlineCode varchar(60),  
  airpriceTax float ,  
  airsubrequetkey int  ,cabinclass varchar(20),  
  otherlegPrice float ,otherlegtax float ,airlegnumber int   
 )   
  
	INSERT  @normalizedResultSet (airresponsekey ,airPriceBase,noOFStops ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey ,airpricetax ,airsubrequetkey ,cabinclass ,otherlegPrice,otherlegtax ,airlegnumber   )  
	(SELECT seg.airresponsekey,result.airOneBaseDisplay ,CASE WHEN COUNT(seg.airresponsekey )-1 > 1 THEN 1 ELSE  COUNT(seg.airresponsekey )-1 END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ),  
	CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
	resp.gdsSourceKey, result.airOneTaxDisplay ,result.airsubRequestkey ,result .cabinClass  ,otherLegPrice,otherLegTax  ,result.airlegnumber   
	FROM @tempOneWayResponses result  INNER JOIN 
	  
	AirResponse resp   ON resp.airResponseKey = result.airOneResponsekey   
	
	INNER JOIN  AirSegments seg   ON result .airOneResponsekey = seg.airResponseKey   
	INNER JOIN #normal N ON resp.airresponsekey = N.airresponsekey   
	--where N.isNeedtoUpdate = 0
	GROUP BY seg.airResponseKey,result.airOneBaseDisplay ,gdssourcekey  ,result .airOneTaxDisplay , result.airsubRequestkey ,result.cabinClass ,result.otherlegprice,otherLegTax ,result.airlegnumber)  
 --select 'NormalizedresultSet'
	--select * from @normalizedResultSet
	--return	
    --STEP 12 INSERT DATA FROM @normalizedResultSet AND @airSegments into @airResponseResultset
	INSERT into @airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfStops ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey 
	, airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected,otherLegPrice,isRefundable,isBrandedFare  ,cabinClass ,fareType,segmentOrder ,airsegmentCabin ,totalCost,
	airSegmentOperatingFlightNumber ,otherlegtax ,isgeneratedBundle,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airSegmentOperatingAirlineCompanyShortName,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
	SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,noOFStops  ,  takeoffdate  , landingdate ,airSegmentOperatingAirlineCode , seg.airSegmentResBookDesigCode,noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver ,priceClassCommentsEconSaver,
	priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice ,airEconFlexPrice,airEconUpgradePrice,airClassSuperSaver,
	airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected ,   
	isnull (otherlegPrice,0)    ,refundable   ,isBrandedFare ,normalized .cabinclass ,fareType,segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,otherlegtax ,isGeneratedBundle,
	airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,seg.airSegmentOperatingAirlineCompanyShortName,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
	FROM @AirSegments seg     
	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber  )  
	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops   
	INNER JOIN AirVendorLookup airVendor  WITH(NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode 
	where (seg.airSubRequestkey = @airBundledRequest OR seg.airSubRequestKey =@airPublishedFareRequest)
	
	
		
	--select * from @airResponseResultset
	--return
IF OBJECT_ID('tempdb..#airResponseResultset_TEMP') IS NOT NULL  
		DROP TABLE #airResponseResultset_TEMP
CREATE TABLE #airResponseResultset_TEMP    
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
  NoOfStops int ,  
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
  airPriceClassSelected   varchar (50) NULL ,  
  otherLegPrice float ,  
  isRefundable bit ,  
  isbrandedFare bit ,  
  cabinClass varchar(20) ,  
  fareType varchar (20),segmentOrder int ,airsegmentCabin varchar (20),  
  totalCost float ,airSegmentOperatingFlightNumber int, otherlegtax float ,  
  isgeneratedBundle bit,
  airSegmentOperatingAirlineCompanyShortName VARCHAR(100)  ,
  airPriceBaseInfantWithSeat float,
  airPriceTaxInfantWithSeat float
 )  
 
 INSERT into #airResponseResultset_TEMP (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfStops ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey 
	, airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected,otherLegPrice,isRefundable,isBrandedFare  ,cabinClass ,fareType,segmentOrder ,airsegmentCabin ,totalCost,
	airSegmentOperatingFlightNumber ,otherlegtax ,isgeneratedBundle,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airSegmentOperatingAirlineCompanyShortName,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)  
	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,normalized.noOFStops  ,  normalized.takeoffdate  , normalized.landingdate ,seg.airSegmentOperatingAirlineCode , seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,normalized.airsubrequetkey ,seg.airsegmentDepartureOffset,seg.airSegmentArrivalOffset ,seg.airSegmentSeatRemaining,resp.priceClassCommentsSuperSaver ,resp.priceClassCommentsEconSaver,
	resp.priceClassCommentsFirstFlex ,resp.priceClassCommentsCorporate,resp.priceClassCommentsEconFlex,resp.priceClassCommentsEconUpgrade,resp.airSuperSaverPrice ,resp.airEconSaverPrice ,resp.airFirstFlexPrice ,resp.airCorporatePrice ,resp.airEconFlexPrice,resp.airEconUpgradePrice,resp.airClassSuperSaver,
	resp.airClassEconSaver,resp.airClassFirstFlex,resp.airClassCorporate,resp.airClassEconFlex,resp.airClassEconUpgrade,resp.airSuperSaverSeatRemaining,resp.airEconSaverSeatRemaining,resp.airFirstFlexSeatRemaining,resp.airCorporateSeatRemaining,resp.airEconFlexSeatRemaining,resp.airEconUpgradeSeatRemaining, resp.airPriceClassSelected ,   
	isnull (normalized.otherlegPrice,0)    ,resp.refundable   ,resp.isBrandedFare ,normalized .cabinclass ,resp.fareType,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,normalized.otherlegtax ,resp.isGeneratedBundle,
	TT.airOneBaseSenior,TT.airOneTaxSenior,TT.airOneBaseChildren,TT.airOneTaxChildren,TT.airOneBaseInfant,TT.airOneTaxInfant,TT.airOneBaseTotal,TT.airOneTaxTotal,TT.airOneBaseDisplay, TT.airOneTaxDisplay,seg.airSegmentOperatingAirlineCompanyShortName,TT.airOnePriceBaseInfantWithSeat,TT.airOnePriceTaxInfantWithSeat
	FROM @AirSegments seg     
	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber  )
	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
	INNER JOIN @AirSegments seg1 ON NN.leg1airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops   
	INNER JOIN AirVendorLookup airVendor  WITH(NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode
	where NN.isNeedtoUpdate = 1)
UNION
(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,normalized.noOFStops  ,  normalized.takeoffdate  , normalized.landingdate ,seg.airSegmentOperatingAirlineCode , seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,normalized.airsubrequetkey ,seg.airsegmentDepartureOffset,seg.airSegmentArrivalOffset ,seg.airSegmentSeatRemaining,resp.priceClassCommentsSuperSaver ,resp.priceClassCommentsEconSaver,
	resp.priceClassCommentsFirstFlex ,resp.priceClassCommentsCorporate,resp.priceClassCommentsEconFlex,resp.priceClassCommentsEconUpgrade,resp.airSuperSaverPrice ,resp.airEconSaverPrice ,resp.airFirstFlexPrice ,resp.airCorporatePrice ,resp.airEconFlexPrice,resp.airEconUpgradePrice,resp.airClassSuperSaver,
	resp.airClassEconSaver,resp.airClassFirstFlex,resp.airClassCorporate,resp.airClassEconFlex,resp.airClassEconUpgrade,resp.airSuperSaverSeatRemaining,resp.airEconSaverSeatRemaining,resp.airFirstFlexSeatRemaining,resp.airCorporateSeatRemaining,resp.airEconFlexSeatRemaining,resp.airEconUpgradeSeatRemaining, resp.airPriceClassSelected ,   
	isnull (normalized.otherlegPrice,0)    ,resp.refundable   ,resp.isBrandedFare ,normalized .cabinclass ,resp.fareType,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,normalized.otherlegtax ,resp.isGeneratedBundle,
	TT.airOneBaseSenior,TT.airOneTaxSenior,TT.airOneBaseChildren,TT.airOneTaxChildren,TT.airOneBaseInfant,TT.airOneTaxInfant,TT.airOneBaseTotal,TT.airOneTaxTotal,TT.airOneBaseDisplay, TT.airOneTaxDisplay,seg.airSegmentOperatingAirlineCompanyShortName,TT.airOnePriceBaseInfantWithSeat,TT.airOnePriceTaxInfantWithSeat
	FROM @AirSegments seg     
	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber  )
	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
	INNER JOIN @AirSegments seg1 ON NN.leg2airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops   
	INNER JOIN AirVendorLookup airVendor  WITH(NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode
	where NN.isNeedtoUpdate = 1)
	UNION
	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,normalized.noOFStops  ,  normalized.takeoffdate  , normalized.landingdate ,seg.airSegmentOperatingAirlineCode , seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,normalized.airsubrequetkey ,seg.airsegmentDepartureOffset,seg.airSegmentArrivalOffset ,seg.airSegmentSeatRemaining,resp.priceClassCommentsSuperSaver ,resp.priceClassCommentsEconSaver,
	resp.priceClassCommentsFirstFlex ,resp.priceClassCommentsCorporate,resp.priceClassCommentsEconFlex,resp.priceClassCommentsEconUpgrade,resp.airSuperSaverPrice ,resp.airEconSaverPrice ,resp.airFirstFlexPrice ,resp.airCorporatePrice ,resp.airEconFlexPrice,resp.airEconUpgradePrice,resp.airClassSuperSaver,
	resp.airClassEconSaver,resp.airClassFirstFlex,resp.airClassCorporate,resp.airClassEconFlex,resp.airClassEconUpgrade,resp.airSuperSaverSeatRemaining,resp.airEconSaverSeatRemaining,resp.airFirstFlexSeatRemaining,resp.airCorporateSeatRemaining,resp.airEconFlexSeatRemaining,resp.airEconUpgradeSeatRemaining, resp.airPriceClassSelected ,   
	isnull (normalized.otherlegPrice,0)    ,resp.refundable   ,resp.isBrandedFare ,normalized .cabinclass ,resp.fareType,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,normalized.otherlegtax ,resp.isGeneratedBundle,
	TT.airOneBaseSenior,TT.airOneTaxSenior,TT.airOneBaseChildren,TT.airOneTaxChildren,TT.airOneBaseInfant,TT.airOneTaxInfant,TT.airOneBaseTotal,TT.airOneTaxTotal,TT.airOneBaseDisplay, TT.airOneTaxDisplay,seg.airSegmentOperatingAirlineCompanyShortName,TT.airOnePriceBaseInfantWithSeat,TT.airOnePriceTaxInfantWithSeat
	FROM @AirSegments seg     
	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber  )
	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
	INNER JOIN @AirSegments seg1 ON NN.leg3airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops   
	INNER JOIN AirVendorLookup airVendor  WITH(NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode
	where NN.isNeedtoUpdate = 1)
	UNION
	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,normalized.noOFStops  ,  normalized.takeoffdate  , normalized.landingdate ,seg.airSegmentOperatingAirlineCode , seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,normalized.airsubrequetkey ,seg.airsegmentDepartureOffset,seg.airSegmentArrivalOffset ,seg.airSegmentSeatRemaining,resp.priceClassCommentsSuperSaver ,resp.priceClassCommentsEconSaver,
	resp.priceClassCommentsFirstFlex ,resp.priceClassCommentsCorporate,resp.priceClassCommentsEconFlex,resp.priceClassCommentsEconUpgrade,resp.airSuperSaverPrice ,resp.airEconSaverPrice ,resp.airFirstFlexPrice ,resp.airCorporatePrice ,resp.airEconFlexPrice,resp.airEconUpgradePrice,resp.airClassSuperSaver,
	resp.airClassEconSaver,resp.airClassFirstFlex,resp.airClassCorporate,resp.airClassEconFlex,resp.airClassEconUpgrade,resp.airSuperSaverSeatRemaining,resp.airEconSaverSeatRemaining,resp.airFirstFlexSeatRemaining,resp.airCorporateSeatRemaining,resp.airEconFlexSeatRemaining,resp.airEconUpgradeSeatRemaining, resp.airPriceClassSelected ,   
	isnull (normalized.otherlegPrice,0)    ,resp.refundable   ,resp.isBrandedFare ,normalized .cabinclass ,resp.fareType,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,normalized.otherlegtax ,resp.isGeneratedBundle,
	TT.airOneBaseSenior,TT.airOneTaxSenior,TT.airOneBaseChildren,TT.airOneTaxChildren,TT.airOneBaseInfant,TT.airOneTaxInfant,TT.airOneBaseTotal,TT.airOneTaxTotal,TT.airOneBaseDisplay, TT.airOneTaxDisplay,seg.airSegmentOperatingAirlineCompanyShortName,TT.airOnePriceBaseInfantWithSeat,TT.airOnePriceTaxInfantWithSeat
	FROM @AirSegments seg     
	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber  )
	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
	INNER JOIN @AirSegments seg1 ON NN.leg4airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops   
	INNER JOIN AirVendorLookup airVendor  WITH(NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode
	where NN.isNeedtoUpdate = 1)
	UNION
	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,normalized.noOFStops  ,  normalized.takeoffdate  , normalized.landingdate ,seg.airSegmentOperatingAirlineCode , seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,normalized.airsubrequetkey ,seg.airsegmentDepartureOffset,seg.airSegmentArrivalOffset ,seg.airSegmentSeatRemaining,resp.priceClassCommentsSuperSaver ,resp.priceClassCommentsEconSaver,
	resp.priceClassCommentsFirstFlex ,resp.priceClassCommentsCorporate,resp.priceClassCommentsEconFlex,resp.priceClassCommentsEconUpgrade,resp.airSuperSaverPrice ,resp.airEconSaverPrice ,resp.airFirstFlexPrice ,resp.airCorporatePrice ,resp.airEconFlexPrice,resp.airEconUpgradePrice,resp.airClassSuperSaver,
	resp.airClassEconSaver,resp.airClassFirstFlex,resp.airClassCorporate,resp.airClassEconFlex,resp.airClassEconUpgrade,resp.airSuperSaverSeatRemaining,resp.airEconSaverSeatRemaining,resp.airFirstFlexSeatRemaining,resp.airCorporateSeatRemaining,resp.airEconFlexSeatRemaining,resp.airEconUpgradeSeatRemaining, resp.airPriceClassSelected ,   
	isnull (normalized.otherlegPrice,0)    ,resp.refundable   ,resp.isBrandedFare ,normalized .cabinclass ,resp.fareType,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,normalized.otherlegtax ,resp.isGeneratedBundle,
	TT.airOneBaseSenior,TT.airOneTaxSenior,TT.airOneBaseChildren,TT.airOneTaxChildren,TT.airOneBaseInfant,TT.airOneTaxInfant,TT.airOneBaseTotal,TT.airOneTaxTotal,TT.airOneBaseDisplay, TT.airOneTaxDisplay,seg.airSegmentOperatingAirlineCompanyShortName,TT.airOnePriceBaseInfantWithSeat,TT.airOnePriceTaxInfantWithSeat
	FROM @AirSegments seg     
	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber  )
	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
	INNER JOIN @AirSegments seg1 ON NN.leg5airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops   
	INNER JOIN AirVendorLookup airVendor  WITH(NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode
	where NN.isNeedtoUpdate = 1)
	UNION
	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,normalized.noOFStops  ,  normalized.takeoffdate  , normalized.landingdate ,seg.airSegmentOperatingAirlineCode , seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,normalized.airsubrequetkey ,seg.airsegmentDepartureOffset,seg.airSegmentArrivalOffset ,seg.airSegmentSeatRemaining,resp.priceClassCommentsSuperSaver ,resp.priceClassCommentsEconSaver,
	resp.priceClassCommentsFirstFlex ,resp.priceClassCommentsCorporate,resp.priceClassCommentsEconFlex,resp.priceClassCommentsEconUpgrade,resp.airSuperSaverPrice ,resp.airEconSaverPrice ,resp.airFirstFlexPrice ,resp.airCorporatePrice ,resp.airEconFlexPrice,resp.airEconUpgradePrice,resp.airClassSuperSaver,
	resp.airClassEconSaver,resp.airClassFirstFlex,resp.airClassCorporate,resp.airClassEconFlex,resp.airClassEconUpgrade,resp.airSuperSaverSeatRemaining,resp.airEconSaverSeatRemaining,resp.airFirstFlexSeatRemaining,resp.airCorporateSeatRemaining,resp.airEconFlexSeatRemaining,resp.airEconUpgradeSeatRemaining, resp.airPriceClassSelected ,   
	isnull (normalized.otherlegPrice,0)    ,resp.refundable   ,resp.isBrandedFare ,normalized .cabinclass ,resp.fareType,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,normalized.otherlegtax ,resp.isGeneratedBundle,
	TT.airOneBaseSenior,TT.airOneTaxSenior,TT.airOneBaseChildren,TT.airOneTaxChildren,TT.airOneBaseInfant,TT.airOneTaxInfant,TT.airOneBaseTotal,TT.airOneTaxTotal,TT.airOneBaseDisplay, TT.airOneTaxDisplay,seg.airSegmentOperatingAirlineCompanyShortName,TT.airOnePriceBaseInfantWithSeat,TT.airOnePriceTaxInfantWithSeat
	FROM @AirSegments seg     
	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber  )
	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
	INNER JOIN @AirSegments seg1 ON NN.leg6airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey   
	INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops   
	INNER JOIN AirVendorLookup airVendor  WITH(NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode
	where NN.isNeedtoUpdate = 1)
	
	--select '@airResponseResultset_temp',* from @airResponseResultset
	--return
	delete t1 FROM @airResponseResultset t1
		INNER JOIN #airResponseResultset_TEMP t2 ON t1.airResponseKey= t2.airResponseKey
		--SELECT '@airResponseResultset after delete',* FROM @airResponseResultset
	--select * from @airResponseResultset
	--return
	insert into @airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfStops ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey 
	, airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected,otherLegPrice,isRefundable,isBrandedFare  ,cabinClass ,fareType,segmentOrder ,airsegmentCabin ,totalCost,
	airSegmentOperatingFlightNumber ,otherlegtax ,isgeneratedBundle,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airSegmentOperatingAirlineCompanyShortName,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)
	(select airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfStops ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey 
	, airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected,otherLegPrice,isRefundable,isBrandedFare  ,cabinClass ,fareType,segmentOrder ,airsegmentCabin ,totalCost,
	airSegmentOperatingFlightNumber ,otherlegtax ,isgeneratedBundle,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airSegmentOperatingAirlineCompanyShortName,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
	from #airResponseResultset_TEMP )
	--select * from @airResponseResultset
	--return
	--SELECT '@airResponseResultset after insert',* FROM #airResponseResultset_TEMP
	--return
--IF OBJECT_ID('tempdb..#airResponseResultset_TEMP_TEMP') IS NOT NULL  
--		DROP TABLE #airResponseResultset_TEMP_TEMP
--CREATE TABLE #airResponseResultset_TEMP_TEMP    
-- (  
--  airSegmentKey uniqueidentifier,  
--  airResponseKey uniqueidentifier ,  
--  airLegNumber int,        
--  airPrice float ,  
--  airPriceTax float ,  
--  AirPriceBaseTotal float,
--  AirPriceTaxTotal float,
--  airRequestKey int, 
--  airSegmentResBookDesigCode varchar(3),
--  noofAirlines int ,              
--  otherLegPrice float ,  
--  isRefundable bit ,     
--  segmentOrder int ,airsegmentCabin varchar (20),  
--  totalCost float , otherlegtax float 
-- )  
 
-- INSERT into #airResponseResultset_TEMP_TEMP (airSegmentKey , airResponseKey,airLegNumber,airPrice,airPriceTax,
-- AirPriceBaseTotal,AirPriceTaxTotal,airRequestKey,
-- airSegmentResBookDesigCode,noofAirlines,otherLegPrice,isRefundable,
-- segmentOrder,airsegmentCabin,totalCost,otherlegtax)  
--	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, normalized .airPriceBase      AS airPriceBase ,normalized.airpriceTax,
--	 TT.airOneBaseTotal,TT.airOneTaxTotal,normalized.airsubrequetkey,
--	 seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,isnull (normalized.otherlegPrice,0),resp.refundable ,
--	  seg.segmentOrder,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),normalized.otherlegtax
--	FROM @AirSegments seg     
--	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber)
--	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
--	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
--	INNER JOIN @AirSegments seg1 ON NN.leg1airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
--	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey    
--	where NN.isNeedtoUpdate = 1)
--	UNION
--	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, normalized .airPriceBase      AS airPriceBase ,normalized.airpriceTax,
--	 TT.airOneBaseTotal,TT.airOneTaxTotal,normalized.airsubrequetkey,
--	 seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,isnull (normalized.otherlegPrice,0),resp.refundable ,
--	  seg.segmentOrder,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),normalized.otherlegtax
--	FROM @AirSegments seg     
--	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber)
--	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
--	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
--	INNER JOIN @AirSegments seg1 ON NN.leg2airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
--	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey    
--	where NN.isNeedtoUpdate = 1)
--	UNION
--	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, normalized .airPriceBase      AS airPriceBase ,normalized.airpriceTax,
--	 TT.airOneBaseTotal,TT.airOneTaxTotal,normalized.airsubrequetkey,
--	 seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,isnull (normalized.otherlegPrice,0),resp.refundable ,
--	  seg.segmentOrder,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),normalized.otherlegtax
--	FROM @AirSegments seg     
--	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber)
--	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
--	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
--	INNER JOIN @AirSegments seg1 ON NN.leg3airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
--	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey    
--	where NN.isNeedtoUpdate = 1)
--	UNION
--	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, normalized .airPriceBase      AS airPriceBase ,normalized.airpriceTax,
--	 TT.airOneBaseTotal,TT.airOneTaxTotal,normalized.airsubrequetkey,
--	 seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,isnull (normalized.otherlegPrice,0),resp.refundable ,
--	  seg.segmentOrder,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),normalized.otherlegtax
--	FROM @AirSegments seg     
--	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber)
--	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
--	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
--	INNER JOIN @AirSegments seg1 ON NN.leg4airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
--	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey    
--	where NN.isNeedtoUpdate = 1)
--	UNION
--	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, normalized .airPriceBase      AS airPriceBase ,normalized.airpriceTax,
--	 TT.airOneBaseTotal,TT.airOneTaxTotal,normalized.airsubrequetkey,
--	 seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,isnull (normalized.otherlegPrice,0),resp.refundable ,
--	  seg.segmentOrder,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),normalized.otherlegtax
--	FROM @AirSegments seg     
--	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber)
--	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
--	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
--	INNER JOIN @AirSegments seg1 ON NN.leg5airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
--	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey    
--	where NN.isNeedtoUpdate = 1)
--	UNION
--	(SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, normalized .airPriceBase      AS airPriceBase ,normalized.airpriceTax,
--	 TT.airOneBaseTotal,TT.airOneTaxTotal,normalized.airsubrequetkey,
--	 seg1.airSegmentResBookDesigCode,normalized.noOfAirlines ,isnull (normalized.otherlegPrice,0),resp.refundable ,
--	  seg.segmentOrder,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),normalized.otherlegtax
--	FROM @AirSegments seg     
--	INNER JOIN @normalizedResultSet normalized ON (seg.airresponsekey = normalized .airresponsekey  and seg.airLegNumber = normalized.airlegnumber)
--	INNER JOIN #tempOneWayResponses_GROUPED TT ON TT.airOneResponsekey = normalized.airresponsekey
--	INNER JOIN #normal NN ON NN.airresponsekey = seg.airREsponsekey
--	INNER JOIN @AirSegments seg1 ON NN.leg6airResponsekey = seg1.airREsponsekey AND seg.airLegNumber = seg1.airLegNumber AND seg.segmentOrder = seg1.segmentOrder
--	INNER JOIN AirResponse resp WITH(NOLOCK) ON seg .airresponsekey = resp.airResponseKey    
--	where NN.isNeedtoUpdate = 1)
	
	--select * from #airResponseResultset_TEMP_TEMP
	--return
	--INNER JOIN #normal NN ON )
  
  -- DELETE REMAINING
  -- INSERT REMAINING IN MAIN TABLE
  
  	IF (@MaxFareTotal != 0)
	BEGIN
		DELETE FROM @airResponseResultset 
		WHERE airresponsekey IN (SELECT A.airResponseKey from @airResponseResultset A WHERE (case when @isTotalPriceSort= 0 then A.airPrice  else A.totalcost end) > @MaxFareTotal)
	END
  
 DECLARE @pagingResultSet Table   
 (  
  rowNum int IDENTITY(1,1) NOT NULL,     
  airResponseKey uniqueidentifier  ,  
  airlineName varchar(100),   
  airPrice float ,   
  actualTakeOffDateForLeg datetime   
  )   
  --select * from @airResponseResultset
  --select * from @normalizedResultSet
  --return
	IF @sortField <> ''  
	BEGIN   
		INSERT into @pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )  

		SELECT    air.airResponseKey ,MIN(airPriceBaseDisplay) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM @airResponseResultset air   
		INNER JOIN @normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey   
		INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   )   
		GROUP BY air.airResponseKey,airlineName   order by   
		CASE WHEN @sortField  = 'Price'      THEN    ( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END  )     END  ,    
		CASE WHEN @sortField  = 'Airline' THEN  MIN(MarketingAirlineName)         END   ,   
		CASE WHEN @sortField  ='Departure' THEN MIN( actualTakeOffDateForLeg) END   ,  
		--CASE WHEN @sortField ='Duration' THEN MIN(duration) END ,  
		CASE WHEN @sortField  ='' THEN MIN( airPrice)  END      
		---- print ( cast(getdate() AS time )  )  
	END   
	ELSE   
	BEGIN   
		INSERT into @pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )  
		SELECT    air.airResponseKey ,MIN(airPriceBaseDisplay ) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM @airResponseResultset air   
		INNER JOIN @normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey   
		INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   )   
		GROUP BY air.airResponseKey,airlineName   order by ( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END),MIN(MarketingAirlineName) , min(normalized.noOFStops ),MIN( actualTakeOffDateForLeg) ,MIN( actualLandingDateForLeg )  
		-- print('page default')  
	END
	
	--select * from @pagingResultSet
	--return
	---- print ( cast(getdate() AS time )  )  
   ---UNNECESSARY CODE -NEED TO REMOVE START HERE
	IF ( @superSetAirlines is not null AND @superSetAirlines <> '' )  
	BEGIN   
		Delete P  
		FROM @pagingResultSet P  
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey  
	END   

	--Hemali
	 IF ( @excludeAirline  <> '' AND @excludeAirline IS NOT NULL )  
	 BEGIN     
	  Delete P    
	  FROM @pagingResultSet P    
	  INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey    
	  
	  Delete P    
      FROM @airResponseResultset P    
      INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey       
    
      Delete P    
      FROM @normalizedResultSet P    
      INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey        
	 END  
	 
	 IF ( @excludedCountries  <> '' AND @excludedCountries IS NOT NULL )
	 BEGIN
		Delete P    
		FROM @pagingResultSet P    
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey    
	  
		Delete P    
		FROM @airResponseResultset P    
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey       
    
		Delete P    
		FROM @normalizedResultSet P    
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey    
	 END
	 --select * from @pagingResultSet
	--return


--select * from @pagingResultSet
--return

	   ---UNNECESSARY CODE -NEED TO REMOVE END HERE
	/**STEP14 MAIN RESULTSET FOR LIST STARTS HERE**/  
   DECLARE @SortedResultSet   AS TABLE   
(  
    [rowNum] [int] NOT NULL,
	[airSegmentKey] [uniqueidentifier] NULL,
	[airResponseKey] [uniqueidentifier] NULL,
	[airLegNumber] [int] NULL,
	[airSegmentMarketingAirlineCode] [varchar](10) NULL,
	[airSegmentFlightNumber] [varchar](50) NULL,
	[airSegmentDuration] [time](7) NULL,
	[airSegmentEquipment] [varchar](50) NULL,
	[airSegmentMiles] [int] NULL,
	[airSegmentDepartureDate] [datetime] NULL,
	[airSegmentArrivalDate] [datetime] NULL,
	[airSegmentDepartureAirport] [varchar](50) NULL,
	[airSegmentArrivalAirport] [varchar](50) NULL,
	[airPrice] [float] NULL,
	[airPriceTax] [float] NULL,
	[airPriceBaseSenior] [float] NULL,
	[airPriceTaxSenior] [float] NULL,
	[airPriceBaseChildren] [float] NULL,
	[airPriceTaxChildren] [float] NULL,
	[airPriceBaseInfant] [float] NULL,
	[airPriceTaxInfant] [float] NULL,
	[airPriceBaseYouth] [float] NULL,
	[airPriceTaxYouth] [float] NULL,
	[AirPriceBaseTotal] [float] NULL,
	[AirPriceTaxTotal] [float] NULL,
	[airPriceBaseDisplay] [float] NULL,
	[airPriceTaxDisplay] [float] NULL,
	[airRequestKey] [int] NULL,
	[gdsSourceKey] [int] NULL,
	[MarketingAirlineName] [varchar](50) NULL,
	[NoOfStops] [int] NULL,
	[actualTakeOffDateForLeg] [datetime] NULL,
	[actualLandingDateForLeg] [datetime] NULL,
	[airSegmentOperatingAirlineCode] [varchar](10) NULL,
	[airSegmentResBookDesigCode] [varchar](3) NULL,
	[noofAirlines] [int] NULL,
	[airlineName] [varchar](50) NULL,
	[airsegmentDepartureOffset] [float] NULL,
	[airSegmentArrivalOffset] [float] NULL,
	[airSegmentSeatRemaining] [int] NULL,
	[priceClassCommentsSuperSaver] [varchar](500) NULL,
	[priceClassCommentsEconSaver] [varchar](500) NULL,
	[priceClassCommentsFirstFlex] [varchar](500) NULL,
	[priceClassCommentsCorporate] [varchar](500) NULL,
	[priceClassCommentsEconFlex] [varchar](500) NULL,
	[priceClassCommentsEconUpgrade] [varchar](500) NULL,
	[airSuperSaverPrice] [float] NULL,
	[airEconSaverPrice] [float] NULL,
	[airFirstFlexPrice] [float] NULL,
	[airCorporatePrice] [float] NULL,
	[airEconFlexPrice] [float] NULL,
	[airEconUpgradePrice] [float] NULL,
	[airClassSuperSaver] [varchar](50) NULL,
	[airClassEconSaver] [varchar](50) NULL,
	[airClassFirstFlex] [varchar](50) NULL,
	[airClassCorporate] [varchar](50) NULL,
	[airClassEconFlex] [varchar](50) NULL,
	[airClassEconUpgrade] [varchar](50) NULL,
	[airSuperSaverSeatRemaining] [int] NULL,
	[airEconSaverSeatRemaining] [int] NULL,
	[airFirstFlexSeatRemaining] [int] NULL,
	[airCorporateSeatRemaining] [int] NULL,
	[airEconFlexSeatRemaining] [int] NULL,
	[airEconUpgradeSeatRemaining] [int] NULL,
	[airSuperSaverFareReferenceKey] [varchar](50) NULL,
	[airEconSaverFareReferenceKey] [varchar](50) NULL,
	[airFirstFlexFareReferenceKey] [varchar](50) NULL,
	[airCorporateFareReferenceKey] [varchar](50) NULL,
	[airEconFlexFareReferenceKey] [varchar](50) NULL,
	[airEconUpgradeFareReferenceKey] [varchar](50) NULL,
	[airPriceClassSelected] [varchar](50) NULL,
	[otherLegPrice] [float] NULL,
	[isRefundable] [bit] NULL,
	[isbrandedFare] [bit] NULL,
	[cabinClass] [varchar](20) NULL,
	[fareType] [varchar](20) NULL,
	[segmentOrder] [int] NULL,
	[airsegmentCabin] [varchar](20) NULL,
	[totalCost] [float] NULL,
	[airSegmentOperatingFlightNumber] [int] NULL,
	[otherlegtax] [float] NULL,
	[isgeneratedBundle] [bit] NULL,
	[airSegmentOperatingAirlineCompanyShortName] [varchar](100) NULL,
	[airPriceBaseInfantWithSeat] [float] NULL,
	[airPriceTaxInfantWithSeat] [float] NULL,
	[DepartureAirPortCityName] [varchar](64) NULL,
	[DepartureAirportStateCode] [varchar](2) NULL,
	[DepartureAirportName] [varchar](100) NULL,
	[DepartureAirportCountryCode] [varchar](2) NULL,
	[ArrivalAirPortCityName] [varchar](64) NULL,
	[ArrivalAirportStateCode] [varchar](2) NULL,
	[ArrivalAirportName] [varchar](100) NULL,
	[ArrivalAirportCountryCode] [varchar](2) NULL,
	[OperatingAirlineName] [varchar](64) NULL,
	[DepartureAirportCountryName] [varchar](128) NULL,
	[ArrivalAirportCountryName] [varchar](128) NULL
 )   
    insert into @SortedResultSet
	SELECT distinct    rowNum,air.*,departureAirport .CityName AS DepartureAirPortCityName ,departureAirport.StateCode AS DepartureAirportStateCode ,departureAirport .AirportName AS DepartureAirportName , departureAirport.CountryCode
	AS DepartureAirportCountryCode,   
	arrivalAirport .CItyName AS ArrivalAirPortCityName ,arrivalAirport .StateCode AS ArrivalAirportStateCode , arrivalAirport .AirportName AS ArrivalAirportName ,arrivalAirport .CountryCode  AS ArrivalAirportCountryCode,  
	operatingAirline .ShortName AS OperatingAirlineName ,
	CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName
	FROM @airResponseResultset air INNER JOIN @pagingResultSet  paging ON air.airResponseKey = paging.airResponseKey  
	LEFT OUTER JOIN AirVendorLookup operatingAirline    ON air .airSegmentOperatingAirlineCode = operatingAirline .AirlineCode   
	LEFT OUTER JOIN AirportLookup departureAirport   ON air .airSegmentDepartureAirport = departureAirport .AirportCode   
	LEFT OUTER JOIN AirportLookup arrivalAirport    ON air .airSegmentArrivalAirport =arrivalAirport .AirportCode   
	LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode
	LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode
	order by rowNum ,airLegNumber ,segmentOrder, airSegmentDepartureDate  
--select * from @SortedResultSet
--return

	SELECT * FROM @SortedResultSet 	order by  CASE 
      WHEN  @sortField  = 'Departure' THEN 'rowNum ,airLegNumber ,segmentOrder, airSegmentDepartureDate'
       WHEN  @sortField  = 'Arrival' THEN 'rowNum ,airLegNumber ,segmentOrder, airSegmentArrivalDate'
	    WHEN  @sortField  = 'Duration' THEN 'rowNum ,airLegNumber ,segmentOrder, airSegmentDuration'
	   
	   ELSE  'rowNum ,airLegNumber ,segmentOrder, airSegmentDepartureDate'
   END 

	/**MAIN RESULTSET FOR LIST ENDS HERE**/  
	
	IF ( @superSetAirlines is not null AND @superSetAirlines <> '' )  
	BEGIN   
		Delete P  
		FROM @airResponseResultset P  
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey      
		Delete P  
		FROM @normalizedResultSet P  
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey     
	END   

	/****STEP 15 MIN-MAX PRICE FOR FILTERS ***/  
	SELECT (case when @isTotalPriceSort = 0 then MIN (airPriceBaseDisplay)  else MIN (totalCost ) end ) AS LowestPrice ,  (case when @isTotalPriceSort = 0 then MAX (airPriceBaseDisplay)  else MAX (totalCost ) end ) AS HighestPrice FROM @airResponseResultset  result1   
	/****MIN-MAX PRICE FOR FILTERS END***/  
   
	/****TAKEOFF-LANDING TIME START****/  
	SELECT distinct  MIN (actualTakeOffDateForLeg ) AS MinDepartureTakeOffDate,  MAX (actualTakeOffDateForLeg) AS MaxDepartureTakeOffDate, MIN (actualLandingDateForLeg) AS MinDepartureLandingDate,  MAX (actualLandingDateForLeg) AS MaxDepartureLandingDate   
	FROM @airResponseResultset    
	/****TAKEOFF-LANDING TIME END****/  
   
	/* STEP 16Stops for Slider START*/  
	SELECT distinct NoOfStops AS NoOfStops  FROM @airResponseResultset      
	/* Stops for Slider END*/  
  
	/******STEP 17 TOTAL RECORD COUNT FOUND START *********/  
    SELECT COUNT(*) AS [TotalCount] FROM @pagingResultSet   
	/******TOTAL RECORD COUNT FOUND END *********/   
	IF @airLines <> '' and @isIgnoreAirlineFilter = 1    
	BEGIN  
		delete from @tmpAirline    
		INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )    
	END  
	   
	/*** MATRIX LOGIC START HERE ***/  
	if ( SELECT COUNT (*) FROM @tmpAirline) > 1    
	BEGIN   
		SELECT (case when @isTotalPriceSort = 0 then MIN (airPriceBaseDisplay)  else MIN (totalCost ) end )AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode FROM @airResponseResultset air  
		INNER JOIN @normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
		INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode   
		LEFT OUTER JOIN AirVendorLookup vendor ON air.airlineName = vendor .AirlineCode   
		GROUP BY airlineName ,ShortName   
	END   
	ELSE   
	BEGIN    
		SELECT (case when @isTotalPriceSort = 0 then MIN (airPriceBaseDisplay)  else MIN (totalCost ) end )AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode FROM @airResponseResultset air  
		INNER JOIN @normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
		LEFT OUTER JOIN AirVendorLookup vendor ON air.airlineName = vendor .AirlineCode   
		GROUP BY airlineName ,ShortName   
	END   
	print(@noOfLegsForRequest)  
	print(@noOfLegsForRequest)  
	DECLARE @markettingAirline AS varchar(100)  
	DECLARE @noOFDrillDownCount as int   

SELECT @isExcludeAirlinesPresent AS IsExcludeAirlinesAvailable
SELECT @isExcludeCountryPresent AS IsExcludeCountryAvailable
DROP TABLE #normal
DROP TABLE #LegwiseUniqueCombination
DROP TABLE #UniqueLegAirResponse
DROP TABLE #FinalUniqueLegAR
DROP TABLE #airResponseCombination
DROP TABLE #tempOneWayResponses_TEMP
DROP TABLE #tempOneWayResponses_GROUPED
DROP TABLE #tempOneWayResponses_OW
DROP TABLE #airResponseResultset_TEMP
--DROP TABLE #airResponseResultset_TEMP_TEMP

GO
