SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*----------------------------------------------------------------------------------------------------------------------------
EXEC Trip..[USP_WeeklyTripReport_DBMAIL] '2016-11-14 00:00:00.000', '2016-11-20 23:59:59.000'
----------------------------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [dbo].[USP_WeeklyTripReport_DBMAIL] 
(    
	@CREATEDFrom	DATETIME,
	@CREATEDTo		DATETIME
)    
AS    
BEGIN    

	EXEC [dbo].[usp_GetFinanceDetailsForBookings_Automated] @FromDate = @CREATEDFrom, @ToDate = @CREATEDTo
	
	--IF OBJECT_ID('tempdb..#WeeklyTripReport') IS NOT NULL
 --   DROP TABLE #WeeklyTripReport

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WeeklyTripReport]') AND type in (N'U'))
	DROP TABLE [dbo].[WeeklyTripReport]
	
	CREATE TABLE [WeeklyTripReport]
	(
		RowNum			TINYINT IDENTITY(1,1),
		[Description]	VARCHAR(1000),
		[Count]			INT,
	)

	--1) Total number of NEW watched trips (unique master trip ID)
	INSERT INTO [WeeklyTripReport] ([Description], [Count])  
	SELECT 'Total number of NEW watched trips (unique master trip ID)', COUNT(*) AS TotalNewWatchedTrips 
	FROM TripSaved TS 
		INNER JOIN Trip  t ON (TS.tripSavedKey = T.tripSavedKey AND TS.userKey = T.userKey )
	WHERE t.CreatedDate BETWEEN @CREATEDFrom AND @CREATEDTo

	--2) Total number of NEW 'watches" by individual (Indiv. trip watcher IDs)
	INSERT INTO [WeeklyTripReport] ([Description], [Count])  
	SELECT 'Total number of NEW "watches" by individual (Indiv. trip watcher IDs)', COUNT(DISTINCT T.userKey) AS TotalNewWatchedByIndividual
	FROM TripSaved TS 
		INNER JOIN Trip  t ON TS.tripSavedKey = T.tripSavedKey  
	WHERE t.CreatedDate BETWEEN @CREATEDFrom AND @CREATEDTo

	--3) total number of "watches" for the week (this is the sum of how many new watched trips there are for the week)
	INSERT INTO [WeeklyTripReport] ([Description], [Count])  
	SELECT 'Total number of "watches" for the week(this is the sum of how many new watched trips there are for the week)', COUNT(*) AS TotalWatchesForTheWeek
	FROM Trip 
	WHERE tripSavedKey IS NOT NULL AND CreatedDate BETWEEN @CREATEDFrom AND @CREATEDTo

	--4) Total number of remaining "active" watched trips at the end of the time perid (weekly), that have not expired
	INSERT INTO [WeeklyTripReport] ([Description], [Count])  
	SELECT 'Total number of remaining "active" watched trips at the end of the time period (weekly), that have not expired', COUNT(*) AS TotalRemainingActiveWatchedTrips
	FROM Trip 
	WHERE startDate > @CREATEDTo AND tripSavedKey IS NOT NULL

	--5) Avg length of time before trip starts (Saved Trip)
	DECLARE @tbl AS TABLE(NumberOfDays INT)
	INSERT INTO @tbl
	SELECT DATEDIFF(DAY,GETDATE(), T.startDate) AS NoDays FROM TripSaved TS INNER JOIN Trip  t
	ON (TS.tripSavedKey = T.tripSavedKey AND TS.userKey = T.userKey  ) WHERE startDate > @CREATEDTo AND t.tripSavedKey IS NOT NULL

	INSERT INTO [WeeklyTripReport] ([Description], [Count])  
	SELECT 'Avg length of time before trip starts (Saved Trip)', AVG(NumberOfDays) AS AvgLengthOfTimeBeforeTripStartsSaved FROM @tbl

	--6) Avg length of time before trip starts (Purchase Trip)
	DECLARE @tbl1 AS TABLE(NumberOfDays INT)
	INSERT INTO @tbl1
	SELECT DATEDIFF(DAY,GETDATE(), startDate) AS NoDays FROM Trip
	--WHERE tripSavedKey IS NULL AND startDate > @CREATEDTo
	WHERE tripPurchasedKey IS NOT NULL AND startDate > @CREATEDTo

	INSERT INTO [WeeklyTripReport] ([Description], [Count])  
	SELECT 'Avg length of time before trip starts (Purchase Trip)', AVG(NumberOfDays) AS AvgLengthOfTimeBeforeTripStartPurchase FROM @tbl1

	DECLARE @xml NVARCHAR(MAX)
	DECLARE @body NVARCHAR(MAX)
	DECLARE @xmlFinance NVARCHAR(MAX)
	DECLARE @bodyFinance NVARCHAR(MAX)

	SET @xml = CAST(( SELECT [RowNum] AS 'td', '', [Description] AS 'td', '',
		   [Count] AS 'td'
	FROM  [WeeklyTripReport] ORDER BY RowNum 
	FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

	SET @body ='<html><body><H3>WEEKLY REPORT FOR BRIAN - DATED From ' 
				+ CONVERT(VARCHAR(25), @CREATEDFrom, 106) + ' To ' 
				+ CONVERT(VARCHAR(25), @CREATEDTo, 106) 
				+ '</H3>
	<table border = 1> 
	<tr>
		<th> SERIAL </th> 
		<th> DESCRIPTION </th> 
		<th> COUNT </th> 
	</tr>'    

	SET @body = @body + @xml +'</table><br>' --</body></html>'

	SET @xmlFinance = CAST(( 
				SELECT tripKey AS 'td',''
				,ISNULL(IssueDate, '') AS 'td',''
				,ISNULL(CreationDate, '') AS 'td',''
				,ISNULL(PassengerName, 'NULL') AS 'td',''
				,ISNULL(AirVendor, 'NULL') AS 'td',''
				,ISNULL(AirGDS, 'NULL') AS 'td',''
				,ISNULL(GDSHotelId, 0) AS 'td',''
				,ISNULL(HotelName, 'NULL') AS 'td',''
				,ISNULL(HotelGDS, 'NULL') AS 'td',''
				,ISNULL(CarVendor, 'NULL') AS 'td',''
				,ISNULL(CarGDS, 'NULL') AS 'td',''
				,ISNULL(TotalFare, 0) AS 'td',''
				,ISNULL(BaseFare, 0) AS 'td',''
				,ISNULL(Commission, 0) AS 'td',''
				,ISNULL(AirDepartureCity, '') AS 'td',''
				,ISNULL(AirArrivalCity, '') AS 'td',''
				,ISNULL(AirDepartureDate, '') AS 'td',''
				,ISNULL(AirReturnDate, '') AS 'td',''
				,ISNULL(HotelCity, '') AS 'td',''
				,ISNULL(CarPickupCity, '') AS 'td',''
				,ISNULL(CarDropoffCity, '') AS 'td',''
				,ISNULL(recordLocator, '') AS 'td',''
				,ISNULL(AirTicketNumber, '') AS 'td',''
				,ISNULL(AirItineraryNumber, '') AS 'td',''
				,ISNULL(HotelTicketNumber, '') AS 'td',''
				,ISNULL(HotelItineraryNumber, '') AS 'td',''
				,ISNULL(CarTicketNumber, '') AS 'td',''
				,ISNULL(CarItineraryNumber, '') AS 'td',''
				,ISNULL(TravelType, '') AS 'td',''
				,ISNULL(Udid, '') AS 'td',''
				,ISNULL(TripRequestKey, 0) AS 'td',''
				,TripPurchaseKey AS 'td',''
	FROM  [FinanceDetails] 
	FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

	SET @bodyFinance = '<H3>Automated Finance Report</H3>
					<table border = 1> 
						<tr>
							<th> tripKey </th>
							<th> IssueDate </th> 
							<th> CreationDate </th> 
							<th> PassengerName </th> 
							<th> AirVendor </th> 
							<th> AirGDS </th> 
							<th> GDSHotelId </th> 
							<th> HotelName </th> 
							<th> HotelGDS </th> 
							<th> CarVendor </th> 
							<th> CarGDS </th> 
							<th> TotalFare </th> 
							<th> BaseFare </th> 
							<th> Commission </th> 
							<th> AirDepartureCity </th> 
							<th> AirArrivalCity </th> 
							<th> AirDepartureDate </th> 
							<th> AirReturnDate </th> 
							<th> HotelCity </th> 
							<th> CarPickupCity </th> 
							<th> CarDropoffCity </th> 
							<th> recordLocator </th> 
							<th> AirTicketNumber </th> 
							<th> AirItineraryNumber </th> 
							<th> HotelTicketNumber </th> 
							<th> HotelItineraryNumber </th> 
							<th> CarTicketNumber </th> 
							<th> CarItineraryNumber </th> 
							<th> TravelType </th> 
							<th> Udid </th> 
							<th> TripRequestKey </th> 
							<th> TripPurchaseKey </th> 
						</tr>'

	SET @bodyFinance = @bodyFinance + @xmlFinance + '</table></body></html>'
	SET @body = @body + @bodyFinance
	
	--EXEC msdb.dbo.sp_send_dbmail
	--	@profile_name = 'SQL ALERTING', -- replace with your SQL Database Mail Profile 
	--	@body = @body,
	--	@body_format ='HTML',
	--	@recipients = 'bruhaspathy@hotmail.com', -- replace with your email address
	--	@subject = 'E-mail in Tabular Format' ;
	DECLARE @title VARCHAR(500)
	SET @title = 'Weekly Save Trip Report For Brian and Booking Finance Detail From ' 
				+ CONVERT(VARCHAR(25), @CREATEDFrom, 106) + ' To ' 
				+ CONVERT(VARCHAR(25), @CREATEDTo, 106) 
				
	--EXEC msdb.dbo.sp_send_dbmail
	--	@profile_name = 'GKProfile', -- replace with your SQL Database Mail Profile 
	--	@body = @body,
	--	@body_format ='HTML',
	--	@recipients = 'ngopal@rinira.com', -- replace with your email address
	--	@subject = @title 
	
PRINT @body

END
GO
