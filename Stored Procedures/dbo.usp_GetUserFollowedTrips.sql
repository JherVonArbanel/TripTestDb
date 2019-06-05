SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[usp_GetUserFollowedTrips]   
 @userId int  
AS  
BEGIN  
   
   
select T.tripKey,TR.tripTo1,DEP.CityName as FromCity,ARR.CityName as ToCity,P.userPendingPoints as  [PendingPoints],PP.userPendingPoints as [TravelPoints],
T.DestinationSmallImageURL as [ImageURL],t.startDate,t.endDate  
/* these below field required to count point from coding*/  
,t.tripCreationPath,
--dbo.udf_GetCrowdCount(t.tripSavedKey) as [followercount], --commented because it causing slowness and we are not using this column in myCrowd-Accounts page
0 as followercount,
(tripOriginalTotalBaseCost+tripOriginalTotalTaxCost) as [TripOriginalPrice],
case when t.startDate >= GETDATE() then 0 else 1 end as [TripCrowdStatus]
--o for current trip and 1 for expired trips

/*,CASE             
      WHEN T.[tripComponentType] = 1 THEN 'Air'            
      WHEN T.[tripComponentType] = 2 THEN 'Car'            
      WHEN T.[tripComponentType] = 3 THEN 'Air,Car'            
      WHEN T.[tripComponentType] = 4 THEN 'Hotel'            
      WHEN T.[tripComponentType] = 5 THEN 'Air,Hotel'            
      WHEN T.[tripComponentType] = 6 THEN 'Car,Hotel'            
      WHEN T.[tripComponentType] = 7 THEN 'Air,Car,Hotel'            
     END AS tripComponents*/  
 from Trip..TripSaved TS  WITH(NOLOCK) 
inner join Trip..Trip T WITH(NOLOCK) on T.tripSavedKey = TS.tripSavedKey  and t.userKey=ts.userKey  
INNER JOIN TripRequest TR WITH(NOLOCK) on T.tripRequestKey = TR.tripRequestKey    
 LEFT JOIN AirportLookup DEP WITH(NOLOCK) ON TR.tripFrom1 = DEP.AirportCode          
 LEFT JOIN AirportLookup ARR WITH(NOLOCK) ON TR.tripTo1 = ARR.AirportCode  
 LEFT JOIN loyalty.dbo.pendingpoints P WITH(NOLOCK) on T.tripKey = P.tripId  AND P.UserId = T.userKey  
 LEFT JOIN [Loyalty].[dbo].[PendingPointsHistory] PP ON T.tripKey = PP.tripId AND PP.IsConverted = 1 AND PP.UserID = T.userKey  
where TS.userKey=@userId and t.tripStatusKey <>17 And T.startDate >= GETDATE()
order by t.startDate desc


--used tripsaved table because it assures user has followed.   
--please check for user key, mismatch record   
  
END  
GO
