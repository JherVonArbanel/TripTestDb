SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripAirSegments table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_TripAirSegments]
	 @airSegmentKey As uniqueidentifier ,
	 @tripAirLegsKey As int ,
	 @airResponseKey As uniqueidentifier,
	 @airLegNumber As int,
	 @airSegmentMarketingAirlineCode As varchar(2),
	 @airSegmentOperatingAirlineCode As varchar(2),
	 @airSegmentFlightNumber As int ,
	 @airSegmentDuration As time ,
	 @airSegmentEquipment As nvarchar(100),
	 @airSegmentMiles As int,
	 @airSegmentDepartureDate As datetime,
	 @airSegmentArrivalDate As datetime,
	 @airSegmentDepartureAirport As varchar(50) ,
	 @airSegmentArrivalAirport As varchar(50) ,
	 @airSegmentResBookDesigCode As varchar(3) ,
	 @airSegmentDepartureOffset As float,
	 @airSegmentArrivalOffset As float,
	 @airSegmentSeatRemaining As int,
	 @airSegmentMarriageGrp As char(10),
	 @airFareBasisCode As varchar(50),
	 @airFareReferenceKey As varchar(400) ,
	 @airSelectedSeatNumber As varchar(10) ,
	 @airsegmentcabin As varchar(50),
	 @ticketNumber As varchar(50),
	 @airSegmentOperatingFlightNumber As varchar(20),
	 @RecordLocator As varchar(10)
	 
AS
BEGIN
 
INSERT INTO [TripAirSegments] 
		([airSegmentKey],[tripAirLegsKey],[airResponseKey],[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode]
        ,[airSegmentFlightNumber],[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate],[airSegmentArrivalDate]
        ,[airSegmentDepartureAirport],[airSegmentArrivalAirport],[airSegmentResBookDesigCode],[airSegmentDepartureOffset]
        ,[airSegmentArrivalOffset],[airSegmentSeatRemaining],[airSegmentMarriageGrp],[airFareBasisCode],[airFareReferenceKey]
        ,[airSelectedSeatNumber],[airsegmentcabin],[ticketNumber],[airSegmentOperatingFlightNumber],[RecordLocator])
	Values 
		(@airSegmentKey, @tripAirLegsKey, @airResponseKey, @airLegNumber, @airSegmentMarketingAirlineCode, @airSegmentOperatingAirlineCode
        ,@airSegmentFlightNumber, @airSegmentDuration, @airSegmentEquipment, @airSegmentMiles, @airSegmentDepartureDate, @airSegmentArrivalDate
        ,@airSegmentDepartureAirport,@airSegmentArrivalAirport, @airSegmentResBookDesigCode, @airSegmentDepartureOffset 
        ,@airSegmentArrivalOffset, @airSegmentSeatRemaining, @airSegmentMarriageGrp, @airFareBasisCode ,@airFareReferenceKey
        ,@airSelectedSeatNumber,@airsegmentcabin,@ticketNumber,@airSegmentOperatingFlightNumber,@RecordLocator)

END

GO
