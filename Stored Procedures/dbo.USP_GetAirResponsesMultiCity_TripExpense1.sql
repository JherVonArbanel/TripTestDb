SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetAirResponsesMultiCity_TripExpense1]  
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
   @allowedOperatingAirlines varchar(500) =''  
 )  
  AS   
 SET NOCOUNT ON   
 DECLARE @FirstRec INT  
 DECLARE @LastRec INT  
  
 -- Initialize variables.  
 SET @FirstRec = (@pageNo  - 1) * @PageSize  
 SET @LastRec = (@pageNo  * @PageSize + 1)  

 DECLARE @airRequestKey AS int  
 Declare @airRequestType AS int    
 SET @airRequestKey =( SELECT TOP 1 airRequestKey  FROM AirSubRequest WHERE airSubRequestKey = @airSubRequestKey )  
 SET @airRequestType =( SELECT  airRequestTypeKey  FROM Airrequest WHERE airRequestKey = @airRequestKey )  
  
 DECLARE @airBundledRequest AS int   
 SET @airBundledRequest = (SELECT TOP 1 AirSubRequestKey FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = -1 )   
    
  /******/  
   
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
 airsegmentCabin varchar (20) ,segmentOrder int   
 )  
 INSERT into @AirSegments ( airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin ,segmentOrder  )  
 (SELECT airSegmentKey,SEG.airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,(case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,airSegmentMarriageGrp ,airFareBasisCode ,airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder  From AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey   
  LEFT OUTER JOIN AircraftsLookup on (seg.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)  
 WHERE airLegNumber = @airRequestTypeKey   
 AND (airSubRequestKey = @airBundledRequest or airSubRequestKey =@airSubRequestKey )    
 AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END ) )  
  
  /***code for date time offset ****/  
 DECLARE @startAirPort AS varchar(100)   
 DECLARE @endAirPort AS varchar(100)   
 SELECT  @startAirPort=  airRequestDepartureAirport ,@endAirPort=airRequestArrivalAirport FROM AirSubRequest WHERE  airSubRequestKey = @airSubRequestKey   
  
 DECLARE @superAirlines AS table ( airLineCode varchar(20))   
 DECLARE @tempResponseToRemove AS table ( airresponsekey uniqueidentifier )   
 IF ( @superSetAirlines <> '' AND @superSetAirlines is not null )  
  BEGIN  
   INSERT @superAirlines (airLineCode )   
    SELECT * FROM vault .dbo.ufn_CSVToTable (@superSetAirlines)  
   INSERT @tempResponseToRemove (airresponsekey )   
    (SELECT distinct airresponsekey FROM @AirSegments WHERE airSegmentMarketingAirlineCode not in (SELECT * FROM @superAirlines) )  
          
    IF (   @allowedOperatingAirlines <> '')  
    BEGIN  
    INSERT @tempResponseToRemove (airresponsekey )   
      (SELECT Distinct s.airResponseKey from AirSegments s inner join AirResponse resp on s.airResponseKey =resp.airResponseKey   
     inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and   
     airSegmentOperatingAirlineCode not in (SELECT * FROM vault.dbo.ufn_CSVToTable ( @allowedOperatingAirlines))   )  
         
    END  
      
  END     
 --CALCULATE DEPARTURE OFFSET     
 DECLARE @departureOffset AS float   
 SET @departureOffset =(  SELECT distinct  TOP 1  airSegmentDepartureOffset FROM AirSegments seg INNER JOIN AirResponse r ON seg.airResponseKey =r.airResponseKey  
  WHERE(  r.airSubRequestKey = @airSubRequestKey     ) AND airLegNumber =@airRequestTypeKey AND airSegmentDepartureAirport= @startAirPort AND airSegmentDepartureOffset is not null  )  
 --CALCULATE ARRIVAL OFFSET   
 DECLARE @arrivalOffset AS float   
 SET @arrivalOffset = (SELECT distinct TOP 1 airSegmentArrivalOffset  FROM AirSegments seg INNER JOIN AirResponse r ON seg.airResponseKey =r.airResponseKey  
 WHERE(  r.airSubRequestKey = @airSubRequestKey    ) AND airLegNumber = @airRequestTypeKey AND airSegmentArrivalAirport=@endAirPort AND airSegmentArrivalOffset is not null )  
  
  
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
 DECLARE @airPriceYouthForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxYouthForAnotherLeg AS FLOAT
 DECLARE @airPriceTotalForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxTotalForAnotherLeg AS FLOAT   
 DECLARE @airPriceDisplayForAnotherLeg AS FLOAT   
 DECLARE @airPriceTaxDisplayForAnotherLeg AS FLOAT   
 
 DECLARE @tmpAirline  TABLE   
  (  
  airLineCode VARCHAR (200)   
  )  
    
 IF @NoOfSTOPs = '-1' /*****Default view WHEN no of sTOPs not SELECTed *********/  
  BEGIN   
   SET @NoOfSTOPs = '0,1,2'  
  END   
 DECLARE @noSTOPs AS table ( stops int  )  
 INSERT @noSTOPs (stops )  
 SELECT * FROM vault.dbo.ufn_CSVToTable (@NoOfSTOPs)  
  
 --IF (SELECT gdsSourceKey  From AirResponse WHERE airResponseKey = @SELECTedResponseKey)  =  9    
 -- BEGIN   
 -- SET @airLines = (SELECT  DISTINCT TOP 1 airSegmentMarketingAirlineCode FROM AirSegments WHERE airResponseKey = @SELECTedResponseKey )  
 -- END   
 IF @airLines <> '' and @isIgnoreAirlineFilter <> 1    -- AND @airLines <> 'Multiple Airlines'  -- AND not exists(  SELECT @airLines WHERE @airLines like '%Multiple Airlines%')  
  BEGIN   
  INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )    
  END   
 ELSE       
  BEGIN   
  INSERT into @tmpAirline(airlineCode)  SELECT DISTINCT seg1.airSegmentMarketingAirlineCode FROM AirSegments seg1 INNER JOIN AirResponse resp  ON seg1.airResponseKey = resp.airResponseKey WHERE ( resp.airSubRequestKey = @airSubRequestKey or resp .airSubRequestKey = @airBundledRequest )  
  INSERT into @tmpAirline (airLineCode ) VALUES  ('Multiple Airlines')  
  END     
  
 DECLARE  @selectedDate AS DATETIME   
 DECLARE @multiLegPrice AS TABLE   
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
 airPriceTaxDisplay float
 )  
 IF ( @airRequestTypeKey = 1 )   
 BEGIN   
   IF ( @airLines = '' or @airLines = 'Multiple Airlines' )   
   BEGIN   
    INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay,airPriceTaxDisplay )  
    SELECT    ( MIN(airPriceBAse  )), 
			  (SELECT MIN ( airpriceTax) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse  )
			   and  ISNULL(r.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(r.gdsSourceKey ,2) ELSE @gdssourcekey END ) ),
			   ( MIN(airPriceBaseSenior  )), 
			  (SELECT MIN ( airpriceTaxSenior) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseSenior =  MIN(resp.airPriceBaseSenior  )
			   and  ISNULL(r.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(r.gdsSourceKey ,2) ELSE @gdssourcekey END ) ),
			   ( MIN(airPriceBaseChildren )), 
			  (SELECT MIN ( airpriceTaxChildren) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseChildren =  MIN(resp.airPriceBaseChildren  )
			   and  ISNULL(r.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(r.gdsSourceKey ,2) ELSE @gdssourcekey END ) ),
			   ( MIN(airPriceBaseInfant  )), 
			  (SELECT MIN ( airpriceTaxInfant) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfant =  MIN(resp.airPriceBaseInfant  )
			   and  ISNULL(r.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(r.gdsSourceKey ,2) ELSE @gdssourcekey END ) ),
			   ( MIN(airPriceBaseYouth )), 
			  (SELECT MIN ( airpriceTaxYouth) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseYouth =  MIN(resp.airPriceBaseYouth  )
			   and  ISNULL(r.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(r.gdsSourceKey ,2) ELSE @gdssourcekey END ) ),
			   ( MIN(AirPriceBaseTotal )), 
			  (SELECT MIN ( AirPriceTaxTotal) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and AirPriceBaseTotal =  MIN(resp.AirPriceBaseTotal  )
			   and  ISNULL(r.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(r.gdsSourceKey ,2) ELSE @gdssourcekey END ) ),
			    ( MIN(airPriceBaseDisplay )), 
			  (SELECT MIN ( airpriceTaxDisplay) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseDisplay =  MIN(resp.airPriceBaseDisplay  )
			   and  ISNULL(r.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(r.gdsSourceKey ,2) ELSE @gdssourcekey END ) )
    FROM AirResponse resp   
    inner join AirSubRequest subReq on resp.airSubRequestKey = subReq.airSubRequestKey   
    WHERE airRequestKey  = @airRequestKey  and airSubRequestLegIndex > 1 and  ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  
    and airResponseKey not in ( select airresponsekey  from @tempResponseToRemove )   
    group by resp.airSubRequestKey   
        
   END   
   ELSE   
   BEGIN  
    INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay )  
    SELECT  TOP 1    airpricebase ,airpricetax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay
    FROM AirResponse resp   
    inner join AirSubRequest subReq on resp.airSubRequestKey = subReq.airSubRequestKey   
    inner join AirSegments seg on resp.airResponseKey = seg.airResponseKey    
    inner join @tmpAirline air on seg .airSegmentMarketingAirlineCode = air.airLineCode   
    WHERE airRequestKey  = @airRequestKey   and airSubRequestLegIndex > 1  and  ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  and resp.airResponseKey not in ( select airresponsekey  
from @tempResponseToRemove )   
    order by airPriceBase ,airPriceTax  
   END   
   
   SET @airPriceForAnotherLeg = (SELECT SUM(Airpricebase) FROM @multiLegPrice )  
   SET @airPriceTaxForAnotherLeg = (SELECT SUM(airPriceTax) FROM @multiLegPrice )  
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
  
    IF   @SelectedResponseKey  is not null and @SelectedResponseKey <> '{00000000-0000-0000-0000-000000000000}'    
     BEGIN  
     IF ( SELECT AirSubRequestKey FROM AirResponse WHERE  airResponseKey = @SELECTedResponseKey ) <>  @airBundledRequest   
      BEGIN  
        
       INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKey ,@SELECTedFareType)  
      END  
     ELSE   
     BEGIN  
     --if (SELECT COUNT(*)   From NormalizedAirResponses WHERE airsubrequestkey = @airSubRequestKey ) > 0   
     --begin   
        
      INSERT @SELECTedResponse (responsekey,fareType )   (SELECT TOP 1  airResponseKey,@SELECTedFareType  FROM  NormalizedAirResponses n inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  WHERE airRequestKey = @airRequestKey and  airSubRequestLegIndex = 1 and flightNumber =(SELECT flightnumber FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey  and airLegNumber =1 )   AND AIRLINES = (SELECT airlines FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKey and airLegNumber =1 ) )  
     --END   
     --ELSE   
     --begin    
     --INSERT @SELECTedResponse (responsekey,fareType )   (SELECT   @SELECTedResponseKey,@SELECTedFareType  )  
     --END   
     END   
     SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM AirSegments WHERE airResponseKey = @SELECTedResponseKey AND airLegNumber =(@airRequestTypeKey-1) )  
    END   
  
    IF @airRequestTypeKey = 3   
    BEGIN    
     IF @SELECTedResponseKeySecond is null or @SELECTedResponseKeySecond ='{00000000-0000-0000-0000-000000000000}'    
     BEGIN  
      SET  @SELECTedResponseKeySecond = @SELECTedResponseKey   
     END   
    END   
    IF   @SELECTedResponseKeySecond is not null or @SELECTedResponseKeySecond <> '{00000000-0000-0000-0000-000000000000}'    
    BEGIN  
     IF ( SELECT AirSubRequestKey FROM AirResponse WHERE  airResponseKey = @SELECTedResponseKeySecond  ) <>  @airBundledRequest   
      BEGIN   
       INSERT @SELECTedResponse (responsekey,fareType  ) values   (@SELECTedResponseKeySecond ,@SELECTedFareType)  
      END   
      ELSE   
      BEGIN  
       INSERT @SELECTedResponse (responsekey,fareType  )   (SELECT TOP 1  airResponseKey,@SELECTedFareType  FROM  NormalizedAirResponses n inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  WHERE airRequestKey = @airRequestKey and airSubRequestLegIndex = 2 and flightNumber =(SELECT flightnumber FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKeySecond  and airLegNumber =2)   AND AIRLINES = (SELECT airlines FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKeySecond and airLegNumber =2) )  
      END   
      SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM AirSegments WHERE airResponseKey = @SELECTedResponseKeySecond AND airLegNumber =(@airRequestTypeKey-1) )  
    END    
  
    IF @airRequestTypeKey = 4   
     BEGIN    
      IF @SELECTedResponseKeyThird is null or @SELECTedResponseKeyThird ='{00000000-0000-0000-0000-000000000000}'    
      BEGIN  
       SET  @SELECTedResponseKeyThird = @SELECTedResponseKey   
      END   
     END   
       
    IF   @SELECTedResponseKeyThird  is not null and @SELECTedResponseKeyThird <> '{00000000-0000-0000-0000-000000000000}'    
    BEGIN  
     IF ( SELECT AirSubRequestKey FROM AirResponse WHERE  airResponseKey = @SELECTedResponseKeyThird  ) <>  @airBundledRequest   
     BEGIN   
       INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKeyThird ,@SELECTedFareType)  
      END   
     ELSE   
     BEGIN  
       INSERT @SELECTedResponse (responsekey,fareType  )   (SELECT TOP 1  airResponseKey,@SELECTedFareType  FROM  NormalizedAirResponses n inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  WHERE airRequestKey = @airRequestKey and airSubRequestLegIndex =3 and flightNumber =(SELECT flightnumber FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKeyThird and airLegNumber =3 )   AND AIRLINES = (SELECT airlines FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKeyThird and airLegNumber =3 ) )  
     END   
     SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM AirSegments WHERE airResponseKey = @SELECTedResponseKeyThird AND airLegNumber =(@airRequestTypeKey-1) )  
    END    
  
    IF @airRequestTypeKey = 5  
    BEGIN    
     IF @SELECTedResponseKeyFourth is null or @SELECTedResponseKeyFourth ='{00000000-0000-0000-0000-000000000000}'    
     BEGIN  
      SET  @SELECTedResponseKeyFourth = @SELECTedResponseKey   
     END   
    END    
    IF   @SELECTedResponseKeyFourth is not null and @SELECTedResponseKeyFourth  <> '{00000000-0000-0000-0000-000000000000}'    
    BEGIN  
     IF ( SELECT AirSubRequestKey FROM AirResponse WHERE  airResponseKey = @SELECTedResponseKeyFourth  ) <>  @airBundledRequest    
     BEGIN   
      INSERT @SELECTedResponse (responsekey,fareType  ) values (@SELECTedResponseKeyFourth,@SELECTedFareType )  
     END    
     ELSE   
     BEGIN  
      INSERT @SELECTedResponse (responsekey,fareType  )   (SELECT TOP 1  airResponseKey ,@SELECTedFareType FROM  NormalizedAirResponses n inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  WHERE airRequestKey = @airRequestKey and airSubRequestLegIndex =4 and flightNumber =(SELECT flightnumber FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKeyFourth and airLegNumber =4 )   AND AIRLINES = (SELECT airlines FROM NormalizedAirResponses WHERE airresponsekey = @SELECTedResponseKeyFourth and airLegNumber =4 ) )  
     END   
     SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM AirSegments WHERE airResponseKey = @SELECTedResponseKeyFourth AND airLegNumber =(@airRequestTypeKey-1) )  
    END   
      
    IF @airRequestTypeKey = 6  
    BEGIN    
     IF @SELECTedResponseKeyFourth is null or @SELECTedResponseKeyFourth ='{00000000-0000-0000-0000-000000000000}'    
     BEGIN  
      SET  @SelectedResponseKeyFifth  = @SELECTedResponseKey   
     END   
    END    
    IF   @SELECTedResponseKeyFourth is not null and @SELECTedResponseKeyFourth  <> '{00000000-0000-0000-0000-000000000000}'    
    BEGIN  
     IF ( SELECT AirSubRequestKey FROM AirResponse WHERE  airResponseKey = @SelectedResponseKeyFifth  ) <>  @airBundledRequest    
     BEGIN   
      INSERT @SELECTedResponse (responsekey,fareType  ) values (@SelectedResponseKeyFifth,@SELECTedFareType )  
     END    
     ELSE   
     BEGIN  
      INSERT @SELECTedResponse (responsekey,fareType  )   (SELECT TOP 1  airResponseKey ,@SELECTedFareType FROM  NormalizedAirResponses n inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  WHERE airRequestKey = @airRequestKey and airSubRequestLegIndex =5 and flightNumber =(SELECT flightnumber FROM NormalizedAirResponses WHERE airresponsekey = @SelectedResponseKeyFifth and airLegNumber =5 )   AND AIRLINES = (SELECT airlines FROM NormalizedAirResponses WHERE airresponsekey = @SelectedResponseKeyFifth and airLegNumber =5 ) )  
     END   
     SET @selectedDate = ( SELECT MAX (airSegmentArrivalDate  )   FROM AirSegments WHERE airResponseKey = @SELECTedResponseKeyFourth AND airLegNumber =(@airRequestTypeKey-1) )  
    END   
  
   DECLARE @SELECTedFareTypeTable as table (  
   fareLegIndex int identity (1,1),  
   fareType varchar(20)  
   )  
   INSERT @SELECTedFareTypeTable ( fareType )(SELECT * FROM vault.dbo.ufn_CSVToTable ( @SELECTedFareType ) )  
  
   UPDATE @SELECTedResponse SET fareType = fare.fareType FROM @SELECTedResponse sResponse  inner join @SELECTedFareTypeTable fare on sResponse .legIndex =fare.fareLegIndex   
   IF ( @airLines = '' or @airLines = 'Multiple Airlines' )   
    BEGIN    
      
     --INSERT @multiLegPrice (airPriceBase,airPriceTax  )  
 
     --SELECT    ( MIN(airPriceBAse  )), (SELECT MIN ( airpriceTax) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse  ) )  FROM AirResponse resp   
     --inner join AirSubRequest subReq on resp.airSubRequestKey = subReq.airSubRequestKey   
       INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay )  
     SELECT    ( MIN(airPriceBase  )), (SELECT MIN ( airpriceTax) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse)),
      ( MIN(airPriceBaseSenior  )), (SELECT MIN ( airpriceTaxSenior) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseSenior =  MIN(resp.airPriceBaseSenior)),
        ( MIN(airPriceBaseChildren  )), (SELECT MIN ( airpriceTaxChildren)FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseChildren =  MIN(resp.airpriceBaseChildren)) ,
        ( MIN(airPriceBaseInfant  )), (SELECT MIN ( airpriceTaxInfant)FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfant =  MIN(resp.airPriceBAseInfant ) ) ,
        ( MIN(airPriceBaseYouth  )), (SELECT MIN ( airpriceTaxYouth)FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseYouth =  MIN(resp.airPriceBAseyouth ) ) ,
        ( MIN(AirPriceBaseTotal  )), (SELECT MIN ( AirPriceTaxTotal) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and AirPriceBaseTotal =  MIN(resp.AirPriceBaseTotal ) ),
        ( MIN(airPriceBaseDisplay  )), (SELECT MIN ( airpriceTaxDisplay) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseDisplay =  MIN(resp.airpriceBaseDisplay ) )
        FROM AirResponse resp   
     inner join AirSubRequest subReq on resp.airSubRequestKey = subReq.airSubRequestKey  
     WHERE airRequestKey  = @airRequestKey  and airSubRequestLegIndex > @airRequestTypeKey  
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
     airPriceTax ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay  FROM AirResponse resp  
     inner join @SELECTedResponse SELECTed   
     on resp .airResponseKey = SELECTed .responsekey   
     
     ----update @multiLegPrice set airPriceBaseDisplay=airPriceBase,airPriceTaxDisplay=airPriceTax
    END   
    ELSE   
    BEGIN  
    
    
     INSERT @multiLegPrice (airPriceBase,airPriceTax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay )  
     SELECT    ( MIN(airPriceBase  )), (SELECT MIN ( airpriceTax) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBase =  MIN(resp.airPriceBAse)),
      ( MIN(airPriceBaseSenior  )), (SELECT MIN ( airpriceTaxSenior) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseSenior =  MIN(resp.airPriceBaseSenior)),
        ( MIN(airPriceBaseChildren  )), (SELECT MIN ( airpriceTaxChildren)FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseChildren =  MIN(resp.airpriceBaseChildren)) ,
        ( MIN(airPriceBaseInfant  )), (SELECT MIN ( airpriceTaxInfant)FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseInfant =  MIN(resp.airPriceBAseInfant ) ) ,
        ( MIN(airPriceBaseYouth  )), (SELECT MIN ( airpriceTaxYouth)FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airPriceBaseYouth =  MIN(resp.airPriceBAseyouth ) ) ,
        ( MIN(AirPriceBaseTotal  )), (SELECT MIN ( AirPriceTaxTotal) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and AirPriceBaseTotal =  MIN(resp.AirPriceBaseTotal ) ),
        ( MIN(airPriceBaseDisplay  )), (SELECT MIN ( airpriceTaxDisplay) FROM AirResponse r  WHERE r.airSubrequestkey = resp.airsubrequestkey and airpriceBaseDisplay =  MIN(resp.airpriceBaseDisplay ) )
        FROM AirResponse resp   
     inner join AirSubRequest subReq on resp.airSubRequestKey = subReq.airSubRequestKey   
     inner join AirSegments seg on resp.airResponseKey = seg.airResponseKey    
     WHERE airRequestKey  = @airRequestKey  and airSubRequestLegIndex > @airRequestTypeKey and seg.airSegmentMarketingAirlineCode =@airLines   
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
     airPriceTax   ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal ,airPriceBaseDisplay,airPriceTaxDisplay 
     FROM AirResponse resp  
     inner join @SELECTedResponse SELECTed   
     on resp .airResponseKey = SELECTed .responsekey   
    END   
   --- WHERE resp.airResponseKey = @SELECTedResponseKey   
  
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
 END   
 
 
  /**pricing logic ends here .**/  
 /**** flitering logic start **/  
 ---creating table variable for container for flitered result ..  
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
  totalCost float ,airSegmentOperatingFlightNumber int,otherlegtax float   
 )  
    
     
     
  DECLARE @AllOneWayResponses  AS table   
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
  airsubRequestkey int ,  
  airpriceTotal float ,   
  otherLegprice float , cabinclass varchar(50),otherlegtax float    
  )      
        
 DECLARE @tempOneWayResponses AS table   
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
  airsubRequestkey int ,  
  airpriceTotal float,  
  otherlegprice float ,cabinclass varchar(50) ,otherlegtax float    
  
  )  
     
 IF ( @airRequestTypeKey = 1)   
 BEGIN   

 INSERT @AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  )  
 SELECT resp.airresponsekey, (airPriceBase   ),
 airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal, airPriceBaseDisplay, airPriceTaxDisplay,flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax ) ,airPriceBase + airPriceTax ,n.cabinclass    
 From NormalizedAirResponses n inner join AirResponse resp on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey =@airBundledRequest      and airlegnumber = @airRequestTypeKey    
 and ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey ,2) ELSE @gdssourcekey END )  


 /***Delete responses which are not available in respective one way responses AS fare buckets are applicable for one way logic  **/   
  IF ( @airBundledRequest is not null )   
  BEGIN   
   IF (SELECT COUNT(*)   From NormalizedAirResponses WHERE airsubrequestkey = @airSubRequestKey ) > 0   
    delete FROM @AllOneWayResponses WHERE airOneResponsekey in (  
    SELECT n.airresponsekey From NormalizedAirResponses n  
    INNER JOIN AirResponse resp ON n.airresponsekey =resp.airResponseKey   
    WHERE resp.airsubrequestkey = @airBundledRequest AND resp.gdsSourceKey = 2  AND airLegNumber =@airRequestTypeKey AND flightNumber not in (  
    SELECT flightNumber From NormalizedAirResponses WHERE airsubrequestkey = @airSubRequestKey))   
      
        
  END   
    /***Delete all other airlines other than filter airlines**/  
    IF @gdssourcekey = 9   
    BEGIN   
  IF(@airLines <> 'Multiple Airlines')  
   BEGIN  
   delete from @AllOneWayResponses where airOneResponsekey in (  
   select distinct seg.airResponseKey   FROM AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey   
   INNER JOIN AirSubRequest subrequest ON resp.airSubRequestKey = subrequest .airSubRequestKey and seg.airSegmentMarketingAirlineCode not in (select * From @tmpAirline )   
   WHERE   airrequestKey = @airRequestKey    AND gdsSourceKey = @gdssourcekey  AND airLegNumber =@airRequestTypeKey)   
  END  
  END   
 END   
 ELSE  
 BEGIN    
  DECLARE @isPure AS int   
  SET  @isPure =(SELECT count(distinct airSegmentMarketingAirlineCode) FROM airsegments WHERE airresponsekey =@SELECTedResponseKey)  
  --IF @airLegNumber = 2 /**Round trip or 1st basic validation for 2nd leg */  
  --BEGIN  
  DECLARE @valid AS TABLE ( airResponsekey uniqueidentifier )   
    
  SET @gdssourcekey = ( SELECT distinct gdssourcekey FROM AirResponse WHERE airResponseKey = @SELECTedResponseKey )           
  
  
  IF (SELECT COUNT(*) FROM @SELECTedResponse SELECTed INNER JOIN AirResponse resp  ON SELECTed .responsekey = resp.airResponseKey WHERE gdsSourceKey = 9 )   = 0   
  BEGIN  
   IF ( @SELECTedFareType = '') /*No bucket SELECTed */  
   BEGIN  
    INSERT @valid ( airResponsekey )   
    ( SELECT * FROM ufn_GetValidResponsesForMultiCity   (@airRequestTypeKey  ,@airBundledRequest   , @SELECTedResponseKey   ,@SELECTedResponseKeySecond   ,@SELECTedResponseKeyThird   ,@SELECTedResponseKeyFourth ,@SelectedResponseKeyFifth  ))  
   END   
  END   
    
  INSERT @AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal ,cabinclass  )  
       SELECT distinct resp.AirResponsekey, (airPriceBase    ) ,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth,airPriceTaxYouth,AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay,N.flightNumber ,N.airlines,resp.airSubRequestKey,airPriceTax ,airPriceBase + airPriceTax ,n.cabinclass  
       FROM AirResponse resp  
       INNER JOIN NormalizedAirResponses n ON resp.airresponsekey = n.airresponsekey  
       INNER JOIN @valid valid ON resp.airResponseKey = valid .airResponsekey  
  AND ISNULL(resp.gdsSourceKey,2) =( Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END ) AND N .airLegNumber = @airRequestTypeKey  
    
  
   declare @isSouthWestPresent as bit   
     
   IF ( select COUNT (*) from  airsegments seg inner join @SELECTedResponse s on seg.airResponseKey =s.responsekey and airSegmentMarketingAirlineCode ='WN' ) > 0    
  BEGIN   
   SET @isSouthWestPresent = 1   
  END   
  ELSE   
  BEGIN   
   SET @isSouthWestPresent = 0   
  END   
    
  IF  @isSouthWestPresent =1   
  BEGIN   
  DELETE FROM @AllOneWayResponses WHERE airOneResponsekey in (Select distinct airresponsekey from  AirSegments where airSegmentMarketingAirlineCode <> 'WN')  
  END  
  ELSE   
  BEGIN   
  DELETE FROM @AllOneWayResponses WHERE airOneResponsekey in (Select distinct airresponsekey from  AirSegments where airSegmentMarketingAirlineCode = 'WN')  
  END  
 /***Delete all other airlines other than filter airlines**/  
  --      IF @gdssourcekey =9   
  --      BEGIN    
  --IF(@airLines <> 'Multiple Airlines')  
  --BEGIN  
  -- delete from @AllOneWayResponses where airOneResponsekey in (  
  -- select distinct seg.airResponseKey   FROM AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey   
  -- INNER JOIN AirSubRequest subrequest ON resp.airSubRequestKey = subrequest .airSubRequestKey and seg.airSegmentMarketingAirlineCode not in (select * From @tmpAirline )   
  -- WHERE   airrequestKey = @airRequestKey    AND gdsSourceKey = @gdssourcekey)  
  --END  
  --END  
 END   
   
  
/***getting valid one ways ***/  
 DECLARE @noOfLegsForRequest AS int   
 SET @noOfLegsForRequest =( SELECT COUNT(*) FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex > 0 )   
  
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
   
 IF ( @validOneWays =1 ) /**checking for all leg one way prices are available*/  
 BEGIN   
   
  IF ( @airRequestTypeKey > 1 )   
  BEGIN   
   
    INSERT @AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax  )  
    SELECT resp.airresponsekey, (airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  ),
	(airPriceBaseSenior + ISNULL(@airPriceSeniorForAnotherLeg,0)  ),(airPriceTaxSenior + ISNULL(@airPriceTaxSeniorForAnotherLeg,0)),
	(airPriceBaseChildren + ISNULL(@airPriceChildrenForAnotherLeg,0)  ),(airPriceTaxChildren + ISNULL(@airPriceTaxChildrenForAnotherLeg,0)),
	(airPriceBaseInfant + ISNULL(@airPriceInfantForAnotherLeg,0)  ),(airPriceTaxInfant + ISNULL(@airPriceTaxInfantForAnotherLeg,0)),
	(airPriceBaseYouth + ISNULL(@airPriceYouthForAnotherLeg,0)  ),(airPriceTaxYouth + ISNULL(@airPriceTaxYouthForAnotherLeg,0)),
	(AirPriceBaseTotal + ISNULL(@airPriceTotalForAnotherLeg,0)  ),(AirPriceTaxTotal + ISNULL(@airPriceTaxTotalForAnotherLeg,0)),
	(airPriceBaseDisplay + ISNULL(@airPriceDisplayForAnotherLeg,0)  ),(airPriceTaxDisplay + ISNULL(@airPriceTaxDisplayForAnotherLeg,0)),
    flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL
	(@airPriceTaxForAnotherLeg,0)), case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,N.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  
   From NormalizedAirResponses n inner join AirResponse resp on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   
   and ISNULL(resp.gdsSourceKey,2) = (Case WHEN @gdssourcekey = 0 THEN ISNULL(resp.gdsSourceKey,2) ELSE @gdssourcekey END )  
    IF  @isSouthWestPresent =1   
  BEGIN   
  DELETE FROM @AllOneWayResponses WHERE airOneResponsekey in (Select distinct airresponsekey from  AirSegments where airSegmentMarketingAirlineCode <> 'WN')  
  END  
  ELSE   
  BEGIN   
  DELETE FROM @AllOneWayResponses WHERE airOneResponsekey in (Select distinct airresponsekey from  AirSegments where airSegmentMarketingAirlineCode = 'WN')  
  END  
   END   
  ELSE   
  BEGIN  
   IF @gdssourcekey =  0 or @gdssourcekey <> 9  
   BEGIN  
     
      
    --SET @airPriceForAnotherLeg =  (SELECT TOP 1 airPriceBase  FROM AirResponse WHERE airSubRequestKey = (@airSubRequestKey + 1) and gdsSourceKey = 2 order by airPriceBase )  
    --Set @airPriceTaxForAnotherLeg =(  SELECT TOP 1 airPriceTax   FROM AirResponse WHERE airSubRequestKey = (@airSubRequestKey + 1) and  gdsSourceKey = 2 order by airPriceBase )  
  
       
     IF ( @airPriceForAnotherLeg is not null AND @airPriceForAnotherLeg > 0 AND (@airRequestType >= 2 )    )   
    BEGIN  
     update @AllOneWayResponses SET otherLegprice = case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,otherlegtax =isnull(@airPriceTaxForAnotherLeg,0
)  

     INSERT @AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
		airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax   )  
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
      flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  
     From NormalizedAirResponses n inner join AirResponse resp on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   
     and gdsSourceKey <> 9  
   END  
    ELSE IF    (@airRequestType=1  )  
    BEGIN   
    update @AllOneWayResponses SET otherLegprice = case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END ,otherlegtax =isnull(@airPriceTaxForAnotherLeg,0)
      
     INSERT @AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior ,airOnePriceTaxSenior, airOnePriceBaseChildren ,airOnePriceTaxChildren ,airOnePriceBaseInfant, airOnePriceTaxInfant,airOnePriceBaseYouth, airOnePriceTaxYouth, airOnePriceBaseTotal, airOnePriceTaxTotal,airOnePriceBaseDisplay, airOnePriceTaxDisplay,
		airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice ,cabinclass ,otherlegtax   )  
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
     flightNumber,airlines,resp .airSubRequestKey ,(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)),(airPriceBase + ISNULL(@airPriceForAnotherLeg,0)  )+(airPriceTax + ISNULL(@airPriceTaxForAnotherLeg,0)) , case when @isTotalPriceSort = 0 THEN  ISNULL(@airPriceForAnotherLeg,0) else( isnull(@airPriceForAnotherLeg ,0) + isnull(@airPriceTaxForAnotherLeg,0) ) END,n .cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  From NormalizedAirResponses n inner join AirResponse resp on n.airresponsekey = resp.airResponseKey WHERE resp.airSubRequestKey = @airSubRequestKey   
     and gdsSourceKey <> 9  
    END  
   END   
   IF @gdssourcekey = 0 or @gdssourcekey = 9  
   BEGIN  
    DECLARE @farelogixairlineLowest AS table (airline  varchar (20) ,airpriceBase   float , airpriceTax   float,airpriceBaseSenior   float , airpriceTaxSenior   float ,airpriceBaseChildren   float , airpriceTaxChildren   float ,airpriceBaseInfant   float , airpriceTaxInfant   float ,airpriceBaseYouth   float , airpriceTaxYouth   float ,AirPriceBaseTotal   float , AirPriceTaxTotal   float ,airpriceBaseDisplay   float , airpriceTaxDisplay   float )  
    INSERT @farelogixairlineLowest   
    SELECT airLines ,sum(airPriceBase) ,sum(airPriceTax),sum(airPriceBaseSenior) ,sum(airPriceTaxSenior),sum(airPriceBaseChildren) ,sum(airPriceTaxChildren),sum(airPriceBaseInfant) ,sum(airPriceTaxInfant),sum(airPriceBaseYouth) ,sum(airPriceTaxYouth),sum(AirPriceBaseTotal) ,sum(AirPriceTaxTotal),sum(airPriceBaseDisplay) ,sum(airPriceTaxDisplay) FROM   
    (  
    SELECT airLegNumber,  SUBSTRING (airlines,1,2) airLines , MIN (airpriceBase )airpriceBase,MIN ( airpriceTax)airpriceTax ,
    MIN (airPriceBaseSenior )airpriceBaseSenior,MIN ( airpriceTaxSenior)airpriceTaxSenior ,
    MIN (airPriceBaseChildren )airPriceBaseChildren,MIN ( airPriceTaxChildren)airpriceTaxChildren  ,
    MIN (airPriceBaseInfant )airPriceBaseInfant,MIN ( airPriceTaxInfant)airPriceTaxInfant ,
    MIN (airPriceBaseYouth )airPriceBaseYouth,MIN ( airPriceTaxYouth)airPriceTaxYouth ,
    MIN (AirPriceBaseTotal )AirPriceBaseTotal,MIN ( AirPriceTaxTotal)AirPriceTaxTotal  ,
    MIN (airPriceBaseDisplay )airPriceBaseDisplay,MIN ( airPriceTaxDisplay)airPriceTaxDisplay  
    FROM NormalizedAirResponses n  
    inner join AirResponse r on n.airresponsekey= r.airResponseKey 
    inner join AirSubRequest s on r.airSubRequestKey = s.airSubRequestKey 
    WHERE airRequestKey = @airRequestKey and airLegNumber <> 1  and gdsSourceKey = 9 group by SUBSTRING (airlines,1,2) ,airLegNumber ) AS FlxPrices group by airLines   
  
    DECLARE @farelogixairline AS table (airline  varchar (20) )  
    INSERT @farelogixairline   
    SELECT * FROM [udf_GetCommonAirline] (@airRequestKey )   
  
   --SELECT SUBSTRING (airlines,1,2) , MIN (airpriceBase ),MIN ( airpriceTax)  FROM NormalizedAirResponses n  inner join AirResponse r on n.airresponsekey= r.airResponseKey inner join AirSubRequest s on r.airSubRequestKey = s.airSubRequestKey WHERE airRequestKey = @airRequestKey and airLegNumber = 2 and gdsSourceKey = 9   
   --     group by SUBSTRING (airlines,1,2)  
  
   --  SELECT SUBSTRING (airlines,1,2) , MIN (airpriceBase ),MIN ( airpriceTax)  FROM NormalizedAirResponses n  inner join AirResponse r on n.airresponsekey= r.airResponseKey inner join AirSubRequest s on r.airSubRequestKey = s.airSubRequestKey   
    INSERT @AllOneWayResponses (airOneResponsekey,airOnePriceBase,airOnePriceBaseSenior,airOnePriceTaxSenior,airOnePriceBaseChildren,airOnePriceTaxChildren,airOnePriceBaseInfant,airOnePriceTaxInfant,airOnePriceBaseYouth,airOnePriceTaxYouth,airOnePriceBaseTotal,airOnePriceTaxTotal,airOnePriceBaseDisplay,airOnePriceTaxDisplay,airSegmentFlightNumber,airSegmentMarketingAirlineCode,airsubRequestkey,airOnePriceTax ,airpriceTotal,otherLegprice,cabinclass  ,otherlegtax  )  
    SELECT resp.airresponsekey,(resp.airPriceBase + ISNULL(f.airpriceBase ,0)  ), 
    (resp.airPriceBaseSenior + ISNULL(f.airPriceBaseSenior ,0)  ),(resp.airPriceTaxSenior + ISNULL(f.airPriceTaxSenior ,0)),
    (resp.airPriceBaseChildren + ISNULL(f.airPriceBaseChildren ,0)  ),(resp.airPriceTaxChildren + ISNULL(f.airPriceTaxChildren  ,0)),
    (resp.airPriceBaseInfant + ISNULL(f.airPriceBaseInfant  ,0)  ),(resp.airPriceTaxInfant  + ISNULL(f.airPriceTaxInfant ,0)),
    (resp.airPriceBaseYouth + ISNULL(f.airPriceBaseYouth  ,0)  ),(resp.airPriceTaxYouth  + ISNULL(f.airPriceTaxYouth ,0)),
    (resp.AirPriceBaseTotal + ISNULL(f.AirPriceBaseTotal ,0)  ),(resp.AirPriceTaxTotal + ISNULL(f.AirPriceTaxTotal  ,0)),
    (resp.airPriceBaseDisplay + ISNULL(f.airPriceBaseDisplay ,0)  ),(resp.airPriceTaxDisplay + ISNULL(f.airPriceTaxDisplay  ,0)),
    flightNumber,airlines,resp .airSubRequestKey ,(resp.airPriceTax + ISNULL(f.airpriceTax  ,0)),(resp.airPriceBase + ISNULL(f.airpriceBase  ,0)  )+(resp.airPriceTax + ISNULL(f.airpriceTax,0)) ,  
     case when @isTotalPriceSort = 0 THEN  ISNULL(f.airpriceBase,0) else( isnull(f.airpriceBase ,0) + isnull(f.airpriceTax,0) ) END  
     ,n.cabinclass ,isnull(@airPriceTaxForAnotherLeg,0)  
    From NormalizedAirResponses n inner join AirResponse resp on n.airresponsekey = resp.airResponseKey   
    INNER JOIN @farelogixairline flxAirlines on flxAirlines.airline = SUBSTRING (n.airlines,1,2)  
    left outer  join @farelogixairlineLowest f on SUBSTRING(n.airlines,1,2)= f.airline   
    WHERE resp.airSubRequestKey = @airSubRequestKey   
    and gdsSourceKey = 9  
   END   
  
  END   
 END   
   
      
  /***Delete all other airlines other than filter airlines**/  
  -- IF @gdssourcekey = 9   
  -- BEGIN  
  --IF(@airLines <> 'Multiple Airlines')  
  --BEGIN  
  -- delete from @AllOneWayResponses where airOneResponsekey in (  
  -- select distinct seg.airResponseKey   FROM AirSegments seg INNER JOIN AirResponse  resp ON seg .airResponseKey = resp.airresponsekey   
  -- INNER JOIN AirSubRequest subrequest ON resp.airSubRequestKey = subrequest .airSubRequestKey and seg.airSegmentMarketingAirlineCode not in (select * From @tmpAirline )   
  -- WHERE   airrequestKey = @airRequestKey    AND gdsSourceKey = @gdssourcekey)  
  --END   
  --END   
 INSERT into @tempOneWayResponses   
 SELECT ROW_NUMBER() over (order by airpriceTotal ) AS airOneIdent , * FROM @AllOneWayResponses    
  
Delete P  
   FROM @tempOneWayResponses P  
   INNER JOIN @tempResponseToRemove T  ON P.airOneResponsekey = T.airresponsekey  
     
 delete @tempOneWayResponses  
 FROM @tempOneWayResponses t,  
 (  
  SELECT min(airOnePriceBase + airOnePriceTax) AS minPrice,MIN(airOneIdent )  AS minIdent,   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,cabinclass   
  FROM @tempOneWayResponses m  
  GROUP BY   airSegmentFlightNumber,airSegmentMarketingAirlineCode  ,cabinclass   
  having count(1) > 1  
 ) AS derived  
 WHERE t.airSegmentFlightNumber = derived.airSegmentFlightNumber AND t.airSegmentMarketingAirlineCode =derived .airSegmentMarketingAirlineCode AND isnull(t.cabinclass,'') =isnull(derived .cabinclass ,'')  
 AND (airOnePriceBase + airOnePriceTax) >= minPrice  AND airOneIdent > minIdent  
   
  
 DECLARE @normalizedResultSet   AS table   
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
 airPriceTaxDisplay float  
 )   
  
 INSERT  @normalizedResultSet (airresponsekey ,airPriceBase,noOFSTOPs ,noOfAirlines ,takeoffdate ,landingdate ,airlinecode ,gdssourcekey ,airpricetax ,airsubrequetkey ,otherlegprice,cabinclass,otherlegtax ,  airPriceBaseSenior, airPriceTaxSenior, airPriceBaseChildren,airPriceTaxChildren, airPriceBaseInfant,airPriceTaxInfant,airPriceBaseYouth, airPriceTaxYouth, airPriceBaseTotal,airPriceTaxTotal, airPriceBaseDisplay,airPriceTaxDisplay )  
 (  
  SELECT seg.airresponsekey,result.airOnePriceBaseDisplay ,CASE WHEN COUNT(seg.airresponsekey )-1  > 1 THEN 1 ELSE  COUNT(seg.airresponsekey )-1 END ,COUNT(distinct seg.airSegmentMarketingAirlineCode ),MIN(airSegmentDepartureDate ) ,MAX(airSegmentArrivalDate ), 
 
  CASE WHEN COUNT(distinct seg.airSegmentMarketingAirlineCode ) > 1 THEN 'Multiple Airlines'  ELSE MIN(seg.airSegmentMarketingAirlineCode) END ,  
  resp.gdsSourceKey, result.airOnePriceTaxDisplay ,result.airsubRequestkey ,otherlegprice ,result.cabinclass ,otherlegtax , result.airOnePriceBaseSenior, result.airOnePriceTaxSenior, result.airOnePriceBaseChildren,result.airOnePriceTaxChildren, result.airOnePriceBaseInfant,result.airOnePriceTaxInfant,result.airOnePriceBaseYouth, result.airOnePriceTaxYouth, result.airOnePriceBaseTotal,result.airOnePriceTaxTotal, result.airOnePriceBaseDisplay,result.airOnePriceTaxDisplay  
  FROM   
  @tempOneWayResponses result  INNER JOIN   
  AirResponse resp   ON resp.airResponseKey = result.airOneResponsekey   
  INNER JOIN  
  AirSegments seg   ON result .airOneResponsekey = seg.airResponseKey   
  WHERE airLegNumber = @airRequestTypeKey  
  GROUP BY seg.airResponseKey,result.airOnePriceBaseDisplay ,gdssourcekey  ,result .airOnePriceTaxDisplay , result.airsubRequestkey ,otherlegprice ,result.cabinclass ,otherlegtax,result.airOnePriceBaseSenior, result.airOnePriceTaxSenior, result.airOnePriceBaseChildren,result.airOnePriceTaxChildren, result.airOnePriceBaseInfant,result.airOnePriceTaxInfant,result.airOnePriceBaseYouth, result.airOnePriceTaxYouth, result.airOnePriceBaseTotal,result.airOnePriceTaxTotal, result.airOnePriceBaseDisplay,result.airOnePriceTaxDisplay     
  having MIN(airSegmentDepartureDate ) > ISNULL ( DATEADD (HH,1, @selectedDate ) , DATEADD(D, -1,GETDATE() ))  
 )  
  
 INSERT into @airResponseResultset (airSegmentKey , airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentFlightNumber,airSegmentDuration, airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate ,airSegmentDepartureAirport,
 airSegmentArrivalAirport,airPrice,MarketingAirlineName,NoOfSTOPs ,actualTakeOffDateForLeg,actualLandingDateForLeg ,airSegmentOperatingAirlineCode , airSegmentResBookDesigCode,noofAirlines ,airlineName , gdsSourceKey ,airPriceTax ,airRequestKey ,
 airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver,priceClassCommentsEconSaver ,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade, 
 airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice ,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,
 airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining, airPriceClassSELECTed,otherLegPrice ,isRefundable ,isBrandedFare,cabinClass ,fareType ,segmentOrder ,airsegmentCabin,totalCost,
 airSegmentOperatingFlightNumber,otherlegtax,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant, airPriceTaxInfant,airPriceBaseYouth, airPriceTaxYouth,
 AirPriceBaseTotal,AirPriceTaxTotal,airPriceBaseDisplay, airPriceTaxDisplay)  
  SELECT seg.airSegmentKey, seg.airResponseKey, seg.airLegNumber, seg. airSegmentMarketingAirlineCode ,seg. airSegmentFlightNumber, seg.airSegmentDuration , seg.airSegmentEquipment , seg.airSegmentMiles , seg.airSegmentDepartureDate ,  
  seg.airSegmentArrivalDate , seg.airSegmentDepartureAirport , seg.airSegmentArrivalAirport ,normalized .airPriceBase AS airPriceBase , airVendor.ShortName AS MarketingAirlineName ,noOFSTOPs  ,  takeoffdate  , landingdate ,airSegmentOperatingAirlineCode ,
  seg.airSegmentResBookDesigCode,noOfAirlines ,normalized .airlineCode ,ISNULL(normalized.gdssourcekey,2) ,normalized.airpriceTax  ,airsubrequetkey ,airsegmentDepartureOffset,airSegmentArrivalOffset ,airSegmentSeatRemaining,priceClassCommentsSuperSaver , 
  priceClassCommentsEconSaver,priceClassCommentsFirstFlex ,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice ,airEconSaverPrice ,airFirstFlexPrice ,airCorporatePrice ,airEconFlexPrice,airEconUpgradePrice,  
  airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining,  
  airPriceClassSELECTed ,otherlegprice ,refundable ,isBrandedFare ,normalized. cabinClass ,resp.faretype,seg.segmentOrder ,seg.airsegmentCabin,(isnull(normalized .airPriceBase,0)+ isnull(normalized.airpriceTax,0)),seg.airSegmentOperatingFlightNumber,otherlegtax ,
  normalized.airPriceBaseSenior,normalized.airPriceTaxSenior,normalized.airPriceBaseChildren,normalized.airPriceTaxChildren,normalized.airPriceBaseInfant, normalized.airPriceTaxInfant,normalized.airPriceBaseYouth, normalized.airPriceTaxYouth,normalized.AirPriceBaseTotal,normalized.AirPriceTaxTotal,normalized.airPriceBaseDisplay, normalized.airPriceTaxDisplay  
  FROM @AirSegments seg     
  INNER JOIN @normalizedResultSet normalized ON seg.airresponsekey = normalized .airresponsekey   
  INNER JOIN AirResponse resp ON seg .airresponsekey = resp.airResponseKey   
  INNER JOIN @noSTOPs nSTOP ON normalized .noOFSTOPs = nSTOP .sTOPs   
  INNER JOIN  AirVendorLookup airVendor   ON seg.airSegmentMarketingAirlineCode = airVendor  .AirlineCode    
  WHERE normalized.airPriceBase  <=    @price    
  AND ( takeoffdate    BETWEEN @minTakeOffDate AND @maxTakeOffDate    )  
  AND (  landingdate  BETWEEN @minLandingDate AND @maxLandingDate  )  

       
 DECLARE @pagingResultSet Table   
 (  
  rowNum int IDENTITY(1,1) NOT NULL,     
  airResponseKey uniqueidentifier  ,  
  airlineName varchar(100),   
  airPrice float ,   
  actualTakeOffDateForLeg datetime   
 )   
     
 IF @sortField <> ''  
 BEGIN   
  INSERT into @pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )  
  
 SELECT    air.airResponseKey ,MIN(airPrice ) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM @airResponseResultset air   
 INNER JOIN @normalizedResultSet normalized on air.airresponsekey = normalized .airresponsekey   
 INNER  JOIN @tmpAirline airline on (normalized .airlineCode  = airline.airLineCode   )   
 GROUP BY air.airResponseKey,airlineName   order by   
 CASE WHEN @sortField  = 'Price'      THEN ( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END  ) END  ,    
 CASE WHEN @sortField  = 'Airline' THEN  MIN(MarketingAirlineName)         END   ,   
 CASE WHEN @sortField  ='Departure' THEN MIN( actualTakeOffDateForLeg) END   ,  
 --CASE WHEN @sortField ='Duration' THEN MIN(duration) END ,  
 CASE WHEN @sortField  ='' THEN MIN( airPrice)  END      
   
 END   
 ELSE   
 BEGIN   
  INSERT into @pagingResultSet (airResponseKey,airPrice ,actualTakeOffDateForLeg ,airlineName    )  
   SELECT    air.airResponseKey ,MIN(airPrice ) ,MIN(actualTakeOffDateForLeg) , MIN(MarketingAirlineName)  FROM @airResponseResultset air   
   INNER JOIN @normalizedResultSet normalized ON air.airresponsekey = normalized .airresponsekey   
   INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   )   
   GROUP BY air.airResponseKey,airlineName  order by  ( case When @isTotalPriceSort = 0  then MIN( airPrice)  else MIN(totalCost ) END) ,MIN(MarketingAirlineName) , min(normalized.noOFSTOPs ),MIN( actualTakeOffDateForLeg) ,MIN( actualLandingDateForLeg )  
    
 END   
   
   
  IF ( @superSetAirlines is not null AND @superSetAirlines <> '' )  
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
 /****MAIN RESULTSET FOR LIST ****STARTS HERE *****/  
   
 SELECT distinct  rowNum,air.*, airSegmentArrivalOffset,departureAirport .CityName AS DepartureAirPortCityName ,departureAirport.StateCode AS DepartureAirportStateCode ,departureAirport .AirportName AS DepartureAirportName , departureAirport.CountryCode AS DepartureAirportCountryCode,   
 arrivalAirport .CItyName AS ArrivalAirPortCityName ,arrivalAirport .StateCode AS ArrivalAirportStateCode , arrivalAirport .AirportName AS ArrivalAirportName ,arrivalAirport .CountryCode  AS ArrivalAirportCountryCode,  
 operatingAirline .ShortName AS OperatingAirlineName  ,isRefundable ,isBrandedFare ,cabinClass    
 FROM @airResponseResultset air INNER JOIN @pagingResultSet  paging ON air.airResponseKey = paging.airResponseKey  
 LEFT OUTER JOIN AirVendorLookup operatingAirline    ON air .airSegmentOperatingAirlineCode = operatingAirline .AirlineCode   
 LEFT OUTER JOIN AirportLookup departureAirport   ON air .airSegmentDepartureAirport = departureAirport .AirportCode   
 LEFT OUTER JOIN AirportLookup arrivalAirport    ON air .airSegmentArrivalAirport =arrivalAirport .AirportCode   
 WHERE ---rowNum > @FirstRec  AND rowNum< @LastRec   AND  
 airLegNumber = CASE WHEN @airRequestTypeKey > -1 THEN @airRequestTypeKey ELSE airLegNumber END    
 order by rowNum ,airlegnumber ,segmentOrder, airSegmentDepartureDate  
   
    /****MAIN RESULTSET FOR LIST ****END HERE *****/  
    
      
    /******MIN -MAX PRICE FOR FILTERS START HERE ***/  
 IF ( @gdssourcekey =9 ) AND @airRequestTypeKey = 2   
 BEGIN  
  SELECT MIN (airPrice)  AS LowestPrice ,MAX(airPrice ) AS HighestPrice FROM @airResponseResultset  result1    
  INNER JOIN @normalizedResultSet normalized ON result1.airresponsekey = normalized .airresponsekey   
  INNER  JOIN @tmpAirline airline ON (normalized .airlineCode  = airline.airLineCode   )   
 END   
 ELSE   
 BEGIN   
    
  
  SELECT (case when @isTotalPriceSort= 0 then( MIN (airPrice) ) else  min (totalcost) end ) AS LowestPrice , (case when @isTotalPriceSort= 0 then MAX(airPrice ) else max(totalcost) end ) AS HighestPrice FROM @airResponseResultset  result1    
 END   
 /******MIN -MAX PRICE FOR FILTERS END HERE ***/  
   
 /***LANDING & TAKEOFF TIME STARTS HERE *****/  
 SELECT distinct  MIN (actualTakeOffDateForLeg ) AS MinDepartureTakeOffDate,  MAX (actualTakeOffDateForLeg) AS MaxDepartureTakeOffDate, MIN (actualLandingDateForLeg) AS MinDepartureLandingDate,  MAX (actualLandingDateForLeg) AS MaxDepartureLandingDate FROM @airResponseResultset    
 /***LANDING & TAKEOFF TIME ENDS HERE *****/  
   
 /* STOPs for Slider END */  
 SELECT distinct NoOfSTOPs AS NoOfSTOPs  FROM @airResponseResultset   
  /* STOPs for Slider END*/  
  
 /*****TOTAL RECORD FOUND *****/  
 SELECT COUNT(*) AS [TotalCount] FROM @pagingResultSet   
 /*****TOTAL RECORD FOUND *****/  
   
 IF @airLines <> '' and @isIgnoreAirlineFilter = 1    
 BEGIN  
  delete from @tmpAirline    
   INSERT into @tmpAirline(airlineCode)    SELECT * FROM vault.dbo.ufn_CSVToTable (@airLines )    
    
 END  
   
 /**** MATRIX SUMMARY STARTES HERE *****/  
 IF ( SELECT COUNT (*) FROM @tmpAirline) > 1    
 BEGIN   
    
  SELECT (case when @isTotalPriceSort = 0 then MIN(airPrice ) else min(totalcost) end ) AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode From @airResponseResultset air  
  INNER JOIN @normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
  INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode   
  LEFT OUTER JOIN AirVendorLookup vendor ON air.airlineName = vendor .AirlineCode   
  GROUP BY airlineName ,ShortName   
 END   
 ELSE   
 BEGIN    
  IF ( @gdssourcekey =9 ) AND @airRequestTypeKey = 2   
  BEGIN  
    
   SELECT (case when @isTotalPriceSort = 0 then MIN(airPrice ) else min(totalcost) end )AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode From @airResponseResultset air  
   INNER JOIN @normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
   INNER JOIN @tmpAirline tmp ON n.airlineCode = tmp.airLineCode   
   LEFT OUTER JOIN AirVendorLookup vendor ON air.airlineName = vendor.AirlineCode   
   GROUP BY airlineName ,ShortName   
  
  END   
  ELSE   
  BEGIN    
   
   SELECT (case when @isTotalPriceSort = 0 then MIN(airPrice ) else min(totalcost) end ) AS LowestPrice ,ISNULL (ShortName,'Multiple Airlines')AS MarketingAirlineName ,airlineName AS airSegmentMarketingAirlineCode From @airResponseResultset air  
   INNER JOIN @normalizedResultSet n ON air.airResponseKey = n.airresponsekey   
   LEFT OUTER JOIN AirVendorLookup vendor ON air.airlineName = vendor .AirlineCode   
   GROUP BY airlineName ,ShortName   
  END   
 END   
   
   
  DECLARE @markettingAirline AS varchar(100)   
        DECLARE @noOFDrillDownCount as int    
  IF @airRequestTypeKey > 1   
  BEGIN   
  
   IF (SELECT count(distinct (airSegmentMarketingAirlineCode ))  FROM AirSegments seg  INNER JOIN @SELECTedResponse SELECTed ON seg.airResponseKey = SELECTed .responsekey ) = 1   
   BEGIN  
      
    IF   (SELECT COUNT(*) FROM @tmpAirline) > 1   
    BEGIN  
     SET @markettingAirline  =(SELECT   distinct (airSegmentMarketingAirlineCode )   FROM AirSegments seg  INNER JOIN @SELECTedResponse SELECTed ON seg.airResponseKey = SELECTed .responsekey )    
        
    END  
    ELSE   
    BEGIN  
     SET @markettingAirline= @airLines       
    END  
       
   END   
   ELSE  
   BEGIN   
      
     
    IF ( SELECT airRequestTypeKey  FROM AirRequest WHERE airRequestKey = @airRequestKey ) >= 2   
    BEGIN  
     IF (SELECT count(distinct (airSegmentMarketingAirlineCode ))  FROM AirSegments seg  WHERE airResponseKey = @SELECTedResponseKey   ) = 1   
     BEGIN  
      IF   (SELECT COUNT(*) FROM @tmpAirline) > 1   
      BEGIN  
         
       SET @markettingAirline  =(SELECT   distinct (airSegmentMarketingAirlineCode )   FROM AirSegments seg   WHERE airResponseKey = @SELECTedResponseKey  )            
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
     
     
  SET @noOFDrillDownCount = ( SELECT top 1 COUNT(*)   FROM @airResponseResultset      air  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = @markettingAirline  )  
   END   
   ELSE   
   BEGIN   
      
   SET @noOFDrillDownCount = (SELECT top 1 COUNT(*)  FROM @airResponseResultset      air  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE   air.airlineName = 'Multiple Airlines')  
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
   IF ( @airRequestTypeKey = 1 )   
      BEGIN  
      DECLARE @seconSubRequestKey AS int   
      SET @seconSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex = 2 )  
  
      DECLARE @tmpSecondLowestPrice AS table   
      (  
      legPrice float ,  
      airline varchar(100)   
      )  
      INSERT @tmpSecondLowestPrice (legPrice ,airline   )  
      SELECT (case when @isTotalPriceSort = 0 then MIN(airPriceBAse ) else min(airPriceBase+ airpriceTax) end )  AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar   
      INNER JOIN   
      (  
       SELECT A.* FROM AirSegments A    
       Except   
       SELECT A.* FROM AirSegments A INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey  
      ) Tmp  
      ON ar.airResponseKey = Tmp.airResponseKey   
      WHERE airSubRequestKey = @seconSubRequestKey GROUP BY  airSegmentMarketingAirlineCode  
  
                         if ( select COUNT (*) from @tmpSecondLowestPrice ) = 0   
                         begin  
                         INSERT @tmpSecondLowestPrice (legPrice ,airline   )  
                         select 0 , t.airLineCode  from @tmpAirline  t  
                         end  
                           
  
   
      --(SELECT min(airPriceBAse    ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar  
      --INNER JOIN AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey   
      -- WHERE airSubRequestKey = @seconSubRequestKey GROUP BY  airSegmentMarketingAirlineCode  
  
  
      DECLARE @thirdSubRequestKey AS int   
      SET @thirdSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =3 )  
  
      DECLARE @tmpThirdLowestPrice AS table   
      (  
      thirdlegPrice float ,  
      airline varchar(100)   
      )  
      INSERT @tmpThirdLowestPrice (thirdlegPrice ,airline   )  
      --SELECT (case when @isTotalPriceSort = 0 then MIN(airPriceBAse ) else min(airPriceBase+ airpriceTax) end ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar  
      --INNER JOIN AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey   
      --WHERE airSubRequestKey = @thirdSubRequestKey GROUP BY  airSegmentMarketingAirlineCode   
        
      select    MIN ( airpricebase )  ,airline    
      from   
      (select ( case when @isTotalPriceSort = 0 then  MIN(airPriceBase ) else  MIN ( airPriceBase + airPriceTax )end ) as airpriceBAse ,   MIN( airSegmentMarketingAirlineCode ) airline   
        From AirResponse   r   
      inner join AirSegments s on r.airResponseKey =s.airResponseKey where airSubRequestKey = @thirdSubRequestKey group by s.airResponseKey    
      having  COUNT(distinct airSegmentMarketingAirlineCode ) = 1) as t   
      group by airline   
  
  
                         if ( select COUNT (*) from @tmpThirdLowestPrice ) = 0   
                         begin  
                         INSERT @tmpThirdLowestPrice (thirdlegPrice ,airline   )  
                         select 0 , t.airLineCode  from @tmpAirline  t  
                         end  
                           
      DECLARE @fourthSubRequestKey AS int   
      SET @fourthSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =4 )  
  
      DECLARE @tmpFourthLowestPrice AS table   
      (  
      fourthlegPrice float ,  
      airline varchar(100)   
      )  
      INSERT @tmpFourthLowestPrice (fourthlegPrice ,airline   )  
      --SELECT (case when @isTotalPriceSort = 0 then MIN(airPriceBAse ) else min(airPriceBAse+ airpriceTax) end ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar  
      --INNER JOIN AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey   
      --WHERE airSubRequestKey = @fourthSubRequestKey GROUP BY  airSegmentMarketingAirlineCode   
  
      select    MIN ( airpricebase )  ,airline    
      from   
      (select ( case when @isTotalPriceSort = 0 then  MIN(airPriceBase ) else  MIN ( airPriceBase + airPriceTax )end ) as airpriceBAse ,   MIN( airSegmentMarketingAirlineCode ) airline   
        From AirResponse   r   
      inner join AirSegments s on r.airResponseKey =s.airResponseKey where airSubRequestKey = @fourthSubRequestKey group by s.airResponseKey    
      having  COUNT(distinct airSegmentMarketingAirlineCode ) = 1) as t   
      group by airline   
        
        
                         if ( select COUNT (*) from @tmpFourthLowestPrice ) = 0   
                         begin  
                         INSERT @tmpFourthLowestPrice (fourthlegPrice  ,airline   )  
                         select 0 , t.airLineCode  from @tmpAirline  t  
                         end  
                           
  
      DECLARE @fifthSubRequestKey AS int   
      SET @fifthSubRequestKey =( SELECT airSubRequestKey  FROM AirSubRequest WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex =4 )  
  
      DECLARE @tmpFifthLowestPrice AS table   
      (  
      fifthlegPrice float ,  
      airline varchar(100)   
      )  
      INSERT @tmpFifthLowestPrice (fifthlegPrice ,airline   )  
      --SELECT (case when @isTotalPriceSort = 0 then MIN(airPriceBAse ) else min(airPriceBAse+ airpriceTax) end ) AS secondLegPrice,airSegmentMarketingAirlineCode FROM AirResponse ar  
      --INNER JOIN AirSegments aseg ON ar.airResponseKey = aseg.airResponseKey   
      --WHERE airSubRequestKey = @fifthSubRequestKey GROUP BY  airSegmentMarketingAirlineCode   
      select    MIN ( airpricebase )  ,airline    
      from   
      (select ( case when @isTotalPriceSort = 0 then  MIN(airPriceBase ) else  MIN ( airPriceBase + airPriceTax )end ) as airpriceBAse ,   MIN( airSegmentMarketingAirlineCode ) airline   
        From AirResponse   r   
      inner join AirSegments s on r.airResponseKey =s.airResponseKey where airSubRequestKey = @fifthSubRequestKey group by s.airResponseKey    
      having  COUNT(distinct airSegmentMarketingAirlineCode ) = 1) as t   
      group by airline   
        
        if ( select COUNT (*) from @tmpFifthLowestPrice ) = 0   
                         begin  
                         INSERT @tmpFifthLowestPrice (fifthlegPrice  ,airline   )  
                         select 0 , t.airLineCode  from @tmpAirline  t  
                         end  
  
      IF(@superSetAirlines != '' AND @superSetAirlines is not null)  
      Begin  
  
       SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights   FROM   
       (  
       SELECT min ((case when @isTotalPriceSort = 0 then r.airPriceBase else (r.airpricebase + r.airPricetax) end )   +ISNULL( legPrice,0) + ISNULL (thirdlegPrice ,0)  + ISNULL (fourthlegPrice ,0) + ISNULL (fifthlegPrice ,0)   
  
       ) AS LowestPrice  
       ,t.noOFSTOPs AS NoOFSegments,t.airlineCode  AS airSegmentMarketingAirlineCode,COUNT(distinct r.airResponseKey ) noOFFLights    
       From   
       @normalizedResultSet   t INNER JOIN   
       (  
        SELECT A.* FROM AirResponse A    
        Except   
        SELECT A.* FROM AirResponse A INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) r   
        ON t.airresponsekey = r.airResponseKey   
        INNER JOIN @tmpAirline air ON t.airlineCode = air.airLineCode   
        InNER JOIN @tmpSecondLowestPrice s ON s.airline = t.airlineCode    
        InNER   JOIN  @tmpThirdLowestPrice third ON t.airlineCode = third.airline   
        InNER   JOIN @tmpFourthLowestPrice fourth ON t.airlineCode = fourth .airline   
        InNER   JOIN @tmpFifthLowestPrice fifth ON t.airlineCode = fifth .airline   
        WHERE t.airsubrequetkey  = @airSubRequestKey AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFSTOPs   
        union   
        SELECT (case when @isTotalPriceSort = 0  Then MIN(t.airPriceBase ) else   MIN(t.airPriceBase +t.airPriceTax) end), t.noOFSTOPs,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights       
        From @normalizedResultSet   t    INNER JOIN   
        (SELECT A.* FROM AirResponse A    
        Except   
        SELECT A.* FROM AirResponse A INNER JOIN @tempResponseToRemove T ON A.airResponseKey = T.airresponsekey) r   
        ON t.airresponsekey = r.airResponseKey   
        WHERE t.airsubrequetkey  <> @airSubRequestKey  AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFSTOPs   
        union   
        SELECT (case when @isTotalPriceSort = 0  Then MIN( airPriceBase ) else   MIN( airPriceBase + airPriceTax) end), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights     From @normalizedResultSet   t    
        INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
        GROUP BY  t.noOFSTOPs   
        union   
        SELECT (case when @isTotalPriceSort = 0  Then MIN( m.airPriceBase  ) else   MIN( m.airPriceBase + m.airPriceTax) end)     AS LowestPrice,m.noOFSTOPs AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  From @normalizedResultSet   m INNER JOIN AirResponse r ON m.airresponsekey =r.airResponseKey  WHERE m.airlineCode ='Multiple Airlines'   GROUP BY m.airlineCode ,noOFSTOPs   
       ) summary1   
       LEFT OUTER  JOIN AirVendorLookup airvend ON summary1 .airSegmentMarketingAirlineCode = airvend .AirlineCode   
       GROUP BY airvend .ShortName,airSegmentMarketingAirlineCode ,NoOFSegments   
     END  
     ELSE  
     BEGIN  
         
      SELECT min( summary1 .LowestPrice) AS LowestPRice, summary1.airSegmentMarketingAirlineCode AS airSegmentMarketingAirlineCode ,NoOFSegments ,ISNULL(airvend .ShortName,airSegmentMarketingAirlineCode) AS marketingAirlineName,sum(summary1.noOFFLights) AS noOFFLights   FROM   
      (  
       SELECT min ((case when @isTotalPriceSort = 0 then r.airPriceBase else (r.airpricebase + r.airPricetax) end )   +ISNULL( legPrice,0) + ISNULL (thirdlegPrice ,0)   
       + ISNULL (fourthlegPrice ,0) + ISNULL (fifthlegPrice ,0)   
       ) AS LowestPrice  
       ,t.noOFSTOPs AS NoOFSegments,t.airlineCode  AS airSegmentMarketingAirlineCode,COUNT(distinct r.airResponseKey ) noOFFLights   From @normalizedResultSet   t INNER JOIN AirResponse r ON t.airresponsekey =r.airResponseKey   
       INNER JOIN @tmpAirline air ON t.airlineCode = air.airLineCode   
       InNER JOIN @tmpSecondLowestPrice s ON s.airline = t.airlineCode    
       InNER JOIN @tmpThirdLowestPrice third ON t.airlineCode = third.airline   
       InNER JOIN @tmpFourthLowestPrice fourth ON t.airlineCode = fourth .airline   
       InNER JOIN @tmpFifthLowestPrice fifth ON t.airlineCode = fifth .airline   
       WHERE t.airsubrequetkey  = @airSubRequestKey AND t.airlineCode <> 'Multiple Airlines' GROUP BY t.airlineCode ,t.noOFSTOPs   
       union   
       SELECT (case when @isTotalPriceSort = 0  Then MIN(t.airPriceBase ) else   MIN(t.airPriceBase +t.airPriceTax) end), t.noOFSTOPs,t.airlineCode,COUNT(distinct t.airResponseKey ) noOFFLights     From @normalizedResultSet   t    WHERE t.airsubrequetkey <> @airSubRequestKey  
       AND t.airlineCode <> 'Multiple Airlines'  GROUP BY t.airlineCode ,t.noOFSTOPs   
       union   
       SELECT (case when @isTotalPriceSort = 0  Then MIN(t.airPriceBase ) else   MIN(t.airPriceBase +t.airPriceTax) end), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights     From @normalizedResultSet   t    
       INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
       GROUP BY  t.noOFSTOPs   
       union   
       SELECT (case when @isTotalPriceSort = 0  Then MIN(m.airPriceBase ) else   MIN(m.airPriceBase +m.airPriceTax) end)     AS LowestPrice,m.noOFSTOPs AS NoOFSegments,m.airlineCode  AS airSegmentMarketingAirlineCode ,COUNT(distinct m.airResponseKey ) noOFFLights  
       From @normalizedResultSet   m INNER JOIN AirResponse r ON m.airresponsekey =r.airResponseKey  WHERE m.airlineCode ='Multiple Airlines'   GROUP BY m.airlineCode ,noOFSTOPs   
      )   
      summary1   
      LEFT OUTER  JOIN AirVendorLookup airvend ON summary1 .airSegmentMarketingAirlineCode = airvend .AirlineCode   
      GROUP BY airvend .ShortName,airSegmentMarketingAirlineCode ,NoOFSegments   
      END  
   END   
  
   ELSE IF   @airRequestTypeKey>= 1  
   BEGIN  
     SELECT ( case when @isTotalPriceSort = 0 then  MIN(airPrice ) else min ( airprice + airpricetax) end )AS LowestPrice ,NoOfSTOPs AS NoOFSegments ,airlineName AS airSegmentMarketingAirlineCode,COUNT(distinct air.airResponseKey ) noOFFLights ,
     ISNULL (ShortName,airlineName)AS MarketingAirlineName From @airResponseResultset air  
    LEFT OUTER JOIN AirVendorLookup vendor ON air.airlineName = vendor .AirlineCode   
    GROUP BY airlineName ,ShortName ,NoOfSTOPs   
    union   
    SELECT ( case when @isTotalPriceSort = 0 then  MIN(airPriceBASe ) else min ( airPriceBASe + airpricetax) end ), t.noOFSTOPs,'all',COUNT(distinct t.airResponseKey ) noOFFLights ,'all'    From @normalizedResultSet t     
    INNER JOIN @tmpAirline air ON air.airLineCode = t.airlineCode  
    GROUP BY  t.noOFSTOPs   
  
    order by   
    MarketingAirlineName  
       
      
   END   
 END   
 ELSE   
 BEGIN   
  
  IF @markettingAirline <> 'Multiple Airlines' AND @markettingAirline <> ''   
  BEGIN   
  
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end )AS LowestPrice ,NoofsTOPs AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,air.MarketingAirlineName  ,0 AS start , 6  AS endTime ,COUNT(
distinct air.airResponseKey ) noOFFLights   FROM @airResponseResultset  air INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  AND air.airlineName = @markettingAirline 
AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)  
   GROUP BY air.NoOfSTOPs ,air.airlineName  ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air 
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END)  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air  
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air 
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air  
   INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = @markettingAirline 
   AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   union   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset air  
   INNER JOIN @normalizedResultSet page ON air.airResponseKey=page.airResponseKey WHERE    page.airlineCode = @markettingAirline AND air.gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN air.gdsSourceKey ELSE @gdssourcekey END )      
   GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   --SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset   air  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE    airSegmentMarketingAirlineCode = @markettingAirline AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName   
   --order by endTime ,start    
     
      
  END   
  ELSE   
  
  BEGIN   
   SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ) AS LowestPrice ,NoofsTOPs AS NoOFSegments ,air.airlineName AS airSegmentMarketingAirlineCode ,'Multiple Airlines' AS MarketingAirlineName  ,0 AS start , 6
  AS endTime ,COUNT(distinct air.airResponseKey ) noOFFLights   FROM @airResponseResultset  air INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  <   '06:00:00.0000000'  
  AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey  END)  
  GROUP BY air.NoOfSTOPs ,air.airlineName     
  union   
  SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,6 , 8 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air 
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey   WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '06:00:00.0000000' AND '07:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0
 THEN gdsSourceKey ELSE @gdssourcekey END)  
  GROUP BY air.NoOfSTOPs ,air.airlineName    
  union   
  SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,8 , 10 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air  
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey  WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '08:00:00.0000000' AND '09:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0
 THEN gdsSourceKey ELSE @gdssourcekey END)  
  GROUP BY air.NoOfSTOPs ,air.airlineName    
  union   
  SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,10, 12 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '10:00:00.0000000' AND '11:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
  AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
  GROUP BY air.NoOfSTOPs ,air.airlineName    
  union   
  SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,12 , 14 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '12:00:00.0000000' AND '13:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
  AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
  GROUP BY air.NoOfSTOPs ,air.airlineName    
  union       
  SELECT(case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,14 , 16,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air  
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '14:00:00.0000000' AND '15:59:59.0000000' AND air.airlineName = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 
THEN gdsSourceKey ELSE @gdssourcekey END )  
  GROUP BY air.NoOfSTOPs ,air.airlineName    
  union   
  SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,16 ,18,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air 
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '16:00:00.0000000' AND '17:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
  AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
  GROUP BY air.NoOfSTOPs ,air.airlineName    
  union   
  SELECT(case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,18 , 20 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '18:00:00.0000000' AND '19:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
  AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
  GROUP BY air.NoOfSTOPs ,air.airlineName    
  union   
  SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,20 , 22 ,COUNT(distinct air.airResponseKey ) noOFFLights FROM @airResponseResultset      air 
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '20:00:00.0000000' AND '21:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
  AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
  GROUP BY air.NoOfSTOPs ,air.airlineName   
  union   
  SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,22 , 24 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset      air  
  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE  CAST (air.actualTakeOffDateForLeg  AS time )  BETWEEN '22:00:00.0000000' AND '23:59:59.0000000' AND air.airlineName = 'Multiple Airlines' 
  AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )  
  GROUP BY air.NoOfSTOPs ,air.airlineName   
  Union   
  select 0 , 0 ,  'Multiple Airlines' ,'Multiple Airlines' ,01 ,23 ,0 --for non stop   
  --union   
  --SELECT MIN (air.airPrice ),NoOfSTOPs ,air.airlineName ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset   air  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE airSegmentMarketingAirlineCode = 'Multiple Airlines' AND gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs ,air.airlineName ,air.MarketingAirlineName SELECT (case when @isTotalPriceSort = 0 then  MIN (air.airPrice ) else min (air.totalcost ) end ),NoOfSTOPs ,'Multiple Airlines' ,'Multiple Airlines' ,01 ,23 ,COUNT(distinct air.airResponseKey ) noOFFLights  FROM @airResponseResultset   air  INNER JOIN @pagingResultSet page ON air.airResponseKey=page.airResponseKey WHERE     gdsSourceKey = (CASE WHEN @gdssourcekey = 0 THEN gdsSourceKey ELSE @gdssourcekey END )      GROUP BY air.NoOfSTOPs  order by endTime ,start   
     
  END   
 END
GO
