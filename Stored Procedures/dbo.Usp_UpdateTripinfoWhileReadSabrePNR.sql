SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[Usp_UpdateTripinfoWhileReadSabrePNR]
@TripKey int

as
BEgin
Update TripAirResponseTax
Set description = (Select top 1 SubTT.description from TripAirResponseTax SubTT Where TT.airResponseKey = SubTT.airResponseKey and SubTT.description is not null and tt.designator = SubTT.designator )
From TripAirResponseTax  TT 
inner join TripAirResponse TA on TT.airResponseKey = TA.airResponseKey 
Where Ta.tripKey = @TripKey  and tt.description  is null and  TT.Active = 1 

/*Update TripAirSegments
Set airsegmentcabin  = (Select top 1 SubTT.airsegmentcabin  from TripAirSegments SubTT 
	Where TT.airResponseKey = SubTT.airResponseKey and (SubTT.airsegmentcabin  is not null and  airsegmentcabin <> '')
	and tt.airSegmentFlightNumber = SubTT.airSegmentFlightNumber 
	 and  tt.airSegmentDepartureAirport = SubTT.airSegmentDepartureAirport  AND SubTT.isDeleted=1)
From TripAirSegments  TT 
inner join TripAirResponse TA on TT.airResponseKey = TA.airResponseKey 
Where Ta.tripKey = @TripKey  and  TT.isDeleted  = 0
*/
End


GO
