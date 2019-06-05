SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/** SWITCHED TO TMAN FOR TOTAL SPEND AND TOTAL TRX - 11/9/12 SE **/
/** Changed Total TRX to be the total unique invoices - 12/17/12 SE **/
/** Changed to use new tables in Tman -- 07/11/13 NH **/

CREATE PROCEDURE [dbo].[usp_GetROISummaryDataForProgramSummary] 
( 
@clientID nvarchar(MAX), --- used for creating specific results for demos
@fromDate varchar(50), 
@toDate varchar(50), 
@dkList varchar(MAX),
@IsRgUsed bit = 0,
@RgValue1 varchar(max) = null
)
AS
BEGIN
SET ANSI_WARNINGS OFF
-----  FOR TESTING - REMOVE
--SET @dkList = @dkList + ','CRP1000910','CRP1000908''
--SET @dkList = @dkList + ','CRP1000879''
--SET @dkList = @dkList + ','CRP1000557''
DECLARE @debug int
SET @debug = 0
		
	DECLARE @roiType nvarchar(2)
	DECLARE @travelType nvarchar(2)

	--DECLARE @UDNum1 int
	--DECLARE @UDVal1 int
	--DECLARE @UDNum2 int
	--DECLARE @UDVal2 int

	DECLARE @selectClause varchar(2000)
	DECLARE @dkClause varchar(2000)
	DECLARE @dateClause varchar(2000)
	DECLARE @whereClause varchar(MAX)
	DECLARE @udidClause varchar(2000)
	DECLARE @otherClause varchar(2000)
	DECLARE @sqlQry varchar(4000)
	DECLARE @rebatePct varchar(7)

	-- Table Variable to build result sets up 
	DECLARE @tempRoiValues TABLE 
	(
		RoiType int, 
		TravelType int,
		Amount float,
		AvgAmt float, 
		cnt int,
		issueDate datetime,
		Dk varchar(50)
		
	)
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- SLE 4/10/2012 - added logic to handle conversion of unexpected date formats
	--                 can not trust that dates will come in as properly formated string
	SET @fromDate = convert(varchar, convert(datetime, @fromDate), 111) + ' 00:00:00'
	SET @toDate = convert(varchar, convert(datetime, @toDate), 111) + ' 23:59:59' 
	
		
---------------------------------
/* CREATE AND LOAD DK TABLES */
---------------------------------
------ SHOULD BE CHANGED --------
/* DK Short no longer needed */
---------------------------------
	-- Temp table to hold versions of the DK list
	DECLARE @DKTable TABLE         
		(        
		DK  VARCHAR(10)    --The string value of the DK           
		)
	
	-- Modify contents of @dkList variable and store in new var
	-- Assumption : @dkList will always have the form 'XXX#######','XXX#######'
	-- We need to extract data and form @dkListShort = '#######','#######'

	Insert into @DKTable(DK)  (select REPLACE(String,'''','') from AI.dbo.ufn_CSVToTable(@dkList))	
	--Set Client ID in temp 
	
	Declare @tmpClientID table
	(ClientID int)
	Insert into @tmpClientID(ClientID)  (select REPLACE(String,'''','') from AI.dbo.ufn_CSVToTable(@ClientID))	

	---------------------------------
	/* CREATE AND LOAD TEMP TABLES */
	---------------------------------
		
	---- Temp table to hold TOTAL transaction costs
	-- SLE 12-17-12 added invoicenum for more accurate TRX count
	CREATE TABLE #TripCost
		(
		travelType VARCHAR(10) , 
		trip_id INT ,  
		pnr CHAR(6),  
		price DECIMAL(18,2)  ,
		noOf INT ,
		Currency varchar(5),
		TripStatus int,
		Enddatetime datetime,
		invoiceNum varchar(10),
		issueDate DateTime,
		Dk varchar(50) 
		 ) 
 
	
	
	---- 10-29-2012 NH New code to support Waivers via Waiver table
	---- Temp table to hold data from ai.dbo.Waivers
	CREATE TABLE #TripWaivers        
		(        
		waiverType VARCHAR(10),
		waiverValue DECIMAL(18,2),
		OpenDtTime datetime,
		Dk varchar(50) 
		) 



-- 11JUL13 NEW TABLES FOR CHANGE TO TMAN

CREATE TABLE #AIR_TMAN
	(
	BookedOnline 		TINYINT,
	PolicySavings 		DECIMAL(18,2),
	NegotiatedSavings 	DECIMAL(18,2),
	WebSavings 			DECIMAL(18,2),
	PrepaidSavings		DECIMAL(18,2),
	AuditSearchSavings	DECIMAL(18,2),
	AgencyDiscSavings	DECIMAL(18,2),
	AwardSavings		DECIMAL(18,2),
	ExchangeAmt			DECIMAL(18,2),
	VoidAmt				DECIMAL(18,2),
	RefundAmt			DECIMAL(18,2),
	TtlTktAmt			DECIMAL(18,2),
	IssueDate			DATETIME,
	Dk varchar(50) 
	)

CREATE TABLE #CAR_TMAN
	(
	BookedOnline 		TINYINT,
	PolicySavings 		DECIMAL(18,2),
	NegotiatedSavings 	DECIMAL(18,2),
	WebSavings 			DECIMAL(18,2),
	PrepaidSavings		DECIMAL(18,2),
	AuditSearchSavings	DECIMAL(18,2),
	AgencyDiscSavings	DECIMAL(18,2),
	AwardSavings		DECIMAL(18,2),
	ExchangeAmt			DECIMAL(18,2),
	VoidAmt				DECIMAL(18,2),
	RefundAmt			DECIMAL(18,2),
	TtlCarAmt			DECIMAL(18,2),
	IssueDate			DATETIME,
	Dk varchar(50) 
	)

CREATE TABLE #HOTEL_TMAN
	(
	BookedOnline 		TINYINT,
	PolicySavings 		DECIMAL(18,2),
	NegotiatedSavings 	DECIMAL(18,2),
	WebSavings 			DECIMAL(18,2),
	PrepaidSavings		DECIMAL(18,2),
	AuditSearchSavings	DECIMAL(18,2),
	AgencyDiscSavings	DECIMAL(18,2),
	AwardSavings		DECIMAL(18,2),
	ExchangeAmt			DECIMAL(18,2),
	VoidAmt				DECIMAL(18,2),
	RefundAmt			DECIMAL(18,2),
	TtlHtlAmt			DECIMAL(18,2),
	IssueDate			DATETIME,
	Dk varchar(50) 
	)

-- 11JUL13 INSERT DATA TO NEW TABLES FOR CHANGE TO TMAN
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 1 start  AIR TMAN'

INSERT #AIR_TMAN
	(BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlTktAmt, IssueDate,DK)
	SELECT BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlTktAmt, IssueDate,DK
	FROM TMAN.DBA.TA_ROI_AIR
	WHERE dk IN (Select DK FROM @DKTable )  
		AND issuedate BETWEEN @fromDate AND @toDate
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 1 end  AIR TMAN'
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 2 start  car TMAN'
INSERT #CAR_TMAN
	(BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlCarAmt, IssueDate,DK)
	SELECT BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlCarCost, IssueDate,DK
	FROM TMAN.DBA.TA_ROI_CAR
	WHERE dk IN (Select DK FROM @DKTable )  
		AND issuedate BETWEEN @fromDate AND @toDate
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 2 end Car TMAN'
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 start Hotel TMAN'
INSERT #HOTEL_TMAN
	(BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlHtlAmt, IssueDate,DK)
	SELECT BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlHtlCost, IssueDate,DK
	FROM TMAN.DBA.TA_ROI_HOTEL
	WHERE dk IN (Select DK FROM @DKTable )  
		AND issuedate BETWEEN @fromDate AND @toDate
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 end Hotel TMAN'
--Audit Savings From OLAP
--SELECT	Sum([Audit].actual_savings) as ActualSavings,Audit.type
--FROM	TAOLAP.[dbo].[vw_AuditSavings_OLAP]  AUDIT   
--			INNER JOIN   @tmpClientID  TMPCLIENT ON AUDIT.client_id = TMPCLIENT.ClientID
--			INNER JOIN   @DKTable  TMPDK ON AUDIT.dk = TMPDK.DK
--WHERE	creation_date between @FromDate and @ToDate
--			AND (rejected_savings > 0 OR actual_savings > 0 OR pending_savings  > 0) 
--Group by Audit.type
	
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4 start trip cost'
	INSERT #TripCost
		( travelType, trip_id, pnr, price, noOf,currency ,TripStatus,Enddatetime, invoiceNum, issueDate,DK)
		SELECT type, 0, pnr, amount, tktDayNgtCount,currency,3,endTravelDate, invoiceNum, IssueDate,DK
		FROM  [TMAN].[dba].TA_SPEND_RPT   
		WHERE dk IN (Select DK FROM @DKTable )  
		AND issuedate BETWEEN @fromDate AND @toDate
		
	
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4 end trip cost'		

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 5 start TripWaivers'	
	---- 10-29-2012 NH New code to support Waivers via Waiver table
	
	--INSERT #TripWaivers 
	--	( waiverType, waiverValue ,OpendtTime,DK)
	--	SELECT waiverType, Sum(valueRecovery),OpendtTime,DK
	--	FROM  AI.dbo.waivers
	--	WHERE DK IN (Select DK FROM @DKTable )  
	--	AND OpenDtTime BETWEEN @fromDate AND @toDate
	--	Group by WaiverType,OpenDtTime,DK 
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 5 end TripWaivers'	
	---------------------------------
	/*   POLICY SAVINGS SECTION    */
	---------------------------------
	
	-------------------------	
	-- TESTING
	-------------------------	
	--SET @selectClause = 'SELECT 0, 0, '
	--'dk FROM #DK ' 
	
	
	--SET @sqlQry = @selectClause 
	--IF (@debug = 1) 
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0, 1, 0 ) 
	--ELSE
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	-------------------------	
	-- Policy Savings - AIR Lost Opportunity *** (booked + actual = original fare) - lowest_fare (LF) is savings not taken at point of sale
	-------------------------	
	
INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount , issueDate,DK) --EXEC(@sqlQry)  
 Select 0 as  RoiType , 
		Case 
		when Type = 'Air' then 1   
		when Type = 'Car' then 2   
		when Type = 'Hotel' then 3 end as TravelType,
		Sum(lost) as Amount , creation_date , vw.dk
		From
		   taolap.dbo.vw_AuditException_OLAP_BETA VW   with (nolock) 
		Inner join @DKTable TMP_DK on    VW.DK = TMP_DK.DK	
 	WHERE (creation_date BETWEEN   @fromDate AND @toDate    )  
	AND vw.foreignStatus IN(0,1) 
	AND lost > 0 and reason_Code not in ('E','A','','FJA')
    Group by Type , creation_date, Vw.Dk
    
	--PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 6 start air Policy Savings'	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	--SELECT 0, 1, ISNULL(SUM(PolicySavings),0), IssueDate,DK FROM #AIR_TMAN 
	--Group by IssueDate,DK
	--PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 6 end air Policy Savings'	
	---------------------------	
	---- Policy Savings - CAR Lost Opportunity *** ((OriginalRate - ROI_LF) * NumOfDays) *** 
	---------------------------	
	
	--PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 7 start car Policy Savings'	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	--SELECT 0, 2, ISNULL(SUM(PolicySavings),0), IssueDate,DK FROM #CAR_TMAN 
	--Group by IssueDate,DK
	-----------------------------	
	---- Policy Savings - HOTEL Lost Opportunity *** ((original_rate - ROI_LF) * nights_booked) *** 
	-----------------------------	
		
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK) 
	--SELECT 0, 3, ISNULL(SUM(PolicySavings),0), IssueDate,DK FROM #HOTEL_TMAN   
	--Group by IssueDate	,DK
	
	-------------------------------	
	-- Negotiated Contracts - AIR Savings Due to Client Contract
	-- *** (UDID91 - ( booked_fare + actual_savings )) = ( FF - original ) ***
	--      UD91 = WP value, without use of client contract, entered by file finishing script
	-------------------------------	

			
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	--SELECT 1, 1,  ISNULL(SUM(NegotiatedSavings),0), IssueDate,DK FROM #AIR_TMAN	
	--Group by IssueDate,DK
	---------------------------------	
	---- Negotiated Contracts - CAR Savings Due to Client Contract
	---- *** ((ROI_ND - originalRate) * num_days) *** ROI_f1 = 'NEG'
	---------------------------------	
	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	--SELECT 1, 2, ISNULL(SUM(NegotiatedSavings),0), IssueDate,DK FROM #CAR_TMAN
	--Group by IssueDate,DK
	-----------------------------------	
	---- Negotiated Contracts - HOTEL Savings Due to Client Contract
	---- *** ((ROI_ND - original_rate) * nights_booked) *** ROI_f1 = 'NEG'
	-----------------------------------	
	
	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK)
	--SELECT 1, 3, ISNULL(SUM(NegotiatedSavings),0), IssueDate,DK FROM #HOTEL_TMAN  
	--Group by IssueDate,DK
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	select 1 as RoiType , case 
  when type = 'Air' then 1 
  when type = 'Car' then 2
  when type = 'Hotel' then 3 end as TravelType,
 (sum(savingsAmt)) as Amount,issuedate , t.DK
 FROM TMAN.[dba].[TA_CONTRACT_RPT] t with (Nolock)
  	Inner join @DKTable TMP_DK on    t.DK = TMP_DK.DK	
Where ForeignStatus in (0,1) AND 
	issuedate BETWEEN  @fromDate AND @toDate 
	and (ND_Amt > PaidFare) 
group by type,issuedate, T.DK
	-------------------------------	
	-- Loyalty Awards - AIR  (2.5% or air volume for client's airline programs (Use carriers in PQ table that dont have ?I = Smap code))
	-- SLE 4/3/2012 - added limitation where PQline not like '%?I%' to omit all the PQ lines relating to snap codes.
	-- TODO - switch away from TripAir to the TripTickets table
	-------------------------------	

	--CREATE TABLE #LoyaltyDK        
		--(        
		--dk varchar(10),
		--carrier VARCHAR(10)
		--)
	--INSERT INTO #LoyaltyDK ( dk, carrier )
	--SELECT dk, carriercode FROM [AI].[dbo].[pq_lines]
	--WHERE dk IN (Select DK FROM @DKTable )   AND PQLine NOT LIKE '%?I%'
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	SELECT 2, 1, ISNULL(SUM(AwardSavings),0), IssueDate,DK FROM #AIR_TMAN  
	Group by IssueDate,DK
	
	-------------------------------	
	-- Loyalty Awards - CAR (WILL ALWAYS SHOW AS $0)
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) VALUES ( 2, 2, 0, GETDATE() ,null) 
	
	
	-------------------------------	
	-- Loyalty Awards - HOTEL (WILL ALWAYS SHOW AS $0)
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) VALUES ( 2, 3, 0, GETDATE() ,null) 
	
	
	-------------------------------	
	-- Determine Payment Rebate % for this Client
	-------------------------------	
	--SET @rebatePct = '0.00000'
	--SELECT @rebatePct=ISNULL(MAX(RebatePercent),0) from [AI].[dbo].[PaymentRebate]
	--WHERE DK IN ( Select DK FROM @DKTable ) AND RebateActive = 'True'
	

	-------------------------------	
	-- Payment Rebate - AIR ( x% rebate on total air spend )
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	--SELECT 3, 1,ISNULL((SUM(TtlTktAmt) * @rebatePct),0), IssueDate,DK FROM #AIR_TMAN 
	--Group by IssueDate,DK
	
	SELECT 3,1,Sum(RebateAmt),issueDate,Payment.DK 
	FROM [TMAN].[dba].[TA_ROI_PAYMENTREBATE] Payment 
	Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK  
	Where  issuedate BETWEEN  @fromDate AND @toDate and Type = 'Air'   
	Group by IssueDate,Payment.DK 
	
	-------------------------------	
	-- Payment Rebate - CAR  ( x% rebate on total car spend )
	-------------------------------	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	--SELECT 3, 2, ISNULL((SUM(TtlCarAmt) * @rebatePct ),0), IssueDate,DK FROM #CAR_TMAN
	--Group by IssueDate,DK
	
	SELECT 3,2,Sum(RebateAmt),issueDate,Payment.DK 
	FROM [TMAN].[dba].[TA_ROI_PAYMENTREBATE] Payment 
	Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK  
	Where  issuedate BETWEEN  @fromDate AND @toDate and Type = 'Car'   
	Group by IssueDate,Payment.DK 
	
	-------------------------------	
	-- Payment Rebate - HOTEL ( x% rebate on total hotel spend )
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	--SELECT 3, 3, ISNULL((SUM(TtlHtlAmt) * @rebatePct ),0), IssueDate,DK FROM #HOTEL_TMAN 
	--Group by IssueDate,DK
	
	SELECT 3,3,Sum(RebateAmt),issueDate,Payment.DK 
	FROM [TMAN].[dba].[TA_ROI_PAYMENTREBATE] Payment 
	Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK  
	Where  issuedate BETWEEN  @fromDate AND @toDate and Type = 'Hotel'   
	Group by IssueDate,Payment.DK 



---------------------------------
/*    RESERVATIONS SECTION	   */
---------------------------------
	
---------------------------------  
/*    RESERVATIONS SECTION    */  
---------------------------------  
     -------------------------------	
	-- Online Adoption - AIR  Calculate the difference between the 
	-- Agent Fee (DOM) adn the Online Fee (ONL) 
	-------------------------------	
 --  DECLARE @onlineSavings float = 0
	--DECLARE @maxDOM float = 0
	--DECLARE @maxONL float = 0
	

	--SELECT @maxDOM = MAX(fee_amount)
 --   FROM [ai].[dbo].[fee] 
 --   WHERE (fee_name = 'DOM')
	--and	dk IN (Select DK FROM @DKTable ) 
	
	--SELECT @maxONL = MAX(fee_amount)
 --   FROM [ai].[dbo].[fee] 
 --   WHERE (fee_name = 'ONL')
	--and	dk IN (Select DK FROM @DKTable ) 

	--SET @onlineSavings = @maxDOM - @maxONL
	--IF @onlineSavings < 0 
	--BEGIN
	--	SET @onlineSavings = 0
	--END

 --       -------------------------------	
	---- Online Adoption - Car & Hotel  Calculate the difference between the 
	---- Agent Fee (LAN) adn the Online Fee (OLL) 
	---------------------------------	
 --   DECLARE @HConlineSavings float = 0
	--DECLARE @HCmaxAGT float = 0
	--DECLARE @HCmaxONL float = 0

 --   SELECT @HCmaxAGT = MAX(fee_amount)
 --   FROM [ai].[dbo].[fee] 
 --   WHERE (fee_name = 'LAN')
	--and	dk IN (Select DK FROM @DKTable ) 
	
	--SELECT @HCmaxONL = MAX(fee_amount)
 --   FROM [ai].[dbo].[fee] 
 --   WHERE (fee_name = 'OLL')
	--and	dk IN (Select DK FROM @DKTable ) 

	--SET @HConlineSavings = @HCmaxAGT - @HCmaxONL
	--IF @HConlineSavings < 0 
	--BEGIN
	--	SET @HConlineSavings = 0
	--END

 -------------------------------   
 -- Online Adoption - AIR    
 -- Online fee savings (see above) times the number of online air transactions )  
 -------------------------------   
 
	
		
	
--	SET @sqlQry = @selectClause + @whereClause
--	IF (@debug = 1) 
--	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) VALUES ( 4, 1, 0, GETDATE(),null ) 
--	ELSE
--	INSERT INTO @tempRoiValues ( RoiType, TravelType,cnt, Amount, issueDate,DK ) 
--SELECT 4, 1, COUNT(*), 0 Creation_Date ,DK FROM tman.dba.ta_transaction_rpt 
--	WHERE (Booked_Online = 1) and	dk IN (Select DK FROM @DKTable )
--and creation_date between  @fromDate and @toDate 
--	AND TYPE = 'Air' GROUP BY Creation_Date,DK
    
   
---------------------------------	
--	-- Online Adoption - CAR 
--	-------------------------------	
--	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 2, 0 ) 

-- --       SET @selectClause = 'SELECT 4, 2, '
--	--SET @selectClause = @selectClause + '(COUNT(*) * ' + CAST(@HConlineSavings as nvarchar(7)) + ') FROM tman.dba.ta_transaction_rpt ' 
--	--SET @whereClause = ' WHERE (Booked_Online = 1) '
--	--SET @whereClause = @whereClause + ' and dk IN (' + @dkList + ') '
--	--SET @whereClause = @whereClause + ' and creation_date between ''' + @fromDate + ''' AND ''' + @toDate + ''''
--	--SET @whereClause = @whereClause + ' AND TYPE = ''CAR'' '
	
		
	
--	SET @sqlQry = @selectClause + @whereClause
--	IF (@debug = 1) 
--	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK ) VALUES ( 4, 2, 0, GETDATE(), null ) 
--	ELSE
--	INSERT INTO @tempRoiValues ( RoiType, TravelType, Cnt, Amount, issueDate ,DK) 
--	SELECT 4, 2, COUNT(*),0, Creation_Date ,DK  FROM tman.dba.ta_transaction_rpt 
--	 WHERE (Booked_Online = 1) and (CarHtlOnly = 1)
--	 and dk IN (Select DK FROM @DKTable ) 
--	 and creation_date between @fromDate and @toDate
--	 AND TYPE = 'CAR' GROUP BY Creation_Date,DK
    
	
	
--	-------------------------------	
--	-- Online Adoption - HOTEL 
--	-------------------------------	
--	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 3, 0 ) 

-- --      SELECT 4, 3, 
--	--(COUNT(*) *  CAST(@HConlineSavings as nvarchar(7)) ) FROM tman.dba.ta_transaction_rpt  
--	-- WHERE (Booked_Online = 1) 	 and dk IN (@dkList + ') 
--	--SET @whereClause = @whereClause + ' and creation_date between ''' + @fromDate + ''' AND ''' + @toDate + ''''
--	--SET @whereClause = @whereClause + ' AND TYPE = ''HOTEL'' '
	
		
	
--	SET @sqlQry = @selectClause + @whereClause
--	IF (@debug = 1) 
--	INSERT INTO @tempRoiValues ( RoiType, TravelType,  Amount, issueDate  ,DK) VALUES ( 4, 3, 0, GETDATE(), null ) 
--	ELSE
--	INSERT INTO @tempRoiValues ( RoiType, TravelType,Cnt, Amount, issueDate ,DK) 
--	SELECT 4, 3, COUNT(*),0, Creation_Date ,DK FROM tman.dba.ta_transaction_rpt 
--	 WHERE (Booked_Online = 1) and (CarHtlOnly = 1)
--	 and dk IN (Select DK FROM @DKTable) 
--	 and creation_date   between @fromDate and @toDate
--	 AND TYPE = 'HOTEL' GROUP BY Creation_Date,DK

	
	-------------------------------	
	-- Web Fares - AIR Savings from use of Web Fare (UD94 - Original_Fare)
	--  (UDID94 Contains the SABRE fare entered by file finish script)
	-------------------------------	

	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	SELECT 5, 1,  ISNULL(SUM(WebSavings),0), IssueDate ,DK FROM #AIR_TMAN   
	Group by IssueDate,DK
	-------------------------------	
	-- Web Fares - CAR Savings from use of Web Rate
	-- ROI_FF = lowest non-discounted rate for same car *** ROI_f1 = 'WEB' 
	-------------------------------	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK ) 
	SELECT 5, 2, ISNULL(SUM(WebSavings),0), IssueDate ,DK FROM #CAR_TMAN  
	Group by IssueDate,DK
	-------------------------------	
	-- Web Fares - HOTEL Savings from use of Web Rate
	-- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'WEB' 
	-------------------------------	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	SELECT 5, 3, ISNULL(SUM(WebSavings),0), IssueDate ,DK FROM #HOTEL_TMAN  
	Group by IssueDate,DK

	
	---- 10-29-2012 NH New code to support Waivers via Waiver table
	-------------------------------	
	-- Restriction Waivers - Waivor/Favors from SalesForce
	-- 
	-------------------------------	
	DECLARE @airTotal float = 0
	DECLARE @hotelTotal float = 0 
	DECLARE @carTotal float = 0 
	
	--select @airTotal = SUM(waiverValue)
	--from #TripWaivers
	--where waiverType = 'Air'
	
	--select @carTotal = SUM(waiverValue)
	--from #TripWaivers
	--where waiverType = 'Car'
	
	--select @hotelTotal = SUM(waiverValue)
	--from #TripWaivers
	--where waiverType = 'Hotel'
	
	-- AIR 
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,Dk ) --VALUES( 6, 1, @airTotal, GETDATE() )
	--Select 6,1,Sum(WaiverValue),OpenDtTime,dk From #TripWaivers Where waiverType = 'air'  Group by OpenDtTime,dk
	---- CAR
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,dk ) --VALUES ( 6, 2, @carTotal, GETDATE() ) 
	--Select 6,2,Sum(WaiverValue),OpenDtTime,dk From #TripWaivers  Where waiverType = 'car' Group by OpenDtTime,dk
	---- Hotel
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,dk ) --VALUES ( 6, 3, @hotelTotal, GETDATE() ) 
	--Select 6,3,Sum(WaiverValue),OpenDtTime,dk From #TripWaivers  Where waiverType = 'hotel' Group by OpenDtTime,dk
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,Dk ) --VALUES( 6, 1, @airTotal, GETDATE() )
	select 6 as RoiType , case 
  when type = 'Air' then 1 
  when type = 'Car' then 2
  when type = 'Hotel' then 3 end as TravelType,
 sum(Isnull(Amount,0)) as Amount , Opendt, IssRes.DK
	
	FROM  Tman.dba.TA_ISSRES_RPT  IssRes   
			INNER JOIN @DKTable  TMPDK ON IssRes.dk = TMPDK.DK
			--INNER JOIN #ForeignStatus FS ON FS.ForeignStatus = IssRes.ForeignStatus
	WHERE 
			 Opendt BETWEEN @FromDate AND @ToDate
			 and  IssRes.ForeignStatus in (0,1)
			 and vendorCode is not null
			 and action ='Waiver'
group by type	,Opendt, IssRes.DK
		
	-------------------------------	
	-- Prepaid - AIR - Savings from use of Prepaid Air  *** (UDID87 - Original_Fare) *** 		
	-- UDID87 contains SABRE fare for prepaid flight
	-- TODO - do not see any data in UD96
	---------------------------------	

		--GOTO CLEANUP
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	SELECT 7, 1, ISNULL(SUM(PrepaidSavings),0), IssueDate ,DK  FROM #AIR_TMAN  
	Group by IssueDate,DK
	
	-------------------------------	
	-- Prepaid - CAR - Savings from use of Prepaid Car  *** ((ROI_FF - originalRate) * numDays) *** 		
	-- ROI_f1 = 'PRE' 
	-- TODO - no data found yet
	-------------------------------	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	SELECT 7, 2, ISNULL(SUM(PrepaidSavings),0), IssueDate,DK FROM #CAR_TMAN 
	Group by IssueDate,DK
	
	-------------------------------	
	-- Prepaid - HOTEL
	-- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'PRE' 
	-------------------------------	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	SELECT 7, 3, ISNULL(SUM(PrepaidSavings),0), IssueDate,DK FROM #HOTEL_TMAN   
	Group by IssueDate,DK

	---------------------------------
	/*       SAVINGS SECTION	   */
	---------------------------------
	
	-------------------------------	
	-- Audit Searches - AIR - Savings found AND TAKEN from nightly robot searches   
	-- *** Actual_savings (found by robot)
	-------------------------------	
	
	--Persist AuditSavings records into temporary table
	--This is added to have records of AuditSavingSearchs from OLAP db in order to match ROI Audit Savings with Audit Savings searches report.
	Create table #AuditSearchSaving 
	(ActualSavings  DECIMAL(38,2),Type VARCHAR(10), IssueDate DATETIME,DK varchar(50))
	
	INSERT INTO #AuditSearchSaving
	(ActualSavings,Type,IssueDate,DK)
	Select ai.dbo.fn_Currency_Converter_New(FareCurrency,Round(actualsavings,0),GETDATE()),[type],creation_date ,DK From
	(
	SELECT	sum(actual_savings) AS actualsavings,type,FareCurrency, creation_date,Audit.DK
	FROM	TAOLAP.[dbo].[AIOlap_Trip] Audit WITH (NOLOCK)
			INNER JOIN   @tmpClientID  TMPCLIENT ON AUDIT.client_id = TMPCLIENT.ClientID
			INNER JOIN   @DKTable  TMPDK ON AUDIT.dk = TMPDK.DK 
	WHERE	creation_date between @FromDate and @ToDate
			AND (rejected_savings > 0 OR actual_savings > 0 OR pending_savings  > 0) 
			And ForeignStatus in (0,1)
	GROUP BY type,FareCurrency, creation_date,Audit.DK
	)Savings	

	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	SELECT 8, 1, ISNULL(ActualSavings,0), IssueDate,DK FROM #AuditSearchSaving Where Type = 'Air'
			
	-------------------------------	
	-- Audit Searches - CAR - Savings found from nightly robot searches   
	-- *** originalRate - foundRate (robot) * days
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK)
	SELECT 8, 2, ISNULL(ActualSavings,0), IssueDate,DK FROM #AuditSearchSaving Where Type = 'Car'
	
	-------------------------------	
	-- Audit Searches - HOTEL - Savings found from nightly robot searches   
	-- *** original_rate - rate_found (robot) * nights_booked
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK)
	SELECT 8, 3, ISNULL(ActualSavings,0), IssueDate,DK FROM #AuditSearchSaving Where Type = 'Hotel'
	--Print @sqlQry


	-------------------------------	
	-- Agency Discounts - AIR - Savings from using Consolidators, consortia, agency contracts
	-- UDID55 (lowest published fare for flight) - UDID54 (consolidator fare)
	-- TODO - Rowdy & John to switch from storing air data in UD54,55,87.91,94 to REMARKS like hotel and car
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	SELECT 9, 1,  ISNULL(SUM(AgencyDiscSavings),0), IssueDate,DK FROM #AIR_TMAN  
	Group by IssueDate,DK
	-------------------------------	
	-- Agency Discounts - CAR - Savings from using Consolidators, consortia, agency contracts
	-- ROI_FF = lowest non-discounted rate for same car *** ROI_f1 = 'TFO' 
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK) 
	SELECT 9, 2, ISNULL(SUM(AgencyDiscSavings),0), IssueDate,DK FROM #CAR_TMAN 
	Group by IssueDate,DK
	-------------------------------	
	-- Agency Discounts - HOTEL Savings from using Consolidators, consortia, agency contracts
	-- ROI_FF = lowest non-discounted rate for same hotel *** ROI_f1 = 'TFO' 
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK)
	SELECT 9, 3, ISNULL(SUM(AgencyDiscSavings),0), IssueDate,DK FROM #HOTEL_TMAN 
	Group by IssueDate,DK
	
	-------------------------------	
	-- PreTrip - AIR - Value of Denied air segments 
	-- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0
	-- TODO - John to add total air, total car, and total hotel cost to the pretrip table
	-------------------------------	

	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	SELECT 10, 1, ISNULL(SUM(booked_fare),0), ApprovedDT ,DK FROM [AI].[dbo].[vw_pretrip_air] 
	WHERE  dk IN (Select DK FROM @DKTable )  
	 AND ApprovedDT BETWEEN @fromDate AND  @toDate 
	AND (IsTripApproved = 0) Group by ApprovedDT,DK
	
	-------------------------------	
	-- PreTrip - CAR - Value of Denied air segments
	-- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0
	-- TODO - John to add total air, total car, and total hotel cost to the pretrip table
	-------------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
	SELECT 10, 2, 
	ISNULL(SUM((Rate / CASE 
					WHEN (ratePlan = 'WY') THEN 5 
					WHEN (ratePlan = 'WK') THEN 5 
					WHEN (ratePlan = 'DY') THEN 1 
					WHEN (ratePlan = 'WD') THEN 2 
					WHEN (ratePlan = 'MY') THEN 30 
					ELSE 1 
				   END) * numDays ),0), ApprovedDT,DK
				FROM [AI].[dbo].[vw_pretrip_car]
	 WHERE  dk IN (Select DK FROM @DKTable )  
	 AND ApprovedDT BETWEEN  @fromDate  AND  @toDate 
	 AND (IsTripApproved = 0) Group by ApprovedDT,DK
	
	-------------------------------	
	-- PreTrip - HOTEL - Value of Denied hotel segments
	-- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0
	-- TODO - John to add total air, total car, and total hotel cost to the pretrip table
	-------------------------------	

	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK) 
		SELECT 10, 3, 
	ISNULL(SUM(total),0), ApprovedDT ,DK FROM [AI].[dbo].[vw_pretrip_hotel] 
	WHERE dk IN (Select DK FROM @DKTable )  
	AND ApprovedDT BETWEEN @fromDate  AND  @toDate 
	AND (IsTripApproved = 0) 
	Group by ApprovedDT,DK
	
	-------------------------------	
	-- LostTickets - AIR
	-------------------------------	
--	DECLARE @LTRAmount float
--	--DECLARE @IssueDate DateTime
--	SELECT @LTRAmount = ISNULL(SUM(Amount),0) 
--	FROM  AI.dbo.vw_bankAddedTickets VW with (nolock)
--  Inner join ai.Dbo.New_dk  with (nolock) on ai.dbo.new_dk.dk =  Vw.dk
--  inner JOIN  ai.dbo.trip_tickets   with (nolock) on   Vw.PNR = ai.dbo.trip_tickets.PNR  and Vw.trip_id= ai.dbo.trip_tickets.trip_id
--  left JOIN ai.dbo.tickets_banked  with (nolock)
--			on ai.dbo.tickets_banked.TicketNumber =ai.dbo.trip_tickets.Ticket
--				 and  Vw.PNR = ai.dbo.trip_tickets.PNR 
--where   IsLTR= 1 and  Vw.issue_date between @fromDate  and @toDate  and
--ForeignStatus in (0,1) 
-- and Vw.DK in (Select DK FROM @DKTable) 
--and type='Air'
INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount,issueDate,DK ) 
	SELECT 11, 1,  ISNULL(SUM(Amount),0) , Vw.AddedDate,VW.DK
	FROM TAOLAP.DBO.AIOLAP_Tickets_Banked Vw with (nolock)
	INNER JOIN @DKTable ND ON Vw.DK  = ND.DK  
	Where Islost = 1  and TransactionType = 'Added' 
	and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
	and AddedDate between @fromDate  and @toDate  
	and isnull(ForeignStatus,-1) in (-1,0,1,2)  and IsHasAir = 1
	Group by vw.AddedDate,VW.DK
	-------------------------------	
	-- LostTickets - CAR - Always $0
	-------------------------------	
		DECLARE @LTR_CarAmount float = 0 

	--SELECT @LTR_CarAmount = ISNULL(SUM(rate*numdays),0)
	--			from ai.dbo.trip_car  with (nolock)
	--			where trip_id in (select a.trip_id
	--				from ai.dbo.trip_tickets a  with (nolock)
	--				join ai.dbo.trip b  with (nolock) on a.trip_id = b.trip_id
	--				where a.oosdt is not null
	--				and a.isLTR = 1
	--				and b.HaveCar = 1
	--				and b.TripStatus <> 6
	--				and b.dk IN (Select DK FROM @DKTable)
	--				and a.issuedt BETWEEN @fromDate AND @toDate
	--				and ForeignStatus in (0,1))
					
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) VALUES ( 11, 2, @LTR_CarAmount, GETDATE(),null ) 
	
	-------------------------------	
	-- LostTickets - HOTEL - Always $0
	-------------------------------	
	
	--DECLARE @LTR_HtlAmount float
	--SELECT @LTR_HtlAmount = ISNULL(SUM(Amount),0) 
	--FROM TAOLAP.DBO.AIOLAP_Tickets_Banked with (nolock)
	--INNER JOIN @DKTable ND ON AIOLAP_Tickets_Banked.DK  = ND.DK  
	--Where TransactionType = 'Used' and IsLost= 1 
	--and issueDate between @fromDate  and @toDate  and
	--ForeignStatus in (0,1)  and Type = 'Hotel'

	--SELECT @LTR_HtlAmount = ISNULL(SUM(total),0)
	--from ai.dbo.trip_hotel  with (nolock)
	--where trip_id in (select a.trip_id
	--			from ai.dbo.trip_tickets a  with (nolock)
	--			join ai.dbo.trip b   with (nolock) on a.trip_id = b.trip_id
	--			where a.oosdt is not null
	--			and a.isLTR = 1
	--			and b.HaveHotel = 1
	--			and b.TripStatus <> 6
	--			and b.dk IN (Select DK FROM @DKTable)
	--			and a.issuedt BETWEEN @fromDate AND @toDate
	--			and ForeignStatus in (0,1)
	--			)
				
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount , issueDate , Dk) 
	select  11, 3,  ISNULL(SUM(Amount),0) ,AddedDate , vw.DK
		FROM TAOLAP.DBO.AIOLAP_Tickets_Banked Vw with (nolock)
	INNER JOIN @DKTable ND ON Vw.DK  = ND.DK  
	Where Islost = 1  and TransactionType = 'Added' 
	and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
	and AddedDate between @fromDate  and @toDate  
	and isnull(ForeignStatus,-1) in (-1,0,1,2)  and IsHasHotel = 1
	Group by vw.AddedDate,VW.DK
				
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount,issueDate,DK ) --VALUES ( 11, 3, @LTR_HtlAmount ) 
	--select 11, 3, ISNULL(SUM(total),0), creation_date,DK
	--from ai.dbo.trip_hotel  with (nolock)
	--where trip_id in (select a.trip_id
	--			from ai.dbo.trip_tickets a  with (nolock)
	--			join ai.dbo.trip b   with (nolock) on a.trip_id = b.trip_id
	--			where a.oosdt is not null
	--			and a.isLTR = 1
	--			and b.HaveHotel = 1
	--			and b.TripStatus <> 6
	--			and b.dk IN (Select DK FROM @DKTable)
	--			and a.issuedt BETWEEN @fromDate AND @toDate
	--			and ForeignStatus in (0,1) 
	--			) Group by creation_date,DK


---------------------------------
/*   CREDITS SAVINGS SECTION   */
---------------------------------
	
	-------------------------------	
	-- Exchanges - AIR - Value of exchanges - LTR values above
	-- SLE 3-28-2012 - Make sure transactions that are exch AND void are only counted on void
	-------------------------------	
	
	
	SET @sqlQry = @selectClause + @whereClause
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK ) 
	SELECT 12 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, Vw.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')
		Group by vw.IssueDate,VW.DK
	-------------------------------	
	-- Exchanges - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,DK) 
SELECT 12 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')
		Group by VW.IssueDate,VW.DK
	-------------------------------	
	-- Exchanges - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK) 
SELECT 12 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')
		Group By VW.IssueDate,VW.DK
	-------------------------------	
	-- Refunds - AIR
	-------------------------------	
	
	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ,dk) 
SELECT 13 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND  refundInd <> 'N' 
		Group By VW.IssueDate,VW.DK
	-------------------------------	
	-- Refunds - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate, DK ) 
SELECT 13 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate, vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND  refundInd <> 'N' 
		Group By vw.IssueDate,VW.DK
	-------------------------------	
	-- Refunds - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate, DK) 
SELECT 13 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND  refundInd <> 'N' 
		Group By VW.IssueDate,VW.DK
	
	-------------------------------	
	-- Voids - AIR
	-------------------------------	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate, DK) 
SELECT 14 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND   voidInd ='Y' 
		Group By VW.IssueDate,VW.DK
	-------------------------------	
	-- Voids - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate, DK) 
SELECT 14 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND   voidInd ='Y' 
		Group By VW.IssueDate,VW.DK
	-------------------------------	
	-- Voids - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK) 
SELECT 14 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice, VW.IssueDate,vw.DK
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_BETA VW
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK 
		Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate
		AND   voidInd ='Y' 
		Group By vw.IssueDate,VW.DK
	
	-------------------------------	
	-- Banked Tickets - AIR
	-------------------------------	
	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK)
	SELECT 15, 1, SUM(Amount) ,AddedDate, Vw.DK
	FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw 
	INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
	Where TransactionType = 'Added' 
 --and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
	and AddedDate BETWEEN @fromdate AND  @todate  
	And isLost = 0 and Type = 'Air'
	and isnull(ForeignStatus,-1) in (-1,0,1,2)
	Group By AddedDate,Vw.DK
	
	-------------------------------	
	-- Banked Tickets - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK) VALUES ( 15, 2, 0, GETDATE(), null ) 
	
	-------------------------------	
	-- Banked Tickets - HOTEL - Always $0
	-------------------------------	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 3, 0 ) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK)
 SELECT 15, 3, SUM(Amount) ,AddedDate , Vw.DK
 FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
 Where TransactionType = 'Added' 
 and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
 and AddedDate BETWEEN @fromdate AND  @todate  
 And isLost = 0 and Type = 'Hotel'
 and isnull(ForeignStatus,-1) in (-1,0,1,2)
 Group by AddedDate , VW.DK
	

  
	-------------------------	
	-- Total Spend - AIR  
	-------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK)  
	SELECT 16, 1, 
	ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime) 
				else price end) else 0 end  ),0) as price, issueDate, DK FROM #TripCost  
	 WHERE (travelType = 'Air')  Group by issueDate,DK
	
	
	-------------------------	
	-- Total Spend - CAR  
	-------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK) 
	SELECT 16, 2, 	ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime) 
				else price end) else 0 end ),0) as price, issueDate,DK  FROM #TripCost 
	WHERE (travelType = 'Car') Group by issueDate,DK
	
	
	---------------------------	
	-- Total Spend - HOTEL  
	---------------------------	
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate,DK)
	SELECT 16, 3,
	ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime) 
				else price end) else 0 end ),0)  as price, issueDate,DK FROM #TripCost 
	WHERE (travelType = 'Hotel') Group by issueDate,DK
	
	
	-------------------------------	
	-- Total Transaction Count
	-- Need to add this single value into construct used for all ROI values being passed back
	-- Will add a 17th row with air=0 car=0 and hotel=total transactions
	-- Main application will identify value of hotel in 17th row as total transactions
	-------------------------------	
	DECLARE @totaltrx as float
	
	SELECT @totaltrx = COUNT(DISTINCT invoiceNum) FROM #TripCost  
	--select @totaltrx 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ) VALUES ( 17, 1, 0, GETDATE() ) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ) VALUES ( 17, 2, 0, GETDATE() ) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount, issueDate ) VALUES ( 17, 3, @totaltrx, GETDATE() ) 

	
	
	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType,cnt, Amount, issueDate,DK ) 
	--SELECT 18, 1, COUNT(*), 0, Creation_Date ,DK FROM tman.dba.ta_transaction_rpt trn 
	--WHERE (Booked_Online = 1) and	dk IN (Select DK FROM @DKTable )
	--and creation_date between  @fromDate and @toDate 
	--AND TYPE = 'Air' GROUP BY Creation_Date,DK
    
   
-------------------------------	
	-- Online Adoption - CAR 
	-------------------------------	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 2, 0 ) 

 --       SET @selectClause = 'SELECT 4, 2, '
	--SET @selectClause = @selectClause + '(COUNT(*) * ' + CAST(@HConlineSavings as nvarchar(7)) + ') FROM tman.dba.ta_transaction_rpt ' 
	--SET @whereClause = ' WHERE (Booked_Online = 1) '
	--SET @whereClause = @whereClause + ' and dk IN (' + @dkList + ') '
	--SET @whereClause = @whereClause + ' and creation_date between ''' + @fromDate + ''' AND ''' + @toDate + ''''
	--SET @whereClause = @whereClause + ' AND TYPE = ''CAR'' '
	
	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Cnt, Amount, issueDate ,DK) 
	--SELECT 18, 2, COUNT(*),0, Creation_Date ,DK  FROM tman.dba.ta_transaction_rpt 
	-- WHERE (Booked_Online = 1) and (CarHtlOnly = 1)
	-- and dk IN (Select DK FROM @DKTable ) 
	-- and creation_date between @fromDate and @toDate
	-- AND TYPE = 'CAR' GROUP BY Creation_Date,DK
    
	
	
	-------------------------------	
	-- Online Adoption - HOTEL 
	-------------------------------	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 3, 0 ) 

 --      SELECT 4, 3, 
	--(COUNT(*) *  CAST(@HConlineSavings as nvarchar(7)) ) FROM tman.dba.ta_transaction_rpt  
	-- WHERE (Booked_Online = 1) 	 and dk IN (@dkList + ') 
	--SET @whereClause = @whereClause + ' and creation_date between ''' + @fromDate + ''' AND ''' + @toDate + ''''
	--SET @whereClause = @whereClause + ' AND TYPE = ''HOTEL'' '
	
		
	
	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType,Cnt, Amount, issueDate ,DK) 
	--SELECT 18, 3, COUNT(*),0, Creation_Date ,DK FROM tman.dba.ta_transaction_rpt 
	-- WHERE (Booked_Online = 1) and (CarHtlOnly = 1)
	-- and dk IN (Select DK FROM @DKTable) 
	-- and creation_date   between @fromDate and @toDate
	-- AND TYPE = 'HOTEL' GROUP BY Creation_Date,DK
	 
	 
	PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' end insert'	

--DECLARE @params as nvarchar(2000)
--SET @params = @fromDate + ' ' + @toDate + ' ' + @dkList
--DECLARE @results as nvarchar(2000)
--SET @results = @totaltrx
--INSERT INTO ai.dbo.temp_sle
 --([params] ,[results])
-- values (@params,  @results)	

CLEANUP:	
	-------------------------------	
	-- Clean up temp tables
	-------------------------------	
	drop table #TripCost
	drop table #TripWaivers 
	drop table #AIR_TMAN
	drop table #CAR_TMAN
	drop table #HOTEL_TMAN
	
	drop table #AuditSearchSaving
	
	-------------------------------	
	-- Clean up null returned values
	-------------------------------	
	--Select * from @tempRoiValues  where RoiType = 17 and TravelType = 3
--	Select sum(Amount) From  @tempRoiValues where  RoiType  = 0 and TravelType = 1 
	
	UPDATE @tempRoiValues 
	SET Amount = 0 
	WHERE (Amount is null)
		
	UPDATE @tempRoiValues 
	SET AvgAmt =  (select Amount  from  @tempRoiValues where RoiType = 17 and TravelType = 3)
	Where RoiType = 15 and TravelType = 3 
	-------------------------------	
	-- Extract values from table variable 
	-- for return to app
	-------------------------------	
	--SELECT  TravelType, sum(Amount) FROM @tempRoiValues  --where RoiType < 16
	--Group by TravelType
	--SELECT  *  FROM @tempRoiValues where RoiType < 16
	DECLARE @totalAmount as float 
	SELECT @totalAmount =  sum(amount)  FROM @tempRoiValues where RoiType < 16
	
	
	
--	SET @totalAmount = (@totalAmount /  case when @totaltrx > 0 then @totaltrx else 1 end )
	SELECT TravelType, sum(amount) as Amt, sum(cnt) as cnt , case when TravelType = 3 then @totalAmount else 0 end, issueDate,DK
	FROM @tempRoiValues where RoiType < 16
	Group by TravelType, issueDate,DK
	
	
	
	--SELECT TravelType, sum(amount), sum(cnt) , MAX(@totaltrx), issueDate,DK FROM @tempRoiValues where RoiType < 16
	--Group by TravelType, issueDate,DK
	
	--ORDER BY RoiType, TravelType
	
	PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' end roi'	
	
END

GO
