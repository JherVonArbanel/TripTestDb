SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec LoadTesting_SQL_TraceReport_SK  @TableName='LoadTesting_Trace_20180228_40Theads_1'
create procedure [dbo].[LoadTesting_SQL_TraceReport_SK]
(
	 @TableName varchar(50)
)
AS
BEGIN
DECLARE @SQL VARCHAR(max)

SET @SQL='SELECT DatabaseName,Textdata,CPU,Reads,Writes,CAST((Duration/1000)/1000. AS decimal(6, 2)) AS [Duration (in Seconds)],StartTime,EndTime
FROM log.dbo.' + @TableName + '
WHERE databasename not in (''ASPState'',''master'',''msdb'')
AND CAST((Duration/1000)/1000. AS decimal(6, 2)) IS NOT NULL
AND CAST((Duration/1000)/1000. AS decimal(6, 2))>1.00
ORDER BY CAST((Duration/1000)/1000. AS decimal(6, 2)) DESC'

EXECUTE(@SQL)

END


GO
