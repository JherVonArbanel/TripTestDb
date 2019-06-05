SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetHistoryTripSearchForAgent]                  
(                  
 @SearchedKey VARCHAR(60),                  
 @SearchedValue VARCHAR(500),                  
 @StringFromDate VARCHAR(30),                
 @StringToDate VARCHAR(30),
 @siteKey int
)                  
AS                  
                  
BEGIN   

 IF(@StringFromDate = N'')
 BEGIN
 SET @StringFromDate = cast('1990-1-1' as datetime)
 END

  IF(@StringToDate = N'')
 BEGIN
 SET @StringToDate = GETDATE()
 END

 Declare @FromDate datetime
 set @FromDate = CAST(@StringFromDate as datetime)
 
 Declare @ToDate datetime
 set @ToDate = CAST(@StringToDate as datetime)
 set @ToDate = DATEADD(ms,-3, DATEADD(day, DATEDIFF(day,0,@ToDate)+1,0))



 declare
 @TicketNumber VARCHAR(50),                  
 @RecordLocator VARCHAR(10),                  
 @PassengerLastName VARCHAR(400),                
 @PassengerFirstName VARCHAR(400),                  
 @airSegmentDepartureDate DATETIME,                  
 @Email VARCHAR(100),                  
 @MobileNumber VARCHAR(100),                 
              
 @origin VARCHAR(100),          
 @destination VARCHAR(100)  


 SET @airSegmentDepartureDate='1900-01-01 00:00:00'
 SET @TicketNumber=N''
 SET @RecordLocator=N''
 SET @PassengerLastName=N''
 SET @PassengerFirstName=N''
 SET @Email=N''
 SET @MobileNumber=N''
 SET @origin=NULL
 SET @destination=NULL



 IF (@SearchedKey ='AgentID')
 BEGIN 
  SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID] 
  not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X

  WHERE  AgentID like '%'+@SearchedValue+'%' 


 END
 ELSE IF (@SearchedKey ='AgentName')
 BEGIN

SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X
   WHERE  AgentName like '%'+@SearchedValue+'%'

 END
 ELSE  IF (@SearchedKey ='PaxEmailID')
 BEGIN

 SET @Email =@SearchedValue
                   
SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X

  WHERE  PaxEmailID like '%'+@SearchedValue+'%' 
 

     union all
  SELECT  '0' as AgentID, '0' as TRAID, '' as AgentName,PassengerFirstName as PaxFirstname,PassengerLastName as PaxLastname,PassengerEmailID as PaxEmailID, cellPhone as PaxMobileNumber, 'Existing Booking' as TransactionType, recordLocator as PNR,convert(varchar(10),TripKey)+',0,9,9,0' as SelectLink from
 (SELECT T.TripKey,case when T.userKey=0 then 'Guest' else 'System' end as isGuest,recordLocator,TPI.PassengerFirstName,TPI.PassengerLastName,(SELECT TOP(1) cellPhone  FROM [vault].[dbo].[UserProfile] where cellPhone like @MobileNumber+'%') as cellPhone  ,TPI.PassengerBirthDate,PassengerEmailID,T.CreatedDate,T.startDate, T.userKey,TR.tripFrom1,TR.tripTo1            
 ,T.tripStatusKey as 'Status' FROM Trip T             
  INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND TR.tripFrom1 = ISNULL(@origin, TR.tripFrom1) AND TR.tripTo1 = ISNULL(@destination, TR.tripTo1)            
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.tripKey AND TPI.IsPrimaryPassenger = 1   
  --INNER JOIN (SELECT userKey,[userRoles] FROM [vault].[dbo].[UserProfile] where ([userRoles] & 1)> 0) AS  TPF ON T.userKey = TPF.userKey   
                   
 WHERE (@RecordLocator = '' OR T.recordLocator = @RecordLocator)                  
  AND (@PassengerLastName = '' OR TPI.PassengerLastName like @PassengerLastName+'%')                 
  AND (@PassengerFirstName = '' OR TPI.PassengerFirstName like @PassengerFirstName+'%')   
  AND (@Email = '' OR TPI.PassengerEmailID like @Email+'%') 
  AND T.CreatedDate  >= @FromDate AND T.CreatedDate  <= @ToDate                 
  AND             
  (            
   @TicketNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TAL.TripKey                  
    FROM TripAirLegs TAL, TripAirLegPassengerInfo TLPI                  
    WHERE TAL.tripAirLegsKey = TLPI.tripAirLegKey AND TLPI.ticketNumber = @TicketNumber                  
   )                  
  )                  
  AND             
  (            
   @MobileNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TP.TripKey                  
    FROM vault.dbo.[USER] U, vault.dbo.UserProfile UP, Trip TP                  
    WHERE U.UserKEy = TP.UserKey                   
    AND U.UserKey = UP.UserKey                  
    AND UP.cellPhone like @MobileNumber+'%'                  
   )                  
  )                  
  AND             
  (            
   @airSegmentDepartureDate = '1/1/1900' OR T.TripKey IN                  
   (                  
    SELECT t.tripkey                  
    FROM Trip t                   
    INNER JOIN                  
    (SELECT t.tripkey , MIN(S.airsegmentdeparturedate) AS DepartDate                  
    FROM Trip t INNER JOIN tripairresponse resp ON t.trippurchasedkey= resp.tripguidkey                   
    INNER JOIN tripairsegments  s  on resp.airresponsekey = s.airresponsekey                   
    GROUP BY t.tripkey,resp.airresponsekey) TSD                  
    ON t.tripKey = TSD.tripKEy                  
    WHERE CONVERT(VARCHAR(10),TSD.DepartDate ,101) = CONVERT(VARCHAR(10),@airSegmentDepartureDate,101)                  
   )                  
  )                  
  AND T.siteKey = @siteKey                  
  AND T.tripPurchasedKey is not null                  
 )  as temptable WHERE recordLocator <> ''                

 END
 ELSE  IF (@SearchedKey ='PaxFirstname')
 BEGIN
    SET @PassengerFirstName = @SearchedValue 
	         
SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X
   WHERE  PaxFirstname like '%'+@SearchedValue+'%'


     union all
  SELECT  '0' as AgentID, '0' as TRAID, '' as AgentName,PassengerFirstName as PaxFirstname,PassengerLastName as PaxLastname,PassengerEmailID as PaxEmailID, cellPhone as PaxMobileNumber, 'Existing Booking' as TransactionType, recordLocator as PNR,convert(varchar(10),TripKey)+',0,9,9,0' as SelectLink from
 (SELECT T.TripKey,case when T.userKey=0 then 'Guest' else 'System' end as isGuest,recordLocator,TPI.PassengerFirstName,TPI.PassengerLastName,(SELECT TOP(1) cellPhone  FROM [vault].[dbo].[UserProfile] where cellPhone like @MobileNumber+'%') as cellPhone  ,TPI.PassengerBirthDate,PassengerEmailID,T.CreatedDate,T.startDate, T.userKey,TR.tripFrom1,TR.tripTo1            
 ,T.tripStatusKey as 'Status' FROM Trip T             
  INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND TR.tripFrom1 = ISNULL(@origin, TR.tripFrom1) AND TR.tripTo1 = ISNULL(@destination, TR.tripTo1)            
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.tripKey AND TPI.IsPrimaryPassenger = 1   
  --INNER JOIN (SELECT userKey,[userRoles] FROM [vault].[dbo].[UserProfile] where ([userRoles] & 1)> 0) AS  TPF ON T.userKey = TPF.userKey   
                   
 WHERE (@RecordLocator = '' OR T.recordLocator = @RecordLocator)                  
  AND (@PassengerLastName = '' OR TPI.PassengerLastName like @PassengerLastName+'%')                 
  AND (@PassengerFirstName = '' OR TPI.PassengerFirstName like @PassengerFirstName+'%')   
  AND (@Email = '' OR TPI.PassengerEmailID like @Email+'%') 
   AND T.CreatedDate  >= @FromDate AND T.CreatedDate  <= @ToDate                        
  AND             
  (            
   @TicketNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TAL.TripKey                  
    FROM TripAirLegs TAL, TripAirLegPassengerInfo TLPI                  
    WHERE TAL.tripAirLegsKey = TLPI.tripAirLegKey AND TLPI.ticketNumber = @TicketNumber                  
   )                  
  )                  
  AND             
  (            
   @MobileNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TP.TripKey                  
    FROM vault.dbo.[USER] U, vault.dbo.UserProfile UP, Trip TP                  
    WHERE U.UserKEy = TP.UserKey                   
    AND U.UserKey = UP.UserKey                  
    AND UP.cellPhone like @MobileNumber+'%'                  
   )                  
  )                  
  AND             
  (            
   @airSegmentDepartureDate = '1/1/1900' OR T.TripKey IN                  
   (                  
    SELECT t.tripkey                  
    FROM Trip t                   
    INNER JOIN                  
    (SELECT t.tripkey , MIN(S.airsegmentdeparturedate) AS DepartDate                  
    FROM Trip t INNER JOIN tripairresponse resp ON t.trippurchasedkey= resp.tripguidkey                   
    INNER JOIN tripairsegments  s  on resp.airresponsekey = s.airresponsekey                   
    GROUP BY t.tripkey,resp.airresponsekey) TSD                  
    ON t.tripKey = TSD.tripKEy                  
    WHERE CONVERT(VARCHAR(10),TSD.DepartDate ,101) = CONVERT(VARCHAR(10),@airSegmentDepartureDate,101)                  
   )                  
  )                  
  AND T.siteKey = @siteKey                  
  AND T.tripPurchasedKey is not null                  
 )  as temptable WHERE recordLocator <> ''              



 END
  ELSE  IF (@SearchedKey ='PaxLastname')
 BEGIN
    SET  @PassengerLastName = @SearchedValue 
	         
SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X

  WHERE  PaxLastname like '%'+@SearchedValue+'%' 

     union all
  SELECT  '0' as AgentID,'0' as TRAID, '' as AgentName,PassengerFirstName as PaxFirstname,PassengerLastName as PaxLastname,PassengerEmailID as PaxEmailID, cellPhone as PaxMobileNumber, 'Existing Booking' as TransactionType, recordLocator as PNR,convert(varchar(10),TripKey)+',0,9,9,0' as SelectLink from
 (SELECT T.TripKey,case when T.userKey=0 then 'Guest' else 'System' end as isGuest,recordLocator,TPI.PassengerFirstName,TPI.PassengerLastName,(SELECT TOP(1) cellPhone  FROM [vault].[dbo].[UserProfile] where cellPhone like @MobileNumber+'%') as cellPhone  ,TPI.PassengerBirthDate,PassengerEmailID,T.CreatedDate,T.startDate, T.userKey,TR.tripFrom1,TR.tripTo1            
 ,T.tripStatusKey as 'Status' FROM Trip T             
  INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND TR.tripFrom1 = ISNULL(@origin, TR.tripFrom1) AND TR.tripTo1 = ISNULL(@destination, TR.tripTo1)            
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.tripKey AND TPI.IsPrimaryPassenger = 1   
  --INNER JOIN (SELECT userKey,[userRoles] FROM [vault].[dbo].[UserProfile] where ([userRoles] & 1)> 0) AS  TPF ON T.userKey = TPF.userKey   
                   
 WHERE (@RecordLocator = '' OR T.recordLocator = @RecordLocator)                  
  AND (@PassengerLastName = '' OR TPI.PassengerLastName like @PassengerLastName+'%')                 
  AND (@PassengerFirstName = '' OR TPI.PassengerFirstName like @PassengerFirstName+'%')   
  AND (@Email = '' OR TPI.PassengerEmailID like @Email+'%')   
   AND T.CreatedDate  >= @FromDate AND T.CreatedDate  <= @ToDate                      
  AND             
  (            
   @TicketNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TAL.TripKey                  
    FROM TripAirLegs TAL, TripAirLegPassengerInfo TLPI                  
    WHERE TAL.tripAirLegsKey = TLPI.tripAirLegKey AND TLPI.ticketNumber = @TicketNumber                  
   )                  
  )                  
  AND             
  (            
   @MobileNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TP.TripKey                  
    FROM vault.dbo.[USER] U, vault.dbo.UserProfile UP, Trip TP                  
    WHERE U.UserKEy = TP.UserKey                   
    AND U.UserKey = UP.UserKey                  
    AND UP.cellPhone like @MobileNumber+'%'                  
   )                  
  )                  
  AND             
  (            
   @airSegmentDepartureDate = '1/1/1900' OR T.TripKey IN                  
   (                  
    SELECT t.tripkey                  
    FROM Trip t                   
    INNER JOIN                  
    (SELECT t.tripkey , MIN(S.airsegmentdeparturedate) AS DepartDate                  
    FROM Trip t INNER JOIN tripairresponse resp ON t.trippurchasedkey= resp.tripguidkey                   
    INNER JOIN tripairsegments  s  on resp.airresponsekey = s.airresponsekey                   
    GROUP BY t.tripkey,resp.airresponsekey) TSD                  
    ON t.tripKey = TSD.tripKEy                  
    WHERE CONVERT(VARCHAR(10),TSD.DepartDate ,101) = CONVERT(VARCHAR(10),@airSegmentDepartureDate,101)                  
   )                  
  )                  
  AND T.siteKey = @siteKey                  
  AND T.tripPurchasedKey is not null                  
 )  as temptable WHERE recordLocator <> ''                     



 END

 ELSE  IF (@SearchedKey ='PaxMobileNumber')
 BEGIN

 SET @MobileNumber = @SearchedValue

SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X

  WHERE  PaxMobileNumber like '%'+@SearchedValue+'%' 

    union all
  SELECT  '0' as AgentID,'0' as TRAID,  '' as AgentName,PassengerFirstName as PaxFirstname,PassengerLastName as PaxLastname,PassengerEmailID as PaxEmailID, cellPhone as PaxMobileNumber, 'Existing Booking' as TransactionType, recordLocator as PNR,convert(varchar(10),TripKey)+',0,9,9,0' as SelectLink from
 (SELECT T.TripKey,case when T.userKey=0 then 'Guest' else 'System' end as isGuest,recordLocator,TPI.PassengerFirstName,TPI.PassengerLastName,(SELECT TOP(1) cellPhone  FROM [vault].[dbo].[UserProfile] where cellPhone like @MobileNumber+'%') as cellPhone  ,TPI.PassengerBirthDate,PassengerEmailID,T.CreatedDate,T.startDate, T.userKey,TR.tripFrom1,TR.tripTo1            
 ,T.tripStatusKey as 'Status' FROM Trip T             
  INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND TR.tripFrom1 = ISNULL(@origin, TR.tripFrom1) AND TR.tripTo1 = ISNULL(@destination, TR.tripTo1)            
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.tripKey AND TPI.IsPrimaryPassenger = 1   
  --INNER JOIN (SELECT userKey,[userRoles] FROM [vault].[dbo].[UserProfile] where ([userRoles] & 1)> 0) AS  TPF ON T.userKey = TPF.userKey   
                   
 WHERE (@RecordLocator = '' OR T.recordLocator = @RecordLocator)                  
  AND (@PassengerLastName = '' OR TPI.PassengerLastName like @PassengerLastName+'%')                 
  AND (@PassengerFirstName = '' OR TPI.PassengerFirstName like @PassengerFirstName+'%')   
  AND (@Email = '' OR TPI.PassengerEmailID like @Email+'%') 
   AND T.CreatedDate  >= @FromDate AND T.CreatedDate  <= @ToDate                        
  AND             
  (            
   @TicketNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TAL.TripKey                  
    FROM TripAirLegs TAL, TripAirLegPassengerInfo TLPI                  
    WHERE TAL.tripAirLegsKey = TLPI.tripAirLegKey AND TLPI.ticketNumber = @TicketNumber                  
   )                  
  )                  
  AND             
  (            
   @MobileNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TP.TripKey                  
    FROM vault.dbo.[USER] U, vault.dbo.UserProfile UP, Trip TP                  
    WHERE U.UserKEy = TP.UserKey                   
    AND U.UserKey = UP.UserKey                  
    AND UP.cellPhone like @MobileNumber+'%'                  
   )                  
  )                  
  AND             
  (            
   @airSegmentDepartureDate = '1/1/1900' OR T.TripKey IN                  
   (                  
    SELECT t.tripkey                  
    FROM Trip t                   
    INNER JOIN                  
    (SELECT t.tripkey , MIN(S.airsegmentdeparturedate) AS DepartDate                  
    FROM Trip t INNER JOIN tripairresponse resp ON t.trippurchasedkey= resp.tripguidkey                   
    INNER JOIN tripairsegments  s  on resp.airresponsekey = s.airresponsekey                   
    GROUP BY t.tripkey,resp.airresponsekey) TSD                  
    ON t.tripKey = TSD.tripKEy                  
    WHERE CONVERT(VARCHAR(10),TSD.DepartDate ,101) = CONVERT(VARCHAR(10),@airSegmentDepartureDate,101)                  
   )                  
  )                  
  AND T.siteKey = @siteKey                  
  AND T.tripPurchasedKey is not null                  
 )   as temptable WHERE recordLocator <> ''                         



 END
 ELSE  IF (@SearchedKey ='PNR')
 BEGIN

SET @RecordLocator= @SearchedValue
                   
SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X

  WHERE  PNR like '%'+@SearchedValue+'%' 


 union all
  SELECT  '0' as AgentID, '0' as TRAID,  '' as AgentName,PassengerFirstName as PaxFirstname,PassengerLastName as PaxLastname,PassengerEmailID as PaxEmailID, cellPhone as PaxMobileNumber, 'Existing Booking' as TransactionType, recordLocator as PNR,convert(varchar(10),TripKey)+',0,9,9,0' as SelectLink from
 (SELECT T.TripKey,case when T.userKey=0 then 'Guest' else 'System' end as isGuest,recordLocator,TPI.PassengerFirstName,TPI.PassengerLastName,(SELECT TOP(1) cellPhone  FROM [vault].[dbo].[UserProfile] where cellPhone like @MobileNumber+'%') as cellPhone  ,TPI.PassengerBirthDate,PassengerEmailID,T.CreatedDate,T.startDate, T.userKey,TR.tripFrom1,TR.tripTo1            
 ,T.tripStatusKey as 'Status' FROM Trip T             
  INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND TR.tripFrom1 = ISNULL(@origin, TR.tripFrom1) AND TR.tripTo1 = ISNULL(@destination, TR.tripTo1)            
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.tripKey AND TPI.IsPrimaryPassenger = 1   
  --INNER JOIN (SELECT userKey,[userRoles] FROM [vault].[dbo].[UserProfile] where ([userRoles] & 1)> 0) AS  TPF ON T.userKey = TPF.userKey   
                   
 WHERE (@RecordLocator = '' OR T.recordLocator = @RecordLocator)                  
  AND (@PassengerLastName = '' OR TPI.PassengerLastName like @PassengerLastName+'%')                 
  AND (@PassengerFirstName = '' OR TPI.PassengerFirstName like @PassengerFirstName+'%')   
  AND (@Email = '' OR TPI.PassengerEmailID like @Email+'%')  
   AND T.CreatedDate  >= @FromDate AND T.CreatedDate  <= @ToDate                       
  AND             
  (            
   @TicketNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TAL.TripKey                  
    FROM TripAirLegs TAL, TripAirLegPassengerInfo TLPI                  
    WHERE TAL.tripAirLegsKey = TLPI.tripAirLegKey AND TLPI.ticketNumber = @TicketNumber                  
   )                  
  )                  
  AND             
  (            
   @MobileNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TP.TripKey                  
    FROM vault.dbo.[USER] U, vault.dbo.UserProfile UP, Trip TP                  
    WHERE U.UserKEy = TP.UserKey                   
    AND U.UserKey = UP.UserKey                  
    AND UP.cellPhone like @MobileNumber+'%'                  
   )                  
  )                  
  AND             
  (            
   @airSegmentDepartureDate = '1/1/1900' OR T.TripKey IN                  
   (                  
    SELECT t.tripkey                  
    FROM Trip t                   
    INNER JOIN                  
    (SELECT t.tripkey , MIN(S.airsegmentdeparturedate) AS DepartDate                  
    FROM Trip t INNER JOIN tripairresponse resp ON t.trippurchasedkey= resp.tripguidkey                   
    INNER JOIN tripairsegments  s  on resp.airresponsekey = s.airresponsekey                   
    GROUP BY t.tripkey,resp.airresponsekey) TSD                  
    ON t.tripKey = TSD.tripKEy                  
    WHERE CONVERT(VARCHAR(10),TSD.DepartDate ,101) = CONVERT(VARCHAR(10),@airSegmentDepartureDate,101)                  
   )                  
  )                  
  AND T.siteKey = @siteKey                  
  AND T.tripPurchasedKey is not null                  
 )  as temptable WHERE recordLocator <> ''                         




 END
 ELSE  IF (@SearchedKey ='TRAID')
 BEGIN


                   
SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X

  WHERE  TRAID like '%'+@SearchedValue+'%' 

 END
 ELSE  IF (@SearchedKey ='TransactionType')
 BEGIN
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X

    union all
  SELECT  '0' as AgentID,'0' as TRAID,  '' as AgentName,PassengerFirstName as PaxFirstname,PassengerLastName as PaxLastname,PassengerEmailID as PaxEmailID, cellPhone as PaxMobileNumber, 'Existing Booking' as TransactionType, recordLocator as PNR,convert(varchar(10),TripKey)+',0,9,9,0' as SelectLink from
 (SELECT T.TripKey,case when T.userKey=0 then 'Guest' else 'System' end as isGuest,recordLocator,TPI.PassengerFirstName,TPI.PassengerLastName,(SELECT TOP(1) cellPhone  FROM [vault].[dbo].[UserProfile] where cellPhone like @MobileNumber+'%') as cellPhone  ,TPI.PassengerBirthDate,PassengerEmailID,T.CreatedDate,T.startDate, T.userKey,TR.tripFrom1,TR.tripTo1            
 ,T.tripStatusKey as 'Status' FROM Trip T             
  INNER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND TR.tripFrom1 = ISNULL(@origin, TR.tripFrom1) AND TR.tripTo1 = ISNULL(@destination, TR.tripTo1)            
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.tripKey AND TPI.IsPrimaryPassenger = 1   
  --INNER JOIN (SELECT userKey,[userRoles] FROM [vault].[dbo].[UserProfile] where ([userRoles] & 1)> 0) AS  TPF ON T.userKey = TPF.userKey   
                   
 WHERE (@RecordLocator = '' OR T.recordLocator = @RecordLocator)                  
  AND (@PassengerLastName = '' OR TPI.PassengerLastName like @PassengerLastName+'%')                 
  AND (@PassengerFirstName = '' OR TPI.PassengerFirstName like @PassengerFirstName+'%')   
  AND (@Email = '' OR TPI.PassengerEmailID like @Email+'%')
   AND T.CreatedDate  >= @FromDate AND T.CreatedDate  <= @ToDate                         
  AND             
  (            
   @TicketNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TAL.TripKey                  
    FROM TripAirLegs TAL, TripAirLegPassengerInfo TLPI                  
    WHERE TAL.tripAirLegsKey = TLPI.tripAirLegKey AND TLPI.ticketNumber = @TicketNumber                  
   )                  
  )                  
  AND             
  (            
   @MobileNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TP.TripKey                  
    FROM vault.dbo.[USER] U, vault.dbo.UserProfile UP, Trip TP                  
    WHERE U.UserKEy = TP.UserKey                   
    AND U.UserKey = UP.UserKey                  
    AND UP.cellPhone like @MobileNumber+'%'                  
   )                  
  )                  
  AND             
  (            
   @airSegmentDepartureDate = '1/1/1900' OR T.TripKey IN                  
   (                  
    SELECT t.tripkey                  
    FROM Trip t                   
    INNER JOIN                  
    (SELECT t.tripkey , MIN(S.airsegmentdeparturedate) AS DepartDate                  
    FROM Trip t INNER JOIN tripairresponse resp ON t.trippurchasedkey= resp.tripguidkey                   
    INNER JOIN tripairsegments  s  on resp.airresponsekey = s.airresponsekey                   
    GROUP BY t.tripkey,resp.airresponsekey) TSD                  
    ON t.tripKey = TSD.tripKEy                  
    WHERE CONVERT(VARCHAR(10),TSD.DepartDate ,101) = CONVERT(VARCHAR(10),@airSegmentDepartureDate,101)                  
   )                  
  )                  
  AND T.siteKey = @siteKey                  
  AND T.tripPurchasedKey is not null                  
 )  as temptable   ) as tempsearchdate
WHERE  TransactionType like '%'+@SearchedValue+'%'           



 END
 ELSE
 BEGIN
                   
SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink from
 (        
 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink
  FROM [Agent].[dbo].[TrackingLog] where  [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate ) as tempkl where PNR <> '' and PNR is not NULL

  union all

 SELECT  AgentID, TRAID, AgentName,PaxFirstname,PaxLastname,PaxEmailID,PaxMobileNumber, TransactionType, PNR,SelectLink
 from
(SELECT (select agentId from [vault].[dbo].[User]  where [userKey] = [ActivityDoneBy]) as AgentID
, 'TRA-' + CONVERT(nvarchar(50), [TrackingID]) as TRAID
      ,(SELECT[userFirstName] +' '+[userLastName] as Name       
  FROM [vault].[dbo].[User]
  where [userKey]=[ActivityDoneBy]) as AgentName      
	  ,(SELECT[userFirstName] as Name     
  FROM [vault].[dbo].[User]
  where [userKey]=[CallerId]) as PaxFirstname

      ,[CallerLastName] as PaxLastname
      ,[CallerEmailId] as PaxEmailID
	  ,(SELECT cellPhone     
  FROM [vault].[dbo].[UserProfile]
  where [userKey]= [CallerId]) as PaxMobileNumber
  ,(SELECT 
    top(1) [Task]
  FROM [Agent].[dbo].[Tracking]
  where [TrackingID] =[Agent].[dbo].[TrackingLog].[TrackingID]) as TransactionType
      ,case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then [dbo].[udf_ConvertRowTolineDataPNR](TrackingLogID) else [CallerPNR] end as PNR,
	  REPLACE (CONVERT(varchar(6),[TrackingID]) +','+ case when ([CallerPNR] IS NULL OR [CallerPNR] = '') then '0' else [CallerPNR] end
	  +','+ case when ([CallerEmailId] IS NULL OR [CallerEmailId] = '') then '0' else [CallerEmailId] end
	  +','+ case when ([CallerLastName] IS NULL OR [CallerLastName] = '') then '0' else [CallerLastName] end
	  +','+ case when ([CallerId] IS NULL OR [CallerId] = 0) then '0' else CONVERT(varchar(6),[CallerId]) end,' ','')
	   as SelectLink, ROW_NUMBER() over(PARTITION BY [TrackingID]
                         ORDER BY [TrackingID] desc) separateKey
  FROM [Agent].[dbo].[TrackingLog] where [TimeStamp] >= @FromDate and [TimeStamp] <= @ToDate and [TrackingID]   not in (
  
 SELECT TRAID FROM
(SELECT [ACTIVITYDONEBY] AS AGENTID
,[TRACKINGID] AS TRAID,CASE WHEN ([CALLERPNR] IS NULL OR [CALLERPNR] = '') THEN [DBO].[UDF_CONVERTROWTOLINEDATAPNR](TRACKINGLOGID) ELSE [CALLERPNR] END AS PNR
  FROM [AGENT].[DBO].[TRACKINGLOG]  ) AS TEMPKL WHERE PNR <> '' AND PNR IS NOT NULL
  
  
  ) ) as tempkl where (PNR = '' or PNR is NULL) and separateKey = 1

  ) as X
 END 
 
 
           
END 

GO
