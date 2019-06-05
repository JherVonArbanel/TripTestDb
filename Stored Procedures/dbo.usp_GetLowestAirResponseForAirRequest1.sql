SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
  CREATE Procedure [dbo].[usp_GetLowestAirResponseForAirRequest1] (@airRequestKey int ,@noOfStops int=1,@excludeAirline varchar(200)='')    
  AS    
  BEGIN    
   DECLARE @ResultTable AS TABLE (    
   airResponsekey UNIQUEiDENTIFIER ,    
   airPricebase FLOAT ,    
   airPriceTax FLOAT   ,    
   airSubRequestLegIndex int     
   )    
    
       
   DECLARE @tempResponseToRemove AS TABLE     
   (    
    airresponsekey UNIQUEIDENTIFIER    
   )     
       
	IF ( @excludeAirline  <> '' AND @excludeAirline is not null )    
	BEGIN     
		---get airlines which will not be part of responses    
		DECLARE @excludedAirlines AS TABLE ( airLineCode varchar(200))    
		INSERT @excludedAirlines (airLineCode )       
		SELECT * FROM vault .dbo.ufn_CSVToTable (@excludeAirline )      

		---get responses which has exclude airlines in segments marketting airline  

		INSERT @tempResponseToRemove (airresponsekey )       
		(SELECT distinct S.airresponsekey FROM AirSegments S WITH(NOLOCK) inner join AirResponse resp on s.airResponseKey =resp.airResponseKey       
		inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey     
		AND subreq.groupKey =1     
		AND airSegmentMarketingAirlineCode   in (SELECT * FROM @excludedAirlines) )      

		---get responses which has exclude airlines in segments operating airline    
		INSERT @tempResponseToRemove (airresponsekey )       
		(SELECT Distinct s.airResponseKey from AirSegments s WITH(NOLOCK) inner join AirResponse resp WITH(NOLOCK)  on s.airResponseKey =resp.airResponseKey       
		inner join AirSubRequest subReq WITH(NOLOCK)  on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey     
		AND subReq.groupKey =1    
		and       
		airSegmentOperatingAirlineCode   in (SELECT * FROM @excludedAirlines   )  )    

	END
	DECLARE @startDate AS DATE 
	DECLARE @endDate AS DATE
	DECLARE @airRequestType AS INT   
	DECLARE @vcCurrentCol  as int  
	SELECT @airRequestType = airRequestTypeKey FROM AirRequest where airrequestKey = @airrequestKey  
	 
	SELECT @startDate =airRequestDepartureDate ,@endDate = airRequestArrivalDate   FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = (Case when @airRequestType =1 THEN 1 ELSE -1 END)
	 
	
	IF ( @airRequestType >1 AND @startDate <> @endDate )
	BEGIN
		DECLARE subRequestCursor  cursor    
		FOR SELECT airSubrequestKey from AirSubRequest WHERE airRequestKey =@airRequestKey AND airSubRequestLegIndex <> -1    
		open subRequestCursor    

		fetch next from subRequestCursor into @vcCurrentCol    

		DECLARE @counter AS INT       
		WHILE @@Fetch_Status = 0    
		BEGIN    
		IF ( @noOfStops = 0 )     
		BEGIN     
			DECLARE @nonStops as Table(airResponseKey uniqueidentifier ,noofstops INT)    
			  
			INSERT @nonStops     
			SELECT seg.airResponseKey ,CASE WHEN COUNT(seg.airSegmentKey) =1 THEN 0 ELSE 1 END  FROM AirSegments Seg WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) ON seg.airResponseKey = resp.airResponseKey where resp.airSubRequestKey = @vcCurrentCol     
			GROUP BY seg.airresponseKey     
			    
			IF  ((SELECT COUNT(*) FROM @nonStops) > 0 )    
				BEGIN     
					INSERT @ResultTable    
					SELECT TOP 1 resp.airResponseKey,airPriceBaseDisplay, airPriceTaxDisplay  ,subreq.airSubRequestLegIndex   FROM AirResponse resp     
					INNER JOIN @nonStops N on resp.airResponseKey = n.airResponseKey     
					INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey  where resp.airSubRequestKey = @vcCurrentCol    
					AND n.noofstops = @noOfStops AND resp.airResponseKey not in (SELECT *FROM @tempResponseToRemove )    
					order by airPriceBaseDisplay+ airPriceTaxDisplay  asc    
				END     
			ELSE     
				BEGIN     
					DELETE FROM @ResultTable     
				END    
			END    
			ELSE     
				BEGIN     
					INSERT INTO @ResultTable     
					SELECT TOP 1 airResponseKey,airPriceBaseDisplay, airPriceTaxDisplay ,subreq.airSubRequestLegIndex   FROM AirResponse resp INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey  where resp.airSubRequestKey = @vcCurrentCol   
					AND resp.airResponseKey not in (SELECT *FROM @tempResponseToRemove )    
					order by (airPriceBaseDisplay + airPriceTaxDisplay) asc    
				END    
				   
			SET @counter = @counter + 1     
			FETCH NEXT FROM subRequestCursor INTO @vcCurrentCol    
		END    

		CLOSE subRequestCursor    
		DEALLOCATE subRequestCursor    
   END
    
 
	IF ( @noOfStops = 0 )     
	BEGIN    
	DECLARE @nonStopRoundTrip as TABLE (    
	airresponsekey UNIQUEIDENTIFIER , leg1NoOfStops INT ,leg2NoOfStops INT
	 
	)     
--(CASE WHEN COUNT(seg.airSegmentKey) =1 THEN 0 ELSE 1 END )
		IF ( @airRequestType > 1 ) 
		BEGIN 
			INSERT @nonStopRoundTrip        
			SELECT leg1.airResponseKey , leg1.leg1NoOfStops ,leg2.leg2NoOfStops FROM    
			( SELECT seg.airResponseKey ,  (COUNT(seg.airSegmentKey)-1 ) leg1NoOfStops FROM AirSegments Seg WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) ON seg.airResponseKey = resp.airResponseKey     
			INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey     
			where  airRequestKey  = @airRequestKey and airSubRequestLegIndex =    - 1 AND airlegnumber = 1    
			GROUP BY seg.airresponseKey)   leg1     
			INNER JOIN     
			( SELECT seg.airResponseKey ,(COUNT(seg.airSegmentKey) -1) leg2NoOfStops FROM AirSegments Seg WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) ON seg.airResponseKey = resp.airResponseKey     
			INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey     
			where  airRequestKey  = @airRequestKey and  airSubRequestLegIndex = - 1 AND airlegnumber =2    
			GROUP BY seg.airresponseKey )   leg2       
			on leg1.airResponseKey = leg2.airResponseKey
		END
		ELSE 
		BEGIN 
			INSERT @nonStopRoundTrip        
			SELECT leg1.airResponseKey , leg1.leg1NoOfStops ,0 FROM    
			( SELECT seg.airResponseKey ,(COUNT(seg.airSegmentKey) -1) leg1NoOfStops FROM AirSegments Seg WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) ON seg.airResponseKey = resp.airResponseKey     
			INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey     
			where  airRequestKey  = @airRequestKey and airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END)   AND airlegnumber = 1    
			GROUP BY seg.airresponseKey)   leg1     
		END 
			 
		INSERT INTO @ResultTable     
		SELECT TOP 1 resp.airResponseKey,airPriceBaseDisplay, airPriceTaxDisplay,subreq.airSubRequestLegIndex   FROM AirResponse resp INNER JOIN      
		@nonStopRoundTrip N on resp.airResponseKey = N.airresponsekey     
		INNER JOIN AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey     
		WHERE airRequestKey  = @airRequestKey and airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END) AND resp.airResponseKey not in (SELECT *FROM @tempResponseToRemove )    
		AND leg1NoOfStops =@noOfStops and isnull(leg2NoOfStops ,0)= @noOfStops     
		ORDER BY (airPriceBaseDisplay+airPriceTaxDisplay) ASC 
	 
		IF NOT Exists ( select 1 from @resultTable)
		BEGIN 
			INSERT INTO @ResultTable 			 
			SELECT TOP 1 resp.airResponseKey,airPriceBaseDisplay, airPriceTaxDisplay,subreq.airSubRequestLegIndex   FROM AirResponse resp INNER JOIN      
			@nonStopRoundTrip N on resp.airResponseKey = N.airresponsekey     
			INNER JOIN AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey     
			WHERE airRequestKey  = @airRequestKey and airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END) AND resp.airResponseKey not in (SELECT *FROM @tempResponseToRemove )    			     
			ORDER BY N.leg1NoOfStops ASC ,n.leg2NoOfStops ASC , (airPriceBaseDisplay+airPriceTaxDisplay) ASC 
		END
	   
	END      
	ELSE     
	BEGIN     
	 
		INSERT INTO @ResultTable     
		SELECT TOP 1 airResponseKey,airPriceBaseDisplay, airPriceTaxDisplay,subreq.airSubRequestLegIndex   FROM AirResponse resp INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey     
		WHERE airRequestKey  = @airRequestKey and airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END)  
		AND resp.airResponseKey not in (SELECT *FROM @tempResponseToRemove )    
		ORDER BY airPriceBaseDisplay, airPriceTaxDisplay ASC    
	 
	END       
	
	DECLARE @oneWayTotalPrice float =0    
	DECLARE @roundTripPrice float = 0    

	Set @roundTripPrice = (SELECT airPricebase + airPriceTax  from @ResultTable where airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END) )    
	Set @oneWayTotalPrice = (SELECT sum(airPricebase) + sum(airPriceTax)  from @ResultTable where airSubRequestLegIndex <> -1 )    

	DECLARE @isOneWay bit     
	if (  (@oneWayTotalPrice  is not null or @oneWayTotalPrice <> 0) and  @roundTripPrice is null) /****only round trip is present ****/    
	BEGIN    
		set @isOneWay =1     
	END     
	else if ( (@roundTripPrice is not null or @roundTripPrice <> 0)  and @oneWayTotalPrice is null )  /****only one way trip is present ****/    
	BEGIN     
		set @isOneWay =0     
	END    
	if ( isnull(@oneWayTotalPrice,0) < isnull(@roundTripPrice,0) )  /****  round trip and one way are present but virtual bundled fare is less than round trip fare ****/    
	BEGIN     
		set @isOneWay = 1     
	END     
	else if ( isnull(@roundTripPrice,0) < isnull(@oneWayTotalPrice,0) )  /****  round trip and one way are present but round trip fare is less than virtual bundled fare****/    
	BEGIN     
		set @isOneWay = 1     
	END     
	IF (  isnull(@oneWayTotalPrice,0) = isnull(@roundTripPrice,0) )    
	BEGIN    
		set @isOneWay =0     
	END    
	print (@isOneWay)  

       
       
   IF ( @isOneWay = 1)     
  BEGIN    
     --SELECT * from AirResponse resp inner join @ResultTable r on resp.airResponseKey =r.airResponsekey where airSubRequestLegIndex <> -1    
		SELECT resp.* --,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse    
		FROM AirResponse  Resp INNER JOIN    
		@ResultTable r on resp.airResponseKey =r.airResponsekey     
		INNER JOIN AirSubRequest SubRq on     Resp.airSubRequestKey =subrq.airSubRequestKey    
		WHERE r.airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END)  

		SELECT           
		airSegmentKey,          
		airsegments.airResponseKey,          
		airLegNumber,          
		airSegmentMarketingAirlineCode,          
		airSegmentOperatingAirlineCode,          
		airSegmentResBookDesigCode,          
		airSegmentFlightNumber,          
		airSegmentDuration,          
		(case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) airSegmentEquipment,          
		airSegmentMiles,           
		airSegmentDepartureDate,           
		airSegmentArrivalDate,          
		airSegmentDepartureAirport,          
		DepartureAirport.AirportName AS DepartureAirportName,           
		DepartureAirport.CityName AS DepartureAirportCityName,          
		DepartureAirport.StateCode AS DepartureAirportStateCode,          
		DepartureAirport.CountryCode AS DepartureAirportCountryCode,           
		airSegmentArrivalAirport,          
		ArrivalAirport.AirportName AS ArrivalAirportName,          
		ArrivalAirport.CityName AS ArrivalAirportCityName,          
		ArrivalAirport.StateCode AS ArrivalAirportStateCode,          
		ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,          
		airSegmentDepartureOffset,          
		airSegmentArrivalOffset,          
		airSegmentMarriageGrp,          
		airSegmentSeatRemaining,           
		airFareBasisCode,          
		airFareReferenceKey,          
		ISNULL((DATEADD(HH, (airSegmentDepartureOffset * -1), airSegmentDepartureDate)), airSegmentDepartureDate) AS EquiairSegmentDepartureDate,     
		DepartureAirport.CityCode AS departureCityCode,     
		ArrivalAirport.CityCode AS ArrivalCityCode,     
		AVL.ShortName AS airSegmentOperatingAirlineName,     
		AVL1.ShortName AS airSegmentMarketingAirlineName,     
		airsegmentCabin ,segmentOrder , airSegmentOperatingFlightNumber,amadeusSNDIndicator     
		,AB.[airlineBaggageLink] As MarketingAirlineBaggageLink, ABO.[airlineBaggageLink] As OperatingAirlineBaggageLink,    
		airSegmentOperatingAirlineCompanyShortName ,CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName    
		,AC.[conditionOfCarriageLink] As MarketingAirlineCarriageLink, ACO.[conditionOfCarriageLink] As OperatingAirlineCarriageLink    
		FROM AirSegments     
		inner join @ResultTable r on AirSegments.airResponseKey =r.airResponsekey    
		LEFT OUTER JOIN AirportLookup DepartureAirport ON airSegmentDepartureAirport = DepartureAirport.AirportCode     
		LEFT OUTER JOIN AirportLookup ArrivalAirport ON airSegmentArrivalAirport = ArrivalAirport.AirportCode     
		LEFT OUTER JOIN AirVendorLookup AVL ON AVL.AirlineCode = airSegmentOperatingAirlineCode     
		LEFT OUTER JOIN AirVendorLookup AVL1 ON AVL1.AirlineCode = airSegmentMarketingAirlineCode     
		LEFT OUTER JOIN AircraftsLookup WITH(NOLOCK) on (AirSegments.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)    
		LEFT OUTER JOIN [AirlineBaggageLink] AB ON AB.AirlineCode = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineBaggageLink] ABO ON ABO.AirlineCode = airSegmentOperatingAirlineCode    
		LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode    
		LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode    
		LEFT OUTER JOIN [AirlineCarriageLink] AC ON AC.airline = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineCarriageLink] ACO ON ACO.airline = airSegmentOperatingAirlineCode     
		WHERE r.airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END)  
		ORDER BY  airLegNumber ASC , EquiairSegmentDepartureDate ASC,segmentOrder ASC     
      
  eND     
  else if (@isOneWay =0)    
  BEGIN    
		   
		SELECT resp.* --,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse    
		FROM AirResponse  Resp INNER JOIN    
		@ResultTable r on resp.airResponseKey =r.airResponsekey     
		INNER JOIN AirSubRequest SubRq on     Resp.airSubRequestKey =subrq.airSubRequestKey    
		WHERE r.airSubRequestLegIndex <> -1  
		  
		  
		SELECT           
		airSegmentKey,          
		airsegments.airResponseKey,          
		airLegNumber,          
		airSegmentMarketingAirlineCode,          
		airSegmentOperatingAirlineCode,          
		airSegmentResBookDesigCode,          
		airSegmentFlightNumber,          
		airSegmentDuration,          
		(case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) airSegmentEquipment,     
		airSegmentMiles,           
		airSegmentDepartureDate,           
		airSegmentArrivalDate,          
		airSegmentDepartureAirport,          
		DepartureAirport.AirportName AS DepartureAirportName,           
		DepartureAirport.CityName AS DepartureAirportCityName,          
		DepartureAirport.StateCode AS DepartureAirportStateCode,          
		DepartureAirport.CountryCode AS DepartureAirportCountryCode,           
		airSegmentArrivalAirport,          
		ArrivalAirport.AirportName AS ArrivalAirportName,          
		ArrivalAirport.CityName AS ArrivalAirportCityName,          
		ArrivalAirport.StateCode AS ArrivalAirportStateCode,          
		ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,          
		airSegmentDepartureOffset,          
		airSegmentArrivalOffset,          
		airSegmentMarriageGrp,          
		airSegmentSeatRemaining,           
		airFareBasisCode,          
		airFareReferenceKey,          
		ISNULL((DATEADD(HH, (airSegmentDepartureOffset * -1), airSegmentDepartureDate)), airSegmentDepartureDate) AS EquiairSegmentDepartureDate,     
		DepartureAirport.CityCode AS departureCityCode,     
		ArrivalAirport.CityCode AS ArrivalCityCode,     
		AVL.ShortName AS airSegmentOperatingAirlineName,     
		AVL1.ShortName AS airSegmentMarketingAirlineName,     
		airsegmentCabin ,segmentOrder , airSegmentOperatingFlightNumber,amadeusSNDIndicator     
		,AB.[airlineBaggageLink] As MarketingAirlineBaggageLink, ABO.[airlineBaggageLink] As OperatingAirlineBaggageLink,    
		airSegmentOperatingAirlineCompanyShortName ,CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName    
		,AC.[conditionOfCarriageLink] As MarketingAirlineCarriageLink, ACO.[conditionOfCarriageLink] As OperatingAirlineCarriageLink    
		FROM AirSegments     
		inner join @ResultTable r on AirSegments.airResponseKey =r.airResponsekey    
		LEFT OUTER JOIN AirportLookup DepartureAirport ON airSegmentDepartureAirport = DepartureAirport.AirportCode     
		LEFT OUTER JOIN AirportLookup ArrivalAirport ON airSegmentArrivalAirport = ArrivalAirport.AirportCode     
		LEFT OUTER JOIN AirVendorLookup AVL ON AVL.AirlineCode = airSegmentOperatingAirlineCode     
		LEFT OUTER JOIN AirVendorLookup AVL1 ON AVL1.AirlineCode = airSegmentMarketingAirlineCode     
		 LEFT OUTER JOIN AircraftsLookup WITH(NOLOCK) on (AirSegments.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)    
		LEFT OUTER JOIN [AirlineBaggageLink] AB ON AB.AirlineCode = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineBaggageLink] ABO ON ABO.AirlineCode = airSegmentOperatingAirlineCode    
		LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode    
		LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode    
		LEFT OUTER JOIN [AirlineCarriageLink] AC ON AC.airline = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineCarriageLink] ACO ON ACO.airline = airSegmentOperatingAirlineCode      
		WHERE r.airSubRequestLegIndex <> -1  
		ORDER BY  airLegNumber ASC , EquiairSegmentDepartureDate ASC,segmentOrder ASC     
 
   END    
END
GO
