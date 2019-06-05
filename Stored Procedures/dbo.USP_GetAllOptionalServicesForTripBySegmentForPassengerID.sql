SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[USP_GetAllOptionalServicesForTripBySegmentForPassengerID]
@airSegmentKey nvarchar(150),
@tripID Int
AS

select distinct * from AirSegmentOptionalServices   seg 
where  seg.airSegmentKey =@airSegmentKey

select * from TripAirSegmentOptionalServices 

serviceStatus
GO
