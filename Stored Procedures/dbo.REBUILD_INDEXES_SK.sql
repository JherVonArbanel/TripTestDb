SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[REBUILD_INDEXES_SK]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @ROW_COUNT INT
	DECLARE @SQL NVARCHAR(MAX)

	/*
	SET @ROW_COUNT=(SELECT COUNT(1)
						FROM sys.dm_db_index_physical_stats (null, NULL, NULL, NULL, NULL) AS indexstats
						INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
						INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
						INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
						AND indexstats.index_id = dbindexes.index_id
						inner join sys.databases db on indexstats.database_id=db.database_id
						WHERE  (dbindexes.[name] IS NOT NULL and dbindexes.[name] not like 'PK_%')
						AND avg_fragmentation_in_percent>10.00
					)

	DECLARE @SQL NVARCHAR(MAX)

	DECLARE  @INDEX_SCRIPT TABLE (Index_Script Nvarchar(max),Row_Num int)
	INSERT INTO @INDEX_SCRIPT
	SELECT 'ALTER INDEX [' + dbindexes.[name] + '] ON ' + db.name + '.dbo.[' + dbtables.[name]  + '] REBUILD' Command_For_Rebuild,ROW_NUMBER() over(order by dbindexes.[name])
				FROM sys.dm_db_index_physical_stats (null, NULL, NULL, NULL, NULL) AS indexstats
				INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
				INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
				INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
				AND indexstats.index_id = dbindexes.index_id
				inner join sys.databases db on indexstats.database_id=db.database_id
				WHERE  (dbindexes.[name] IS NOT NULL and dbindexes.[name] not like 'PK_%')
				AND avg_fragmentation_in_percent>10.00
	*/
	
		IF OBJECT_ID('TEMPDB..#RebuildIndexScript') IS NOT NULL
		DROP TABLE #RebuildIndexScript
		CREATE TABLE #RebuildIndexScript
		(
			Id int identity(1,1),
			DBName Varchar(50),
			Command_For_Rebuild varchar(max)
		)



		EXEC sp_MSforeachdb 
		'USE [?]
		DECLARE @database_id INT = DB_ID()
		IF  ''?''  NOT IN (''msdb'',''model'',''master'',''tempdb'',''TMAN'')  
		BEGIN
		
		INSERT INTO #RebuildIndexScript
		SELECT 
		''?'',
		''ALTER INDEX ['' + dbindexes.[name] + ''] ON ['' + ''?'' + ''].dbo.['' +  dbtables.[name]  + ''] REBUILD'' Command_For_Rebuild
		FROM sys.dm_db_index_physical_stats (@database_id, NULL, NULL, NULL, NULL) AS indexstats
		INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
		INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
		INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
		AND indexstats.index_id = dbindexes.index_id
		WHERE indexstats.database_id = DB_ID() and dbindexes.[name] IS NOT NULL
		AND indexstats.avg_fragmentation_in_percent>10.00
		--and dbindexes.[name] NOT LIKE ''PK%''
		ORDER BY indexstats.avg_fragmentation_in_percent desc
		END
		'
		
		SET @ROW_COUNT= IDENT_CURRENT('TEMPDB..#RebuildIndexScript')
		
		--DELETE FROM #RebuildIndexScript WHERE DBName IN('msdb','model','master','tempdb','TMAN')
		--select * from #RebuildIndexScript

		DECLARE  @INDEX_SCRIPT TABLE (Index_Script Nvarchar(max),Row_Num int)
	    INSERT INTO @INDEX_SCRIPT		
		SELECT Command_For_Rebuild,id FROM  #RebuildIndexScript	

		IF @ROW_COUNT> 0
		BEGIN
				WHILE @ROW_COUNT!=0
				BEGIN
					SET @SQL=(SELECT Index_Script FROM @INDEX_SCRIPT WHERE Row_Num=@ROW_COUNT)
					BEGIN TRY
						EXEC (@SQL)
					END TRY
					BEGIN CATCH
					END CATCH
					SET @ROW_COUNT=@ROW_COUNT-1
				END
		END
		SET NOCOUNT OFF
END
GO
