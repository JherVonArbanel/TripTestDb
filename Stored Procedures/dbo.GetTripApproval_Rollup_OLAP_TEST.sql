SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--,@SiteKey=0,@FromDate='2013-01-01 00:00:00'--select @p15
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE  [dbo].[GetTripApproval_Rollup_OLAP_TEST]
	@pageNo As int,
	@pageSize As int,
	@sqlString As nvarchar(MAX),
	@filterType As nvarchar(50),
	@sortField As nvarchar(50),
	@sortType As nvarchar(50),	
	@IsRgUsed bit,
	@numRg1 int=0 , 
	@RgValue1 varchar (255)='',
	@numRg2 int=0 , 
	@RgValue2 varchar (255)='',  
	@clientId As varchar(MAX),
	@groupby varchar(100),
	@drillDown int =0 ,
	@ReportData int = 6 ,
	@ForeignStatus varchar(10) = '',
 	@TotalRecords int OUTPUT
AS
DECLARE @SQL1 As nvarchar(MAX),
		@SQL2 As nvarchar(MAX),
		@SQL3 As nvarchar(MAX),
		@SQL4 As nvarchar(MAX),
		@SQL5 As nvarchar(MAX),
		@VAL1 As int,
		@VAL2 As int,
		@VAL4 As  nvarchar(50),
		@sortColumn As nvarchar(50)		    

	SET @VAL1 = (@pageNo-1)*@pageSize + 1
	SET @VAL2 = @pageNo * @pageSize

--CLIENTS TEMP TABLE
CREATE TABLE #tmpClientID
(ClientID int)

create table #supplierType  
    (tripType  varchar(10))
if ( @filterType ='all')
begin
  set @filterType ='air,car,hotel'
end 
insert #supplierType (tripType )
select * from ufn_CSVToTable ( @filterType)  
Insert Into #tmpClientID
Select * From dbo.ufn_CSVToTable(Replace(@ClientID,'''',''))

--**Replace dbo.Trip to Trip in Sqlstring variable
Select @sqlString = Replace(@sqlString,'dbo.trip.','Trip.')

--ForeignStatus Temp Table
create table #ForeignStatus (trip_Status  int)

if(isnull(@ForeignStatus,'')='' or @ForeignStatus ='All')
	begin
		insert into #ForeignStatus 
		select 0 union select 1 
	end
else 
	begin
		insert into #ForeignStatus select * From ufn_CSVToTable (@ForeignStatus)
	end
--End	

-- print 'here1'	
IF @groupby = 'None'
   BEGIN	
	
	IF  @filterType ='Air'
		BEGIN
	Select @sqlString = Replace(@sqlString,'vw.dk','Trip.dk')
	CREATE TABLE #tempAir
	(
		rowNum int IDENTITY(1,1) Primary Key NOT NULL,
		approverId int, 
		createDT datetime, 
		pnr char(6), 
		client_address varchar(4000),
		reason_code varchar(max),
		isTripApproved bit,
		approvedComment varchar(500),
		qPlaced varchar(100),
		approver varchar(200),
		approvedDate datetime,
		clientNotified datetime,
		clientNotifiedGUID uniqueIdentifier,
		isOpsCleared bit,
		opsCleared_date datetime,
		trip_id int,
		passenger_name varchar(255),
		create_date datetime,
		issue_date datetime,
 		client_id char(10), 
		dk varchar(50), 
		cust_name varchar(255),
		dk_id int,
		qPlacedDT datetime,
		startDateTime datetime,
		fare float,
		vendor varchar(50),
		Tripstatus int,
		UdidSummary varchar(4000),
		VendorName varchar(255),
		ForeignStatus int
    )
		IF @sortField = 'Passenger Name'
		   BEGIN
			 SET @sortColumn = 'trip.Passenger_Name'
		   END
		ELSE IF @sortField = 'Approver'
		   BEGIN
			 SET @sortColumn = 'PTA.Approver'
		   END
		ELSE IF @sortField = 'Status'
		   BEGIN
			 SET @sortColumn = 'PTA.IsTripApproved'
		   END		
		ELSE IF @sortField = 'Status Date'
		   BEGIN
			 SET @sortColumn = 'PTA.ApprovedDT'
		   END	
		ELSE IF @sortField = 'Value'
		   BEGIN
			 SET @sortColumn = 'TRIP.Current_Rate'
		   END
		ELSE IF @sortField = 'Reason'
		   BEGIN
			 SET @sortColumn = 'PTA.ApprovedComment'
		   END		   	
		IF  @sortType ='Descending'
		   BEGIN
			SET @sortType = 'DESC'
		   END
		ELSE
		   BEGIN
			SET @sortType = 'ASC'
		   END
			
			SET @SQL1 = 'SELECT  PTA.PreTripApprovalID, PTA.CreateDT, PTA.PNR, 
					PTA.ClientAddresses, PTA.ApprovalReasonCode, PTA.IsTripApproved, 
					PTA.ApprovedComment, PTA.QPlaced, PTA.Approver, PTA.ApprovedDT, 
					PTA.ClientNotified, PTA.ClientNotifiedGUID, PTA.IsOPSCleared, 
					PTA.OPSClearedDT, ISNULL(Trip.trip_id, 0) AS trip_id, ISNULL(Trip.Passenger_Name, '''') AS Passenger_Name, 
					ISNULL(Trip.creation_date, ''1/1/2000'') AS creation_date, ISNULL(Trip.issue_date, ''1/1/1900'') AS issue_date, 
					ISNULL(Trip.client_id,  0 ) AS client_id, Trip.dk, NewClient.CustName, Trip.dk_id, PTA.QPlacedDT, 
					Trip.StartDateTime, current_rate as booked_fare, Trip.carrier, Trip.TripStatus,Trip.UDIDSummary,Trip.Vendorname,
					Trip.ForeignStatus
					
			FROM	dbo.AIOLAP_Trip Trip INNER JOIN
                    dbo.AIOLAP_NewClient NewClient ON Trip.Dk_Id = NewClient.dk_id INNER JOIN
                    dbo.AIOLAP_PreTripApproval PTA ON Trip.trip_id = PTA.trip_id INNER JOIN
                    #tmpClientID Clients on Trip.Client_ID = Clients.ClientID INNER JOIN
                    #ForeignStatus FS on ForeignStatus = trip_Status
                    Where Trip.Type = ''Air'' And  trip.haveair = 1  and current_rate > 0 and ' + @sqlString
                    
			
			--IF(@IsRgUsed = 1)
			--	BEGIN
			--			SET @SQL1 +='LEFT OUTER JOIN (SELECT DISTINCT TRIP_ID FROM AIOLAP_Trip_UDID  TU   WHERE ((num = ' + convert (varchar(10),@numRg1) + ' AND val = ISNULL(NULLIF(''' + @RgValue1 + ''',''Default''),val)) 
			--							or (num = ' + convert (varchar(10),@numRg2) + ' and val= ISNULL(NULLIF(''' + @RgValue2 + ''',''Default''),val)))
			--							 )  AS TU ON TRIP.TRIP_ID=TU.TRIP_ID '-- +
			--	END
			
			--SET @SQL1 += ' WHERE Trip.Type = ''Air''  trip.haveair = 1  and current_rate > 0 and trip.client_id in (' + @clientId + ') and ' + @sqlString   
			--SET @SQL1 += ' WHERE Trip.Type = ''Air'' And  trip.haveair = 1  and current_rate > 0 and ' + @sqlString   
			--SET @SQL1 +=  	case when @sortField <> '' then + ' order by ' + @sortColumn + ' ' + @sortType  else '' end
			
			SET @SQL2 = @SQL1

    INSERT INTO #tempAir
    (
		approverId, 
		createDT, 
		pnr, 
		client_address,
		reason_code,
		isTripApproved,
		approvedComment,
		qPlaced,
		approver,
		approvedDate,
		clientNotified,
		clientNotifiedGUID,
		isOpsCleared,
		opsCleared_date,
		trip_id,
		passenger_name,
		create_date,
		issue_date,
 		client_id, 
		dk, 
		cust_name,
		dk_id,
		qPlacedDT,
		startDateTime,
		fare,
		vendor,
		Tripstatus,
		UdidSummary,
		VendorName,
		ForeignStatus
    )
    EXEC(@SQL1)
	
	--Rajesh Started for approval report
	If @ReportData&8 = 8 --ONLY LIST DATA
		Begin
			PRINT 'Only List Data'	
			SELECT	rownum,approverId,createDT, pnr, client_address,reason_code,isTripApproved,approvedComment,qPlaced,approver,
			approvedDate,clientNotified,clientNotifiedGUID,isOpsCleared,opsCleared_date,trip_id,passenger_name,create_date,
			issue_date,client_id, dk, cust_name,dk_id,qPlacedDT,startDateTime,fare,vendor,Tripstatus,UdidSummary  
			FROM	#tempAir 	
			--left outer join @tmpUDIDDetails udid on (#tempAir.trip_id = udid .tripID    and #tempAir.rowNum  = udid .rowid )
	
			WHERE rowNum >=@VAL1 AND rowNum<=@VAL2 order by rowNum
			SELECT  @TotalRecords =  Count(*) From   #tempAir 				
		End
	If @ReportData&4 = 4 OR @ReportData&6 = 6--ONLY MATRIX DATA
		Begin			
			If @drillDown = 0
				Begin
					PRINT 'Only Matrix Data'	   
				    SELECT Count(isnull(fare,0)) As TotalCountApprovedAir, Sum(fare) As TotalCostAirApprovedTrip, ForeignStatus  FROM #tempAir  WHERE isTripApproved=1 
				    SELECT Count(isnull(fare,0)) AS TotalCountDeniedAir, Sum(fare)  As TotalCostAirDeniedTrip, ForeignStatus FROM #tempAir WHERE isTripApproved=0 AND approvedDate <> '1/1/2000'
				    SELECT Count(isnull(fare,0)) As TotalCountPendingAir, Sum(fare)  As TotalCostAirPendingTrip, ForeignStatus FROM #tempAir WHERE isTripApproved=0 And approvedDate = '1/1/2000'			   			  					
				    Union -- Domestic
				    SELECT Count(isnull(fare,0)) As TotalCountApprovedAir, Sum(fare) As TotalCostAirApprovedTrip, ForeignStatus  FROM #tempAir  WHERE isTripApproved=1 AND ForeignStatus = 0
				    SELECT Count(isnull(fare,0)) AS TotalCountDeniedAir, Sum(fare)  As TotalCostAirDeniedTrip, ForeignStatus FROM #tempAir WHERE isTripApproved=0 AND approvedDate <> '1/1/2000' AND ForeignStatus = 0
				    SELECT Count(isnull(fare,0)) As TotalCountPendingAir, Sum(fare)  As TotalCostAirPendingTrip, ForeignStatus FROM #tempAir WHERE isTripApproved=0 And approvedDate = '1/1/2000' AND ForeignStatus = 0			   			  					
				    Union -- International
				    SELECT Count(isnull(fare,0)) As TotalCountApprovedAir, Sum(fare) As TotalCostAirApprovedTrip, ForeignStatus  FROM #tempAir  WHERE isTripApproved=1 AND ForeignStatus = 1
				    SELECT Count(isnull(fare,0)) AS TotalCountDeniedAir, Sum(fare)  As TotalCostAirDeniedTrip, ForeignStatus FROM #tempAir WHERE isTripApproved=0 AND approvedDate <> '1/1/2000' AND ForeignStatus = 1
				    SELECT Count(isnull(fare,0)) As TotalCountPendingAir, Sum(fare)  As TotalCostAirPendingTrip, ForeignStatus FROM #tempAir WHERE isTripApproved=0 And approvedDate = '1/1/2000'	AND ForeignStatus = 1		   			  									    				    
				End
			Else
				Begin
					PRINT 'Only Matrix Data'
					create table #airVendors 
					( rowID int  IDENTITY(1,1) NOT NULL,    
						vendor   varchar(50),
						total   float  )
					INSERT #airVendors (vendor,total )
			        	SELECT  vendor ,sum(t.fare) from #tempAir t   group by vendor  order by SUM(fare) desc 		  
			  		    SELECT Count(isnull(fare,0)) As TotalCountApprovedAir, Sum(fare) As TotalCostAirApprovedTrip, #tempAir.vendor  FROM #tempAir inner join  #airVendors a on  #tempAir.vendor= a.vendor WHERE isTripApproved=1 group by #tempAir.vendor,rowid  order by rowID asc
					    SELECT Count(isnull(fare,0)) AS TotalCountDeniedAir, Sum(fare)  As TotalCostAirDeniedTrip, #tempAir.vendor FROM #tempAir inner join  #airVendors a on  #tempAir.vendor= a.vendor WHERE isTripApproved=0 And approvedDate <> '1/1/2000' group by #tempAir.vendor,rowid   order by rowID asc
					    SELECT Count(isnull(fare,0)) As TotalCountPendingAir, Sum(fare)  As TotalCostAirPendingTrip, #tempAir.vendor FROM #tempAir inner join  #airVendors a on  #tempAir.vendor= a.vendor WHERE isTripApproved=0 And approvedDate = '1/1/2000' group by #tempAir.vendor ,rowid  order by rowID asc
					    SELECT #tempAir.vendor,VendorName FROM #tempAir 
						   inner join  #airVendors a on  #tempAir.vendor= a.vendor 
							--INNER JOIN dbo.CARRIER_LookUp ON dbo.CARRIER_LookUp.L_KEY = #tempAir.vendor 
						group by #tempAir.vendor,VendorName,rowid  
						order by rowID asc	   
					DROP TABLE #airVendors
				END 
			
			DROP TABLE #tempAir							
		End
	If @ReportData&2 = 2 OR @ReportData&6 = 6 --ONLY CURRENT LIST DATA
		Begin
			PRINT 'Only Current List Data'
			SET   @SQL5='SELECT trip.passenger_name,trip.trip_id,trip.pnr,trip.MiniItinStr,trip.creation_date,
				   trip.startDateTime,(TA.Fare) As tripfare,TA.ClientNotified ,TA.ApprovalReasonCode as reason_code, TA.ClientNotifiedGUID 
				   FROM  AIOLAP_PreTripApproval TA INNER JOIN AIOLAP_Trip trip ON trip.pnr = TA.pnr
				   WHERE  trip.haveair = 1  and current_rate > 0  and TA.IsTripApproved=0 And TA.ApprovedDT = ''1/1/2000'' and TA.ClientNotified <> ''1/1/2000'' 
				   and trip.StartDatetime > getdate()+1 and trip.client_id in (' + @clientId + ') and ' + @sqlString
			print @sql5
			EXEC(@SQL5)			
		End
	End		
	--Rajesh Ended for approval report 
	ELSE IF @filterType ='Car'
		BEGIN
Select @sqlString = Replace(@sqlString,'vw.dk','Trip.dk')
	CREATE TABLE #tempCar
	(
		rowNum int IDENTITY(1,1) Primary Key NOT NULL,
		approverId int, 
		createDT datetime, 
		pnr char(6), 
		client_address varchar(4000),
		reason_code varchar(max),
		isTripApproved bit,
		approvedComment varchar(500),
		qPlaced varchar(100),
		approver varchar(200),
		approvedDate datetime,
		clientNotified datetime,
		clientNotifiedGUID uniqueIdentifier,
		isOpsCleared bit,
		opsCleared_date datetime,
		trip_id int,
		passenger_name varchar(255),
		create_date datetime,
		issue_date datetime,
 		client_id char(10), 
		dk varchar(50), 
		cust_name varchar(255),
		dk_id int,
		qPlacedDT datetime,
		startDateTime datetime,
		fare float,
		vendor varchar(100),
		Tripstatus int,
		UdidSummary varchar(4000),
		VendorName varchar(255),
		ForeignStatus int 
    )

	--IF @sortField <> ''
	-- BEGIN
		IF @sortField = 'Passenger Name'
		   BEGIN
			 SET @sortColumn = 'trip.Passenger_Name'
		   END
		ELSE IF @sortField = 'Approver'
		   BEGIN
			 SET @sortColumn = 'PTA.Approver'
		   END
		ELSE IF @sortField = 'Status'
		   BEGIN
			 SET @sortColumn = 'PTA.IsTripApproved'
		   END		
		ELSE IF @sortField = 'Status Date'
		   BEGIN
			 SET @sortColumn = 'PTA.ApprovedDT'
		   END	
		ELSE IF @sortField = 'Value'
		   BEGIN
			 SET @sortColumn = 'Trip.Current_Rate'
		   END
		ELSE IF @sortField = 'Reason'
		   BEGIN
			 SET @sortColumn = 'PTA.ApprovedComment'
		   END		   	
		IF  @sortType ='Descending'
		   BEGIN
			SET @sortType = 'DESC'
		   END
		ELSE
		   BEGIN
			SET @sortType = 'ASC'
		   END

			SET @SQL1 = 'SELECT  PTA.PreTripApprovalID, PTA.CreateDT, PTA.PNR, 
			PTA.ClientAddresses, PTA.ApprovalReasonCode, PTA.IsTripApproved, 
			PTA.ApprovedComment, PTA.QPlaced, PTA.Approver, PTA.ApprovedDT, 
			PTA.ClientNotified, PTA.ClientNotifiedGUID, PTA.IsOPSCleared, 
			PTA.OPSClearedDT, ISNULL(Trip.trip_id, 0) AS trip_id, ISNULL(Trip.Passenger_Name, '''') AS Passenger_Name, 
			ISNULL(Trip.creation_date, ''1/1/2000'') AS creation_date, ISNULL(Trip.issue_date, ''1/1/1900'') AS issue_date, 
			ISNULL(Trip.client_id,  0 ) AS client_id, Trip.dk, NewClient.CustName, Trip.dk_id, PTA.QPlacedDT, 
			Trip.StartDateTime,Abs((Trip.original_Rate )  / 
			CASE WHEN (ratePlan = ''WY'') THEN 5 WHEN (ratePlan = ''WK'') THEN 5 WHEN (ratePlan = ''DY'') THEN 1 
			WHEN (ratePlan = ''WD'') THEN 2 WHEN (ratePlan = ''MY'') THEN 30 ELSE 1 END) * nights_days as price,
			TRIP.vendor, Trip.TripStatus ,Trip.UdidSummary ,Trip.VendorName,
			Trip.ForeignStatus
			FROM    dbo.AIOLAP_Trip Trip INNER JOIN
                    dbo.AIOLAP_NewClient NewClient ON Trip.Dk_Id = NewClient.dk_id INNER JOIN
                    dbo.AIOLAP_PreTripApproval PTA ON Trip.trip_id = PTA.trip_id INNER JOIN 
                    #ForeignStatus FS on ForeignStatus = trip_Status
                    WHERE Trip.Type = ''Car'' And trip.havecar = 1  and  original_Rate > 0 and Trip.client_id in (' + @clientId + ') and ' + @sqlString  
  		
			--IF(@IsRgUsed = 1)
			--	BEGIN
			--			SET @SQL1 +=' LEFT OUTER JOIN (SELECT DISTINCT TRIP_ID FROM AIOLAP_Trip_UDID  TU   WHERE ((num = ' + convert (varchar(10),@numRg1) + ' AND val = ISNULL(NULLIF(''' + @RgValue1 + ''',''Default''),val)) 
			--							or (num = ' + convert (varchar(10),@numRg2) + ' and val=ISNULL(NULLIF(''' + @RgValue2 + ''',''Default''),val)))
			--							 )  AS TU ON TRIP.TRIP_ID=TU.TRIP_ID '-- +
			--	END
			
				--SET @SQL1 += ' WHERE Trip.Type = ''Car'' And trip.havecar = 1  and  original_Rate > 0 and Trip.client_id in (' + @clientId + ') and ' + @sqlString   
				--SET @SQL1 +=  	case when @sortField <> '' then + ' order by ' + @sortColumn + ' ' + @sortType  else '' end
    INSERT INTO #tempCar
    (
		approverId, 
		createDT, 
		pnr, 
		client_address,
		reason_code,
		isTripApproved,
		approvedComment,
		qPlaced,
		approver,
		approvedDate,
		clientNotified,
		clientNotifiedGUID,
		isOpsCleared,
		opsCleared_date,
		trip_id,
		passenger_name,
		create_date,
		issue_date,
 		client_id, 
		dk, 
		cust_name,
		dk_id,
		qPlacedDT,
		startDateTime,
		fare,
		vendor,
		Tripstatus,
		UdidSummary,
		vendorName,
		ForeignStatus  
    )
        EXEC(@SQL1)
If @ReportData&8 = 8 --ONLY LIST DATA
Begin
	PRINT 'Only List Data'
		SELECT rownum,approverId,createDT, pnr, client_address,reason_code,isTripApproved,approvedComment,qPlaced,
		approver,approvedDate,clientNotified,clientNotifiedGUID,isOpsCleared,opsCleared_date,trip_id,
		passenger_name,create_date,issue_date,client_id, dk, cust_name,dk_id,qPlacedDT,startDateTime,
		fare,vendor,Tripstatus,UdidSummary  FROM  #tempCar 
 	--left outer join @tmpUDIDDetailCar udid on (#tempCar.trip_id = udid .tripID    and #tempCar.rowNum  = udid .rowid )
	WHERE rowNum >=@VAL1 AND rowNum<=@VAL2 order by rowNum
 
	SELECT  @TotalRecords =  Count(*) From   #tempCar
End
If @ReportData&4 = 4 OR @ReportData&6 = 6--ONLY MATRIX DATA
Begin
	If @drillDown = 0
	Begin
		PRINT 'Only Matrix Data'
			   SELECT Count(isnull(fare,0)) As TotalCountApprovedCar, Sum(fare) As TotalCostCarApprovedTrip FROM #tempCar WHERE isTripApproved=1
			   SELECT Count(isnull(fare,0)) As TotalCountDeniedCar, Sum(fare)  As TotalCostCarDeniedTrip FROM #tempCar WHERE isTripApproved=0 And approvedDate <> '1/1/2000'
			   SELECT Count(isnull(fare,0)) As TotalCountPendingCar, Sum(fare)  As TotalCostCarPendingTrip FROM #tempCar  WHERE isTripApproved=0 And approvedDate = '1/1/2000'
			UNION -- Domestic
			   SELECT Count(isnull(fare,0)) As TotalCountApprovedCar, Sum(fare) As TotalCostCarApprovedTrip FROM #tempCar WHERE isTripApproved=1 AND ForeignStatus = 0
			   SELECT Count(isnull(fare,0)) As TotalCountDeniedCar, Sum(fare)  As TotalCostCarDeniedTrip FROM #tempCar WHERE isTripApproved=0 And approvedDate <> '1/1/2000' AND ForeignStatus = 0
			   SELECT Count(isnull(fare,0)) As TotalCountPendingCar, Sum(fare)  As TotalCostCarPendingTrip FROM #tempCar  WHERE isTripApproved=0 And approvedDate = '1/1/2000' AND ForeignStatus = 0
			UNION -- International
			   SELECT Count(isnull(fare,0)) As TotalCountApprovedCar, Sum(fare) As TotalCostCarApprovedTrip FROM #tempCar WHERE isTripApproved=1 AND ForeignStatus = 1
			   SELECT Count(isnull(fare,0)) As TotalCountDeniedCar, Sum(fare)  As TotalCostCarDeniedTrip FROM #tempCar WHERE isTripApproved=0 And approvedDate <> '1/1/2000' AND ForeignStatus = 1
			   SELECT Count(isnull(fare,0)) As TotalCountPendingCar, Sum(fare)  As TotalCostCarPendingTrip FROM #tempCar  WHERE isTripApproved=0 And approvedDate = '1/1/2000' AND ForeignStatus = 1			   			   
	End
Else
	Begin
		PRINT 'Only Matrix Data'
				 create table #carVendors 
		( 
			rowID int  IDENTITY(1,1) NOT NULL,    
			vendor   varchar(50),
			total   float  )
			
			INSERT #carVendors (vendor,total )		  
			SELECT   vendor ,sum(t.fare) from #tempCar t   group by vendor  order by SUM(fare) desc 
				
			SELECT Count(isnull(fare,0)) As TotalCountApprovedCar, Sum(fare) As TotalCostCarApprovedTrip, #tempCar.vendor FROM #tempCar  inner join #carVendors c on #tempCar.vendor =c.vendor WHERE isTripApproved=1 group by #tempCar.vendor,rowid order by rowid asc 



			SELECT Count(isnull(fare,0)) As TotalCountDeniedCar, Sum(fare)  As TotalCostCarDeniedTrip, #tempCar.vendor FROM #tempCar inner join #carVendors c on #tempCar.vendor =c.vendor WHERE isTripApproved=0 And approvedDate <> '1/1/2000' group by #tempCar.vendor,rowid order by rowid asc
			SELECT Count(isnull(fare,0)) As TotalCountPendingCar, Sum(fare)  As TotalCostCarPendingTrip, #tempCar.vendor FROM #tempCar inner join #carVendors c on #tempCar.vendor =c.vendor WHERE isTripApproved=0 And approvedDate = '1/1/2000' group by #tempCar.vendor,rowid order by rowid asc 
			SELECT #tempCar.vendor,  VendorName 
			FROM #tempCar 
			inner join #carVendors c on #tempCar.vendor =c.vendor  
			--INNER JOIN  dbo.Car_LookUp ON dbo.Car_LookUp.CODE = #tempCar.vendor 
			group by #tempCar.vendor,VendorName,rowid order by rowid asc


			EXEC(@SQL5)
			  
			DROP TABLE #carVendors
		 END  
		 
		DROP TABLE #tempCar  
End
	If @ReportData&2 = 2 OR @ReportData&6 = 6 --ONLY CURRENT LIST DATA
Begin
	PRINT 'Only Current List Data'
			   SET   @SQL5='SELECT trip.passenger_name,trip.trip_id,trip.pnr,trip.MiniItinStr,trip.creation_date,trip.startDateTime, 
			   TA.TotalCar As tripfare,TA.ClientNotified ,TA.ApprovalReasonCode as reason_code, TA.ClientNotifiedGUID 
			   FROM  AIOLAP_PreTripApproval TA 
			   inner join AIOLAP_Trip trip  ON trip.pnr = TA.pnr
			   WHERE TA.IsTripApproved=0 And TA.ApprovedDT = ''1/1/2000'' and TA.ClientNotified <> ''1/1/2000'' and trip.StartDatetime > getdate()+1 
			   and client_id in (' + @clientId + ') and ' + @sqlString  

			  EXEC(@SQL5)		
End

End
	ELSE IF @filterType ='Hotel'
		BEGIN
Select @sqlString = Replace(@sqlString,'vw.dk','Trip.dk')
	CREATE TABLE #tempHotel
	(
		rowNum int IDENTITY(1,1) Primary Key NOT NULL,
		approverId int, 
		createDT datetime, 
		pnr char(6), 
		client_address varchar(4000),
		reason_code varchar(max),
		isTripApproved bit,
		approvedComment varchar(500),
		qPlaced varchar(100),
		approver varchar(200),
		approvedDate datetime,
		clientNotified datetime,
		clientNotifiedGUID uniqueIdentifier,
		isOpsCleared bit,
		opsCleared_date datetime,
		trip_id int,
		passenger_name varchar(255),
		create_date datetime,
		issue_date datetime,
 		client_id char(10), 
		dk varchar(50), 
		cust_name varchar(255),
		dk_id int,
		qPlacedDT datetime,
		startDateTime datetime,		
		fare float,
		vendor varchar(100),
		Tripstatus int,
		UdidSummary varchar(4000),
		VendorName varchar(255),
		ForeignStatus int 
    )
    
	
		IF @sortField = 'Passenger Name'
		   BEGIN
			 SET @sortColumn = 'Trip.Passenger_Name'
		   END
		ELSE IF @sortField = 'Approver'
		   BEGIN
			 SET @sortColumn = 'PTA.Approver'
		   END
		ELSE IF @sortField = 'Status'
		   BEGIN
			 SET @sortColumn = 'PTA.IsTripApproved'
		   END		
		ELSE IF @sortField = 'Status Date'
		   BEGIN
			 SET @sortColumn = 'PTA.ApprovedDT'
		   END	
		ELSE IF @sortField = 'Value'
		   BEGIN
			 SET @sortColumn = 'Trip.Current_Rate'
		   END
		ELSE IF @sortField = 'Reason'
		   BEGIN
			 SET @sortColumn = 'PTA.ApprovedComment'
		   END		   	
		IF  @sortType ='Descending'
		   BEGIN
			SET @sortType = 'DESC'
		   END
		ELSE
		   BEGIN
			SET @sortType = 'ASC'
		   END    

	
			SET @SQL1 = 'SELECT  PTA.PreTripApprovalID, PTA.CreateDT, PTA.PNR, 
			PTA.ClientAddresses, PTA.ApprovalReasonCode, PTA.IsTripApproved, 
			PTA.ApprovedComment, PTA.QPlaced, PTA.Approver, PTA.ApprovedDT, 
			PTA.ClientNotified, PTA.ClientNotifiedGUID, PTA.IsOPSCleared, PTA.OPSClearedDT, 
			ISNULL(Trip.trip_id, 0) AS trip_id, ISNULL(Trip.Passenger_Name, '''') AS Passenger_Name, ISNULL(Trip.creation_date, ''1/1/2000'') AS creation_date, 
			ISNULL(Trip.issue_date, ''1/1/1900'') AS issue_date, ISNULL(Trip.client_id,  0 ) AS client_id, Trip.dk, NewClient.CustName, 
			Trip.dk_id, PTA.QPlacedDT, Trip.StartDateTime, Trip.total as total,Trip.vendor, Trip.TripStatus,Trip.UdidSummary,Trip.VendorName,
			Trip.ForeignStatus  
			 FROM   dbo.AIOLAP_Trip Trip INNER JOIN
                      dbo.AIOLAP_NewClient NewClient ON Trip.Dk_Id = NewClient.dk_id INNER JOIN
                      dbo.AIOLAP_PreTripApproval PTA ON Trip.trip_id = PTA.trip_id INNER JOIN 
					  #ForeignStatus FS on ForeignStatus = trip_Status
					  
			WHERE Trip.Type = ''Hotel'' and trip.havehotel = 1  and  Trip.total > 0  and Trip.client_id in (' + @clientId + ') and ' + @sqlString		  
			--IF(@IsRgUsed = 1)
			--	BEGIN
			--			SET @SQL1 +=' LEFT OUTER JOIN (SELECT DISTINCT TRIP_ID FROM AIOLAP_Trip_UDID  TU   WHERE ((num = ' + convert (varchar(10),@numRg1) + ' AND val = ISNULL(NULLIF(''' + @RgValue1 + ''',''Default''),val)) 
			--							or (num = ' + convert (varchar(10),@numRg2) + ' and val= ISNULL(NULLIF(''' + @RgValue2 + ''',''Default''),val)))
			--							 )  AS TU ON Trip.TRIP_ID=TU.TRIP_ID '-- +
			--	END
			
			--SET @SQL1 += ' WHERE Trip.Type = ''Hotel'' and trip.havehotel = 1  and  Trip.total > 0  and Trip.client_id in (' + @clientId + ') and ' + @sqlString   
			--SET @SQL1 +=  	case when @sortField <> '' then + ' order by ' + @sortColumn + ' ' + @sortType  else '' end	 
	   -- -- print '3'   
	 print 'Hotel-' + @sql1
    INSERT INTO #tempHotel
    (
		approverId, 
		createDT, 
		pnr, 
		client_address,
		reason_code,
		isTripApproved,
		approvedComment,
		qPlaced,
		approver,
		approvedDate,
		clientNotified,
		clientNotifiedGUID,
		isOpsCleared,
		opsCleared_date,
		trip_id,
		passenger_name,
		create_date,
		issue_date,
 		client_id, 
		dk, 
		cust_name,
		dk_id,
		qPlacedDT,
		startDateTime,
		fare,
		vendor,
		Tripstatus,
		UdidSummary,
		VendorName,
		ForeignStatus 
    )
    EXEC(@SQL1)

If @ReportData&8 = 8 --ONLY LIST DATA
Begin
	PRINT 'Only List Data'
	SELECT rownum, approverId,createDT, pnr, client_address,reason_code,isTripApproved,approvedComment,qPlaced,
		approver,approvedDate,clientNotified,clientNotifiedGUID,isOpsCleared,opsCleared_date,trip_id,
		passenger_name,create_date,issue_date,client_id, dk, cust_name,dk_id,qPlacedDT,startDateTime,
		fare,vendor,Tripstatus,UdidSummary  
	FROM  #tempHotel 
 		--left outer join @tmpUDIDDetailHotel udid on (#tempHotel.trip_id = udid .tripID    and #tempHotel.rowNum  = udid .rowid )
	WHERE rowNum >=@VAL1 AND rowNum<=@VAL2 order by rowNum

	SELECT  @TotalRecords =  Count(*) From   #tempHotel 	
End
If @ReportData&4 = 4 OR @ReportData&6 = 6--ONLY MATRIX DATA
Begin
	If @drillDown = 0
	Begin
		PRINT 'Only Matrix Data'
		   SELECT Count(isnull(fare,0)) As TotalCountApprovedHotel, Sum(fare) As TotalCostHotelApprovedTrip FROM #tempHotel WHERE isTripApproved=1
		   SELECT Count(isnull(fare,0)) As TotalCountDeniedHotel, Sum(fare)  As TotalCostHotelDeniedTrip FROM #tempHotel WHERE isTripApproved=0 And approvedDate <> '1/1/2000'
		   SELECT Count(isnull(fare,0)) As TotalCountPendingHotel , Sum(fare)  As TotalCostHotelPendingTrip FROM #tempHotel WHERE isTripApproved=0 And approvedDate = '1/1/2000'		
		   UNION -- Domestic
		   SELECT Count(isnull(fare,0)) As TotalCountApprovedHotel, Sum(fare) As TotalCostHotelApprovedTrip FROM #tempHotel WHERE isTripApproved=1 AND ForeignStatus = 0
		   SELECT Count(isnull(fare,0)) As TotalCountDeniedHotel, Sum(fare)  As TotalCostHotelDeniedTrip FROM #tempHotel WHERE isTripApproved=0 And approvedDate <> '1/1/2000' AND ForeignStatus = 0
		   SELECT Count(isnull(fare,0)) As TotalCountPendingHotel , Sum(fare)  As TotalCostHotelPendingTrip FROM #tempHotel WHERE isTripApproved=0 And approvedDate = '1/1/2000' AND ForeignStatus = 0		 
		   UNION -- International
		   SELECT Count(isnull(fare,0)) As TotalCountApprovedHotel, Sum(fare) As TotalCostHotelApprovedTrip FROM #tempHotel WHERE isTripApproved=1 AND ForeignStatus = 1
		   SELECT Count(isnull(fare,0)) As TotalCountDeniedHotel, Sum(fare)  As TotalCostHotelDeniedTrip FROM #tempHotel WHERE isTripApproved=0 And approvedDate <> '1/1/2000' AND ForeignStatus = 1
		   SELECT Count(isnull(fare,0)) As TotalCountPendingHotel , Sum(fare)  As TotalCostHotelPendingTrip FROM #tempHotel WHERE isTripApproved=0 And approvedDate = '1/1/2000' AND ForeignStatus = 1	 			   		   
	End
Else
	Begin
		PRINT 'Only Matrix Data'
			CREATE table #hotelVendors 
			( 
				rowID int  IDENTITY(1,1) NOT NULL,    
				vendor   varchar(50),
				total   float  
			)
			
			INSERT #hotelVendors (vendor,total )		  
			SELECT   vendor ,sum(t.fare) from #tempHotel t   group by vendor  order by SUM(fare) desc 
				
			SELECT Count(isnull(fare,0)) As TotalCountApprovedHotel, Sum(fare) As TotalCostHotelApprovedTrip, #tempHotel.vendor FROM #tempHotel inner join  #hotelVendors H on #tempHotel.vendor=H.vendor WHERE isTripApproved=1 group by #tempHotel.vendor,rowid order by rowid asc
			SELECT Count(isnull(fare,0)) As TotalCountDeniedHotel, Sum(fare)  As TotalCostHotelDeniedTrip, #tempHotel.vendor FROM #tempHotel  inner join  #hotelVendors H on #tempHotel.vendor=H.vendor WHERE isTripApproved=0 And approvedDate <> '1/1/2000' group by #tempHotel.vendor,rowid order by rowid asc 
			SELECT Count(isnull(fare,0)) As TotalCountPendingHotel , Sum(fare)  As TotalCostHotelPendingTrip,#tempHotel.vendor FROM #tempHotel  inner join  #hotelVendors H on #tempHotel.vendor=H.vendor WHERE isTripApproved=0 And approvedDate = '1/1/2000' group by #tempHotel.vendor,rowid order by rowid asc 
			SELECT #tempHotel.vendor, VendorName FROM #tempHotel  
			inner join  #hotelVendors H on #tempHotel.vendor=H.vendor 
--			INNER JOIN dbo.Hotel_LookUp ON dbo.Hotel_LookUp.L_KEY=#tempHotel.vendor 
			group by #tempHotel.vendor,VendorName ,rowid order by rowid asc 		
	End
End
If @ReportData&2 = 2 OR @ReportData&6 = 6 --ONLY CURRENT LIST DATA
Begin
	PRINT 'Only Current List Data'
	           -- only pending trip approval    // getdate()+1  => StartDate should be greater then deadline date, which is 24 hrs before start date
		   SET   @SQL5='SELECT Trip.passenger_name,Trip.trip_id,Trip.pnr,Trip.MiniItinStr,Trip.creation_date,Trip.startDateTime,
		   (TA.TotalHotel) As tripfare,TA.ClientNotified ,TA.ApprovalReasonCode as reason_code, TA.ClientNotifiedGUID 
		   FROM  AIOLAP_PreTripApproval TA 
		   inner join AIOLAP_Trip Trip ON Trip.pnr = TA.pnr
		   WHERE TA.IsTripApproved=0 And TA.ApprovedDT = ''1/1/2000'' and TA.ClientNotified <> ''1/1/2000'' and Trip.StartDatetime > getdate()+1 
		   and client_id in (' + @clientId + ') and ' + @sqlString  

		  --EXEC(@SQL2)
		  --EXEC(@SQL3)
		  --EXEC(@SQL4) 
		 EXEC(@SQL5)
End
	 
		 DROP TABLE #tempHotel	   
	END
	ELSE --ALL
      BEGIN  
		CREATE TABLE #tmpTripsItineraryApproval
		(
			rowNum int IDENTITY(1,1) primary key NOT NULL,
			triptype varchar(10), 
			approverId int, 
			createDT datetime, 
			pnr char(6), 
			client_address varchar(4000),
			reason_code varchar(max),
			isTripApproved bit,
			approvedComment varchar(500),
			qPlaced varchar(100),
			approver varchar(200),
			approvedDate datetime,
			clientNotified datetime,
			clientNotifiedGUID uniqueIdentifier,
			isOpsCleared bit,
			opsCleared_date datetime,
			trip_id int,
			passenger_name varchar(255),
			create_date datetime,
			issue_date datetime,
 			client_id char(10), 
			dk varchar(50), 
			cust_name varchar(255),
			dk_id int,
			qPlacedDT datetime,
			startDateTime datetime,
			fare float,
			miniitinstr varchar(200),
			tripfare float,
			Tripstatus int,
			UdidSummary varchar(4000) null,
			ForeignStatus int
		)
		
				IF @sortField = 'Passenger Name'
				   BEGIN
					 SET @sortColumn = 'Passenger_Name'
				   END
				ELSE IF @sortField = 'Approver'
				   BEGIN
					 SET @sortColumn = 'Approver'
				   END
				ELSE IF @sortField = 'Status'
				   BEGIN
					 SET @sortColumn = 'IsTripApproved'
				   END		
				ELSE IF @sortField = 'Status Date'
				   BEGIN
					 SET @sortColumn = 'ApprovedDT'
				   END	
				ELSE IF @sortField = 'Value'
				   BEGIN
					 SET @sortColumn = 'fare'
				   END
				ELSE IF @sortField = 'Reason'
				   BEGIN
					 SET @sortColumn = 'ApprovedComment'
				   END		   	
				IF  @sortType ='Descending'
				   BEGIN
					SET @sortType = 'DESC'
				   END
				ELSE
				   BEGIN
					SET @sortType = 'ASC'
				   END
				   
				   
					SET @SQL1 = 'SELECT  type,PreTripApprovalID,CreateDT,PNR,ClientAddresses,ApprovalReasonCode,IsTripApproved,
										ApprovedComment,QPlaced,Approver,ApprovedDT,ClientNotified,ClientNotifiedGUID,
										IsOPSCleared,OPSClearedDT,vw.trip_id,Passenger_Name,vw.creation_date,issue_date,client_id,dk,CustName,dk_id,
										QPlacedDT,StartDateTime,fare,vw.miniitinstr,vw.tripfare , vw.TripStatus,UDIDSummary, ForeignStatus 
										FROM vw_AuditApprovals_OLAP vw INNER JOIN 
										#supplierType SType on vw.type = Stype.triptype INNER JOIN
										#tmpClientID Clients on vw.Client_ID = Clients.ClientID INNER JOIN 
										#ForeignStatus FS on ForeignStatus = trip_Status'
					--IF(@IsRgUsed = 1)
					--	BEGIN
					--		SET @SQL1 +=' INNER JOIN (SELECT DISTINCT TRIP_ID FROM AIOLAP_Trip_UDID  TU   WHERE ((num = ' + convert (varchar(10),@numRg1) + ' AND val = ISNULL(NULLIF(''' + @RgValue1 + ''',''Default''),val))
					--							or (num = ' + convert (varchar(10),@numRg2) + ' and val= ISNULL(NULLIF(''' + @RgValue2 + ''',''Default''),val)))
					--							 )  AS TU ON vw.TRIP_ID=TU.TRIP_ID '-- +
					--	END				
					SET @SQL1 +='  WHERE  (vw.type=''Air'' and  haveair = 1  and current_rate  >= 0) or (vw.type=''Car'' and havecar = 1  and  original_Rate  >= 0) or ( vw.type=''Hotel'' and havehotel = 1  and  total >= 0) and ' + @sqlString   +  CASE WHEN  @sortColumn 
<> '' THEN  ' order by ' + @sortColumn + ' ' + @sortType ELSE '' END 
		
		
			  -- -- print '4'  
			  print @SQL1
			  
		
			  
			INSERT INTO #tmpTripsItineraryApproval
			(
				triptype, 
				approverId, 
				createDT, 
				pnr, 
				client_address,
				reason_code,
				isTripApproved,
				approvedComment,
				qPlaced,
				approver,
				approvedDate,
				clientNotified,
				clientNotifiedGUID,
				isOpsCleared,
				opsCleared_date,
				trip_id,
				passenger_name,
				create_date,
				issue_date,
 				client_id, 
				dk, 
				cust_name,
				dk_id,
				qPlacedDT,
				startDateTime,
				fare,
				miniitinstr,
				tripfare,
				Tripstatus,
				UDIDSummary,
				ForeignStatus
		      )
		  
			 EXEC(@SQL1)		
	
			If @ReportData&8 = 8 --ONLY LIST DATA
			Begin
			   PRINT 'Only List Data'	
			
			   SELECT triptype, 
				approverId, 
				createDT, 
				pnr, 
				client_address,
				reason_code,
				isTripApproved,
				approvedComment,
				qPlaced,
				approver,
				approvedDate,
				clientNotified,
				clientNotifiedGUID,
				isOpsCleared,
				opsCleared_date,
				trip_id,
				passenger_name,
				create_date,
				issue_date,
 				client_id, 
				dk, 
				cust_name,
				dk_id,
				qPlacedDT,
				startDateTime,
				fare,
				miniitinstr,
				tripfare,
				Tripstatus,
				UDIDSummary,
				ForeignStatus
			   FROM  #tmpTripsItineraryApproval 
			   ---left outer join @tmpUDIDDetailsAll udid on (#tmpTripsItineraryApproval.trip_id = udid .tripID  and #tmpTripsItineraryApproval.triptype  = udid .type and #tmpTripsItineraryApproval.rowNum  = udid .rowid )
				WHERE rowNum >=@VAL1 AND rowNum<=@VAL2 --order by rowNum		
				
			   Update Statistics #tmpTripsItineraryApproval
				
			   SELECT  @TotalRecords =  Count(*) From   #tmpTripsItineraryApproval								
			End
			If @ReportData&4 = 4 OR @ReportData&6 = 6--ONLY MATRIX DATA
			Begin
			   PRINT 'Consolidate Matrix Data' 
			   --SELECT 
					 -- isnull( SUM(fare+fare+fare),0) as TotalCountApprovedTrip, count(*) as TotalCostApprovedTrip, 'Air' as triptype, 2 as ForeignStatus
			   --From #tmpTripsItineraryApproval where triptype = 'Air'
			   --UNION
			   --SELECT 
					 -- isnull( SUM(fare+fare+fare),0) as TotalCountApprovedTrip, count(*) as TotalCostApprovedTrip, 'Car' as triptype, 2 as ForeignStatus
			   --From #tmpTripsItineraryApproval where triptype = 'Car'
			   --UNION
			   --SELECT 
					 -- isnull( SUM(fare+fare+fare),0) as TotalCountApprovedTrip, count(*) as TotalCostApprovedTrip, 'Hotel' as triptype, 2 as ForeignStatus
			   --From #tmpTripsItineraryApproval where triptype = 'Hotel'			   
			   
			   --UNION ALL
			   
			   SELECT Count(isnull(fare,0)) As TotalCountApprovedTrip , Sum(fare) As TotalCostApprovedTrip ,triptype, ForeignStatus  FROM #tmpTripsItineraryApproval  WHERE isTripApproved=1 group by triptype, ForeignStatus
				UNION ALL
			   SELECT Count(isnull(fare,0)) As TotalCountApprovedTrip , Sum(fare) As TotalCostApprovedTrip ,triptype, 2 as ForeignStatus  FROM #tmpTripsItineraryApproval  WHERE isTripApproved=1 group by triptype
			   
			   SELECT Count(isnull(fare,0)) As TotalCountDeniedTrip, Sum(fare)  As TotalCostDeniedTrip , triptype, ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate <> '1/1/2000' group by triptype, ForeignStatus
			   UNION ALL
			   SELECT Count(isnull(fare,0)) As TotalCountDeniedTrip, Sum(fare)  As TotalCostDeniedTrip , triptype, 2 as ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate <> '1/1/2000' group by triptype
			   
			   SELECT Count(isnull(fare,0)) As TotalCountPendingTrip, Sum(fare)  As TotalCostPendingTrip ,triptype, ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate = '1/1/2000' group by triptype, ForeignStatus   --and ClientNotified <> '1/1/2000' group by triptype -- commented ClientNotified <> '1/1/2000'  for air count mismatch with air filter
			   UNION ALL
			   SELECT Count(isnull(fare,0)) As TotalCountPendingTrip, Sum(fare)  As TotalCostPendingTrip ,triptype, 2 as ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate = '1/1/2000' group by triptype   --and ClientNotified <> '1/1/2000' group by triptype -- commented ClientNotified <> '1/1/2000'  for air count mismatch with air filter
			   
			   
			   --UNION --Domestic			   
   			--   SELECT Count(isnull(fare,0)) As TotalCountApprovedTrip , Sum(fare) As TotalCostApprovedTrip ,triptype, ForeignStatus  FROM #tmpTripsItineraryApproval  WHERE isTripApproved=1 AND ForeignStatus = 1 group by triptype, ForeignStatus
			   --SELECT Count(isnull(fare,0)) As TotalCountDeniedTrip, Sum(fare)  As TotalCostDeniedTrip , triptype, ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate <> '1/1/2000' AND ForeignStatus = 1 group by triptype , ForeignStatus
			   --SELECT Count(isnull(fare,0)) As TotalCountPendingTrip, Sum(fare)  As TotalCostPendingTrip ,triptype, ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate = '1/1/2000' AND ForeignStatus = 1  group by triptype , ForeignStatus --and ClientNotified <> '1/1/2000' group by triptype -- commented ClientNotified <> '1/1/2000'  for air count mismatch with air filter
			   --UNION --International
   			--   SELECT Count(isnull(fare,0)) As TotalCountApprovedTrip , Sum(fare) As TotalCostApprovedTrip ,triptype, ForeignStatus  FROM #tmpTripsItineraryApproval  WHERE isTripApproved=1 AND ForeignStatus = 2 group by triptype, ForeignStatus
			   --SELECT Count(isnull(fare,0)) As TotalCountDeniedTrip, Sum(fare)  As TotalCostDeniedTrip , triptype, ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate <> '1/1/2000' AND ForeignStatus = 2 group by triptype, ForeignStatus 
			   --SELECT Count(isnull(fare,0)) As TotalCountPendingTrip, Sum(fare)  As TotalCostPendingTrip ,triptype, ForeignStatus FROM #tmpTripsItineraryApproval WHERE IsTripApproved=0 And approvedDate = '1/1/2000' AND ForeignStatus = 2  group by triptype, ForeignStatus  --and ClientNotified <> '1/1/2000' group by triptype -- commented ClientNotified <> '1/1/2000'  for air count mismatch with air filter		
			End   
			If @ReportData&2 = 2 OR @ReportData&6 = 6 --ONLY CURRENT LIST DATA   
			Begin
			   -- only pending trip approval    // getdate()+1  => StartDate should be greater then deadline date, which is 24 hrs before start date
			   SELECT TP.passenger_name,TP.trip_id,TP.pnr,TP.MiniItinStr,TP.create_date as creation_date,TP.startDateTime,
						(TA.Fare + TA.TotalHotel + TA.TotalCar ) As tripfare,TA.ClientNotified ,TA.ApprovalReasonCode as reason_code, 
						 TA.ClientNotifiedGUID 
			   FROM  dbo.AIOLAP_PreTripApproval TA INNER JOIN #tmpTripsItineraryApproval TP ON TP.pnr = TA.pnr
			   INNER JOIN #tmpClientID Clients on TP.client_id = Clients.ClientID 
			   WHERE TA.IsTripApproved=0 And TA.ApprovedDT = '1/1/2000' and TA.ClientNotified <> '1/1/2000' and TP.StartDatetime > getdate()+1 
			   --and client_id in (' + @clientId + ') 
			   
			   SELECT  @TotalRecords =  Count(*) FROM  dbo.AIOLAP_PreTripApproval TA INNER JOIN #tmpTripsItineraryApproval TP ON TP.pnr = TA.pnr
			   INNER JOIN #tmpClientID Clients on TP.client_id = Clients.ClientID 
			   WHERE TA.IsTripApproved=0 And TA.ApprovedDT = '1/1/2000' and TA.ClientNotified <> '1/1/2000' and TP.StartDatetime > getdate()+1
			   
				End			   			   
				EXEC(@SQL5)			   

			   DROP TABLE #tmpTripsItineraryApproval			
			   
     
     END
     
 END
ELSE
  BEGIN
  
	    
  print 'Create Table'
	CREATE TABLE #tempSubTotalTrip
		(
			rowNum int IDENTITY(1,1) Primary Key NOT NULL,
			approverId int, 
			createDT datetime, 
			pnr char(6), 
			client_address varchar(4000),
			reason_code varchar(MAX),
			isTripApproved bit,
			approvedComment varchar(500),
			qPlaced varchar(100),
			approver varchar(200),
			approvedDate datetime,
			clientNotified datetime,
			clientNotifiedGUID uniqueIdentifier,
			isOpsCleared bit,
			opsCleared_date datetime,
			trip_id int,
			passenger_name varchar(255),
			create_date datetime,
			issue_date datetime,
 			client_id char(10), 
			dk varchar(50), 
			cust_name varchar(255),
			dk_id int,
			qPlacedDT datetime,
			startDateTime datetime,
			airFare float,
			carFare float,
			hotelFare float
		 )
	   print 'Set select insert statement'
			  SET @SQL1 = 'SELECT  PreTripApprovalID, CreateDT, PTA.PNR, 
			  ClientAddresses, ApprovalReasonCode, IsTripApproved, 
			  ApprovedComment, QPlaced, Approver, ApprovedDT, 
			  ClientNotified, ClientNotifiedGUID, IsOPSCleared, OPSClearedDT, 
			  ISNULL(Trip.trip_id, 0) AS trip_id, ISNULL(Passenger_Name, '''') AS Passenger_Name, ISNULL(creation_date, ''1/1/2000'') AS creation_date, 
			  ISNULL(issue_date, ''1/1/1900'') AS issue_date, ISNULL(Trip.client_id,  0 ) AS client_id, trip.dk, CustName, 
			  Trip.dk_id, QPlacedDT, StartDateTime, current_rate as booked_fare, totalLessMC, total  
			  FROM	dbo.AIOLAP_Trip Trip INNER JOIN
                    dbo.AIOLAP_NewClient NewClient ON Trip.Dk_Id = NewClient.dk_id INNER JOIN
                    dbo.AIOLAP_PreTripApproval PTA ON Trip.trip_id = PTA.trip_id INNER JOIN #supplierType on tripType = Trip.type                     
                    WHERE  (#supplierType.tripType= ''Car'' And trip.havecar = 1  and  original_Rate > 0 ) or 
                           (#supplierType.tripType = ''Air'' And  trip.haveair = 1  and current_rate > 0) or 
                           (#supplierType.tripType = ''Hotel'' and trip.havehotel = 1  and Trip.total > 0) 
			  and newclient.client_id in (' + @clientId + ')and ' + @sqlString   

		 print 'Insert Data'
		 --print 'Subtotal-'  +  @sql1
		INSERT INTO #tempSubTotalTrip
		(
			approverId, 
			createDT, 
			pnr, 
			client_address,
			reason_code,
			isTripApproved,
			approvedComment,
			qPlaced,
			approver,
			approvedDate,
			clientNotified,
			clientNotifiedGUID,
			isOpsCleared,
			opsCleared_date,
			trip_id,
			passenger_name,
			create_date,
			issue_date,
 			client_id, 
			dk, 
			cust_name,
			dk_id,
			qPlacedDT,
			startDateTime,
			airFare,
			carFare,
			hotelFare
		 )
		EXEC(@SQL1)		      
		 
		 print 'data inserted'
		 print 'create temp subtotal table' 
		create table   #tmpSubTotal
		(
			rowId int IDENTITY(1,1) NOT NULL,   
			groupbyfield  varchar(255),  
			totalCost decimal(18,2),
			totalCount bigint ,
			average decimal (18,2)
		  ) 

		
				IF @sortField = 'Passenger Name'
				   BEGIN
				     if @groupby='Approver'
				       BEGIN
							SET @sortColumn = 'approver'
						END
					  ELSE
					   BEGIN
							SET @sortColumn = 'passenger_name'					   
					   END
				   END
				ELSE IF @sortField = 'Cost'
				   BEGIN
					 SET @sortColumn = 'totalCost'
				   END
				ELSE IF @sortField = 'Count'
				   BEGIN
					 SET @sortColumn = 'totalCount'
				   END		
				ELSE IF @sortField = 'Average'
				   BEGIN
					 SET @sortColumn = 'Average'
				   END	
				   
				IF  @sortType ='Descending'
				   BEGIN
					SET @sortType = 'DESC'
				   END
				ELSE
				   BEGIN
					SET @sortType = 'ASC'
				   END				    
				   print 'set insert statement'
					SET @SQL2 = 'select ' + CASE WHEN  @groupby='PassengerName' THEN  ' passenger_name ' 
							WHEN  @groupby='Approver' THEN 'approver ' END + '
					,SUM(ISNULL(airFare,0) + ISNULL(carFare,0) + ISNULL(hotelFare,0))as TotalCost,Count(trip_id) as TotalCount , (SUM(ISNULL(airFare,0) + ISNULL(carFare,0) + ISNULL(hotelFare,0))/Count(trip_id)) as Average  from #tempSubTotalTrip group by ' 
					+ CASE 	WHEN  @groupby='PassengerName' THEN  ' passenger_name ' 
							WHEN  @groupby='Approver' THEN 'approver ' END +  
					+ CASE WHEN @sortColumn <> '' THEN  ' order by ' + @sortColumn + ' ' + @sortType ELSE '' END
							print 'Insert data'
					insert into #tmpSubTotal (groupbyfield ,totalCost ,totalCount ,Average )
					EXEC(@SQL2)		 
		 print 'Data inserted'
		 select * from #tmpSubTotal  where  rowid > @VAL1 and rowid < @VAL2  
		 SELECT  @TotalRecords =  Count(*) From   #tmpSubTotal 
		 DROP TABLE #tmpSubTotal
		 DROP TABLE #tempSubTotalTrip
  
  END
DROP TABLE #supplierType	
GO
