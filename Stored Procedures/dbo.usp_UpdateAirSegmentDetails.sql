SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 12/13/2017
-- Description:	Procedure to update Air Segment details
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateAirSegmentDetails]
	@airSegmentResBookDesigCode VARCHAR(3) = '',
	@airSegmentMarriageGrp CHAR(10) = '',
	@airSegmentKey UNIQUEIDENTIFIER,
	@airSegmentFlightNumber INT,
	@airFareReferenceKey nvarchar(400)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE 
		AirSegments
	SET
		airSegmentResBookDesigCode = @airSegmentResBookDesigCode, 
		airSegmentMarriageGrp = @airSegmentMarriageGrp,
		airFareReferenceKey = @airFareReferenceKey
	WHERE
		airSegmentKey = @airSegmentKey
		AND airSegmentFlightNumber = @airSegmentFlightNumber
END
GO
