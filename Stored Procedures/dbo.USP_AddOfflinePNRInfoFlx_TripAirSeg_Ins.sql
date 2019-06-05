SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoFlx_TripAirSeg_Ins]
(  
	@airSegmentKey	UNIQUEIDENTIFIER, 
	@tripAirLegsKey INT, 
	@airResponseKey UNIQUEIDENTIFIER, 
	@airLegNumber	INT, 
	@airSegmentMarketingAirlineCode VARCHAR(2), 
	@airSegmentOperatingAirlineCode VARCHAR(2),
	@airSegmentFlightNumber INT, 
	@airSegmentDuration		TIME, 
	@airSegmentEquipment	NVARCHAR(50), 
	@airSegmentMiles		INT, 
	@airSegmentDepartureDate DATETIME, 
	@airSegmentArrivalDate	DATETIME, 
	@airSegmentDepartureAirport VARCHAR(50), 
	@airSegmentArrivalAirport	VARCHAR(50), 
	@airSegmentResBookDesigCode VARCHAR(3), 
	@airSegmentDepartureOffset	FLOAT, 
	@airSegmentArrivalOffset	FLOAT, 
	@airSegmentSeatRemaining	INT, 
	@airSegmentMarriageGrp		CHAR(10), 
	@airFareBasisCode			VARCHAR(50), 
	@airFareReferenceKey		VARCHAR(400), 
	@airSelectedSeatNumber		VARCHAR(10), 
	@ticketNumber		VARCHAR(50), 
	@airsegmentcabin	VARCHAR(20), 
	@RecordLocator		VARCHAR(10)
)AS  
  
BEGIN  

	INSERT INTO [TripAirSegments] 
	(
		[airSegmentKey], [tripAirLegsKey], [airResponseKey], [airLegNumber], [airSegmentMarketingAirlineCode], [airSegmentOperatingAirlineCode], 
		[airSegmentFlightNumber], [airSegmentDuration], [airSegmentEquipment], [airSegmentMiles], [airSegmentDepartureDate], 
		[airSegmentArrivalDate], [airSegmentDepartureAirport], [airSegmentArrivalAirport], [airSegmentResBookDesigCode], 
		[airSegmentDepartureOffset], [airSegmentArrivalOffset], [airSegmentSeatRemaining], 
		[airSegmentMarriageGrp], [airFareBasisCode], [airFareReferenceKey], [airSelectedSeatNumber], [ticketNumber], 
		[airsegmentcabin], [RecordLocator]
	)
    VALUES 
    (
		@airSegmentKey, @tripAirLegsKey, @airResponseKey, @airLegNumber, @airSegmentMarketingAirlineCode, @airSegmentOperatingAirlineCode,
		@airSegmentFlightNumber, @airSegmentDuration, @airSegmentEquipment, @airSegmentMiles, @airSegmentDepartureDate, @airSegmentArrivalDate, 
		@airSegmentDepartureAirport, @airSegmentArrivalAirport, @airSegmentResBookDesigCode, @airSegmentDepartureOffset, 
		@airSegmentArrivalOffset, @airSegmentSeatRemaining, @airSegmentMarriageGrp, @airFareBasisCode, @airFareReferenceKey, 
		@airSelectedSeatNumber, @ticketNumber, @airsegmentcabin, @RecordLocator
    )

END  

GO
