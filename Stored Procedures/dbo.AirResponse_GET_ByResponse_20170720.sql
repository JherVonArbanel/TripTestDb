SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AirResponse_GET_ByResponse_20170720] 
(            
 @airRequestKey INT,            
 @LegIndex  INT,            
 @flightNumber VARCHAR(100),            
 @airLines  VARCHAR(2000),            
 @airResponseKey UNIQUEIDENTIFIER = NULL,            
 @withAirSegment INT,
 @airResponseMultiBrandID VARCHAR(100) = N'00000000-0000-0000-0000-000000000000'            
)             
AS            
BEGIN 
 DECLARE @leg1BrandName AS varchar(100)
 --CREATE TABLE #Temp_ResultSet      
	--(   
	--airResponsekey uniqueidentifier , 
	--airsubRequestkey int ,  
	--airPriceBase float ,  
	--airPriceTax float,  
	--airPriceBaseSenior float,
	--airPriceTaxSenior float,
	--airPriceBaseChildren float,
	--airPriceTaxChildren float,
	--airPriceBaseInfant float,
	--airPriceTaxInfant float,
	--airPriceBaseYouth float,
	--airPriceTaxYouth float,
	--airPriceBaseTotal float,
	--airPriceTaxTotal float,
	--airPriceBaseDisplay float,
	--airPriceTaxDisplay float,
	--airPriceBaseInfantWithSeat float,
	--airPriceTaxInfantWithSeat float, 
	--gdsSourceKey int,
	--ValidatingCarrier varchar(10),
	--contractCode varchar(50),
	--fareType varchar(20),
	--refundable bit,
	--IsPublishedCallResponse bit,
	--airResponseMultiBrandKey uniqueidentifier
	--)
	             
 IF @withAirSegment = 0            
 BEGIN        
  IF EXISTS(  
   SELECT TOP 1 NormalizedAirResponses.airResponseKey, NormalizedAirResponses.airsubrequestkey, airPriceBase, airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airPriceBaseYouth,
   airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, gdsSourceKey ,ValidatingCarrier,contractCode, fareType, AirResponse.refundable,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse  
   FROM NormalizedAirResponses WITH (NOLOCK)            
   INNER JOIN AirSubRequest subRq WITH (NOLOCK)on NormalizedAirResponses.airsubrequestkey =subRq.airSubRequestKey   
   LEFT OUTER JOIN AirResponse WITH (NOLOCK) ON AirResponse.airResponseKey = NormalizedAirResponses.airResponseKey           
   WHERE NormalizedAirResponses.airSubRequestKey = (SELECT airSubRequestKey FROM AirSubRequest           
   WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = @LegIndex)           
   AND flightNumber = '' + @flightNumber + '' AND airlines IN ('' + @airLines + '')           
   AND AirResponse.airResponseKey = @airResponseKey   
      )  
  BEGIN
   IF (@airResponseMultiBrandID = N'00000000-0000-0000-0000-000000000000')
   BEGIN 
   --print('1')
	   SELECT TOP 1 NormalizedAirResponses.airResponseKey, NormalizedAirResponses.airsubrequestkey, airPriceBase, airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airPriceBaseYouth,
	   airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, gdsSourceKey ,ValidatingCarrier,contractCode, fareType, AirResponse.refundable,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse  
	   FROM NormalizedAirResponses WITH (NOLOCK)            
	   INNER JOIN AirSubRequest subRq WITH (NOLOCK) on NormalizedAirResponses.airsubrequestkey =subRq.airSubRequestKey   
	   LEFT OUTER JOIN AirResponse WITH (NOLOCK)ON AirResponse.airResponseKey = NormalizedAirResponses.airResponseKey           
	   WHERE NormalizedAirResponses.airSubRequestKey = (SELECT airSubRequestKey FROM AirSubRequest           
	   WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = @LegIndex)           
	   AND flightNumber = '' + @flightNumber + '' AND airlines IN ('' + @airLines + '')           
	   AND AirResponse.airResponseKey = @airResponseKey 
   END 
   ELSE
   BEGIN
   --print('2')
	   SELECT TOP 1 NormalizedAirResponses.airResponseKey, NormalizedAirResponses.airsubrequestkey, airPriceBase, airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airPriceBaseYouth,
	   airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, gdsSourceKey ,ValidatingCarrier,contractCode, fareType, AirResponse.refundable,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse  
	   FROM NormalizedAirResponses WITH (NOLOCK)            
	   INNER JOIN AirSubRequest subRq WITH (NOLOCK) on NormalizedAirResponses.airsubrequestkey =subRq.airSubRequestKey   
	   LEFT OUTER JOIN AirResponse WITH (NOLOCK)ON AirResponse.airResponseKey = NormalizedAirResponses.airResponseKey           
	   WHERE NormalizedAirResponses.airSubRequestKey = (SELECT airSubRequestKey FROM AirSubRequest           
	   WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = @LegIndex)           
	   AND flightNumber = '' + @flightNumber + '' AND airlines IN ('' + @airLines + '')           
	   AND AirResponse.airResponseKey = @airResponseKey
   END 
  END  
   ELSE  
   BEGIN 
   IF (@airResponseMultiBrandID = N'00000000-0000-0000-0000-000000000000')
   BEGIN
    -- print('3')
	   SELECT TOP 1 NormalizedAirResponses.airResponseKey, NormalizedAirResponses.airsubrequestkey, airPriceBase, airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, gdsSourceKey ,ValidatingCarrier,contractCode, fareType, AirResponse.refundable,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse  
	   FROM NormalizedAirResponses  WITH (NOLOCK)           
	   INNER JOIN AirSubRequest subRq WITH (NOLOCK) on NormalizedAirResponses.airsubrequestkey =subRq.airSubRequestKey   
	   LEFT OUTER JOIN AirResponse WITH (NOLOCK) ON AirResponse.airResponseKey = NormalizedAirResponses.airResponseKey           
	   WHERE NormalizedAirResponses.airSubRequestKey = (SELECT airSubRequestKey FROM AirSubRequest           
	   WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = @LegIndex)           
	   AND flightNumber = '' + @flightNumber + '' AND airlines IN ('' + @airLines + '')
   END
   ELSE
   BEGIN
     --print('4')
       SELECT  @leg1BrandName = airLegBrandName FROM NormalizedAirResponsesMultiBrand WITH(NOLOCK) WHERE airresponseMultiBrandkey = @airResponseMultiBrandID and airLegNumber = @LegIndex  

    --   INSERT INTO #Temp_ResultSet(airResponsekey,airsubRequestkey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airPriceBaseYouth,airPriceTaxYouth,airPriceBaseTotal,airPriceTaxTotal,gdsSourceKey,ValidatingCarrier,contractCode,fareType,refundable,IsPublishedCallResponse)
    --   SELECT TOP 1 NormalizedAirResponses.airResponseKey, NormalizedAirResponses.airsubrequestkey, airPriceBase, airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, gdsSourceKey ,ValidatingCarrier,contractCode, fareType, AirResponse.refundable,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse  
	   --FROM NormalizedAirResponses  WITH (NOLOCK)           
	   --INNER JOIN AirSubRequest subRq WITH (NOLOCK) on NormalizedAirResponses.airsubrequestkey =subRq.airSubRequestKey   
	   --LEFT OUTER JOIN AirResponse WITH (NOLOCK) ON AirResponse.airResponseKey = NormalizedAirResponses.airResponseKey           
	   --WHERE NormalizedAirResponses.airSubRequestKey = (SELECT airSubRequestKey FROM AirSubRequest           
	   --WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = @LegIndex)           
	   --AND flightNumber = '' + @flightNumber + '' AND airlines IN ('' + @airLines + '')
	   
	   --SELECT @leg1BrandName
	   
       IF(@leg1BrandName IS NOT NULL)
       BEGIN
    --   SELECT * FROM #Temp_ResultSet P
    --   INNER JOIN AirResponseMultiBrand ARMB ON P.airResponsekey = ARMB.airResponseKey
    --   INNER JOIN NormalizedAirResponsesMultiBrand NARMB ON NARMB.airresponseMultiBrandkey = ARMB.airResponseMultiBrandKey
    --   WHERE NARMB.airLegBrandName = @leg1BrandName
      
    --   UPDATE P 
    --   SET P.airPriceBase = ARMB.airPriceBase,P.airPriceTax = ARMB.airPriceTax,P.airPriceBaseSenior = ARMB.airPriceBaseSenior,P.airPriceTaxSenior = ARMB.airPriceTaxSenior,P.airPriceBaseChildren = ARMB.airPriceBaseChildren,
    --   P.airPriceTaxChildren = ARMB.airPriceTaxChildren,P.airPriceBaseInfant = ARMB.airPriceBaseInfant,P.airPriceTaxInfant = ARMB.airPriceTaxInfant,P.airPriceBaseInfantWithSeat = ARMB.airPriceBaseInfantWithSeat,P.airPriceTaxInfantWithSeat = ARMB.airPriceTaxInfantWithSeat,
    --   P.airPriceBaseYouth = ARMB.airPriceBaseYouth,P.airPriceTaxYouth = ARMB.airPriceTaxYouth,P.airPriceBaseTotal = ARMB.airPriceBaseTotal,P.airPriceTaxTotal = ARMB.airPriceTaxTotal,
    --   P.gdsSourceKey = ARMB.gdsSourceKey,P.ValidatingCarrier = ARMB.ValidatingCarrier,P.contractCode = ARMB.contractCode,P.fareType = ARMB.fareType,
    --   P.refundable = ARMB.refundable,P.airResponseMultiBrandKey = ARMB.airResponseMultiBrandKey
    --   FROM #Temp_ResultSet P
    --   INNER JOIN AirResponseMultiBrand ARMB ON P.airResponsekey = ARMB.airResponseKey
    --   INNER JOIN NormalizedAirResponsesMultiBrand NARMB ON NARMB.airresponseMultiBrandkey = ARMB.airResponseMultiBrandKey
    --   WHERE NARMB.airLegBrandName = @leg1BrandName  
	   
	   --SELECT airResponsekey,airsubRequestkey,airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseInfantWithSeat,airPriceTaxInfantWithSeat,airPriceBaseYouth,airPriceTaxYouth,airPriceBaseTotal,airPriceTaxTotal,gdsSourceKey,ValidatingCarrier,contractCode,fareType,refundable,IsPublishedCallResponse,airResponseMultiBrandKey from #Temp_ResultSet
	   
	   SELECT TOP 1 NormalizedAirResponses.airResponseKey, NormalizedAirResponses.airsubrequestkey, ARMB.airPriceBase, ARMB.airPriceTax,ARMB.airPriceBaseSenior,ARMB.airPriceTaxSenior,ARMB.airPriceBaseChildren,ARMB.airPriceTaxChildren,ARMB.airPriceBaseInfant,ARMB.airPriceTaxInfant,ARMB.airPriceBaseInfantWithSeat,ARMB.airPriceTaxInfantWithSeat,ARMB.airPriceBaseYouth,ARMB.airPriceTaxYouth,ARMB.AirPriceBaseTotal,ARMB.AirPriceTaxTotal, ARMB.gdsSourceKey ,ARMB.ValidatingCarrier,ARMB.contractCode, ARMB.fareType, ARMB.refundable,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse,ARMB.airResponseMultiBrandKey  
	   FROM NormalizedAirResponses  WITH (NOLOCK)           
	   INNER JOIN AirSubRequest subRq WITH (NOLOCK) on NormalizedAirResponses.airsubrequestkey =subRq.airSubRequestKey   
	   LEFT OUTER JOIN AirResponse WITH (NOLOCK) ON AirResponse.airResponseKey = NormalizedAirResponses.airResponseKey 
	   LEFT OUTER JOIN AirResponseMultiBrand ARMB WITH (NOLOCK) ON AirResponse.airResponseKey = ARMB.airResponseKey         
	   LEFT OUTER JOIN NormalizedAirResponsesMultiBrand NARMB WITH (NOLOCK) ON NARMB.airResponseMultiBrandKey = ARMB.airResponseMultiBrandKey         
	   WHERE NormalizedAirResponses.airSubRequestKey = (SELECT airSubRequestKey FROM AirSubRequest           
	   WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = @LegIndex)           
	   AND NormalizedAirResponses.flightNumber = '' + @flightNumber + '' AND NormalizedAirResponses.airlines IN ('' + @airLines + '')
	   AND NARMB.airLegBrandName = @leg1BrandName
	   END
   END       
  END  
 END            
 ELSE            
 BEGIN
   IF (@airResponseMultiBrandID = N'00000000-0000-0000-0000-000000000000') 
   BEGIN
	   SELECT airSegmentKey, airResponseKey, airLegNumber, airSegmentMarketingAirlineCode, airSegmentOperatingAirlineCode,           
	   airSegmentResBookDesigCode, airSegmentFlightNumber, airSegmentDuration, airSegmentEquipment, airSegmentMiles,           
	   airSegmentDepartureDate, airSegmentArrivalDate, airSegmentDepartureAirport, DepartureAirport.AirportName AS DepartureAirportName,           
	   DepartureAirport.CityName AS DepartureAirportCityName, DepartureAirport.StateCode AS DepartureAirportStateCode,           
	   DepartureAirport.CountryCode AS DepartureAirportCountryCode, airSegmentArrivalAirport,           
	   ArrivalAirport.AirportName AS ArrivalAirportName, ArrivalAirport.CityName AS ArrivalAirportCityName,           
	   ArrivalAirport.StateCode AS ArrivalAirportStateCode, ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,           
	   airSegmentDepartureOffset, airSegmentArrivalOffset, DepartureAirport.CityCode AS departureCityCode,           
	   ArrivalAirport.CityCode AS ArrivalCityCode, airSegmentMarriageGrp, airSegmentOperatingAirlineCode,           
	   airSegmentOperatingFlightNumber, AVL.ShortName AS airSegmentOperatingAirlineName,  
	   -- ADDED FOR SHOWING OPERATING AIRLINES ON FLIGHT RECAP PAGE.             
	   AVL1.ShortName AS airSegmentMarketingAirlineName               
	   ,AB.[airlineBaggageLink] As MarketingAirlineBaggageLink, ABO.[airlineBaggageLink] As OperatingAirlineBaggageLink, airSegmentOperatingAirlineCompanyShortName  ,CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName  
	   ,AC.[conditionOfCarriageLink] As MarketingAirlineCarriageLink, ACO.[conditionOfCarriageLink] As OperatingAirlineCarriageLink  
	   ,airsegmentCabin,segmentOrder,airsegmentPricingKey,airSegmentBrandName
	  FROM AirSegments  WITH (NOLOCK)           
	   LEFT OUTER JOIN AirportLookup DepartureAirport WITH (NOLOCK) ON airSegmentDepartureAirport = DepartureAirport.AirportCode              
	   LEFT OUTER JOIN AirportLookup ArrivalAirport WITH (NOLOCK) ON airSegmentArrivalAirport = ArrivalAirport.AirportCode              
	   LEFT OUTER JOIN AirVendorLookup AVL WITH (NOLOCK) ON AVL.AirlineCode = airSegmentOperatingAirlineCode                
	   LEFT OUTER JOIN AirVendorLookup AVL1  WITH (NOLOCK) ON AVL1.AirlineCode = airSegmentMarketingAirlineCode         
	   LEFT OUTER JOIN [AirlineBaggageLink] AB WITH (NOLOCK) ON AB.AirlineCode = airSegmentMarketingAirlineCode    
	   LEFT OUTER JOIN [AirlineBaggageLink] ABO WITH (NOLOCK) ON ABO.AirlineCode = airSegmentOperatingAirlineCode    
	   LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode  
	   LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode  
	   LEFT OUTER JOIN [AirlineCarriageLink] AC WITH (NOLOCK)ON AC.airline = airSegmentMarketingAirlineCode  
	   LEFT OUTER JOIN [AirlineCarriageLink] ACO WITH (NOLOCK) ON ACO.airline = airSegmentOperatingAirlineCode  
	  WHERE airResponseKey = @airResponseKey         
	  order by  airResponseKey , segmentOrder
   END
   ELSE
   BEGIN
	   SELECT AirSegments.airSegmentKey, AirSegments.airResponseKey, AirSegments.airLegNumber, airSegmentMarketingAirlineCode, airSegmentOperatingAirlineCode,           
	   ASMB.airSegmentResBookDesigCode, airSegmentFlightNumber, airSegmentDuration, airSegmentEquipment, airSegmentMiles,           
	   airSegmentDepartureDate, airSegmentArrivalDate, airSegmentDepartureAirport, DepartureAirport.AirportName AS DepartureAirportName,           
	   DepartureAirport.CityName AS DepartureAirportCityName, DepartureAirport.StateCode AS DepartureAirportStateCode,           
	   DepartureAirport.CountryCode AS DepartureAirportCountryCode, airSegmentArrivalAirport,           
	   ArrivalAirport.AirportName AS ArrivalAirportName, ArrivalAirport.CityName AS ArrivalAirportCityName,           
	   ArrivalAirport.StateCode AS ArrivalAirportStateCode, ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,           
	   airSegmentDepartureOffset, airSegmentArrivalOffset, DepartureAirport.CityCode AS departureCityCode,           
	   ArrivalAirport.CityCode AS ArrivalCityCode, airSegmentMarriageGrp, airSegmentOperatingAirlineCode,           
	   airSegmentOperatingFlightNumber, AVL.ShortName AS airSegmentOperatingAirlineName,  
	   -- ADDED FOR SHOWING OPERATING AIRLINES ON FLIGHT RECAP PAGE.             
	   AVL1.ShortName AS airSegmentMarketingAirlineName               
	   ,AB.[airlineBaggageLink] As MarketingAirlineBaggageLink, ABO.[airlineBaggageLink] As OperatingAirlineBaggageLink, airSegmentOperatingAirlineCompanyShortName  ,CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName  
	   ,AC.[conditionOfCarriageLink] As MarketingAirlineCarriageLink, ACO.[conditionOfCarriageLink] As OperatingAirlineCarriageLink  
	   ,ASMB.airsegmentCabin,AirSegments.segmentOrder,AirSegments.airsegmentPricingKey,ASMB.airSegmentBrandName
	  FROM AirSegments  WITH (NOLOCK)
	   INNER JOIN AirSegmentsMultiBrand ASMB ON ASMB.airResponseKey = AirSegments.airResponseKey            
	   LEFT OUTER JOIN AirportLookup DepartureAirport WITH (NOLOCK) ON airSegmentDepartureAirport = DepartureAirport.AirportCode              
	   LEFT OUTER JOIN AirportLookup ArrivalAirport WITH (NOLOCK) ON airSegmentArrivalAirport = ArrivalAirport.AirportCode              
	   LEFT OUTER JOIN AirVendorLookup AVL WITH (NOLOCK) ON AVL.AirlineCode = airSegmentOperatingAirlineCode                
	   LEFT OUTER JOIN AirVendorLookup AVL1  WITH (NOLOCK) ON AVL1.AirlineCode = airSegmentMarketingAirlineCode         
	   LEFT OUTER JOIN [AirlineBaggageLink] AB WITH (NOLOCK) ON AB.AirlineCode = airSegmentMarketingAirlineCode    
	   LEFT OUTER JOIN [AirlineBaggageLink] ABO WITH (NOLOCK) ON ABO.AirlineCode = airSegmentOperatingAirlineCode    
	   LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode  
	   LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode  
	   LEFT OUTER JOIN [AirlineCarriageLink] AC WITH (NOLOCK)ON AC.airline = airSegmentMarketingAirlineCode  
	   LEFT OUTER JOIN [AirlineCarriageLink] ACO WITH (NOLOCK) ON ACO.airline = airSegmentOperatingAirlineCode  
	  WHERE AirSegments.airResponseKey = @airResponseKey and ASMB.airResponseMultiBrandKey = @airResponseMultiBrandID        
	  order by  airResponseKey , segmentOrder
   END           
 END            
END 
--DROP TABLE #Temp_ResultSet           
GO
