SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <18th Aug 17>
-- Description:	<To Insert into TripAirSegments Table>
--<TripAirLegs>
--	<TripAirSegments>
--		<TripAirLeg>
--			<gdsSourceKey>12</gdsSourceKey><selectedBrand></selectedBrand><recordLocator></recordLocator><airLegNumber>1</airLegNumber>
--			<validatingCarrier>WN</validatingCarrier><contractCode></contractCode><isRefundable>True</isRefundable>
--			<TripAirLegPassengerInfos>
--				<TripAirLegPassengerInfo>
--					<PassengerKey>0</PassengerKey><PassengerTypeKey>1</PassengerTypeKey><ticketNumber>5268524543663</ticketNumber><InvoiceNumber></InvoiceNumber>
--				</TripAirLegPassengerInfo>
--			</TripAirLegPassengerInfos>
--		</TripAirLeg>
--		<TripAirSegment>
--			<airSegmentKey>4ca256a9-f5bc-48ba-9df4-e3595e4f1450</airSegmentKey><airLegNumber>1</airLegNumber><airSegmentMarketingAirlineCode>WN</airSegmentMarketingAirlineCode>
--			<airSegmentOperatingAirlineCode>WN</airSegmentOperatingAirlineCode><airSegmentFlightNumber>3508</airSegmentFlightNumber><airSegmentDuration>01:25:00</airSegmentDuration>
--			<airSegmentEquipment></airSegmentEquipment><airSegmentMiles>0</airSegmentMiles><airSegmentDepartureDate>9/10/2017 3:00:00 PM</airSegmentDepartureDate>
--			<airSegmentArrivalDate>9/10/2017 4:25:00 PM</airSegmentArrivalDate><airSegmentDepartureAirport>SFO</airSegmentDepartureAirport><airSegmentArrivalAirport>LAX</airSegmentArrivalAirport>
--			<airSegmentResBookDesigCode>Y</airSegmentResBookDesigCode><airSegmentDepartureOffset>0</airSegmentDepartureOffset><airSegmentArrivalOffset>0</airSegmentArrivalOffset>
--			<airSegmentSeatRemaining>0</airSegmentSeatRemaining><airSegmentMarriageGrp>          </airSegmentMarriageGrp><airFareBasisCode></airFareBasisCode>
--			<airFareReferenceKey></airFareReferenceKey><airSelectedSeatNumber></airSelectedSeatNumber><airsegmentcabin>Economy</airsegmentcabin><ticketNumber></ticketNumber>
--			<airSegmentOperatingFlightNumber>3508</airSegmentOperatingFlightNumber><RecordLocator>RH9VPR</RecordLocator><RPH>0</RPH>
--			<airSegmentOperatingAirlineCompanyShortName></airSegmentOperatingAirlineCompanyShortName><DepartureTerminal></DepartureTerminal><ArrivalTerminal></ArrivalTerminal>
--			<PNRNo>2727377</PNRNo><airSegmentBrandName>Anytime</airSegmentBrandName>
--			<TripAirSegmentPassengersInfo>
--				<TripAirSegmentPassengerInfo>
--					<PassengerKey>0</PassengerKey><PassengerTypeKey>1</PassengerTypeKey><airFareBasisCode></airFareBasisCode><airSelectedSeatNumber></airSelectedSeatNumber><seatMapStatus></seatMapStatus>
--				</TripAirSegmentPassengerInfo>
--			</TripAirSegmentPassengersInfo>
--		</TripAirSegment>
--	</TripAirSegments>
--</TripAirLegs>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TripAirSegments_Insert] 
	-- Add the parameters for the stored procedure here
	@xmldata XML, @airResponseKey uniqueidentifier, @TripAirLegSegment SavePurchaseTrip_TripAirLegSegment Readonly, @TripPassenger SavePurchaseTrip_TripPassenger Readonly
AS
BEGIN
	declare @tmp table (ARow int, airSegmentKey uniqueidentifier, airLegNumber int, airSegmentMarketingAirlineCode nvarchar(2), 
			airSegmentOperatingAirlineCode nvarchar(2), airSegmentFlightNumber int, airSegmentDuration time(7), airSegmentEquipment nvarchar(50), 
			airSegmentMiles int, airSegmentDepartureDate datetime, airSegmentArrivalDate datetime, airSegmentDepartureAirport nvarchar(50), 
			airSegmentArrivalAirport nvarchar(50), airSegmentResBookDesigCode nvarchar(3), airSegmentDepartureOffset float, airSegmentArrivalOffset float,
            airSegmentSeatRemaining int, airSegmentMarriageGrp nvarchar(10), airFareBasisCode nvarchar(50), airFareReferenceKey nvarchar(400), 
            airSelectedSeatNumber nvarchar(10), airsegmentcabin nvarchar(20), ticketNumber nvarchar(50), airSegmentOperatingFlightNumber nvarchar(20), 
            RecordLocator nvarchar(10), RPH nvarchar(2), airSegmentOperatingAirlineCompanyShortName nvarchar(100), DepartureTerminal nvarchar(100), 
            ArrivalTerminal nvarchar(100), PNRNo nvarchar(15), airSegmentBrandName nvarchar(50),airSegmentFareCategory nvarchar(100), PassengerKey int, 
            PassengerTypeKey int, airSelectedSeatNumberPax nvarchar(10), seatMapStatus nvarchar(3), airFareBasisCodePax nvarchar(50),upgradeStatus varchar(50),
			authNumber varchar(20),originalBookingCode varchar(3),originalCabin varchar(20),originalBrandName varchar(100))
	
	INSERT @tmp (ARow, airSegmentKey, airLegNumber, airSegmentMarketingAirlineCode, airSegmentOperatingAirlineCode,
                 airSegmentFlightNumber, airSegmentDuration, airSegmentEquipment, airSegmentMiles, airSegmentDepartureDate, airSegmentArrivalDate,
                 airSegmentDepartureAirport, airSegmentArrivalAirport, airSegmentResBookDesigCode, airSegmentDepartureOffset, airSegmentArrivalOffset,
                 airSegmentSeatRemaining, airSegmentMarriageGrp, airFareBasisCode, airFareReferenceKey, airSelectedSeatNumber, airsegmentcabin, ticketNumber,
                 airSegmentOperatingFlightNumber, RecordLocator, RPH, airSegmentOperatingAirlineCompanyShortName, DepartureTerminal, ArrivalTerminal, PNRNo,
                 airSegmentBrandName,airSegmentFareCategory, upgradeStatus ,
			authNumber ,originalBookingCode ,originalCabin ,originalBrandName,PassengerKey, PassengerTypeKey, airSelectedSeatNumberPax, seatMapStatus, airFareBasisCodePax )
	SELECT X.N, X.C.value('TripAirSegment[1]/airSegmentKey[1]','varchar(50)'), X.C.value('TripAirSegment[1]/airLegNumber[1]','int'), 
				X.C.value('TripAirSegment[1]/airSegmentMarketingAirlineCode[1]','varchar(2)'), X.C.value('TripAirSegment[1]/airSegmentOperatingAirlineCode[1]','varchar(2)'), 
				X.C.value('TripAirSegment[1]/airSegmentFlightNumber[1]','int'), X.C.value('TripAirSegment[1]/airSegmentDuration[1]','time(7)'),
				X.C.value('TripAirSegment[1]/airSegmentEquipment[1]','varchar(50)'), X.C.value('TripAirSegment[1]/airSegmentMiles[1]','int'),
				(case when (charindex('-', X.C.value('TripAirSegment[1]/airSegmentDepartureDate[1]','VARCHAR(30)')) > 0) 
					then CONVERT(datetime, X.C.value('TripAirSegment[1]/airSegmentDepartureDate[1]','VARCHAR(30)'), 103) 
					when (charindex('/', X.C.value('TripAirSegment[1]/airSegmentDepartureDate[1]','VARCHAR(30)')) > 0) 
					then CONVERT(datetime, X.C.value('TripAirSegment[1]/airSegmentDepartureDate[1]','VARCHAR(30)'), 101)
					else X.C.value('TripAirSegment[1]/airSegmentDepartureDate[1]','datetime') end),
				(case when (charindex('-', X.C.value('TripAirSegment[1]/airSegmentArrivalDate[1]','VARCHAR(30)')) > 0) 
					then CONVERT(datetime, X.C.value('TripAirSegment[1]/airSegmentArrivalDate[1]','VARCHAR(30)'), 103) 
					when (charindex('/', X.C.value('TripAirSegment[1]/airSegmentArrivalDate[1]','VARCHAR(30)')) > 0) 
					then CONVERT(datetime, X.C.value('TripAirSegment[1]/airSegmentArrivalDate[1]','VARCHAR(30)'), 101) 
					else X.C.value('TripAirSegment[1]/airSegmentArrivalDate[1]','datetime') end),
				X.C.value('TripAirSegment[1]/airSegmentDepartureAirport[1]','varchar(50)'), X.C.value('TripAirSegment[1]/airSegmentArrivalAirport[1]','varchar(50)'),
				X.C.value('TripAirSegment[1]/airSegmentResBookDesigCode[1]','varchar(3)'), X.C.value('TripAirSegment[1]/airSegmentDepartureOffset[1]','float'),
				X.C.value('TripAirSegment[1]/airSegmentArrivalOffset[1]','float'), X.C.value('TripAirSegment[1]/airSegmentSeatRemaining[1]','int'),
				X.C.value('TripAirSegment[1]/airSegmentMarriageGrp[1]','varchar(10)'), X.C.value('TripAirSegment[1]/airFareBasisCode[1]','varchar(50)'),
				X.C.value('TripAirSegment[1]/airFareReferenceKey[1]','varchar(400)'), X.C.value('TripAirSegment[1]/airSelectedSeatNumber[1]','varchar(10)'),
				X.C.value('TripAirSegment[1]/airsegmentcabin[1]','varchar(20)'), X.C.value('TripAirSegment[1]/ticketNumber[1]','varchar(50)'),
				X.C.value('TripAirSegment[1]/airSegmentOperatingFlightNumber[1]','varchar(20)'), X.C.value('TripAirSegment[1]/RecordLocator[1]','varchar(10)'),
				X.C.value('TripAirSegment[1]/RPH[1]','varchar(2)'), X.C.value('TripAirSegment[1]/airSegmentOperatingAirlineCompanyShortName[1]','varchar(100)'),
				X.C.value('TripAirSegment[1]/DepartureTerminal[1]','varchar(100)'), X.C.value('TripAirSegment[1]/ArrivalTerminal[1]','varchar(100)'),
				X.C.value('TripAirSegment[1]/PNRNo[1]','varchar(15)'), X.C.value('TripAirSegment[1]/airSegmentBrandName[1]','varchar(50)'),
				X.C.value('TripAirSegment[1]/airSegmentFareCategory[1]','varchar(100)'), 
				X.C.value('TripAirSegment[1]/upgradeStatus[1]','varchar(50)'), 
				X.C.value('TripAirSegment[1]/authNumber[1]','varchar(20)'), 
				X.C.value('TripAirSegment[1]/originalBookingCode[1]','varchar(3)'), 
				X.C.value('TripAirSegment[1]/originalCabin[1]','varchar(20)'), 
				X.C.value('TripAirSegment[1]/originalBrandName[1]','varchar(100)'), 
				Y.C2.value('TripAirSegmentPassengerInfo[1]/PassengerKey[1]','int'), Y.C2.value('TripAirSegmentPassengerInfo[1]/PassengerTypeKey[1]','int'),
				Y.C2.value('TripAirSegmentPassengerInfo[1]/airSelectedSeatNumber[1]','varchar(10)'),
				Y.C2.value('TripAirSegmentPassengerInfo[1]/seatMapStatus[1]','varchar(3)') ,Y.C2.value('TripAirSegmentPassengerInfo[1]/airFareBasisCode[1]','varchar(50)')				 
	FROM (
		SELECT T.C.query('.') C, row_number() over (order by C) N
		FROM @xmldata.nodes('//TripAirSegment') T(C)) X
	OUTER APPLY (
		SELECT T2.C2.query('.') C2
		FROM X.C.nodes('TripAirSegment[1]/TripAirSegmentPassengersInfo/TripAirSegmentPassengerInfo') T2(C2)) Y
	--select 'Segments',* from @tmp

	INSERT INTO [TripAirSegments] (airSegmentKey, tripAirLegsKey, airResponseKey, airLegNumber, airSegmentMarketingAirlineCode, airSegmentOperatingAirlineCode,
                 airSegmentFlightNumber, airSegmentDuration, airSegmentEquipment, airSegmentMiles, airSegmentDepartureDate, airSegmentArrivalDate,
                 airSegmentDepartureAirport, airSegmentArrivalAirport, airSegmentResBookDesigCode, airSegmentDepartureOffset, airSegmentArrivalOffset,
                 airSegmentSeatRemaining, airSegmentMarriageGrp, airFareBasisCode, airFareReferenceKey, airSelectedSeatNumber, airsegmentcabin, ticketNumber,
                 airSegmentOperatingFlightNumber, RecordLocator, RPH, airSegmentOperatingAirlineCompanyShortName, DepartureTerminal, ArrivalTerminal, PNRNo,
                 airSegmentBrandName, airSegmentFareCategory,upgradeStatus ,authNumber ,originalBookingCode ,originalCabin ,originalBrandName)
     select NEWID() AS airSegmentKey, R.tripAirLegKey, R.airResponseKey, R.airLegNumber, R.airSegmentMarketingAirlineCode, 
				R.airSegmentOperatingAirlineCode, R.airSegmentFlightNumber, R.airSegmentDuration, R.airSegmentEquipment, R.airSegmentMiles, 
				R.airSegmentDepartureDate, R.airSegmentArrivalDate, R.airSegmentDepartureAirport, R.airSegmentArrivalAirport, 
				R.airSegmentResBookDesigCode, R.airSegmentDepartureOffset, R.airSegmentArrivalOffset, R.airSegmentSeatRemaining, 
				R.airSegmentMarriageGrp, R.airFareBasisCode, R.airFareReferenceKey, R.airSelectedSeatNumber, R.airsegmentcabin, 
				R.ticketNumber, R.airSegmentOperatingFlightNumber, R.RecordLocator, R.RPH, R.airSegmentOperatingAirlineCompanyShortName, 
				R.DepartureTerminal, R.ArrivalTerminal, R.PNRNo, R.airSegmentBrandName,R.airSegmentFareCategory ,R.upgradeStatus ,
				R.authNumber ,R.originalBookingCode ,R.originalCabin ,R.originalBrandName
	from (select DISTINCT x.airSegmentKey, T.tripAirLegKey, @airResponseKey as airResponseKey, X.airLegNumber, airSegmentMarketingAirlineCode, airSegmentOperatingAirlineCode,
                 airSegmentFlightNumber, airSegmentDuration, airSegmentEquipment, airSegmentMiles, airSegmentDepartureDate, airSegmentArrivalDate,
                 airSegmentDepartureAirport, airSegmentArrivalAirport, airSegmentResBookDesigCode, airSegmentDepartureOffset, airSegmentArrivalOffset,
                 airSegmentSeatRemaining, airSegmentMarriageGrp, airFareBasisCode, airFareReferenceKey, airSelectedSeatNumber, airsegmentcabin, ticketNumber,
                 airSegmentOperatingFlightNumber, RecordLocator, RPH, airSegmentOperatingAirlineCompanyShortName, DepartureTerminal, ArrivalTerminal, PNRNo,
                 airSegmentBrandName,airSegmentFareCategory,upgradeStatus ,authNumber ,originalBookingCode ,originalCabin ,originalBrandName
    From (select distinct * from @tmp) X 
			left outer join @TripAirLegSegment T on X.airLegNumber = T.airLegNumber
	--order by ARow --order by commented on 17--oct-2018 By Ravi/sunil/pankaj( Remove duplication segment in case of multipax)-- order by is important to maintain correlation
	)R order by R.airLegNumber,R.RPH
    -- get the last identity generated to correlate AID in B
	declare @lastid int
	SET @lastid = scope_identity()

	-- Max(ARow) is how many A records were entered, add back ARow to get
	-- the ID generated for the A record
	insert TripAirSegmentPassengerInfo (tripAirSegmentkey, tripPassengerInfoKey, airSelectedSeatNumber, seatMapStatus, airFareBasisCode)
	Select distinct X.tripAirSegmentkey, TPI.TripPassengerInfoKey, X.airSelectedSeatNumberPax, X.seatMapStatus, X.airFareBasisCodePax 
	from(select ARow, @lastid-M.M+ARow as tripAirSegmentkey, PassengerKey, PassengerTypeKey, airSelectedSeatNumberPax, seatMapStatus, airFareBasisCodePax
			from @tmp, (select max(ARow) M from @tmp) M
			where PassengerKey is not null
			--order by ARow
		) X left outer join ( select * from TripPassengerInfo 
								where TripPassengerInfoKey in (select tripPassengerInfoKey from @TripPassenger)) TPI 
								on x.PassengerTypeKey = TPI.PassengerTypeKey and X.PassengerKey = TPI.PassengerKey
		--left outer join @TripPassenger P on X.PassengerKey = P.PassengerKey order by X.ARow
		
	
END
GO
