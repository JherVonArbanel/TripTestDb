SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--USP_GetSavedTripsforCity 'DFW','To' ,5,9
 CREATE Procedure [dbo].[USP_GetSavedTripsforCity] 
(
@cityCode varchar(20) ,
@cityType varchar ( 20) = 'From' ,
@siteKey int , 
@resultCount int = 6 
)
AS 
BEGIN 

declare @Tripdetails as Table 
(
TripdetailsKey int identity (1,1),
 tripKey int,
 tripsavedKey uniqueidentifier ,
triprequestkey int ,
tripstartdate datetime ,
tripenddate datetime ,
tripfrom varchar(20),
tripTo varchar(20),
tripComponentType int, 
rankRating int ,
tripAirsavings float,  
tripcarsavings float,
triphotelsavings float
)
 insert into @Tripdetails ( tripKey  , tripsavedKey   ,triprequestkey   , tripstartdate   ,tripenddate   ,tripfrom  ,tripTo , tripComponentType  , 
rankRating  )
SELECT  top 9 t1.tripKey  , t1.tripsavedKey   ,t1.triprequestkey   ,  startdate   , enddate   ,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType    , (case when watchersCount = 1 then 2 
 when watchersCount = 2 and watchersCount < 5 then  5 
 when watchersCount > 4 then 7 end ) as [Rank]   
  FROM Trip T1
INNER JOIN 
 (select MIN(tripKey) tripkey  , TS.tripSavedKey ,COUNT(tripKEY) as  watchersCount  
  
 from trip T inner join TripSaved TS on T.tripSavedKey = TS.tripSavedKey where siteKey =@siteKey and T.tripStatusKey <> 17 
Group by TS.tripSavedKey  
)  AS DERIED on t1.tripKey =DERIED.tripkey and T1.tripStatusKey <> 17  
Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey  and T1.tripStatusKey <> 17  
 
 where t1.startdate > DATEAdd(DAY,1 ,getdate())  and  (case when  @cityType = 'From' then   TR.tripFrom1   
when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = @cityCode order by [RANK] desc ,tripkey desc 

declare @otherTrips as bit = 0
if   (SELECT COUNT(*)  from @Tripdetails) < 9 
BEGIN 

SET @otherTrips = 1 
  insert into @Tripdetails ( tripKey  , tripsavedKey   ,triprequestkey   , tripstartdate   ,tripenddate   ,tripfrom  , tripTo , tripComponentType  , 
rankRating  )
SELECT  top 6 t1.tripKey  , t1.tripsavedKey   ,t1.triprequestkey   ,  startdate   , enddate   ,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType    , (case when watchersCount = 1 then 2 
 when watchersCount = 2 and watchersCount < 5 then  5 
 when watchersCount > 4 then 7 end ) as [Rank]  
  FROM Trip T1
INNER JOIN 
 (select MIN(tripKey) tripkey  , TS.tripSavedKey ,COUNT(tripKEY) as  watchersCount  
  
 from trip T inner join TripSaved TS on T.tripSavedKey = TS.tripSavedKey where siteKey =@siteKey  and T.tripStatusKey <> 17  
Group by TS.tripSavedKey  
)  AS DERIED on t1.tripKey =DERIED.tripkey  and T1.tripStatusKey <> 17   
Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey  and T1.tripStatusKey <> 17
 
 where  t1.startdate >DATEAdd(DAY,1 ,getdate()) and ( case when  @cityType = 'From' then   TR.tripFrom1   
when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end )<>   @cityCode order by [RANK] desc ,tripkey desc 
END 
IF ( @otherTrips = 1) 
BEGIN 
declare @lastCount as int = 9 
IF ( SELECT COUNT(*) from @Tripdetails)  > 9
BEGIN 
SET @lastCount = 9 
END 
 END

delete from @Tripdetails where TripdetailsKey > @lastCount 

DECLARE @deal table
(
 dealId int , 
 tripkey int ,
componentType int 
)
Insert @deal 
SELECT MAX(TripSavedDealKey),TSD.tripKey ,componentType  FROM TripSavedDeals TSD inner join @Tripdetails TD on tsd.tripKey =TD.tripKey 
--where Convert(Date,TSD.creationDate )=  Convert(Date,getdate()) 
group by tsd.tripKey ,componentType 

update @Tripdetails SET tripAirsavings = 
  (isnull(DTAP.tripAdultBase,Dtap.tripSeniorBase ) + ISNULL(OTAP.tripAdultTax ,otap.tripSeniorTax)) - (isnull(OTAP.tripAdultBase,otap.tripSeniorBase ) + ISNULL(OTAP.tripAdultTax ,otap.tripSeniorTax)) 

  from TripAirResponse OTR inner join TripAirPrices OTAP  
ON OTR.searchAirPriceBreakupKey = OTAP.tripAirPriceKey
inner join @Tripdetails T ON t.tripsavedKey = OTR.tripguidkey 
inner join @deal  D on t.tripKey = d.tripkey 
inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId 
inner join TripAirResponse DTR 
ON DTR.airResponseKey = tsd.responseKey 
inner join TripAirPrices DTAP  
ON DTR.searchAirPriceBreakupKey = DTAP.tripAirPriceKey



update  @Tripdetails SET triphotelsavings = (( DTR.hotelTotalPrice - THR.hotelTotalPrice ) / 2) FROM TripHotelResponse THR inner join @Tripdetails TD on thr.tripGUIDKey =td.tripsavedKey 
inner join @deal  D on tD.tripKey = d.tripkey 
inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId 
inner join TripHotelResponse DTR 
ON DTR.hotelResponseKey = tsd.responseKey 


update  @Tripdetails SET triphotelsavings =   ( DTR.SearchCarPrice+ DTR.searchCarTax)   - ( THR.SearchCarPrice+ THR.searchCarTax) 
FROM TripCarResponse THR inner join @Tripdetails TD on thr.tripGUIDKey =td.tripsavedKey 
inner join @deal  D on td.tripKey = d.tripkey 
inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId 
inner join TripCarResponse DTR 
ON DTR.carResponseKey = tsd.responseKey 

SELECT t.* ,FA.CityName as fromCity , FA.StateCode fromState , fa.CountryCode fromCountry ,TA.CityName as ToCity , 
TA.StateCode ToState , Ta.CountryCode ToCountry  FROM @Tripdetails  T
left outer join 
AirportLookup FA on 
T.tripfrom = FA.AirportCode 
left outer join 
AirportLookup TA on 
T.tripto = TA.AirportCode 

where TripdetailsKey between 1 and @resultCount

END
GO
