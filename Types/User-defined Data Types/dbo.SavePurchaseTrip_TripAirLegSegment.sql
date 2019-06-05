CREATE TYPE [dbo].[SavePurchaseTrip_TripAirLegSegment] AS TABLE
(
[tripAirLegKey] [int] NULL,
[airLegNumber] [int] NULL,
[airSegmentKey] [uniqueidentifier] NULL
)
GO
