SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <10th Aug 17>
-- Description:	<To Insert into TripAirPrices Table>
--<TripAirPrices>
--	<TripAirPrice>
--		<tripCategory>Actual</tripCategory>
--		<tripAdultBase>192.32</tripAdultBase><tripAdultTax>28.62</tripAdultTax>
--		<tripSeniorBase>182.32</tripSeniorBase><tripSeniorTax>27.62</tripSeniorTax>
--		<tripYouthBase>172.32</tripYouthBase><tripYouthTax>26.62</tripYouthTax>
--		<tripChildBase>162.32</tripChildBase><tripChildTax>25.62</tripChildTax>
--		<tripInfantBase>152.32</tripInfantBase><tripInfantTax>24.62</tripInfantTax>
--		<tripInfantWithSeatBase>142.32</tripInfantWithSeatBase><tripInfantWithSeatTax>23.62</tripInfantWithSeatTax>
--		<tripAirResponseTaxes>
--			<tripAirResponseTax>
--				<amount>10.20</amount><designator>ABC</designator><nature>tax1</nature><description>TAX1</description>
--			</tripAirResponseTax>
--			<tripAirResponseTax>
--				<amount>30.40</amount><designator>BCD</designator><nature>tax2</nature><description>TAX2</description>
--			</tripAirResponseTax>
--		</tripAirResponseTaxes>
--	</TripAirPrice>
--	<TripAirPrice>
--		<tripCategory>Reprice</tripCategory>
--		<tripAdultBase>192.32</tripAdultBase><tripAdultTax>28.62</tripAdultTax>
--		<tripSeniorBase>182.32</tripSeniorBase><tripSeniorTax>27.62</tripSeniorTax>
--		<tripYouthBase>172.32</tripYouthBase><tripYouthTax>26.62</tripYouthTax>
--		<tripChildBase>162.32</tripChildBase><tripChildTax>25.62</tripChildTax>
--		<tripInfantBase>152.32</tripInfantBase><tripInfantTax>24.62</tripInfantTax>
--		<tripInfantWithSeatBase>142.32</tripInfantWithSeatBase><tripInfantWithSeatTax>23.62</tripInfantWithSeatTax>
--		<tripAirResponseTaxes>
--			<tripAirResponseTax>
--				<amount>10.20</amount><designator>ABC</designator><nature>tax1</nature><description>TAX1</description>
--			</tripAirResponseTax>
--			<tripAirResponseTax>
--				<amount>30.40</amount><designator>BCD</designator><nature>tax2</nature><description>TAX2</description>
--			</tripAirResponseTax>
--		</tripAirResponseTaxes>
--	</TripAirPrice>
--</TripAirPrices>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TripAirPrices_Insert] 
	-- Add the parameters for the stored procedure here
	@xmldata XML, @airResponseKey uniqueidentifier
AS
BEGIN
	declare @tmp table (ARow int, tripCategory nvarchar(50), tripAdultBase FLOAT, tripAdultTax FLOAT, tripSeniorBase FLOAT, tripSeniorTax FLOAT, tripYouthBase FLOAT, 
						tripYouthTax FLOAT, tripChildBase FLOAT, tripChildTax FLOAT, tripInfantBase FLOAT, tripInfantTax FLOAT, 
						tripInfantWithSeatBase FLOAT, tripInfantWithSeatTax FLOAT,
						amount FLOAT, designator nvarchar(50), nature nvarchar(50), descript nvarchar(50))
	
	INSERT @tmp (ARow, tripCategory, tripAdultBase, tripAdultTax, tripSeniorBase, tripSeniorTax, tripYouthBase, tripYouthTax, tripChildBase, tripChildTax,
					 tripInfantBase, tripInfantTax, tripInfantWithSeatBase, tripInfantWithSeatTax, amount, designator, nature, descript)
	SELECT X.N, X.C.value('TripAirPrice[1]/tripCategory[1]','varchar(50)'),
				X.C.value('TripAirPrice[1]/tripAdultBase[1]','float'), X.C.value('TripAirPrice[1]/tripAdultTax[1]','float'), 
				X.C.value('TripAirPrice[1]/tripSeniorBase[1]','float'), X.C.value('TripAirPrice[1]/tripSeniorTax[1]','float'),
				X.C.value('TripAirPrice[1]/tripYouthBase[1]','float'), X.C.value('TripAirPrice[1]/tripYouthTax[1]','float'),
				X.C.value('TripAirPrice[1]/tripChildBase[1]','float'), X.C.value('TripAirPrice[1]/tripChildTax[1]','float'),
				X.C.value('TripAirPrice[1]/tripInfantBase[1]','float'), X.C.value('TripAirPrice[1]/tripInfantTax[1]','float'),
				X.C.value('TripAirPrice[1]/tripInfantWithSeatBase[1]','float'), X.C.value('TripAirPrice[1]/tripInfantWithSeatTax[1]','float'),
				Y.C2.value('tripAirResponseTax[1]/amount[1]','float') amount, Y.C2.value('tripAirResponseTax[1]/designator[1]','varchar(50)') designator, 
				Y.C2.value('tripAirResponseTax[1]/nature[1]','varchar(50)') nature, Y.C2.value('tripAirResponseTax[1]/description[1]','varchar(50)') descript
	FROM (
		SELECT T.C.query('.') C, row_number() over (order by C) N
		FROM @xmldata.nodes('//TripAirPrice') T(C)) X
	OUTER APPLY (
		SELECT T2.C2.query('.') C2
		FROM X.C.nodes('TripAirPrice[1]/tripAirResponseTaxes/tripAirResponseTax') T2(C2)) Y
	
	DECLARE @output TABLE (id int, category nvarchar(50))
	DECLARE @tempTripAirPrice TABLE (tripCategory nvarchar(50), tripAdultBase FLOAT, tripAdultTax FLOAT, tripSeniorBase FLOAT, tripSeniorTax FLOAT, tripYouthBase FLOAT, 
			 tripYouthTax FLOAT, tripChildBase FLOAT, tripChildTax FLOAT, tripInfantBase FLOAT, tripInfantTax FLOAT, tripInfantWithSeatBase FLOAT, tripInfantWithSeatTax FLOAT)
	
	INSERT INTO  @tempTripAirPrice (tripCategory, tripAdultBase,tripAdultTax,tripSeniorBase,tripSeniorTax,tripYouthBase,tripYouthTax,tripChildBase,
				tripChildTax ,tripInfantBase ,tripInfantTax,tripInfantWithSeatBase,tripInfantWithSeatTax)
	select tripCategory, tripAdultBase, tripAdultTax, tripSeniorBase, tripSeniorTax, tripYouthBase, tripYouthTax, tripChildBase, tripChildTax,
					 tripInfantBase, tripInfantTax, tripInfantWithSeatBase, tripInfantWithSeatTax
		from (select distinct ARow, tripCategory, tripAdultBase, tripAdultTax, tripSeniorBase, tripSeniorTax, tripYouthBase, tripYouthTax, tripChildBase, tripChildTax,
					 tripInfantBase, tripInfantTax, tripInfantWithSeatBase, tripInfantWithSeatTax from @tmp) X
				order by ARow -- order by is important to maintain correlation
	
	MERGE INTO TripAirPrices USING @tempTripAirPrice AS temp ON 1 = 0
	WHEN NOT MATCHED THEN
	Insert (tripAdultBase, tripAdultTax, tripSeniorBase, tripSeniorTax, tripYouthBase, tripYouthTax, tripChildBase, tripChildTax,
					 tripInfantBase, tripInfantTax, creationDate, tripInfantWithSeatBase, tripInfantWithSeatTax)
	VALUES (temp.tripAdultBase, temp.tripAdultTax, temp.tripSeniorBase, temp.tripSeniorTax, temp.tripYouthBase, temp.tripYouthTax, temp.tripChildBase,
		  temp.tripChildTax, temp.tripInfantBase, temp.tripInfantTax, getdate(), temp.tripInfantWithSeatBase, temp.tripInfantWithSeatTax)
    OUTPUT inserted.tripAirPriceKey, temp.tripCategory INTO @output;	

	-- get the last identity generated to correlate tripAirPriceKey in tripAirResponseTax
	declare @lastid int
	SET @lastid = scope_identity()

	-- Max(ARow) is how many A records were entered, add back ARow to get
	-- the ID generated for the A record
	insert tripAirResponseTax (airResponseKey, tripAirPriceKey, amount, designator, nature, [description])
	select @airResponseKey, @lastid-M.M+ARow, amount, designator, nature, descript
		from @tmp, (select max(ARow) M from @tmp) M
		where amount is not null
		order by ARow
	
	select * from @output		
	
END
GO
