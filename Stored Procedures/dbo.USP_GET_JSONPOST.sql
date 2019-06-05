SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GET_JSONPOST]
(
	@Recordlocator NVARCHAR(10)
)
AS
BEGIN

	DECLARE @xmlNotNull BIT=1

	;WITH CTE AS
	(
	SELECT 
		TripRequestkey
		,CreateDate
		,Type
		,WSName
		,Convert(nvarchar(max),xmldata) XmlData
		,Event
		,Details
		,ExceptionMessage
		,StackTrace
		,LogLevelKey
		,Comment
		,SessionId
		,Url
		,SingleBookThreadId
		,GroupBookThreadId 
	FROM log..AuditLogs
	WHERE	[event] like '%JSON%'
			AND ((@xmlNotNull = 1 and DATALENGTH(XmlData) != 19) or (@xmlNotNull != 1) )
	)
	SELECT TripRequestkey
		,CreateDate
		,Type
		,WSName
		,CASt(xmldata as XML) JSON_XML
		,Event
		,Details
		,ExceptionMessage
		,StackTrace
		,LogLevelKey
		,Comment
		,SessionId
		,Url
		,SingleBookThreadId
		,GroupBookThreadId
	FROM CTE WHERE XmlData like '%' + @Recordlocator + '%'

END
GO
