SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[USP_GetAirResponsesMultiCityInternationalH]
(
--DECLARE	
	@airSubRequestKey int ,
	@sortField varchar(50)='',
	@airRequestTypeKey int ,    
	@pageNo int ,
	@pageSize int ,
	@airLines  varchar(200),
	@price float ,
	@NoOfStops varchar (50)  ,
	@selectedResponseKey uniqueidentifier =null  ,
	@selectedResponseKeySecond uniqueidentifier =null  ,
	@selectedResponseKeyThird uniqueidentifier =null  ,
	@selectedResponseKeyFourth uniqueidentifier =null  ,
	@selectedResponseKeyFifth uniqueidentifier =null  ,
	@minTakeOffDate Datetime ,
	@maxTakeOffDate Datetime ,
	@minLandingDate Datetime ,
	@maxLandingDate Datetime ,
	@drillDownLevel int = 0 ,
	@gdssourcekey int = 0 ,
	@selectedFareType varchar(100) ='',	
	@superSetAirlines varchar(200)='',
	@isIgnoreAirlineFilter bit = 0 ,
	@isTotalPriceSort bit = 0 ,
	@allowedOperatingAirlines varchar(400) ='',
	@excludeAirline varchar (500) = '',
	@excludedCountries varchar ( 500) = '',
	@siteKey int = 0,
	@matrixview  int = 0, ---0 for RT and 1 for legwise 
	@MaxNoofstops INT = 1
)
AS
-- SELECT @airSubRequestKey=921611,@airRequestTypeKey=2,@SuperSetairLines=N'AA,AB,AY,BA,CX,IB,LA,MH,QR,RJ',@allowedOperatingAirlines=N'AA,MH,BA,AB,CX,AY,IB,JL,LA,QF,RJ,S7,QR',@airLines=N'',@price=2147483647,@pageNo=0,@pageSize=30,@NoOfStops=N'-1',@selectedResponseKey='DAA4D819-67DC-4E4D-B4D5-351D42D61061',@drillDownLevel=N'1',@gdsSourcekey=2,@minTakeOffDate='2013-10-23 00:00:00',@maxTakeOffDate='2016-01-23 00:00:00',@minLandingDate='2013-10-23 00:00:00',@maxLandingDate='2016-01-23 00:00:00',@selectedFareType=N'',@isIgnoreAirlineFilter=N'False',@isTotalPriceSort=N'True',@siteKey=7,@matrixView=0

	SET NOCOUNT ON 
	DECLARE @FirstRec int
	DECLARE @LastRec int
	DECLARE @isExcludeAirlinesPresent BIT = 0 , @isExcludeCountryPresent BIT = 0

	-- Initialize variables.
	SET @FirstRec = (@pageNo  - 1) * @PageSize
	SET @LastRec = (@pageNo  * @PageSize + 1)

	---- print (cast(getdate() AS time))

	DECLARE @airRequestKey AS int 
	SET @airRequestKey =( SELECT TOP 1 airRequestKey  FROM AirSubRequest WITH (NOLOCK)WHERE airSubRequestKey = @airSubRequestKey )
	DECLARE @airRequestTripType   AS int  
	SET @airRequestTripType =( select airRequestTypeKey  from AirRequest  WITH (NOLOCK) where airRequestKey =@airRequestKey )
	DECLARE @airBundledRequest AS int 
	SET @airBundledRequest = (SELECT TOP 1 AirSubRequestKey FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = -1 AND groupKey =1) 

	DECLARE @airPublishedFareRequest AS int   
	IF ( @airRequestTripType > 1 ) 
	BEGIN 
		SET @airPublishedFareRequest = (SELECT TOP 1 AirSubRequestKey FROM AirSubRequest WITH(NOLOCK) WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = -1 AND groupKey =2)   
	END 
	ELSE 
	BEGIN
		SET @airPublishedFareRequest = (SELECT TOP 1 AirSubRequestKey FROM AirSubRequest WITH(NOLOCK) WHERE airRequestKey = @airRequestKey  AND groupKey =2)   
	END
     
	DECLARE @airSubRequestCount  AS INT 
	IF ( SELECT airRequestTypeKey  from AirRequest  WITH (NOLOCK) where airRequestKey =@airRequestKey )  =1
	BEGIN
		SET @airSubRequestCount = 1
	END 
	ELSE IF ( select airRequestTypeKey  from AirRequest  WITH (NOLOCK) where airRequestKey =@airRequestKey )  = 2
	BEGIN 
		SET @airSubRequestCount = 2 
	END 
	ELSE 
	BEGIN
		SET @airSubRequestCount = (Select COUNT(*) -1 From AirSubRequest  WITH (NOLOCK) where airRequestKey =@airRequestKey ) 
		SET @airSubRequestCount = 2 
	END

/******/

	CREATE TABLE #AirSegments
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
		airSegmentOperatingFlightNumber int  ,
		airsegmentCabin varchar (20)  ,
		segmentOrder int ,
		airSegmentOperatingAirlineCompanyShortName VARCHAR(100)		
	)

	INSERT INTO #AirSegments ( airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey ,airSegmentOperatingFlightNumber,airsegmentCabin ,segmentOrder,airSegmentOperatingAirlineCompanyShortName  )
	(
		SELECT airSegmentKey,SEG.airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,(case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey ,airSegmentOperatingFlightNumber,airsegmentCabin  ,segmentOrder,airSegmentOperatingAirlineCompanyShortName 
		FROM AirSegments seg WITH (NOLOCK) INNER JOIN AirResponse  resp WITH (NOLOCK) ON seg .airResponseKey = resp.airresponsekey LEFT OUTER JOIN AircraftsLookup WITH (NOLOCK) on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)
		INNER JOIN AirSubRequest subrequest  WITH (NOLOCK) ON resp.airSubRequestKey = subrequest .airSubRequestKey 
		WHERE  seg.airLegNumber = @airRequestTypeKey 
		AND   airRequestKey = @airRequestKey  AND ISNULL(resp.gdsSourceKey,2) =( CASE WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) 
	)
	
	DELETE FROM #AirSegments WHERE airResponseKey in ( SELECT distinct airResponseKey FROM #AirSegments where airSegmentMarketingAirlineCode ='WN')

	/***code for date time offset ****/
	DECLARE @startAirPort AS varchar(100) 
	DECLARE @endAirPort AS varchar(100) 
 	SELECT  @startAirPort=  airRequestDepartureAirport ,@endAirPort=airRequestArrivalAirport FROM AirSubRequest WHERE  airSubRequestKey =
	
	(SELECT top 1 airSubRequestKey from AirSubRequest WITH (NOLOCK) where airRequestKey =@airRequestKey and airSubRequestLegIndex = @airRequestTypeKey and groupKey =1  )
 	
 	DECLARE @tempResponseToRemove AS TABLE ( airresponsekey uniqueidentifier )
		
	-- declare Tables
	DECLARE @tblAirlinesGroup AS TABLE ( marketingAirline varchar(10),operatingAirline varchar(10), groupKey int)
	DECLARE @tblSuperAirlines AS TABLE ( marketingAirline varchar(10))
	DECLARE @tblOperatingAirlines AS TABLE ( operatingAirline VARCHAR(10))
	DECLARE @tblExcludedAirlines AS TABLE ( excludeAirline VARCHAR(10))	
	DECLARE @tblExcludedCountries AS TABLE ( excludeCountry VARCHAR(10))	  	  
	DECLARE @tblExcludedAirport AS TABLE ( excludeAirport VARCHAR(10))	  
	
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
			-- gourpkey 2: Add data to @tblAirlinesGroup(combination) table @tblOperatingAirlines for 
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
				SELECT AFF.MarketingAirline, AFF.OperatingAirline, 1 from vault.dbo.affiliateAirlines AFF
				INNER JOIN @tblSuperAirlines S ON AFF.MarketingAirline = S.marketingAirline
				WHERE AFF.SiteKey = @siteKey 
				
				IF @airPublishedFareRequest > 0 -- For GroupKey 2
				BEGIN						
					INSERT INTO @tblAirlinesGroup(marketingAirline, operatingAirline, groupKey) 			
					SELECT AFF.MarketingAirline, AFF.OperatingAirline, 2 from vault.dbo.affiliateAirlines AFF
					WHERE AFF.SiteKey = @siteKey
				END
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
			
			IF @airPublishedFareRequest > 0 -- For GroupKey 2
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
		SELECT * FROM vault .dbo.ufn_CSVToTable (@excludeAirline )  
		
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT distinct airresponsekey FROM #AirSegments WHERE airSegmentMarketingAirlineCode   in (SELECT * FROM @tblExcludedAirlines))  
		IF ( (SELECT Count(distinct airresponsekey) FROM #AirSegments WHERE airSegmentMarketingAirlineCode   in (SELECT * FROM @tblExcludedAirlines))  > 0 )
		BEGIN 
			SET @isExcludeAirlinesPresent =  1 
		END
		INSERT @tempResponseToRemove (airresponsekey )   
		(SELECT Distinct s.airResponseKey from AirSegments s WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) on s.airResponseKey =resp.airResponseKey   
		inner join AirSubRequest subReq WITH (NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and   
		airSegmentOperatingAirlineCode in (SELECT * FROM @tblExcludedAirlines))
		IF ( @isExcludeAirlinesPresent = 0 ) 
		BEGIN
			IF((SELECT COUNT(Distinct s.airResponseKey)from AirSegments s WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) on s.airResponseKey =resp.airResponseKey   
		inner join AirSubRequest subReq WITH (NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and   
		airSegmentOperatingAirlineCode in (SELECT * FROM @tblExcludedAirlines))> 0)
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
    
  
	DECLARE @departureOffset AS float 
	SET @departureOffset =(  SELECT distinct  TOP 1  airSegmentDepartureOffset FROM AirSegments seg WITH (NOLOCK) INNER JOIN AirResponse r WITH (NOLOCK) ON seg.airResponseKey =r.airResponseKey
	WHERE(  r.airSubRequestKey = @airBundledRequest      )
	 AND airLegNumber =@airRequestTypeKey AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null  )

 
	DECLARE @arrivalOffset AS float 
	SET @arrivalOffset = (SELECT distinct TOP 1 airSegmentArrivalOffset  FROM AirSegments seg WITH (NOLOCK) INNER JOIN AirResponse r WITH (NOLOCK) ON seg.airResponseKey =r.airResponseKey
	WHERE(  r.airSubRequestKey = @airBundledRequest    )
	 AND airLegNumber = @airRequestTypeKey AND airSegmentArrivalAirport=@endAirPort AND airSegmentArrivalOffset is not null )


 /****time offset logic ends here ***/

/****logic for calculating price for higher legs *****/


	 DECLARE @airPriceForAnotherLeg AS float 
	 DECLARE @airPriceTaxForAnotherLeg AS float 
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

	---- print('multiCIty')
	---- print(@airPriceForAnotherLeg)
	DECLARE @tmpAirline  TABLE (
	airLineCode varchar (200) ) 

	IF @NoOfStops = '-1' /*****Default view WHEN no of stops not selected *********/
	BEGIN 
		SET @NoOfStops = '0,1,2'
	END 


	DECLARE @noStops AS TABLE 
	(
	stops int 
	)

	INSERT @noStops (stops )
	SELECT * FROM vault.dbo.ufn_CSVToTable (@NoOfStops)

	IF @airLines <> ''  and @isIgnoreAirlineFilter <> 1  -- AND @airLines <> 'Multiple Airlines'  -- AND not exists(  SELECT @airLines WHERE @airLines like '%Multiple Airlines%')

	BEGIN 
		INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )  
	END 
	ELSE     
	BEGIN 
		INSERT into @tmpAirline(airlineCode)  SELECT distinct seg1.airSegmentMarketingAirlineCode FROM AirSegments seg1  WITH (NOLOCK) INNER JOIN AirResponse resp  WITH (NOLOCK) ON seg1.airResponseKey = resp.airResponseKey 
		INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey = subreq .airSubRequestKey 
		WHERE ( airRequestKey = @airRequestKey )
		INSERT into @tmpAirline (airLineCode ) values  ('Multiple Airlines')
	END   

---creating TABLE variable for container for flitered result ..
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
		totalCost float ,airSegmentOperatingFlightNumber int, otherlegtax float,
		airSegmentOperatingAirlineCompanyShortName VARCHAR(100) ,
		otherlegAirlines varchar(100) ,
		noOfOtherlegairlines int ,
		airRowNum int identity (1,1) ,
		legDuration int ,
		legConnections Varchar(100),
		actualNoOFStops int,
		isLowestJourneyTime bit,
		isSameAirlinesItin bit,
	 	airSuperSaverTax float ,  
	    airEconSaverTax float ,  
	    airFirstFlexTax  float ,  
	    airCorporateTax  float ,  
	    airEconFlexTax float   ,  
	    airEconUpgradeTax float 
	)

     declare @airrequestType as int 
			set @airrequestType = ( select  airRequestTypeKey  from AirRequest WITH (NOLOCK) where airRequestKey = @airRequestKey ) 
---- print('uniquifying started ..')
---- print (cast(getdate() AS time))
     CREATE TABLE #AllOneWayResponses 
	(
	    --airOneIdent int identity (1,1),
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
		airsubRequestkey int 
		,airLegConnections varchar(200),
		airLegBookingClasses varchar(50),
		otherLegPrice float ,
		otherLegTax float  ,
		cabinClass varchar(20) ,
		otherlegAirlines varchar(100) ,
		noOfOtherlegairlines int    ,
		legConnections Varchar(100)
	 )    

	CREATE TABLE #tempOneWayResponses 
	(
		airOneIdent int,
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
		airsubRequestkey int 
		,airLegConnections varchar(200),
		airLegBookingClasses varchar(50),
		otherLegPrice float ,
		otherLegTax float  ,
		cabinClass varchar(20) ,
		otherlegAirlines varchar(100) ,
		noOfOtherlegairlines int    ,
		legConnections Varchar(100)
	)
	DELETE FROM #tempOneWayResponses 
	if ( @airRequestTypeKey = 1) 
	BEGIN 

		IF ( @gdssourcekey =0  or @gdssourcekey <> 9 ) 
			Begin 
			SET @airPriceForAnotherLeg = (SELECT TOP 1 ( airPriceBase/@airSubRequestCount)  FROM AirResponse resp  WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBase ) 
			SET @airPriceTaxForAnotherLeg = (SELECT TOP 1 ( airPriceTax/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9  order by airPriceTax ) 
			SET @airPriceSeniorForAnotherLeg = (SELECT TOP 1 ( airPriceBaseSenior/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseSenior ) 
			SET @airPriceTaxSeniorForAnotherLeg = (SELECT TOP 1 ( airPriceTaxSenior/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxSenior ) 
			SET @airPriceChildrenForAnotherLeg = (SELECT TOP 1 ( airPriceBaseChildren/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseChildren ) 
			SET @airPriceTaxChildrenForAnotherLeg = (SELECT TOP 1 ( airPriceTaxChildren/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxChildren ) 
			SET @airPriceInfantForAnotherLeg = (SELECT TOP 1 ( airPriceBaseInfant/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseInfant ) 
			SET @airPriceTaxInfantForAnotherLeg = (SELECT TOP 1 ( airPriceTaxInfant/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxInfant ) 
			SET @airPriceYouthForAnotherLeg = (SELECT TOP 1 ( airPriceBaseYouth/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseYouth ) 
			SET @airPriceTaxYouthForAnotherLeg = (SELECT TOP 1 ( airPriceTaxYouth/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxYouth ) 
			SET @airPriceTotalForAnotherLeg = (SELECT TOP 1 ( AirPriceBaseTotal/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by AirPriceBaseTotal ) 
			SET @airPriceTaxTotalForAnotherLeg = (SELECT TOP 1 ( AirPriceTaxTotal/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by AirPriceTaxTotal ) 
			SET @airPriceDisplayForAnotherLeg = (SELECT TOP 1 ( airPriceBaseDisplay/@airSubRequestCount)  FROM AirResponse resp  WITH (NOLOCK)INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseDisplay ) 
			SET @airPriceTaxDisplayForAnotherLeg = (SELECT TOP 1 ( airPriceTaxDisplay/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxDisplay ) 
			
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airLegConnections,airLegBookingClasses,otherLegPrice ,otherLegTax ,cabinClass,airOnePriceBaseSenior,airOnePriceTaxSenior,
			airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,
			airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,legConnections)
			SELECT resp.airresponsekey, (airPriceBase) , flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ),airLegConnections,airLegBookingClasses,
			CASE WHEN @isTotalPriceSort = 0 THEN ISNULL( airPriceBase/@airSubRequestCount ,0) ELSE ISNULL( airPriceBase /@airSubRequestCount,0)  + ISNULL( airPriceTax/@airSubRequestCount ,0) end    , airPriceTax /@airSubRequestCount  ,n.cabinClass,
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airLegConnections 
			FROM NormalizedAirResponses n WITH (NOLOCK) INNER JOIN AirResponse resp  WITH (NOLOCK) ON n.airresponsekey = resp.airResponseKey 
			INNER JOIN AirSubRequest subRequest WITH (NOLOCK) ON resp .airSubRequestKey = subRequest .airSubRequestKey 
			WHERE  airRequestKey = @airRequestKey AND airLegNumber = @airRequestTypeKey
			AND gdsSourceKey <> 9
			
			 
			
			if @airRequestTripType = 1 
			BEGIN  
			update #AllOneWayResponses set otherLegPrice = 0 , otherLegTax = 0 
			END 
		END 

		IF ( @gdssourcekey = 0 or @gdssourcekey = 9 ) 
		BEGIN

				print ( 'farelogix' ) 
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airLegConnections,airLegBookingClasses,otherLegPrice ,otherLegTax  ,cabinClass,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,legConnections)
				SELECT resp.airresponsekey, (airPriceBase   ), flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ),airLegConnections,airLegBookingClasses,
				CASE WHEN @isTotalPriceSort = 0 THEN  airPriceBase /@airSubRequestCount ELSE (airPriceBase /@airSubRequestCount) +(airPriceTax /@airSubRequestCount) end  ,airPriceTax /@airSubRequestCount  ,n.cabinclass,
				airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airLegConnections 
				FROM NormalizedAirResponses n WITH (NOLOCK) INNER JOIN AirResponse resp  WITH (NOLOCK) ON n.airresponsekey = resp.airResponseKey 
				INNER JOIN AirSubRequest subRequest WITH (NOLOCK) ON resp .airSubRequestKey = subRequest .airSubRequestKey 
				WHERE  airRequestKey = @airRequestKey AND airLegNumber = @airRequestTypeKey
				AND  resp.gdsSourceKey = 9 AND isbrandedFare = 0 

				DECLARE @fareLogixBrandedFare AS TABLE 
				(
					airline varchar(2) ,
					airPriceBase float , 
					airPriceTax float  ,
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
					airPriceTaxDisplay float
				)
				
				INSERT @fareLogixBrandedFare ( airline,airPriceBase ,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay )  
				SELECT airlines ,sum (AirAmount ),SUM( airTax ),sum(PriceSenior),sum(TaxSenior),SUM(PriceChildren),SUM(TaxChildren),SUM(PriceInfant),SUM(TaxInfant),SUM(PriceYouth),SUM(TaxYouth),SUM(PriceTotal),SUM(TaxTotal),SUM(PriceDisplay), SUM(TaxDisplay)   FROM 
				(
					SELECT  SUBSTRING (  n.airlines,1,2 )airlines,min (airPriceBase   )AirAmount, MIN ( airpriceTAX) airTax,airLegNumber,
					MIN(airPriceBaseSenior) AS PriceSenior,MIN(airPriceTaxSenior)AS TaxSenior,
					MIN(airPriceBaseChildren) AS PriceChildren,MIN(airPriceTaxChildren) AS TaxChildren,
					MIN(airPriceBaseInfant) AS PriceInfant,MIN(airPriceTaxInfant) AS TaxInfant,
					MIN(airPriceBaseYouth) AS PriceYouth, MIN(airPriceTaxYouth) AS TaxYouth,
					MIN(AirPriceBaseTotal) AS PriceTotal,MIN(AirPriceTaxTotal)AS TaxTotal,
					MIN(airPriceBaseDisplay) AS PriceDisplay, MIN(airPriceTaxDisplay) AS TaxDisplay
				    
					FROM NormalizedAirResponses n WITH (NOLOCK) INNER JOIN AirResponse resp WITH (NOLOCK) ON n.airresponsekey = resp.airResponseKey 
					INNER JOIN AirSubRequest subRequest WITH (NOLOCK) ON resp .airSubRequestKey = subRequest .airSubRequestKey 
					WHERE  airRequestKey = @airRequestKey AND airLegNumber <> @airRequestTypeKey
					AND  resp.gdsSourceKey = 9 AND isbrandedFare =1  GROUP BY SUBSTRING (  n.airlines,1,2 ) ,airLegNumber
				)
				farelogix
				GROUP BY airlines 
				
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airLegConnections,airLegBookingClasses,otherLegPrice ,otherLegTax ,cabinClass,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,legConnections)
					SELECT resp.airresponsekey, (resp.airPriceBase + ISNULL(f.airPriceBase,0)   ), 
					flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(f.airPriceTax,0) ),airLegConnections,airLegBookingClasses,f.airPriceBase   ,f.airPriceTax ,n.cabinclass,
				    (resp.airPriceBaseSenior + ISNULL(f.airPriceBaseSenior,0)   ), 
				    (resp.airPriceTaxSenior + ISNULL(f.airPriceTaxSenior,0) ),
					(resp.airPriceBaseChildren + ISNULL(f.airPriceBaseChildren,0)   ), 
					(resp.airPriceTaxChildren + ISNULL(f.airPriceTaxChildren,0) ),
					(resp.airPriceBaseInfant + ISNULL(f.airPriceBaseInfant,0)   ), 
					(resp.airPriceTaxInfant + ISNULL(f.airPriceTaxInfant,0) ),
					(resp.airPriceBaseYouth + ISNULL(f.airPriceBaseYouth,0)   ), 
					(resp.airPriceTaxYouth + ISNULL(f.airPriceTaxYouth,0) ),
					(resp.AirPriceBaseTotal + ISNULL(f.AirPriceBaseTotal,0)   ),
					(resp.AirPriceTaxTotal + ISNULL(f.AirPriceTaxTotal,0) ),
					(resp.airPriceBaseDisplay + ISNULL(f.airPriceBaseDisplay,0)   ),
					(resp.airPriceTaxDisplay + ISNULL(f.airPriceTaxDisplay,0) ),airLegConnections 
					FROM NormalizedAirResponses n WITH (NOLOCK) INNER JOIN AirResponse resp WITH (NOLOCK) ON n.airresponsekey = resp.airResponseKey 
					INNER JOIN AirSubRequest subRequest WITH (NOLOCK)ON resp .airSubRequestKey = subRequest .airSubRequestKey 
					LEFT OUTER JOIN  @fareLogixBrandedFare f ON SUBSTRING (n.airlines ,1,2 ) = airline 
					WHERE  airRequestKey = @airRequestKey AND airLegNumber = @airRequestTypeKey
					AND  resp.gdsSourceKey = 9 AND isbrandedFare = 1 

		END 


	/***Delete responses which are not available in respective one way responses AS fare buckets are applicable for one way logic  **/ 

	--  DELETE FROM #tempOneWayResponses WHERE airOneResponsekey in (
	--  SELECT airresponsekey FROM NormalizedAirResponses WHERE airsubrequestkey = @airBundledRequest AND airLegNumber =@airRequestTypeKey AND flightNumber not in (
	--SELECT flightNumber FROM NormalizedAirResponses WHERE airsubrequestkey = @airSubRequestKey)) 

	END 
	ELSE
	BEGIN  
			DECLARE @isPure AS int 
			SET  @isPure =(SELECT count(distinct airSegmentMarketingAirlineCode) FROM airsegments WHERE airresponsekey =@selectedResponseKey)
			--if @airLegNumber = 2 /**Round trip or 1st basic validation for 2nd leg */
			--BEGIN
			 DECLARE @valid AS TABLE ( 
			  airResponsekey uniqueidentifier ) 
			  

			--if (SELECT COUNT(*) FROM @SelectedResponse selected INNER JOIN AirResponse resp  ON selected .responsekey = resp.airResponseKey WHERE gdsSourceKey = 9 )	  = 0 
			--BEGIN
			--if ( @selectedFareType = '') /*No bucket selected */
			-- BEGIN

			SET @airPriceForAnotherLeg = (SELECT 
			CASE WHEN @selectedFareType='Super Saver' THEN ISNULL(airSuperSaverPrice/@airSubRequestCount,airPriceBase /@airSubRequestCount )
			WHEN @selectedFareType =   'Econ Saver' THEN   ISNULL(airEconSaverPrice/@airSubRequestCount ,airPriceBase /@airSubRequestCount ) 
			WHEN @selectedFareType =   'First Flex' THEN   ISNULL( airFirstFlexPrice/@airSubRequestCount ,airPriceBase /@airSubRequestCount) 
			WHEN @selectedFareType=   'Corporate' THEN   ISNULL(airCorporatePrice/@airSubRequestCount  ,airPriceBase /@airSubRequestCount) 
			WHEN @selectedFareType =   'Econ Flex' THEN  ISNULL( airEconFlexPrice /@airSubRequestCount ,airPriceBase /@airSubRequestCount) 
			WHEN @selectedFareType =  'Instant Upgrade' THEN  ISNULL ( airEconUpgradePrice/@airSubRequestCount ,airPriceBase /@airSubRequestCount)
			ELSE airPriceBase / @airSubRequestCount
			END 
			FROM AirResponse WITH (NOLOCK) WHERE airresponsekey = @selectedResponseKey )

			SET @airPriceTaxForAnotherLeg = (SELECT 
			CASE WHEN @selectedFareType='Super Saver' THEN ISNULL(airSuperSaverTax/@airSubRequestCount,airPriceTax /@airSubRequestCount)
			WHEN @selectedFareType =   'Econ Saver' THEN   ISNULL(airEconSaverTAx /@airSubRequestCount,airPriceTax /@airSubRequestCount ) 
			WHEN @selectedFareType =   'First Flex' THEN   ISNULL( airFirstFlexTAx/@airSubRequestCount ,airPriceTax /@airSubRequestCount) 
			WHEN @selectedFareType=   'Corporate' THEN   ISNULL(airCorporateTAx/@airSubRequestCount  ,airPriceTax /@airSubRequestCount) 
			WHEN @selectedFareType =   'Econ Flex' THEN  ISNULL( airEconFlexTAx /@airSubRequestCount ,airPriceTax /@airSubRequestCount) 
			WHEN @selectedFareType =  'Instant Upgrade' THEN  ISNULL ( airEconUpgradetax/@airSubRequestCount ,airPriceTax  /@airSubRequestCount)
			ELSE airPriceTAx / @airSubRequestCount
			END 
			FROM AirResponse WITH (NOLOCK) WHERE airresponsekey = @selectedResponseKey )
			
			
			if @airPriceForAnotherLeg =  0 
			BEGIN
				SET @airPriceForAnotherLeg =  (SELECT airPriceBase /@airSubRequestCount FROM AirResponse WITH (NOLOCK) WHERE airresponsekey = @selectedResponseKey )
				SET @airPriceTaxForAnotherLeg  =  (SELECT airPricetax /@airSubRequestCount FROM AirResponse WITH (NOLOCK)WHERE airresponsekey = @selectedResponseKey )
				SET @airPriceSeniorForAnotherLeg = (SELECT TOP 1 ( airPriceBaseSenior/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseSenior ) 
				SET @airPriceTaxSeniorForAnotherLeg = (SELECT TOP 1 ( airPriceTaxSenior/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxSenior ) 
				SET @airPriceChildrenForAnotherLeg = (SELECT TOP 1 ( airPriceBaseChildren/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseChildren ) 
				SET @airPriceTaxChildrenForAnotherLeg = (SELECT TOP 1 ( airPriceTaxChildren/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxChildren ) 
				SET @airPriceInfantForAnotherLeg = (SELECT TOP 1 ( airPriceBaseInfant/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseInfant ) 
				SET @airPriceTaxInfantForAnotherLeg = (SELECT TOP 1 ( airPriceTaxInfant/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxInfant )
				SET @airPriceYouthForAnotherLeg = (SELECT TOP 1 ( airPriceBaseYouth/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseYouth ) 
				SET @airPriceTaxYouthForAnotherLeg = (SELECT TOP 1 ( airPriceTaxYouth/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxYouth )
				SET @airPriceTotalForAnotherLeg = (SELECT TOP 1 ( AirPriceBaseTotal/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by AirPriceBaseTotal ) 
				SET @airPriceTaxTotalForAnotherLeg = (SELECT TOP 1 ( AirPriceTaxTotal/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by AirPriceTaxTotal) 
				SET @airPriceDisplayForAnotherLeg = (SELECT TOP 1 ( airPriceBaseDisplay/@airSubRequestCount)  FROM AirResponse resp  WITH (NOLOCK)INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseDisplay ) 
				SET @airPriceTaxDisplayForAnotherLeg = (SELECT TOP 1 ( airPriceTaxDisplay/@airSubRequestCount)  FROM AirResponse resp  WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxDisplay)
		 	END 
		 	
			IF ( SELECT  isBrandedFare FROM AirResponse WITH (NOLOCK) WHERE airresponsekey = @selectedResponseKey ) = 0 
			BEGIN 
		    
			IF ( @airrequestType = 2) 
			BEGIN 
				INSERT @valid ( airResponsekey ) 
 			 ( SELECT * FROM dbo.[ufn_GetValidResponsesForMultiCityInternational]   (@airRequestTypeKey  ,@airSubRequestKey   , @selectedResponseKey   ,@selectedResponseKeySecond   ,@selectedResponseKeyThird   ,@selectedResponseKeyFourth ,@selectedResponseKeyFifth    ))
				print('To do round tripe' )
			END 
			ELSE IF ( @airrequestType = 3) 
			BEGIN
			 INSERT @valid ( airResponsekey ) 

				( SELECT * FROM dbo.[ufn_GetValidResponsesForMultiCityInternational]   (@airRequestTypeKey  ,@airSubRequestKey   , @selectedResponseKey   ,@selectedResponseKeySecond   ,@selectedResponseKeyThird   ,@selectedResponseKeyFourth ,@selectedResponseKeyFifth  ))
			END 
			--END 
			   

 			   INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax   ,cabinClass ,otherLegPrice,otherLegTax,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal ,airOnePriceBaseDisplay, airOnePriceTaxDisplay,legConnections)
 								 SELECT resp.AirResponsekey,								 
 						         (CASE WHEN @selectedFareType = '' THEN  airPriceBase ELSE ((airPriceBase/@airSubRequestCount)+ @airPriceForAnotherLeg )  END ),
 						         nresp.flightNumber ,nresp.airlines,resp.airSubRequestKey,
 								    (CASE WHEN @selectedFareType = '' THEN  airPriceTax ELSE ((airPriceTax/@airSubRequestCount)+ @airPriceTaxForAnotherLeg )  END ) 
 								     ,nresp.cabinclass,
 									 (case when @isTotalPriceSort = 0 then @airPriceForAnotherLeg else @airPriceForAnotherLeg + @airPriceTaxForAnotherLeg  end), 
 									 isnull(@airPriceTaxForAnotherLeg /@airSubRequestCount ,airPriceTax /@airSubRequestCount ),
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceBaseSenior ELSE ((airPriceBaseSenior/@airSubRequestCount)+ @airPriceSeniorForAnotherLeg )  END ),
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceTaxSenior ELSE ((airPriceTaxSenior/@airSubRequestCount)+ @airPriceTaxSeniorForAnotherLeg )  END ) ,
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceBaseChildren ELSE ((airPriceBaseChildren/@airSubRequestCount)+ @airPriceChildrenForAnotherLeg )  END ),
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceTaxChildren ELSE ((airPriceTaxChildren/@airSubRequestCount)+ @airPriceTaxChildrenForAnotherLeg )  END ) ,
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceBaseInfant ELSE ((airPriceBaseInfant/@airSubRequestCount)+ @airPriceInfantForAnotherLeg )  END) ,
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceTaxInfant ELSE ((airPriceTaxInfant/@airSubRequestCount)+ @airPriceTaxInfantForAnotherLeg )  END ) ,
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceBaseYouth ELSE ((airPriceBaseYouth/@airSubRequestCount)+ @airPriceYouthForAnotherLeg )  END) ,
 									 (CASE WHEN @selectedFareType = '' THEN  airPriceTaxYouth ELSE ((airPriceTaxYouth/@airSubRequestCount)+ @airPriceTaxYouthForAnotherLeg )  END ) ,
 									 (CASE WHEN @selectedFareType = '' THEN  AirPriceBaseTotal ELSE ((AirPriceBaseTotal/@airSubRequestCount)+ @airPriceTotalForAnotherLeg )  END) ,
 									 (CASE WHEN @selectedFareType = '' THEN  AirPriceTaxTotal ELSE ((AirPriceTaxTotal/@airSubRequestCount)+ @airPriceTaxTotalForAnotherLeg )  END ),
 								   (CASE WHEN @selectedFareType = '' THEN  airPriceBaseDisplay ELSE ((airPriceBaseDisplay/@airSubRequestCount)+ @airPriceForAnotherLeg )  END ),
 								   (CASE WHEN @selectedFareType = '' THEN  airPriceTaxDisplay ELSE ((airPriceTaxDisplay/@airSubRequestCount)+ @airPriceTaxForAnotherLeg )  END)    ,
 								   airLegConnections 
								   FROM AirResponse resp  WITH (NOLOCK)
								   INNER JOIN @valid valid ON resp.airResponseKey = valid .airResponsekey 
								   INNER JOIN NormalizedAirResponses nresp WITH (NOLOCK) ON resp.airResponseKey = nresp .airresponsekey 
								   AND ISNULL(resp.gdsSourceKey,2) =( CASE WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) AND nresp .airLegNumber = @airRequestTypeKey

			END 
			ELSE  

			BEGIN
				print ( 'flx') 
				DECLARE @flxairlines AS varchar(10) 
				SET @flxairlines  = (SELECT distinct airSegmentMarketingAirlineCode FROM AirSegments WHERE airResponseKey = @selectedResponseKey)
				   INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay ,legConnections)
				   SELECT r.airResponseKey , r.airPriceBase + @airPriceForAnotherLeg , n.flightNumber ,n.airlines ,r.airSubRequestKey ,airPriceTax + @airPriceTaxForAnotherLeg ,
				   r.airPriceBaseSenior + @airPriceSeniorForAnotherLeg ,
				   airPriceTaxSenior + @airPriceTaxSeniorForAnotherLeg ,
				   r.airPriceBaseChildren + @airPriceChildrenForAnotherLeg ,
				   airPriceTaxChildren + @airPriceTaxChildrenForAnotherLeg ,
				   r.airPriceBaseInfant + @airPriceInfantForAnotherLeg ,
				   airPriceTaxInfant + @airPriceTaxInfantForAnotherLeg ,
				   r.airPriceBaseYouth + @airPriceYouthForAnotherLeg ,
				   airPriceTaxYouth + @airPriceTaxYouthForAnotherLeg ,
				   r.AirPriceBaseTotal + @airPriceTotalForAnotherLeg ,
				   r.AirPriceTaxTotal + @airPriceTaxTotalForAnotherLeg ,
				   r.airPriceBaseDisplay + @airPriceDisplayForAnotherLeg ,
				   airPriceTaxDisplay + @airPriceTaxDisplayForAnotherLeg ,
				   airLegConnections 
				   FROM AirResponse r WITH (NOLOCK) INNER JOIN NormalizedAirResponses n WITH (NOLOCK) ON r.airResponseKey = n.airresponsekey  INNER JOIN AirSubRequest subReq ON n.airsubrequestkey = subReq.airSubRequestKey 
				   WHERE SUBSTRING ( n.airlines ,1,2 ) = @flxairlines AND airRequestKey = @airRequestKey AND airLegNumber = @airRequestTypeKey
			END 

	END 
print ('NEW' ) 
			print (@airPriceForAnotherLeg)
		--END 
		-- print( 'valid oneways1') 

		/***getting valid one ways ***/
		DECLARE @noOfLegsForRequest AS int 
		SET @noOfLegsForRequest =( SELECT COUNT(*) FROM AirSubRequest WITH (NOLOCK) WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex > 0 ) 

		--DECLARE @validOneWays AS bit = 1 

		--if  @noOfLegsForRequest > 1 
		--BEGIN
		--if ( @airRequestTypeKey > 1 )
		--BEGIN  
		-- if ( SELECT COUNT (*) FROM @SelectedResponse ) = @airRequestTypeKey -1 
		--		BEGIN 
		--		SET @validOneWays = 1
		--		END 
		--		ELSE  
		--		BEGIN
		--		SET @validOneWays = 0 
		--		 END 
		--		 END 
		--END 
		---- print( 'valid oneways') 
		---- print ( @validOneWays) 
		--/***END  valid one ways ***/

		-- if ( @validOneWays =1 ) /**checking for all leg one way prices are available*/
		--BEGIN 
		--  INSERT #tempOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax  )
		--   SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ), flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0))
		--   FROM NormalizedAirResponses n INNER JOIN AirResponse resp ON n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey 
		-- AND ISNULL(resp.gdsSourceKey,2) = (CASE WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )

		--END 
		-- print(@airPriceTaxForAnotherLeg) 
 /***Delete all other airlines other than filter airlines**/
 
  DECLARE @secondLegDetails as TABLE 
  (
  otherLegAirlines varchar(40) , 
  responsekey uniqueidentifier , 
  otherlegsAirlinesCount int 
  
  )

       INSERT @secondLegDetails ( otherlegsAirlinesCount ,responsekey ,otherLegAirlines )
		SELECT COUNT(DISTINCT airSegmentMarketingAirlineCode) , seg.airResponseKey ,
		( CASE WHEN (COUNT(DISTINCT airSegmentMarketingAirlineCode))> 1 THEN 'Multiple Airlines' ELSE 
		MIN (airSegmentMarketingAirlineCode ) END ) From airsegments seg WITH (NOLOCK)  INNER JOIN airresponse r WITH ( NOLOCK)
		ON seg.airResponseKey = r.airResponseKey where airSubRequestKey =@airBundledRequest  and airLegNumber = 2
		GROUP BY seg.airResponseKey 

 

		INSERT @secondLegDetails ( otherlegsAirlinesCount ,responsekey ,otherLegAirlines )
		SELECT COUNT(DISTINCT airSegmentMarketingAirlineCode) , seg.airResponseKey ,
		( CASE WHEN (COUNT(DISTINCT airSegmentMarketingAirlineCode))> 1 THEN 'Multiple Airlines' ELSE 
		MIN (airSegmentMarketingAirlineCode ) END ) From airsegments seg WITH (NOLOCK)  INNER JOIN airresponse r WITH ( NOLOCK)
		ON seg.airResponseKey = r.airResponseKey where airSubRequestKey =@airPublishedFareRequest  and airLegNumber = 2
		GROUP BY seg.airResponseKey 
		
		UPDATE  A  SET otherlegAirlines = S.otherLegAirlines , noOfOtherlegairlines = otherlegsAirlinesCount  FROM #AllOneWayResponses A inner join @secondLegDetails S on A.airOneResponsekey = S.responsekey and airsubRequestkey = @airBundledRequest 
     
     
     
 	INSERT into #tempOneWayResponses 
	SELECT ROW_NUMBER() over (order by (case when @isTotalPriceSort = 0 then airOnePriceBaseDisplay  else airOnePriceBaseDisplay + airOnePriceTaxDisplay end )  ) AS airOneIdent , * FROM #AllOneWayResponses  
	 
	--- SELECT airsubRequestkey, * FROM #tempOneWayResponses where airsubRequestkey = @airBundledRequest 
 -- IF @gdssourcekey = 9 
-- BEGIN
-- if ( @airLines <> 'Multiple Airlines')
-- BEGIN
--	delete from #tempOneWayResponses where airOneResponsekey in (
--	select distinct seg.airResponseKey   FROM AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey 
--		INNER JOIN AirSubRequest subrequest ON resp.airSubRequestKey = subrequest .airSubRequestKey and seg.airSegmentMarketingAirlineCode not in (select * From @tmpAirline ) 
--	 	WHERE   airrequestKey = @airRequestKey    AND gdsSourceKey = @gdssourcekey)
	 	
	 

--END
--END 
	Delete P
		 FROM #tempOneWayResponses P
		 INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey
		 
		  --  SELECT airsubRequestkey, * FROM #tempOneWayResponses where airsubRequestkey = @airBundledRequest 
 	DELETE #tempOneWayResponses
	FROM #tempOneWayResponses t,
	(
		SELECT min(airOnePriceBaseDisplay + airOnePriceTaxDisplay) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,isnull(cabinClass ,'') cabinClass
		FROM #tempOneWayResponses m
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode   ,isnull(cabinClass ,'')
		having count(1) > 1
	) AS derived
	WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode  AND isnull(t.cabinclass,'') =isnull(derived .cabinclass,'') 
	AND airOnePriceBaseDisplay + airOnePriceTaxDisplay >= minPrice  AND airOneIdent > minIdent
	---- print (cast(getdate() AS time))
	---- print('uniquifying ended ..')
 

	DECLARE @rowIndex AS INT = 0
	
	CREATE TABLE #normalizedResultSet
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
		otherlegPrice float ,otherlegtax float ,
		otherlegAirlines varchar(100) ,
		noOfOtherlegairlines int    ,
		legConnections Varchar(100) ,
		actualNoOFStops int,
		legDurationInMinutes INT ,
		legDuration INT ,
		startingFlightNumber Varchar(10),
		startingFlightAirline Varchar(20),
		isLowestJourneyTime bit default 0, 
		rowNumber INT,
		isSameAirlinesItin bit default 0,
		lastFlightNumber Varchar(10),
   lastFlightAirline Varchar(20) 
	) 

		INSERT  #normalizedResultSet (airresponsekey ,airPriceBase,noOFStops ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey ,airpricetax ,airsubrequetkey ,cabinclass ,otherlegPrice,otherlegtax  ,legConnections ,actualNoOFStops,otherlegAirlines,noOfOtherlegairlines )
		(
			SELECT seg.airresponsekey,result.airOnePriceBaseDisplay ,CASE WHEN COUNT(seg.airresponsekey )-1 > 1 THEN (CASE WHEN @MaxNoofstops=2 THEN 2 ELSE 1 END) ELSE  COUNT(seg.airresponsekey )-1 END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ),
			CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,
			resp.gdsSourceKey, result .airOnePriceTaxDisplay ,result.airsubRequestkey ,result .cabinClass  ,otherLegPrice,otherLegTax  ,legConnections ,(COUNT(seg.airresponsekey )-1),otherlegAirlines,noOfOtherlegairlines 
			FROM 
			#tempOneWayResponses result  INNER JOIN 
			AirResponse resp WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey 
			INNER JOIN
			AirSegments seg  WITH (NOLOCK)  ON result .airOneResponsekey = seg.airResponseKey 
			WHERE airLegNumber = @airRequestTypeKey
			GROUP BY seg.airResponseKey,result.airOnePriceBaseDisplay ,gdssourcekey  ,result .airOnePriceTaxDisplay , result.airsubRequestkey ,result.cabinClass ,result.otherlegprice,otherLegTax ,legConnections,result.otherlegAirlines ,result.noOfOtherlegairlines
		 )
 
		/**Remove participating airlines ***/
		
		--DELETE N FROM #normalizedResultSet N INNER JOIN @superAirlines S on N.airlineCode = S.airLineCode
		-- where airsubrequetkey = @airPublishedFareRequest  
		
		/******/
		
		 /****Logic for lower connection point display Rick's recommendation point#9 ******/
		 UPDATE  N SET takeoffdate = airSegmentDepartureDate  , startingFlightAirline = airSegmentMarketingAirlineCode , startingFlightNumber = airSegmentFlightNumber   FROM #normalizedResultSet N inner join
				 AirSegments seg  WITH (NOLOCK) ON N.airresponsekey = seg.airResponseKey  and seg.airLegNumber =@airRequestTypeKey and segmentOrder = 1 
				
		 --UPDATE  N SET landingdate  = airSegmentArrivalDate   FROM #normalizedResultSet N inner join
			--	 AirSegments seg  WITH (NOLOCK) ON N.airresponsekey = seg.airResponseKey  and seg.airLegNumber =@airRequestTypeKey and segmentOrder = (n.actualNoOFStops + 1) 
		
		 UPDATE  N SET landingdate  = airSegmentArrivalDate ,lastFlightAirline = airSegmentMarketingAirlineCode , lastFlightNumber = airSegmentFlightNumber    FROM #normalizedResultSet N inner join
		 AirSegments seg  WITH (NOLOCK) ON N.airresponsekey = seg.airResponseKey  and seg.airLegNumber =@airRequestTypeKey and segmentOrder = (n.actualNoOFStops + 1) 
				
		 UPDATE  N SET legDurationInMinutes = DATEDIFF( MINUTE , DATEADD( MINUTE, (@departureOffset*-1),N.takeoffdate ), DATEADD( MINUTE, (@arrivalOffset*-1), N.landingdate) ),
		 legDuration  = DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),N.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), N.landingdate) )
		 FROM #normalizedResultSet N
		 
		 UPDATE #normalizedResultSet 
		 SET @rowIndex = RowNumber = @rowIndex + 1 
	 		 
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
		 
		 
		 --UPDATE  N1 SET isLowestJourneyTime = 1 FROM #normalizedResultSet N1 
		 --INNER JOIN 
		 --(
		 --SELECT  MIN(rowNumber) minRowIndex ,MAX(rowNumber) maxRowIndex, MIN(N.legDurationInMinutes) durationInMinutes,MAX(N.legDurationInMinutes) maximumDuration,COUNT(*) totalRecords ,noOFSTOPs ,startingFlightAirline ,startingFlightNumber,( airPriceBase  + airpriceTax ) Price  FROM #normalizedResultSet N 
		 --GROUP BY noOFSTOPs ,startingFlightAirline ,startingFlightNumber , ( airPriceBase  + airpriceTax ),N.legConnections
		 -- )   DERIVED 
		 --ON N1.rowNumber = DERIVED.minRowIndex
		 
		 UPDATE #normalizedResultSet SET isSameAirlinesItin = 1 WHERE (airlineCode = otherlegAirlines ) 
			and airlineCode<> 'Multiple Airlines' AND otherlegAirlines <> 'Multiple Airlines'
			
		 UPDATE #normalizedResultSet SET isSameAirlinesItin = 1 WHERE  airlineCode = 'Multiple Airlines'
  
	 IF ( @airRequestType = 1) 
	 BEGIN 
	  UPDATE #normalizedResultSet SET isSameAirlinesItin = 1
	 END
 
 
 		INSERT into #airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfStops ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey , airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected,otherLegPrice,isRefundable,isBrandedFare  ,cabinClass ,fareType,segmentOrder ,airsegmentCabin ,totalCost,airSegmentOperatingFlightNumber ,otherlegtax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airSegmentOperatingAirlineCompanyShortName,legConnections ,legDuration ,actualNoOFStops,isLowestJourneyTime,isSameAirlinesItin,otherlegAirlines,noOfOtherlegairlines
 		,airSuperSaverTax,airEconSaverTax,airFirstFlexTax,airCorporateTax,airEconFlexTax,airEconUpgradeTax)  
			SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,noOFStops  ,  takeoffdate  , landingdate ,airSegmentOperatingAirlineCode , seg.airSegmentResBookDesigCode,noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver ,priceClassCommentsEconSaver,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice ,airEconFlexPrice,airEconUpgradePrice,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected , 		
		   otherlegPrice ,refundable, isBrandedFare, normalized.cabinclass ,fareType,segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,otherlegtax, airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay, seg.airSegmentOperatingAirlineCompanyShortName,
		    legconnections,DATEDIFF( HOUR , DATEADD( HOUR, (@departureOffset*-1),normalized.takeoffdate ), DATEADD( HOUR, (@arrivalOffset*-1), normalized.landingdate) ) ,actualNoOFStops,isLowestJourneyTime,isSameAirlinesItin,otherlegAirlines,noOfOtherlegairlines 
		    ,airSuperSaverTax,airEconSaverTax,airFirstFlexTax,airCorporateTax,airEconFlexTax,airEconUpgradetax
			FROM #AirSegments seg   
			INNER JOIN #normalizedResultSet normalized ON seg.airresponsekey = normalized .airresponsekey 
			INNER JOIN AirResponse resp WITH (NOLOCK) ON seg .airresponsekey = resp.airResponseKey 
			INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops 
			INNER JOIN  AirVendorLookup airVendor WITH (NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode  
			 WHERE  normalized.airPriceBase  <=    @price  			AND 
			 ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )
			AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )
			
			 select * from #AirSegments where airResponseKey = 'E4F5E16C-9636-4A8E-B5BF-F1C12B932E7A'
			 return
		
		---- print ( cast(getdate() AS time )  )
		---- print('result')
		CREATE TABLE #pagingResultSet 
		(
		rowNum int IDENTITY(1,1) NOT NULL,   
		airResponseKey uniqueidentifier  ,
		airlineName varchar(100), 
		airPrice float , 
		actualTakeOffDateForLeg datetime ,
		isSmartFare bit default 0  
		) 

	IF @sortField <> ''
	BEGIN 
		INSERT into #pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )

		SELECT    air.airResponseKey ,MIN(airPrice ) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air 
		INNER JOIN #normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey 
		INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   ) 
		GROUP BY air.airResponseKey,airlineName,normalized.legDurationInMinutes     order by 
		CASE WHEN @sortField  = 'Price'      THEN    ( case When @isTotalPriceSort = 0  then ROUND(MIN( airPrice),0)  else ROUND(MIN(totalCost ),0) END  )     END  ,  
		CASE WHEN @sortField  = 'Airline' THEN  MIN(MarketingAirlineName)         END   , 
		CASE WHEN @sortField  ='Departure' THEN MIN( actualTakeOffDateForLeg) END   ,
		--CASE WHEN @sortField ='Duration' THEN MIN(duration) END ,
		CASE WHEN @sortField  ='' THEN ROUND( MIN( airPrice),0)  END ,
	    normalized.legDurationInMinutes  
	 
	---- print ( cast(getdate() AS time )  )

	END 
	ELSE 
	BEGIN 
		INSERT into #pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )
		SELECT    air.airResponseKey ,MIN(airPrice ) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air 
		INNER JOIN #normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey 
		INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   ) 
		GROUP BY air.airResponseKey,airlineName,normalized.legDurationInMinutes     order by ( case When @isTotalPriceSort = 0  then ROUND(MIN( airPrice),0)  else ROUND(MIN(totalCost ),0) END), normalized.legDurationInMinutes,MIN(MarketingAirlineName) , min(normalized.noOFStops ),MIN( actualTakeOffDateForLeg) ,MIN( actualLandingDateForLeg )
	-- print('page default')
	END 
---- print ( cast(getdate() AS time )  )

	if ( @superSetAirlines is not null AND @superSetAirlines <> '' )
	BEGIN 
		Delete P
		FROM #pagingResultSet P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
		
	END 
	IF ( @excludeAirline  <> '' AND @excludeAirline IS NOT NULL )
	BEGIN 
		Delete P
		FROM #pagingResultSet P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
		
	END 
	IF ( @excludedCountries  <> '' AND @excludedCountries IS NOT NULL )
	BEGIN 
		Delete P
		FROM #pagingResultSet P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
		
	END 
	
	
		
  /**MAIN RESULTSET FOR LIST STARTS HERE**/
	SELECT distinct rowNum,air.*, airSegmentArrivalOffset,departureAirport .CityName AS DepartureAirPortCityName ,departureAirport.StateCode AS DepartureAirportStateCode ,departureAirport .AirportName AS DepartureAirportName , departureAirport.CountryCode AS DepartureAirportCountryCode, 
	arrivalAirport .CItyName AS ArrivalAirPortCityName ,arrivalAirport .StateCode AS ArrivalAirportStateCode , arrivalAirport .AirportName AS ArrivalAirportName ,arrivalAirport .CountryCode  AS ArrivalAirportCountryCode,
	operatingAirline .ShortName AS OperatingAirlineName,isRefundable ,isbrandedFare ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,
	CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName,issmartFare
	FROM #airResponseResultset air INNER JOIN #pagingResultSet  paging ON air.airResponseKey = paging.airResponseKey
	LEFT OUTER JOIN AirVendorLookup operatingAirline WITH (NOLOCK)   ON air .airSegmentOperatingAirlineCode = operatingAirline .AirlineCode 
	LEFT OUTER JOIN AirportLookup departureAirport WITH (NOLOCK)  ON air .airSegmentDepartureAirport = departureAirport .AirportCode 
	LEFT OUTER JOIN AirportLookup arrivalAirport  WITH (NOLOCK)  ON air .airSegmentArrivalAirport =arrivalAirport .AirportCode 
	LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode
	LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode
	
	WHERE ---rowNum > @FirstRec  AND rowNum< @LastRec   AND
	airLegNumber = CASE WHEN @airRequestTypeKey > -1 THEN @airRequestTypeKey ELSE airLegNumber END  
	order by rowNum ,airLegNumber ,segmentOrder, airSegmentDepartureDate
  /**MAIN RESULTSET FOR LIST ENDS HERE**/
  if ( @superSetAirlines is not null AND @superSetAirlines <> '' )
	BEGIN 
		Delete P
		FROM #airResponseResultset P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
		
		Delete P
		FROM #normalizedResultSet P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
	 
	END 
	IF ( @excludeAirline  <> '' AND @excludeAirline IS NOT NULL )
	BEGIN 
		Delete P
		FROM #airResponseResultset P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
		
		Delete P
		FROM #normalizedResultSet P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
	 
	END 
	
	IF ( @excludedCountries  <> '' AND @excludedCountries IS NOT NULL )
	BEGIN 
		Delete P
		FROM #airResponseResultset P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
		
		Delete P
		FROM #normalizedResultSet P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
	 
	END 
	
	
	
  /****MIN-MAX PRICE FOR FILTERS ***/
	SELECT (case when @isTotalPriceSort = 0 then MIN (airPrice)  else MIN (totalCost ) end ) AS LowestPrice ,(case when @isTotalPriceSort = 0 then MAX (airPrice)  else MAX (totalCost ) end ) AS HighestPrice FROM #airResponseResultset  result1 
	/****MIN-MAX PRICE FOR FILTERS END***/
	
	/****TAKEOFF-LANDING TIME START****/
	SELECT distinct  CASE WHEN  MIN (actualTakeOffDateForLeg ) = MAX (actualTakeOffDateForLeg) THEN DATEADD(MINUTE, -1, MIN (actualTakeOffDateForLeg)) ELSE MIN (actualTakeOffDateForLeg) END AS MinDepartureTakeOffDate,  MAX (actualTakeOffDateForLeg) AS MaxDepartureTakeOffDate, MIN (actualLandingDateForLeg) AS MinDepartureLandingDate,  MAX (actualLandingDateForLeg) AS MaxDepartureLandingDate,
	cast(CAST(CONVERT(DATE, MAX (actualLandingDateForLeg)) AS VARCHAR(20)) +' '+Replace(Min(Replace(LEFT(CONVERT(TIME(0),actualLandingDateForLeg) ,5),':','.')),'.',':') +':00' as datetime) as MinDepartureLandingTime ,
	cast(CAST(CONVERT(DATE, MAX (actualLandingDateForLeg)) AS VARCHAR(20)) +' '+Replace(Max(Replace(LEFT(CONVERT(TIME(0),actualLandingDateForLeg) ,5),':','.')),'.',':') +':00' as datetime) as MaxDepartureLandingTime
	FROM #airResponseResultset  
	/****TAKEOFF-LANDING TIME END****/
	
	/* Stops for Slider START*/
	SELECT distinct NoOfStops AS NoOfStops  FROM #airResponseResultset    
   /* Stops for Slider END*/

	/******TOTAL RECORD COUNT FOUND START *********/
    SELECT COUNT(*) AS [TotalCount] FROM #pagingResultSet 
	/******TOTAL RECORD COUNT FOUND END *********/ 
	IF @airLines <> '' and @isIgnoreAirlineFilter = 1  
	BEGIN
		delete from @tmpAirline  
	 	INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )  
	 
	END
	
	/*** MATRIX LOGIC START HERE ***/
	if ( SELECT COUNT (*) FROM @tmpAirline) > 1  
	BEGIN 
		SELECT (case when @isTotalPriceSort = 0 then MIN (airPrice)  else MIN (totalCost ) end )AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode FROM #airResponseResultset air
		INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey 
		INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode 
		LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode 
		GROUP BY airlineName ,ShortName 
	END 
	ELSE 
	BEGIN  
		SELECT (case when @isTotalPriceSort = 0 then MIN (airPrice)  else MIN (totalCost ) end )AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode FROM #airResponseResultset air
		INNER JOIN #normalizedResultSet n ON air.airResponseKey = n.airresponsekey 
		LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode 
		GROUP BY airlineName ,ShortName 
	END 
	print(@noOfLegsForRequest)
		print(@noOfLegsForRequest)
	DECLARE @markettingAirline AS varchar(100)
	DECLARE @noOFDrillDownCount as int 
		IF @airRequestTypeKey > 1 
			BEGIN 
			 
				IF (SELECT count(distinct (airSegmentMarketingAirlineCode ))  FROM AirSegments seg WITH (NOLOCK) WHERE airResponseKey =@selectedResponseKey AND airLegNumber = @airRequestTypeKey-1 ) = 1 
				BEGIN
				IF   (SELECT COUNT(*) FROM @tmpAirline) > 1 
					BEGIN
						SET @markettingAirline  =(SELECT distinct  TOP 1(airSegmentMarketingAirlineCode )   FROM AirSegments seg WITH (NOLOCK) WHERE airResponseKey =@selectedResponseKey AND airLegNumber = @airRequestTypeKey-1)  
						print('a1')
					END
					ELSE 
					BEGIN
						SET @markettingAirline= @airLines
						print('a2')					 
					END
				END 
				ELSE IF (@airLines <> '') AND (select COUNT(*) from @tmpAirline ) = 1
					BEGIN 
					SET @markettingAirline= @airLines		
					print('a3')					 
					END 
				ELSE
				BEGIN 
					SET @markettingAirline='Multiple Airlines'
				 print('a4')
				END 
			END 
			ELSE 
			BEGIN
				if   (SELECT COUNT(*) FROM @tmpAirline) = 1 
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
		 print ('newtest')
		 
		--SET @noOFDrillDownCount = ( SELECT top 1 COUNT(*)   FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
		--	GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName )
		SET @noOFDrillDownCount = (SELECT top 1 COUNT(*)  FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = @markettingAirline )
		 END 
			ELSE 
			BEGIN 
			print ('newtest2')
			SET @noOFDrillDownCount = (SELECT top 1 COUNT(*)  FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = 'Multiple Airlines' )
			
		 
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
		select @drillDownLevel 
	IF ( @drillDownLevel =0 ) 
	BEGIN
			IF ( @airRequestTypeKey = 0 ) 
			BEGIN
				DECLARE @seconSubRequestKey AS int 
				SET @seconSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WITH (NOLOCK) WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = 2 )

				DECLARE @tmpSecondLowestPrice AS TABLE 
				(
				legPrice float ,
				airline varchar(100) 
				)
				INSERT @tmpSecondLowestPrice (legPrice ,airline   )

				--(SELECT min(airPriceBAse    ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar
				--INNER JOIN AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey 
				-- WHERE airSubRequestKey = @seconSubRequestKey GROUP BY  airSegmentMarketingAirlineCode


				SELECT min(airPriceBAse) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar WITH (NOLOCK)
				INNER JOIN 
				(SELECT A.* FROM #AirSegments A  
				Except 
				SELECT A.* FROM #AirSegments A INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) Tmp
				ON ar.airResponseKey = Tmp.airResponseKey 
				WHERE airSubRequestKey = @seconSubRequestKey GROUP BY  airSegmentMarketingAirlineCode

				DECLARE @thirdSubRequestKey AS int 
				SET @thirdSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WITH (NOLOCK) WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =3 )

				DECLARE @tmpThirdLowestPrice AS TABLE 
				(
				thirdlegPrice float ,
				airline varchar(100) 
				)
				INSERT @tmpThirdLowestPrice (thirdlegPrice ,airline   )
				SELECT min(airPriceBAse    ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar WITH (NOLOCK)
				INNER JOIN #AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey 
				WHERE airSubRequestKey = @thirdSubRequestKey GROUP BY  airSegmentMarketingAirlineCode 

				DECLARE @fourthSubRequestKey AS int 
				SET @fourthSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WITH (NOLOCK) WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =4 )

				DECLARE @tmpFourthLowestPrice AS TABLE 
				(
				fourthlegPrice float ,
				airline varchar(100) 
				)
				
				INSERT @tmpFourthLowestPrice (fourthlegPrice ,airline   )
				SELECT min(airPriceBAse    ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar WITH (NOLOCK)
				INNER JOIN #AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey 
				WHERE airSubRequestKey = @fourthSubRequestKey GROUP BY  airSegmentMarketingAirlineCode 

				DECLARE @fifthSubRequestKey AS int 
				SET @fifthSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WITH (NOLOCK)WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =4 )

				DECLARE @tmpFifthLowestPrice AS TABLE 
				(
				fifthlegPrice float ,
				airline varchar(100) 
				)
				INSERT @tmpFifthLowestPrice (fifthlegPrice ,airline   )
				SELECT min(airPriceBAse    ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar WITH (NOLOCK)
				INNER JOIN #AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey 
				WHERE airSubRequestKey = @fifthSubRequestKey GROUP BY  airSegmentMarketingAirlineCode 


				if(@superSetAirlines != '')
				BEGIN

					SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights ,CONVERT(BIT,1) AS isSameAirlinesItin  FROM 
					(
					SELECT min (r.airPriceBase   +ISNULL( legPrice,0) + ISNULL (thirdlegPrice ,0) 

					+ ISNULL (fourthlegPrice ,0) + ISNULL (fifthlegPrice ,0) 

					) AS LowestPrice
					,t.noOFStops AS NoOFSegments,t.airlineCode  AS airSegmentMarketingAirlineCode,COUNT(distinct r.airResponseKey ) noOFFLights  

					FROM 
					#normalizedResultSet   t INNER JOIN 
					(
						SELECT A.* FROM AirResponse A WITH (NOLOCK) 
						Except 
						SELECT A.* FROM AirResponse A WITH (NOLOCK) INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) r 
						ON t.airresponsekey = r.airResponseKey 
						INNER JOIN @tmpAirline air ON t.airlineCode = air.airLineCode 
						LEFT OUTER JOIN @tmpSecondLowestPrice s ON s.airline = t.airlineCode  
						LEFT OUTER JOIN @tmpThirdLowestPrice third ON t.airlineCode = third.airline 
						LEFT OUTER JOIN @tmpFourthLowestPrice fourth ON t.airlineCode = fourth .airline 
						LEFT OUTER JOIN @tmpFifthLowestPrice fifth ON t.airlineCode = fifth .airline 
						WHERE t.airsubrequetkey  = @airSubRequestKey AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFStops 
						union 
						SELECT (case when @isTotalPriceSort = 0 then MIN (t.airPriceBase)  else MIN (t.airpricebase +t.airpriceTax ) end ), t.noOFStops,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights     
						FROM #normalizedResultSet   t    INNER JOIN 
						(SELECT A.* FROM AirResponse A  WITH (NOLOCK)
						Except 
						SELECT A.* FROM AirResponse A WITH (NOLOCK) INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) r 
						ON t.airresponsekey = r.airResponseKey 
						WHERE t.airsubrequetkey  <> @airSubRequestKey  AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFStops 
						union 
						SELECT (case when @isTotalPriceSort = 0 then MIN (airPriceBAse)  else MIN (airPriceBase + airpriceTax  ) end ), t.noOFStops,'all',COUNT(distinct t.airResponseKey ) noOFFLights     FROM #normalizedResultSet   t  
						INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode

						GROUP BY  t.noOFStops 

						union 
						SELECT (case when @isTotalPriceSort = 0 then MIN (m.airPriceBase )  else MIN (m.airpriceTax ) end )    AS LowestPrice,m.noOFStops AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  FROM #normalizedResultSet   m INNER JOIN AirResponse r ON m.airresponsekey =r.airResponseKey  WHERE m.airlineCode ='Multiple Airlines'   GROUP BY m.airlineCode ,noOFStops 
					) summary1 
					LEFT OUTER  JOIN AirVendorLookup airvend WITH (NOLOCK) ON summary1 .airSegmentMarketingAirlineCode = airvend .AirlineCode 
					GROUP BY airvend .ShortName,airSegmentMarketingAirlineCode ,NoOFSegments 
				END
				ELSE
				BEGIN					
					SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights ,CONVERT(BIT,1) AS isSameAirlinesItin   FROM 
					(
						SELECT min (r.airPriceBase   +ISNULL( legPrice,0) + ISNULL (thirdlegPrice ,0) 	+ ISNULL (fourthlegPrice ,0) + ISNULL (fifthlegPrice ,0) 
						) AS LowestPrice
						,t.noOFStops AS NoOFSegments,t.airlineCode  AS airSegmentMarketingAirlineCode,COUNT(distinct r.airResponseKey ) noOFFLights   FROM #normalizedResultSet   t INNER JOIN AirResponse r ON t.airresponsekey =r.airResponseKey 
						INNER JOIN @tmpAirline air ON t.airlineCode = air.airLineCode 
						LEFT OUTER JOIN @tmpSecondLowestPrice s ON s.airline = t.airlineCode  
						LEFT OUTER JOIN @tmpThirdLowestPrice third ON t.airlineCode = third.airline 
						LEFT OUTER JOIN @tmpFourthLowestPrice fourth ON t.airlineCode = fourth .airline 
						LEFT OUTER JOIN @tmpFifthLowestPrice fifth ON t.airlineCode = fifth .airline 
						WHERE t.airsubrequetkey  = @airSubRequestKey AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFStops 
						union 
						SELECT MIN(airPriceBase ), t.noOFStops,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights     FROM #normalizedResultSet   t    WHERE t.airsubrequetkey  <> @airSubRequestKey  AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFStops 
						union 
						SELECT MIN(airPriceBase ), t.noOFStops,'all',COUNT(distinct t.airResponseKey ) noOFFLights     FROM #normalizedResultSet   t  
						INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode
						GROUP BY  t.noOFStops 
						union 
						SELECT min (m.airPriceBase)     AS LowestPrice,m.noOFStops AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  FROM #normalizedResultSet   m INNER JOIN AirResponse r ON m.airresponsekey =r.airResponseKey  WHERE m.airlineCode ='Multiple Airlines'   GROUP BY m.airlineCode ,noOFStops 
					) summary1 
					LEFT OUTER  JOIN AirVendorLookup airvend WITH (NOLOCK) ON summary1 .airSegmentMarketingAirlineCode = airvend .AirlineCode 
					GROUP BY airvend .ShortName,airSegmentMarketingAirlineCode ,NoOFSegments 
				END
				END 
				ELSE if   @airRequestTypeKey >= 1
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

					IF ( @isTotalPriceSort = 0 ) 
					BEGIN
						UPDATE T SET isSameAirlinesItin = 1 FROM  @MatrixResult T Inner join #airResponseResultset A
						ON t.airSegmentMarketingAirlineCode =A.airlineName AND T.LowestPrice = A.airprice  
						WHERE A.airlineName =A.otherlegAirlines AND noOfOtherlegairlines = 1 
						and airlineName <> 'Multiple Airlines' AND otherlegAirlines <> 'Multiple Airlines' 

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

					--SELECT (case when @isTotalPriceSort = 0 then MIN (airPrice)  else MIN (totalCost ) end ) AS LowestPrice ,NoOfStops AS NoOFSegments ,airlineName AS airSegmentMarketingAirlineCode,COUNT(distinct air.airResponseKey ) noOFFLights ,ISNULL (ShortName,airlineName)AS MarketingAirlineName FROM #airResponseResultset air
					--LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode 
					--GROUP BY airlineName ,ShortName ,NoOfStops 
					--union 
					--SELECT (case when @isTotalPriceSort = 0 then MIN (airPriceBase )  else MIN (airPriceBase + airpriceTax  ) end ), t.noOFStops,'all',COUNT(distinct t.airResponseKey ) noOFFLights ,'all'    FROM #normalizedResultSet t   
					--INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode
					--GROUP BY  t.noOFStops 
					--order by 
					--MarketingAirlineName
				END 
	END 
	ELSE 
		BEGIN 
		IF @markettingAirline <> 'Multiple Airlines' AND @markettingAirline <> '' 
		BEGIN 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ) AS LowestPrice ,Noofstops AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,air.MarketingAirlineName  ,1as start , 6  AS endTime ,COUNT(distinct air.airResponseKey ) noOFFLights   FROM #airResponseResultset  air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)
			GROUP BY air.NoOfStops ,air.airlineName  ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '08:00:00.0000000' AND '09:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT(case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 

			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,air.MarketingAirlineName ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset   air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE    airSegmentMarketingAirlineCode = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			order by endTime ,start  
		END 
		ELSE 

		BEGIN 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ) AS LowestPrice ,Noofstops AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,'Multiple Airlines' AS MarketingAirlineName  ,1as start , 6  AS endTime ,COUNT(distinct air.airResponseKey ) noOFFLights   FROM #airResponseResultset  air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)
			GROUP BY air.NoOfStops ,air.airlineName   
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)
			GROUP BY air.NoOfStops ,air.airlineName  
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '08:00:00.0000000' AND '09:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)
			GROUP BY air.NoOfStops ,air.airlineName  
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName  
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName  
			union     
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName  
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName  
			union 
			SELECT(case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName  
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM #airResponseResultset      air INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName 
			union 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset      air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  between '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
			GROUP BY air.NoOfStops ,air.airlineName  
			union 
			select 0 , 0 ,  'Multiple Airlines' ,'Multiple Airlines' ,01 ,23 ,0 --for non stop 
			union 
			--SELECT MIN (air.airPrice ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset   air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE    airSegmentMarketingAirlineCode = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfSTOPs ,'Multiple Airlines' ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset   air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE     gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs  
			order by endTime ,start 
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
    inner join NormalizedAirResponses N WITH (NOLOCK)
on A.airResponseKey = N.airresponsekey and N.airLegNumber =  @airRequestTypeKey  and a.airLegNumber =@airRequestTypeKey  

  
  
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
 
 SELECT DISTINCT A.legConnections,COUNT(DISTINCT Airresponsekey), MIN(CAST( A.airResponseKey AS varchar(200))) ,A.actualNoOFStops ,  MIN( totalCost),MAX(totalCost) ,   MIN(legDuration)  ,MAX(legDuration)  ,
 ( CASE  WHEN @airRequestType = 1 then 'OneWay' 
    WHEN @airRequestType = 2 then 'RoundTrip' 
    WHEN @airRequestType =3 then 'MultiCity' END) ,  replace( NA.airlines ,',,',',')
 FROM #airResponseResultset A inner join  
  @cityPairAirlines NA on A.legConnections= NA.airLegConnections 
  GROUP BY A.legConnections,A.actualNoOFStops,NA.airlines 

 
   
  
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
             depart.CityName DepartCityName ,CAST (depart.Latitude as VARCHAR(200)) "DepartAirport/@Lattitude" ,CAST (depart.Longitude as VARCHAR(200))"DepartAirport/@Longitude"  ,DEPART.AirportCode as DepartAirport  ,
             
             arrival.CityName ArrivalCityName ,
             CAST (arrival.Latitude as VARCHAR(200)) "ArrivalAirport/@Lattitude" ,CAST (Arrival.Longitude as VARCHAR(200))"ArrivalAirport/@Longitude"  ,Arrival.AirportCode as ArrivalAirport  
             
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
SELECT @isExcludeCountryPresent AS IsExcludeCountryAvailable
DROP TABLE #tmpDeparturesLowest 
DROP TABLE #tmpArrivalLowest  
DROP TABLE #airResponseResultset
DROP TABLE #AllOneWayResponses
DROP TABLE #normalizedResultSet
DROP TABLE #pagingResultSet
DROP TABLE #AirSegments
DROP TABLE #tempOneWayResponses



GO
