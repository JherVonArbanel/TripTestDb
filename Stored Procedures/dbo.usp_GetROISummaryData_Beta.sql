SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

  
/** SWITCHED TO TMAN FOR TOTAL SPEND AND TOTAL TRX - 11/9/12 SE **/  
/** Changed Total TRX to be the total unique invoices - 12/17/12 SE **/  
/** Changed to use new tables in Tman -- 07/11/13 NH **/  
  
CREATE PROCEDURE [dbo].[usp_GetROISummaryData_Beta]   
(   
@clientID nvarchar(MAX), --- used for creating specific results for demos  
@fromDate nvarchar(20),   
@toDate nvarchar(20),   
@dkList varchar(MAX),   
@IsRgUsed bit=0,
@udidNum1 int=0,  
@udidValue1 nvarchar(Max)='',  
@udidNum2 int=0,  
@udidValue2 nvarchar(100)='' ,
@isFromProgramSummary bit = 0 
)  
AS  
BEGIN  
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 1 start sp'
SET ANSI_WARNINGS OFF  
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
 
CREATE TABLE #tmpRG (RGNum INT,RGValue VARCHAR(255))

IF (@IsRgUsed != 0 AND @udidValue1 <> '')
	INSERT INTO #tmpRG (RGNum,RGValue) 
	SELECT (SUBSTRING(string,1,CHARINDEX('-',string)-1)), (SUBSTRING(string,CHARINDEX('-',string)+1,LEN(string)))	FROM AI.[dbo].[ufn_DelimiterToTable](@udidValue1,'|') 
	
	
	
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
   

 DECLARE @dkListShort nvarchar(500) = ''  
 DECLARE @position int   
 DECLARE @prefix nvarchar(10) = ''''   
  
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
  pnr CHAR(6),    
  price DECIMAL(18,2)  ,  
  Currency varchar(5),  
  TripStatus int,  
  Enddatetime datetime,  
  invoiceNum varchar(10)  ,
  exchangeRateAmount decimal(18,2)
   )   
   

  
Declare  @AIR_TMAN  table
 (  
 WebSavings   DECIMAL(18,2),  
 PrepaidSavings  DECIMAL(18,2),  
 AwardSavings  DECIMAL(18,2)
 )  
  
Declare @CAR_TMAN table
 (  
 
 WebSavings   DECIMAL(18,2),  
 PrepaidSavings  DECIMAL(18,2)
 )  
  
declare @HOTEL_TMAN   table
 (  
 WebSavings   DECIMAL(18,2),  
 PrepaidSavings  DECIMAL(18,2)
 )  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 2 end table' 
-- 11JUL13 INSERT DATA TO NEW TABLES FOR CHANGE TO TMAN 


if(@IsRgUsed = 0 ) 
Begin
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 start TMAN AIR table' 
INSERT @AIR_TMAN  
 (  WebSavings,  PrepaidSavings, AwardSavings)  
 SELECT  WebSavings,  PrepaidSavings, AwardSavings
 FROM TMAN.DBA.TA_ROI_AIR  Air With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Air.DK
 WHERE  issuedate BETWEEN @fromDate AND @toDate  
   

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 end TMAN AIR table' 

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  start TMAN CaR table' 
  
INSERT @CAR_TMAN  
 (WebSavings,  PrepaidSavings)  
 SELECT WebSavings,  PrepaidSavings
 FROM TMAN.DBA.TA_ROI_CAR  Car With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Car.DK 
 WHERE issuedate BETWEEN @fromDate AND @toDate  


 
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  End TMAN CaR table'   
  
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  start TMAN Hotel table' 
INSERT @HOTEL_TMAN  
 (WebSavings,  PrepaidSavings)  
 SELECT WebSavings,  PrepaidSavings
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
  ( travelType,  pnr, price, currency ,TripStatus,Enddatetime, invoiceNum)  
  SELECT type,  pnr, amount, currency,3,endTravelDate, invoiceNum  
  FROM  [TMAN].[dba].TA_SPEND_RPT  spend With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = spend.DK  
  WHERE  issuedate BETWEEN @fromDate AND @toDate  

update @TripCost
set price = tc.price / E.exchangeRateAmount,
	exchangeRateAmount = E.exchangeRateAmount
From 	@TripCost Tc inner join	vault.dbo.Currency C  on Tc.currency  = C.currencyCode 
		inner join  vault.dbo.exchangeRate E on C.currencyKey  = E.currencyKey 
Where currency <> 'USD' and currency is not null and exchangeRateDate = Enddatetime



update @TripCost
set price = tc.price / tmp.exchangeRateAmount,
	exchangeRateAmount = tmp.exchangeRateAmount
From 	@TripCost Tc inner join	
		( select top 1 currencyCode, exchangeRateAmount  from  vault.dbo.Currency C 
		inner join  vault.dbo.exchangeRate E on C.currencyKey  = E.currencyKey order by  exchangeRateDate desc )  tmp on
		Tc.Currency = tmp.currencyCode 
Where currency <> 'USD' and currency is not null and tc.exchangeRateAmount <= 0 



   --select count(*) from @TripCost
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 5  end TMAN spend table'   
   End
   Else
   Begin
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 start TMAN AIR table' 
INSERT @AIR_TMAN  
 (WebSavings,  PrepaidSavings, AwardSavings)  
 SELECT WebSavings,  PrepaidSavings, AwardSavings
 FROM TMAN.DBA.TA_ROI_AIR  Air With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Air.DK
 
 WHERE  issuedate BETWEEN @fromDate AND @toDate  
  And  RecordKey IN (SELECT DISTINCT recordkey 
						  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue) 
   

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 end TMAN AIR table' 

PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  start TMAN CaR table' 
  
INSERT @CAR_TMAN  
 (WebSavings,  PrepaidSavings)  
 SELECT WebSavings,  PrepaidSavings
 FROM TMAN.DBA.TA_ROI_CAR  Car With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Car.DK 
 WHERE issuedate BETWEEN @fromDate AND @toDate  
   And  RecordKey IN (SELECT DISTINCT recordkey 
						  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue) 


 
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  End TMAN CaR table'   
  
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 4  start TMAN Hotel table' 
INSERT @HOTEL_TMAN  
 (WebSavings,  PrepaidSavings)  
 SELECT WebSavings,  PrepaidSavings
 FROM TMAN.DBA.TA_ROI_HOTEL Hotel With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = Hotel.DK
 WHERE issuedate BETWEEN @fromDate AND @toDate 
   And  RecordKey IN (SELECT DISTINCT recordkey 
						  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)  
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
  ( travelType, pnr, price, currency ,Enddatetime, invoiceNum)  
  SELECT type,  pnr, amount,currency,
  endTravelDate, invoiceNum  
  FROM  [TMAN].[dba].TA_SPEND_RPT  spend With (Nolock)
 Inner join @DKTable tmpDK on tmpDK.dk = spend.DK  
  WHERE  issuedate BETWEEN @fromDate AND @toDate  
  And  RecordKey IN (SELECT DISTINCT recordkey 
						  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue) 
   --select count(*) from @TripCost
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 5  end TMAN spend table'   
   End
    
   
 ---------------------------------  
 /*   POLICY SAVINGS SECTION    */  
 ---------------------------------  
 -------------------------   
 -- Policy Savings - AIR Lost Opportunity *** (booked + actual = original fare) - lowest_fare (LF) is savings not taken at point of sale  
 -------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 7  start policy' 
if(@IsRgUsed = 0 ) 
Begin
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
		TravelType,
		Sum(lost) as Amount
		From
		   taolap.dbo.vw_AuditException_OLAP_ROI_Beta VW   with (nolock) 
		Inner join @DKTable TMP_DK on    VW.DK = TMP_DK.DK	
 	WHERE (creation_date BETWEEN   @fromDate AND @toDate    )  
 	AND lost > 0
	AND vw.foreignStatus IN(0,1) 
    Group by TravelType )  a on t.TravelType = a.TravelType 
   End
   Else
   Begin
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
		   taolap.dbo.vw_AuditException_OLAP_Beta VW   with (nolock) 
		Inner join @DKTable TMP_DK on    VW.DK = TMP_DK.DK	
 	WHERE (creation_date BETWEEN   @fromDate AND @toDate    )  
	AND lost > 0
	AND vw.foreignStatus IN(0,1) 
	 and reason_Code not in ('E','A','','FJA')
	and vw.trip_id in 	(SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
							INNER JOIN #tmpRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE)
    Group by Type )  a on t.TravelType = a.TravelType 
   End
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 3 start sp' 
  
   
  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 7  end policy'    
   
 -------------------------------   
 -- Negotiated Contracts - AIR Savings Due to Client Contract  
 -- *** (UDID91 - ( booked_fare + actual_savings )) = ( FF - original ) ***  
 --      UD91 = WP value, without use of client contract, entered by file finishing script  
 -------------------------------   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 8  start contract'    
  
  INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  Select  1 , 1 , 0 
  Union 
  Select  1 , 2 , 0 
  Union 
  Select  1 , 3 , 0 
 
if(@IsRgUsed = 0 ) 
Begin
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
	and isnull(DiscountType,0) = 0 
group by type )  a on t.TravelType = a.TravelType and RoiType = 1 
 End
 Else
 Begin
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
	and isnull(DiscountType,0) = 0 
	 And  t.RecordKey IN (SELECT DISTINCT recordkey 
						  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue) 
group by type )  a on t.TravelType = a.TravelType and RoiType = 1 
 End
 
 
   
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 8  end contract'    
 -------------------------------   
 -- Loyalty Awards - AIR  (2.5% or air volume for client's airline programs (Use carriers in PQ table that dont have ?I = Smap code))  
 -- SLE 4/3/2012 - added limitation where PQline not like '%?I%' to omit all the PQ lines relating to snap codes.  
 -- TODO - switch away from TripAir to the TripTickets table  
 -------------------------------   
  
 
   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 9  start awards'    
 
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
 ---------------------------------   
 --PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 10  start payment'      
 --SET @rebatePct = '0.00000'  
 --SELECT @rebatePct=ISNULL(MAX(RebatePercent),0) from [AI].[dbo].[PaymentRebate] Payment with (nolock)
 --Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK  
 --WHERE RebateActive = 'True'  
   
  
 -------------------------------   
 -- Payment Rebate - AIR ( x% rebate on total air spend )  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
 --SELECT 3, 1,ISNULL((SUM(TtlTktAmt) *  @rebatePct ),0) FROM @AIR_TMAN 
 SELECT 3,1, Sum(RebateAmt) FROM [TMAN].[dba].[TA_ROI_PAYMENTREBATE] Payment 
 Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK   
  Where  issuedate BETWEEN  @fromDate AND @toDate 
  and Type = 'Air'
   
 -------------------------------   
 -- Payment Rebate - CAR  ( x% rebate on total car spend )  
 -------------------------------   

 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)  
 --SELECT 3, 2,  ISNULL((SUM(TtlCarAmt) *  @rebatePct ),0) FROM @CAR_TMAN
  SELECT 3,2, Sum(RebateAmt) FROM [TMAN].[dba].[TA_ROI_PAYMENTREBATE] Payment 
 Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK   
  Where  issuedate BETWEEN  @fromDate AND @toDate 
  and Type = 'Car'   
   
   
 -------------------------------   
 -- Payment Rebate - HOTEL ( x% rebate on total hotel spend )  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
 --SELECT 3, 3,ISNULL((SUM(TtlHtlAmt) * @rebatePct ),0) FROM @HOTEL_TMAN 
  SELECT 3,3, Sum(RebateAmt) FROM [TMAN].[dba].[TA_ROI_PAYMENTREBATE] Payment 
 Inner join @DKTable tmpDK on tmpDK.dk = Payment.DK   
  Where  issuedate BETWEEN  @fromDate AND @toDate 
  and Type = 'Hotel'
  
  
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
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
	SELECT 4, 1, COUNT(*)  * @onlineSavings 
	FROM tman.dba.ta_spend_rpt trn  with (nolock) Inner join @DKTable tmpDK on tmpDK.dk = trn.DK 
	WHERE (BookedOnline in (1,2))
	and IssueDate between  @FromDate AND @ToDate 
	and TYPE = 'Air'
	
	
	
	
		
	print @HConlineSavings
	-------------------------------	
	-- Online Adoption - CAR 
	-------------------------------	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 2, 0 ) 

INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
	SELECT 4, 2, COUNT(*)  * @HConlineSavings 
	FROM tman.dba.ta_spend_rpt trn  with (nolock) Inner join @DKTable tmpDK on tmpDK.dk = trn.DK 
	WHERE (BookedOnline in (1,2))and (CarHtlOnly = 1)
	and IssueDate between  @FromDate AND @ToDate 
	and TYPE = 'Car '
	
	
	
	-------------------------------	
	-- Online Adoption - HOTEL 
	-------------------------------	
	--INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 3, 0 ) 

	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
	SELECT 4, 3, COUNT(*)  * @HConlineSavings 
	FROM tman.dba.ta_spend_rpt trn  with (nolock) Inner join @DKTable tmpDK on tmpDK.dk = trn.DK 
	WHERE (BookedOnline in (1,2))and (CarHtlOnly = 1)
	and IssueDate between  @FromDate AND @ToDate 
	and TYPE = 'Hotel '
		
	
	
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 11  end online adoption'      
 -------------------------------   
 -- Web Fares - AIR Savings from use of Web Fare (UD94 - Original_Fare)  
 --  (UDID94 Contains the SABRE fare entered by file finish script)  
 -------------------------------   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 12  start websaving'      
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )
 SELECT 5, 1, ISNULL(SUM(WebSavings),0) FROM @AIR_TMAN   
     
 -------------------------------   
 -- Web Fares - CAR Savings from use of Web Rate  
 -- ROI_FF = lowest non-discounted rate for same car *** ROI_f1 = 'WEB'   
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)   
  SELECT 5, 2, ISNULL(SUM(WebSavings),0) FROM @CAR_TMAN  
   
 -------------------------------   
 -- Web Fares - HOTEL Savings from use of Web Rate  
 -- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'WEB'   
 -------------------------------   
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
 
 
if(@IsRgUsed = 0 ) 
Begin
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
END
ELSE
BEGIN
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
					INNER JOIN (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
								INNER JOIN #tmpRG B ON TU.NUM = B.RGNum AND TU.VAL = B.RGValue
				)  AS TU ON TU.UDIDTrip_ID= IssRes.TRIP_ID
					--INNER JOIN #ForeignStatus FS ON FS.ForeignStatus = IssRes.ForeignStatus
			WHERE 
					 Opendt BETWEEN @FromDate AND @ToDate
					 and  IssRes.ForeignStatus in (0,1)
					 and vendorCode is not null
					 and action ='Waiver'
		group by type			 
		 )  a on t.TravelType = a.TravelType and RoiType = 6
 END
   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 13  end Restriction'   
 -------------------------------   
 -- Prepaid - AIR - Savings from use of Prepaid Air  *** (UDID87 - Original_Fare) ***     
 -- UDID87 contains SABRE fare for prepaid flight  
 -- TODO - do not see any data in UD96  
 ---------------------------------   
   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 14  start PrepaidSavings'   
  --GOTO CLEANUP  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )
  SELECT 7, 1, ISNULL(SUM(PrepaidSavings),0) FROM @AIR_TMAN   
   
   
 -------------------------------   
 -- Prepaid - CAR - Savings from use of Prepaid Car  *** ((ROI_FF - originalRate) * numDays) ***     
 -- ROI_f1 = 'PRE'   
 -- TODO - no data found yet  
 -------------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)   
  SELECT 7, 2, ISNULL(SUM(PrepaidSavings),0) FROM @CAR_TMAN  
   
   
 -------------------------------   
 -- Prepaid - HOTEL  
 -- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'PRE'   
 -------------------------------   
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
 
 if(@IsRgUsed = 0 )
 Begin
	 Update #AuditSearchSaving 
	 Set ActualSavings =  ai.dbo.fn_Currency_Converter_New(FareCurrency , tmp.ActualSavings, GETDATE())
	 From 
	 #AuditSearchSaving Inner join 
	  ( 
	 
	 Select FareCurrency , Round(actualsavings,0) as actualsavings,[type] From  
	 (  
	 SELECT sum(actual_savings) AS actualsavings,type,FareCurrency  
	 FROM TAOLAP.[dbo].[AIOlap_Trip] Audit WITH (NOLOCK)  
	   INNER JOIN   @tmpClientID  TMPCLIENT ON AUDIT.client_id = TMPCLIENT.ClientID  
	   INNER JOIN   @DKTable  TMPDK ON AUDIT.dk = TMPDK.DK   
	 WHERE creation_date between @FromDate and @ToDate  
	   AND (rejected_savings > 0 OR actual_savings > 0 OR pending_savings  > 0)   
	   And ForeignStatus in (0,1,2)  
	 GROUP BY type,FareCurrency   
	 )Savings    ) 
	 tmp on #AuditSearchSaving.Type = tmp.type
	  
	 SET @selectClause = 'SELECT 8, 1, '  
	 SET @selectClause = @selectClause + 'ISNULL(ActualSavings,0) FROM #AuditSearchSaving Where Type = ''Air''   '   
 end
 else
 Begin
	 Update #AuditSearchSaving 
	 Set ActualSavings = ai.dbo.fn_Currency_Converter_New(FareCurrency , tmp.ActualSavings, GETDATE())
	 From 
	 #AuditSearchSaving Inner join 
	 ( 
	 Select FareCurrency, Round(actualsavings,0) as actualsavings,[type] From  
	 (  
	 SELECT sum(actual_savings) AS actualsavings,type,FareCurrency  
	 FROM TAOLAP.[dbo].[AIOlap_Trip] Audit WITH (NOLOCK)  
	   INNER JOIN   @tmpClientID  TMPCLIENT ON AUDIT.client_id = TMPCLIENT.ClientID  
	   INNER JOIN   @DKTable  TMPDK ON AUDIT.dk = TMPDK.DK   
   		INNER JOIN (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
								INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
				)  AS TU ON TU.UDIDTrip_ID=Audit.TRIP_ID
	 WHERE creation_date between @FromDate and @ToDate  
	   AND (rejected_savings > 0 OR actual_savings > 0 OR pending_savings  > 0)   
	   And ForeignStatus in (0,1,2)  
	 GROUP BY type,FareCurrency   
	 )Savings    ) 
	 tmp on #AuditSearchSaving.Type = tmp.type
	  
	 SET @selectClause = 'SELECT 8, 1, '  
	 SET @selectClause = @selectClause + 'ISNULL(ActualSavings,0) FROM #AuditSearchSaving Where Type = ''Air''   '   
  end
  
 SET @sqlQry = @selectClause   
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


 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  Select  9 , 1 , 0 
  Union 
  Select  9 , 2 , 0 
  Union 
  Select  9 , 3 , 0 
 
if(@IsRgUsed = 0 ) 
Begin
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
	and DiscountType =1 
group by type )  a on t.TravelType = a.TravelType and RoiType = 9 
 End
 Else
 Begin
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
	and DiscountType =1 
	 And  t.RecordKey IN (SELECT DISTINCT recordkey 
						  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue) 
group by type )  a on t.TravelType = a.TravelType and RoiType = 9
 End
   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 16  end AgencyDiscSavings'     
 ---------------------------------------------------------   
 -- PreTrip - AIR - Value of Denied air segments: Approval   
 ---------------------------------------------------------   
 
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 17  start PreTrip'   
  
if(@IsRgUsed = 0 )   -- With out Udid filter 
Begin
INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )	
SELECT 10, 1 ,  ISNULL(SUM(vw.fare),0) 
--FROM TAOLAP.DBO.vw_AuditApprovals_OLAP_Beta
FROM AI.DBO.vw_trip_itinerary_approval_ROI_Beta vw
inner join @DKTable tmp on tmp.DK = vw.dk
WHERE  
creation_date BETWEEN  @fromDate  AND  @toDate  and type = 'Air'
AND IsTripApproved=0  AND approvedDT <> '1/1/2000'
AND ( approvedComment not like '%DEADLINE REACHED%' and approvedComment not like '%approval cancelled%') 
and ApprovalReasonCode not like '%Notification%'
and ((type='Air' and  haveair = 1)  --and current_rate  >= 0) 
or (type='Car' and havecar = 1)  --and  original_Rate  >= 0)
or ( type='Hotel' and havehotel = 1))  --and  total >= 0))
and foreignstatus in(-1,0,1,2)
	 -------------------------------   
 -- PreTrip - CAR - Value of Denied Car segments   
 -------------------------------   
	 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)		
	SELECT 10, 2 , 
	 ISNULL(SUM(vw.fare),0) 
	 FROM AI.DBO.vw_trip_itinerary_approval_ROI_Beta vw
	 inner join @DKTable tmp on tmp.DK = vw.dk  
	 --FROM TAOLAP.DBO.vw_AuditApprovals_OLAP_Beta
	WHERE   creation_date BETWEEN  @fromDate  AND  @toDate and type = 'Car'
	 AND IsTripApproved=0  AND approvedDT <> '1/1/2000'
	 AND ( approvedComment not like '%DEADLINE REACHED%' and approvedComment not like '%approval cancelled%') 
	and ApprovalReasonCode not like '%Notification%'
	 and ((type='Air' and  haveair = 1)--  and current_rate  >= 0) 
	 or (type='Car' and havecar = 1)--  and  original_Rate  >= 0) 
	 or( type='Hotel' and havehotel = 1))--  and  total >= 0))
	 and foreignstatus in(-1,0,1,2)
	 
	 -------------------------------   
 -- PreTrip - HOTEL - Value of Denied Hotel segments   
 -------------------------------   
	  INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)		
	SELECT 10, 3 , 
	 ISNULL(SUM(vw.fare),0) 
	 FROM AI.DBO.vw_trip_itinerary_approval_ROI_Beta vw
	  inner join @DKTable tmp on tmp.DK = vw.dk
	 --FROM TAOLAP.DBO.vw_AuditApprovals_OLAP_Beta
	WHERE creation_date BETWEEN  @fromDate  AND  @toDate and type ='Hotel'
	 AND IsTripApproved=0  AND approvedDT <> '1/1/2000'
	 AND ( approvedComment not like '%DEADLINE REACHED%' and approvedComment not like '%approval cancelled%') 
	and ApprovalReasonCode not like '%Notification%'
	 and ((type='Air' and  haveair = 1)--  and current_rate  >= 0) 
	 or (type='Car' and havecar = 1)--  and  original_Rate  >= 0)  
	 or( type='Hotel' and havehotel = 1))--  and  total >= 0))
	 and foreignstatus in(-1,0,1,2) 
   End
   Else
   Begin    -- With  Udid filter 
 
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
SELECT 10, 1 ,  ISNULL(SUM(vw.fare),0) 
FROM AI.DBO.vw_trip_itinerary_approval_ROI_Beta vw
--FROM TAOLAP.DBO.vw_AuditApprovals_OLAP_Beta
		 	Inner JOIN 
			(SELECT DISTINCT trip_id as TUTRIP_ID
			 FROM AI.DBO.Trip_UDID TU WITH (NOLOCK)
			--FROM TAOLAP..AIOLAP_Trip_UDID TU WITH (NOLOCK)
				inner join #tmpRG b on TU.Num = b.RGNum and TU.Val = b.RGValue
			) UD ON trip_id=UD.TUTRIP_ID									

WHERE  dk IN (Select DK FROM @DKTable )  

AND IsTripApproved=0  AND approvedDT <> '1/1/2000'
AND ( approvedComment not like '%DEADLINE REACHED%' and approvedComment not like '%approval cancelled%') 
and ApprovalReasonCode not like '%Notification%'
and type in ('Air') 
and ((type='Air' and  haveair = 1)--  and current_rate  >= 0) 
or (type='Car' and havecar = 1)--  and  original_Rate  >= 0) 
or ( type='Hotel' and havehotel = 1 ))-- and  total >= 0))
AND creation_date BETWEEN  @fromDate  AND  @toDate 
and foreignstatus in(-1,0,1,2)

	 -------------------------------   
 -- PreTrip - CAR - Value of Denied Car segments   
 -------------------------------   
INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)		
SELECT 10, 2 , ISNULL(SUM(vw.fare),0)
FROM AI.DBO.vw_trip_itinerary_approval_ROI_Beta vw 
--FROM TAOLAP.DBO.vw_AuditApprovals_OLAP_Beta
				Inner JOIN 
				(SELECT DISTINCT trip_id as TUTRIP_ID
				FROM AI.DBO.Trip_UDID TU WITH (NOLOCK)
				--FROM TAOLAP..AIOLAP_Trip_UDID TU WITH (NOLOCK)
					inner join #tmpRG b on TU.Num = b.RGNum and TU.Val = b.RGValue
				) UD ON trip_id=UD.TUTRIP_ID			
WHERE  dk IN (Select DK FROM @DKTable )  
AND IsTripApproved=0  AND approvedDT <> '1/1/2000'
AND ( approvedComment not like '%DEADLINE REACHED%' and approvedComment not like '%approval cancelled%') 
and ApprovalReasonCode not like '%Notification%'
and type in ('Car') 
and ((type='Air' and  haveair = 1 )-- and current_rate  >= 0) 
or (type='Car' and havecar = 1)--  and  original_Rate  >= 0)
or ( type='Hotel' and havehotel = 1 ))-- and  total >= 0))
AND creation_date BETWEEN  @fromDate  AND  @toDate 
and foreignstatus in(-1,0,1,2)

	 -------------------------------   
 -- PreTrip - HOTEL - Value of Denied Hotel segments   
 -------------------------------   
INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )-- EXEC(@sqlQry)		
SELECT 10, 3 , 	 ISNULL(SUM(vw.fare),0) 	 
FROM AI.DBO.vw_trip_itinerary_approval_ROI_Beta vw
--FROM TAOLAP.DBO.vw_AuditApprovals_OLAP_Beta
Inner JOIN 
		(SELECT DISTINCT trip_id as TUTRIP_ID
		FROM AI.DBO.Trip_UDID TU WITH (NOLOCK)
		--FROM TAOLAP..AIOLAP_Trip_UDID TU WITH (NOLOCK)
			inner join #tmpRG b on TU.Num = b.RGNum and TU.Val = b.RGValue
		) UD ON trip_id=UD.TUTRIP_ID			
WHERE  dk IN (Select DK FROM @DKTable )  
AND IsTripApproved=0  AND approvedDT <> '1/1/2000'
AND ( approvedComment not like '%DEADLINE REACHED%' and approvedComment not like '%approval cancelled%') 
and ApprovalReasonCode not like '%Notification%'
and type in ('Hotel') 
and ((type='Air' and  haveair = 1)--  and current_rate  >= 0) 
or (type='Car' and havecar = 1)--  and  original_Rate  >= 0) 
or ( type='Hotel' and havehotel = 1))--  and  total >= 0))
AND creation_date BETWEEN  @fromDate  AND  @toDate 
and foreignstatus in(-1,0,1,2) 
   End

   
   
   
  PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 17  end PreTrip'    
   -------------------------------	
	-- LostTickets - AIR
	-------------------------------	
	DECLARE @LTRAmount float
	
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 18  start banked tickets'   	
	DECLARE @LTR_CarAmount float =  0 
		DECLARE @LTR_HtlAmount float

if(@IsRgUsed = 0 )
BEGIN
		--SELECT @LTRAmount = ISNULL(SUM(Amount),0) 
		--FROM TAOLAP.DBO.AIOLAP_Tickets_Banked with (nolock)
		--INNER JOIN @DKTable ND ON  TAOLAP.DBO.AIOLAP_Tickets_Banked.DK  = ND.DK  
		--Where
		--	Islost = 1  and TransactionType = 'Added' 
		--	and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		--	and AddedDate between @fromDate  and @toDate  
		--	and isnull(ForeignStatus,-1) in (-1,0,1,2)  and IsHasAir = 1
		
		
		---Lost value for Air
		SELECT @LTRAmount = ISNULL( sum(AI.DBO.tickets_banked.Amount) ,0)
		FROM  @DKTable ND 
		inner JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK = ND.dk
		inner JOIN AI.DBO.trip WITH (NOLOCK) ON AI.DBO.tickets_banked.pnr =AI.DBO.trip.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip.dk
		inner join ai.dbo.trip_tickets TT WITH (NOLOCK) ON AI.DBO.tickets_banked.TicketNumber = TT.Ticket and oosdt is not null
	
		WHERE AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate  
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		and isnull(tt.isLTR, 0 )  = 1 		
		AND IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		and HaveAir = 1


		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 1, @LTRAmount )
			
			-------------------------------	
			-- LostTickets - CAR 
			-------------------------------	


			INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 2, @LTR_CarAmount ) 
			
			-------------------------------	
			-- LostTickets - HOTEL 
			-------------------------------	


		--SELECT @LTR_HtlAmount = ISNULL(SUM(Amount),0) 
		--FROM TAOLAP.DBO.AIOLAP_Tickets_Banked with (nolock)
		--INNER JOIN @DKTable ND ON TAOLAP.DBO.AIOLAP_Tickets_Banked.DK  = ND.DK  

		--	Where Islost = 1  and TransactionType = 'Added' 
		--	and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		--	and AddedDate between @fromDate  and @toDate  
		--	and isnull(ForeignStatus,-1) in (-1,0,1,2)  and IsHasHotel = 1
		
		---Lost value for Hotel
		
		SELECT @LTR_HtlAmount = ISNULL( sum(AI.DBO.tickets_banked.Amount) ,0)
		FROM  @DKTable ND 
		inner JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK = ND.dk
		inner JOIN AI.DBO.trip WITH (NOLOCK) ON AI.DBO.tickets_banked.pnr =AI.DBO.trip.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip.dk
		inner join ai.dbo.trip_tickets TT WITH (NOLOCK) ON AI.DBO.tickets_banked.TicketNumber = TT.Ticket and oosdt is not null
		
		WHERE AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate  
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		and 
		isnull(tt.isLTR, 0 )  = 1 		
		AND IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		and HaveHotel = 1

		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 3, @LTR_HtlAmount ) 
END
ELSE
BEGIN
		--SELECT @LTRAmount = ISNULL(SUM(Amount),0) 
		--FROM TAOLAP.DBO.AIOLAP_Tickets_Banked with (nolock)
		--INNER JOIN @DKTable ND ON  TAOLAP.DBO.AIOLAP_Tickets_Banked.DK  = ND.DK  
		--INNER JOIN (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
		--					INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
		--	)  AS TU ON TU.UDIDTrip_ID=TRIP_ID
		--Where
		--	Islost = 1  and TransactionType = 'Added' 
		--	and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		--	and AddedDate between @fromDate  and @toDate  
		--	and isnull(ForeignStatus,-1) in (-1,0,1,2)  and IsHasAir = 1
		
		---Lost value for Air
		SELECT @LTRAmount = ISNULL( sum(AI.DBO.tickets_banked.Amount) ,0)
		FROM @DKTable ND 
		inner JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK =ND.dk
		inner JOIN AI.DBO.trip WITH (NOLOCK) ON AI.DBO.tickets_banked.pnr =AI.DBO.trip.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip.dk
		inner join ai.dbo.trip_tickets TT WITH (NOLOCK) ON AI.DBO.tickets_banked.TicketNumber = TT.Ticket and oosdt is not null
		
		INNER JOIN (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
							INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
			) AS TU ON TU.UDIDTrip_ID= AI.DBO.trip.trip_id
		WHERE
		AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate  
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		and 
		 isnull(tt.isLTR, 0 )  = 1 		
		AND IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		
		and HaveAir = 1

		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 1, @LTRAmount )
			
			-------------------------------	
			-- LostTickets - CAR 
			-------------------------------	

			
			INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 2, @LTR_CarAmount ) 
			
			-------------------------------	
			-- LostTickets - HOTEL 
			-------------------------------	



		--SELECT @LTR_HtlAmount = ISNULL(SUM(Amount),0) 
		--FROM TAOLAP.DBO.AIOLAP_Tickets_Banked with (nolock)
		--INNER JOIN @DKTable ND ON TAOLAP.DBO.AIOLAP_Tickets_Banked.DK  = ND.DK 
		--INNER JOIN (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
		--					INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
		--	)  AS TU ON TU.UDIDTrip_ID=TRIP_ID 
		--	Where Islost = 1  and TransactionType = 'Added' 
		--	and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		--	and AddedDate between @fromDate  and @toDate  
		--	and isnull(ForeignStatus,-1) in (-1,0,1,2)  and IsHasHotel = 1
		
		---Lost value for Hotel
		SELECT @LTR_HtlAmount = ISNULL( sum(AI.DBO.tickets_banked.Amount) ,0)
		FROM  @DKTable ND
		inner JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK =ND.dk
		inner JOIN AI.DBO.trip WITH (NOLOCK) ON AI.DBO.tickets_banked.pnr =AI.DBO.trip.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip.dk
		inner join ai.dbo.trip_tickets TT WITH (NOLOCK) ON AI.DBO.tickets_banked.TicketNumber = TT.Ticket and oosdt is not null
		INNER JOIN (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
							INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
			)  AS TU ON TU.UDIDTrip_ID= AI.DBO.trip.trip_id
		WHERE AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate   		
		AND IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		and isnull(tt.isLTR, 0 )  = 1 
		and HaveHotel = 1
		

			INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 3, @LTR_HtlAmount ) 
 END

  
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 18  end banked tickets'   	 
  
---------------------------------  
/*   CREDITS SAVINGS SECTION   */  
---------------------------------  
   
 -------------------------------   
 -- Exchanges - AIR - Value of exchanges - LTR values above  
 -- SLE 3-28-2012 - Make sure transactions that are exch AND void are only counted on void  
 -------------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 19  start ExchangeAmt'   	

 IF(@IsRgUsed = 0 )
 BEGIN
    
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		 SELECT 12 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')  
		    
		 -------------------------------   
		 -- Exchanges - CAR - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 12 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')  
		   
		 -------------------------------   
		 -- Exchanges - HOTEL - Always $0  
		 -------------------------------  
		 ----Commented for 16186 
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
	
		 SELECT 12 , 3 ,0  AS TotalPrice  
		 
		 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 19  end ExchangeAmt'   	   
		 -------------------------------   
		 -- Refunds - AIR  
		 ------------------------------- 
		 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 20  start Refund'   	  
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 13 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND  refundInd <> 'N'   
		    
		 -------------------------------   
		 -- Refunds - CAR - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 13 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND  refundInd <> 'N'   
		   
		 -------------------------------   
		 -- Refunds - HOTEL - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 13 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND  refundInd <> 'N'   
		   
		   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 20  end Refund'   	  
		 -------------------------------   
		 -- Voids - AIR  
		 -------------------------------   
		 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 21  start VoidAmt'   	  
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 14 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND   voidInd ='Y'   
		    
		 -------------------------------   
		 -- Voids - CAR - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 14 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND   voidInd ='Y'   
		   
		 -------------------------------   
		 -- Voids - HOTEL - Always $0  
		 -------------------------------   
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 14 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		AND   voidInd ='Y'   

		PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 21  end VoidAmt'   	  
		-------------------------------   
		-- Banked Tickets - AIR  
		-------------------------------   
		PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 22  start1 banked tickets'   	  

		IF (@debug = 1)   
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 1, 0 )   
		ELSE 
		
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
		 
		SELECT 15, 1, sum(AI.DBO.tickets_banked.Amount) 
		FROM @DKTable ND 
		inner JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK =ND.dk  
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) and AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate
		inner JOIN AI.DBO.trip WITH (NOLOCK) ON AI.DBO.tickets_banked.pnr =AI.DBO.trip.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip.dk
		Left join ai.dbo.trip_tickets TT WITH (NOLOCK) ON AI.DBO.tickets_banked.TicketNumber = TT.Ticket and oosdt is not null
		WHERE 
		AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate  
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		and
		 isnull(tt.isLTR, 0 )  = 0		
		AND IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		and HaveAir = 1
		 
		 --SELECT 15, 1, SUM(Amount) 
		 --FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw 
		 --INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		 --Where TransactionType = 'Added' 
		 ----and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		 --and AddedDate BETWEEN @fromdate AND  @todate  
		 --And isLost = 0 and Type = 'Air'
		 --and isnull(ForeignStatus,-1) in (-1,0,1,2)
		   
		-------------------------------   
		-- Banked Tickets - CAR - Always $0  
		-------------------------------   
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 2, 0 )   

		-------------------------------   
		-- Banked Tickets - HOTEL - Always $0  
		-------------------------------   
		IF (@debug = 1)   
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 3, 0 )   
		ELSE  
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 

		SELECT 15, 3, SUM(ai.dbo.trip_hotel.total) 
		FROM @DKTable ND 
		inner JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK = ND.dk
		INNER JOIN ai.dbo.trip_hotel ON AI.DBO.tickets_banked.pnr =AI.DBO.trip_hotel.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip_hotel.dk
	Left join ai.dbo.trip_tickets TT WITH (NOLOCK) ON AI.DBO.tickets_banked.TicketNumber = TT.Ticket and oosdt is not null	
		WHERE 
		AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate 
		AND isnull(tt.isLTR, 0 )  = 0		
		and IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
	--	AND haveHotel=1  

		 
		 --SELECT 15, 3, SUM(Amount) 
		 --FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		 --Where TransactionType = 'Added' 
		 --and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		 --and AddedDate BETWEEN @fromdate AND  @todate  
		 --And isLost = 0 and Type = 'Hotel'
		 --and isnull(ForeignStatus,-1) in (-1,0,1,2)
		  
		PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 22  end banked tickets'   	  
END
ELSE
BEGIN
   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		 SELECT 12 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   

		  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')  
		  And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)     
		 -------------------------------   
		 -- Exchanges - CAR - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 12 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND (VW.ExchangeInd = 'Y' and VW.VoidInd <> 'Y')  
		  And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)   
		 -------------------------------   
		 -- Exchanges - HOTEL - Always $0  
		 -------------------------------   
		 ----Commented for 16186
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
			SELECT 12 , 3 ,0  AS TotalPrice  

							
		 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 19  end ExchangeAmt'   	   
		 -------------------------------   
		 -- Refunds - AIR  
		 ------------------------------- 
		 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 20  start Refund'   	  
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 13 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND  refundInd <> 'N' 
		  And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)     
		    
		 -------------------------------   
		 -- Refunds - CAR - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 13 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND  refundInd <> 'N'   
		   And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)   
		   
		 -------------------------------   
		 -- Refunds - HOTEL - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 13 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND  refundInd <> 'N'
			And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)      
		   
		   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 20  end Refund'   	  
		 -------------------------------   
		 -- Voids - AIR  
		 -------------------------------   
		 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 21  start VoidAmt'   	  
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 14 , 1 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Air' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND   voidInd ='Y'   
			And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)   
		 -------------------------------   
		 -- Voids - CAR - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 14 , 2 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Car' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND   voidInd ='Y'   
		   And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)   
		   
		 -------------------------------   
		 -- Voids - HOTEL - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount )   
		SELECT 14 , 3 , SUM(ABS(ISNULL(VW.TtlTktAmt,0)) )  AS TotalPrice  
		  FROM  TMAN.dbo.vw_ReportCancellation_rpt_Beta VW  
		  INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		  Where vw.type= 'Hotel' and VW.IssueDate BETWEEN  @fromdate AND  @todate  
		  AND   voidInd ='Y'   
		  And  VW.RecordKey IN (SELECT DISTINCT recordkey 
								  FROM tman.dba.ta_udef a inner join #tmpRG b on a.UdefNum = b.RGNum and a.UdefData = b.RGValue)   
		   PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 21  end VoidAmt'   	  
		 -------------------------------   
		 -- Banked Tickets - AIR  
		 -------------------------------   
		 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 22  start banked tickets'   	  
		   
		IF (@debug = 1)   
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 1, 0 )   
		ELSE  
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 
		
		SELECT 15, 1, sum(AI.DBO.tickets_banked.Amount) 
		FROM  AI.DBO.new_dk WITH (NOLOCK)
		inner JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK = AI.DBO.new_dk.dk
		LEFT OUTER JOIN AI.DBO.trip WITH (NOLOCK) ON AI.DBO.tickets_banked.pnr =AI.DBO.trip.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip.dk
		Left join ai.dbo.trip_tickets TT WITH (NOLOCK) ON AI.DBO.tickets_banked.TicketNumber = TT.Ticket and oosdt is not null
		INNER JOIN @DKTable ND ON  AI.DBO.tickets_banked.DK  = ND.DK 		
		WHERE isnull(tt.isLTR, 0 )  = 0		
		AND IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		and AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate  
		and HaveAir = 1
		 AND AI.DBO.trip.TRIP_ID IN  (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
									INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
					)  
		
		-- SELECT 15, 1, SUM(Amount) 
		-- FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw 
		-- INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		-- Where TransactionType = 'Added' 
		-- --and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		-- and AddedDate BETWEEN @fromdate AND  @todate  
		-- And isLost = 0 and Type = 'Air'
		-- and isnull(ForeignStatus,-1) in (-1,0,1,2)
		--AND VW.TRIP_ID IN  (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
		--							INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
		--			)  
		 -------------------------------   
		 -- Banked Tickets - CAR - Always $0  
		 -------------------------------   
		 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 2, 0 )   
		   
		 -------------------------------   
		 -- Banked Tickets - HOTEL - Always $0  
		-------------------------------   
		IF (@debug = 1)   
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 3, 0 )   
		ELSE  
		INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) 

		SELECT 15, 3,  SUM(ai.dbo.trip_hotel.total) 
		FROM  AI.DBO.new_dk WITH (NOLOCK)
		LEFT OUTER JOIN AI.DBO.tickets_banked_client_rollup WITH (NOLOCK) ON 
		AI.DBO.tickets_banked_client_rollup.client_id = AI.DBO.new_dk.client_id
		LEFT OUTER JOIN AI.DBO.tickets_banked WITH (NOLOCK) ON AI.DBO.tickets_banked.DK = AI.DBO.new_dk.dk
		LEFT OUTER JOIN AI.DBO.trip WITH (NOLOCK) ON AI.DBO.tickets_banked.pnr =AI.DBO.trip.pnr AND ai.dbo.tickets_banked.dk = ai.dbo.trip.dk
		INNER JOIN ai.dbo.trip_hotel ON AI.DBO.trip.trip_id = ai.dbo.trip_hotel.trip_id
		INNER JOIN @DKTable ND ON  AI.DBO.tickets_banked.DK  = ND.DK  
		WHERE TMan.[dba].[fn_ta_get_ltr_flag](AI.DBO.tickets_banked.TicketNumber) = 0 
		and IsUsed= 0 AND comment <> 'Deleted from Log, should not display'
		and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		and AI.dbo.tickets_banked.AddedDate between @fromDate  and @toDate 
		AND haveHotel=1  

		 --SELECT 15, 3, SUM(Amount) 
		 --FROM TAOLAP.DBO.AIOLAP_Tickets_Banked vw INNER JOIN @DKTable TMP_DK ON VW.DK = TMP_DK.DK   
		 --Where TransactionType = 'Added' 
		 --and  expirydate > dateadd(dd, datediff(dd,1,getdate()),0) 
		 --and AddedDate BETWEEN @fromdate AND  @todate  
		 --And isLost = 0 and Type = 'Hotel'
		 --and isnull(ForeignStatus,-1) in (-1,0,1,2)
		 --AND VW.TRIP_ID IN  (SELECT DISTINCT TU.TRIP_ID AS UDIDTrip_ID FROM AI.DBO.Trip_UDID  TU 
			--						INNER JOIN #TMPRG B ON TU.NUM = B.RGNUM AND TU.VAL = B.RGVALUE
			--		)  
		
		   
		  
		PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 22  end banked tickets'   	  
  END
 -------------------------   
 -- Total Spend - AIR    
 -------------------------   
 PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 23  start Total Spend'   	  
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  SELECT 16, 1, ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
    else price end) else 0 end  ),0) as price FROM @TripCost 
  WHERE (travelType = 'Air')  
   
   
 -------------------------   
 -- Total Spend - CAR    
 -------------------------   
 INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) --EXEC(@sqlQry)  
  SELECT 16, 2,ISNULL(SUM(case when TripStatus <> 6 then (case when currency <> 'USD' then ai.dbo.fn_Currency_Converter_New(currency ,price,enddatetime)   
    else price end) else 0 end ),0) as price  FROM @TripCost 
  WHERE (travelType = 'Car')  
   
   
 ---------------------------   
 -- Total Spend - HOTEL    
 ---------------------------   
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
  
  
CLEANUP:   
 -------------------------------   
 -- Clean up temp tables  
 -------------------------------   
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
 IF(@isFromProgramSummary = 0 )
 Begin
	SELECT * FROM @tempRoiValues  
	ORDER BY RoiType, TravelType  
End
Else
BEgin

	SELECT case 
		when  TravelType =  1 then 'Air'
		when  TravelType = 2 then 'Car'
		when  TravelType = 3 then 'Hotel' end
		AS TYPE , sum(amount) as Amt,  case when @totalcnt > 0 then (sum(amount)  / @totalcnt ) else 0 end as AvgAmt, -1 as ForeignStatus 
	FROM @tempRoiValues where RoiType < 16
	Group by TravelType
	
	Union
	SELECT case 
		when  TravelType =  1 then 'Air'
		when  TravelType = 2 then 'Car'
		when  TravelType = 3 then 'Hotel' end
		AS TYPE , sum(amount) as Amt,  case  when @totalcnt > 0 then (sum(amount)  / @totalcnt ) else 0 end  as AvgAmt, 0  as ForeignStatus 
	FROM @tempRoiValues where RoiType < 16
	Group by TravelType
	
	Union
	SELECT case 
		when  TravelType =  1 then 'Air'
		when  TravelType = 2 then 'Car'
		when  TravelType = 3 then 'Hotel' end
		AS TYPE , sum(amount) as Amt,  case when @totalcnt > 0 then  (sum(amount)  / @totalcnt ) else 0 end as AvgAmt, 1 as ForeignStatus 
	FROM @tempRoiValues where RoiType < 16
	Group by TravelType

End	

--select 
--		Policy_Opportunities,Negotiated_Discounts,Loyalty_Awards,Payment_Rebate,Online_Adoption,Web_Fares,Waiver_Favors,Prepaid_Travel,					Audit_Searches,Agency_Discount,PreTrip_Approval,Lost_Tickets,Exchanges,Refunds,Voids,Banked_Tickets 
--	from AI..tblROIUserFilter WHERE UserKey = 561187
   
DROP TABLE #tmpRG   
PRINT CONVERT( VARCHAR(24), GETDATE(), 121) + ' - 1 end sp'   
END
GO
