SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
        
create PROCEDURE [dbo].[USP_Report_TransactionCounter_test_new] (   
  --DECLARE    
   @pageNo As int = 1,        
   @pageSize As int = 25,        
   @isCurrentYear as bit = 1,      
   @drillDown int =0 ,      
   @userID int,      
   @dateRangeType Nvarchar(50),      
   @fromDate datetime,      
   @toDate datetime,      
   @airline nvarchar(50),      
   @eventCode nvarchar(100),      
   @formOfPayment nvarchar(10),      
   @country nvarchar(10),      
   @fareType nvarchar(20),      
   @BookType As smallint,       
   @sortField as varchar (200) ,         
   @sortDirection as varchar(20) ,      
   @groupBy varchar(100)='',      
   @TotalRecords As int  = 0 OUTPUT,      
   @siteKey int      
   )       AS      
  
--SELECT @pageNo=1,@PageSize=25,@isCurrentYear=1,@drillDown=1,@userID=0,@dateRangeType=N'bookdate',@fromDate='2012-01-01 00:00:00',  
--@toDate='2012-12-31 23:59:59',@airline=NULL,@eventCode=NULL,@formOfPayment=NULL,@country=NULL,@fareType=NULL,@BookType=0,@sortField=NULL,  
--@sortDirection=NULL,@siteKey=1        
  
--SELECT @pageNo=1,@PageSize=25,@isCurrentYear=1,@drillDown=1,@userID=0,@dateRangeType=N'bookdate',@fromDate='2014-04-01 00:00:00',  
--@toDate='2014-05-31 23:59:59',@airline=NULL,@eventCode=NULL,@formOfPayment=NULL,@country=NULL,@fareType=NULL,@BookType=0,@sortField=NULL,  
--@sortDirection=NULL,@siteKey=1        
  
--SELECT @pageNo=1,@PageSize=815,@isCurrentYear=1,@drillDown=1,@userID=0,@dateRangeType=N'bookdate',@fromDate='2014-10-01 00:00:00'  
-- ,@toDate='2015-02-28 23:59:59',@airline=NULL,@eventCode=NULL,@formOfPayment=NULL,@country=NULL,@fareType=NULL,@BookType=0,@sortField=NULL  
-- ,@sortDirection=NULL,@TotalRecords=0,@siteKey=1  
  
  
  -- Create table for MIA-ORD-FRA-MIA as City,Airlines as Vendor      
   declare @sortType varchar(20)       
   declare @sortColumn varchar(100)       
        
  IF OBJECT_ID('tempdb..#tblSegmentDtl') IS NOT NULL  
   DROP TABLE #tblSegmentDtl  
     
  CREATE TABLE #tblSegmentDtl   
  (            
   AirResponseKey nvarchar(300),            
   City Nvarchar(2000),      
   Carriers Nvarchar(400),      
   CarriersName Nvarchar(2000),     
   VendorCode Nvarchar(200),      
   Vendor Nvarchar(200),      
   fareType Nvarchar(100),      
   bookingClass Nvarchar(100),      
   farebasisCode Nvarchar(1000),  
   Countrycode Nvarchar(20),   
   ArrivalCountryCode NVarchar(20)  
  )           
        
  -- Create table for Trip Itineraries detail      
  IF OBJECT_ID('tempdb..#tripItinerary') IS NOT NULL  
   DROP TABLE #tripItinerary  
     
  CREATE TABLE #tripItinerary   
  (      
  rowId int IDENTITY(1,1) NOT NULL,      
  tripKey int,      
  PassengerName varchar(255),      
  recordlocator varchar(20),      
  Booked datetime,      
  Travel datetime,       
  City varchar(2000),      
  Vendor varchar(200),      
  VendorCode varchar(200),      
  AdvPurch int,      
  agentStatus int,      
  RawUSDPrice FLOAT,  
  RawEURPrice FLOAT,   
  BookingPseudo VARCHAR(5),  
  Price float,      
  appliedDiscount float,      
  NormalPrice float,      
  totalPrice float,    
  meetingCode varchar(200),      
  tripStatus INT,  
  tripStatusName VARCHAR(20),      
  fareType Nvarchar(100),      
  bookingClass Nvarchar(100),      
  farebasisCode Nvarchar(1000),      
  creditCardVendorCode Varchar ( 10),  
  countryCode varchar(20), ArrivalCountryCode VARCHAR(20),  
  tripType  int ,      
  currencyCode varchar(5) ,      
  envUdidValue nvarchar(50),      
  cashUdidValue nvarchar(100),      
  siteKey int ,    
  carriers varchar(200),    
  carriersName varchar(400)  
    
  ,PassengerLocale varchar(100)  
   ,actualAirPrice decimal(10,2)     
  )      
        
  -- Create table for Air Matrix      
        
  DECLARE @tblMatrix AS table         
  (      
  rowId int IDENTITY(1,1) NOT NULL,      
  vendor varchar(200),      
  vendorName varchar(200),            
  OnlineTotal decimal(18,2),      
  OnlineCount  int,      
  agentTotal decimal(18,2),      
  agentCount  int,      
  TotalAmount decimal(18,2),      
  TotalCount  int      
  )       
        
  IF OBJECT_ID('tempdb..#tmpSubTotal') IS NOT NULL  
   DROP TABLE #tmpSubTotal  
     
  CREATE TABLE #tmpSubTotal   
  (      
  rowId int IDENTITY(1,1) NOT NULL,         
  groupbyfield  varchar(255),        
  totalCost decimal(18,2),      
  totalcount bigint ,      
  Average decimal (18,2)      
  ---type varchar(10) ,      
  )       
        
  IF OBJECT_ID('tempdb..#tblEnv') IS NOT NULL  
   DROP TABLE #tblEnv  
     
  CREATE TABLE #tblEnv   
  (       
  tripkey  int ,       
  envUdidNumber  int ,       
  envUdidValue nvarchar (100),      
  cashUdidNumber  int ,       
  cashUdidValue nvarchar (100)      
  )       
   IF(@BookType = 1)      
   BEGIN      
    SET @BookType = 0 -- AGENT      
   END      
   ELSE IF(@BookType = 2)      
   BEGIN      
    SET @BookType = 1 -- ONLINE      
   END      
   ELSE IF(@BookType = 0)      
   BEGIN      
    SET @BookType = 2 -- ONLINE AND AGENT      
   END      
  
  insert #tblEnv(tripkey,envUdidNumber,envUdidValue)      
   select  distinct PUDID.tripkey, companyUdidNumber ,ltrim(PassengerUDIDValue) from  TripPassengerUDIDInfo PUDID      
   inner join Trip t On T.tripkey =PUDID.tripkey      
   where T.tripStatusKey <> 17 and companyUdidNumber = 6 and Active = 1 and       
   (      
  (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.ISSUEDATE else T.startDate end)       
  between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997') OR      
  (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.ISSUEDATE else T.endDate  end)       
  between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997'))      
        
--SELECT GETDATE() AS [2]  
        
  update #tblEnv set cashUdidNumber  = companyUdidNumber ,cashUdidValue= isnull(PassengerUDIDValue,'TRUE')      
  from #tblEnv t inner join  TripPassengerUDIDInfo p on t.tripkey = p.tripkey and p.  companyUdidNumber = 48--21(Issue: http://tfs.its.com:8080/tfs/web/wi.aspx?id=933# Udid No. changed from 21 to 48. Jayant)      
  
--SELECT GETDATE() AS [3]  
        
  -- insert into segment detail table (3F2074EC-6393-43F7-B010-BC6CFD97CA15;MIA-ATL-LAX-IAH-MIA-SFO-DFW-MIA-DFW;AA,CO,DL;DL;Delta Airlines)      
        
  INSERT Into #tblSegmentDtl (AirResponseKey ,City,Carriers ,Carriersname,fareType ,bookingClass,farebasisCode  
   ,Countrycode,ArrivalCountryCode,VendorCode,Vendor )      
        
  select temp1. * ,  Carriers  as  VendorCode,      
   CarriersName    
    from      
  (select Tseg.airResponseKey, Tseg.airSegmentDepartureAirport +'-'+      
  (select STUFF((SELECT  '-' + airSegmentArrivalAirport FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1       
  FOR XML PATH ('')),1,1,''))   City,      
  (select STUFF((SELECT distinct ',' + airSegmentMarketingAirlineCode FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1       
  FOR XML PATH ('')),1,1,''))   Carriers,      
  (select STUFF((SELECT distinct ',' + AVL.ShortName FROM TripAirSegments     
  left outer join AirVendorLookup AVL on  TripAirSegments.airSegmentMarketingAirlineCode =AVL.AirlineCode  ---and Tseg.tripAirSegmentKey = Tmp.segKey      
  where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1       
  FOR XML PATH ('')),1,1,''))   CarriersName,     
  ISNULL(Tseg.airsegmentcabin,'') fareType,      
  (select STUFF((SELECT  ',' + airSegmentResBookDesigCode FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1       
  FOR XML PATH ('')),1,1,''))   bookingclass,      
  (select STUFF((SELECT  ',' + airFareBasisCode FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1       
  FOR XML PATH ('')),1,1,''))   farebasicCode   
  ,airport.CountryCode, airportArrival.CountryCode ArrivalCountryCode    
  from (select MIN(tripAirSegmentKey) segKey from TripAirSegments seg inner join       
  TripAirLegs leg on seg.tripAirLegsKey = leg.tripAirLegsKey       
  inner join trip    on leg.tripKey = trip.tripKey       
  where trip.tripStatusKey <> 17 and seg.isDeleted <> 1 and leg.isDeleted <> 1   
  --AND seg.airsegmentcabin <> ''  --and trip.userKey = 0       
  and        
  (      
  (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then Trip.ISSUEDATE else Trip.startDate end)       
  between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997') OR      
  (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then Trip.ISSUEDATE else Trip.endDate  end)       
  between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997'))      
        
    group by seg.airResponseKey) Tmp       
        
  left outer join TripAirSegments Tseg on (Tseg.tripAirSegmentKey = Tmp.segKey and Tseg.isDeleted <> 1)-- and Tseg.airsegmentcabin <> '')      
  left outer join AirportLookup airport on Tseg.airSegmentDepartureAirport = airport.AirportCode       
  left outer join AirportLookup airportArrival on Tseg.airSegmentArrivalAirport = airportArrival.AirportCode         
  ) temp1        
  --left outer join AirVendorLookup AVL on  temp1.Carriers =AVL.AirlineCode  ---and Tseg.tripAirSegmentKey = Tmp.segKey      
--SELECT GETDATE() AS [4]  
      
  update #tblSegmentDtl  set VendorCode ='Multiple',Vendor ='Multiple Airlines' where VendorCode  like '%,%'--       
  -- create Report Name,Booked(Date),Travel(Date),City(From-To),Vendor(Airline),Adv.Purch.,Status(Agent/Online),Price      
--SELECT GETDATE() AS [5]  
       
  Insert into #tripItinerary (tripkey, PassengerName, Booked, Travel, City, Vendor, VendorCode, AdvPurch, agentStatus, Price, appliedDiscount,   
   meetingCode, tripStatus, tripStatusName, fareType, bookingClass, farebasisCode, creditCardVendorCode, recordlocator, countryCode
   , ArrivalCountryCode, tripType,currencyCode, envUdidValue, cashUdidValue, totalprice, carriers, carriersName,PassengerLocale, actualAirPrice   
  )      
     
  select  T.tripKey,isnull(Pax.PassengerLastName+'/'+Pax.PassengerFirstName,'') as 'PassengerName',T.CreatedDate as 'Booked',T.startDate as 'Travel',       
  isnull(TSD.City,''),isnull(TSD.Vendor,''),isnull(TSD.VendorCode,''),      
  isnull(DATEDIFF(DAY,T.CreatedDate,T.startDate),0) AS 'AdvPurch', T.isOnlineBooking as agentStatus,    
(  
 case  when Pax.PassengerLocale <> 'USD' Then   
  isnull(TAR.actualAirPrice, 0) / ISNULL(  Tman.dba.fn_xchange_rate(Pax.PassengerLocale,T.ISSUEDATE) , 1)   
 
 else       
  isnull(TAR.actualAirPrice, 0)   
 end  
) as Price,      
  ISNULL(TAR.appliedDiscount , 0 ) ,      
   ltrim(ISNULL( T.meetingCodeKey, '')) as meetingCode, T.tripStatusKey as tripStatus, TSL.tripStatusName as tripStatusName  
   ,fareType,bookingClass,farebasisCode,TripCard.creditCardVendorCode,t.recordLocator   
   ,Countrycode ,TSD.ArrivalCountryCode, (case when CountryCode ='US' then 0 else 1 end) ,pax.PassengerLocale      
  ,envUdidValue,cashUdidValue,   
(  
 case  when Pax.PassengerLocale <> 'USD' Then   
  isnull(TAR.actualAirPrice, 0) / ISNULL(Tman.dba.fn_xchange_rate(Pax.PassengerLocale,T.ISSUEDATE), 1)    
 else       
  isnull(TAR.actualAirPrice, 0)   
 end  
) as TotalPrice,  
  TSD.carriers,TSD.carriersName  
  ,Pax.PassengerLocale  
  ,actualAirPrice    
  from Trip T      
   inner join TripPassengerInfo Pax on T.tripKey = isnull(pax.TripKey,0) and Pax.PassengerFirstName is not null --and nullif(T.meetingCodeKey,'') is not null      
   left outer join TripStatusLookup TSL on T.tripStatusKey = TSL.tripStatusKey   
   left outer join TripAirResponse TAR on T.tripKey=TAR.tripKey       
   left outer join #tblSegmentDtl TSD on  TAR.airResponseKey =isnull(TSD.AirResponseKey,'')       
   left outer join TripPassengerCreditCardInfo TripCard on T.tripKey  = TripCard.TripKey  AND TripCard.Active = 1     
   left outer join #tblEnv E on T.tripKey = E.tripkey   
  where T.tripStatusKey <> 17 AND T.tripStatusKey <> 1 AND    
   (      
   (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.ISSUEDATE else T.startDate end)       
         
  between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997')      
  OR (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.ISSUEDATE else T.endDate  end)       
         
  between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997')      
  )      
  AND ISNULL(TSD.VendorCode,'') = ISNULL(@airline,ISNULL(VendorCode,''))      
  AND siteKey=@siteKey      
  AND ISNULL(T.meetingCodeKey,'') = ISNULL(@eventCode,ISNULL(T.meetingCodeKey,''))      
  AND ISNULL(TripCard.creditCardVendorCode,'') = ISNULL(@formOfPayment,ISNULL(TripCard.creditCardVendorCode,''))      
  AND       
   ISNULL ( TSD.Countrycode,'') = ISNUll ( @country,isnull ( TSD.Countrycode,''))       
  AND TSD.fareType = ISNULL(@fareType,TSD.fareType)       
  And      
  T.isOnlineBooking = ( Case when @BookType = 2 then t.isOnlineBooking else @BookType end )      
  --(       
   AND ( ( E.envUdidValue <> 'PRODUCTION' )  or ( E.envUdidValue = 'PRODUCTION' AND cashUdidValue ='FALSE' )  )      
    order by       t.recordLocator
  --case when @sortField = 'ConventionCode' and @sortDirection ='Descending' then    ltrim(T.meetingCodeKey)     End   desc,       
  --case when @sortField = 'ConventionCode' and @sortDirection ='Ascending' then    ltrim(T.meetingCodeKey)  End   asc ,      
  --case when @sortField = 'Booked' and @sortDirection ='Descending' then    T.CreatedDate  End   desc,       
  --case when @sortField = 'Booked' and @sortDirection ='Ascending' then    T.CreatedDate  End   asc ,      
  --case when @sortField = 'Travel' and @sortDirection ='Descending' then    T.startDate  End   desc,       
  --case when @sortField = 'Travel' and @sortDirection ='Ascending' then    T.startDate End   asc ,      
  --case when @sortField = 'City' and @sortDirection ='Descending' then    TSD.City  End   desc,       
  --case when @sortField = 'City' and @sortDirection ='Ascending' then    TSD.City  End   asc ,      
  --case when @sortField = 'Vendor' and @sortDirection ='Descending' then    TSD.Vendor  End desc,       
  --case when @sortField = 'Vendor' and @sortDirection ='Ascending' then    TSD.Vendor  End asc ,      
  --case when @sortField = 'Adv' and @sortDirection ='Descending' then     isnull(DATEDIFF(DAY,T.CreatedDate,T.startDate),0)   End desc,       
  --case when @sortField = 'Adv' and @sortDirection ='Ascending' then   isnull(DATEDIFF(DAY,T.CreatedDate,T.startDate),0)  End asc ,      
  --case when @sortField = 'Status' and @sortDirection ='Descending' then    case   when T.tripRequestKey   > 0  then 1 else 0 end End desc,       
  --case when @sortField = 'Status' and @sortDirection ='Ascending' then    case   when T.tripRequestKey   > 0  then 1 else 0 end End asc ,      
  --case when @sortField = 'Price' and @sortDirection ='Descending' then    isnull(TAR.actualAirPrice,0) End desc,       
  --case when @sortField = 'Price' and @sortDirection ='Ascending' then    isnull(TAR.actualAirPrice ,0)  End asc ,      
  ----case when (@sortField = '' OR @sortField IS NULL) and (@sortDirection ='' OR @sortDirection IS NULL) then    T.startDate End desc,      
  ----case when (@sortField = '' ) and @sortDirection ='Ascending' then    T.startDate End asc,   
  --case when (@sortField = '' ) and @sortDirection ='Descending' then    T.startDate End desc      

      
  update T set totalPrice = TT.addCollectFare ,price = 0 ,appliedDiscount=0       
  from #tripItinerary T INNER JOIN (    
  --Select TripKey,tripTicketInfoKey,(AddCollectFare + serviceCharge) as addCollectFare , Row_Number() OVER(PARTITION BY tripKey ORDER BY tripKey ASC,tripTicketInfoKey DESC) AS RowNumber     
  Select TripKey,tripTicketInfoKey,Totalfare as addCollectFare , Row_Number() OVER(PARTITION BY tripKey ORDER BY tripKey ASC,tripTicketInfoKey DESC) AS RowNumber  --#6606  
  From TripTicketInfo    
  WHERE IsExchanged = 1    
  --Group By TripKey,tripTicketInfoKey,AddCollectFare,serviceCharge) TT    
  Group By TripKey,tripTicketInfoKey,TotalFare) TT  --#6606  
  ON T.TripKey = TT.TripKey    
  AND TT.RowNumber = 1    
      
--SELECT GETDATE() AS [7]  
      
  update #tripItinerary set NormalPrice = price / ((100-appliedDiscount) * 0.01) where isnull(appliedDiscount,0) > 0       
  update #tripItinerary set NormalPrice = price where  isnull(appliedDiscount,0) =0         
        
  Insert into @tblMatrix(vendor,vendorName,OnlineTotal,OnlineCount,agentTotal,agentCount,TotalAmount,TotalCount)       
  select isnull(nullif(T.VendorCode,''),'Multiple') as vendor, isnull(nullif(T.Vendor,''),'Multiple') as vendorName ,SUM(case when T.agentStatus = 1 then isnull(T.totalPrice,0) else 0 end) as OnlineAirCost,Count( case when T.agentStatus = 1 then T.agentStatus end)      
        
   as OnlineAirCount,      
  SUM(case when T.agentStatus = 0 then isnull(T.totalPrice,0) else 0 end) as AgentAirCost,Count( case when T.agentStatus = 0 then T.agentStatus end) as agentAirCount,      
  SUM(isnull(T.totalPrice,0)) as totalAirCost,Count(T.agentStatus) as totalAirCount      
  from #tripItinerary T Group by T.VendorCode,T.Vendor      
  
UPDATE t SET t.RawUSDPrice = CASE WHEN t.currencyCode = 'USD' THEN TAR.actualAirPrice ELSE 0 END  
       , t.RawEURPrice = CASE WHEN t.currencyCode = 'EUR' THEN TAR.actualAirPrice ELSE 0 END  
       ,BookingPseudo = CASE WHEN currencyCode = 'USD' THEN 'N0PG'  
             WHEN currencyCode = 'EUR' THEN 'N0BG' END  
        FROM #tripItinerary t
			INNER JOIN TripAirResponse TAR on T.tripKey=TAR.tripKey

--SELECT GETDATE() AS [8]  
        
   IF ( @groupBy <> '')      
   BEGIN      
         
     if @groupby='PassengerName'      
   begin       
     insert into #tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )      
     select main.meetingCode  , SUM(main.totalPrice)as Cost, count(PassengerName) as TotalCount ,sum(totalPrice  )/count(meetingCode) as Average       
     from #tripItinerary main group by main.meetingCode       
     order by       
     case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.meetingCode    End   desc,       
     case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.meetingCode   End   asc ,      
     case when @sortField = 'count' and @sortDirection ='Descending' then   count(meetingCode)   end desc ,      
     case when @sortField = 'count' and @sortDirection ='Ascending' then   count(meetingCode) end asc ,        
     case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc,       
     case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,      
     case  when @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/ count(meetingCode)) end  desc ,      
     case  when @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/ count(meetingCode) )end  asc        
        
--SELECT GETDATE() AS [9]  
    end       
   else if @groupby='Vendor'      
   begin      
    insert into #tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )      
    select main.Vendor  ,SUM(totalPrice)as Cost, count(Vendor) as TotalCount ,sum(totalPrice )/count(Vendor) as Average  from       
    #tripItinerary main group by main.Vendor         
    order by       
    case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.Vendor   End   desc,       
    case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.Vendor  End   asc ,      
    case when @sortField = 'count' and @sortDirection ='Descending' then  count(Vendor)    end desc ,      
    case when @sortField = 'count' and @sortDirection ='Ascending' then count(Vendor)end asc ,        
    case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc,       
    case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,      
    case  when    @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/count(Vendor) ) end  desc ,      
    case  when    @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/count(Vendor))end  asc        
--SELECT GETDATE() AS [10]  
   end       
   else if @groupby='AdvPurch'      
   begin      
    insert into #tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )      
    select main.AdvPurch   ,SUM(totalPrice)as Cost, count(AdvPurch) as TotalCount ,sum(totalPrice )/count(AdvPurch) as Average  from       
    #tripItinerary main group by main.AdvPurch         
    order by       
    case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.AdvPurch   End   desc,       
    case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.AdvPurch  End   asc ,      
    case when @sortField = 'count' and @sortDirection ='Descending' then  count(AdvPurch)    end desc ,      
    case when @sortField = 'count' and @sortDirection ='Ascending' then count(AdvPurch)end asc ,        
    case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc,       
    case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,      
    case  when    @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/count(AdvPurch) ) end  desc ,      
    case  when    @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/count(AdvPurch))end  asc        
--SELECT GETDATE() AS [11]  
   end       
   else if @groupby='Status'      
   begin      
    insert into #tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )      
    select case when  main.agentStatus = 1 then 'Online' else 'Agent'  end ,SUM(totalPrice)as Cost, count(agentStatus) as TotalCount ,sum(totalPrice )/count(agentStatus) as Average  from       
    #tripItinerary main group by main.agentStatus         
    order by       
    case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.agentStatus   End   desc,       
    case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.agentStatus  End   asc ,      
    case when @sortField = 'count' and @sortDirection ='Descending' then  count(agentStatus)    end desc ,      
    case when @sortField = 'count' and @sortDirection ='Ascending' then count(agentStatus)end asc ,        
    case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc,       
    case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,      
    case  when    @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/count(agentStatus) ) end  desc ,      
    case  when    @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/count(agentStatus))end  asc        
--SELECT GETDATE() AS [12]  
   end       
    select * from #tmpSubTotal where  rowid > @pageSize*(@pageNo-1) and rowId <= @pageSize*(@pageNo)      
   END      
   ELSE       
   BEGIN      
         
  select * from #tripItinerary main where rowId > @pageSize*(@pageNo-1) and rowId <= @pageSize*(@pageNo)       
   order by         
  case when @sortField = 'Price' and @sortDirection ='Descending' then    totalPrice End desc,         
  case when @sortField = 'Price' and @sortDirection ='Ascending' then    totalPrice  End asc     
--SELECT GETDATE() AS [13]  
    ENd      
         
  select * from @tblMatrix order by vendor      
         
         
   if ( @groupBy ='')      
    begin      
  select count(*) as totalrecords from #tripItinerary      
  select @TotalRecords = count(*)  from #tripItinerary      
  end       
  else       
  begin      
  select count(*) as totalrecords from #tmpSubTotal       
  select @TotalRecords = count(*)  from #tmpSubTotal      
  end      
      
  select @BookType as booktype    
      
  select * from #tripItinerary   
  
--SELECT @TotalRecords   
---- Added For testing Remove this part -----------------------  
--Select @sortField SortField, @sortDirection SortDirection  
GO
