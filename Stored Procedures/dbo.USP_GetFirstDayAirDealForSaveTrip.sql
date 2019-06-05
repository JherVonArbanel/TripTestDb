SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Jayant Guru  
-- Create date: 25th October 2013  
-- Description: Gets Air deals for first day of save trip  
-- =============================================  
  
--EXEC USP_GetFirstDayAirDealForSaveTrip 184566, 0, 1,3, 'WN'  
CREATE PROCEDURE [dbo].[USP_GetFirstDayAirDealForSaveTrip]  
 @airRequestKey INT  
 ,@noOfStops INT = 1  
 ,@leadComponentType INT  
 ,@fromPage INT  
 ,@excludeAirlines VARCHAR(200) = ''  
 ,@airResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'  
    
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
 /*Variable Declaration*/  
 DECLARE @startDate DATE   
   ,@endDate DATE  
   ,@airRequestType INT  
   ,@vcCurrentCol INT  
   ,@airSubRequestKey INT  
   ,@noOfAirStops INT  
   ,@firstHalfMinPrice FLOAT = 0  
   ,@secondHalfMinPrice FLOAT = 0  
 /*END: Variable Declaration*/  
   
 /*Declaring Variable Tables*/  
 DECLARE @tempResponseToRemove AS TABLE       
 (      
  airResponseKey UNIQUEIDENTIFIER      
    )  
      
    DECLARE @ResultTable AS TABLE   
    (      
  airResponsekey UNIQUEIDENTIFIER  
  ,airPricebase FLOAT  
  ,airPriceTax FLOAT  
  ,airSubRequestLegIndex INT  
  ,DealType CHAR  
 )  
   
 --IF ( @noOfStops = 0 )       
 --BEGIN      
 -- DECLARE @nonStopFlights AS TABLE   
 -- (      
 --  airResponsekey UNIQUEIDENTIFIER  
 --  ,leg1NoOfStops INT, leg2NoOfStops INT  
 -- )  
 --END  
   
 DECLARE @TotalNumberOfStops AS TABLE  
 (  
  totalNumberOfStops INT  
  ,AirResponseKey UNIQUEIDENTIFIER  
 )    
    /*END: Declaring Variable Tables*/  
      
    /*Declaring Temp Table*/  
    CREATE TABLE #TblAirResponse  
 (      
  airResponseKey uniqueidentifier,total float,totalNoOfStops INT  
 )  
 /*END: Declaring Temp Table*/  
      
    /*Storing exclude airlines in @tempResponseToRemove table*/     
 IF (@excludeAirlines  <> '' AND @excludeAirlines is not null)      
 BEGIN   
  ---get airlines which will not be part of responses      
  DECLARE @excludedAirlines AS TABLE (airLineCode varchar(200))     
     
  INSERT @excludedAirlines (airLineCode)         
  SELECT * FROM vault.dbo.ufn_CSVToTable (@excludeAirlines)        
  
  ---get responses which has exclude airlines in segments marketting airline  
  INSERT @tempResponseToRemove (airresponsekey)  
  SELECT DISTINCT S.airresponsekey FROM AirSegments S WITH(NOLOCK)   
  INNER JOIN AirResponse resp WITH(NOLOCK)   
  ON s.airResponseKey = resp.airResponseKey         
  INNER JOIN AirSubRequest subReq WITH(NOLOCK)   
  ON resp.airSubRequestKey = subReq.airSubRequestKey    
  WHERE airRequestKey = @airRequestKey       
  AND subreq.groupKey = 1       
  AND airSegmentMarketingAirlineCode     
  IN (SELECT * FROM @excludedAirlines)  
  
  ---get responses which has exclude airlines in segments operating airline      
  INSERT @tempResponseToRemove (airresponsekey )         
  SELECT DISTINCT s.airResponseKey FROM AirSegments s WITH(NOLOCK)   
  INNER JOIN AirResponse resp WITH(NOLOCK)   
  ON s.airResponseKey = resp.airResponseKey         
  INNER JOIN AirSubRequest subReq WITH(NOLOCK)   
  ON resp.airSubRequestKey = subReq.airSubRequestKey    
  where airRequestKey = @airRequestKey       
  AND subReq.groupKey = 1      
  AND airSegmentOperatingAirlineCode IN (SELECT * FROM @excludedAirlines)  
 END  
 /*END: Storing exclude airlines in @tempResponseToRemove table*/  
   
 SELECT @airRequestType = airRequestTypeKey   
 FROM AirRequest WITH (NOLOCK)  
 WHERE airrequestKey = @airRequestKey    
    
 SELECT @startDate = airRequestDepartureDate  
 ,@endDate = airRequestArrivalDate  
 ,@airSubRequestKey = airSubRequestKey  
 FROM AirSubRequest WITH (NOLOCK)  
 WHERE airRequestKey = @airRequestKey  
 AND airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE -1 END) AND groupKey=1
    
 INSERT INTO #TblAirResponse(airResponseKey,total)      
 SELECT airResponseKey, (airPriceBaseDisplay+airPriceTaxDisplay)  
 FROM AirResponse WITH (NOLOCK)   
 WHERE airSubRequestKey = @AirSubRequestKey --ORDER BY total ASC  
   
 /*Deleting exclude airline from #TblAirResponse table*/  
 DELETE FROM #TblAirResponse WHERE airResponseKey IN (SELECT airResponseKey FROM @tempResponseToRemove)  
   
 /*Finding and storing total stops*/  
 INSERT INTO @TotalNumberOfStops  
 SELECT COUNT(airResponseKey), airResponseKey FROM AirSegments WITH(NOLOCK)   
 WHERE airResponseKey IN (SELECT airResponseKey FROM #TblAirResponse)  
 GROUP BY airResponseKey   
   
 /*Update total stops in table #TblAirResponse from variable table @TotalNumberOfStops.  
 If trip type is one way and we are searching for non-stop flights then total number   
 of stops should be 1.  
 If trip type is Round Trip and we are searching for non-stop flights then total number   
 of stops should be 2.*/  
 UPDATE AR  
 SET AR.totalNoOfStops = (SELECT totalNumberOfStops  
 FROM @TotalNumberOfStops NS  
 WHERE NS.AirResponseKey = AR.airResponseKey)  
 FROM #TblAirResponse AR  
   
 --SELECT * FROM #TblAirResponse ORDER BY totalNoOfStops ASC  
   
 /*    
 IF(@noOfStops = 0)  
 BEGIN  
 --print @airRequestType  
  IF ( @airRequestType > 1 )   
  BEGIN --for round trip  
   INSERT @nonStopFlights          
   SELECT leg1.airResponseKey , leg1.leg1NoOfStops ,leg2.leg2NoOfStops FROM      
   (SELECT seg.airResponseKey ,  (COUNT(seg.airSegmentKey) - 1) leg1NoOfStops FROM AirSegments Seg WITH (NOLOCK)   
   INNER JOIN #TblAirResponse resp ON seg.airResponseKey = resp.airResponseKey       
   INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey       
   where  airRequestKey  = @airRequestKey and airSubRequestLegIndex = -1 AND airlegnumber = 1      
   GROUP BY seg.airresponseKey) leg1  
   INNER JOIN       
   (SELECT seg.airResponseKey ,(COUNT(seg.airSegmentKey) - 1) leg2NoOfStops   
   FROM AirSegments Seg WITH (NOLOCK) inner join #TblAirResponse resp   
   ON seg.airResponseKey = resp.airResponseKey       
   INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey       
   where  airRequestKey  = @airRequestKey and  airSubRequestLegIndex = - 1 AND airlegnumber = 2      
   GROUP BY seg.airresponseKey)   leg2  
   on leg1.airResponseKey = leg2.airResponseKey  
  END  
  ELSE   
  BEGIN --for One way  
   INSERT @nonStopFlights          
   SELECT leg1.airResponseKey , leg1.leg1NoOfStops ,0 FROM      
   ( SELECT seg.airResponseKey ,(COUNT(seg.airSegmentKey) -1) leg1NoOfStops FROM AirSegments Seg WITH (NOLOCK) inner join AirResponse resp WITH (NOLOCK) ON seg.airResponseKey = resp.airResponseKey       
   INNER JOIN  AirSubRequest subReq on resp.airSubRequestKey = subreq.airSubRequestKey       
   where  airRequestKey  = @airRequestKey and airSubRequestLegIndex = (CASE WHEN @airRequestType = 1 THEN 1 ELSE  - 1 END)   AND airlegnumber = 1      
   GROUP BY seg.airresponseKey)   leg1       
  END  
 END  
 */  
   
 --IF(@leadComponentType = 0)  
 --BEGIN  
 -- SELECT TOP 1 * FROM #TblAirResponse TAR  
 -- INNER JOIN AirSegments ASEG  
 -- ON TAR.airResponseKey = ASEG.airResponseKey  
 -- WHERE total = (SELECT MIN(total) FROM #TblAirResponse)  
 -- AND ASEG.airSegmentDepartureDate = (SELECT MIN(airSegmentDepartureDate) FROM AirSegments   
 -- WHERE airResponseKey IN (SELECT airResponseKey FROM #TblAirResponse)  
 -- AND ASEG.airLegNumber = 1 AND ASEG.segmentOrder = 1)  
 --END  
   
 /*If there is no hotel and user has selected AIR then Air becomes the lead component type*/  
   
 /*Setting the value to find non-stop flight*/  
 IF(@noOfStops = 0)  
 BEGIN  
  IF(@airRequestType = 2) --For round trip non-stop totalNoOfStops in #TblAirResponse should be 2  
  BEGIN  
   SET @noOfAirStops = 2  
  END  
 ELSE --For one way non-stop totalNoOfStops in #TblAirResponse should be 1  
  BEGIN  
   SET @noOfAirStops = 1  
  END  
 END  
 /*END: Setting the value to find non-stop flight*/  
   
 IF(@leadComponentType = 1)  
 BEGIN  
  IF(@fromPage = 1 OR @fromPage = 3)--follow deals and get deals page  
  BEGIN  
   /*Recommended deal: TODO - Rules yet not finalized*/  
   INSERT INTO @ResultTable (airResponsekey, dealType)  
   SELECT TOP 1 TAR.airResponseKey, 'R' FROM #TblAirResponse TAR  
   ORDER BY totalNoOfStops ASC, total ASC  
  END  
    
  IF(@fromPage = 3 OR @fromPage = 2)--for trip summary and get deals page  
  BEGIN  
   /*Minimum price between 12 AM(Midnight) to 12 PM(Afternoon)*/  
   --SELECT @firstHalfMinPrice = MIN(AR.total)  
   --FROM #TblAirResponse AR  
   --INNER JOIN AirSegments ASEG WITH (NOLOCK)  
   --ON AR.airResponseKey = ASEG.airResponseKey  
   --AND ASEG.airSegmentDepartureDate  
   --BETWEEN CONVERT(VARCHAR,@startDate) + ' 00:01:00.000'   
   --AND CONVERT(VARCHAR,@startDate) + ' 12:00:00.000'  
   /*END: Minimum price between 12 AM(Midnight) to 12 PM(Afternoon)*/  
     
   /*Minimum price between 12:01 PM(Afternoon) to 11:59 PM(Midnight)*/  
   --SELECT @secondHalfMinPrice = MIN(AR.total)  
   --FROM #TblAirResponse AR  
   --INNER JOIN AirSegments ASEG WITH (NOLOCK)  
   --ON AR.airResponseKey = ASEG.airResponseKey  
   --AND ASEG.airSegmentDepartureDate  
   --BETWEEN CONVERT(VARCHAR,@startDate) + ' 12:01:00.000'   
   --AND CONVERT(VARCHAR,@startDate) + ' 23:59:00.000'  
   /*END: Minimum price between 12:01 PM(Afternoon) to 11:59 PM(Midnight)*/  
     
   /*FIRST HALF - 12 AM(Midnight) to 12 PM(Afternoon)*/  
   IF(@noOfStops = 0)--for non-stop flight  
   BEGIN  
    /*Lowest fare deal: TODO - Rules yet not finalized*/  
    INSERT INTO @ResultTable (airResponsekey, dealType)  
    SELECT TOP 1 TAR.airResponseKey, 'L' FROM #TblAirResponse TAR  
    INNER JOIN AirSegments ASEG WITH (NOLOCK)  
    ON TAR.airResponseKey = ASEG.airResponseKey  
    WHERE ASEG.airSegmentDepartureDate  
    BETWEEN CONVERT(VARCHAR,@startDate) + ' 00:01:00.000'   
    AND CONVERT(VARCHAR,@startDate) + ' 12:00:00.000'  
    AND TAR.totalNoOfStops = @noOfAirStops  
    AND TAR.airResponseKey NOT IN (SELECT airResponseKey FROM @ResultTable)  
    AND TAR.airResponseKey <> @airResponseKey  
    AND ASEG.airLegNumber = 1  
    AND ASEG.segmentOrder = 1  
    ORDER BY TAR.total ASC, ASEG.airSegmentDepartureDate ASC  
   END  
     
   /*Applicable for 1+stop flight AND ALSO IF no result found for non-stop flight*/  
   IF((SELECT COUNT(airResponsekey) FROM @ResultTable WHERE DealType = 'L') = 0)  
   BEGIN  
    /*Lowest fare deal: TODO - Rules yet not finalized*/  
    INSERT INTO @ResultTable (airResponsekey, dealType)  
    SELECT TOP 1 TAR.airResponseKey, 'L' FROM #TblAirResponse TAR  
    INNER JOIN AirSegments ASEG WITH(NOLOCK)  
    ON TAR.airResponseKey = ASEG.airResponseKey  
    WHERE ASEG.airSegmentDepartureDate  
    BETWEEN CONVERT(VARCHAR,@startDate) + ' 00:01:00.000'   
    AND CONVERT(VARCHAR,@startDate) + ' 12:00:00.000'  
    AND TAR.airResponseKey NOT IN (SELECT airResponseKey FROM @ResultTable)  
    AND TAR.airResponseKey <> @airResponseKey  
    AND ASEG.airLegNumber = 1  
    AND ASEG.segmentOrder = 1  
    ORDER BY TAR.total ASC, ASEG.airSegmentDepartureDate ASC   
   END     
   /*END: FIRST HALF - 12 AM(Midnight) to 12 PM(Afternoon)*/  
     
   /*EXCEPTION BLOCK - WHEN NO FLIGHT FOUND IN 1ST HALF, SELECT FLIGHT FROM 2ND HALF*/  
   IF((SELECT COUNT(airResponsekey) FROM @ResultTable WHERE DealType = 'L') = 0)  
   BEGIN  
    INSERT INTO @ResultTable (airResponsekey, dealType)  
    SELECT TOP 1 TAR.airResponseKey, 'L' FROM #TblAirResponse TAR  
    INNER JOIN AirSegments ASEG WITH(NOLOCK)  
    ON TAR.airResponseKey = ASEG.airResponseKey  
    WHERE ASEG.airSegmentDepartureDate  
    BETWEEN CONVERT(DATETIME,CONVERT(VARCHAR,@startDate) + ' 12:01:00.000')   
    AND CONVERT(DATETIME,CONVERT(VARCHAR,@startDate) + ' 23:59:00.000')  
    AND TAR.airResponseKey NOT IN (SELECT airResponseKey FROM @ResultTable)  
    AND TAR.airResponseKey <> @airResponseKey  
    AND ASEG.airLegNumber = 1  
    AND ASEG.segmentOrder = 1  
    ORDER BY TAR.total ASC, ASEG.airSegmentDepartureDate ASC    
   END  
   /*END: EXCEPTION BLOCK - WHEN NO FLIGHT FOUND IN 1ST HALF, SELECT FLIGHT FROM 2ND HALF*/  
     
   /*SECOND HALF - 12:01 PM(Afternoon) to 11:59 PM(Midnight*/   
   IF(@noOfStops = 0)--for non-stop flight  
   BEGIN  
    /*Upgraded Deal: TODO - Rules yet not finalized*/  
    INSERT INTO @ResultTable (airResponsekey, dealType)  
    SELECT TOP 1 TAR.airResponseKey, 'U' FROM #TblAirResponse TAR  
    INNER JOIN AirSegments ASEG WITH(NOLOCK)  
    ON TAR.airResponseKey = ASEG.airResponseKey  
    WHERE ASEG.airSegmentDepartureDate  
    BETWEEN CONVERT(DATETIME,CONVERT(VARCHAR,@startDate) + ' 12:01:00.000')   
    AND CONVERT(DATETIME,CONVERT(VARCHAR,@startDate) + ' 23:59:00.000')  
    AND TAR.totalNoOfStops = @noOfAirStops  
    AND TAR.airResponseKey NOT IN (SELECT airResponseKey FROM @ResultTable)  
    AND TAR.airResponseKey <> @airResponseKey  
    AND ASEG.airLegNumber = 1  
    AND ASEG.segmentOrder = 1  
    ORDER BY TAR.total ASC, ASEG.airSegmentDepartureDate ASC      
   END  
     
   /*Applicable for 1+stop flight and also IF no result found for non-stop flight*/  
   IF((SELECT COUNT(airResponsekey) FROM @ResultTable WHERE DealType = 'U') = 0)  
   BEGIN  
    /*Upgraded Deal: TODO - Rules yet not finalized*/  
    INSERT INTO @ResultTable (airResponsekey, dealType)  
    SELECT TOP 1 TAR.airResponseKey, 'U' FROM #TblAirResponse TAR  
    INNER JOIN AirSegments ASEG WITH(NOLOCK)  
    ON TAR.airResponseKey = ASEG.airResponseKey  
    WHERE ASEG.airSegmentDepartureDate  
    BETWEEN CONVERT(VARCHAR,@startDate) + ' 12:01:00.000'  
    AND CONVERT(VARCHAR,@startDate) + ' 23:59:00.000'  
    AND TAR.airResponseKey NOT IN (SELECT airResponseKey FROM @ResultTable)  
    AND TAR.airResponseKey <> @airResponseKey  
    AND ASEG.airLegNumber = 1  
    AND ASEG.segmentOrder = 1  
    ORDER BY TAR.total ASC, ASEG.airSegmentDepartureDate ASC  
   END  
   /*END: SECOND HALF - 12:01 PM(Afternoon) to 11:59 PM(Midnight*/  
     
   /*EXCEPTION BLOCK - WHEN NO FLIGHT FOUND IN 2ND HALF, SELECT FLIGHT FROM FIRST HALF*/  
   IF((SELECT COUNT(airResponsekey) FROM @ResultTable WHERE DealType = 'U') = 0)  
   BEGIN  
    INSERT INTO @ResultTable (airResponsekey, dealType)  
    SELECT TOP 1 TAR.airResponseKey, 'U' FROM #TblAirResponse TAR  
    INNER JOIN AirSegments ASEG WITH(NOLOCK)  
    ON TAR.airResponseKey = ASEG.airResponseKey  
    WHERE ASEG.airSegmentDepartureDate  
    BETWEEN CONVERT(VARCHAR,@startDate) + ' 00:01:00.000'   
    AND CONVERT(VARCHAR,@startDate) + ' 12:00:00.000'  
    AND TAR.airResponseKey NOT IN (SELECT airResponseKey FROM @ResultTable)  
    AND TAR.airResponseKey <> @airResponseKey  
    AND ASEG.airLegNumber = 1  
    AND ASEG.segmentOrder = 1  
    ORDER BY TAR.total ASC, ASEG.airSegmentDepartureDate ASC  
   END  
   /*END: EXCEPTION BLOCK - WHEN NO FLIGHT FOUND IN 2ND HALF, SELECT FLIGHT FROM FIRST HALF*/  
     
  END  
    
 END  
 /*END: If there is no hotel and user has selected AIR then Air becomes the lead component type*/  
 ELSE   
 /*If AIR is not the lead component type*/  
 BEGIN  
  IF(@noOfStops = 0) --For Non-Stop Flight  
  BEGIN  
   INSERT INTO @ResultTable (airResponsekey, dealType)  
   SELECT TOP 1 TAR.airResponseKey, 'R' FROM #TblAirResponse TAR  
   INNER JOIN AirSegments ASEG WITH(NOLOCK)  
   ON TAR.airResponseKey = ASEG.airResponseKey  
   WHERE TAR.totalNoOfStops = @noOfAirStops  
   ORDER BY TAR.total ASC, ASEG.airSegmentDepartureDate ASC  
  END  
    
  /*Applicable for 1+Stop flight AND ALSO if no flights found for non-stop*/  
  IF((SELECT COUNT(airResponsekey) FROM @ResultTable) = 0)  
  BEGIN  
   INSERT INTO @ResultTable (airResponsekey, dealType)  
   SELECT TOP 1 TAR.airResponseKey, 'R' FROM #TblAirResponse TAR  
   INNER JOIN AirSegments ASEG WITH(NOLOCK)  
   ON TAR.airResponseKey = ASEG.airResponseKey  
   ORDER BY tar.total ASC, ASEG.airSegmentDepartureDate ASC   
  END  
  /*END: Applicable for 1+Stop flight AND ALSO if no flights found for non-stop*/  
    
 END  
 /*END: If AIR is not the lead component type*/  
   
 --DELETE FROM @ResultTable WHERE DealType = 'U'  
   
 /*Final select query to return data*/  
 SELECT R.DealType, resp.*  
  FROM AirResponse Resp WITH(NOLOCK) INNER JOIN      
  @ResultTable r on resp.airResponseKey = r.airResponsekey       
  INNER JOIN AirSubRequest SubRq WITH(NOLOCK)   
  on  Resp.airSubRequestKey = subrq.airSubRequestKey  
      
 SELECT DISTINCT             
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
 FROM AirSegments WITH(NOLOCK)       
 inner join @ResultTable r on AirSegments.airResponseKey = r.airResponsekey      
 LEFT OUTER JOIN AirportLookup DepartureAirport WITH (NOLOCK)  
 ON airSegmentDepartureAirport = DepartureAirport.AirportCode       
 LEFT OUTER JOIN AirportLookup ArrivalAirport WITH (NOLOCK)  
 ON airSegmentArrivalAirport = ArrivalAirport.AirportCode       
 LEFT OUTER JOIN AirVendorLookup AVL WITH (NOLOCK)  
 ON AVL.AirlineCode = airSegmentOperatingAirlineCode       
 LEFT OUTER JOIN AirVendorLookup AVL1 WITH (NOLOCK)  
 ON AVL1.AirlineCode = airSegmentMarketingAirlineCode       
 LEFT OUTER JOIN AircraftsLookup WITH(NOLOCK)   
 on (AirSegments.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)      
 LEFT OUTER JOIN [AirlineBaggageLink] AB WITH (NOLOCK)  
 ON AB.AirlineCode = airSegmentMarketingAirlineCode      
 LEFT OUTER JOIN [AirlineBaggageLink] ABO WITH (NOLOCK)  
 ON ABO.AirlineCode = airSegmentOperatingAirlineCode      
 LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)    
 ON departureAirport.CountryCode = CD.CountryCode      
 LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)    
 ON arrivalAirport.CountryCode = CA.CountryCode      
 LEFT OUTER JOIN [AirlineCarriageLink] AC WITH (NOLOCK)  
 ON AC.airline = airSegmentMarketingAirlineCode      
 LEFT OUTER JOIN [AirlineCarriageLink] ACO WITH (NOLOCK)  
 ON ACO.airline = airSegmentOperatingAirlineCode  
 ORDER BY airResponseKey ASC, airLegNumber ASC, segmentOrder ASC    
 /*END: Final select query to return data*/  
    
 DROP TABLE #TblAirResponse  
END  
  
  
GO
