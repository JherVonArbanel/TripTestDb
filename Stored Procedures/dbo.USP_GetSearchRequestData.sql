SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 21-May-2012
-- Description:	Get data to build search request
-- =============================================
--exec USP_GetSearchRequestData 2, 5, 2
CREATE PROCEDURE [dbo].[USP_GetSearchRequestData]
	-- Add the parameters for the stored procedure here
	@AirRequestTypeKey int
	,@SiteKey int
	,@BufferDays int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
declare @temp_asr_grp as table
(
		PkGroupId int identity(1,1),AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int,Adults int,Children int,Seniors int
		,DepartureAirportLeg1 varchar(10),ArrivalAirportLeg1 varchar(10),DepartureDateLeg1 datetime,DepartureAirportLeg2 varchar(10)
		,ArrivalAirportLeg2 varchar(10),DepartureDateLeg2 datetime,DepartureAirportLeg3 varchar(10),ArrivalAirportLeg3 varchar(10)
		,DepartureDateLeg3 datetime,DepartureAirportLeg4 varchar(10),ArrivalAirportLeg4 varchar(10),DepartureDateLeg4 datetime
		,DepartureAirportLeg5 varchar(10),ArrivalAirportLeg5 varchar(10),DepartureDateLeg5 datetime,DepartureAirportLeg6 varchar(10)
		,ArrivalAirportLeg6 varchar(10),DepartureDateLeg6 datetime
)
declare @TableLeg1 as table
(	
	AirRequestType int,TripRequestKey int,TripKey int,AirRequestKey int,AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int,Adults int,Children int,Seniors int
	,DepartureAirportLeg1 varchar(10),ArrivalAirportLeg1 varchar(10),DepartureDateLeg1 datetime,LegIndex1 int
)

declare @TableLeg2 table
(
	AirRequestType int,TripRequestKey int,TripKey int,AirRequestKey int,AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int,Adults int,Children int,Seniors int
	,DepartureAirportLeg2 varchar(10),ArrivalAirportLeg2 varchar(10),DepartureDateLeg2 datetime,LegIndex2 int
)

declare @TableLeg3 table
(
	AirRequestType int,TripRequestKey int,TripKey int,AirRequestKey int,AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int,Adults int,Children int,Seniors int
	,DepartureAirportLeg3 varchar(10),ArrivalAirportLeg3 varchar(10),DepartureDateLeg3 datetime,LegIndex3 int
)

declare @TableLeg4 table
(
	AirRequestType int,TripRequestKey int,TripKey int,AirRequestKey int,AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int,Adults int,Children int,Seniors int
	,DepartureAirportLeg4 varchar(10),ArrivalAirportLeg4 varchar(10),DepartureDateLeg4 datetime,LegIndex4 int
)

declare @TableLeg5 table
(
	AirRequestType int,TripRequestKey int,TripKey int,AirRequestKey int,AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int,Adults int,Children int,Seniors int
	,DepartureAirportLeg5 varchar(10),ArrivalAirportLeg5 varchar(10),DepartureDateLeg5 datetime,LegIndex5 int
)

declare @TableLeg6 table
(
	AirRequestType int,TripRequestKey int,TripKey int,AirRequestKey int,AirRequestTypeKey int,IsInternationalTrip bit,ClassLevel int,Adults int,Children int,Seniors int
	,DepartureAirportLeg6 varchar(10),ArrivalAirportLeg6 varchar(10),DepartureDateLeg6 datetime,LegIndex6 int
)

insert into @TableLeg1
	SELECT AR.airRequestTypeKey, TR.tripRequestKey, TR.tripKey, TRA.airRequestKey,AR.airRequestTypeKey,AR.isInternationalTrip, TRA.airRequestClassKey,
	TRA.airRequestAdults, TRA.airRequestChildren, TRA.airRequestSeniors , ASR.airRequestDepartureAirport, ASR.airRequestArrivalAirport,
	ASR.airRequestDepartureDate, ASR.airSubRequestLegIndex
	FROM Trip TR
	inner join TripRequest_air TRA on TR.tripRequestKey = TRA.tripRequestKey
	inner join AirRequest AR on TRA.airRequestKey = AR.airRequestKey
	inner join airSubRequest ASR on ASR.AirRequestKey = TRA.airRequestKey
	WHERE AR.airRequestTypeKey = @AirRequestTypeKey and TR.siteKey = @SiteKey and ASR.airSubRequestLegIndex = 1
	AND CONVERT(VARCHAR(10), startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))

IF(@AirRequestTypeKey = 2 or @AirRequestTypeKey = 3)
Begin
insert into @TableLeg2
	SELECT AR.airRequestTypeKey, TR.tripRequestKey, TR.tripKey, TRA.airRequestKey,AR.airRequestTypeKey,AR.isInternationalTrip, TRA.airRequestClassKey,
	TRA.airRequestAdults, TRA.airRequestChildren, TRA.airRequestSeniors , ASR.airRequestDepartureAirport, ASR.airRequestArrivalAirport,
	ASR.airRequestDepartureDate, ASR.airSubRequestLegIndex
	FROM Trip TR
	inner join TripRequest_air TRA on TR.tripRequestKey = TRA.tripRequestKey
	inner join AirRequest AR on TRA.airRequestKey = AR.airRequestKey
	inner join airSubRequest ASR on ASR.AirRequestKey = TRA.airRequestKey
	WHERE AR.airRequestTypeKey = @AirRequestTypeKey and TR.siteKey = @SiteKey and ASR.airSubRequestLegIndex = 2
	AND CONVERT(VARCHAR(10), startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
End

IF(@AirRequestTypeKey = 3)
Begin
insert into @TableLeg3
	SELECT AR.airRequestTypeKey, TR.tripRequestKey, TR.tripKey, TRA.airRequestKey,AR.airRequestTypeKey,AR.isInternationalTrip, TRA.airRequestClassKey,
	TRA.airRequestAdults, TRA.airRequestChildren, TRA.airRequestSeniors , ASR.airRequestDepartureAirport, ASR.airRequestArrivalAirport,
	ASR.airRequestDepartureDate, ASR.airSubRequestLegIndex
	FROM Trip TR
	inner join TripRequest_air TRA on TR.tripRequestKey = TRA.tripRequestKey
	inner join AirRequest AR on TRA.airRequestKey = AR.airRequestKey
	inner join airSubRequest ASR on ASR.AirRequestKey = TRA.airRequestKey
	WHERE AR.airRequestTypeKey = @AirRequestTypeKey and TR.siteKey = @SiteKey and ASR.airSubRequestLegIndex = 3
	AND CONVERT(VARCHAR(10), startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))

insert into @TableLeg4
	SELECT AR.airRequestTypeKey, TR.tripRequestKey, TR.tripKey, TRA.airRequestKey,AR.airRequestTypeKey,AR.isInternationalTrip, TRA.airRequestClassKey,
	TRA.airRequestAdults, TRA.airRequestChildren, TRA.airRequestSeniors , ISNULL(ASR.airRequestDepartureAirport,'0'), ISNULL(ASR.airRequestArrivalAirport,'0'),
	ISNULL(ASR.airRequestDepartureDate,'1753-01-01 00:00:00.000'), ISNULL(ASR.airSubRequestLegIndex,4)
	FROM Trip TR
	inner join TripRequest_air TRA on TR.tripRequestKey = TRA.tripRequestKey
	inner join AirRequest AR on TRA.airRequestKey = AR.airRequestKey
	inner join airSubRequest ASR on ASR.AirRequestKey = TRA.airRequestKey
	WHERE AR.airRequestTypeKey = @AirRequestTypeKey and TR.siteKey = @SiteKey and ASR.airSubRequestLegIndex = 4
	AND CONVERT(VARCHAR(10), startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))

insert into @TableLeg5
	SELECT AR.airRequestTypeKey, TR.tripRequestKey, TR.tripKey, TRA.airRequestKey,AR.airRequestTypeKey,AR.isInternationalTrip, TRA.airRequestClassKey,
	TRA.airRequestAdults, TRA.airRequestChildren, TRA.airRequestSeniors , ISNULL(ASR.airRequestDepartureAirport,'0'), ISNULL(ASR.airRequestArrivalAirport,'0'),
	ISNULL(ASR.airRequestDepartureDate,'1753-01-01 00:00:00.000'), ISNULL(ASR.airSubRequestLegIndex,5)
	FROM Trip TR
	inner join TripRequest_air TRA on TR.tripRequestKey = TRA.tripRequestKey
	inner join AirRequest AR on TRA.airRequestKey = AR.airRequestKey
	inner join airSubRequest ASR on ASR.AirRequestKey = TRA.airRequestKey
	WHERE AR.airRequestTypeKey = @AirRequestTypeKey and TR.siteKey = @SiteKey and ASR.airSubRequestLegIndex = 5
	AND CONVERT(VARCHAR(10), startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))

insert into @TableLeg6
	SELECT AR.airRequestTypeKey, TR.tripRequestKey, TR.tripKey, TRA.airRequestKey,AR.airRequestTypeKey,AR.isInternationalTrip, TRA.airRequestClassKey,
	TRA.airRequestAdults, TRA.airRequestChildren, TRA.airRequestSeniors , ISNULL(ASR.airRequestDepartureAirport,'0'), ISNULL(ASR.airRequestArrivalAirport,'0'),
	ISNULL(ASR.airRequestDepartureDate,'1753-01-01 00:00:00.000'), ISNULL(ASR.airSubRequestLegIndex,6)
	FROM Trip TR
	inner join TripRequest_air TRA on TR.tripRequestKey = TRA.tripRequestKey
	inner join AirRequest AR on TRA.airRequestKey = AR.airRequestKey
	inner join airSubRequest ASR on ASR.AirRequestKey = TRA.airRequestKey
	WHERE AR.airRequestTypeKey = @AirRequestTypeKey and TR.siteKey = @SiteKey and ASR.airSubRequestLegIndex = 6
	AND CONVERT(VARCHAR(10), startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
	
	--select * from @TableLeg6
End

IF(@AirRequestTypeKey = 1)
Begin
	insert into AirRequestForBid (AirRequestType,TripRequestKey,TripKey,AirRequestKey,AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors
	,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,LegIndex1)
	select Leg1.AirRequestType,Leg1.TripRequestKey,Leg1.TripKey,Leg1.AirRequestKey,Leg1.AirRequestTypeKey,Leg1.IsInternationalTrip,Leg1.ClassLevel
	,Leg1.Adults,Leg1.Children,Leg1.Seniors,Leg1.DepartureAirportLeg1,Leg1.ArrivalAirportLeg1,Leg1.DepartureDateLeg1,Leg1.LegIndex1
	 from @TableLeg1 Leg1 
 
Insert into @temp_asr_grp
        (AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1)
select distinct AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1
from AirRequestForBid

	update asr set
	asr.pkGroupId = grp.PkGroupId 
	from AirRequestForBid asr 
	left outer join @temp_asr_grp grp on
	grp.AirRequestTypeKey = asr.AirRequestTypeKey
	and grp.IsInternationalTrip = asr.IsInternationalTrip 
	and grp.ClassLevel = ISNULL(asr.ClassLevel,0)
	and grp.Adults = ISNULL(asr.Adults,0)
	and grp.Children = ISNULL(asr.Children,0)
	and grp.Seniors = ISNULL(asr.Seniors,0)
	and grp.DepartureAirportLeg1 = asr.DepartureAirportLeg1
	and grp.ArrivalAirportLeg1 = asr.ArrivalAirportLeg1
	and grp.DepartureDateLeg1 = asr.DepartureDateLeg1
End

Else If(@AirRequestTypeKey = 2)
Begin
	insert into AirRequestForBid (AirRequestType,TripRequestKey,TripKey,AirRequestKey,AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors
	,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,LegIndex1 	
	,DepartureAirportLeg2,ArrivalAirportLeg2,DepartureDateLeg2,LegIndex2)
	select Leg1.AirRequestType,Leg1.TripRequestKey,Leg1.TripKey,Leg1.AirRequestKey,Leg1.AirRequestTypeKey,Leg1.IsInternationalTrip
	,Leg1.ClassLevel,Leg1.Adults,Leg1.Children,Leg1.Seniors,Leg1.DepartureAirportLeg1,Leg1.ArrivalAirportLeg1,Leg1.DepartureDateLeg1,Leg1.LegIndex1
	,Leg2.DepartureAirportLeg2,Leg2.ArrivalAirportLeg2,Leg2.DepartureDateLeg2,Leg2.LegIndex2
	 from @TableLeg1 Leg1 
	 inner join @TableLeg2 Leg2 on Leg1.AirRequestKey = Leg2.AirRequestKey
  
 insert into @temp_asr_grp
        (AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,DepartureAirportLeg2
		,ArrivalAirportLeg2,DepartureDateLeg2)
select distinct AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,DepartureAirportLeg2
		,ArrivalAirportLeg2,DepartureDateLeg2
from AirRequestForBid

	update asr set
	asr.pkGroupId = grp.PkGroupId 
	from AirRequestForBid asr 
	left outer join @temp_asr_grp grp on 
	grp.AirRequestTypeKey = asr.AirRequestTypeKey
	and grp.IsInternationalTrip = asr.IsInternationalTrip 
	and grp.ClassLevel = ISNULL(asr.ClassLevel,0)
	and grp.Adults = ISNULL(asr.Adults,0)
	and grp.Children = ISNULL(asr.Children,0)
	and grp.Seniors = ISNULL(asr.Seniors,0)
	and grp.DepartureAirportLeg1 = asr.DepartureAirportLeg1
	and grp.ArrivalAirportLeg1 = asr.ArrivalAirportLeg1
	and grp.DepartureDateLeg1 = asr.DepartureDateLeg1
	and grp.DepartureAirportLeg2 = asr.DepartureAirportLeg2
	and grp.ArrivalAirportLeg2 = asr.ArrivalAirportLeg2
	and grp.DepartureDateLeg2 = asr.DepartureDateLeg2
End

Else If(@AirRequestTypeKey = 3)
Begin
	insert into AirRequestForBid (AirRequestType,TripRequestKey,TripKey,AirRequestKey,AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors
	,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,LegIndex1 	
	,DepartureAirportLeg2,ArrivalAirportLeg2,DepartureDateLeg2,LegIndex2 
	,DepartureAirportLeg3,ArrivalAirportLeg3,DepartureDateLeg3,LegIndex3 	
	,DepartureAirportLeg4,ArrivalAirportLeg4,DepartureDateLeg4,LegIndex4 
	,DepartureAirportLeg5,ArrivalAirportLeg5,DepartureDateLeg5,LegIndex5 
	,DepartureAirportLeg6,ArrivalAirportLeg6,DepartureDateLeg6,LegIndex6)
	select Leg1.AirRequestType,Leg1.TripRequestKey,Leg1.TripKey,Leg1.AirRequestKey,Leg1.AirRequestTypeKey,Leg1.IsInternationalTrip,Leg1.ClassLevel,Leg1.Adults,Leg1.Children,Leg1.Seniors
	,Leg1.DepartureAirportLeg1,Leg1.ArrivalAirportLeg1,Leg1.DepartureDateLeg1,Leg1.LegIndex1
	,Leg2.DepartureAirportLeg2,Leg2.ArrivalAirportLeg2,Leg2.DepartureDateLeg2,Leg2.LegIndex2
	,Leg3.DepartureAirportLeg3,Leg3.ArrivalAirportLeg3,Leg3.DepartureDateLeg3,Leg3.LegIndex3
	,Leg4.DepartureAirportLeg4,Leg4.ArrivalAirportLeg4,Leg4.DepartureDateLeg4,Leg4.LegIndex4
	,Leg5.DepartureAirportLeg5,Leg5.ArrivalAirportLeg5,Leg5.DepartureDateLeg5,Leg5.LegIndex5
	,Leg6.DepartureAirportLeg6,Leg6.ArrivalAirportLeg6,Leg6.DepartureDateLeg6,Leg6.LegIndex6
	 from @TableLeg1 Leg1 
	 inner join @TableLeg2 Leg2 on Leg1.AirRequestKey = Leg2.AirRequestKey
	 inner join @TableLeg3 Leg3 on Leg1.AirRequestKey = Leg3.AirRequestKey
	 inner join @TableLeg4 Leg4 on Leg1.AirRequestKey = Leg4.AirRequestKey
	 inner join @TableLeg5 Leg5 on Leg1.AirRequestKey = Leg5.AirRequestKey
	 inner join @TableLeg6 Leg6 on Leg1.AirRequestKey = Leg6.AirRequestKey
 
insert into @temp_asr_grp
        (AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,DepartureAirportLeg2
		,ArrivalAirportLeg2,DepartureDateLeg2,DepartureAirportLeg3,ArrivalAirportLeg3,DepartureDateLeg3,DepartureAirportLeg4
		,ArrivalAirportLeg4,DepartureDateLeg4,DepartureAirportLeg5,ArrivalAirportLeg5,DepartureDateLeg5,DepartureAirportLeg6
		,ArrivalAirportLeg6,DepartureDateLeg6)
select distinct AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,DepartureAirportLeg2
		,ArrivalAirportLeg2,DepartureDateLeg2,DepartureAirportLeg3,ArrivalAirportLeg3,DepartureDateLeg3,DepartureAirportLeg4
		,ArrivalAirportLeg4,DepartureDateLeg4,DepartureAirportLeg5,ArrivalAirportLeg5,DepartureDateLeg5,DepartureAirportLeg6
		,ArrivalAirportLeg6,DepartureDateLeg6
from AirRequestForBid

	update asr set
	asr.pkGroupId = grp.PkGroupId 
	from AirRequestForBid asr 
	left outer join @temp_asr_grp grp on 
	grp.AirRequestTypeKey = asr.AirRequestTypeKey
	and grp.IsInternationalTrip = asr.IsInternationalTrip 
	and grp.ClassLevel = ISNULL(asr.ClassLevel,0)
	and grp.Adults = ISNULL(asr.Adults,0)
	and grp.Children = ISNULL(asr.Children,0)
	and grp.Seniors = ISNULL(asr.Seniors,0)
	and grp.DepartureAirportLeg1 = asr.DepartureAirportLeg1
	and grp.ArrivalAirportLeg1 = asr.ArrivalAirportLeg1
	and grp.DepartureDateLeg1 = asr.DepartureDateLeg1
	and grp.DepartureAirportLeg2 = asr.DepartureAirportLeg2
	and grp.ArrivalAirportLeg2 = asr.ArrivalAirportLeg2
	and grp.DepartureDateLeg2 = asr.DepartureDateLeg2
	and grp.DepartureAirportLeg3 = asr.DepartureAirportLeg3
	and grp.ArrivalAirportLeg3 = asr.ArrivalAirportLeg3
	and grp.DepartureDateLeg3 = asr.DepartureDateLeg3
	and grp.DepartureAirportLeg4 = asr.DepartureAirportLeg4
	and grp.ArrivalAirportLeg4 = asr.ArrivalAirportLeg4
	and grp.DepartureDateLeg4 = ISNULL(asr.DepartureDateLeg4,'1753-01-01 00:00:00.000')
	and grp.DepartureAirportLeg5 = asr.DepartureAirportLeg5
	and grp.ArrivalAirportLeg5 = asr.ArrivalAirportLeg5
	and grp.DepartureDateLeg5 = ISNULL(asr.DepartureDateLeg5,'1753-01-01 00:00:00.000')
	and grp.DepartureAirportLeg6 = asr.DepartureAirportLeg6
	and grp.ArrivalAirportLeg6 = asr.ArrivalAirportLeg6
	and grp.DepartureDateLeg6 = ISNULL(asr.DepartureDateLeg6,'1753-01-01 00:00:00.000')
End
	
	--select PkGroupId,AirRequestTypeKey,IsInternationalTrip,ClassLevel,Adults,Children,Seniors,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,DepartureAirportLeg2
	--	,ArrivalAirportLeg2,DepartureDateLeg2,DepartureAirportLeg3,ArrivalAirportLeg3,DepartureDateLeg3,DepartureAirportLeg4
	--	,ArrivalAirportLeg4,DepartureDateLeg4,DepartureAirportLeg5,ArrivalAirportLeg5,DepartureDateLeg5,DepartureAirportLeg6
	--	,ArrivalAirportLeg6,DepartureDateLeg6 from @temp_asr_grp order by PkGroupId
	select PkGroupId, AirRequestTypeKey from @temp_asr_grp order by PkGroupId
	
	
END
GO
