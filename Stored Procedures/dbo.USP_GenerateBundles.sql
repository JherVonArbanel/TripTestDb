SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[USP_GenerateBundles]   
( @airsubRequestKey int )   
AS   
  
SET NOCOUNT ON   
  
   
 /***** Response time Optimization Code starts here ***/  
   
 DECLARE  @AirResponse  AS TABLE(  
 [airResponseKey] [uniqueidentifier] NOT NULL,  
 [airSubRequestKey] [int] NOT NULL,  
 [airPriceBase] [float] NOT NULL,  
 [airPriceTax] [float] NOT NULL,  
 [gdsSourceKey] [int] NULL,  
 [refundable] [bit] NULL,  
 [airClass] [varbinary](50) NULL,  
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
 [airSuperSaverFareReferenceKey] [varchar](1000) NULL,  
 [airEconSaverFareReferenceKey] [varchar](1000) NULL,  
 [airFirstFlexFareReferenceKey] [varchar](1000) NULL,  
 [airCorporateFareReferenceKey] [varchar](1000) NULL,  
 [airEconFlexFareReferenceKey] [varchar](1000) NULL,  
 [airEconUpgradeFareReferenceKey] [varchar](1000) NULL,  
 [airPriceClassSelected] [varchar](1000) NULL,  
 [airSuperSaverTax] [float] NULL,  
 [airEconSaverTax] [float] NULL,  
 [airEconFlexTax] [float] NULL,  
 [airCorporateTax] [float] NULL,  
 [airEconUpgradetax] [float] NULL,  
 [airFirstFlexTax] [float] NULL,  
 [airSuperSaverFareBasisCode] [varchar](50) NULL,  
 [airEconSaverFareBasisCode] [varchar](50) NULL,  
 [airFirstFlexFareBasisCode] [varchar](50) NULL,  
 [airCorporateFareBasisCode] [varchar](50) NULL,  
 [airEconFlexFareBasisCode] [varchar](50) NULL,  
 [airEconUpgradeFareBasisCode] [varchar](50) NULL,  
 [isBrandedFare] [bit] NULL,  
 [cabinClass] [varchar](20) NULL,  
 [fareType] [varchar](20) NULL,  
 [isGeneratedBundle] [bit] NULL,  
 [ValidatingCarrier] [varchar](3) NULL  
)   
  
INSERT INTO @Airresponse (airResponseKey,airSubRequestKey,airPriceBase,airPriceTax,gdsSourceKey,refundable,airClass ,priceClassCommentsSuperSaver,priceClassCommentsEconSaver,priceClassCommentsFirstFlex,priceClassCommentsCorporate,  
       priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice,airEconSaverPrice,airFirstFlexPrice,airCorporatePrice,airEconFlexPrice  
      ,airEconUpgradePrice,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade  
      ,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining ,airEconUpgradeSeatRemaining,airSuperSaverFareReferenceKey,airEconSaverFareReferenceKey,airFirstFlexFareReferenceKey  
      ,airCorporateFareReferenceKey,airEconFlexFareReferenceKey,airEconUpgradeFareReferenceKey,airPriceClassSelected,airSuperSaverTax,airEconSaverTax,airEconFlexTax        
      ,airCorporateTax,airEconUpgradetax,airFirstFlexTax,airSuperSaverFareBasisCode,airEconSaverFareBasisCode,airFirstFlexFareBasisCode ,airCorporateFareBasisCode,airEconFlexFareBasisCode,airEconUpgradeFareBasisCode,isBrandedFare,cabinClass,fareType,isGeneratedBundle ,ValidatingCarrier)  
        
      (  
     SELECT airResponseKey,airSubRequestKey,airPriceBase,airPriceTax,gdsSourceKey,refundable,airClass ,priceClassCommentsSuperSaver,priceClassCommentsEconSaver,priceClassCommentsFirstFlex,priceClassCommentsCorporate,  
       priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice,airEconSaverPrice,airFirstFlexPrice,airCorporatePrice,airEconFlexPrice  
      ,airEconUpgradePrice,airClassSuperSaver,airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade  
      ,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining ,airEconUpgradeSeatRemaining,airSuperSaverFareReferenceKey,airEconSaverFareReferenceKey,airFirstFlexFareReferenceKey  
      ,airCorporateFareReferenceKey,airEconFlexFareReferenceKey,airEconUpgradeFareReferenceKey,airPriceClassSelected,airSuperSaverTax,airEconSaverTax,airEconFlexTax        
      ,airCorporateTax,airEconUpgradetax,airFirstFlexTax,airSuperSaverFareBasisCode,airEconSaverFareBasisCode,airFirstFlexFareBasisCode ,airCorporateFareBasisCode,airEconFlexFareBasisCode,airEconUpgradeFareBasisCode,isBrandedFare,cabinClass,fareType,isGeneratedBundle ,ValidatingCarrier  
  FROM  AirResponse where airSubRequestKey = @airsubRequestKey    
  )  
   
   
 DECLARE @NormalizedAirResponses AS TABLE (  
 airresponsekey uniqueidentifier NULL,  
 flightNumber varchar(100) NULL,  
 airlines varchar(100) NULL,  
 airsubrequestkey int NULL,  
 airLegNumber int NULL,  
 airLegBookingClasses varchar(50) NULL,  
 operatingAirlines varchar(200) NULL,  
 airLegConnections varchar(200) NULL,  
 cabinclass varchar(20) NULL  
)  
    
  INSERT @NormalizedAirResponses (airresponsekey,flightNumber,airlines,airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,cabinclass)  
  SELECT  airresponsekey,flightNumber,airlines,airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,cabinclass  
  FROM  NormalizedAirResponses where airSubRequestKey = @airsubRequestKey    
    
    
  DECLARE @AirSegments AS  TABLE  (  
 airSegmentKey uniqueidentifier NOT NULL,airResponseKey uniqueidentifier NOT NULL,airLegNumber int NOT NULL,airSegmentMarketingAirlineCode varchar(2) NOT NULL,airSegmentOperatingAirlineCode varchar(2) NULL,  
 airSegmentFlightNumber int NOT NULL,airSegmentDuration time(7) NULL,airSegmentEquipment nvarchar(50) NULL,airSegmentMiles int NULL,airSegmentDepartureDate datetime NOT NULL,airSegmentArrivalDate datetime NOT NULL,  
 airSegmentDepartureAirport varchar(50) NOT NULL,airSegmentArrivalAirport varchar(50) NOT NULL,airSegmentResBookDesigCode varchar(3) NULL,airSegmentDepartureOffset float NULL,  
 airSegmentArrivalOffset float NULL,airSegmentSeatRemaining int NULL,airSegmentMarriageGrp char(10) NULL,airFareBasisCode varchar(50) NULL,airFareReferenceKey varchar(400) NULL,  
 airSegmentOperatingFlightNumber int NULL,airsegmentCabin varchar(20) NULL,segmentOrder int NULL,amadeusSNDIndicator varchar(3) NULL  
)    
  
INSERT @AirSegments  (airSegmentKey,S.airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration  
  
      ,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport  
      ,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode  
      ,airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator)  
  
SELECT airSegmentKey,S.airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration  
  
      ,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport  
      ,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode  
      ,airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator  
  FROM AirSegments  S    
  INNER JOIN @AirResponse R on S.airResponseKey =R.airResponseKey   
    
    
    
   /***** Response time Optimization Code ends here ***/  
     
   /****create pivot table which will give all leg data for response in single  row ****/  
declare @pivottedResponse as Table (airresponsekey uniqueidentifier,   
oneFlight varchar(100),oneClass varchar(100),oneConnection varchar(200),oneairline varchar(200),  
secondFlight varchar(100),secondClass varchar(100),secondConnection varchar(200),secondairline varchar(200),  
thirdFlight varchar(100),thirdClass varchar(100),thirdConnection varchar(200),thirdairline varchar(200),  
fourthFlight varchar(100),fourthClass varchar(100),fourthConnection varchar(200),fourthairline varchar(200),  
fifthFlight varchar(100),fifthClass varchar(100),fifthConnection varchar(200),fifthairline varchar(200),  
sixthFlight varchar(100),sixthClass varchar(100),sixthConnection varchar(200),sixthairline varchar(200),  
airpricebase float , airpricetax float,gdssourcekey int ,validatingcarrier varchar(3)  
  
)  
  
   
      insert @pivottedResponse   
        
      select a1.airresponsekey,a1.flightnumber,a1.airlegbookingclasses,a1.airLegConnections,a1.airlines ,  
      isnull(a2.flightnumber,''),isnull(a2.airlegbookingclasses,''),isnull(a2.airLegConnections,''),isnull(a2.airlines,'') ,  
     ISNULL( a3.flightnumber,''),isnull(a3.airlegbookingclasses,''),isnull(a3.airLegConnections,''),isnull(a3.airlines,'') ,  
      ISNULL(a4.flightnumber,''),isnull(a4.airlegbookingclasses,''),isnull(a4.airLegConnections,''),isnull(a4.airlines,'') ,  
      ISNULL(a5.flightnumber,''),isnull(a5.airlegbookingclasses,''),isnull(a5.airLegConnections,''),isnull(a5.airlines,'')  ,  
     ISNULL( a6.flightnumber,''),ISNULL(a6.airlegbookingclasses,''),ISNULL(a6.airLegConnections,'') ,ISNULL ( a6.airlines,'') ,  
      airpricebase ,airpricetax,gdsSourceKey ,ISNULL(ValidatingCarrier ,'')  
        
      from  @NormalizedAirResponses a1   
      inner join @Airresponse r on a1.airresponsekey = r.airresponsekey AND a1.airlegnumber =1  
      left outer join @NormalizedAirResponses a2 on (a1.airresponsekey = a2.airresponsekey and  a2.airlegnumber=2)  
       left outer join @NormalizedAirResponses a3 on (a1.airresponsekey = a3.airresponsekey and a3.airlegnumber=3)  
        left outer join @NormalizedAirResponses a4 on (a1.airresponsekey = a4.airresponsekey and  a4.airlegnumber=4)  
         left outer join @NormalizedAirResponses a5 on (a1.airresponsekey = a5.airresponsekey and a5.airlegnumber=5)  
          left outer join @NormalizedAirResponses a6  on (a1.airresponsekey = a6.airresponsekey and a6.airlegnumber=6)  
      where      a1.airsubrequestkey = @airsubrequestkey   
  --  select * From @pivottedResponse   
   
 /*****pivotted table implementation ends here ***/  
   
 /*****Create estimation of bundles actual vs estimated ****/  
 DECLARE @estimationTable as Table (ID int identity (1,1), oneFlight int,secondFlight int ,thirdFlight int,fourthFlight int,fifthFlight int,sixthFlight int,total int ,estimated int,  
 oneClass varchar(100),oneConnection varchar(200),oneairline varchar(200),  
 secondClass varchar(100),secondConnection varchar(200),secondairline varchar(200),  
 thirdClass varchar(100),thirdConnection varchar(200),thirdairline varchar(200),  
 fourthClass varchar(100),fourthConnection varchar(200),fourthairline varchar(200),  
 fifthClass varchar(100),fifthConnection varchar(200),fifthairline varchar(200),  
 sixthClass varchar(100),sixthConnection varchar(200),sixthairline varchar(200),  
 airpricebase float , airpricetax float,gdssourcekey int,validatingcarrier varchar(3)  
  
 )  
  
 INSERT @estimationTable  
 SELECT   COUNT(distinct oneFlight ) oneflight,COUNT(distinct secondFlight ) seconndFlight,COUNT(distinct thirdFlight ) thirdflight ,  
 COUNT(distinct fourthflight)fourthFlight ,COUNT( distinct fifthflight)fifthflight , COUNT ( distinct sixthflight) sixthflight ,COUNT(airresponsekey )total,  
  
 ((case when COUNT(distinct oneFlight ) > 0 then COUNT(distinct oneFlight ) else 1 end) *   
 (case when   COUNT(distinct secondFlight )  > 0 then  COUNT(distinct secondFlight ) else 1 end ) *   
 (case when COUNT(distinct thirdFlight) > 0 then COUNT(distinct thirdFlight)else 1 end  )  *  
 (case when COUNT(distinct fourthflight) > 0 then COUNT(distinct fourthflight) else 1 end ) *   
 (case when COUNT( distinct fifthflight) > 0 then COUNT( distinct fifthflight) else 1 end ) *  
 (case when COUNT ( distinct sixthflight)>  0 then  COUNT( distinct sixthflight) else 1 end ) ) estimated ,  
 isnull(oneClass,''), isnull(oneConnection,''),isnull(oneairline ,'') ,  
 isnull(secondclass,''),isnull(secondConnection,''),ISNULL( secondairline ,''),  
 isnull(thirdClass,''),isnull(thirdConnection,''),isnull(thirdairline,'') ,    
 isnull(fourthClass,''), isnull(fourthConnection,'') ,isnull(fourthairline,''),   
 isnull(fifthClass,''), isnull(fifthconnection,''),isnull(fifthairline,'') ,  
 isnull(sixthClass,''),isnull(sixthConnection,''),isnull(sixthairline,'') ,   
 airpricebase , airpricetax,gdssourcekey ,validatingcarrier   
 FROM @pivottedResponse        
 group by  isnull(oneairline ,'') , isnull(oneClass,''), isnull(oneConnection,''),  
 ISNULL( secondairline ,''),isnull(secondclass,''),isnull(secondConnection,''),  
 isnull(thirdairline,'') ,  isnull(thirdClass,''),isnull(thirdConnection,''),  
 isnull(fourthairline,''),  isnull(fourthClass,''), isnull(fourthConnection,'') ,  
 isnull(fifthairline,'') , isnull(fifthClass,''), isnull(fifthconnection,''),  
 isnull(sixthairline,'') , isnull(sixthClass,''),isnull(sixthConnection,''),  
 airpricebase , airpricetax,gdssourcekey ,validatingcarrier  
  
 /****Bundles estimation ends here ****/  
  
 /***Delete combinations where estimated = total ,We can generate more bundles out of it . All unique combination are coverd in GDS responses ****/  
 DELETE FROM @estimationTable WHERE estimated = total   
  
 /****Check out estimation table for opportunity where we can generate more bundles **** DIff is the count of bundles we can generate out of GDS responses*****/   
 SELECT SUM(ESTIMATED ) estimated , SUM(total) as actual , (SUM( estimated)  -SUM(total) ) AS Diff   FROM @estimationTable  
 SELECT * FROM @estimationTable   
  
 /**Ends Here***/  
 Declare @estimateID as int   
 SELECT @estimateID = MIN(ID) from @estimationTable   
   
 /**** Get air request details ID , requestType ( oneqay,round,multi ) START HERE ***/  
 DECLARE @airRequestID as INT   
 SET @airRequestID = (select airRequestKey from AirSubRequest where airSubRequestKey =@airsubRequestKey )  
 DECLARE @airsubrequestCount AS INT   
 DECLARE @airRequestTypeKey AS INT   
 SET @airRequestTypeKey =( select airRequestTypeKey  from AirRequest WHERE airRequestKey = @airRequestID )  
  
 IF ( @airRequestTypeKey = 3)   
 BEGIN   
 SET @airsubrequestCount = ( Select COUNT(*) -1 from AirSubRequest where airRequestKey = (@airRequestID ))  
 END   
 ELSE IF ( @airRequestTypeKey = 2)   
 BEGIN  
 SET @airsubrequestCount = 2  
 END  
   
 /***End HERE***/   
   
 /*****ITERATE THORUGH ALL ESTIMATED COMBINATION FOR GENERATED BUNDLES WHERE WE CAN GENERATE BUNDLES******/  
  WHILE @estimateID IS NOT NULL  
    
  BEGIN  
    
   ---PRINT (@estimateID)  
   /****DELETE ALL PREVIOUS ESTIMATED COMBINATION START HERE***/  
   DELETE from @estimationTable WHERE ID < @estimateID  
    
   /***GET DETAILS FOR CURRENT ESTIMATIONID ****/  
    DECLARE @legOneAirline varchar(100), @legOneConnection varchar(100) , @legOneClass varchar(100)   
    DECLARE @legTwoAirline varchar(100), @legTwoConnection varchar(100) , @legTwoClass varchar(100)   
    DECLARE @legThreeAirline varchar(100), @legThreeConnection varchar(100) , @legThreeClass varchar(100)   
    DECLARE @legFourAirline varchar(100), @legFourConnection varchar(100) , @legFourClass varchar(100)   
    DECLARE @legFiveAirline varchar(100), @legFiveConnection varchar(100) , @legFiveClass varchar(100)   
    DECLARE @legSixAirline varchar(100), @legSixConnection varchar(100) , @legSixClass varchar(100)   
    declare @actualPriceBase float   
    declare @actualTax float   
        
      
        
   SELECT @legOneAirline =oneAirline , @legOneConnection= oneConnection , @legOneClass = oneClass ,  
   @legTwoAirline=secondAirline, @legTwoConnection =secondConnection , @legTwoClass=secondClass  ,  
   @legThreeAirline=thirdAirline, @legThreeConnection=thirdConnection , @legThreeClass =thirdClass,  
   @legFourAirline=fourthAirline, @legFourConnection =fourthConnection, @legFourClass =fourthClass,  
   @legFiveAirline=fifthairline , @legFiveConnection= fifthConnection, @legFiveClass=fifthClass,  
   @legSixAirline=sixthairline , @legSixConnection=sixthConnection , @legSixClass =sixthClass,  
   @actualPriceBase = airpricebase,   @actualTax  =airpricetax  
   FROM @estimationTable WHERE ID = @estimateID   
       
    /****DELETE ALL PREVIOUS ESTIMATED COMBINATION END HERE***/  
     
   /****GET VALID COMBINATION FOR CURRENCT ESTIMATED ROW ( airline,booking class,connections same ) START HERE******/    
   DECLARE @ResultTable as Table ( airresponseKey uniqueidentifier )   
   DELETE FROM @ResultTable    
      
   IF ( @airsubrequestCount =1 ) /***ONE WAY*****/  
   BEGIN  
    INSERT INTO @ResultTable (airresponseKey)  
  
    SELECT n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 1  and Airlines = @legOneAirline and airlegBookingClasses = @legOneClass  AND   airLegConnections =@legOneConnection   
  
   END  
   ELSE IF (@airsubrequestCount = 2 ) /***ROUND TRIP*****/  
   BEGIN  
   --print ( 'round trip')  
    insert into @ResultTable (airresponseKey)  
    (   
    select n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 1  and Airlines = @legOneAirline and airlegBookingClasses = @legOneClass  AND   airLegConnections =@legOneConnection   
  
    INTERSECT   
    select n.airresponsekey  from @NormalizedAirResponses n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 2  and Airlines = @legTwoAirline and airlegBookingClasses =@legTwoClass   AND   airLegConnections =@legTwoConnection )   
   END   
   ELSE IF ( @airsubrequestCount = 3 ) /*** 3LEG MULTICITY******/  
   BEGIN   
    insert into @ResultTable (airresponseKey)  
    (   
    select n.airresponsekey  from @NormalizedAirResponses n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 1  and Airlines = @legOneAirline  and airlegBookingClasses = @legOneClass AND airLegConnections =@legOneConnection   
  
    INTERSECT   
    select n.airresponsekey  from @NormalizedAirResponses n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 2  and Airlines = @legTwoAirline  and airlegBookingClasses =@legTwoClass AND airLegConnections =@legTwoConnection   
  
    INTERSECT   
    select n.airresponsekey  from @NormalizedAirResponses n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 3  and Airlines = @legThreeAirline and airlegBookingClasses = @legThreeClass AND airLegConnections =@legThreeConnection   
    )  
   END   
   ELSE IF ( @airsubrequestCount = 4) /*****4LEG MULTICITY******/  
   BEGIN  
    INSERT INTO @ResultTable (airresponseKey)  
    (   
    SELECT n.airresponsekey  from @NormalizedAirResponses n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 1  and Airlines = @legOneAirline and airlegBookingClasses = @legOneClass AND airLegConnections =@legOneConnection   
  
    INTERSECT   
    SELECT n.airresponsekey  from @NormalizedAirResponses n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 2  and Airlines = @legTwoAirline and airlegBookingClasses =@legTwoClass AND airLegConnections =@legTwoConnection   
  
    INTERSECT   
    SELECT n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 3  and Airlines = @legThreeAirline and airlegBookingClasses = @legThreeClass AND airLegConnections =@legThreeConnection   
  
    INTERSECT   
    SELECT n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber =4  and Airlines = @legFourAirline and airlegBookingClasses = @legFourClass AND airLegConnections =@legFourConnection   
    )   
   END  
  
   ELSE IF ( @airsubrequestCount = 5) /*****5LEG MULTICITY*****/  
   BEGIN  
    INSERT INTO @ResultTable (airresponseKey)  
    (   
    select n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 1  and Airlines = @legOneAirline and airlegBookingClasses = @legOneClass  AND   airLegConnections =@legOneConnection   
  
    INTERSECT   
    select n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 2  and Airlines = @legTwoAirline and airlegBookingClasses =@legTwoClass   AND   airLegConnections =@legTwoConnection   
  
    INTERSECT   
    select n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 3  and Airlines = @legThreeAirline and airlegBookingClasses = @legThreeClass  AND   airLegConnections =@legThreeConnection   
  
    INTERSECT   
    select n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber =4  and Airlines = @legFourAirline and airlegBookingClasses = @legFourClass  AND   airLegConnections =@legFourConnection   
    INTERSECT   
    select n.airresponsekey  from @NormalizedAirResponses  n  inner join @Airresponse r   
    ON n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber =5  and Airlines = @legFiveAirline and airlegBookingClasses = @legfiveClass  AND   airLegConnections =@legFiveConnection    
    )   
   END  
  
    ELSE IF ( @airsubrequestCount = 6) /*****6LEG MULTICITY****/  
    BEGIN  
    INSERT INTO @ResultTable (airresponseKey)  
    (       
    SELECT n.airresponsekey  FROM @NormalizedAirResponses  n  inner join @Airresponse r   
    ON (n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 1  and Airlines = @legOneAirline and airlegBookingClasses = @legOneClass  AND   airLegConnections =@legOneConnection )  
  
    INTERSECT   
    SELECT n.airresponsekey  FROM @NormalizedAirResponses  n  inner join @Airresponse r   
    ON ( n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 2  and Airlines = @legTwoAirline and airlegBookingClasses =@legTwoClass   AND   airLegConnections =@legTwoConnection )  
      
    INTERSECT   
    SELECT n.airresponsekey  FROM @NormalizedAirResponses  n  inner join @Airresponse r   
    ON (n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber = 3  and Airlines = @legThreeAirline and airlegBookingClasses = @legThreeClass  AND   airLegConnections =@legThreeConnection )  
  
    INTERSECT   
    SELECT n.airresponsekey  FROM @NormalizedAirResponses  n  inner join @Airresponse r   
    ON (n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber =4  and Airlines = @legFourAirline and airlegBookingClasses = @legFourClass  AND   airLegConnections =@legFourConnection )  
      
    INTERSECT   
    SELECT n.airresponsekey  FROM @NormalizedAirResponses  n  inner join @Airresponse r   
    ON (n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber =5  and Airlines = @legFiveAirline and airlegBookingClasses = @legfiveClass  AND   airLegConnections =@legFiveConnection  )  
    INTERSECT   
    SELECT n.airresponsekey  FROM @NormalizedAirResponses  n  inner join @Airresponse r   
    ON (n.airresponsekey =r.airResponseKey AND n.airSubrequestkey  = @airsubrequestkey AND airPriceBase =@actualPriceBase and airPriceTax =@actualTax   
    and airLegnumber =6  and Airlines = @legSixAirline and airlegBookingClasses = @legSixClass   AND   airLegConnections =@legSixConnection   )  
    )   
    END  
  
  --select * From @ResultTable  r inner join @NormalizedAirResponses n on r.airresponseKey =n.airresponsekey  order by n.airresponsekey ,airLegNumber   
    /****GET VALID COMBINATION FOR CURRENCT ESTIMATED ROW ( airline,booking class,connections same ) END HERE******/    
  
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 1 START HERE ***/  
    DECLARE @flight1 AS TABLE ( ID INT IDENTITY(1,1),     oneflight VARCHAR(50),oneairline varchar(20) )   
    IF ( @airsubrequestCount > 0)   
    INSERT @flight1   
    SELECT DISTINCT oneflight,oneairline   FROM @pivottedResponse p Inner join @ResultTable r on p.airresponsekey =r.airresponseKey   
     where  oneClass =@legOneClass AND oneairline =@legOneAirline  AND oneConnection =@legOneConnection and airpricebase =@actualPriceBase and airpricetax =@actualTax   
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 1 END HERE ***/  
      
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 2 START HERE ***/  
    DECLARE @flight2  AS TABLE ( ID INT IDENTITY(1,1),     secondFlight VARCHAR(50) ,secondairline varchar(20))   
    IF ( @airsubrequestCount > 1)   
    INSERT @flight2  
    SELECT DISTINCT secondFlight ,secondairline FROM @pivottedResponse  p Inner join @ResultTable r on p.airresponsekey =r.airresponseKey where  
    secondClass =@legTwoClass  AND secondairline =@legTwoAirline  and secondConnection =@legTwoConnection  
     and airpricebase =@actualPriceBase and airpricetax =@actualTax   
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 2 END HERE ***/  
      
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 3 START HERE ***/  
    DECLARE @flight3  AS TABLE ( ID INT IDENTITY(1,1),     thirdFlight VARCHAR(50), thirdairline varchar(20))   
    IF ( @airsubrequestCount > 2)   
    insert @flight3  
    SELECT DISTINCT thirdFlight ,thirdairline  FROM @pivottedResponse  p Inner join @ResultTable r on p.airresponsekey =r.airresponseKey  where   
    thirdClass = @legThreeClass  AND thirdairline =@legThreeAirline  and thirdConnection =@legThreeConnection   
    and airpricebase =@actualPriceBase and airpricetax =@actualTax   
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 3 END HERE ***/  
      
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 4 START HERE ***/  
    DECLARE @flight4  AS TABLE ( ID INT IDENTITY(1,1),     fourthFlight VARCHAR(50) ,fourthairline varchar(20))   
    IF ( @airsubrequestCount > 3)   
    INSERT @flight4  
    SELECT DISTINCT fourthFlight ,fourthairline  FROM @pivottedResponse  p Inner join @ResultTable r on p.airresponsekey =r.airresponseKey  where    
    fourthClass =@legFourClass  AND fourthairline=@legFourAirline and fourthConnection =  @legFourConnection   
    and airpricebase =@actualPriceBase and airpricetax =@actualTax     
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 4 END HERE ***/  
      
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 5 START HERE ***/  
    DECLARE @flight5  AS TABLE ( ID INT IDENTITY(1,1),     fifthFlight VARCHAR(50) ,fifthairline varchar(20))   
    IF ( @airsubrequestCount > 4)   
    INSERT @flight5  
    SELECT DISTINCT fifthFlight,fifthairline    FROM @pivottedResponse  p Inner join @ResultTable r on p.airresponsekey =r.airresponseKey  where    
    fifthClass  =@legFiveClass   AND fifthairline=@legFiveAirline and fifthConnection =  @legfiveConnection   
    and airpricebase =@actualPriceBase and airpricetax =@actualTax   
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 5 END HERE ***/  
      
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 6 START HERE ***/  
    DECLARE @flight6 AS TABLE ( ID INT IDENTITY(1,1),     sixthFlight VARCHAR(50),sixthairline varchar(20) )   
    IF ( @airsubrequestCount > 5)   
    INSERT @flight6  
    SELECT DISTINCT sixthFlight,sixthairline    FROM @pivottedResponse  p Inner join @ResultTable r on p.airresponsekey =r.airresponseKey  where    
    sixthClass  =@legSixClass   AND sixthairline=@legSixAirline and sixthConnection =  @legSixConnection   
    and airpricebase =@actualPriceBase and airpricetax =@actualTax   
      
    /***GET DISTINCT FLIGHT NUMBER FOR LEG 6 START HERE ***/  
      
    /****** GENERATE COMBINATIONS  OUT OF @flight1,@flight2 ,@flight3,@flight4,@flight5,@flight6 Data (Total COMBINATIONS =@flight1*@flight2*@flight3*@flight4*@flight5*@flight6 )****/  
    DECLARE @flightNum1 VARCHAR ( 50 )  
    DECLARE @airline1 varchar( 20)  
    DECLARE @one Varchar(20)    
    SELECT @one = MIN( ID ) FROM @flight1   
    DECLARE @estimatedCombination AS TABLE (ID INT IDENTITY (1,1), oneflight VARCHAR(50) default '',oneairline varchar(20)default '',secondflight VARCHAR(50)default '',secondairline VARCHAR(20)default '' ,thirdFlight VARCHAR(50)default '',thirdairline VARCHAR(20)default '',fourthflight VARCHAR(50)default '' ,fourthAirline VARCHAR(20)default '',fifthFlight varchar(50)default '',fifthairline varchar(20)default '',sixthflight varchar(50)default '',sixthairline varchar(20)default '')  
  
    /******ITERATE THROUGH @flight1,@flight2 ,@flight3,@flight4,@flight5,@flight6  for INSERTING INTO ESTIMATEDCOMBINATION START HERE*****/  
    WHILE @one is not null  
    BEGIN  
     SELECT @flightNum1 =oneflight , @airline1= oneairline  FROM @flight1 WHERE ID = @one  
     DECLARE @flightNum2 VARCHAR ( 50 )  
     DECLARE @airline2 VARCHAR(20)  
     DECLARE @two Varchar(20)  
       
     SELECT @two = MIN( ID ) FROM @flight2     
      IF ( @airsubrequestCount =1 )   
        INSERT @estimatedCombination (oneflight,oneairline ) values  ( @flightNum1 ,@airline1    )    
      WHILE @two is not null  
      BEGIN  
       SELECT @flightNum2 =secondflight ,@airline2 =secondairline  FROM @flight2 WHERE ID = @two  
       DECLARE @flightNum3 VARCHAR ( 50 )  
       DECLARE @airline3 VARCHAR(20)  
       DECLARE @three Varchar(20)  
       SELECT @three = MIN( ID ) FROM @flight3     
          
        IF ( @airsubrequestCount = 2 )   
       INSERT @estimatedCombination (oneflight,oneairline ,secondflight,secondairline) values  ( @flightNum1,@airline1  ,@flightNum2 ,@airline2   )   
       WHILE @three is not null  
       BEGIN  
         -- print ('test3')  
        SELECT @flightNum3 =thirdFlight,@airline3 =thirdairline   FROM @flight3 WHERE ID = @three  
        DECLARE @flightNum4 VARCHAR ( 50 )  
        DECLARE @airline4 VARCHAR(20)  
        DECLARE @four Varchar(20)  
        SELECT @four = MIN( ID ) FROM @flight4     
         IF ( @airsubrequestCount =3 )   
           
         INSERT @estimatedCombination (oneflight,oneairline,secondflight,secondairline,thirdFlight,thirdairline) values  ( @flightNum1 ,@airline1 ,@flightNum2,@airline2,@flightNum3,@airline3   )   
            
           
        WHILE @four is not null  
        BEGIN  
           
        SELECT @flightNum4 =fourthFlight ,@airline4 =fourthairline  FROM @flight4 WHERE ID = @four  
           
        DECLARE @flightNum5 VARCHAR ( 50 )  
        DECLARE @airline5 VARCHAR( 20)  
        DECLARE @five Varchar(20)  
        SELECT @five = MIN( ID ) FROM @flight5     
         IF ( @airsubrequestCount = 4 )   
           
         INSERT @estimatedCombination (oneflight,oneairline ,secondflight,secondairline,thirdFlight,thirdairline ,fourthflight ,fourthAirline) values  ( @flightNum1,@airline1 ,@flightNum2,@airline2,@flightNum3,@airline3 ,@flightNum4 ,@airline4  )   
            
           
        WHILE ( @five  is not null AND @five !='')  
        BEGIN  
          -- print ('test4')  
         SELECT @flightNum5 =fifthFlight,@airline5= fifthairline  FROM @flight5 WHERE ID = @five  
         IF  ( @airsubrequestCount = 5)   
         INSERT @estimatedCombination (oneflight,oneairline ,secondflight,secondairline ,thirdFlight,thirdairline ,fourthflight,fourthAirline ,fifthFlight,fifthairline )  values  ( @flightNum1,@airline1 ,@flightNum2,@airline2,@flightNum3,@airline3 ,@flightNum4,@airline4 ,@flightNum5 ,@airline5)   
          DECLARE @flightNum6 VARCHAR ( 50 )  
          DECLARE @airline6 VARCHAR ( 20)  
          DECLARE @six Varchar(20)  
          SELECT @six= MIN( ID ) FROM @flight6    
           WHILE (@six is not null AND @six !='')  
           BEGIN  
           --  print ('test6')  
            SELECT @flightNum6 =sixthFlight ,@airline6=sixthairline FROM @flight6 WHERE ID = @six  
            INSERT @estimatedCombination (oneflight,oneairline,secondflight,secondairline,thirdFlight,thirdairline,fourthflight,fourthAirline ,fifthFlight,fifthairline, sixthflight ,sixthairline )  values   
             ( @flightNum1,@airline1 ,@flightNum2,@airline2,@flightNum3,@airline3 ,@flightNum4,@airline4 ,@flightNum5,@airline5 ,@flightNum6,@airline6 )   
  
            SELECT @six = MIN( ID ) FROM @flight6 WHERE ID > @six  
           END  
          SELECT @five = MIN( ID ) FROM @flight5 WHERE ID > @five  
        END  
          
         SELECT @four = MIN( ID ) FROM @flight4 WHERE ID > @four  
        END  
  
        SELECT @three = MIN( ID ) FROM @flight3 WHERE ID > @three  
       END  
  
      SELECT @two = MIN( ID ) FROM @flight2 WHERE ID > @two  
      END  
     SELECT @one = MIN( ID ) FROM @flight1 WHERE ID > @one  
       
    END  
    /******ITERATE THROUGH @flight1,@flight2 ,@flight3,@flight4,@flight5,@flight6  for INSERTING INTO ESTIMATEDCOMBINATION START HERE*****/  
      
    /*****CLEAR @flight1,@flight2 ,@flight3,@flight4,@flight5,@flight6 TABLES AFTER WORK DONE START HERE****/  
    --SELECT * FROM @flight1   
    --SELECT * FROM @flight2  
    --SELECT * FROM @flight3   
    --SELECT * FROM @flight4  
    --SELECT * FROM @flight5  
    --SELECT * FROM @flight6  
      
    DELETE FROM @flight1   
    DELETE FROM @flight2   
    DELETE FROM @flight3   
    DELETE FROM @flight4   
    DELETE FROM @flight5   
    DELETE FROM @flight6   
      
    -- SELECT * FROM @estimatedCombination   
    -- SELECT 1  
      
    --SELECT *  FROM @estimatedCombination e   
       
    -- inner join @pivottedResponse p on (  
    -- (e.oneflight = p.oneFlight AND e.oneAirline = p.oneAirline  )   
    -- AND (e.secondflight =p.secondFlight AND e.secondairline = p.secondAirline)  
    -- AND (e.thirdFlight =p.thirdFlight  AND e.thirdairline = p.thirdairline )  
    --  AND (e.fourthflight =p.fourthFlight AND e.fourthairline = p.fourthairline)  
    -- AND (e.fifthFlight =p.fifthFlight  AND e.fifthAirline = p.fifthairline )  
    -- AND (e.sixthflight = p.sixthFlight  AND e.sixthairline = p.sixthairline )  
    -- )    
       
     /*****CLEAR @flight1,@flight2 ,@flight3,@flight4,@flight5,@flight6 TABLES AFTER WORK DONE END HERE ****/  
       
     /****DELETE ALL COMBINATIONS WHICH ARE PART OF GDS RESPONSES START HERE ***/  
     DELETE E  FROM @estimatedCombination E   
  
     INNER JOIN @pivottedResponse p on (  
     e.oneflight = p.oneFlight AND e.oneAirline = p.oneAirline     
     AND e.secondflight =p.secondFlight AND e.secondairline = p.secondAirline  
     AND e.thirdFlight =p.thirdFlight  AND e.thirdairline = p.thirdairline   
     AND e.fourthflight =p.fourthFlight AND e.fourthairline = p.fourthairline  
     AND e.fifthFlight = p.fifthFlight  AND e.fifthAirline = p.fifthairline   
     AND e.sixthflight = p.sixthFlight  AND e.sixthairline = p.sixthairline   
     )    
     WHERE p.oneClass = @legOneClass and p.secondClass=isnull(@legTwoClass ,'') and p.thirdClass = ISNULL (@legThreeClass,'')   
     AND  p.fourthClass = ISNULL ( @legFourClass,'') AND p.fifthClass = ISNULL( @legFiveClass ,'') AND p.sixthClass = ISNULL( @legSixClass,'')  
  
     --SELECT * FROM @estimatedCombination   
    /****DELETE ALL COMBINATIONS WHICH ARE PART OF GDS RESPONSES START HERE ***/  
      
    /***ITERATE THROUGH REMAINING COMBINATION FOR GENERATING BUNDLES ****/  
    DECLARE @newID as INT   
    SELECT @newID = MIN(ID) from @estimatedCombination   
     WHILE @newID IS NOT NULL   
     BEGIN   
      ------ ID FOR NEW AIR RESPONSE------------  
      DECLARE @newResponseID AS UNIQUEIDENTIFIER  
     --select * from @estimatedCombination  
      SET @newResponseID = NEWID ()   
      DELETE from @estimatedCombination WHERE ID < @newID  
      DECLARE @flightNumber1  as varchar(100) ,@flightNumber2 as varchar(100),@flightNumber3  as varchar(100) ,@flightNumber4 as varchar(100),@flightNumber5  as varchar(100) ,@flightNumber6 as varchar(100)  
      SELECT @flightNumber1 = oneflight , @flightNumber2 = secondflight , @flightNumber3 =thirdFlight ,@flightNumber4=fourthflight ,@flightnumber5 = fifthFlight,@flightNumber6 =sixthflight  
       from @estimatedCombination  where ID= @newID   
      ----CREATE NEW AIRRESPONSE -------  
        
     --- SELECT @flightNumber1,@flightNumber2 ,@flightNumber3,@flightNumber4   
        
      /***CREATE NEW AIRRESPONSE START HERE **/  
      INSERT AirResponse ([airResponseKey],[airSubRequestKey] ,[airPriceBase],[airPriceTax],[gdsSourceKey],[refundable],[airClass],[priceClassCommentsSuperSaver],[priceClassCommentsEconSaver],[priceClassCommentsFirstFlex],[priceClassCommentsCorporate],[priceClassCommentsEconFlex],[priceClassCommentsEconUpgrade],[airSuperSaverPrice],[airEconSaverPrice],[airFirstFlexPrice],[airCorporatePrice] ,[airEconFlexPrice],[airEconUpgradePrice],[airClassSuperSaver],[airClassEconSaver],[airClassFirstFlex] ,[airClassCorporate],[airClassEconFlex] ,[airClassEconUpgrade],[airSuperSaverSeatRemaining],[airEconSaverSeatRemaining],[airFirstFlexSeatRemaining],[airCorporateSeatRemaining],[airEconFlexSeatRemaining],[airEconUpgradeSeatRemaining],[airSuperSaverFareReferenceKey],[airEconSaverFareReferenceKey],[airFirstFlexFareReferenceKey],[airCorporateFareReferenceKey],[airEconFlexFareReferenceKey],[airEconUpgradeFareReferenceKey],[airPriceClassSelected],[airSuperSaverTax],[airEconSaverTax],[airEconFlexTax],[airCorporateTax],[airEconUpgradetax],[airFirstFlexTax],[airSuperSaverFareBasisCode],[airEconSaverFareBasisCode],[airFirstFlexFareBasisCode],[airCorporateFareBasisCode],[airEconFlexFareBasisCode],[airEconUpgradeFareBasisCode],[isBrandedFare],[cabinClass],[fareType],[isGeneratedBundle],[ValidatingCarrier])   
      SELECT top 1 @newResponseID,resp.airSubRequestKey,airPriceBase,airPriceTax,gdsSourceKey,refundable,airClass,priceClassCommentsSuperSaver,priceClassCommentsEconSaver,  
      priceClassCommentsFirstFlex,priceClassCommentsCorporate,priceClassCommentsEconFlex,priceClassCommentsEconUpgrade,airSuperSaverPrice,  
      airEconSaverPrice,airFirstFlexPrice,airCorporatePrice,airEconFlexPrice,airEconUpgradePrice,airClassSuperSaver,  
      airClassEconSaver,airClassFirstFlex,airClassCorporate,airClassEconFlex,airClassEconUpgrade,airSuperSaverSeatRemaining,airEconSaverSeatRemaining,  
      airFirstFlexSeatRemaining,airCorporateSeatRemaining,airEconFlexSeatRemaining,airEconUpgradeSeatRemaining,airSuperSaverFareReferenceKey,  
      airEconSaverFareReferenceKey,airFirstFlexFareReferenceKey,airCorporateFareReferenceKey,airEconFlexFareReferenceKey,airEconUpgradeFareReferenceKey,  
      airPriceClassSelected,airSuperSaverTax,airEconSaverTax,airEconFlexTax,airCorporateTax,airEconUpgradetax,airFirstFlexTax,airSuperSaverFareBasisCode,  
      airEconSaverFareBasisCode,airFirstFlexFareBasisCode,airCorporateFareBasisCode,airEconFlexFareBasisCode,airEconUpgradeFareBasisCode,isBrandedFare,  
      resp.cabinClass,fareType,1 ,resp.ValidatingCarrier   
      from @NormalizedAirResponses N INNER JOIN @Airresponse resp   
      ON n.airresponsekey =resp.airResponseKey   
      INNER JOIN @ResultTable  r on  resp.airResponseKey =r.airresponseKey   
      AND flightNumber  =  @flightNumber1  
      and airLegConnections  = @legOneConnection and airLegBookingClasses  = @legOneClass  and airlines  =@legOneAirline  and resp.airsubrequestkey =@airsubrequestkey   
      AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax   
        
     /****INSERT LEG 1 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS START HERE ****/  
      IF ( @flightNumber1 is not null )   
       BEGIN  
         INSERT NormalizedAirResponses    ([airresponsekey],[flightNumber] ,[airlines] ,[airsubrequestkey],[airLegNumber],[airLegBookingClasses],[operatingAirlines],[airLegConnections],[cabinclass])
         SELECT top 1 @newResponseID,flightNumber,airlines,N.airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,N.cabinclass from @NormalizedAirResponses N  
         INNER JOIN @Airresponse r ON N.airresponsekey = R.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax   
         INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey   
            
         AND flightNumber  =  @flightNumber1  
         and airLegConnections  = @legOneConnection and airLegBookingClasses  = @legOneClass  and airlines  =@legOneAirline  and N.airsubrequestkey =@airsubrequestkey   
        --PRINT ( 'LEG1'+   @flightNumber1)  
    
          INSERT AirSegments   ([airSegmentKey],[airResponseKey],[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber],[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate] ,[airSegmentArrivalDate] ,[airSegmentDepartureAirport],[airSegmentArrivalAirport] ,[airSegmentResBookDesigCode],[airSegmentDepartureOffset],[airSegmentArrivalOffset] ,[airSegmentSeatRemaining] ,[airSegmentMarriageGrp],[airFareBasisCode] ,[airFareReferenceKey] ,[airSegmentOperatingFlightNumber] ,[airsegmentCabin],[segmentOrder],[amadeusSNDIndicator])
         SELECT NEWID(),@newResponseID,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,  
         airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,  
         airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode,  
         airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator FROM @AirSegments where airResponseKey =(  
         SELECT top 1  N.airresponsekey  from @NormalizedAirResponses N  
         INNER JOIN @Airresponse r ON N.airresponsekey = R.airResponseKey AND airPriceBase =    @actualPriceBase   AND airPriceTax = @actualTax   
         INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey   
         AND flightNumber  =  @flightNumber1  
         and airLegConnections  = @legOneConnection and airLegBookingClasses  = @legOneClass  and airlines  =@legOneAirline  and N.airsubrequestkey =@airsubrequestkey   
         )   
         AND airLegNumber =1  
  
       END  
     /****INSERT LEG 1 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS END HERE ****/  
         
     /****INSERT LEG 2 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS START HERE ****/    
      IF ( @flightNumber2 is not null )    
       BEGIN    
         INSERT NormalizedAirResponses  ([airresponsekey],[flightNumber] ,[airlines] ,[airsubrequestkey],[airLegNumber],[airLegBookingClasses],[operatingAirlines],[airLegConnections],[cabinclass]) 
         SELECT top 1 @newResponseID,flightNumber,airlines,N.airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,N.cabinclass from   
         @NormalizedAirResponses   N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax    
         INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey  AND flightNumber  =  @flightNumber2  
         and airLegConnections  = @legTwoConnection and airLegBookingClasses  = @legTwoClass   and airlines =@legTwoAirline   and N.airsubrequestkey =@airsubrequestkey   
         ---PRINT ( 'LEG2'+   @flightNumber2)  
          INSERT AirSegments   ([airSegmentKey],[airResponseKey],[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber],[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate] ,[airSegmentArrivalDate] ,[airSegmentDepartureAirport],[airSegmentArrivalAirport] ,[airSegmentResBookDesigCode],[airSegmentDepartureOffset],[airSegmentArrivalOffset] ,[airSegmentSeatRemaining] ,[airSegmentMarriageGrp],[airFareBasisCode] ,[airFareReferenceKey] ,[airSegmentOperatingFlightNumber] ,[airsegmentCabin],[segmentOrder],[amadeusSNDIndicator])
         SELECT NEWID(),@newResponseID,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,  
         airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,  
         airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode,  
         airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator FROM @AirSegments where airResponseKey =(  
         SELECT top 1  N.airResponseKey  from @NormalizedAirResponses N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax    
         INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey  AND flightNumber  =  @flightNumber2  
         and airLegConnections  = @legTwoConnection and airLegBookingClasses  = @legTwoClass   and airlines =@legTwoAirline   and N.airsubrequestkey =@airsubrequestkey   
         ) AND airLegNumber =2  
       END  
     /****INSERT LEG 2 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS END HERE ****/  
        
     /****INSERT LEG 3 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS START HERE ****/  
      IF ( @flightNumber3 is not null )   
       BEGIN    
          INSERT NormalizedAirResponses  ([airresponsekey],[flightNumber] ,[airlines] ,[airsubrequestkey],[airLegNumber],[airLegBookingClasses],[operatingAirlines],[airLegConnections],[cabinclass]) 
         SELECT top 1 @newResponseID,flightNumber,airlines,N.airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,N.cabinclass from  
          @NormalizedAirResponses   N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax    
          INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey  AND flightNumber  =  @flightNumber3  
         and airLegConnections  = @legThreeConnection and airLegBookingClasses  = @legThreeClass   and airlines =@legThreeAirline   and N.airsubrequestkey =@airsubrequestkey   
        --- PRINT ( 'LEG3' +   @flightNumber3)  
          INSERT AirSegments  ([airSegmentKey],[airResponseKey],[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber],[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate] ,[airSegmentArrivalDate] ,[airSegmentDepartureAirport],[airSegmentArrivalAirport] ,[airSegmentResBookDesigCode],[airSegmentDepartureOffset],[airSegmentArrivalOffset] ,[airSegmentSeatRemaining] ,[airSegmentMarriageGrp],[airFareBasisCode] ,[airFareReferenceKey] ,[airSegmentOperatingFlightNumber] ,[airsegmentCabin],[segmentOrder],[amadeusSNDIndicator]) 
         SELECT NEWID(),@newResponseID,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,  
         airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,  
         airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode,  
         airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator FROM @AirSegments where airResponseKey =  
         ( SELECT top 1 N.airresponsekey  from @NormalizedAirResponses  N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax   
         INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey   AND flightNumber  =  @flightNumber3  
         and airLegConnections  = @legThreeConnection and airLegBookingClasses  = @legThreeClass   and airlines =@legThreeAirline   and N.airsubrequestkey =@airsubrequestkey ) AND airLegNumber =3  
  
       END  
      /****INSERT LEG 3 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS END HERE ****/  
        
      /****INSERT LEG 4 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS START HERE ****/  
      IF ( @flightNumber4 is not null )   
       BEGIN    
         INSERT NormalizedAirResponses   ([airresponsekey],[flightNumber] ,[airlines] ,[airsubrequestkey],[airLegNumber],[airLegBookingClasses],[operatingAirlines],[airLegConnections],[cabinclass])
        SELECT top 1 @newResponseID,flightNumber,airlines,N.airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,N.cabinclass from  
         @NormalizedAirResponses   N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax    
         INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey   
         AND flightNumber  =  @flightNumber4  
        and airLegConnections  = @legFourConnection and airLegBookingClasses  = @legFourClass  and airlines =@legFourAirline   and N.airsubrequestkey =@airsubrequestkey   
        --PRINT ( 'LEG4' + @flightNumber4 )  
        INSERT AirSegments   ([airSegmentKey],[airResponseKey],[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber],[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate] ,[airSegmentArrivalDate] ,[airSegmentDepartureAirport],[airSegmentArrivalAirport] ,[airSegmentResBookDesigCode],[airSegmentDepartureOffset],[airSegmentArrivalOffset] ,[airSegmentSeatRemaining] ,[airSegmentMarriageGrp],[airFareBasisCode] ,[airFareReferenceKey] ,[airSegmentOperatingFlightNumber] ,[airsegmentCabin],[segmentOrder],[amadeusSNDIndicator])
        SELECT NEWID(),@newResponseID,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,  
        airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,  
        airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode,  
        airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator FROM @AirSegments where airResponseKey = (  
        SELECT top 1 N.airresponsekey  from @NormalizedAirResponses    N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax   
        INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey AND flightNumber  =  @flightNumber4  
        and airLegConnections  = @legFourConnection and airLegBookingClasses  = @legFourClass  and airlines =@legFourAirline   and N.airsubrequestkey =@airsubrequestkey    
        ) AND airLegNumber =4  
       END         
      /****INSERT LEG 4 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS END HERE ****/  
        
      /****INSERT LEG 5 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS START  HERE ****/  
      IF ( @flightNumber5 is not null )   
       BEGIN    
         INSERT NormalizedAirResponses   ([airresponsekey],[flightNumber] ,[airlines] ,[airsubrequestkey],[airLegNumber],[airLegBookingClasses],[operatingAirlines],[airLegConnections],[cabinclass])
        SELECT top 1 @newResponseID,flightNumber,airlines,N.airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,N.cabinclass from  
         @NormalizedAirResponses   N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax    
         INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey   
         AND flightNumber  =  @flightNumber5  
        and airLegConnections  = @legFiveConnection and airLegBookingClasses  = @legFiveClass  and airlines =@legFiveAirline   and N.airsubrequestkey =@airsubrequestkey   
       -- PRINT ( 'LEG5' + @flightNumber5 )  
        INSERT AirSegments   ([airSegmentKey],[airResponseKey],[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber],[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate] ,[airSegmentArrivalDate] ,[airSegmentDepartureAirport],[airSegmentArrivalAirport] ,[airSegmentResBookDesigCode],[airSegmentDepartureOffset],[airSegmentArrivalOffset] ,[airSegmentSeatRemaining] ,[airSegmentMarriageGrp],[airFareBasisCode] ,[airFareReferenceKey] ,[airSegmentOperatingFlightNumber] ,[airsegmentCabin],[segmentOrder],[amadeusSNDIndicator])
        SELECT NEWID(),@newResponseID,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,  
        airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,  
        airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode,  
        airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator FROM @AirSegments where airResponseKey = (  
        SELECT top 1 N.airresponsekey  from @NormalizedAirResponses    N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax   
        INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey AND flightNumber  =  @flightNumber5  
        and airLegConnections  = @legFiveConnection and airLegBookingClasses  = @legFiveClass  and airlines =@legFiveAirline   and N.airsubrequestkey =@airsubrequestkey    
        ) AND airLegNumber =5  
       END  
      /****INSERT LEG 5 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS END HERE ****/  
       
      /****INSERT LEG 6 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS START HERE ****/  
      IF ( @flightNumber6 is not null )   
      BEGIN    
        INSERT NormalizedAirResponses   ([airresponsekey],[flightNumber] ,[airlines] ,[airsubrequestkey],[airLegNumber],[airLegBookingClasses],[operatingAirlines],[airLegConnections],[cabinclass])
       SELECT top 1 @newResponseID,flightNumber,airlines,N.airsubrequestkey,airLegNumber,airLegBookingClasses,operatingAirlines,airLegConnections,N.cabinclass from  
        @NormalizedAirResponses   N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax    
        INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey   
        AND flightNumber  =  @flightNumber6  
       and airLegConnections  = @legSixConnection and airLegBookingClasses  = @legSixClass  and airlines =@legSixAirline   and N.airsubrequestkey =@airsubrequestkey   
      -- PRINT ( 'LEG6' + @flightNumber6 )  
       INSERT AirSegments   ([airSegmentKey],[airResponseKey],[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber],[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate] ,[airSegmentArrivalDate] ,[airSegmentDepartureAirport],[airSegmentArrivalAirport] ,[airSegmentResBookDesigCode],[airSegmentDepartureOffset],[airSegmentArrivalOffset] ,[airSegmentSeatRemaining] ,[airSegmentMarriageGrp],[airFareBasisCode] ,[airFareReferenceKey] ,[airSegmentOperatingFlightNumber] ,[airsegmentCabin],[segmentOrder],[amadeusSNDIndicator])
       SELECT NEWID(),@newResponseID,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber,airSegmentDuration,  
       airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,  
       airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp,airFareBasisCode,  
       airFareReferenceKey,airSegmentOperatingFlightNumber,airsegmentCabin,segmentOrder,amadeusSNDIndicator FROM @AirSegments where airResponseKey = (  
       SELECT top 1 N.airresponsekey  from @NormalizedAirResponses    N Inner join @Airresponse R on N.airresponsekey = r.airResponseKey AND airPriceBase =@actualPriceBase AND airPriceTax =@actualTax   
       INNER JOIN @ResultTable  tmpResp on  r.airResponseKey =tmpresp.airresponseKey AND flightNumber  =  @flightNumber6  
       and airLegConnections  = @legSixConnection and airLegBookingClasses  = @legSixClass  and airlines =@legSixAirline   and N.airsubrequestkey =@airsubrequestkey    
       ) AND airLegNumber =6  
      END  
        
      /****INSERT LEG 6 IN NORMALIZED TABLE AND SEGMENTS IN AIRSEGMENTS END HERE ****/  
  /***CREATE NEW AIRRESPONSE END HERE **/  
     SELECT @newID = MIN(ID) from @estimatedCombination WHERE ID > @newID  
    ---  print ( '@newID=' +  cast ( @newID as varchar(100)))  
    
     
   END  
  --select * from @estimatedCombination  order by 1 asc   
   Delete from @ResultTable    
  delete from @estimatedCombination   
    
   SELECT @estimateID = MIN(ID) from @estimationTable WHERE ID > @estimateID  
      
  --BREAK  
       
  END  
    
  /***ITERATE THORUGH ALL ESTIMATED COMBINATION ENDS HERE*****/  
DELETE FROM @pivottedResponse   
DELETE FROM @estimationTable   
DELETE FROM @AirResponse   
DELETE FROM @AirSegments   
DELETE FROM @NormalizedAirResponses  
  
GO
