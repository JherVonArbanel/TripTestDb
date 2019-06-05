SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
---- Exec usp_GetDBStatistic 5
CREATE PROC [dbo].[usp_GetDBStatistic]
(      
	@SiteKey INT = 1
)
AS 
BEGIN 

	-- Email Querry--
	DECLARE @BodyBookVsLook varchar(max)
	DECLARE @BodyTripDetail varchar(max)
	DECLARE @BodyErrorLog varchar(max)

	declare @TableHead varchar(max)
	declare @TableHeadTripDetail varchar(max)
	declare @TableHeadErrorLog varchar(max)

	declare @TableTail varchar(max)
	declare @mailitem_id as int
	declare	@statusMsg as varchar(max)
	declare	@Error as varchar(max) 
	declare	@Note as varchar(max)

	Set NoCount On;
	set @mailitem_id = null
	set @statusMsg = null
	set @Error = null
	set @Note = null
	Set @TableTail = '</table></body></html>';

	---- Book Vs Look ----------------------------------------------------------------------------------------------------------------

	DECLARE @tmpTbl TABLE (siteName NVARCHAR(4000), statusName NVARCHAR(1000), Cnt INT)
	
	INSERT INTO @tmpTbl

	SELECT S.siteName, TS.tripStatusName, count(1) AS cnt 
	FROM Trip..Trip T
		INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey 
		INNER JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey AND S.siteKey = @SiteKey
	WHERE CONVERT(DATE, T.CreatedDate, 103) = CONVERT(DATE, GETDATE() - 1, 103)
	GROUP BY S.siteName, TS.tripStatusName

	UNION ALL

	SELECT 'All Site Search','Total Search',count(1) 
	FROM trip..tripRequest t
	WHERE CONVERT(DATE, T.tripRequestCreated, 103) = CONVERT(DATE, GETDATE() - 1, 103)

	UNION ALL
	
	SELECT 'Site Visits','Total',count(1) 
	FROM [log]..usertrace t 
	WHERE CONVERT(DATE, T.LoginTime, 103) = CONVERT(DATE, GETDATE() - 1, 103)
								

	Set @TableHead = '<html><head>' +
	'<H1 style="color: #000000">BOOK Vs LOOK</H1>' +
	'<style>' +
	'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;color:Black;} ' +
	'</style>' +
	'</head>' +
	'<body><table cellpadding=0 cellspacing=0 border=0>' +
	'<tr bgcolor=#F6AC5D>'+
	'<td align=center><b>SITE NAME</b></td>' +
	'<td align=center><b>STATUS</b></td>' +
	'<td align=center><b>COUNT</b></td></tr>';

	--Select information for the Report-- 
	SELECT @BodyBookVsLook = (SELECT siteName AS [TD], statusName AS [TD], Cnt AS [TD] FROM @tmpTbl
								
								FOR XML RAW('tr'), ELEMENTS)
	
	-- Replace the entity codes and row numbers
	Set @BodyBookVsLook = Replace(@BodyBookVsLook, '_x0020_', space(1))
	Set @BodyBookVsLook = Replace(@BodyBookVsLook, '_x003D_', '=')
	Set @BodyBookVsLook = Replace(@BodyBookVsLook, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#C6CFFF>')
	Set @BodyBookVsLook = Replace(@BodyBookVsLook, '<TRRow>0</TRRow>', '')

	Set @BodyBookVsLook = @TableHead + @BodyBookVsLook + @TableTail 

	---- Trip Details ----------------------------------------------------------------------------------------------------------------

	Set @TableHeadTripDetail = '<html><head>' +
	'<H1 style="color: #000000">TRIP DETAIL</H1>' +
	'<style>' +
	'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;color:Black;} ' +
	'</style>' +
	'</head>' +
	'<body><table cellpadding=0 cellspacing=0 border=0>' +
	'<tr bgcolor=#F6AC5D>'+
	'<td align=center><b>PNR</b></td>' +
	'<td align=center><b>STATUS</b></td>' +
	'<td align=center><b>CREATED DATE</b></td>' +
	'<td align=center><b>SITE</b></td></tr>';

	SELECT @BodyTripDetail = (SELECT recordLocator AS [TD], TS.tripStatusName AS [TD], CreatedDate AS [TD], S.siteName AS [TD] 
	FROM Trip..Trip T
		INNER JOIN trip..TripStatusLookup TS ON T.tripStatusKey = TS.tripStatusKey 
		INNER JOIN vault..SiteConfiguration S ON T.siteKey = S.siteKey AND S.siteKey = @SiteKey 
	WHERE CONVERT(DATE, T.CreatedDate, 103) > CONVERT(DATE, GETDATE() - 5, 103)  ---- Make it -1 while deploying on live server
	ORDER BY S.siteName, TS.tripStatusName, T.CreatedDate  

	For XML raw('tr'), Elements)
	-- Replace the entity codes and row numbers
	Set @BodyTripDetail = Replace(@BodyTripDetail, '_x0020_', space(1))
	Set @BodyTripDetail = Replace(@BodyTripDetail, '_x003D_', '=')
	Set @BodyTripDetail = Replace(@BodyTripDetail, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#C6CFFF>')
	Set @BodyTripDetail = Replace(@BodyTripDetail, '<TRRow>0</TRRow>', '')

	Set @BodyTripDetail = @TableHeadTripDetail + @BodyTripDetail + @TableTail 

	---- Error Log Summary ----------------------------------------------------------------------------------------------------------------

	--Set @TableHeadErrorLog = '<html><head>' +
	--'<H1 style="color: #000000">ERROR LOG SUMMARY</H1>' +
	--'<style>' +
	--'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;color:Black;} ' +
	--'</style>' +
	--'</head>' +
	--'<body><table cellpadding=0 cellspacing=0 border=0>' +
	--'<tr bgcolor=#F6AC5D>'+
	--'<td align=center><b>SITE URL</b></td>' +
	--'<td align=center><b>LOG LEVEL</b></td>' +
	--'<td align=center><b>EVENT</b></td>' +
	--'<td align=center><b>EXCEPTION MESSAGE</b></td>' +
	--'<td align=center><b>COUNT</b></td></tr>';

	--SELECT @BodyErrorLog = (SELECT   ISNULL(SITEURL,'') AS [TD]
	--								,LOGLEVELKEY AS [TD], [EVENT] AS [TD]
	--								,[EXCEPTIONMESSAGE] AS [TD]
	--								,COUNT(1) AS [TD] FROM [LOG]..LOG_NEW T
	--						WHERE	 CONVERT(DATE, T.CREATEDDATE, 103) = CONVERT(DATE, GETDATE() - 1, 103)
	--						GROUP BY SITEURL,LOGLEVELKEY,[EVENT],[EXCEPTIONMESSAGE]
	--						ORDER BY SITEURL,5 DESC  
	--FOR XML RAW('tr'), ELEMENTS)
	
	---- Replace the entity codes and row numbers
	--Set @BodyErrorLog = Replace(@BodyErrorLog, '_x0020_', space(1))
	--Set @BodyErrorLog = Replace(@BodyErrorLog, '_x003D_', '=')
	--Set @BodyErrorLog = Replace(@BodyErrorLog, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#C6CFFF>')
	--Set @BodyErrorLog = Replace(@BodyErrorLog, '<TRRow>0</TRRow>', '')

	--Set @BodyErrorLog = @TableHeadErrorLog + @BodyErrorLog + @TableTail 

	PRINT @BodyBookVsLook 
	PRINT @BodyTripDetail 
	PRINT @BodyErrorLog
	
	SELECT @BodyBookVsLook + '<BR>' + @BodyTripDetail AS Body -- + '<BR>' + @BodyErrorLog

END
GO
