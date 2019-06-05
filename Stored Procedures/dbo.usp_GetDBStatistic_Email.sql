SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[usp_GetDBStatistic_Email] --[dbo].[usp_GetDBStatistic_Email] 1
(      
	@SiteKey INT = 9
)
AS 
--Select top 100 * from tripRequest order by 1 desc
	DECLARE @tmpTbl TABLE (Id INT IDENTITY(1,1),ReportName NVARCHAR(1000))

 Insert into @tmpTbl values ('BOOK Vs LOOK SUMMARY')  
 Insert into @tmpTbl values ('Reprice Fail')  
 Insert into @tmpTbl values ('INDEX Fragmentation')  
 Insert into @tmpTbl values ('Table Row Count')  
 Insert into @tmpTbl values ('Used Space in Trip Database')  
 Insert into @tmpTbl values ('TRIP DETAIL (Top 100)')  
 Insert into @tmpTbl values ('LOG STATISTIC')  
 Insert into @tmpTbl values ('LOG Status')  
 Insert into @tmpTbl values ('LOG SUMMARY  (Top 100)')  
 Insert into @tmpTbl values ('LOG DETAILS  (Top 100)')  
 
	Select id, reportname from @tmpTbl Order by id

--Select * from vault..SiteConfiguration
--Declare @SiteKey INT = 6

-- Task 1: BOOK Vs LOOK SUMMARY
BEGIN
	/* Old cmmented by sunilK 11092018
	SELECT TOP 1000 S.siteName,subsiteURL = ISNULL(SS.subsiteURL,'Direct'), tripStatusName = 'Trip Status: ' + TS.tripStatusName, count(1) AS cnt   
	 FROM Trip..Trip T  WITH (NOLOCK)
	  INNER JOIN trip..TripStatusLookup TS   WITH (NOLOCK) ON T.tripStatusKey = TS.tripStatusKey   
	  INNER JOIN vault..SiteConfiguration S   WITH (NOLOCK) ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
	  LEFT OUTER JOIN vault..SubSite SS WITH (NOLOCK) ON SS.subsiteKey = T.subsiteKey
	 WHERE CONVERT(DATE, T.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
	 GROUP BY S.siteName,SS.subsiteURL, TS.tripStatusName  
	 UNION ALL
	 SELECT TOP 1000 S.siteName,ISNULL(SS.subsiteURL,'Direct'), 'Total Book', count(1) AS cnt   
	 FROM Trip..Trip T  
	  INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey   
	  INNER JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
		LEFT OUTER JOIN vault..SubSite SS   WITH (NOLOCK) ON SS.subsiteKey = T.subsiteKey
	 WHERE CONVERT(DATE, T.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
	 GROUP BY S.siteName,SS.subsiteURL
	 UNION ALL  
	 SELECT isnull(S.siteName,''),subsiteURL='Not Available', 'Total Look',count(1)   
	 FROM trip..tripRequest t  
	 Left JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
	 WHERE CONVERT(DATE, T.tripRequestCreated, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
	 Group by S.siteName
	 ORDER BY 1, 2,3
	 */
	 SELECT TOP 1000 
	S.siteName,subsiteURL = ISNULL(SS.subsiteURL,'Direct'), tripStatusName = 'Number of Bookings: ' + TS.tripStatusName, count(1) AS cnt   
FROM Trip..Trip T  WITH (NOLOCK)
INNER JOIN trip..TripStatusLookup TS   WITH (NOLOCK) ON T.tripStatusKey = TS.tripStatusKey   
INNER JOIN vault..SiteConfiguration S   WITH (NOLOCK) ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
LEFT OUTER JOIN vault..SubSite SS WITH (NOLOCK) ON SS.subsiteKey = T.subsiteKey
WHERE CONVERT(DATE, T.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
GROUP BY S.siteName,SS.subsiteURL, TS.tripStatusName  

UNION ALL

SELECT TOP 1000 
	S.siteName,ISNULL(SS.subsiteURL,'Direct'), 'Number of Bookings: Total', count(1) AS cnt   
FROM Trip..Trip T  
INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey   
INNER JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
LEFT OUTER JOIN vault..SubSite SS   WITH (NOLOCK) ON SS.subsiteKey = T.subsiteKey
WHERE CONVERT(DATE, T.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
GROUP BY S.siteName,SS.subsiteURL

UNION ALL  
	 --SELECT isnull(S.siteName,''),subsiteURL='Not Available', 'Total Look',count(1)   
	 --FROM trip..tripRequest t  
	 --Left JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
	 --WHERE CONVERT(DATE, T.tripRequestCreated, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
	 --Group by S.siteName
	 --ORDER BY 1, 2,3
--union all

SELECT
	 S.siteName,ISNULL(SS.subsiteURL,'Direct'),'Number of Searches: Total',CNT=(Count(1)) 
FROM	TRIP..tripRequest T
LEFT JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
LEFT JOIN vault..SubSite SS ON T.subsiteKey = SS.subsiteKey --AND S.siteKey = @SiteKey  
WHERE CONVERT(DATE, T.tripRequestCreated, 103) = CONVERT(DATE, GETDATE() - 1, 103) 
GROUP BY S.siteName, SS.subsiteURL 

UNION ALL

SELECT 
	 S.siteName
	,ISNULL(SS.subsiteURL,'Direct')
	,tripStatusName='Number of Searches: ' + TT.page + ' '
	,CNT=Count(1)  
FROM	trip..tripRequest T
LEFT OUTER JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey  
LEFT OUTER JOIN vault..SubSite SS ON T.subsiteKey = SS.subsiteKey --AND S.siteKey = @SiteKey  
LEFT OUTER JOIN Trip..TripTrail TT ON T.tripRequestKey=TT.tripRequestKey
WHERE CONVERT(DATE, T.tripRequestCreated, 103) = CONVERT(DATE, GETDATE() - 1, 103)
	 AND NOT EXISTS (select tripRequestKey from trip..trip TP where T.tripRequestKey=TP.tripRequestKey)
	 AND TT.tripTrailKey=(Select max(tripTrailKey) from trip..TripTrail TT1 where TT1.tripRequestKey=T.tripRequestKey)
GROUP BY S.siteName, SS.subsiteURL,TT.page
ORDER BY 1,2,3,4 Desc
END	
 
 
 -- Reprice Fali
 BEGIN
     SELECT	 SIT.siteName
			,Typesd =  CASE WHEN ISNULL(T.tripKey,0)  = 0 THEN 'Look Only' ELSE 'Look and Book' END
			,TT.*
			,UserName = ISNULL(USR.userFirstName,'') + ' ' + ISNULL(USR.userLastName,'')
			,CompanyName = ISNULL(CMP.companyName,'')
    FROM	TripTrail TT
			LEFT OUTER JOIN TripRequest TR ON TR.tripRequestKey = TT.tripRequestKey
			LEFT OUTER JOIN VAULT..[User] USR ON USR.userKey = TR.userKey
			LEFT OUTER JOIN VAULT..Company CMP ON CMP.COMPANYKEY = USR.companyKey
			LEFT OUTER JOIN VAULT..SiteConfiguration SIT ON SIT.siteKey = TR.SITEKEY
			LEFT OUTER JOIN Trip T ON T.tripRequestKey = TR.tripRequestKey
	WHERE   [Status] = 0 AND Page in ('PassengerDetail','PaymentLoad')
	AND CONVERT(DATE, TT.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)  
	ORDER BY SIT.siteKey, TT.tripRequestKey, TT.CreatedDate
	
 END

 -- INDEX Fragmentation  --Original
 
 BEGIN 
	
	IF EXISTS ( SELECT * FROM [tempdb].[dbo].[sysobjects] WHERE id = OBJECT_ID(N'[tempdb].[dbo].[tmp_indexfragmentation_details]'))
	DROP TABLE [tempdb].[dbo].[tmp_indexfragmentation_details]

	CREATE TABLE [tempdb].[dbo].[tmp_indexfragmentation_details](
		[DatabaseName]                  [nvarchar] (100) NULL,
		[TableName]                        [nvarchar] (100) NULL,
		[indexName]                     [nvarchar] (100) NULL,
		[avg_fragmentation_percent]      float NULL,
		[page_count]                     Float NULL
		,[Command_For_Rebuild]            [nvarchar] (MAx) default 'NA'

	) ON [PRIMARY]

	DECLARE @dbname varchar(1000)
	DECLARE @sqlQuery nvarchar(4000)

	DECLARE dbcursor CURSOR for

	SELECT name FROM sys.databases WHERE name  IN ('trip','Vault','CMS','CarContent','HotelContent')--, 'tempdb', 'model', 'msdb')

	OPEN dbcursor
	FETCH NEXT FROM dbcursor INTO @dbname
		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @sqlQuery = '

			USE [' + @dbname + '];
			IF EXISTS(SELECT compatibility_level FROM sys.databases WHERE name  = N'''+ @dbname +''' AND compatibility_level >= 90 )
			BEGIN
				INSERT INTO [tempdb].[dbo].[tmp_indexfragmentation_details]
				(DatabaseName,TableName, indexName, avg_fragmentation_percent, page_count, Command_For_Rebuild)
				SELECT top 12 db_name(),
					dbtables.[name] ,
					dbindexes.[name],
					indexstats.avg_fragmentation_in_percent,
					indexstats.page_count, ''ALTER INDEX '' + dbindexes.[name] + '' ON '' + dbtables.[name]  + '' REBUILD'' Command_For_Rebuild
				FROM sys.dm_db_index_physical_stats (DB_ID(1), NULL, NULL, NULL, NULL) AS indexstats
					INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
					INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
					INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
						AND indexstats.index_id = dbindexes.index_id
				WHERE indexstats.database_id = DB_ID() and dbindexes.[name] IS NOT NULL
					and indexstats.avg_fragmentation_in_percent>10.00
				ORDER BY indexstats.avg_fragmentation_in_percent desc
			END;'
			EXEC sp_executesql @sqlQuery
			FETCH NEXT FROM dbcursor
			INTO @dbname
		END
	CLOSE dbcursor
	Deallocate dbcursor
	
	DECLARE @uniqValue UNIQUEIDENTIFIER, @createdDate DATETIME 
	SELECT @uniqValue = NEWID(), @createdDate = GETDATE()

	--INSERT INTO TRIP.dbo.Indexfragmentation_details(uniqueValue, DatabaseName, TableName, indexName, avg_fragmentation_percent, page_count, Command_For_Rebuild, CreatedDate)
	--SELECT @uniqValue, DatabaseName, TableName, indexName, avg_fragmentation_percent, page_count, Command_For_Rebuild, @createdDate 
	--FROM [tempdb].[dbo].[tmp_indexfragmentation_details] ORDER BY avg_fragmentation_percent DESC--, page_count DESC

	SELECT DatabaseName, TableName, indexName, avg_fragmentation_percent, page_count 
	FROM [tempdb].[dbo].[tmp_indexfragmentation_details] ORDER BY avg_fragmentation_percent DESC--, page_count DESC

	IF EXISTS ( SELECT * FROM [tempdb].[dbo].[sysobjects] WHERE id = OBJECT_ID(N'[tempdb].[dbo].[tmp_indexfragmentation_details]'))
	DROP TABLE [tempdb].[dbo].[tmp_indexfragmentation_details]

 END
 /*
 Begin
	DECLARE @uniqValue UNIQUEIDENTIFIER, @createdDate DATETIME 
	SELECT @uniqValue = NEWID(), @createdDate = GETDATE()

	DECLARE @Last_Date DATETIME =(SELECT max(CreatedDate) FROM [Indexfragmentation_details])
	DECLARE @Number_OF_Search int
	SELECT @Number_OF_Search=count(1) FROM TripRequest WHERE  tripRequestCreated>@Last_Date

	INSERT INTO TRIP.dbo.Indexfragmentation_details(uniqueValue, DatabaseName, TableName, indexName, avg_fragmentation_percent, page_count, Command_For_Rebuild, CreatedDate,NumberOfSearch)
	SELECT  @uniqValue,db_name(),dbtables.[name] ,dbindexes.[name],
	indexstats.avg_fragmentation_in_percent,indexstats.page_count, 
	'ALTER INDEX ' + dbindexes.[name] + ' ON ' + dbtables.[name]  + ' REBUILD' Command_For_Rebuild,
	@createdDate,@Number_OF_Search NumberOfSearch
	FROM sys.dm_db_index_physical_stats (DB_ID(1), NULL, NULL, NULL, NULL) AS indexstats
	INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
	INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
	INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
	AND indexstats.index_id = dbindexes.index_id
	WHERE dbindexes.[name] in('IX_NormalizedAirResponses','IX_INC_airResponseKey','IX_AirSegments_Airresponse'
	,'IX_INC_gdsSourceKey','Idx_hotelResponseKey','IX_Trip_SiteKey_TripstatusKey'
	,'PK_SabreRestSession','PK_TripEMDTicketInfo','IDX_RNR_TripPassengerAirVendorPreference_GET_tripKey'
	,'IND_tripGUIDKey','Idx_SubTypeCode','IDX_RNR_AircraftsLookup_GET_SubTypeCode_AircraftCode')
	ORDER BY indexstats.avg_fragmentation_in_percent desc
	/*
	SELECT  db_name(),
	dbtables.[name] ,
	dbindexes.[name],
	indexstats.avg_fragmentation_in_percent
	--indexstats.page_count, 'ALTER INDEX ' + dbindexes.[name] + ' ON ' + dbtables.[name]  + ' REBUILD' Command_For_Rebuild
	FROM sys.dm_db_index_physical_stats (DB_ID(1), NULL, NULL, NULL, NULL) AS indexstats
	INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
	INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
	INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
	AND indexstats.index_id = dbindexes.index_id
	WHERE 
	/*
	indexstats.database_id = DB_ID() and dbindexes.[name] IS NOT NULL
	and indexstats.avg_fragmentation_in_percent>10.00
	*/
	dbindexes.[name] in('IX_NormalizedAirResponses','IX_INC_airResponseKey','IX_AirSegments_Airresponse'
	,'IX_INC_gdsSourceKey','Idx_hotelResponseKey','IX_Trip_SiteKey_TripstatusKey'
	,'PK_SabreRestSession','PK_TripEMDTicketInfo','IDX_RNR_TripPassengerAirVendorPreference_GET_tripKey'
	,'IND_tripGUIDKey','Idx_SubTypeCode','IDX_RNR_AircraftsLookup_GET_SubTypeCode_AircraftCode')
	ORDER BY indexstats.avg_fragmentation_in_percent desc
	*/
	select top 12 DatabaseName,TableName,indexName,convert(numeric(18,2),avg_fragmentation_percent) avg_fragmentation_percent
	,page_count,NumberOfSearch 
	from Indexfragmentation_details 
	where indexName in('IX_NormalizedAirResponses','IX_INC_airResponseKey','IX_AirSegments_Airresponse'
		,'IX_INC_gdsSourceKey','Idx_hotelResponseKey','IX_Trip_SiteKey_TripstatusKey'
		,'PK_SabreRestSession','PK_TripEMDTicketInfo','IDX_RNR_TripPassengerAirVendorPreference_GET_tripKey'
		,'IND_tripGUIDKey','Idx_SubTypeCode','IDX_RNR_AircraftsLookup_GET_SubTypeCode_AircraftCode')
	order by CreatedDate desc
				


 End
 */
--	UNION ALL
--	SELECT 'Site Visits','Total',count(1) 
--	FROM [log]..usertrace t 
--	WHERE CONVERT(DATE, T.LoginTime, 103) = CONVERT(DATE, GETDATE() - 1, 103)

-- ROW COUNT
BEGIN 
SELECT 
		t.NAME AS TableName,
		--s.Name AS SchemaName,
		p.rows AS RowCounts,
		--SUM(a.total_pages) * 8 AS TotalSpaceKB, 
		CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
		(CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)))/1024 AS TotalSpaceGB --,
	    
		--SUM(a.used_pages) * 8 AS UsedSpaceKB, 
		--CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
		--(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
		--CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
		--(CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2))) /1024 AS UnusedSpaceGB
	FROM 
		sys.tables t
	INNER JOIN      
		sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
		sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN 
		sys.schemas s ON t.schema_id = s.schema_id
	WHERE 
		t.NAME NOT LIKE 'dt%' 
		AND t.is_ms_shipped = 0
		AND i.OBJECT_ID > 255 
		AND p.rows > 0
	GROUP BY 
		t.Name, s.Name, p.Rows
	ORDER BY 
		2 DESC
		
	--SELECT DB='TRIP', TBL = 'Trip' , CNT = COUNT(1) FROM Trip WITH (NOLOCK)   UNION ALL
	--SELECT DB='TRIP', TBL = 'AirSubRequest' , CNT = COUNT(1) FROM AirSubRequest WITH (NOLOCK) UNION ALL 
	--SELECT DB='TRIP', TBL = 'AirSubRequest' , CNT = COUNT(1) FROM AirResponse WITH (NOLOCK) UNION ALL 
	--SELECT DB='TRIP', TBL = 'AirSegments' , CNT = COUNT(1) FROM AirSegments WITH (NOLOCK)  UNION ALL 
	--SELECT DB='TRIP', TBL = 'NormalizedAirResponses' , CNT = COUNT(1) FROM NormalizedAirResponses WITH (NOLOCK)  UNION ALL 
	--SELECT DB='TRIP', TBL = 'AirResponseMultiBrand' , CNT = COUNT(1) FROM AirResponseMultiBrand WITH (NOLOCK)  UNION ALL 
	--SELECT DB='TRIP', TBL = 'AirSegmentsMultiBrand' , CNT = COUNT(1) FROM AirSegmentsMultiBrand WITH (NOLOCK)  UNION ALL 
	--SELECT DB='TRIP', TBL = 'NormalizedAirResponsesMultiBrand' , CNT = COUNT(1) FROM NormalizedAirResponsesMultiBrand WITH (NOLOCK)  UNION ALL 
	--SELECT DB='TRIP', TBL = 'TripRequest' , CNT = COUNT(1) FROM TripRequest WITH (NOLOCK)  UNION ALL 
	--SELECT DB='TRIP', TBL = 'Airrequest' , CNT = COUNT(1) FROM Airrequest WITH (NOLOCK)   UNION ALL 
	--SELECT DB='TRIP', TBL = 'TripRequest_air' , CNT = COUNT(1) FROM TripRequest_air WITH (NOLOCK)  
	---- UNION ALL 
	--ORDER BY 1,3 DESC
END 

BEGIN -- Used Space in Trip Database

	SELECT 
		t.NAME AS TableName,
		--s.Name AS SchemaName,
		p.rows AS RowCounts,
		--SUM(a.total_pages) * 8 AS TotalSpaceKB, 
		CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
		(CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)))/1024 AS TotalSpaceGB --,
	    
		--SUM(a.used_pages) * 8 AS UsedSpaceKB, 
		--CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
		--(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
		--CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
		--(CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2))) /1024 AS UnusedSpaceGB
	FROM 
		sys.tables t
	INNER JOIN      
		sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
		sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN 
		sys.schemas s ON t.schema_id = s.schema_id
	WHERE 
		t.NAME NOT LIKE 'dt%' 
		AND t.is_ms_shipped = 0
		AND i.OBJECT_ID > 255 
		AND p.rows > 0
	GROUP BY 
		t.Name, s.Name, p.Rows
	ORDER BY 
		4 DESC
END
	SELECT  TOP 100 recordLocator AS [PNR]
			,TS.tripStatusName AS [STATUS]
			,CreatedDate AS [CREATED DATE]
			,S.siteName AS [SITE NAME]
			,isnull(TP.PassengerEmailID,'') as [Guest Email]
			,isnull(UR.userLogin,'') as [Member]
	FROM	 Trip..Trip T
			INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey 
			Left outer JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey --AND S.siteKey = @SiteKey 
			Left outer Join trip..TripPassengerInfo TP on T.tripKey = TP.TripKey
			Left outer Join vault..[User] UR on UR.userkey = t.userKey
	WHERE	CONVERT(DATE, T.CreatedDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)  ---- Make it -1 while deploying on live server
	ORDER BY S.siteName, TS.tripStatusName, T.CreatedDate 
	
	SELECT	 SiteUrl = isnull(SiteUrl,'')
			,LogLevelKey, CNT= Count(1)
	FROM     [Log].dbo.Log_new 
	where	 CONVERT(DATE, CreatedDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)
	Group By SiteUrl, LogLevelKey 
	Order By SiteUrl, LogLevelKey Desc


	SELECT   TOP 100 LogLevelKey
			,SiteUrl = isnull(SiteUrl,'')
			,CNT = COUNT(TRAVELCOMPONENTTYPE)
	FROM     [Log].dbo.Log_new 
	where	 CONVERT(DATE, CreatedDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)
	group by LogLevelKey,SiteUrl
	UNion all
	SELECT   -1
			,SiteUrl = 'TOTAL COUNT'
			,CNT = COUNT(TRAVELCOMPONENTTYPE)
	FROM     [Log].dbo.Log_new 
	where	 CONVERT(DATE, CreatedDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)
	
	Order by LogLevelKey desc,SiteUrl,CNT desc
	

	SELECT   TOP 100 CNT = COUNT(TRAVELCOMPONENTTYPE)
			,SiteUrl = isnull(SiteUrl,'')
			,LogLevelKey
			,ExceptionMessage
			,StackTrace
	FROM     [Log].dbo.Log_new 
	where	 CONVERT(DATE, CreatedDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)
	group by LogLevelKey, SiteUrl,URL, ExceptionMessage, StackTrace
	Order by LogLevelKey desc, SiteUrl,CNT desc, URL, ExceptionMessage, StackTrace


	SELECT  TOP 100 LogId, UserKey, SessionId, TripRequestkey, Event, Comment, LogLevelKey, URL, ExceptionMessage, PageName, ModuleType, StackTrace, CreatedDate, ThreadID, IPAddress, TravelComponentType, 
							 SiteUrl
	FROM            [Log].dbo.Log_new 
	where CONVERT(DATE, CreatedDate, 103) > CONVERT(DATE, GETDATE() - 1, 103)
	Order by 1

GO
