SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Steve Edgerton
-- Create date: 7/16/2009
-- Description:	Get ROI data for Client
-- Modified:	12/3/2009 - SLE
--				Created table variables to speed up performance (cut time by more than 1/2)  
-- Modified:	1/6/2010 - SLE
--				Added logic to compute percent savings  
-- Modified:	2/8/2011 - SLE
--				Removed references to @clientID - onlhy used to force values for demos
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetROISummaryDataTest] 
( 
@clientID nvarchar(10), --- used for creating specific results for demos
@fromDate nvarchar(20), 
@toDate nvarchar(20), 
@dkList nvarchar(2000), 
@udidNum1 int,
@udidValue1 nvarchar(100),
@udidNum2 int,
@udidValue2 nvarchar(100)
)
AS
BEGIN

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

	DECLARE @selectClause nvarchar(500)
	DECLARE @dkClause nvarchar(500)
	DECLARE @dateClause nvarchar(1000)
	DECLARE @whereClause nvarchar(1000)
	DECLARE @udidClause nvarchar(1000)
	DECLARE @otherClause nvarchar(1000)
	DECLARE @sqlQry nvarchar(4000)
	DECLARE @rebatePct nvarchar(7)

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
	
	SET @fromDate = @fromDate + ' 00:00:01'
	SET @toDate = @toDate + ' 23:59:59' 
	
	---------------------------------
	/* CREATE AND LOAD DK TABLES */
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
print ('dk start')
	SET @position = 5
	WHILE @position < LEN(@dkList)
	BEGIN
		-- create local variable that contains list of short DKs (last 7 digits = TMAN ClientCode)
		SET @dkListShort = @dkListShort + @prefix + SUBSTRING(@dkList,@position,7) 
		SET @prefix = ''','''
		
		-- Add items to @DKTable so they can be used in "IN" clause
		-- SQL does not allow statement like WHERE DK IN ( @dkList )
		-- when executed directly in stored procedure
		-- must use : WHERE DK IN (Select DK from @DKTable)
		
		
		INSERT INTO @DKTable         
		VALUES (SUBSTRING(@dkList,@position-3,10),SUBSTRING(@dkList,@position,7))
		
	 
		-- increment to 4th character of next DK
		SET @position = @position + 13 
	END	
	SET @dkListShort = @dkListShort + ''''
	
	print ('dk end')
	-- UDID Clause is the same for all queries - NOT NEEDED PER RICK 12/1/2009
	--SET @udidClause = ''
	--IF @udidValue1 <> 'Default'
	--BEGIN
	--	SET @udidClause = ' AND UDID' + @udidNum1 + ' = ''' + @udidValue1 + ''' '
	--END 
	
	--IF @udidValue2 <> 'Default'
	--BEGIN
	--	SET @udidClause = ' AND UDID' + @udidNum2 + ' = ''' + @udidValue2 + ''' '
	--END 

	---------------------------------
	/* CREATE AND LOAD TEMP TABLES */
	---------------------------------
	-- Temp table to hold each trip - needed for waiver favors 
	CREATE TABLE #Trips         
		(        
		trip_id BIGINT,
		dk  VARCHAR(10),     -- Client DK number          
		creation_date DATETIME, 
		Booked_Online int
		PRIMARY KEY (trip_id)
		)
	
	-- Temp table to hold AIR transaction information
	CREATE TABLE #TripAir         
		(        
		trip_id BIGINT,
		DK  VARCHAR(10),     -- Client DK number          
		Book_Date DATETIME,
		Carrier VARCHAR(2),
		Booked_Online INT,
		Booked_Fare DECIMAL(18,2),
		Actual_Savings DECIMAL(18,2),
		Original_Fare DECIMAL(18,2),
		Lowest_Fare DECIMAL(18,2),
		PRIMARY KEY (trip_id)
		)
	
	-- Temp table to hold CAR transaction information
	CREATE TABLE #TripCar         
		(        
		trip_id BIGINT,
		DK  VARCHAR(10),     -- Client DK number          
		Book_Date DATETIME,
		ratePlan VARCHAR(10),
		numDays INT,
		ROI_f1 VARCHAR(3),
		originalRate DECIMAL(18,2),
		foundRate DECIMAL(18,2),
		ROI_ND DECIMAL(18,2),
		ROI_FF DECIMAL(18,2),
		ROI_LF DECIMAL(18,2)
		)

	---- Temp table to hold HOTEL transaction information
	CREATE TABLE #TripHotel         
		(        
		trip_id BIGINT,
		DK  VARCHAR(10),     -- Client DK number          
		Book_Date DATETIME,
		nights_booked INT,
		ROI_f1 VARCHAR(3),
		original_rate DECIMAL(18,2),
		rate_found DECIMAL(18,2),
		total DECIMAL(18,2),
		ROI_ND DECIMAL(18,2),
		ROI_FF DECIMAL(18,2),
		ROI_LF DECIMAL(18,2)
		)
	
	---- Temp table to hold CREDIT transaction information
	CREATE TABLE #TripCredit         
		(        
		TtlTktAmt DECIMAL(18,2),
		ExchangeInd CHAR(1),
		RefundInd CHAR(1),
		VoidInd CHAR(1)
		)
		
	---- Temp table to hold TOTAL transaction costs
	CREATE TABLE #TripCost
		(
		travelType VARCHAR(10) , 
		trip_id INT ,  
		pnr CHAR(6),  
		price DECIMAL(18,2)  ,
		noOf INT 
		 ) 
 
	---- Temp table to hold UDID54 information
	CREATE TABLE #TripUDID54         
		(        
		trip_id BIGINT,
		UDID54_Value DECIMAL(18,2)
		)
	
	---- Temp table to hold UDID55 information
	CREATE TABLE #TripUDID55         
		(        
		trip_id BIGINT,
		UDID55_Value DECIMAL(18,2)
		)
	
	---- NEW CODE TO SUPPORT WAIVERS - 11-19-2010	
	---- Temp table to hold UDID97 information
	CREATE TABLE #TripUDID97        
		(        
		trip_id BIGINT,
		UDID97_Value VARCHAR(30)
		)
		print ('trip start')
	INSERT #Trips 
		( trip_id, dk, creation_date, Booked_Online )
		SELECT trip_id, dk, creation_date, Booked_Online
		FROM  AI.dbo.trip 
		WHERE dk IN (Select DK FROM @DKTable ) 
		AND creation_date BETWEEN @fromDate AND @toDate
		
		 
	print ('trip end')
	print ('tripair start')
	INSERT #TripAir 
		( trip_id, DK, Book_Date, Carrier, Booked_Online, Booked_Fare, Actual_Savings, Original_Fare, Lowest_Fare )
		SELECT a.trip_id, a.DK, a.creation_date, a.Carrier, b.Booked_Online, ISNULL(a.Booked_Fare,0), ISNULL(a.Actual_Savings,0), ISNULL((a.Booked_Fare + a.Actual_Savings),0), ISNULL(a.Lowest_Fare,0)
		FROM  ai.dbo.trip_airfare a, #Trips  b  
		WHERE a.trip_id = b.trip_id

			 
		
	INSERT #TripCar 
		( trip_id, DK, Book_Date, ratePlan, numDays, ROI_f1, originalRate, foundRate, ROI_ND, ROI_FF, ROI_LF )
		SELECT a.trip_id, b.DK, b.creation_date,  a.ratePlan , a.numDays,  a.ROI_f1 , ISNULL(a.originalRate,0), ISNULL(a.foundRate,0), ISNULL(a.ROI_ND,0), ISNULL(a.ROI_FF,0), ISNULL(a.ROI_LF,0)
		FROM  ai.dbo.trip_car a, #Trips b 
		WHERE a.trip_id = b.trip_id
		print ('tripCar end')
	UPDATE #TripCar
		SET numDays = 1
		WHERE numDays < 1
		
 print ('triphotel start')
	INSERT #TripHotel 
		( trip_id, DK, Book_Date, nights_booked, ROI_f1, original_rate, rate_found, total, ROI_ND, ROI_FF, ROI_LF )
		SELECT a.trip_id, b.DK, b.creation_date, a.nights_booked, a.ROI_f1, ISNULL(a.original_rate,0), ISNULL(a.rate_found,0), ISNULL(a.total,0), ISNULL(a.ROI_ND,0), ISNULL(a.ROI_FF,0), ISNULL(a.ROI_LF,0)
		FROM  ai.dbo.trip_hotel a, #Trips  b  
		WHERE a.trip_id = b.trip_id
print ('triphotel end')
	-- PRE WAIVER CODE
	--INSERT #TripAir 
	--	( trip_id, DK, Book_Date, Carrier, Booked_Online, Booked_Fare, Actual_Savings, Original_Fare, Lowest_Fare )
	--	SELECT a.trip_id, a.DK, a.creation_date, a.Carrier, b.Booked_Online, ISNULL(a.Booked_Fare,0), ISNULL(a.Actual_Savings,0), ISNULL((a.Booked_Fare + a.Actual_Savings),0), ISNULL(a.Lowest_Fare,0)
	--	FROM  ai.dbo.trip_airfare a, AI.dbo.trip  b  
	--	WHERE a.trip_id = b.trip_id
	--	AND	a.dk IN (Select DK FROM @DKTable ) 
	--	AND a.creation_date BETWEEN @fromDate AND @toDate

	--INSERT #TripCar 
	--	( trip_id, DK, Book_Date, ratePlan, numDays, ROI_f1, originalRate, foundRate, ROI_ND, ROI_FF, ROI_LF )
	--	SELECT a.trip_id, b.DK, b.creation_date, a.ratePlan, a.numDays, a.ROI_f1, ISNULL(a.originalRate,0), ISNULL(a.foundRate,0), ISNULL(a.ROI_ND,0), ISNULL(a.ROI_FF,0), ISNULL(a.ROI_LF,0)
	--	FROM  ai.dbo.trip_car a, AI.dbo.trip  b  
	--	WHERE a.trip_id = b.trip_id
	--	AND	b.dk IN (Select DK FROM @DKTable ) 
	--	AND b.creation_date BETWEEN @fromDate AND @toDate
	
	--UPDATE #TripCar
	--	SET numDays = 1
	--	WHERE numDays < 1

	-- PRE WAIVER CODE
	--INSERT #TripHotel 
	--	( trip_id, DK, Book_Date, nights_booked, ROI_f1, original_rate, rate_found, total, ROI_ND, ROI_FF, ROI_LF )
	--	SELECT a.trip_id, b.DK, b.creation_date, a.nights_booked, a.ROI_f1, ISNULL(a.original_rate,0), ISNULL(a.rate_found,0), ISNULL(a.total,0), ISNULL(a.ROI_ND,0), ISNULL(a.ROI_FF,0), ISNULL(a.ROI_LF,0)
	--	FROM  ai.dbo.trip_hotel a, AI.dbo.trip  b  
	--	WHERE a.trip_id = b.trip_id
	--	AND	b.dk IN (Select DK FROM @DKTable ) 
	--	AND b.creation_date BETWEEN @fromDate AND @toDate

print ( 'tripcredit start')
	INSERT #TripCredit 
		( TtlTktAmt, ExchangeInd, RefundInd, VoidInd )
		SELECT TtlTktAmt, ExchangeInd, RefundInd, VoidInd
		FROM  [tman].[dbo].[vw_TA_Ticket]  
		WHERE ClientCode IN (Select DK FROM @DKTable ) 
		AND IssueDate BETWEEN @fromDate AND @toDate
print ( 'tripcredit end ')
print ( 'tripCost start')
	INSERT #TripCost
		( travelType, trip_id, pnr, price, noOf )
		SELECT type, trip_id, pnr, Price, noOf
		FROM  [ai].[dbo].[vw_ReportTransaction]  
		WHERE dk IN (Select DK FROM @DKTable ) 
		AND creation_date BETWEEN @fromDate AND @toDate
print ( 'tripcost end')

print ( 'tripudid54 start' )
	INSERT #TripUDID54 
		( trip_id, UDID54_Value )
		SELECT b.trip_id, MIN(CAST(REPLACE(b.val, ',','') AS float))
		FROM  #TripAir a, AI.dbo.Trip_UDID b
		WHERE (a.trip_id = b.trip_id)
		AND (b.num = 54)
		group by b.trip_id
	print ( 'tripudid54 end ' )
	
	print ( 'tripudid55 start' )
	 
		
	INSERT #TripUDID55 
		( trip_id, UDID55_Value )
		SELECT b.trip_id, MAX(CAST(REPLACE(rtrim(ltrim(b.val)), ',','') AS float))
		FROM  #TripAir a, AI.dbo.Trip_UDID b
		WHERE (a.trip_id = b.trip_id)
		AND (b.num = 55) 
		group by b.trip_id
print ( 'tripudid55 end' )
print ( 'tripudid97 start' )
	INSERT #TripUDID97 
		( trip_id, UDID97_Value )
		SELECT a.trip_id, b.val
		FROM  #Trips a, AI.dbo.Trip_UDID b
		WHERE (a.trip_id = b.trip_id)
		AND (b.num = 97) 
		
		print ( 'tripudid97 start' )

---------------------------------
/*   POLICY SAVINGS SECTION    */
---------------------------------
	
	-------------------------	
	-- Policy Savings - AIR Lost Opportunity *** (booked + actual = original fare) - lowest_fare (LF) is savings not taken at point of sale
	-------------------------	
	SET @selectClause = 'SELECT 0, 1, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(Original_Fare - lowest_fare),0) FROM #TripAir ' 
	SET @whereClause = ' WHERE (Original_Fare > lowest_fare) AND (lowest_fare > 0)'
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------	
	-- Policy Savings - CAR Lost Opportunity *** ((OriginalRate - ROI_LF) * NumOfDays) *** 
	-------------------------	
	SET @selectClause = 'SELECT 0, 2, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(((originalRate - ROI_LF) / CASE 
					WHEN (ratePlan = ''WY'') THEN 5 
					WHEN (ratePlan = ''WK'') THEN 5 
					WHEN (ratePlan = ''DY'') THEN 1 
					WHEN (ratePlan = ''WD'') THEN 2 
					WHEN (ratePlan = ''MY'') THEN 30 
					ELSE 1 
				   END) * numDays ),0)
				FROM #TripCar ' 
	SET @whereClause = ' WHERE (ROI_LF is not null) AND (originalRate > ROI_LF) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0, 2, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	---------------------------	
	-- Policy Savings - HOTEL Lost Opportunity *** ((original_rate - ROI_LF) * nights_booked) *** 
	---------------------------	
	SET @selectClause = 'SELECT 0, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM((original_rate - ROI_LF) * nights_booked ),0) FROM #TripHotel  ' 
	SET @whereClause = ' WHERE  (ROI_LF is not null) AND (original_rate > ROI_LF) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 0,3, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- Negotiated Contracts - AIR Savings Due to Client Contract
	-- *** (UDID91 - ( booked_fare + actual_savings )) = ( FF - original ) ***
	--      UD91 = WP value, without use of client contract, entered by file finishing script
	-------------------------------	
	SET @selectClause = 'SELECT 1, 1, '
	SET @selectClause = @selectClause + ' ISNULL(SUM(CAST(replace(b.val, '','','''') AS float) - Original_Fare),0) '
	SET @selectClause = @selectClause + ' FROM #TripAir a, [AI].[dbo].[trip_UDID] b ' 
	SET @whereClause = ' WHERE (a.trip_id = b.trip_id) AND (b.num = 91) AND (Original_Fare < CAST(replace(b.val, '','','''') AS float)) '
	--SET @selectClause = 'SELECT 1, 1, '
	--SET @selectClause = @selectClause + ' ISNULL(SUM(((ROI_ND - originalRate)* 2.13 / CASE 
	--				WHEN (ratePlan = ''WY'') THEN 5 
	--				WHEN (ratePlan = ''WK'') THEN 5 
	--				WHEN (ratePlan = ''DY'') THEN 1 
	--				WHEN (ratePlan = ''WD'') THEN 2 
	--				WHEN (ratePlan = ''MY'') THEN 30 
	--				ELSE 1 
	--			   END) * numDays ),0)
	--			FROM #TripCar ' 
	--SET @whereClause = ' WHERE (ROI_ND is not null) AND (ROI_f1 =''NEG'') '

	SET @sqlQry = @selectClause + @whereClause
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- Negotiated Contracts - CAR Savings Due to Client Contract
	-- *** ((ROI_ND - originalRate) * num_days) *** ROI_f1 = 'NEG'
	-------------------------------	
	SET @selectClause = 'SELECT 1, 2, '
	SET @selectClause = @selectClause + ' ISNULL(SUM(((ROI_ND - originalRate) / CASE 
					WHEN (ratePlan = ''WY'') THEN 5 
					WHEN (ratePlan = ''WK'') THEN 5 
					WHEN (ratePlan = ''DY'') THEN 1 
					WHEN (ratePlan = ''WD'') THEN 2 
					WHEN (ratePlan = ''MY'') THEN 30 
					ELSE 1 
				   END) * numDays ),0)
				FROM #TripCar ' 
	SET @whereClause = ' WHERE (ROI_ND is not null) AND (ROI_f1 =''NEG'') '
	
	SET @sqlQry = @selectClause + @whereClause
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	---------------------------------	
	-- Negotiated Contracts - HOTEL Savings Due to Client Contract
	-- *** ((ROI_ND - original_rate) * nights_booked) *** ROI_f1 = 'NEG'
	---------------------------------	
	SET @selectClause = 'SELECT 1, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM((ROI_ND - original_rate) * nights_booked ),0) FROM #TripHotel  ' 
	SET @whereClause = ' WHERE  (ROI_ND is not null) AND (ROI_f1 =''NEG'') '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 1, 3, 3 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- Loyalty Awards - AIR  (2.5% or air volume for client's airline programs (Use carriers in PQ table))
	-------------------------------	
	SET @selectClause = 'SELECT 2, 1, '
	SET @selectClause = @selectClause + ' ISNULL((SUM(booked_fare) * 0.025),0)  ' 
	SET @selectClause = @selectClause + ' FROM #TripAir ' 
	SET @whereClause = ' WHERE carrier IN (SELECT carrierCode FROM [AI].[dbo].[pq_lines] WHERE DK IN (' + @dkList + '))'
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 2, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- Loyalty Awards - CAR (WILL ALWAYS SHOW AS $0)
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 2, 2, 0 ) 
	
	
	-------------------------------	
	-- Loyalty Awards - HOTEL (WILL ALWAYS SHOW AS $0)
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 2, 3, 0 ) 
	
	
	-------------------------------	
	-- Determine Payment Rebate % for this Client
	-------------------------------	
	SET @rebatePct = '0.00000'
	SELECT @rebatePct=ISNULL(MAX(RebatePercent),0) from [AI].[dbo].[PaymentRebate]
	WHERE DK IN ( Select DK from @DKTable ) AND RebateActive = 'True'
	
	-------------------------------	
	-- Payment Rebate - AIR ( x% rebate on total air spend )
	-------------------------------	
	SET @selectClause = 'SELECT 3, 1, '
	SET @selectClause = @selectClause + 'ISNULL((SUM(booked_fare) * ' + @rebatePct + '),0) FROM #TripAir ' 
	
	SET @sqlQry = @selectClause 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
	
	-------------------------------	
	-- Payment Rebate - CAR  ( x% rebate on total car spend )
	-------------------------------	
	SET @selectClause = 'SELECT 3, 2, '
	SET @selectClause = @selectClause + '	SUM(((originalRate / CASE 
					WHEN (ratePlan = ''WY'') THEN 5 
					WHEN (ratePlan = ''WK'') THEN 5 
					WHEN (ratePlan = ''DY'') THEN 1 
					WHEN (ratePlan = ''WD'') THEN 2 
					WHEN (ratePlan = ''MY'') THEN 30 
					ELSE 1 
				   END) * numDays ) * ' + @rebatePct + ' ) 
				FROM #TripCar ' 
	SET @whereClause = ' WHERE (numDays > 0)'
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 3, 2, 5 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- Payment Rebate - HOTEL ( x% rebate on total hotel spend )
	-------------------------------	
	SET @selectClause = 'SELECT 3, 3, '
	SET @selectClause = @selectClause + '(SUM(total) * ' + @rebatePct + ') FROM #TripHotel ' 
	
	SET @sqlQry = @selectClause 
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 3, 3, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)




---------------------------------
/*    RESERVATIONS SECTION	   */
---------------------------------
	-------------------------------	
	-- Online Adoption - AIR  Calculate the difference between the 
	-- Agent Fee (DOM) adn the Online Fee (ONL) 
	-------------------------------	
	DECLARE @onlineSavings float = 0
	DECLARE @maxDOM float = 0
	DECLARE @maxONL float = 0
	
	SELECT @maxDOM = MAX(fee_amount)
    FROM [ai].[dbo].[fee] 
    WHERE (fee_name = 'DOM')
	and	dk IN (Select DK FROM @DKTable )
	
	SELECT @maxONL = MAX(fee_amount)
    FROM [ai].[dbo].[fee] 
    WHERE (fee_name = 'ONL')
	and	dk IN (Select DK FROM @DKTable )

	SET @onlineSavings = @maxDOM - @maxONL
	IF @onlineSavings < 0 
	BEGIN
		SET @onlineSavings = 0
	END

	-------------------------------	
	-- Online Adoption - AIR  
	-- Online fee savings (see above) times the number of online air transactions )
	-------------------------------	
	SET @selectClause = 'SELECT 4, 1, '
	SET @selectClause = @selectClause + '(COUNT(*) * ' + CAST(@onlineSavings as nvarchar(7)) + ') FROM #TripAir ' 
	SET @whereClause = ' WHERE (Booked_Online = 1) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
		
	
	-------------------------------	
	-- Online Adoption - CAR (always $0)
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 2, 0 ) 
	
	
	-------------------------------	
	-- Online Adoption - HOTEL (always $0)
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 4, 3, 0 ) 

	
	-------------------------------	
	-- Web Fares - AIR Savings from use of Web Fare 
	--  (UDID94 Contains the SABRE fare entered by file finish script)
	-------------------------------	
	SET @selectClause = 'SELECT 5, 1, '
	SET @selectClause = @selectClause + ' ISNULL(SUM(CAST(replace(b.val, '','','''') AS float) - Original_Fare),0)  ' 
	SET @selectClause = @selectClause + ' FROM #TripAir a, [AI].[dbo].[trip_UDID] b ' 
	SET @whereClause = ' WHERE (a.trip_id = b.trip_id) AND (b.num = 94) '
	SET @whereClause = @whereClause + ' AND (Original_Fare < CAST(replace(b.val, '','','''') AS float)) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 5, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry) 
			
	-------------------------------	
	-- Web Fares - CAR Savings from use of Web Rate
	-- ROI_FF = lowest non-discounted rate for same car *** ROI_f1 = 'WEB' 
	-------------------------------	
	SET @selectClause = 'SELECT 5, 2, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(((ROI_FF - originalRate)  / CASE 
					WHEN (ratePlan = ''WY'') THEN 5 
					WHEN (ratePlan = ''WK'') THEN 5 
					WHEN (ratePlan = ''DY'') THEN 1 
					WHEN (ratePlan = ''WD'') THEN 2 
					WHEN (ratePlan = ''MY'') THEN 30 
					ELSE 1 
				   END) * numDays ),0) 
				   FROM #TripCar ' 
	SET @whereClause = ' WHERE (ROI_FF > originalRate) AND (ROI_f1 =''WEB'') '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 5, 2, 6 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry) 
	
	-------------------------------	
	-- Web Fares - HOTEL Savings from use of Web Rate
	-- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'WEB' 
	-------------------------------	
	SET @selectClause = 'SELECT 5, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM((ROI_FF - original_rate) * nights_booked ),0) FROM #TripHotel ' 
	SET @whereClause = ' WHERE (ROI_FF > original_rate) AND (ROI_f1 =''WEB'') '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 5, 3, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
		
	-------------------------------	
	-- Restriction Waivers - AIR UD97 with A100.00, C100.00, or H100.00
	-- Loop through each of the UD97 records and parse out values for A,C,H
	-------------------------------	
	DECLARE @numStart int = 1
	DECLARE @numEnd int 
	DECLARE @numLength int 
	DECLARE @curType char(1)
	DECLARE @curValue float = 0
	DECLARE @airTotal float = 0
	DECLARE @hotelTotal float = 0 
	DECLARE @carTotal float = 0 
	DECLARE @udidStr nvarchar(100)
		
	DECLARE @MyCursor CURSOR 

	SET @MyCursor = CURSOR FAST_FORWARD 
	FOR 
		SELECT UDID97_Value
		FROM #TripUDID97
		
	OPEN @MyCursor 
	FETCH NEXT FROM @MyCursor 
	INTO @udidStr
		 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		SET @numStart = PATINDEX('%[A,C,H]%',@udidStr) 
	
		WHILE (@numStart > 0)
		BEGIN
			SET @numEnd = CHARINDEX('.',@udidStr,@numStart) + 2
			SET @numLength = @numEnd - @numStart
			SET @curType = SUBSTRING(@udidStr,@numStart,1)
			SET @curValue = CAST(SUBSTRING(@udidStr,@numStart+1,@numLength) as float)
			
			IF (@curType = 'A')
			BEGIN
				SET @airTotal = @airTotal + @curValue
			END
			IF (@curType = 'H')
			BEGIN
				SET @hotelTotal = @hotelTotal + @curValue
			END
			IF (@curType = 'C')
			BEGIN
				SET @carTotal = @carTotal + @curValue
			END

			SET @udidStr = SUBSTRING(@udidStr,@numEnd+1,LEN(@udidStr)-@numEnd)
			SET @numStart = PATINDEX('%[A,C,H]%',@udidStr)

		END

		FETCH NEXT FROM @MyCursor 
		INTO @udidStr
		
	END 

	--SELECT @airTotal, @carTotal, @hotelTotal

	CLOSE @MyCursor 
	DEALLOCATE @MyCursor 
	
	-- SET @sqlQry = @selectClause + @whereClause
	-- IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 6, 1, @airTotal ) 
	-- ELSE
	-- INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
	-------------------------------	
	-- Restriction Waivers - CAR  UD97 with A100, C100, or H100
	-- TODO - Determine how to get this data out
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 6, 2, @carTotal ) 
	
	-------------------------------	
	-- Restriction Waivers - HOTEL  UD97 with A100, C100, or H100
	-- TODO - Determine how to get this data out
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 6, 3, @hotelTotal ) 
	
	
	-------------------------------	
	-- Prepaid - AIR - Savings from use of Prepaid Air  *** (UDID87 - Original_Fare) *** 		
	-- UDID87 contains SABRE fare for prepaid flight
	-- TODO - do not see any data in UD87
	-------------------------------	
	SET @selectClause = 'SELECT 7, 1, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(CAST(replace(b.val, '','','''') AS float) - Original_Fare),0)  ' 
	SET @selectClause = @selectClause + ' FROM #TripAir a, [AI].[dbo].[trip_UDID] b ' 
	SET @whereClause = ' WHERE (a.trip_id = b.trip_id) AND (b.num = 87) '
	SET @whereClause = @whereClause + ' AND (Original_Fare < CAST(replace(b.val, '','','''') AS float)) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 7, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
		
	-------------------------------	
	-- Prepaid - CAR - Savings from use of Prepaid Car  *** ((ROI_FF - originalRate) * numDays) *** 		
	-- ROI_f1 = 'PRE' 
	-- TODO - no data found yet
	-------------------------------	
	SET @selectClause = 'SELECT 7, 2, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(((ROI_FF - originalRate)  / CASE 
					WHEN (ratePlan = ''WY'') THEN 5 
					WHEN (ratePlan = ''WK'') THEN 5 
					WHEN (ratePlan = ''DY'') THEN 1 
					WHEN (ratePlan = ''WD'') THEN 2 
					WHEN (ratePlan = ''MY'') THEN 30 
					ELSE 1 
				   END) * numDays ),0) 
				   FROM #TripCar ' 
	SET @whereClause = ' WHERE (ROI_f1 =''PRE'') AND (ROI_FF > originalRate) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 7, 2, 7 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry) 
	
	
	-------------------------------	
	-- Prepaid - HOTEL
	-- ROI_FF = lowest non-discounted rate for same hotel room *** ROI_f1 = 'PRE' 
	-------------------------------	
	SET @selectClause = 'SELECT 7, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM((ROI_FF - original_rate) * nights_booked ),0) FROM #TripHotel ' 
	SET @whereClause = ' WHERE (ROI_FF > original_rate) AND (original_rate > 0) AND (ROI_f1 =''PRE'') '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 7, 3, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	

---------------------------------
/*       SAVINGS SECTION	   */
---------------------------------
	
	-------------------------------	
	-- Audit Searches - AIR - Savings found AND TAKEN from nightly robot searches   
	-- *** Actual_savings (found by robot)
	-------------------------------	
	SET @selectClause = 'SELECT 8, 1, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(actual_savings),0) FROM #TripAir ' 
	
	SET @sqlQry = @selectClause 
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 8, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
			
	-------------------------------	
	-- Audit Searches - CAR - Savings found from nightly robot searches   
	-- *** originalRate - foundRate (robot) * days
	-------------------------------	
	SET @selectClause = 'SELECT 8, 2, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(((originalRate - foundRate) / CASE 
					WHEN (ratePlan = ''WY'') THEN 5 
					WHEN (ratePlan = ''WK'') THEN 5 
					WHEN (ratePlan = ''DY'') THEN 1 
					WHEN (ratePlan = ''WD'') THEN 2 
					WHEN (ratePlan = ''MY'') THEN 30 
					ELSE 1 
				   END) * numDays ),0)
				FROM #TripCar ' 
	SET @whereClause = ' WHERE (foundRate > 0) AND (originalRate > foundRate) '
	
	SET @sqlQry = @selectClause + @whereClause
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
 
	
	-------------------------------	
	-- Audit Searches - HOTEL - Savings found from nightly robot searches   
	-- *** original_rate - rate_found (robot) * nights_booked
	-------------------------------	
	SET @selectClause = 'SELECT 8, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM((original_rate - rate_found) * nights_booked ),0) FROM #TripHotel  ' 
	SET @whereClause = ' WHERE (rate_found > 0) AND (original_rate > rate_found) '
	
	SET @sqlQry = @selectClause + @whereClause
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)	
	
	-------------------------------	
	-- Agency Discounts - AIR - Savings from using Consolidators, consortia, agency contracts
	-- UDID55 (lowest published fare for flight) - UDID54 (consolidator fare)
	-- TODO - Rowdy & John to switch from storing air data in UD54,55,87.91,94 to REMARKS like hotel and car
	-------------------------------	
	SET @selectClause = 'SELECT 9, 1, '
	SET @selectClause = @selectClause + ' ISNULL(SUM(UDID55_Value - UDID54_Value),0) ' 
	SET @selectClause = @selectClause + ' FROM #TripUDID54 a, #TripUDID55 b ' 
	SET @whereClause = ' WHERE (a.trip_id = b.trip_id) ' 
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 9, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	-------------------------------	
	-- Agency Discounts - CAR - Savings from using Consolidators, consortia, agency contracts
	-- ROI_FF = lowest non-discounted rate for same car *** ROI_f1 = 'TFO' 
	-------------------------------	
	SET @selectClause = 'SELECT 9, 2, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(((ROI_FF - originalRate)  / CASE 
					WHEN (ratePlan = ''WY'') THEN 5 
					WHEN (ratePlan = ''WK'') THEN 5 
					WHEN (ratePlan = ''DY'') THEN 1 
					WHEN (ratePlan = ''WD'') THEN 2 
					WHEN (ratePlan = ''MY'') THEN 30 
					ELSE 1 
				   END) * numDays ),0) 
				   FROM #TripCar ' 
	SET @whereClause = ' WHERE (ROI_FF > originalRate) AND (ROI_f1 =''TFO'') '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 9, 2, 9 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry) 
	
	-------------------------------	
	-- Agency Discounts - HOTEL Savings from using Consolidators, consortia, agency contracts
	-- ROI_FF = lowest non-discounted rate for same hotel *** ROI_f1 = 'TFO' 
	-------------------------------	
	SET @selectClause = 'SELECT 9, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM((ROI_FF - original_rate) * nights_booked ),0) FROM #TripHotel ' 
	SET @whereClause = ' WHERE (ROI_FF > original_rate) AND (ROI_f1 =''TFO'') '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 9, 3, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- PreTrip - AIR - Value of Denied air segments 
	-- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0
	-- TODO - John to add total air, total car, and total hotel cost to the pretrip table
	-------------------------------	
	SET @selectClause = 'SELECT 10, 1, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(booked_fare),0) FROM [AI].[dbo].[vw_pretrip_air] ' 
	SET @whereClause = ' WHERE  dk IN (' + @dkList + ') '
	SET @whereClause = @whereClause + ' AND ApprovedDT BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' ' 
	SET @whereClause = @whereClause + ' AND (IsTripApproved = 0) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 10, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry) 
	
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
				FROM [AI].[dbo].[vw_pretrip_car] ' 
	SET @whereClause = ' WHERE  dk IN (' + @dkList + ') '
	SET @whereClause = @whereClause + ' AND ApprovedDT BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' ' 
	SET @whereClause = @whereClause + ' AND (IsTripApproved = 0) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 10, 2, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry) 
	
	-------------------------------	
	-- PreTrip - HOTEL - Value of Denied hotel segments
	-- *** if approvedDT > 01-01-2000 (it has been acted upon) and isTripApproved = 0
	-- TODO - John to add total air, total car, and total hotel cost to the pretrip table
	-------------------------------	
	SET @selectClause = 'SELECT 10, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(total),0) FROM [AI].[dbo].[vw_pretrip_hotel] ' 
	SET @whereClause = ' WHERE  dk IN (' + @dkList + ') '
	SET @whereClause = @whereClause + ' AND ApprovedDT BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' ' 
	SET @whereClause = @whereClause + ' AND (IsTripApproved = 0) '
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 10, 3, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry) 
	
	
	-------------------------------	
	-- LostTickets - AIR
	-------------------------------	
	DECLARE @LTRAmount float
	
	SELECT @LTRAmount = ISNULL(SUM(booked_fare),0) FROM [AI].[dbo].[vw_trip_ltr] A,  
	[AI].[dbo].[new_dk] B
	WHERE A.dk_id = B.dk_id
	AND DK IN (Select DK FROM @DKTable ) 
	AND issue_date BETWEEN @fromDate AND @toDate
	AND LTR = 1
	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 1, @LTRAmount )
	
	-------------------------------	
	-- LostTickets - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 2, 0 ) 
	
	-------------------------------	
	-- LostTickets - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 11, 3, 0 ) 
	



---------------------------------
/*   CREDITS SAVINGS SECTION   */
---------------------------------
	
	-------------------------------	
	-- Exchanges - AIR - Value of exchanges - LTR values above
	-------------------------------	
	SET @selectClause = 'SELECT 12, 1, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(TtlTktAmt),0) FROM #TripCredit ' 
	SET @whereClause = ' WHERE ExchangeInd=''Y'''
	
	SET @sqlQry = @selectClause + @whereClause
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
	-------------------------------	
	-- Exchanges - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 12, 2, 0 ) 
	
	-------------------------------	
	-- Exchanges - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 12, 3, 0 ) 
	
	
	-------------------------------	
	-- Refunds - AIR
	-------------------------------	
	SET @selectClause = 'SELECT 13, 1, '
	SET @selectClause = @selectClause + 'ISNULL((SUM(TtlTktAmt) * -1),0) FROM #TripCredit ' 
	SET @whereClause = ' WHERE RefundInd=''Y'''
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 13, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
	-------------------------------	
	-- Refunds - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 13, 2, 0 ) 
	
	-------------------------------	
	-- Refunds - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 13, 3, 0 ) 
	
	
	-------------------------------	
	-- Voids - AIR
	-------------------------------	
	SET @selectClause = 'SELECT 14, 1, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(TtlTktAmt),0) FROM #TripCredit ' 
	SET @whereClause = ' WHERE VoidInd=''Y'''
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 14, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
	-------------------------------	
	-- Voids - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 14, 2, 0 ) 
	
	-------------------------------	
	-- Voids - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 14, 3, 0 ) 
	
	
	-------------------------------	
	-- Banked Tickets - AIR
	-------------------------------	
	SET @selectClause = 'SELECT 15, 1, '
	SET @selectClause = @selectClause + 'SUM(Amount) FROM [AI].[dbo].[tickets_banked] ' 
	SET @dkClause = ' WHERE ( DK IN (' + @dkList + ') ) '
	SET @dateClause = ' AND ( AddedDate BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + ''' ) ' 
	SET @otherClause = ' AND ( IsLost = 0 ) AND ( IsUsed = 0 ) '
	
	SET @sqlQry = @selectClause + @dkClause + @dateClause + @otherClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 1, 0 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
		
	-------------------------------	
	-- Banked Tickets - CAR - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 2, 0 ) 
	
	-------------------------------	
	-- Banked Tickets - HOTEL - Always $0
	-------------------------------	
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 15, 3, 0 ) 
	
	

  
	-------------------------	
	-- Total Spend - AIR  
	-------------------------	
	SET @selectClause = 'SELECT 16, 1, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(price),0) FROM #TripCost ' 
	SET @whereClause = ' WHERE (travelType = ''Air'')'
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 16, 1, 1 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------	
	-- Total Spend - CAR  
	-------------------------	
	SET @selectClause = 'SELECT 16, 2, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(price),0) FROM #TripCost ' 
	SET @whereClause = ' WHERE (travelType = ''Car'')'
		
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 16, 2, 4 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	---------------------------	
	-- Total Spend - HOTEL  
	---------------------------	
	SET @selectClause = 'SELECT 16, 3, '
	SET @selectClause = @selectClause + 'ISNULL(SUM(price),0) FROM #TripCost ' 
	SET @whereClause = ' WHERE (travelType = ''Hotel'')'
	
	SET @sqlQry = @selectClause + @whereClause
	IF (@debug = 1) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 16, 3, 3 ) 
	ELSE
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) EXEC(@sqlQry)
	
	
	-------------------------------	
	-- Total Transaction Count
	-- Need to add this single value into construct used for all ROI values being passed back
	-- Will add a 17th row with air=0 car=0 and hotel=total transactions
	-- Main application will identify value of hotel in 17th row as total transactions
	-------------------------------	
	DECLARE @totaltrx as float
	
	SELECT @totaltrx = COUNT(*) FROM [AI].[dbo].[trip]  
	WHERE DK IN (Select DK FROM @DKTable ) 
	AND issue_date BETWEEN @fromDate AND @toDate
		
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 17, 1, 0 ) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 17, 2, 0 ) 
	INSERT INTO @tempRoiValues ( RoiType, TravelType, Amount ) VALUES ( 17, 3, @totaltrx ) 
	
	-------------------------------	
	-- Clean up temp tables
	-------------------------------	
	drop table #TripAir
	drop table #TripCar
	drop table #TripHotel
	drop table #TripCredit
	drop table #TripCost
	drop table #TripUDID54 
	drop table #TripUDID55 

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
	
	--select * from #TripCar
	--where ROI_f1 = 'NEG'
	--drop table #TripCar
	
END
GO
