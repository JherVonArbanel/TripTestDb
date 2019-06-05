SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_SendMail_PNR_Details]
AS
BEGIN
		CREATE TABLE #Temp 
		( 
		  FirstName	Varchar(50),
		  LastName Varchar(50),
		  Tripkey int,
		  TripName varchar(50),
		  RecordLocator Varchar(50),
		  StartDate Datetime,
		  EndDate Datetime,
		  CreatedDate datetime
		)

		INSERT INTO #Temp
		SELECT
			ISNULL(U.userFirstName,TP.PassengerFirstName) FirstName,
			ISNULL(U.userLastName,Tp.PassengerLastName) LastName,
			T.tripKey,
			T.tripName,
			T.recordlocator,
			T.startDate,
			T.endDate,
			T.CreatedDate
		FROM trip..trip T
		LEFT OUTER JOIN vault..[user] U ON T.userKey=U.userKey
		LEFT OUTER JOIN TripPassengerInfo TP ON T.tripKey=TP.TripKey and TP.Active = 1 
		WHERE
			CONVERT(VARCHAR(8),T.createddate,112)= CONVERT(VARCHAR(8),DATEADD(DD,-1,GETDATE()),112)
			AND ISNULL(T.recordLocator,'') <>'' and T.sitekey=3
		ORDER BY T.tripkey
  
		DECLARE @xml NVARCHAR(MAX)
		DECLARE @body NVARCHAR(MAX)

		SET @xml =CAST(( 
					SELECT 
						[FirstName] AS 'td','',
						[LastName] AS 'td','',
						[TripKey] AS 'td','',
						[TripName] AS 'td','',
						[RecordLocator] AS 'td','',
						Convert(nvarchar(max),[StartDate] ,121 ) AS 'td','',
						Convert(nvarchar(max),[EndDate] ,121 ) AS 'td','',
						Convert(nvarchar(max),[CreatedDate] ,121 ) AS 'td',''
					FROM #Temp 
					ORDER BY [CreatedDate] 
				FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

		SET @body ='<html><body>
		<H3>SMB QA PNR Details</H3>
		<table border = 1> 
		<tr>
		<th> FirstName </th> 
		<th> LastName </th>
		<th> TripKey </th> 
		<th> TripName </th>
		<th> RecordLocator </th> 
		<th> StartDate </th> 
		<th> EndDate </th> 
		<th> CreatedDate </th> 
		</tr>'    

		SET @body = @body + @xml +'</table></body></html>'


		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'SMB_PNR_DETAILS', 
		@body = @body,
		@body_format ='HTML',
		@recipients = 'sunil.kumbhar@rinira.com', 
		@subject = 'SMB QA PNR Details' ;
		select * from #Temp
		DROP TABLE #Temp
END
GO
