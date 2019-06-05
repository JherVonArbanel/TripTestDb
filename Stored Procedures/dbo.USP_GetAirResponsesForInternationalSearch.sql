SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[USP_GetAirResponsesForInternationalSearch]
(
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
	 @excludeAirline varchar ( 500) = ''
)
AS
	SET NOCOUNT ON 
	DECLARE @FirstRec int
	DECLARE @LastRec int

	-- Initialize variables.
	SET @FirstRec = (@pageNo  - 1) * @PageSize
	SET @LastRec = (@pageNo  * @PageSize + 1)

	---- print (cast(getdate() AS time))

	DECLARE @airRequestKey AS int 
	SET @airRequestKey =( SELECT TOP 1 airRequestKey  FROM AirSubRequest WITH (NOLOCK)WHERE airSubRequestKey = @airSubRequestKey )
	declare @airRequestTripType   AS int  
	SET @airRequestTripType =( select airRequestTypeKey  from AirRequest  WITH (NOLOCK) where airRequestKey =@airRequestKey )
--DECLARE @airBundledRequest AS int 
--SET @airBundledRequest = (SELECT TOP 1 AirSubRequestKey FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = -1 ) 
	Declare @airSubRequestCount  as int 
	if ( select airRequestTypeKey  from AirRequest  WITH (NOLOCK) where airRequestKey =@airRequestKey )  =1
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

	--CREATE TABLE #AirSegments 
	--(
	--	airSegmentKey uniqueidentifier ,
	--	airResponseKey uniqueidentifier   ,
	--	airLegNumber int NOT NULL,
	--	airSegmentMarketingAirlineCode varchar(2)  ,
	--	airSegmentOperatingAirlineCode varchar(2)  ,
	--	airSegmentFlightNumber int  ,
	--	airSegmentDuration time(7)  ,
	--	airSegmentEquipment nvarchar(50)  ,
	--	airSegmentMiles int  ,
	--	airSegmentDepartureDate datetime  ,
	--	airSegmentArrivalDate datetime  ,
	--	airSegmentDepartureAirport varchar(50)  ,
	--	airSegmentArrivalAirport varchar(50)  ,
	--	airSegmentResBookDesigCode varchar(50)  ,
	--	airSegmentDepartureOffset float  ,
	--	airSegmentArrivalOffset float   ,
	--	airSegmentSeatRemaining  int ,
	--	airSegmentMarriageGrp char(10),
	--	airFareBasisCode varchar(50) ,
	--	airFareReferenceKey varchar(400),airSegmentOperatingFlightNumber int  ,
	--	airsegmentCabin varchar (20)  ,segmentOrder int 
		
	--)



	--INSERT INTO @AirSegments ( airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey ,airSegmentOperatingFlightNumber,airsegmentCabin ,segmentOrder  )
	--(
	--	SELECT airSegmentKey,SEG.airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,(case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey ,airSegmentOperatingFlightNumber,airsegmentCabin  ,segmentOrder FROM AirSegments seg WITH (NOLOCK) INNER JOIN AirResponse  resp WITH (NOLOCK) ON seg .airResponseKey = resp.airresponsekey LEFT OUTER JOIN AircraftsLookup WITH (NOLOCK) on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)
	--	INNER JOIN AirSubRequest subrequest  WITH (NOLOCK) ON resp.airSubRequestKey = subrequest .airSubRequestKey 
	--	WHERE  seg.airLegNumber = @airRequestTypeKey AND   airRequestKey = @airRequestKey  AND ISNULL(resp.gdsSourceKey,2) =( CASE WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) 
	--)
	
	 

	/***code for date time offset ****/
	DECLARE @startAirPort AS varchar(100) 
	DECLARE @endAirPort AS varchar(100) 
	SELECT  @startAirPort=  airRequestDepartureAirport ,@endAirPort=airRequestArrivalAirport FROM AirSubRequest WITH (NOLOCK) WHERE  airSubRequestKey = @airSubRequestKey 

	DECLARE @superAirlines AS TABLE ( airLineCode varchar(20)) 
	 DECLARE @excludedAirlines AS table ( airLineCode varchar(20)) 
	DECLARE @tempResponseToRemove AS TABLE ( airresponsekey uniqueidentifier ) 
	IF ( @superSetAirlines <> '' )
	BEGIN
		INSERT @superAirlines (airLineCode ) SELECT * FROM vault .dbo.ufn_CSVToTable (@superSetAirlines)
		INSERT @tempResponseToRemove (airresponsekey ) 
		(SELECT distinct S.airresponsekey FROM AirSegments S WITH (NOLOCK)  inner join AirResponse resp WITH (NOLOCK) on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and airSegmentMarketingAirlineCode not in (SELECT * FROM @superAirlines) ) 
		union 
		 (SELECT Distinct s.airResponseKey from AirSegments s WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq  WITH (NOLOCK)on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and airSegmentMarketingAirlineCode not in (SELECT * FROM @superAirlines) )
				   
				   if ( @allowedOperatingAirlines <> '' )
				   BEGIN 
				   INSERT @tempResponseToRemove (airresponsekey ) 
				 (SELECT Distinct s.airResponseKey from AirSegments s WITH (NOLOCK)inner join AirResponse resp WITH (NOLOCK) on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq WITH (NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and airSegmentOperatingAirlineCode not in (SELECT * FROM vault.dbo.ufn_CSVToTable (@allowedOperatingAirlines )) )
				 END
		
	END   
	/***REMOVE SOUTHWEST FROM INTERNATIONAL SEARCH****/
	INSERT @tempResponseToRemove (airresponsekey ) ( SELECT distinct S.airResponseKey FROM AirSegments S WITH (NOLOCK) INNER JOIN  AirResponse resp WITH (NOLOCK) on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq WITH (NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and  airSegmentMarketingAirlineCode ='WN' or airSegmentOperatingAirlineCode='WN')
	/****SOUTHWEST LOGIC ENDS HERE ****/
	IF ( @excludeAirline  <> '' AND @excludeAirline is not null )
  BEGIN 
  INSERT @excludedAirlines (airLineCode )   
    SELECT * FROM vault .dbo.ufn_CSVToTable (@excludeAirline )  
     INSERT @tempResponseToRemove (airresponsekey )   
    (SELECT distinct S.airresponsekey FROM AirSegments S WITH(NOLOCK) inner join AirResponse resp on s.airResponseKey =resp.airResponseKey   
     inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey AND airSegmentMarketingAirlineCode   in (SELECT * FROM @excludedAirlines) )  

     INSERT @tempResponseToRemove (airresponsekey )   
      (SELECT Distinct s.airResponseKey from AirSegments s WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) on s.airResponseKey =resp.airResponseKey   
     inner join AirSubRequest subReq WITH (NOLOCK) on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and   
     airSegmentOperatingAirlineCode   in (SELECT * FROM @excludedAirlines   )  )
  
    
  END
---SELECT * FROM @tempResponseToRemove 


---- print('  SELECT distinct  airSegmentDepartureOffset FROM AirSegments seg INNER JOIN AirResponse r ON seg.airResponseKey =r.airResponseKey
--            WHERE(  r.airSubRequestKey = ' + convert(nvarchar, @airSubRequestKey)  + '    ) AND airLegNumber = ' + convert(nvarchar, @airRequestTypeKey) + ' AND airSegmentDepartureAirport=  ' + convert(nvarchar, @startAirPort) + ' AND airSegmentDepartureOffset is not null  ')

	DECLARE @departureOffset AS float 
	SET @departureOffset =(  SELECT distinct  TOP 1  airSegmentDepartureOffset FROM AirSegments seg WITH (NOLOCK) INNER JOIN AirResponse r WITH (NOLOCK) ON seg.airResponseKey =r.airResponseKey
	WHERE(  r.airSubRequestKey = @airSubRequestKey     ) AND airLegNumber =@airRequestTypeKey AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null  )


	DECLARE @arrivalOffset AS float 
	SET @arrivalOffset = (SELECT distinct TOP 1 airSegmentArrivalOffset  FROM AirSegments seg WITH (NOLOCK) INNER JOIN AirResponse r WITH (NOLOCK) ON seg.airResponseKey =r.airResponseKey
	WHERE(  r.airSubRequestKey = @airSubRequestKey    ) AND airLegNumber = @airRequestTypeKey AND airSegmentArrivalAirport=@endAirPort AND airSegmentArrivalOffset is not null )


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
     DECLARE @airPriceInfantWithSeatForAnotherLeg AS FLOAT   
	 DECLARE @airPriceTaxInfantWithSeatForAnotherLeg AS FLOAT

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
		airPriceBaseInfantWithSeat float,
		airPriceTaxInfantWithSeat float,
	)


---- print('uniquifying started ..')
---- print (cast(getdate() AS time))
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
		airsubRequestkey int 
		,airLegConnections varchar(200),
		airLegBookingClasses varchar(50),
		otherLegPrice float ,
		otherLegTax float  ,
		cabinClass varchar(20),
		airOnePriceBaseInfantWithSeat float,
		airOnePriceTaxInfantWithSeat float
	 )    

	--DECLARE @tempOneWayResponses AS TABLE 
	--(
	--	airOneIdent int,
	--	airOneResponsekey uniqueidentifier , 
	--	airOnePriceBase float ,
	--	airOnePriceTax float,
	--	airOnePriceBaseSenior float,
	--	airOnePriceTaxSenior float,
	--	airOnePriceBaseChildren float,
	--	airOnePriceTaxChildren float,
	--	airOnePriceBaseInfant float,
	--	airOnePriceTaxInfant float,
	--	airOnePriceBaseYouth float,
	--	airOnePriceTaxYouth float,
	--	airOnePriceBaseTotal float,
	--	airOnePriceTaxTotal float,
	--	airOnePriceBaseDisplay float,
 --       airOnePriceTaxDisplay float,
	--	airSegmentFlightNumber varchar(100),
	--	airSegmentMarketingAirlineCode varchar(100),
	--	airsubRequestkey int 
	--	,airLegConnections varchar(200),
	--	airLegBookingClasses varchar(50),
	--	otherLegPrice float ,
	--	otherLegTax float  ,
	--	cabinClass varchar(20) 
	--)
	--DELETE FROM @tempOneWayResponses
	if ( @airRequestTypeKey = 1) 
	BEGIN 

		IF ( @gdssourcekey =0  or @gdssourcekey <> 9 ) 
			Begin 
			SET @airPriceForAnotherLeg = (SELECT TOP 1 ( airPriceBase/@airSubRequestCount)  FROM AirResponse resp  WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBase ) 
			SET @airPriceTaxForAnotherLeg = (SELECT TOP 1 ( airPriceTax/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9  order by airPriceTax ) 
			SET @airPriceSeniorForAnotherLeg = (SELECT TOP 1 ( airPriceBaseSenior/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseSenior ) 
			SET @airPriceTaxSeniorForAnotherLeg = (SELECT TOP 1 ( airPriceTaxSenior/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK) ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxSenior ) 
			SET @airPriceChildrenForAnotherLeg = (SELECT TOP 1 ( airPriceBaseChildren/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseChildren ) 
			SET @airPriceTaxChildrenForAnotherLeg = (SELECT TOP 1 ( airPriceTaxChildren/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxChildren ) 
			SET @airPriceInfantForAnotherLeg = (SELECT TOP 1 ( airPriceBaseInfant/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseInfant ) 
			SET @airPriceTaxInfantForAnotherLeg = (SELECT TOP 1 ( airPriceTaxInfant/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxInfant ) 
			SET @airPriceYouthForAnotherLeg = (SELECT TOP 1 ( airPriceBaseYouth/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseYouth ) 
			SET @airPriceTaxYouthForAnotherLeg = (SELECT TOP 1 ( airPriceTaxYouth/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxYouth ) 
			SET @airPriceTotalForAnotherLeg = (SELECT TOP 1 ( AirPriceBaseTotal/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by AirPriceBaseTotal ) 
			SET @airPriceTaxTotalForAnotherLeg = (SELECT TOP 1 ( AirPriceTaxTotal/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by AirPriceTaxTotal ) 
			SET @airPriceDisplayForAnotherLeg = (SELECT TOP 1 ( airPriceBaseDisplay/@airSubRequestCount)  FROM AirResponse resp  WITH (NOLOCK)INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseDisplay ) 
			SET @airPriceTaxDisplayForAnotherLeg = (SELECT TOP 1 ( airPriceTaxDisplay/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxDisplay ) 
			
			SET @airPriceInfantWithSeatForAnotherLeg = (SELECT TOP 1 ( airPriceBaseInfantWithSeat/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseInfantWithSeat ) 
			SET @airPriceTaxInfantWithSeatForAnotherLeg = (SELECT TOP 1 ( airPriceTaxInfantWithSeat/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK)  INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxInfantWithSeat ) 
			
			
			INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airLegConnections,airLegBookingClasses,otherLegPrice ,otherLegTax ,cabinClass,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)
			SELECT resp.airresponsekey, (airPriceBase) , flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ),airLegConnections,airLegBookingClasses,
			CASE WHEN @isTotalPriceSort = 0 THEN ISNULL( airPriceBase/@airSubRequestCount ,0) ELSE ISNULL( airPriceBase /@airSubRequestCount,0)  + ISNULL( airPriceTax/@airSubRequestCount ,0) end    , airPriceTax /@airSubRequestCount  ,n.cabinClass,
			airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,
			resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
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
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airLegConnections,airLegBookingClasses,otherLegPrice ,otherLegTax  ,cabinClass,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)
				SELECT resp.airresponsekey, (airPriceBase   ), flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ),airLegConnections,airLegBookingClasses,
				CASE WHEN @isTotalPriceSort = 0 THEN  airPriceBase /@airSubRequestCount ELSE (airPriceBase /@airSubRequestCount) +(airPriceTax /@airSubRequestCount) end  ,airPriceTax /@airSubRequestCount  ,n.cabinclass,
				airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,resp.airPriceBaseInfantWithSeat,resp.airPriceTaxInfantWithSeat
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
					airPriceTaxDisplay float,
					airPriceBaseInfantWithSeat float,
					airPriceTaxInfantWithSeat float
				)
				
				INSERT @fareLogixBrandedFare ( airline,airPriceBase ,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat )  
				SELECT airlines ,sum (AirAmount ),SUM( airTax ),sum(PriceSenior),sum(TaxSenior),SUM(PriceChildren),SUM(TaxChildren),SUM(PriceInfant),SUM(TaxInfant),SUM(PriceYouth),SUM(TaxYouth),SUM(PriceTotal),SUM(TaxTotal),SUM(PriceDisplay), SUM(TaxDisplay),SUM(PriceInfantWithSeat), SUM(TaxInfantWithSeat)   FROM 
				(
					SELECT  SUBSTRING (  n.airlines,1,2 )airlines,min (airPriceBase   )AirAmount, MIN ( airpriceTAX) airTax,airLegNumber,
					MIN(airPriceBaseSenior) AS PriceSenior,MIN(airPriceTaxSenior)AS TaxSenior,
					MIN(airPriceBaseChildren) AS PriceChildren,MIN(airPriceTaxChildren) AS TaxChildren,
					MIN(airPriceBaseInfant) AS PriceInfant,MIN(airPriceTaxInfant) AS TaxInfant,
					MIN(airPriceBaseYouth) AS PriceYouth, MIN(airPriceTaxYouth) AS TaxYouth,
					MIN(AirPriceBaseTotal) AS PriceTotal,MIN(AirPriceTaxTotal)AS TaxTotal,
					MIN(airPriceBaseDisplay) AS PriceDisplay, MIN(airPriceTaxDisplay) AS TaxDisplay,
				    MIN(airPriceBaseInfantWithSeat) AS PriceInfantWithSeat,MIN(airPriceTaxInfantWithSeat) AS TaxInfantWithSeat
					FROM NormalizedAirResponses n WITH (NOLOCK) INNER JOIN AirResponse resp WITH (NOLOCK) ON n.airresponsekey = resp.airResponseKey 
					INNER JOIN AirSubRequest subRequest WITH (NOLOCK) ON resp .airSubRequestKey = subRequest .airSubRequestKey 
					WHERE  airRequestKey = @airRequestKey AND airLegNumber <> @airRequestTypeKey
					AND  resp.gdsSourceKey = 9 AND isbrandedFare =1  GROUP BY SUBSTRING (  n.airlines,1,2 ) ,airLegNumber
				)
				farelogix
				GROUP BY airlines 
				
				INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airLegConnections,airLegBookingClasses,otherLegPrice ,otherLegTax ,cabinClass,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airOnePriceBaseInfantWithSeat,airOnePriceTaxInfantWithSeat)
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
					(resp.airPriceTaxDisplay + ISNULL(f.airPriceTaxDisplay,0) ),
					(resp.airPriceBaseInfantWithSeat + ISNULL(f.airPriceBaseInfantWithSeat,0)   ), 
					(resp.airPriceTaxInfantWithSeat + ISNULL(f.airPriceTaxInfantWithSeat,0) )
					FROM NormalizedAirResponses n WITH (NOLOCK) INNER JOIN AirResponse resp WITH (NOLOCK) ON n.airresponsekey = resp.airResponseKey 
					INNER JOIN AirSubRequest subRequest WITH (NOLOCK)ON resp .airSubRequestKey = subRequest .airSubRequestKey 
					LEFT OUTER JOIN  @fareLogixBrandedFare f ON SUBSTRING (n.airlines ,1,2 ) = airline 
					WHERE  airRequestKey = @airRequestKey AND airLegNumber = @airRequestTypeKey
					AND  resp.gdsSourceKey = 9 AND isbrandedFare = 1 

		END 


	/***Delete responses which are not available in respective one way responses AS fare buckets are applicable for one way logic  **/ 

	--  DELETE FROM @tempOneWayResponses WHERE airOneResponsekey in (
	--  SELECT airresponsekey FROM NormalizedAirResponses WHERE airsubrequestkey = @airBundledRequest AND airLegNumber =@airRequestTypeKey AND flightNumber not in (
	--SELECT flightNumber FROM NormalizedAirResponses WHERE airsubrequestkey = @airSubRequestKey)) 

	END 
	ELSE
	BEGIN  
			DECLARE @isPure AS int 
			SET  @isPure =(SELECT count(distinct airSegmentMarketingAirlineCode) FROM airsegments WITH (NOLOCK)WHERE airresponsekey =@selectedResponseKey)
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
				SET @airPriceInfantWithSeatForAnotherLeg = (SELECT TOP 1 ( airPriceBaseInfantWithSeat/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceBaseInfantWithSeat ) 
				SET @airPriceTaxInfantWithSeatForAnotherLeg = (SELECT TOP 1 ( airPriceTaxInfantWithSeat/@airSubRequestCount)  FROM AirResponse resp WITH (NOLOCK) INNER JOIN AirSubRequest subreq WITH (NOLOCK)ON resp.airSubRequestKey= subreq .airSubRequestKey  WHERE airRequestKey = @airRequestKey AND gdsSourceKey <> 9 order by airPriceTaxInfantWithSeat )
		 	END 
			IF ( SELECT  isBrandedFare FROM AirResponse WITH (NOLOCK) WHERE airresponsekey = @selectedResponseKey ) = 0 
			BEGIN 
		    declare @airrequestType as int 
			set @airrequestType = ( select  airRequestTypeKey  from AirRequest WITH (NOLOCK) where airRequestKey = @airRequestKey ) 
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
			   

 			   INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax   ,cabinClass ,otherLegPrice,otherLegTax,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal ,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airOnePriceBaseInfant,airOnePriceTaxInfant)
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
 								   (CASE WHEN @selectedFareType = '' THEN  airPriceTaxDisplay ELSE ((airPriceTaxDisplay/@airSubRequestCount)+ @airPriceTaxForAnotherLeg )  END),
 								   (CASE WHEN @selectedFareType = '' THEN  airPriceBaseInfantWithSeat ELSE ((airPriceBaseInfantWithSeat/@airSubRequestCount)+ @airPriceInfantWithSeatForAnotherLeg )  END) ,
 								   (CASE WHEN @selectedFareType = '' THEN  airPriceTaxInfantWithSeat ELSE ((airPriceTaxInfantWithSeat/@airSubRequestCount)+ @airPriceTaxInfantWithSeatForAnotherLeg )  END ) 
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
				   INSERT #AllOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airOnePriceBaseInfant,airOnePriceTaxInfant )
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
				   airPriceTaxDisplay + @airPriceTaxDisplayForAnotherLeg,
				   r.airPriceBaseInfantWithSeat + @airPriceInfantWithSeatForAnotherLeg ,
				   airPriceTaxInfantWithSeat + @airPriceTaxInfantWithSeatForAnotherLeg 
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
		--  INSERT @tempOneWayResponses (airOneResponsekey,airOnePriceBase,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax  )
		--   SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ), flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0))
		--   FROM NormalizedAirResponses n INNER JOIN AirResponse resp ON n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey 
		-- AND ISNULL(resp.gdsSourceKey,2) = (CASE WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )

		--END 
		-- print(@airPriceTaxForAnotherLeg) 
 /***Delete all other airlines other than filter airlines**/
 --	INSERT into @tempOneWayResponses 
	--SELECT ROW_NUMBER() over (order by airOnePriceBaseDisplay ) AS airOneIdent , * FROM @AllOneWayResponses  
	
 -- IF @gdssourcekey = 9 
-- BEGIN
-- if ( @airLines <> 'Multiple Airlines')
-- BEGIN
--	delete from @tempOneWayResponses where airOneResponsekey in (
--	select distinct seg.airResponseKey   FROM AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey 
--		INNER JOIN AirSubRequest subrequest ON resp.airSubRequestKey = subrequest .airSubRequestKey and seg.airSegmentMarketingAirlineCode not in (select * From @tmpAirline ) 
--	 	WHERE   airrequestKey = @airRequestKey    AND gdsSourceKey = @gdssourcekey)
	 	
	 

--END
--END 
	Delete P
		 FROM #AllOneWayResponses P
		 INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey
		 
	DELETE #AllOneWayResponses
	FROM #AllOneWayResponses t,
	(
		SELECT min(airOnePriceBaseDisplay) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,isnull(cabinClass ,'') cabinClass
		FROM #AllOneWayResponses m
		GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode   ,isnull(cabinClass ,'')
		having count(1) > 1
	) AS derived
	WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode  AND isnull(t.cabinclass,'') =isnull(derived .cabinclass,'') 
	AND airOnePriceBaseDisplay >= minPrice  AND airOneIdent > minIdent
	---- print (cast(getdate() AS time))
	---- print('uniquifying ended ..')



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
		otherlegPrice float ,otherlegtax float 
	) 

		INSERT  #normalizedResultSet (airresponsekey ,airPriceBase,noOFStops ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey ,airpricetax ,airsubrequetkey ,cabinclass ,otherlegPrice,otherlegtax   )
		(
			SELECT seg.airresponsekey,result.airOnePriceBaseDisplay ,CASE WHEN COUNT(seg.airresponsekey )-1 > 1 THEN 1 ELSE  COUNT(seg.airresponsekey )-1 END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ),
			CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,
			resp.gdsSourceKey, result .airOnePriceTaxDisplay ,result.airsubRequestkey ,result .cabinClass  ,otherLegPrice,otherLegTax  
			FROM 
			#AllOneWayResponses  result  INNER JOIN 
			AirResponse resp WITH (NOLOCK)  ON resp.airResponseKey = result.airOneResponsekey 
			INNER JOIN
			AirSegments seg  WITH (NOLOCK)  ON result .airOneResponsekey = seg.airResponseKey 
			WHERE airLegNumber = @airRequestTypeKey
			GROUP BY seg.airResponseKey,result.airOnePriceBaseDisplay ,gdssourcekey  ,result .airOnePriceTaxDisplay , result.airsubRequestkey ,result.cabinClass ,result.otherlegprice,otherLegTax 
		 )
 
 		INSERT into #airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfStops ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey , airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected,otherLegPrice,isRefundable,isBrandedFare  ,cabinClass ,fareType,segmentOrder ,airsegmentCabin ,totalCost,airSegmentOperatingFlightNumber ,otherlegtax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat)
			SELECT     seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , (case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate , seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport  ,normalized .airPriceBase      AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,noOFStops  ,  takeoffdate  , landingdate ,airSegmentOperatingAirlineCode , seg.airSegmentResBookDesigCode,noOfAirlines ,normalized .airlineCode , ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver ,priceClassCommentsEconSaver,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice ,airEconFlexPrice,airEconUpgradePrice,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSelected , 
			
		   otherlegPrice    ,refundable   ,isBrandedFare ,normalized .cabinclass ,fareType,segmentOrder ,seg.airsegmentCabin,(isnull(normalized.airPriceBase,0) + ISNULL (normalized.airpriceTax,0) ),seg.airSegmentOperatingFlightNumber,otherlegtax, airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay, resp.airPriceBaseInfantWithSeat, resp.airPriceTaxInfantWithSeat
			FROM AirSegments seg   WITH (NOLOCK)
			INNER JOIN #normalizedResultSet normalized ON seg.airresponsekey = normalized .airresponsekey 
			INNER JOIN AirResponse resp WITH (NOLOCK) ON seg .airresponsekey = resp.airResponseKey 
			 LEFT OUTER JOIN AircraftsLookup WITH (NOLOCK) on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)
			INNER JOIN @noStops nStop ON normalized .noOFStops = nStop .stops 
			INNER JOIN  AirVendorLookup airVendor WITH (NOLOCK)  ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode  
			 WHERE  normalized.airPriceBase  <=    @price  			AND 
			 ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )
			AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )
			
			 
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
		INSERT into #pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )
		SELECT    air.airResponseKey ,MIN(airPrice ) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM #airResponseResultset air 
		INNER JOIN #normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey 
		INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   ) 
		GROUP BY air.airResponseKey,airlineName   order by ( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END),MIN(MarketingAirlineName) , min(normalized.noOFStops ),MIN( actualTakeOffDateForLeg) ,MIN( actualLandingDateForLeg )
	-- print('page default')
	END 
---- print ( cast(getdate() AS time )  )

	if ( @superSetAirlines is not null AND @superSetAirlines <> '' )
	BEGIN 
		Delete P
		FROM #pagingResultSet P
		INNER JOIN @tempResponseToRemove T  ON P.airResponseKey = T.airresponsekey
		
	END 
	

	
  /**MAIN RESULTSET FOR LIST STARTS HERE**/
	SELECT distinct rowNum,air.*, airSegmentArrivalOffset,departureAirport .CityName AS DepartureAirPortCityName ,departureAirport.StateCode AS DepartureAirportStateCode ,departureAirport .AirportName AS DepartureAirportName , departureAirport.CountryCode AS DepartureAirportCountryCode, 
	arrivalAirport .CItyName AS ArrivalAirPortCityName ,arrivalAirport .StateCode AS ArrivalAirportStateCode , arrivalAirport .AirportName AS ArrivalAirportName ,arrivalAirport .CountryCode  AS ArrivalAirportCountryCode,
	operatingAirline .ShortName AS OperatingAirlineName,isRefundable ,isbrandedFare ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,isSmartFare,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat
	FROM #airResponseResultset air INNER JOIN #pagingResultSet  paging ON air.airResponseKey = paging.airResponseKey
	LEFT OUTER JOIN AirVendorLookup operatingAirline WITH (NOLOCK)   ON air .airSegmentOperatingAirlineCode = operatingAirline .AirlineCode 
	LEFT OUTER JOIN AirportLookup departureAirport WITH (NOLOCK)  ON air .airSegmentDepartureAirport = departureAirport .AirportCode 
	LEFT OUTER JOIN AirportLookup arrivalAirport  WITH (NOLOCK)  ON air .airSegmentArrivalAirport =arrivalAirport .AirportCode 
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
  /****MIN-MAX PRICE FOR FILTERS ***/
	SELECT (case when @isTotalPriceSort = 0 then MIN (airPrice)  else MIN (totalCost ) end ) AS LowestPrice ,(case when @isTotalPriceSort = 0 then MAX (airPrice)  else MAX (totalCost ) end ) AS HighestPrice FROM #airResponseResultset  result1 
	/****MIN-MAX PRICE FOR FILTERS END***/
	
	/****TAKEOFF-LANDING TIME START****/
	SELECT distinct  MIN (actualTakeOffDateForLeg ) AS MinDepartureTakeOffDate,  MAX (actualTakeOffDateForLeg) AS MaxDepartureTakeOffDate, MIN (actualLandingDateForLeg) AS MinDepartureLandingDate,  MAX (actualLandingDateForLeg) AS MaxDepartureLandingDate 
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
			 
				IF (SELECT count(distinct (airSegmentMarketingAirlineCode ))  FROM AirSegments seg  WHERE airResponseKey =@selectedResponseKey AND airLegNumber = @airRequestTypeKey-1 ) = 1 
				BEGIN
				IF   (SELECT COUNT(*) FROM @tmpAirline) > 1 
					BEGIN
						SET @markettingAirline  =(SELECT distinct  TOP 1(airSegmentMarketingAirlineCode )   FROM AirSegments seg WHERE airResponseKey =@selectedResponseKey AND airLegNumber = @airRequestTypeKey-1)  
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
		 
		--SET @noOFDrillDownCount = ( SELECT top 1 COUNT(*)   FROM @airResponseResultset      air  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )
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
				(SELECT A.* FROM AirSegments A  WITH (NOLOCK)
				Except 
				SELECT A.* FROM AirSegments A WITH (NOLOCK)INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) Tmp
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
				INNER JOIN AirSegments aseg WITH (NOLOCK) ON ar.airResponseKey = aseg.airResponseKey 
				WHERE airSubRequestKey = @thirdSubRequestKey GROUP BY  airSegmentMarketingAirlineCode 

				DECLARE @fourthSubRequestKey AS int 
				SET @fourthSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =4 )

				DECLARE @tmpFourthLowestPrice AS TABLE 
				(
				fourthlegPrice float ,
				airline varchar(100) 
				)
				
				INSERT @tmpFourthLowestPrice (fourthlegPrice ,airline   )
				SELECT min(airPriceBAse    ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar WITH (NOLOCK)
				INNER JOIN AirSegments aseg WITH (NOLOCK) ON ar.airResponseKey = aseg.airResponseKey 
				WHERE airSubRequestKey = @fourthSubRequestKey GROUP BY  airSegmentMarketingAirlineCode 

				DECLARE @fifthSubRequestKey AS int 
				SET @fifthSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =4 )

				DECLARE @tmpFifthLowestPrice AS TABLE 
				(
				fifthlegPrice float ,
				airline varchar(100) 
				)
				INSERT @tmpFifthLowestPrice (fifthlegPrice ,airline   )
				SELECT min(airPriceBAse    ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar WITH (NOLOCK)
				INNER JOIN AirSegments aseg WITH (NOLOCK)ON ar.airResponseKey = aseg.airResponseKey 
				WHERE airSubRequestKey = @fifthSubRequestKey GROUP BY  airSegmentMarketingAirlineCode 


				if(@superSetAirlines != '')
				BEGIN

					SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights   FROM 
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
						(SELECT A.* FROM AirResponse A WITH (NOLOCK)
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
					SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights   FROM 
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

					SELECT (case when @isTotalPriceSort = 0 then MIN (airPrice)  else MIN (totalCost ) end ) AS LowestPrice ,NoOfStops AS NoOFSegments ,airlineName AS airSegmentMarketingAirlineCode,COUNT(distinct air.airResponseKey ) noOFFLights ,ISNULL (ShortName,airlineName)AS MarketingAirlineName FROM #airResponseResultset air
					LEFT OUTER JOIN AirVendorLookup vendor WITH (NOLOCK) ON air.airlineName = vendor .AirlineCode 
					GROUP BY airlineName ,ShortName ,NoOfStops 
					union 
					SELECT (case when @isTotalPriceSort = 0 then MIN (airPriceBase )  else MIN (airPriceBase + airpriceTax  ) end ), t.noOFStops,'all',COUNT(distinct t.airResponseKey ) noOFFLights ,'all'    FROM #normalizedResultSet t   
					INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode
					GROUP BY  t.noOFStops 
					order by 
					MarketingAirlineName
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
			--SELECT MIN (air.airPrice ),NoOfStops ,air.airlineName ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset   air  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE    airSegmentMarketingAirlineCode = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfStops ,air.airlineName ,air.MarketingAirlineName 
			SELECT (case when @isTotalPriceSort = 0 then MIN (air.airPrice)  else MIN (totalCost ) end ),NoOfSTOPs ,'Multiple Airlines' ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM #airResponseResultset   air  INNER JOIN #pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE     gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs  
			order by endTime ,start 
		END 
	END 
DROP TABLE #airResponseResultset
DROP TABLE #AllOneWayResponses
DROP TABLE #normalizedResultSet
DROP TABLE #pagingResultSet
--DROP TABLE #AirSegments 


GO
