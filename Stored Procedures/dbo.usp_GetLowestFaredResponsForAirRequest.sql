SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  CREATE Procedure [dbo].[usp_GetLowestFaredResponsForAirRequest] (@airRequestKey int ,@gdsSourceKey int)
  AS
  BEGIN
	  DECLARE @ResultTable AS TABLE (
	  airResponsekey UNIQUEiDENTIFIER ,
	  airPricebase FLOAT ,
	  airPriceTax FLOAT   ,
	  airSubRequestLegIndex int 
	  )
	  DECLARE @vcCurrentCol  as int
		DECLARE subRequestCursor  cursor
		FOR SELECT airSubrequestKey from AirSubRequest WHERE airRequestKey =@airRequestKey AND airSubRequestLegIndex <> -1
		open subRequestCursor

		fetch next from subRequestCursor into @vcCurrentCol

	    
	  WHILE @@Fetch_Status = 0
	  BEGIN
		INSERT INTO @ResultTable 
		 SELECT TOP 1 airResponseKey,airPriceBase,airPriceTax,subreq.airSubRequestLegIndex   FROM AirResponse resp INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey  where resp.airSubRequestKey = @vcCurrentCol order by airPriceBase asc
		FETCH NEXT FROM subRequestCursor INTO @vcCurrentCol
	  END

	  CLOSE subRequestCursor
	  DEALLOCATE subRequestCursor
	  
	  INSERT INTO @ResultTable 
  		 SELECT TOP 1 airResponseKey,airPriceBase,airPriceTax,subreq.airSubRequestLegIndex   FROM AirResponse resp INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey 
  		  WHERE airRequestKey  = @airRequestKey and airSubRequestLegIndex = - 1 ORDER BY airPriceBase ASC
	    
	  
	  DECLARE @oneWayTotalPrice float =0
	  DECLARE @roundTripPrice float = 0
	  
	  Set @roundTripPrice = (SELECT airPricebase + airPriceTax  from @ResultTable where airSubRequestLegIndex = -1 )
	  Set @oneWayTotalPrice = (SELECT sum(airPricebase) + sum(airPriceTax)  from @ResultTable where airSubRequestLegIndex <> -1 )
	   
	   DECLARE @isOneWay bit 
	   if ( @oneWayTotalPrice  is not null and @roundTripPrice is null) /****only round trip is present ****/
	   BEGIN
			set @isOneWay =1 
	   END 
	   else if ( @roundTripPrice is not null and @oneWayTotalPrice is null )  /****only one way trip is present ****/
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
		if ( @isOneWay = 1) 
		BEGIN
		   SELECT * from AirResponse resp inner join @ResultTable r on resp.airResponseKey =r.airResponsekey where airSubRequestLegIndex <> -1
		   SELECT 
			airSegmentKey,
			r.airResponseKey,
			airLegNumber,
			airSegmentMarketingAirlineCode,
			airSegmentOperatingAirlineCode,
			airSegmentResBookDesigCode,
			airSegmentFlightNumber,
			airSegmentDuration,
			airSegmentEquipment,
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
			isnull((DATEADD(HH,(airSegmentDepartureOffset * -1), airSegmentDepartureDate)),airSegmentDepartureDate) AS EquiairSegmentDepartureDate,
			DepartureAirport.CityCode AS departureCityCode,
			ArrivalAirport.CityCode AS ArrivalCityCode,
			AVL.ShortName AS airSegmentOperatingAirlineName ,airsegmentCabin ,segmentOrder ,airSegmentOperatingAirlineCompanyShortName 
			
		FROM AirSegments 
		inner join @ResultTable r on AirSegments.airResponseKey =r.airResponsekey
			LEFT OUTER JOIN AirportLookup DepartureAirport ON airSegmentDepartureAirport = DepartureAirport.AirportCode  
			LEFT OUTER JOIN AirportLookup ArrivalAirport ON airSegmentArrivalAirport = ArrivalAirport.AirportCode   
			LEFT OUTER JOIN AirVendorLookup AVL ON AVL.AirlineCode = airSegmentOperatingAirlineCode  where airSubRequestLegIndex <> -1 
			order by r.airResponsekey ,segmentOrder 
		  -- SELECT * from AirSegments seg inner join @ResultTable r on seg.airResponseKey =r.airResponsekey where airSubRequestLegIndex <> -1 
		eND 
		else if (@isOneWay =2)
		BEGIN
			SELECT * from AirResponse resp inner join @ResultTable r on resp.airResponseKey =r.airResponsekey where airSubRequestLegIndex = -1
			
			SELECT 
			airSegmentKey,
			r.airResponseKey,
			airLegNumber,
			airSegmentMarketingAirlineCode,
			airSegmentOperatingAirlineCode,
			airSegmentResBookDesigCode,
			airSegmentFlightNumber,
			airSegmentDuration,
			airSegmentEquipment,
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
			isnull((DATEADD(HH,(airSegmentDepartureOffset * -1), airSegmentDepartureDate)),airSegmentDepartureDate) AS EquiairSegmentDepartureDate,
			DepartureAirport.CityCode AS departureCityCode,
			ArrivalAirport.CityCode AS ArrivalCityCode,
			AVL.ShortName AS airSegmentOperatingAirlineName ,airsegmentCabin ,segmentOrder ,airSegmentOperatingAirlineCompanyShortName 
			
		FROM AirSegments 
		inner join @ResultTable r on AirSegments.airResponseKey =r.airResponsekey
			LEFT OUTER JOIN AirportLookup DepartureAirport ON airSegmentDepartureAirport = DepartureAirport.AirportCode  
			LEFT OUTER JOIN AirportLookup ArrivalAirport ON airSegmentArrivalAirport = ArrivalAirport.AirportCode   
			LEFT OUTER JOIN AirVendorLookup AVL ON AVL.AirlineCode = airSegmentOperatingAirlineCode
	     where airSubRequestLegIndex = -1 order by r.airResponsekey ,segmentOrder 
		 END
END
GO
