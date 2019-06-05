SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_UpdateBookingClassForSegment] 
(
@segmentKey uniqueidentifier ,
@bookingClass varchar(10)
)
AS 
BEGIN 
UPDATE TripAirSegments SET airSegmentResBookDesigCode =@bookingClass where airSegmentKey =@segmentKey 
END
GO
