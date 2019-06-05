SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--EXEC usp_GetDBStatistic_Email_new
CREATE PROC [dbo].[usp_GetDBStatistic_Email_new]  
(        
 @SiteKey INT = 1  
)  
AS   
--Select top 100 * from tripRequest order by 1 desc  
 DECLARE @tmpTbl TABLE (Id INT,ReportName NVARCHAR(1000))  
  
 Insert into @tmpTbl values ('1','BOOK Vs LOOK SUMMARY')  
 Insert into @tmpTbl values ('2','TRIP DETAIL (Top 100)')  
 Insert into @tmpTbl values ('3','LOG STATISTIC')  
 Insert into @tmpTbl values ('4','LOG Status')  
 Insert into @tmpTbl values ('5','LOG SUMMARY  (Top 100)')  
 Insert into @tmpTbl values ('6','LOG DETAILS  (Top 100)')  
  
 Select id, reportname from @tmpTbl Order by id  
  
--Select * from vault..SiteConfiguration  
--Declare @SiteKey INT = 6  
  
 SELECT TOP 1000 S.siteName, tripStatusName = 'Trip Status: ' + TS.tripStatusName, count(1) AS cnt   
 FROM Trip..Trip T  
  INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey   
  INNER JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
 WHERE CONVERT(DATE, T.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
 GROUP BY S.siteName, TS.tripStatusName  
 UNION ALL
 SELECT TOP 1000 S.siteName, 'Total Book', count(1) AS cnt   
 FROM Trip..Trip T  
  INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey   
  INNER JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
 WHERE CONVERT(DATE, T.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
 GROUP BY S.siteName
 UNION ALL  
 SELECT isnull(S.siteName,''), 'Total Look',count(1)   
 FROM trip..tripRequest t  
 Left JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
 WHERE CONVERT(DATE, T.tripRequestCreated, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
 Group by S.siteName  
 ORDER BY 1, 2
-- UNION ALL  
-- SELECT 'Site Visits','Total',count(1)   
-- FROM [log]..usertrace t   
-- WHERE CONVERT(DATE, T.LoginTime, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
  
  
  
 SELECT  TOP 100 recordLocator AS [PNR]  
   ,TS.tripStatusName AS [STATUS]  
   ,CreatedDate AS [CREATED DATE]  
   ,S.siteName AS [SITE NAME]  
   ,isnull(TP.PassengerEmailID,'') as [Guest Email]  
   ,isnull(UR.userLogin,'') as [Member]  
 FROM  Trip..Trip T  
   INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey   
   Left outer JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey   
   Left outer Join trip..TripPassengerInfo TP on T.tripKey = TP.TripKey  
   Left outer Join vault..[User] UR on UR.userkey = t.userKey  
 WHERE CONVERT(DATE, T.CreatedDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)  ---- Make it -1 while deploying on live server  
 ORDER BY S.siteName, TS.tripStatusName, T.CreatedDate   
   
 SELECT  TOP 100 SiteUrl = isnull(Url,'')  
   ,LogLevelKey, CNT= Count(1)  
 FROM     [Log].dbo.AuditLogs   
 where  CONVERT(DATE, CreateDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)  
 Group By Url, LogLevelKey   
 Order By Url, LogLevelKey Desc  
  
  
 SELECT   TOP 100 LogLevelKey  
   ,SiteUrl = isnull(Url,'')  
   ,CNT = COUNT([TYPE])  
 FROM     [Log].dbo.AuditLogs   
 where  CONVERT(DATE, CreateDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)  
 group by LogLevelKey,Url  
 UNion all  
 SELECT   -1  
   ,SiteUrl = 'TOTAL COUNT'  
   ,CNT = COUNT(TYPE)  
 FROM     [Log].dbo.AuditLogs   
 where  CONVERT(DATE, CreateDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)  
   
 Order by LogLevelKey desc,SiteUrl,CNT desc  
   
  
 SELECT   TOP 100 CNT = COUNT([TYPE])  
   ,SiteUrl = isnull(Url,'')  
   ,LogLevelKey  
   ,ExceptionMessage  
   ,StackTrace  
 FROM     [Log].dbo.AuditLogs   
 where  CONVERT(DATE, CreateDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)  
 group by LogLevelKey, Url,URL, ExceptionMessage, StackTrace  
 Order by LogLevelKey desc, SiteUrl,CNT desc, URL, ExceptionMessage, StackTrace  
  
  
 SELECT  TOP 100 AuditKey, UserKey, SessionId, TripRequestkey, Event, Comment, LogLevelKey, URL, ExceptionMessage, '' as PageName, '' as ModuleType, StackTrace, CreateDate, '' as ThreadID, '' as IPAddress, [Type],   
        Url  
 FROM            [Log].dbo.AuditLogs   
 where CONVERT(DATE, CreateDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)  
 Order by 1
GO
