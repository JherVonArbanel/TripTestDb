SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_Report_TransactionCounter_Backup_1]
(    
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
 @fareType nvarchar(10),
 @BookType As smallint,	
 @sortField as varchar (200) ,   
 @sortDirection as varchar(20) ,
 @groupBy varchar(100)='',
 @TotalRecords As int  = 0  OUTPUT
)    
AS

-- Create table for MIA-ORD-FRA-MIA as City,Airlines as Vendor
	declare @sortType varchar(20) 
	declare @sortColumn varchar(100) 

	
	
DECLARE @tblSegmentDtl as table      
(      
 AirResponseKey nvarchar(300),      
 City Nvarchar(2000),
 Carriers Nvarchar(2000),
 VendorCode Nvarchar(200),
 Vendor Nvarchar(200),
 fareType Nvarchar(100),
 bookingClass Nvarchar(100),
 farebasisCode Nvarchar(1000),Countrycode Nvarchar(20)
)     

-- Create table for Trip Itineraries detail
DECLARE @tripItinerary as table
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
Price float,
appliedDiscount float,
NormalPrice float,
meetingCode varchar(200),
tripStatus int,
fareType Nvarchar(100),
bookingClass Nvarchar(100),
farebasisCode Nvarchar(1000),
creditCardVendorCode Varchar ( 10),countryCode varchar(20),
tripType  int ,
currencyCode varchar(5) ,
envUdidValue nvarchar(50),
cashUdidValue nvarchar(100)

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


DECLARE    @tmpSubTotal as table
(
rowId int IDENTITY(1,1) NOT NULL,   
groupbyfield  varchar(255),  
totalCost decimal(18,2),
totalcount bigint ,
Average decimal (18,2)
---type varchar(10) ,
  ) 

declare @tblEnv as Table ( tripkey  int , envUdidNumber  int , envUdidValue nvarchar (100),cashUdidNumber  int , cashUdidValue nvarchar (100)) 
insert @tblEnv(tripkey,envUdidNumber,envUdidValue)
 select  distinct PUDID.tripkey, companyUdidNumber ,ltrim(PassengerUDIDValue) from  TripPassengerUDIDInfo PUDID
 inner join Trip t On T.tripkey =PUDID.tripkey
 where companyUdidNumber = 6 and Active = 1 and 
 (
(case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.CreatedDate else T.startDate end) 
between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997') OR
(case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.CreatedDate else T.endDate  end) 
between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997'))

update @tblenv set cashUdidNumber  = companyUdidNumber ,cashUdidValue= isnull(PassengerUDIDValue,'TRUE')
from @tblenv t inner join  TripPassengerUDIDInfo p on t.tripkey = p.tripkey and p.  companyUdidNumber = 21
 
-- declare @tblCash as Table ( tripkey  int , cashUdidNumber  int , cashUdidValue nvarchar (100)) 
--insert @tblCash
-- select PUDID.tripkey, companyUdidNumber ,PassengerUDIDValue from  TripPassengerUDIDInfo PUDID
-- inner join Trip t On T.tripkey =PUDID.tripkey
-- where companyUdidNumber = 20 and Active = 1  AND 
-- (
--(case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.CreatedDate else T.startDate end) 
--between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997') OR
--(case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.CreatedDate else T.endDate  end) 
--between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997'))

 
 

-- insert into segment detail table (3F2074EC-6393-43F7-B010-BC6CFD97CA15;MIA-ATL-LAX-IAH-MIA-SFO-DFW-MIA-DFW;AA,CO,DL;DL;Delta Airlines)

INSERT Into @tblSegmentDtl (AirResponseKey ,City,Carriers ,fareType ,bookingClass,farebasisCode,Countrycode,VendorCode,Vendor )
 

select temp1. * ,  AVL.AirlineCode  as  VendorCode,
isnull(AVL.ShortName,'Multiple Airlines') Vendor 
     from
(select Tseg.airResponseKey, Tseg.airSegmentDepartureAirport +'-'+
(select STUFF((SELECT  '-' + airSegmentArrivalAirport FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1 
FOR XML PATH ('')),1,1,''))   City,
(select STUFF((SELECT distinct ',' + airSegmentMarketingAirlineCode FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1 
FOR XML PATH ('')),1,1,''))   Carriers,
Tseg.airsegmentcabin fareType,
(select STUFF((SELECT  ',' + airSegmentResBookDesigCode FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1 
FOR XML PATH ('')),1,1,''))   bookingclass,
(select STUFF((SELECT  ',' + airFareBasisCode FROM TripAirSegments where airResponseKey = Tseg.airResponseKey  and isDeleted <> 1 
FOR XML PATH ('')),1,1,''))   farebasicCode ,airport.CountryCode
from (select MIN(tripAirSegmentKey) segKey from TripAirSegments seg inner join 
TripAirLegs leg on seg.tripAirLegsKey = leg.tripAirLegsKey 
inner join trip    on leg.tripKey = trip.tripKey 
where seg.isDeleted <> 1  and trip.userKey = 0 and  
(
(case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then Trip.CreatedDate else Trip.startDate end) 
between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997') OR
(case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then Trip.CreatedDate else Trip.endDate  end) 
between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997'))

  group by seg.airResponseKey) Tmp 

left outer join TripAirSegments Tseg on (Tseg.tripAirSegmentKey = Tmp.segKey and Tseg.isDeleted <> 1)
left outer join AirportLookup airport on Tseg.airSegmentDepartureAirport = airport.AirportCode 

) temp1  
left outer join AirVendorLookup AVL on  temp1.Carriers =AVL.AirlineCode  ---and Tseg.tripAirSegmentKey = Tmp.segKey
 
update @tblSegmentDtl  set VendorCode ='Multiple' where VendorCode is null -- 
-- create Report Name,Booked(Date),Travel(Date),City(From-To),Vendor(Airline),Adv.Purch.,Status(Agent/Online),Price
 Insert into @tripItinerary (tripkey,PassengerName ,Booked,Travel,City,Vendor,VendorCode,AdvPurch,agentStatus, Price  ,appliedDiscount,  meetingCode  ,tripStatus,fareType,bookingClass,farebasisCode,creditCardVendorCode ,recordlocator ,countryCode,tripType

 ,currencyCode
,envUdidValue,cashUdidValue
  )
select  T.tripKey,isnull(Pax.PassengerLastName+'/'+Pax.PassengerFirstName,'') as 'PassengerName',T.CreatedDate as 'Booked',T.startDate as 'Travel', 
isnull(TSD.City,''),isnull(TSD.Vendor,''),isnull(TSD.VendorCode,''),
isnull(DATEDIFF(DAY,T.CreatedDate,T.startDate),0) AS 'AdvPurch', case   when T.tripRequestKey   > 0  then 1 else 0 end as   'agentStatus',
(case  when Pax.PassengerLocale <> 'USD' Then  vault.dbo.ufn_Currency_Converter_New(Pax.PassengerLocale, isnull(TAR.actualAirPrice + TAR.actualAirTax,0),T.CreatedDate) else 
isnull(TAR.actualAirPrice + TAR.actualAirTax,0) end ) as Price,
ISNULL(TAR.appliedDiscount , 0 ) ,
 ltrim(ISNULL( T.meetingCodeKey, '')) as meetingCode,T.tripStatusKey as tripStatus,fareType,bookingClass,farebasisCode,TripCard.creditCardVendorCode,t.recordLocator ,Countrycode ,(case when CountryCode ='US' then 0 else 1 end) ,pax.PassengerLocale
,envUdidValue,cashUdidValue
from Trip T
inner join TripPassengerInfo Pax on T.tripKey = isnull(pax.TripKey,0) and Pax.PassengerFirstName is not null and nullif(T.meetingCodeKey,'') is not null
left outer join TripAirResponse TAR on T.tripKey=TAR.tripKey 
left outer join @tblSegmentDtl TSD on  TAR.airResponseKey =isnull(TSD.AirResponseKey,'') 
left outer join TripPassengerCreditCardInfo TripCard on T.tripKey  = TripCard.TripKey 
left outer join @tblenv E on 
T.tripKey = E.tripkey 
where
 (
 (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.CreatedDate else T.startDate end) 
 
between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997')
OR (case when Lower(ISNULL(@dateRangeType,'bookdate'))=Lower('bookdate') then T.CreatedDate else T.endDate  end) 
 
between ISNULL(@fromDate,'1753-01-01 00:00:00.000') and ISNULL(@toDate, '9999-12-31 23:59:59.997')
)
AND ISNULL(TSD.VendorCode,'') = ISNULL(@airline,ISNULL(VendorCode,''))
AND ISNULL(T.meetingCodeKey,'') = ISNULL(@eventCode,ISNULL(T.meetingCodeKey,''))
AND ISNULL(TripCard.creditCardVendorCode,'') = ISNULL(@formOfPayment,ISNULL(TripCard.creditCardVendorCode,''))
AND 
 ISNULL ( TSD.Countrycode,'') = ISNUll ( @country,isnull ( TSD.Countrycode,'')) 
-- (select COUNT(CountryCode) from vault.dbo.CityLookup  
--INNER JOIN ufn_CSVSplitString(REPLACE(TSD.City,'-',',')) City ON City.String = CityLookup.IataCityCode
--where CountryCode = ISNULL(@country,CountryCode)) > 0
AND TSD.fareType = ISNULL(@fareType,TSD.fareType) 
And( 
	(T.tripRequestKey > 0 and @BookType = 2 )
 OR 
  (T.tripRequestKey = 0 and @BookType = 1 )
  OR 
  (T.tripRequestKey >= 0 and (@BookType = 3  or @BookType = 0                    ) )
  )
 AND ( ( E.envUdidValue <> 'PRODUCTION' )  or ( E.envUdidValue = 'PRODUCTION' AND cashUdidValue ='FALSE' )  )
  order by 
case when @sortField = 'ConventionCode' and @sortDirection ='Descending' then    ltrim(T.meetingCodeKey)     End   desc, 
case when @sortField = 'ConventionCode' and @sortDirection ='Ascending' then    ltrim(T.meetingCodeKey)  End   asc ,
case when @sortField = 'Booked' and @sortDirection ='Descending' then    T.CreatedDate  End   desc, 
case when @sortField = 'Booked' and @sortDirection ='Ascending' then    T.CreatedDate  End   asc ,
case when @sortField = 'Travel' and @sortDirection ='Descending' then    T.startDate  End   desc, 
case when @sortField = 'Travel' and @sortDirection ='Ascending' then    T.startDate End   asc ,
case when @sortField = 'City' and @sortDirection ='Descending' then    TSD.City  End   desc, 
case when @sortField = 'City' and @sortDirection ='Ascending' then    TSD.City  End   asc ,
case when @sortField = 'Vendor' and @sortDirection ='Descending' then    TSD.Vendor  End desc, 
case when @sortField = 'Vendor' and @sortDirection ='Ascending' then    TSD.Vendor  End asc ,
case when @sortField = 'Adv' and @sortDirection ='Descending' then     isnull(DATEDIFF(DAY,T.CreatedDate,T.startDate),0)   End desc, 
case when @sortField = 'Adv' and @sortDirection ='Ascending' then   isnull(DATEDIFF(DAY,T.CreatedDate,T.startDate),0)  End asc ,
case when @sortField = 'Status' and @sortDirection ='Descending' then    case   when T.tripRequestKey   > 0  then 1 else 0 end End desc, 
case when @sortField = 'Status' and @sortDirection ='Ascending' then    case   when T.tripRequestKey   > 0  then 1 else 0 end End asc ,
case when @sortField = 'Price' and @sortDirection ='Descending' then    isnull(TAR.actualAirPrice + TAR.actualAirTax,0) End desc, 
case when @sortField = 'Price' and @sortDirection ='Ascending' then    isnull(TAR.actualAirPrice + TAR.actualAirTax,0)  End asc ,
case when @sortField = '' and @sortDirection ='Descending' then    T.startDate End desc
update @tripItinerary set NormalPrice = price / ((100-appliedDiscount) * 0.01) where isnull(appliedDiscount,0) > 0 
update @tripItinerary set NormalPrice = price where  isnull(appliedDiscount,0) =0   



Insert into @tblMatrix(vendor,vendorName,OnlineTotal,OnlineCount,agentTotal,agentCount,TotalAmount,TotalCount) 
select isnull(nullif(T.VendorCode,''),'Multiple') as vendor, isnull(nullif(T.Vendor,''),'Multiple') as vendorName ,SUM(case when T.agentStatus = 1 then isnull(T.price,0) else 0 end) as OnlineAirCost,Count( case when T.agentStatus = 1 then T.agentStatus end)

 as OnlineAirCount,
SUM(case when T.agentStatus = 0 then isnull(T.price,0) else 0 end) as AgentAirCost,Count( case when T.agentStatus = 0 then T.agentStatus end) as agentAirCount,
SUM(isnull(T.price,0)) as totalAirCost,Count(T.agentStatus) as totalAirCount
from @tripItinerary T Group by T.VendorCode,T.Vendor


 IF ( @groupBy <> '')
 BEGIN
 
   if @groupby='PassengerName'
	begin 
			insert into @tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )
			select main.meetingCode  , SUM(main.price)as Cost, count(PassengerName) as TotalCount ,sum(price  )/count(meetingCode) as Average 
			from @tripItinerary main group by main.meetingCode 
			order by 
			case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.meetingCode    End   desc, 
			case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.meetingCode   End   asc ,
			case when @sortField = 'count' and @sortDirection ='Descending' then   count(meetingCode)   end desc ,
			case when @sortField = 'count' and @sortDirection ='Ascending' then   count(meetingCode) end asc ,  
			case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc, 
			case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,
			case  when    @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/ count(meetingCode)) end  desc ,
			case  when    @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/ count(meetingCode) )end  asc  

 
	 end 
	else if @groupby='Vendor'
	begin
		insert into @tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )
		select main.Vendor  ,SUM(price)as Cost, count(Vendor) as TotalCount ,sum(price )/count(Vendor) as Average  from 
		@tripItinerary main group by main.Vendor   
		order by 
		case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.Vendor   End   desc, 
		case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.Vendor  End   asc ,
		case when @sortField = 'count' and @sortDirection ='Descending' then  count(Vendor)    end desc ,
		case when @sortField = 'count' and @sortDirection ='Ascending' then count(Vendor)end asc ,  
		case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc, 
		case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,
		case  when    @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/count(Vendor) ) end  desc ,
		case  when    @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/count(Vendor))end  asc  
	end 
	else if @groupby='AdvPurch'
	begin
		insert into @tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )
		select main.AdvPurch   ,SUM(price)as Cost, count(AdvPurch) as TotalCount ,sum(price )/count(AdvPurch) as Average  from 
		@tripItinerary main group by main.AdvPurch   
		order by 
		case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.AdvPurch   End   desc, 
		case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.AdvPurch  End   asc ,
		case when @sortField = 'count' and @sortDirection ='Descending' then  count(AdvPurch)    end desc ,
		case when @sortField = 'count' and @sortDirection ='Ascending' then count(AdvPurch)end asc ,  
		case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc, 
		case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,
		case  when    @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/count(AdvPurch) ) end  desc ,
		case  when    @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/count(AdvPurch))end  asc  
	end 
	else if @groupby='Status'
	begin
		insert into @tmpSubTotal (groupbyfield ,totalCost ,totalcount ,Average )
		select case when  main.agentStatus = 1 then 'Online' else 'Agent'  end ,SUM(price)as Cost, count(agentStatus) as TotalCount ,sum(price )/count(agentStatus) as Average  from 
		@tripItinerary main group by main.agentStatus   
		order by 
		case when @sortField = 'groupby' and @sortDirection ='Descending' then    main.agentStatus   End   desc, 
		case when @sortField = 'groupby' and @sortDirection ='Ascending' then    main.agentStatus  End   asc ,
		case when @sortField = 'count' and @sortDirection ='Descending' then  count(agentStatus)    end desc ,
		case when @sortField = 'count' and @sortDirection ='Ascending' then count(agentStatus)end asc ,  
		case when @sortField = 'amount' and @sortDirection ='Descending'   then  SUM(price) end desc, 
		case when @sortField = 'amount' and @sortDirection ='Ascending'   then  SUM(price) end asc,
		case  when    @sortField = 'avg' and @sortDirection ='Descending' then  (sum(price )/count(agentStatus) ) end  desc ,
		case  when    @sortField = 'avg' and @sortDirection ='Ascending' then  (sum(price )/count(agentStatus))end  asc  
	end 
		select * from @tmpSubTotal  where  rowid > @pageSize*(@pageNo-1) and rowId <= @pageSize*(@pageNo)
 END
 ELSE 
 BEGIN
 
select * from @tripItinerary main where rowId > @pageSize*(@pageNo-1) and rowId <= @pageSize*(@pageNo) 

  ENd
 
select * from @tblMatrix order by vendor
 
 
 if ( @groupBy ='')
  begin
select count(*) as totalrecords from @tripItinerary
select @TotalRecords = count(*)  from @tripItinerary
end 
else 
begin
select count(*) as totalrecords from @tmpSubTotal 
select @TotalRecords = count(*)  from @tmpSubTotal
end 




GO
