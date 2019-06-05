SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*

declare @totalRecords int

exec [usp_Get_Page_Tripsdetail] 'currenttrips',1,25,25,369,'1/1/1900 12:00:00 AM','12/31/9999 11:59:59 PM',null,null,@totalRecords Out

*/

CREATE PROCEDURE [dbo].[usp_Get_Page_Tripsdetail] 
@PageName nvarchar(500),
@pageNo int,
@pageSize int,
@userkey int,
@tripName nvarchar(50),
@fromDate nvarchar(50),
@toDate nvarchar(50),
@traveler int,
@status int,
@totalRecords INT OUTPUT
AS
BEGIN	         
    Declare @strQuery nvarchar(4000),@paramDesc nvarchar(200)
    
    ---- get the trip detail from trip table with filter parameter
    SET @strQuery =' SELECT RowID = ROW_NUMBER() OVER (ORDER BY tripkey desc),* INTO #tmpTrip FROM trip where userKey='+CONVERT(VARCHAR(100),@userKey)
	if @tripName is not null AND @tripname <> ''
	BEGIN
		SET @strQuery +=' AND tripKey='+CONVERT(VARCHAR(100),@tripName) 
	END
	if @fromDate is not null AND @fromDate <> '' and @toDate is not null AND @toDate <> ''
	BEGIN
		SET @strQuery +=' AND isnull(startDate,'''+@fromDate+''') between '''+@fromDate+''' AND '''+@toDate+''''
	END
	if @traveler is not null AND @traveler <> ''
	BEGIN
		SET @strQuery +=' AND userKey='+CONVERT(VARCHAR(100),@traveler)
	END
	if @status is not null AND @status <> ''
	BEGIN
		SET @strQuery +=' AND tripstatuskey='+CONVERT(VARCHAR(100),@status)
	END
 --   if @PageName = 'currenttrips'
	--BEGIN
	--	SET @strQuery +=' AND tripstatuskey <> 1 AND endDate >= GETDATE() AND recordlocator is not null AND recordlocator<>'''''
	--END	
	--else if @PageName = 'pasttrips'
	--BEGIN
	--	SET @strQuery +=' AND tripstatuskey <> 1 AND endDate < GETDATE() AND Recordlocator is not null AND recordlocator<>'''''
	--END	
	else if @PageName = 'savedtrips'
	BEGIN
		SET @strQuery +=' AND (recordlocator is null OR recordlocator='''') '
	END	
	SET @strQuery+=' SET @totalRecordsOut=@@ROWCOUNT '    ---get total records count in output parameter
	SET @strQuery+=' SELECT tripKey,tripName,userKey,recordLocator,startDate,endDate,tripStatusKey,agencyKey FROM #tmpTrip ' 
    SET @strQuery+=' WHERE RowID > ('+CONVERT(VARCHAR(100),@pageNo)+'-1)*'+CONVERT(VARCHAR(100),@pageSize)+' and RowID <= '+CONVERT(VARCHAR(100),@pageNo)+'*'+CONVERT(VARCHAR(100),@pageSize)+' order by tripkey desc '    
    
    ---  get the Air, car and hotel response detail for filtered trips
    SET @strQuery+=' SELECT vt.TYPE,vt.tripKey,vt.recordLocator,vt.basecost,vt.tax,vt.vendorcode,vt.VendorName,vt.airSegmentDepartureAirport,vt.airSegmentArrivalAirport,vt.flightNumber,vt.departuredate,vt.arrivaldate,vt.carType,vt.Ratingtype '
    SET @strQuery+=' FROM vw_TripDetails vt inner join #tmpTrip tmp on  tmp.tripKey = vt.tripKey order by tripKey desc,departuredate asc'
    
    EXEC SP_EXECUTESQL @strQuery,N'@totalRecordsOut INT OUTPUT', @totalRecords OUTPUT    
    print @strQuery
END

/*

select * from Trip order by tripKey desc


*/

GO
