SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_BulkInsertAirSegmentsMultiBrand]
	@airSegmentsMultiBrand [TVP_AirSegmentMultiBrand] READONLY
AS
BEGIN
	INSERT INTO AirSegmentsMultiBrand(airSegmentMultiBrandKey,	airSegmentKey, airResponseMultiBrandKey,
	airResponseKey, airLegNumber, airSegmentResBookDesigCode, airSegmentSeatRemaining,
	airSegmentFareBasisCode, airSegmentFareReferenceKey, airSegmentCabin, 
	segmentOrder, airSegmentPricingKey, airSegmentBrandName, airSegmentBrandID,
	airSegmentBaggage, airSegmentMealCode, isReturnFare)
	SELECT airSegmentMultiBrandKey,	airSegmentKey, airResponseMultiBrandKey,
	airResponseKey, airLegNumber, airSegmentResBookDesigCode, airSegmentSeatRemaining,
	airSegmentFareBasisCode, airSegmentFareReferenceKey, airSegmentCabin, 
	segmentOrder, airSegmentPricingKey, airSegmentBrandName, airSegmentBrandID,
	airSegmentBaggage, airSegmentMealCode, isReturnFare
	FROM @airSegmentsMultiBrand 
END
GO
