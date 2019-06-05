SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[USP_GetOptionalServicesForTripBySegmentForPassengerID]
@airSegmentKey nvarchar(150),
@tripID Int
AS

select *  from TripAirSegmentOptionalServices t 
 
where tripkey=@tripID  and t.airSegmentKey =@airSegmentKey AND ISNULL ( isDeleted , 0 )= 0 
GO
