SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[SavePurchaseTrip_TripAirLegs_Insert] 
	-- Add the parameters for the stored procedure here
	@xmldata XML, @airResponseKey uniqueidentifier, @TripPassenger SavePurchaseTrip_TripPassenger Readonly
AS
BEGIN
	declare @tmp table (ARow int, gdsSourceKey int, selectedBrand nvarchar(50), recordLocator nvarchar(50), airLegNumber int, validatingCarrier nvarchar(10),
						contractCode nvarchar(50), isRefundable bit, TicketDesignator nvarchar(10), PassengerKey int, ticketNumber nvarchar(50), InvoiceNumber nvarchar(20), airSegmentKey uniqueidentifier, BucketCategory int)
	
	INSERT @tmp (ARow, gdsSourceKey, selectedBrand, recordLocator, airLegNumber, validatingCarrier, contractCode, isRefundable, TicketDesignator,
					PassengerKey, ticketNumber, InvoiceNumber, airSegmentKey, BucketCategory)
	SELECT W.N, X.C1.value('TripAirLeg[1]/gdsSourceKey[1]','int'), X.C1.value('TripAirLeg[1]/selectedBrand[1]','varchar(50)'), 
				X.C1.value('TripAirLeg[1]/recordLocator[1]','varchar(50)'), X.C1.value('TripAirLeg[1]/airLegNumber[1]','int'), 
				X.C1.value('TripAirLeg[1]/validatingCarrier[1]','varchar(10)'), X.C1.value('TripAirLeg[1]/contractCode[1]','varchar(50)'), 
				X.C1.value('TripAirLeg[1]/isRefundable[1]','bit'), X.C1.value('TripAirLeg[1]/TicketDesignator[1]','varchar(10)'),
				Y.C2.value('TripAirLegPassengerInfo[1]/PassengerKey[1]','int'), Y.C2.value('TripAirLegPassengerInfo[1]/ticketNumber[1]','varchar(50)'), 
				Y.C2.value('TripAirLegPassengerInfo[1]/InvoiceNumber[1]','varchar(20)'), Z.C3.value('TripAirSegment[1]/airSegmentKey[1]', 'varchar(50)'),
				 X.C1.value('TripAirLeg[1]/BucketCategory[1]','int')
	FROM (
		SELECT T.C.query('.') C, row_number() over (order by C) N
		FROM @xmldata.nodes('//TripAirSegments') T(C)) W
	OUTER APPLY (
		SELECT T1.C1.query('.') C1--, row_number() over (order by C) N
		FROM W.C.nodes('/TripAirSegments[1]/TripAirLeg') T1(C1)) X
	OUTER APPLY (
		SELECT T2.C2.query('.') C2
		FROM W.C.nodes('TripAirSegments[1]/TripAirLeg/TripAirLegPassengerInfos/TripAirLegPassengerInfo') T2(C2)) Y
	OUTER APPLY (
		SELECT T3.C3.query('.') C3
		FROM W.C.nodes('TripAirSegments[1]/TripAirSegment') T3(C3)) Z	
	
	DECLARE @output SavePurchaseTrip_TripAirLegSegment 
	DECLARE @tempTripAirLegs TABLE (gdsSourceKey int, selectedBrand nvarchar(50), recordLocator nvarchar(50), airLegNumber int, validatingCarrier nvarchar(10),
						contractCode nvarchar(50), isRefundable bit, TicketDesignator nvarchar(10), airSegmentKey uniqueidentifier,Row_Num int,BucketCategory int)
	
	INSERT INTO  @tempTripAirLegs (gdsSourceKey, selectedBrand, recordLocator, airLegNumber, validatingCarrier, contractCode, isRefundable, TicketDesignator, airSegmentKey,BucketCategory,Row_Num)
	select gdsSourceKey, selectedBrand, recordLocator, airLegNumber, validatingCarrier, contractCode, isRefundable, TicketDesignator, airSegmentKey,BucketCategory,row_number() over(partition by airlegnumber order by airlegnumber)
		from (select distinct ARow, gdsSourceKey, selectedBrand, recordLocator, airLegNumber, validatingCarrier, contractCode, isRefundable, TicketDesignator, airSegmentKey,BucketCategory from @tmp) X
				order by ARow -- order by is important to maintain correlation

	Declare  @output1 table(tripAirLegsKey int,airLegNumber int) 
	
	MERGE INTO TripAirLegs USING @tempTripAirLegs AS temp ON 1 = 0 
	WHEN NOT MATCHED and temp.row_num=1 THEN
	Insert (airResponseKey, gdsSourceKey, selectedBrand, recordLocator, airLegNumber, validatingCarrier, contractCode, isRefundable, TicketDesignator,BucketCategory)
	VALUES ( @airResponseKey, temp.gdsSourceKey, temp.selectedBrand, temp.recordLocator, temp.airLegNumber, temp.validatingCarrier, temp.contractCode, temp.isRefundable, temp.TicketDesignator,temp.BucketCategory)
	 OUTPUT inserted.tripAirLegsKey, temp.airLegNumber INTO @output1;
	
	-- get the last identity generated to correlate tripAirPriceKey in tripAirResponseTax
	declare @lastid int
	SET @lastid = scope_identity()

	INSERT INTO @output(airLegNumber,airSegmentKey)
	SELECT airLegNumber,airSegmentKey FROM @tmp
	order by airLegNumber

	UPDATE t
	SET T.tripAirLegKey=t1.tripAirLegsKey
	FROM
	@output t
	INNER JOIN @output1 t1 On t.airLegNumber=t1.airLegNumber
	
	-- Max(ARow) is how many A records were entered, add back ARow to get
	-- the ID generated for the A record
	insert TripAirLegPassengerInfo (tripAirLegKey, tripPassengerInfoKey, ticketNumber, InvoiceNumber)
	Select distinct X.tripAirLegKey, P.TripPassengerInfoKey, X.ticketNumber, X.InvoiceNumber 
	from(select ARow, @lastid-M.M+ARow as tripAirLegKey, PassengerKey, ticketNumber, InvoiceNumber
			from @tmp, (select max(ARow) M from @tmp) M
			where PassengerKey is not null
			--order by ARow
		) X left outer join @TripPassenger P on X.PassengerKey = P.PassengerKey --order by X.ARow
	
	Exec [dbo].[SavePurchaseTrip_TripAirSegments_Insert] @xmldata, @airResponseKey, @output, @TripPassenger
	
END
GO
