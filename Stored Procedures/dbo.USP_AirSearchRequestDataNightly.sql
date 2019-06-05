SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 27-July-2012
-- Description:	Get data to build Air search request
-- =============================================
--exec [USP_AirSearchRequestDataNightly] 2, 36, 4
CREATE PROCEDURE [dbo].[USP_AirSearchRequestDataNightly]
	-- Add the parameters for the stored procedure here
	@AirRequestTypeKey int
	,@SiteKey int
	,@BufferDays int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @temp_asr_grp As Table
	(
	PkGroupId int identity(1,1),AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int
	,AdultCount int,SeniorCount int,ChildCount int,InfantCount int,YouthCount int,TotalTraveler int
	,DepartureAirportLeg1 varchar(10),ArrivalAirportLeg1 varchar(10),DepartureDateLeg1 datetime,DepartureAirportLeg2 varchar(10)
	,ArrivalAirportLeg2 varchar(10),DepartureDateLeg2 datetime
	)
	
	Declare @tbl As Table (airSegmentDepartureAirport varchar(3),airSegmentDepartureDate datetime, airLegNumber int,airSegmentArrivalAirport varchar(3),tripKey int,TripSavedKey uniqueidentifier)
	Declare @tbl2 as table (airSegmentDepartureAirport varchar(3),airSegmentDepartureDate datetime, airLegNumber int,airSegmentArrivalAirport varchar(3),tripKey int,TripSavedKey uniqueidentifier)
	Declare @tbl3 as table (airSegmentDepartureAirport varchar(3),airSegmentDepartureDate datetime, airLegNumber int,airSegmentArrivalAirport varchar(3),tripKey int,TripSavedKey uniqueidentifier)
	Declare @SegmentDetail as Table (TripSavedKey uniqueidentifier, AirLegNumber int , MinTripSegkey int,MaxTripSegKey int , TripKey int )
	Declare @Aggregrate As Table (TripType int, TripKey int)
	
	Insert Into @SegmentDetail (TripSavedKey,AirLegNumber,MinTripSegkey,MaxTripSegKey,TripKey)
	Select TS.tripSavedKey, airLegNumber , MIN(tripAirSegmentKey),MAX(tripAirSegmentKey ) tripsegKey ,t.tripKey From TripAirSegments S INNER JOIN TripAirResponse R 
	On s.airResponseKey = r.airResponseKey 
	Inner Join TripSaved TS On TS.tripSavedKey = R.tripGUIDKey
	Inner Join Trip t On t.tripSavedKey = TS.tripSavedKey
	Where T.tripKey NOT IN
	(SELECT T.tripKey From trip T  Inner Join TripAirResponse TH On t.tripPurchasedKey = th.tripGUIDKey And Th.isDeleted = 0) 
	Group By t.tripKey ,s.airLegNumber, TS.tripSavedKey Order By tripKey 
	
	--Select * from @SegmentDetail
	
	Insert Into @tbl
	Select s.airSegmentDepartureAirport ,s.airSegmentDepartureDate , s.airLegNumber,s2.airSegmentArrivalAirport, tripKey,SEG.TripSavedKey
	From TripAirSegments S inner join @segmentDetail SEG on s.tripAirSegmentKey = seg.mintripsegkey 
	INNER JOIN TripAirSegments s2 On SEG.maxTripSegKey = s2.tripAirSegmentKey
	
	--Select * from @tbl
	
	Insert into @Aggregrate 
	Select (COUNT(tripKey)) as TripCount ,tripKey
	from @tbl group by tripKey having (COUNT(tripKey)) = @AirRequestTypeKey
	
	--Select * from @Aggregrate
	
	--Applicable for one way and round trip
	Insert into @tbl2
	Select airSegmentDepartureAirport,airSegmentDepartureDate,airLegNumber,airSegmentArrivalAirport,tripKey,TripSavedKey
	From @tbl Where tripKey in (Select tripKey From @Aggregrate) And airLegNumber = 1
	
	--Select * from @tbl2
	
	If(@AirRequestTypeKey = 2)
		Begin
			Insert into @tbl3
			Select airSegmentDepartureAirport,airSegmentDepartureDate,airLegNumber,airSegmentArrivalAirport,tripKey,TripSavedKey
			From @tbl Where tripKey in (Select tripKey From @Aggregrate) And airLegNumber = 2
			
			--Select * from @tbl3
			
			Insert Into AirRequestNightly (TripRequestKey,TripKey,AirRequestTypeKey,DepartureAirportLeg1,ArrivalAirportLeg1
			,DepartureDateLeg1,LegIndex1,DepartureAirportLeg2,ArrivalAirportLeg2,DepartureDateLeg2,LegIndex2,AdultCount,SeniorCount
			,ChildCount,InfantCount,YouthCount,TotalTraveler,TripSavedKey)
			Select TR.tripRequestKey,T.tripKey,@AirRequestTypeKey,T.airSegmentDepartureAirport,T.AirSegmentArrivalAirport
			,convert(Datetime,convert(Varchar(20),T.airSegmentDepartureDate,103),103),T.airLegNumber,T.AirSegmentArrivalAirport
			,T.airSegmentDepartureAirport,convert(Datetime,convert(Varchar(20),TB.airSegmentDepartureDate ,103),103)
			,TB.airLegNumber,ISNUll(TR.tripAdultsCount,0),ISNUll(TR.tripSeniorsCount,0),ISNUll(TR.tripChildCount,0)
			,ISNUll(TR.tripInfantCount,0),ISNUll(TR.tripYouthCount,0),ISNUll(TR.noOfTotalTraveler,0),TB.TripSavedKey
			From @tbl2 T  
			Inner Join @tbl3 TB ON T.tripKey = TB.tripKey
			Inner Join Trip TR On T.tripKey = TR.tripKey
			Where TR.siteKey = @SiteKey
			And CONVERT(VARCHAR(10), TR.startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
			
			Insert Into @temp_asr_grp
			(AdultCount,SeniorCount,ChildCount,InfantCount,YouthCount,TotalTraveler,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1
			,DepartureAirportLeg2,ArrivalAirportLeg2,DepartureDateLeg2)
			Select Distinct AdultCount,SeniorCount,ChildCount,InfantCount,YouthCount,TotalTraveler
			,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,DepartureAirportLeg2,ArrivalAirportLeg2,DepartureDateLeg2
			From AirRequestNightly
			
			Update asr Set
			asr.pkGroupId = grp.PkGroupId 
			From AirRequestNightly asr 
			left outer join @temp_asr_grp grp On
			grp.AdultCount = asr.AdultCount
			and grp.SeniorCount = asr.SeniorCount
			and grp.ChildCount = asr.ChildCount
			and grp.InfantCount = asr.InfantCount
			and grp.YouthCount = asr.YouthCount
			and grp.DepartureAirportLeg1 = asr.DepartureAirportLeg1
			and grp.ArrivalAirportLeg1 = asr.ArrivalAirportLeg1
			and grp.DepartureDateLeg1 = asr.DepartureDateLeg1
			and grp.DepartureAirportLeg2 = asr.DepartureAirportLeg2
			and grp.ArrivalAirportLeg2 = asr.ArrivalAirportLeg2
			and grp.DepartureDateLeg2 = asr.DepartureDateLeg2
			
		End
	Else If(@AirRequestTypeKey = 1)
		Begin
		
			Insert Into AirRequestNightly (TripRequestKey,TripKey,AirRequestTypeKey,DepartureAirportLeg1,ArrivalAirportLeg1
			,DepartureDateLeg1,LegIndex1,AdultCount,SeniorCount
			,ChildCount,InfantCount,YouthCount,TotalTraveler,TripSavedKey)
			Select TR.tripRequestKey,T.tripKey,@AirRequestTypeKey,T.airSegmentDepartureAirport,T.AirSegmentArrivalAirport
			,convert(Datetime,convert(Varchar(20),T.airSegmentDepartureDate,103),103),T.airLegNumber,ISNUll(TR.tripAdultsCount,0)
			,ISNUll(TR.tripSeniorsCount,0),ISNUll(TR.tripChildCount,0),ISNUll(TR.tripInfantCount,0),ISNUll(TR.tripYouthCount,0)
			,ISNUll(TR.noOfTotalTraveler,0),T.TripSavedKey
			From @tbl2 T  
			Inner Join Trip TR On T.tripKey = TR.tripKey
			Where TR.siteKey = @SiteKey
			And CONVERT(VARCHAR(10), TR.startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
			
			Insert Into @temp_asr_grp
			(AdultCount,SeniorCount,ChildCount,InfantCount,YouthCount,TotalTraveler,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1)
			Select Distinct AdultCount,SeniorCount,ChildCount,InfantCount,YouthCount,TotalTraveler
			,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1
			From AirRequestNightly
			
			Update asr Set
			asr.pkGroupId = grp.PkGroupId 
			From AirRequestNightly asr 
			left outer join @temp_asr_grp grp On
			grp.AdultCount = asr.AdultCount
			and grp.SeniorCount = asr.SeniorCount
			and grp.ChildCount = asr.ChildCount
			and grp.InfantCount = asr.InfantCount
			and grp.YouthCount = asr.YouthCount
			and grp.DepartureAirportLeg1 = asr.DepartureAirportLeg1
			and grp.ArrivalAirportLeg1 = asr.ArrivalAirportLeg1
			and grp.DepartureDateLeg1 = asr.DepartureDateLeg1
		End
	
	Select PkGroupId From @temp_asr_grp order by PkGroupId
	
END
GO
