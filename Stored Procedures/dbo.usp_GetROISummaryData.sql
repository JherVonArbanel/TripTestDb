SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
/** SWITCHED TO TMAN FOR TOTAL SPEND AND TOTAL TRX - 11/9/12 SE **/  
/** Changed Total TRX to be the total unique invoices - 12/17/12 SE **/  
/** Changed to use new tables in Tman -- 07/11/13 NH **/  
  
CREATE PROCEDURE [dbo].[usp_GetROISummaryData]   
(   
@clientID nvarchar(MAX), --- used for creating specific results for demos  
@fromDate nvarchar(20),   
@toDate nvarchar(20),   
@dkList varchar(MAX),   
@udidNum1 int,  
@udidValue1 nvarchar(100),  
@udidNum2 int,  
@udidValue2 nvarchar(100)  
)  
AS  
BEGIN  
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 1 start sp'
SET ANSI_WARNINGS OFF  
-----  FOR TESTING - REMOVE  
--SET @dkList = @dkList + ',''CRP1000910'',''CRP1000908'''  
--SET @dkList = @dkList + ',''CRP1000879'''  
--SET @dkList = @dkList + ',''CRP1000557'''  
DECLARE @debug int  
SET @debug = 0  
    
 DECLARE @roiType nvarchar(2)  
 DECLARE @travelType nvarchar(2)  
  
 DECLARE @UDNum1 int  
 DECLARE @UDVal1 int  
 DECLARE @UDNum2 int  
 DECLARE @UDVal2 int  
  
 DECLARE @selectClause varchar(max)  
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
  Amount float  
 )  
   
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 
 -- SLE 4/10/2012 - added logic to handle conversion of unexpected date formats  
 --                 can not trust that dates will come in as properly formated string  
 SET @fromDate = convert(varchar, convert(datetime, @fromDate), 111) + ' 00:00:00'  
 SET @toDate = convert(varchar, convert(datetime, @toDate), 111) + ' 23:59:59'   

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 2 start table'
---------------------------------  
/* CREATE AND LOAD DK TABLES */  
---------------------------------  
------ SHOULD BE CHANGED --------  
/* DK Short no longer needed */  
---------------------------------  
 -- Temp table to hold versions of the DK list  
 DECLARE @DKTable TABLE           
  (          
  DK  VARCHAR(10),     --The string value of the DK             
  DKShort  VARCHAR(7)  --The string value of the last 7 characters of DK            
  )  
   
 -- Modify contents of @dkList variable and store in new var  
 -- Assumption : @dkList will always have the form 'XXX#######','XXX#######'  
 -- We need to extract data and form @dkListShort = '#######','#######'  
 DECLARE @dkListShort nvarchar(500) = ''  
 DECLARE @position int   
 DECLARE @prefix nvarchar(10) = ''''   
  
 --SET @position = 5  
 --WHILE @position < LEN(@dkList)  
 --BEGIN  
 -- -- create local variable that contains list of short DKs (last 7 digits = TMAN ClientCode)  
 -- SET @dkListShort = @dkListShort + @prefix + SUBSTRING(@dkList,@position,7)   
 -- SET @prefix = ''','''  
    
 -- -- Add items to @DKTable so they can be used in "IN" clause  
 -- -- SQL does not allow statement like WHERE DK IN ( @dkList )  
 -- -- when executed directly in stored procedure  
 -- -- must use : WHERE DK IN (Select DK from @DKTable)  
    
 -- INSERT INTO @DKTable           
 -- VALUES (SUBSTRING(@dkList,@position-3,10),SUBSTRING(@dkList,@position,7))  
    
 -- -- increment to 4th character of next DK  
 -- SET @position = @position + 13   
 --END   
 --SET @dkListShort = @dkListShort + ''''  
  
  
 
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
 declare @TripCost  table
  (  
  travelType VARCHAR(10) ,   
  trip_id INT ,    
  pnr CHAR(6),    
  price DECIMAL(18,2)  ,  
  noOf INT ,  
  Currency varchar(5),  
  TripStatus int,  
  Enddatetime datetime,  
  invoiceNum varchar(10)  
   )   
   
   
   
 ---- 10-29-2012 NH New code to support Waivers via Waiver table  
 ---- Temp table to hold data from ai.dbo.Waivers  
 CREATE TABLE #TripWaivers          
  (          
  waiverType VARCHAR(10),  
  waiverValue DECIMAL(18,2)  
  )   
  
  
  
-- 11JUL13 NEW TABLES FOR CHANGE TO TMAN  
  
Declare  @AIR_TMAN  table
 (  
 BookedOnline   TINYINT,  
 PolicySavings   DECIMAL(18,2),  
 NegotiatedSavings  DECIMAL(18,2),  
 WebSavings   DECIMAL(18,2),  
 PrepaidSavings  DECIMAL(18,2),  
 AuditSearchSavings DECIMAL(18,2),  
 AgencyDiscSavings DECIMAL(18,2),  
 AwardSavings  DECIMAL(18,2),  
 ExchangeAmt  DECIMAL(18,2),  
 VoidAmt   DECIMAL(18,2),  
 RefundAmt  DECIMAL(18,2),  
 TtlTktAmt  DECIMAL(18,2)  
 )  
  
Declare @CAR_TMAN  table
 (  
 BookedOnline   TINYINT,  
 PolicySavings   DECIMAL(18,2),  
 NegotiatedSavings  DECIMAL(18,2),  
 WebSavings   DECIMAL(18,2),  
 PrepaidSavings  DECIMAL(18,2),  
 AuditSearchSavings DECIMAL(18,2),  
 AgencyDiscSavings DECIMAL(18,2),  
 AwardSavings  DECIMAL(18,2),  
 ExchangeAmt  DECIMAL(18,2),  
 VoidAmt   DECIMAL(18,2),  
 RefundAmt  DECIMAL(18,2),  
 TtlCarAmt  DECIMAL(18,2)  
 )  
  
declare @HOTEL_TMAN   table
 (  
 BookedOnline   TINYINT,  
 PolicySavings   DECIMAL(18,2),  
 NegotiatedSavings  DECIMAL(18,2),  
 WebSavings   DECIMAL(18,2),  
 PrepaidSavings  DECIMAL(18,2),  
 AuditSearchSavings DECIMAL(18,2),  
 AgencyDiscSavings DECIMAL(18,2),  
 AwardSavings  DECIMAL(18,2),  
 ExchangeAmt  DECIMAL(18,2),  
 VoidAmt   DECIMAL(18,2),  
 RefundAmt  DECIMAL(18,2),  
 TtlHtlAmt  DECIMAL(18,2)  
 )  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 2 end table' 
-- 11JUL13 INSERT DATA TO NEW TABLES FOR CHANGE TO TMAN 

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 start TMAN AIR table' 
INSERT @AIR_TMAN  
 (BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlTktAmt)  
 SELECT BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlTktAmt  
 FROM TMAN.DBA.TA_ROI_AIR  Air With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Air.DK
 WHERE  issuedate BETWEEN @fromDate AND @toDate  
   

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 end TMAN AIR table' 

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  start TMAN CaR table' 
  
INSERT @CAR_TMAN  
 (BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlCarAmt)  
 SELECT BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlCarCost  
 FROM TMAN.DBA.TA_ROI_CAR  Car With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Car.DK 
 WHERE issuedate BETWEEN @fromDate AND @toDate  


 
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  End TMAN CaR table'   
  
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  start TMAN Hotel table' 
INSERT @HOTEL_TMAN  
 (BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlHtlAmt)  
 SELECT BookedOnline, PolicySavings, NegotiatedSavings,  WebSavings,  PrepaidSavings, AuditSearchSavings, AgencyDiscSavings, AwardSavings, ExchangeAmt, VoidAmt, RefundAmt, TtlHtlCost  
 FROM TMAN.DBA.TA_ROI_HOTEL Hotel With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Hotel.DK
 WHERE issuedate BETWEEN @fromDate AND @toDate  
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  end TMAN hotel table' 
  
    

--Audit Savings From OLAP  
--SELECT Sum([Audit].actual_savings) as ActualSavings,Audit.type  
--FROM TAOLAP.[dbo].[vw_AuditSavings_OLAP]  AUDIT     
--   INNER JOIN   @tmpClientID  TMPCLIENT ON AUDIT.client_id = TMPCLIENT.ClientID  
--   INNER JOIN   @DKTable  TMPDK ON AUDIT.dk = TMPDK.DK  
--WHERE creation_date between @FromDate and @ToDate  
--   AND (rejected_savings > 0 OR actual_savings > 0 OR pending_savings  > 0)   
--Group by Audit.type  
   
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 5  start TMAN spend table'   
 INSERT @TripCost  
  ( travelType, trip_id, pnr, price, noOf,currency ,TripStatus,Enddatetime, invoiceNum)  
  SELECT type, 0, pnr, amount, tktDayNgtCount,currency,3,endTravelDate, invoiceNum  
  FROM  [TMAN].[dba].TA_SPEND_RPT  spend With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = spend.DK  
  WHERE  issuedate BETWEEN @fromDate AND @toDate  

   --select count(*) from @TripCost
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 5  end TMAN spend table'   
   
    
   
 ---- 10-29-2012 NH New code to support Waivers via Waiver table  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 6  start TMAN waivers table'     
 INSERT #TripWaivers   
  ( waiverType, waiverValue )  
  SELECT waiverType, valueRecovery  
  FROM  AI.dbo.waivers  waivers
  Inner join @DKTable tmpDK on tmpDK.dk = waivers.DK  
  WHERE OpenDtTime BETWEEN @fromDate AND @toDate   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 6  end TMAN waivers table'     
  
 ---------------------------------  
 /*   POLICY SAVINGS SECTION    */  
 ---------------------------------  
   
 -------------------------   
 -- TESTING  
 -------------------------   
 --SET @selectClause = 'SELECT 0, 0, '  
 --SET @selectClause = @selectClause + 'dk FROM #DK '   
   
   
 --SET @sqlQry = @selectClause   
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0, 1, 0 )   
 --ELSE  
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)  
   
 -------------------------   
 -- Policy Savings - AIR Lost Opportunity *** (booked + actual = original fare) - lowest_fare (LF) is savings not taken at point of sale  
 -------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 7  start policy' 
 --SET @selectClause = 'SELECT 0, 1, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(PolicySavings),0) FROM @AIR_TMAN '   
   
   
 --SET @sqlQry = @selectClause   
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0, 1, 0 )   
 --ELSE  
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  --SELECT 0, 1, ISNULL(SUM(PolicySavings),0) FROM @AIR_TMAN 
    INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  Select  0 , 1 , 0 
  Union 
  Select  0 , 2 , 0 
  Union 
  Select  0 , 3 , 0 
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 2 start sp'
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 start sp'
  Update t
  Set Amount = a.Amount
 From @tempRoiValues t inner join 
 
 ( Select  
		Case 
		when Type = 'Air' then 1   
		when Type = 'Car' then 2   
		when Type = 'Hotel' then 3 end as TravelType,
		Sum(lost) as Amount
		From
		   taolap.dbo.vw_AuditException_OLAP VW   with (nolock) 
		Inner join @DKTable TMP_DK on    VW.DK = TMP_DK.DK	
 	WHERE (creation_date BETWEEN   @fromDate AND @toDate    )  
	AND vw.foreignStatus IN(0,1) 
	AND lost > 0 and reason_Code not in ('E','A','','FJA')
    Group by Type )  a on t.TravelType = a.TravelType 
    
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 start sp' 
  
   
 -------------------------   
 -- Policy Savings - CAR Lost Opportunity *** ((OriginalRate - ROI_LF) * NumOfDays) ***   
 -------------------------   
 --SET @selectClause = 'SELECT 0, 2, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(PolicySavings),0) FROM @CAR_TMAN '   
 --SET @whereClause = '  '  
    
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0, 2, 0 )   
 --ELSE  
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
 -- SELECT 0, 2,ISNULL(SUM(PolicySavings),0) FROM @CAR_TMAN 
   
   
 ---------------------------   
 -- Policy Savings - HOTEL Lost Opportunity *** ((original_rate - ROI_LF) * nights_booked) ***   
 ---------------------------   
    
 -- SET @selectClause = 'SELECT 0, 3, '  
 -- SET @selectClause = @selectClause + 'ISNULL(SUM(PolicySavings),0) FROM @HOTEL_TMAN   '   
 --SET @whereClause = ' '   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0,3, 0 )   
 --ELSE  
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
 -- SELECT 0, 3, ISNULL(SUM(PolicySavings),0) FROM @HOTEL_TMAN   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 7  end policy'    
   
 -------------------------------   
 -- Negotiated Contracts - AIR Savings Due to Client Contract  
 -- *** (UDID91 - ( booked_fare + actual_savings )) = ( FF - original ) ***  
 --      UD91 = WP value, without use of client contract, entered by file finishing script  
 -------------------------------   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 8  start contract'    
  
 --SET @selectClause = 'SELECT 1, 1, '  
 --SET @selectClause = @selectClause + ' ISNULL(SUM(NegotiatedSavings),0) FROM @AIR_TMAN'   
 --SET @whereClause = ' '  
     
 --SET @sqlQry = @selectClause + @whereClause  
 
 
 
    INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  Select  1 , 1 , 0 
  Union 
  Select  1 , 2 , 0 
  Union 
  Select  1 , 3 , 0 
 
 
 Update t
  Set Amount = a.Amount
 From @tempRoiValues t inner join 
 
 ( select case 
  when type = 'Air' then 1 
  when type = 'Car' then 2
  when type = 'Hotel' then 3 end as TravelType,
 sum(ND_Amt-PaidFare) as Amount
 FROM TMAN.[dba].[TA_CONTRACT_RPT] t with (Nolock)
  	Inner join @DKTable TMP_DK on    t.DK = TMP_DK.DK	
Where ForeignStatus in (0,1) AND 
	issuedate BETWEEN  @fromDate AND @toDate 
	and (ND_Amt > PaidFare) 
group by type )  a on t.TravelType = a.TravelType and RoiType = 1 
 
 -- SELECT 1, 1, ISNULL(SUM(NegotiatedSavings),0) FROM @AIR_TMAN
 --SET @whereClause = ' '  
 -- EXEC(@sqlQry)  
 --print @sqlQry  
   
 -------------------------------   
 -- Negotiated Contracts - CAR Savings Due to Client Contract  
 -- *** ((ROI_ND - originalRate) * num_days) *** ROI_f1 = 'NEG'  
 -------------------------------   
   
 --SET @selectClause = 'SELECT 1, 2, '  
 --SET @selectClause = @selectClause + ' ISNULL(SUM(NegotiatedSavings),0) FROM @CAR_TMAN '   
 --SET @whereClause = '  '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)  
 --SELECT 1, 2,  ISNULL(SUM(NegotiatedSavings),0) FROM @CAR_TMAN 
   
   
 ---------------------------------   
 -- Negotiated Contracts - HOTEL Savings Due to Client Contract  
 -- *** ((ROI_ND - original_rate) * nights_booked) *** ROI_f1 = 'NEG'  
 ---------------------------------   
   
 --SET @selectClause = 'SELECT 1, 3, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(NegotiatedSavings),0) FROM @HOTEL_TMAN  '   
 --SET @whereClause = '  '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 1, 3, 3 )   
 --ELSE  
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
 --SELECT 1, 3, ISNULL(SUM(NegotiatedSavings),0) FROM @HOTEL_TMAN  
 
   
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 8  end contract'    
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
   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 9  start awards'    
 --SET @selectClause = 'SELECT 2, 1, '  
 --SET @selectClause = @selectClause + '  ISNULL(SUM(AwardSavings),0) FROM @AIR_TMAN  '   
 --SET @whereClause = ' '  
   
   
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 2, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
  SELECT 2, 1, ISNULL(SUM(AwardSavings),0) FROM @AIR_TMAN  
 
 
   
 -------------------------------   
 -- Loyalty Awards - CAR (WILL ALWAYS SHOW AS $0)  
 -------------------------------   
 
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 2, 2, 0 )   
   
   
 -------------------------------   
 -- Loyalty Awards - HOTEL (WILL ALWAYS SHOW AS $0)  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 2, 3, 0 )   
   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 9  end awards'        
 -------------------------------   
 -- Determine Payment Rebate % for this Client  
 -------------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 10  start payment'      
 SET @rebatePct = '0.00000'  
 SELECT @rebatePct=ISNULL(MAX(RebatePercent),0) from [AI].[dbo].[PaymentRebate] Payment with (nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK  
 WHERE RebateActive = 'True'  
   
  
 -------------------------------   
 -- Payment Rebate - AIR ( x% rebate on total air spend )  
 -------------------------------   
 --SET @selectClause = 'SELECT 3, 1, '  
 --SET @selectClause = @selectClause + 'ISNULL((SUM(TtlTktAmt) * ' + @rebatePct + '),0) FROM @AIR_TMAN '   
   
 --SET @sqlQry = @selectClause   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
 SELECT 3, 1,ISNULL((SUM(TtlTktAmt) *  @rebatePct ),0) FROM @AIR_TMAN 
 
    
   
 -------------------------------   
 -- Payment Rebate - CAR  ( x% rebate on total car spend )  
 -------------------------------   
 --SET @selectClause = 'SELECT 3, 2, '  
 --SET @selectClause = @selectClause + ' ISNULL((SUM(TtlCarAmt) * ' + @rebatePct + '),0) FROM @CAR_TMAN'   
 --SET @whereClause = ''  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 3, 2, 5 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)  
 SELECT 3, 2,  ISNULL((SUM(TtlCarAmt) *  @rebatePct ),0) FROM @CAR_TMAN
   
   
   
 -------------------------------   
 -- Payment Rebate - HOTEL ( x% rebate on total hotel spend )  
 -------------------------------   
 --SET @selectClause = 'SELECT 3, 3, '  
 --SET @selectClause = @selectClause + 'ISNULL((SUM(TtlHtlAmt) * ' + @rebatePct + '),0) FROM @HOTEL_TMAN '   
   
 --SET @sqlQry = @selectClause   
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 3, 3, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
   SELECT 3, 3,ISNULL((SUM(TtlHtlAmt) * @rebatePct ),0) FROM @HOTEL_TMAN 
  
  
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 10  end payment'      
---------------------------------  
/*    RESERVATIONS SECTION    */  
---------------------------------  
        -------------------------------	
	-- Online Adoption - AIR  Calculate the difference between the 
	-- Agent Fee (DOM) adn the Online Fee (ONL) 
	-------------------------------	
	PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 11  start online adoption'      
		PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 11.1  start tmp online adoption'  
	DECLARE @onlineSavings float = 0
	DECLARE @maxDOM float = 0
	DECLARE @maxONL float = 0
	

	SELECT @maxDOM = MAX(fee_amount)
    FROM [ai].[dbo].[fee] fee with (nolock)
    Inner join @DKTable tmpDK on tmpDK.dk = fee.DK      
    WHERE (fee_name = 'DOM')
	--and	dk IN (Select DK FROM @DKTable ) 
	
	SELECT @maxONL = MAX(fee_amount)
    FROM [ai].[dbo].[fee] fee with (nolock)
    Inner join @DKTable tmpDK on tmpDK.dk = fee.DK  
    WHERE (fee_name = 'ONL')
	--and	dk IN (Select DK FROM @DKTable ) 

	SET @onlineSavings = @maxDOM - @maxONL
	IF @onlineSavings < 0 
	BEGIN
		SET @onlineSavings = 0
	END

        -------------------------------	
	-- Online Adoption - Car & Hotel  Calculate the difference between the 
	-- Agent Fee (LAN) adn the Online Fee (OLL) 
	-------------------------------	
        DECLARE @HConlineSavings float = 0
	DECLARE @HCmaxAGT float = 0
	DECLARE @HCmaxONL float = 0

    SELECT @HCmaxAGT = MAX(fee_amount)
    FROM [ai].[dbo].[fee] fee with (nolock)
    Inner join @DKTable tmpDK on tmpDK.dk = fee.DK  
    WHERE (fee_name = 'LAN')
	--and	dk IN (Select DK FROM @DKTable ) 
	
	SELECT @HCmaxONL = MAX(fee_amount)
    FROM [ai].[dbo].[fee] fee with (nolock)
    Inner join @DKTable tmpDK on tmpDK.dk = fee.DK  
    WHERE (fee_name = 'OLL')
	--and	dk IN (Select DK FROM @DKTable ) 

	SET @HConlineSavings = @HCmaxAGT - @HCmaxONL
	IF @HConlineSavings < 0 
	BEGIN
		SET @HConlineSavings = 0
	END
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 11.1  end tmp online adoption'  

 -------------------------------	
	-- Online Adoption - AIR  
	-- Online fee savings (see above) times the number of online air transactions )
	-------------------------------	
	print @onlineSavings
	
	SET @selectClause = 'SELECT 4, 1, '
	SET @selectClause = @selectClause + '(COUNT(*) * ' + CAST(@onlineSavings as nvarchar(7)) + ') FROM tman.dba.ta_spend_rpt trn with (nolock) ' --Inner join @DKTable tmpDK on tmpDK.dk = trn.DK   ' 
	SET @whereClause = ' WHERE (BookedOnline = 1) '
	SET @whereClause = @whereClause + ' and dk IN (' + @dkList + ') '
	SET @whereClause = @whereClause + ' and IssueDate between ''' + @fromDate + ''' AND ''' + @toDate + ''''
	SET @whereClause = @whereClause + ' AND TYPE = ''Air'' '
	
	--SELECT 4, 1, (COUNT(*) * 17) FROM tman.dba.ta_spend_rpt trn Inner join @DKTable tmpDK on tmpDK.dk = trn.DK    WHERE (Booked_Online = 1)  and creation_date between '2014/03/01 00:00:00' AND '2014/05/31 23:59:59' AND TYPE = 'Air' 
		
	--print @sqlQry
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
		
	print @HConlineSavings
	-------------------------------	
	-- Online Adoption - CAR 
	-------------------------------	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 2, 0 ) 

        SET @selectClause = 'SELECT 4, 2, '
	SET @selectClause = @selectClause + '(COUNT(*) * ' + CAST(@HConlineSavings as nvarchar(7)) + ') FROM tman.dba.ta_spend_rpt trn with (nolock) ' --Inner join @DKTable tmpDK on tmpDK.dk = trn.DK  ' 
	SET @whereClause = ' WHERE (BookedOnline = 1) and (CarHtlOnly = 1)'
	SET @whereClause = @whereClause + ' and dk IN (' + @dkList + ') '
	SET @whereClause = @whereClause + ' and Issuedate between ''' + @fromDate + ''' AND ''' + @toDate + ''''
	SET @whereClause = @whereClause + ' AND TYPE = ''CAR'' '
	
	--print @sqlQry
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 2, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- Online Adoption - HOTEL 
	-------------------------------	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 3, 0 ) 

        SET @selectClause = 'SELECT 4, 3, '
	SET @selectClause = @selectClause + '(COUNT(*) * ' + CAST(@HConlineSavings as nvarchar(7)) + ') FROM tman.dba.ta_spend_rpt ' --trn Inner join @DKTable tmpDK on tmpDK.dk = trn.DK ' 
	SET @whereClause = ' WHERE (BookedOnline = 1) and (CarHtlOnly = 1)'
	SET @whereClause = @whereClause + ' and dk IN (' + @dkList + ') '
	SET @whereClause = @whereClause + ' and IssueDate between ''' + @fromDate + ''' AND ''' + @toDate + ''''
	SET @whereClause = @whereClause + ' AND TYPE = ''HOTEL'' '
	
		
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 3, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 11  end online adoption'      
 -------------------------------   
 -- Web Fares - AIR Savings from use of Web Fare (UD94 - Original_Fare)  
 --  (UDID94 Contains the SABRE fare entered by file finish script)  
 -------------------------------   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 12  start websaving'      
 --SET @selectClause = 'SELECT 5, 1, '  
 --SET @selectClause = @selectClause + ' ISNULL(SUM(WebSavings),0) FROM @AIR_TMAN   '   
 --SET @whereClause = '  '  
   
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 5, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )
 SELECT 5, 1, ISNULL(SUM(WebSavings),0) FROM @AIR_TMAN   
     
 -------------------------------   
 -- Web Fares - CAR Savings from use of Web Rate  
 -- ROI_FF = lowest non-discounted rate for same car *** ROI_f1 = 'WEB'   
 -------------------------------   
 --SET @selectClause = 'SELECT 5, 2, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(WebSavings),0) FROM @CAR_TMAN  '   
 --SET @whereClause = ' '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 5, 2, 6 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)   
  SELECT 5, 2, ISNULL(SUM(WebSavings),0) FROM @CAR_TMAN  
   
 -------------------------------   
 -- Web Fares - HOTEL Savings from use of Web Rate  
 -- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'WEB'   
 -------------------------------   
 --SET @selectClause = 'SELECT 5, 3, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(WebSavings),0) FROM @HOTEL_TMAN  '   
 --SET @whereClause = '  '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 5, 3, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  SELECT 5, 3, ISNULL(SUM(WebSavings),0) FROM @HOTEL_TMAN  
    
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 12  end websaving'      
   
 ---- 10-29-2012 NH New code to support Waivers via Waiver table  
 -------------------------------   
 -- Restriction Waivers - Waivor/Favors from SalesForce  
 --   
 -------------------------------
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 13  start Restriction'         

INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  Select  6 , 1 , 0 
  Union 
  Select  6 , 2 , 0 
  Union 
  Select  6 , 3 , 0 
 
 
 Update t
  Set Amount = a.Amount
 From @tempRoiValues t inner join 
 
 ( select case 
  when type = 'Air' then 1 
  when type = 'Car' then 2
  when type = 'Hotel' then 3 end as TravelType,
 sum(Isnull(Amount,0)) as Amount 
	
	FROM  Tman.dba.TA_ISSRES_RPT  IssRes   
			INNER JOIN @DKTable  TMPDK ON IssRes.dk = TMPDK.DK
			--INNER JOIN #ForeignStatus FS ON FS.ForeignStatus = IssRes.ForeignStatus
	WHERE 
			 Opendt BETWEEN @FromDate AND @ToDate
			 and  IssRes.ForeignStatus in (0,1)
			 and vendorCode is not null
			 and action ='Waiver'
group by type			 
 
 )  a on t.TravelType = a.TravelType and RoiType = 6
   
   
     PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 13  end Restriction'   
 -------------------------------   
 -- Prepaid - AIR - Savings from use of Prepaid Air  *** (UDID87 - Original_Fare) ***     
 -- UDID87 contains SABRE fare for prepaid flight  
 -- TODO - do not see any data in UD96  
 ---------------------------------   
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 14  start PrepaidSavings'   
  --GOTO CLEANUP  
 --SET @selectClause = 'SELECT 7, 1, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(PrepaidSavings),0) FROM @AIR_TMAN   '   
 --SET @whereClause = '  '  
    
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 7, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )
  SELECT 7, 1, ISNULL(SUM(PrepaidSavings),0) FROM @AIR_TMAN   
   
   
 -------------------------------   
 -- Prepaid - CAR - Savings from use of Prepaid Car  *** ((ROI_FF - originalRate) * numDays) ***     
 -- ROI_f1 = 'PRE'   
 -- TODO - no data found yet  
 -------------------------------   
 --SET @selectClause = 'SELECT 7, 2, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(PrepaidSavings),0) FROM @CAR_TMAN  '   
 --SET @whereClause = '  '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 7, 2, 7 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)   
  SELECT 7, 2, ISNULL(SUM(PrepaidSavings),0) FROM @CAR_TMAN  
   
   
 -------------------------------   
 -- Prepaid - HOTEL  
 -- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'PRE'   
 -------------------------------   
 --SET @selectClause = 'SELECT 7, 3, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(PrepaidSavings),0) FROM @HOTEL_TMAN   '   
 --SET @whereClause = ' '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 7, 3, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
 SELECT 7, 3, ISNULL(SUM(PrepaidSavings),0) FROM @HOTEL_TMAN   
   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 14  end PrepaidSavings'   
 ---------------------------------  
 /*       SAVINGS SECTION    */  
 ---------------------------------  
   
 -------------------------------   
 -- Audit Searches - AIR - Savings found AND TAKEN from nightly robot searches     
 -- *** Actual_savings (found by robot)  
 -------------------------------   
   
 --Persist AuditSavings records into temporary table  
 --This is added to have records of AuditSavingSearchs from OLAP db in order to match ROI Audit Savings with Audit Savings searches report.  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 15  start ActualSavings'   
 Create table #AuditSearchSaving   
 (ActualSavings  DECIMAL(38,2),Type VARCHAR(10))  
   
 Insert into #AuditSearchSaving Values (0, 'Air')
 Insert into #AuditSearchSaving Values (0, 'Car')
 Insert into #AuditSearchSaving Values (0, 'Hotel')
 Update #AuditSearchSaving 
 Set ActualSavings = tmp.ActualSavings
 From 
 #AuditSearchSaving Inner join 
 
 ( 
 
 Select ai.dbo.fn_Currency_Converter_New(FareCurrency,Round(actualsavings,0),GETDATE()) as actualsavings,[type] From  
 (  
 SELECT sum(actual_savings) AS actualsavings,type,FareCurrency  
 FROM TAOLAP.[dbo].[AIOlap_Trip] Audit WITH (NOLOCK)  
   INNER JOIN   @tmpClientID  TMPCLIENT ON AUDIT.client_id = TMPCLIENT.ClientID  
   INNER JOIN   @DKTable  TMPDK ON AUDIT.dk = TMPDK.DK   
 WHERE creation_date between @FromDate and @ToDate  
   AND (rejected_savings > 0 OR actual_savings > 0 OR pending_savings  > 0)   
   And ForeignStatus in (0,1)  
 GROUP BY type,FareCurrency   
 )Savings    ) 
 tmp on #AuditSearchSaving.Type = tmp.type
  
 SET @selectClause = 'SELECT 8, 1, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(AuditSearchSavings),0) FROM @AIR_TMAN    '   
 SET @selectClause = @selectClause + 'ISNULL(ActualSavings,0) FROM #AuditSearchSaving Where Type = ''Air''   '   
   
   
 SET @sqlQry = @selectClause   
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 8, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)  
     
 -------------------------------   
 -- Audit Searches - CAR - Savings found from nightly robot searches     
 -- *** originalRate - foundRate (robot) * days  
 -------------------------------   
   
 SET @selectClause = 'SELECT 8, 2, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(AuditSearchSavings),0) FROM @CAR_TMAN '   
 SET @selectClause = @selectClause + 'ISNULL(ActualSavings,0) FROM #AuditSearchSaving Where Type = ''Car''   '   
 SET @whereClause = '  '  
 SET @sqlQry = @selectClause + @whereClause  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)  
   
   
 -------------------------------   
 -- Audit Searches - HOTEL - Savings found from nightly robot searches     
 -- *** original_rate - rate_found (robot) * nights_booked  
 -------------------------------   
 -- SLE 4/2/2012 Removed pending_savings as these are not valid until accepted or declined  
 SET @selectClause = 'SELECT 8, 3, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(AuditSearchSavings),0) FROM @HOTEL_TMAN   '   
 SET @selectClause = @selectClause + 'ISNULL(ActualSavings,0) FROM #AuditSearchSaving Where Type = ''Hotel''   '   
 SET @whereClause = '  '  
   
 SET @sqlQry = @selectClause + @whereClause  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)   
 --Print @sqlQry  
  
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 15  end ActualSavings'   
 -------------------------------   
 -- Agency Discounts - AIR - Savings from using Consolidators, consortia, agency contracts  
 -- UDID55 (lowest published fare for flight) - UDID54 (consolidator fare)  
 -- TODO - Rowdy & John to switch from storing air data in UD54,55,87.91,94 to REMARKS like hotel and car  
 -------------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 16  start AgencyDiscSavings'   
 --SET @selectClause = 'SELECT 9, 1, '  
 --SET @selectClause = @selectClause + ' ISNULL(SUM(AgencyDiscSavings),0) FROM @AIR_TMAN  '   
 --SET @whereClause = '  '   
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 9, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
 SELECT 9, 1,  ISNULL(SUM(AgencyDiscSavings),0) FROM @AIR_TMAN  
 
   
 -------------------------------   
 -- Agency Discounts - CAR - Savings from using Consolidators, consortia, agency contracts  
 -- ROI_FF = lowest non-discounted rate for same car *** ROI_f1 = 'TFO'   
 -------------------------------   
 --SET @selectClause = 'SELECT 9, 2, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(AgencyDiscSavings),0) FROM @CAR_TMAN '   
 --SET @whereClause = ' '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 9, 2, 9 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)   
  SELECT 9, 2,   ISNULL(SUM(AgencyDiscSavings),0) FROM @CAR_TMAN 
   
 -------------------------------   
 -- Agency Discounts - HOTEL Savings from using Consolidators, consortia, agency contracts  
 -- ROI_FF = lowest non-discounted rate for same hotel *** ROI_f1 = 'TFO'   
 -------------------------------   
 --SET @selectClause = 'SELECT 9, 3, '  
 --SET @selectClause = @selectClause + ' ISNULL(SUM(AgencyDiscSavings),0) FROM @HOTEL_TMAN  '   
 --SET @whereClause = ' '   
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 9, 3, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
 SELECT 9, 3,ISNULL(SUM(AgencyDiscSavings),0) FROM @HOTEL_TMAN  
   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 16  end AgencyDiscSavings'     
 -------------------------------   
 -- PreTrip - AIR - Value of Denied air segments   
 -- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0  
 -- TODO - John to add total air, total car, and total hotel cost to the pretrip table  
 -------------------------------   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 17  start PreTrip'   
 --SET @selectClause = 'SELECT 10, 1, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(booked_fare),0) FROM [AI].[dbo].[vw_pretrip_air] trn with (nolock) '-- Inner join @DKTable tmpDK on tmpDK.dk = trn.DK  '   
 --SET @whereClause = ' WHERE  dk IN (' + @dkList + ') AND '  
 --SET @whereClause = @whereClause + '  ApprovedDT BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' '   
 --SET @whereClause = @whereClause + ' AND (IsTripApproved = 0) '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 10, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)   
  SELECT 10, 1, ISNULL(SUM(booked_fare),0) FROM [AI].[dbo].[vw_pretrip_air] trn with (nolock) Inner join @DKTable tmpDK on tmpDK.dk = trn.DK     
  WHERE    ApprovedDT BETWEEN  @fromDate  AND  @toDate 
  AND (IsTripApproved = 0)   
    PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 17 .1 start PreTrip'   
 -------------------------------   
 -- PreTrip - CAR - Value of Denied air segments  
 -- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0  
 -- TODO - John to add total air, total car, and total hotel cost to the pretrip table  
 -------------------------------   
 SET @selectClause = 'SELECT 10, 2, '  
 SET @selectClause = @selectClause + 'ISNULL(SUM((Rate / CASE   
     WHEN (ratePlan = ''WY'') THEN 5   
     WHEN (ratePlan = ''WK'') THEN 5   
     WHEN (ratePlan = ''DY'') THEN 1   
     WHEN (ratePlan = ''WD'') THEN 2   
     WHEN (ratePlan = ''MY'') THEN 30   
     ELSE 1   
       END) * numDays ),0)  
    FROM [AI].[dbo].[vw_pretrip_car] trn with (nolock) '-- Inner join @DKTable tmpDK on tmpDK.dk = trn.DK '   
 SET @whereClause = ' WHERE  dk IN (' + @dkList + ') AND '  
 SET @whereClause = @whereClause + '  ApprovedDT BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' '   
 SET @whereClause = @whereClause + ' AND (IsTripApproved = 0) '  
    PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 17 .1 start car PreTrip'  
 SET @sqlQry = @selectClause + @whereClause  
 IF (@debug = 1)   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 10, 2, 0 )   
 ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)   
    PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 17 .1 start hotel PreTrip'  
 -------------------------------   
 -- PreTrip - HOTEL - Value of Denied hotel segments  
 -- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0  
 -- TODO - John to add total air, total car, and total hotel cost to the pretrip table  
 -------------------------------   
 SET @selectClause = 'SELECT 10, 3, '  
 SET @selectClause = @selectClause + 'ISNULL(SUM(total),0) FROM [AI].[dbo].[vw_pretrip_hotel] trn with (nolock) '--Inner join @DKTable tmpDK on tmpDK.dk = trn.DK  '   
 SET @whereClause = ' WHERE   dk IN (' + @dkList + ') AND '  
 SET @whereClause = @whereClause + '  ApprovedDT BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' '   
 SET @whereClause = @whereClause + ' AND (IsTripApproved = 0) '  
   
 SET @sqlQry = @selectClause + @whereClause  
 IF (@debug = 1)   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 10, 3, 0 )   
 ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)   
   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 17  end PreTrip'    
   -------------------------------	
	-- LostTickets - AIR
	-------------------------------	
	DECLARE @LTRAmount float
	
	--SELECT @LTRAmount = ISNULL(SUM(booked_fare),0) FROM [AI].[dbo].[vw_trip_ltr] A  
	-- inner JOIN  ai.dbo.trip_tickets  on   A.PNR = ai.dbo.trip_tickets.PNR  and A.trip_id= ai.dbo.trip_tickets.trip_id
	--			  left JOIN AI.dbo.tickets_banked 
	--						on Ai.dbo.tickets_banked.TicketNumber =Ai.dbo.trip_tickets.Ticket
	--							 and  a.PNR = ai.dbo.trip_tickets.PNR 
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 18  start banked tickets'   	
SELECT @LTRAmount = ISNULL(SUM(Amount),0) 
FROM TAOLAP.DBO.AIOLAP_Tickets_Banked with (nolock)
INNER JOIN @DKTable ND ON AIOLAP_Tickets_Banked.DK  = ND.DK  
Where TransactionType = 'Used' and IsLost= 1 
and issueDate between @fromDate  and @toDate  and
ForeignStatus in (0,1)  and Type = 'Air'

--FROM  AI.dbo.vw_bankAddedTickets VW with (nolock)
--  Inner join ai.Dbo.New_dk  with (nolock) on ai.dbo.new_dk.dk =  Vw.dk
--  inner JOIN  ai.dbo.trip_tickets   with (nolock) on   Vw.PNR = ai.dbo.trip_tickets.PNR  and Vw.trip_id= ai.dbo.trip_tickets.trip_id
--  left JOIN ai.dbo.tickets_banked  with (nolock)
--			on ai.dbo.tickets_banked.TicketNumber =ai.dbo.trip_tickets.Ticket
--				 and  Vw.PNR = ai.dbo.trip_tickets.PNR 
  
--where   IsLTR= 1 and  Vw.issue_date between @fromDate  and @toDate  and
--ForeignStatus in (0,1) 
-- and Vw.DK in (Select DK FROM @DKTable) 
--and type='Air'

	
INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 1, @LTRAmount )
	
	-------------------------------	
	-- LostTickets - CAR 
	-------------------------------	

	DECLARE @LTR_CarAmount float =  0 

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
	--				and ForeignStatus in (0,1)
	--				)

	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 2, @LTR_CarAmount ) 
	
	-------------------------------	
	-- LostTickets - HOTEL 
	-------------------------------	

	DECLARE @LTR_HtlAmount float

SELECT @LTR_HtlAmount = ISNULL(SUM(Amount),0) 
FROM TAOLAP.DBO.AIOLAP_Tickets_Banked with (nolock)
INNER JOIN @DKTable ND ON AIOLAP_Tickets_Banked.DK  = ND.DK  
Where TransactionType = 'Used' and IsLost= 1 
and issueDate between @fromDate  and @toDate  and
ForeignStatus in (0,1)  and Type = 'Hotel'

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

	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 3, @LTR_HtlAmount ) 
   
  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 18  start banked tickets'   	 
  
---------------------------------  
/*   CREDITS SAVINGS SECTION   */  
---------------------------------  
   
 -------------------------------   
 -- Exchanges - AIR - Value of exchanges - LTR values above  
 -- SLE 3-28-2012 - Make sure transactions that are exch AND void are only counted on void  
 -------------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 19  start ExchangeAmt'   	
 SET @selectClause = 'SELECT 12, 1, '  
 SET @selectClause = @selectClause + 'ISNULL(SUM(ExchangeAmt),0) FROM   vw_ReportCancellation_rpt '-- INNER JOIN #dk TMP_DK ON VW.DK = TMP_DK.DK '   
 SET @whereClause = ' '  
   
 SET @sqlQry = @selectClause + @whereClause  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
 SELECT 12 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')  
    
 -------------------------------   
 -- Exchanges - CAR - Always $0  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 12 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')  
   
 -------------------------------   
 -- Exchanges - HOTEL - Always $0  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 12 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 19  end ExchangeAmt'   	   
 -------------------------------   
 -- Refunds - AIR  
 ------------------------------- 
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 20  start Refund'   	  
 --SET @selectClause = 'SELECT 13, 1, '  
 --SET @selectClause = @selectClause + 'ISNULL((SUM(RefundAmt) * -1),0) FROM @AIR_TMAN '   
 --SET @whereClause = ' '    
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 13, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 13 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND  refundInd <> 'N'   
    
 -------------------------------   
 -- Refunds - CAR - Always $0  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 13 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND  refundInd <> 'N'   
   
 -------------------------------   
 -- Refunds - HOTEL - Always $0  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 13 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND  refundInd <> 'N'   
   
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 20  end Refund'   	  
 -------------------------------   
 -- Voids - AIR  
 -------------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 21  start VoidAmt'   	  
 --SET @selectClause = 'SELECT 14, 1, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(VoidAmt),0) FROM @AIR_TMAN '   
 --SET @whereClause = ' '  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 14, 1, 0 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 14 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND   voidInd ='Y'   
    
 -------------------------------   
 -- Voids - CAR - Always $0  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 14 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND   voidInd ='Y'   
   
 -------------------------------   
 -- Voids - HOTEL - Always $0  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
SELECT 14 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
  FROM  TMAN.dbo.vw_ReportCancellation_rpt VW  
  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
  Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
  AND   voidInd ='Y'   
   
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 21  end VoidAmt'   	  
 -------------------------------   
 -- Banked Tickets - AIR  
 -------------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 22  start banked tickets'   	  
 --SET @selectClause = 'SELECT 15, 1, '  
 --SET @selectClause = @selectClause + 'SUM(Amount) FROM [AI].[dbo].[tickets_banked] Left join [AI].[dbo].trip on [AI].[dbo].tickets_banked.pnr = [AI].[dbo].trip.pnr and   AI.dbo.tickets_banked.dk = Ai.dbo.trip.dk  '   
 --SET @dkClause = ' WHERE HaveAir=1 and   ForeignStatus in (0,1) and ( Ai.dbo.tickets_banked.DK IN (' + @dkList + ') ) '  
 --SET @dateClause = ' AND ( AddedDate BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' ) '   
 --SET @otherClause = ' AND ( TMan.[dba].[fn_ta_get_ltr_flag](AI.DBO.tickets_banked.TicketNumber)  = 0 ) and IsUsed= 0 and comment <> ''Deleted from Log, should not display'' and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) '  
   
 --SET @sqlQry = @selectClause + @dkClause + @dateClause + @otherClause  
   
 print @sqlQry  
   
 IF (@debug = 1)   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 1, 0 )   
 ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
 SELECT 15, 1, SUM(Amount) 
 FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw 
 INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
 Where TransactionType = 'Added' 
 --and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
 and AddedDate BETWEEN @fromdate AND  @todate  
 And isLost = 0 and Type = 'Air'
 and ForeignStatus in (0,1)
   
 -------------------------------   
 -- Banked Tickets - CAR - Always $0  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 2, 0 )   
   
 -------------------------------   
 -- Banked Tickets - HOTEL - Always $0  
 -------------------------------   
 --SET @selectClause = 'SELECT 15, 3, '  
 --SET @selectClause = @selectClause + 'SUM(Amount) FROM [AI].[dbo].[tickets_banked] Left join [AI].[dbo].trip on [AI].[dbo].tickets_banked.pnr = [AI].[dbo].trip.pnr and   AI.dbo.tickets_banked.dk = Ai.dbo.trip.dk  '   
 --SET @dkClause = ' WHERE HaveHotel=1 and   ForeignStatus in (0,1) and ( Ai.dbo.tickets_banked.DK IN (' + @dkList + ') ) '  
 --SET @dateClause = ' AND ( AddedDate BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' ) '   
 --SET @otherClause = ' AND ( TMan.[dba].[fn_ta_get_ltr_flag](AI.DBO.tickets_banked.TicketNumber)  = 0 ) and IsUsed= 0 and comment <> ''Deleted from Log, should not display'' and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) '  
   
 --SET @sqlQry = @selectClause + @dkClause + @dateClause + @otherClause  
   
 --print @sqlQry  
 
 IF (@debug = 1)   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 3, 0 )   
 ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
 SELECT 15, 3, SUM(Amount) 
 FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
 Where TransactionType = 'Added' 
 and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
 and AddedDate BETWEEN @fromdate AND  @todate  
 And isLost = 0 and Type = 'Hotel'
 and ForeignStatus in (0,1)
 --EXEC(@sqlQry)  
   
   
  
    PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 22  end banked tickets'   	  
 -------------------------   
 -- Total Spend - AIR    
 -------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 23  start Total Spend'   	  
 --SET @selectClause = 'SELECT 16, 1, '  
   
 --SET @selectClause = @selectClause + 'ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> ''USD'' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
 --   else price end) else 0 end  ),0) as price FROM @TripCost '   
 --SET @whereClause = ' WHERE (travelType = ''Air'')'  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 16, 1, 1 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  SELECT 16, 1, ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
    else price end) else 0 end  ),0) as price FROM @TripCost 
  WHERE (travelType = 'Air')  
   
   
 -------------------------   
 -- Total Spend - CAR    
 -------------------------   
 --SET @selectClause = 'SELECT 16, 2, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> ''USD'' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
 --   else price end) else 0 end ),0) as price  FROM @TripCost '   
 --SET @whereClause = ' WHERE (travelType = ''Car'')'  
    
 --SET @sqlQry = @selectClause + @whereClause  
   
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 16, 2, 4 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  SELECT 16, 2,ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
    else price end) else 0 end ),0) as price  FROM @TripCost 
  WHERE (travelType = 'Car')  
   
   
 ---------------------------   
 -- Total Spend - HOTEL    
 ---------------------------   
 --SET @selectClause = 'SELECT 16, 3, '  
 --SET @selectClause = @selectClause + 'ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> ''USD'' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
 --   else price end) else 0 end ),0)  as price FROM @TripCost '   
 --SET @whereClause = ' WHERE (travelType = ''Hotel'')'  
   
 --SET @sqlQry = @selectClause + @whereClause  
 --IF (@debug = 1)   
 --INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 16, 3, 3 )   
 --ELSE  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  SELECT 16, 3, ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
    else price end) else 0 end ),0)  as price FROM @TripCost    
  WHERE (travelType = 'Hotel')  
   
   
 -------------------------------   
 -- Total Transaction Count  
 -- Need to add this single value into construct used for all ROI values being passed back  
 -- Will add a 17th row with air=0 car=0 and hotel=total transactions  
 -- Main application will identify value of hotel in 17th row as total transactions  
 -------------------------------   
 DECLARE @totaltrx as float  
   
 SELECT @totaltrx = COUNT(distinct  invoiceNum) FROM @TripCost    

 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 17, 1, 0 )   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 17, 2, 0 )   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 17, 3, @totaltrx )   
 
 
  DECLARE @totalcnt as int   
   
 SELECT @totalcnt = COUNT(distinct  invoiceNum) FROM @TripCost    

 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 18, 1, 0 )   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 18, 2, 0 )   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 18, 3, @totalcnt )   
 
 
  
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 23  end Total Spend'   	  
  
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
 --drop table @TripCost  
 drop table #TripWaivers   
 --drop table @AIR_TMAN  
 --drop table @CAR_TMAN  
 --drop table @HOTEL_TMAN  
   
 drop table #AuditSearchSaving  
   
 -------------------------------   
 -- Clean up null returned values  
 -------------------------------   
 UPDATE @tempRoiValues   
 SET Amount = 0   
 WHERE (Amount is null)  
    
 -------------------------------   
 -- Extract values from table variable   
 -- for return to app  
 -------------------------------   
 SELECT * FROM @tempRoiValues  
 ORDER BY RoiType, TravelType  
   
   
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 1 end sp'   
END
GO
