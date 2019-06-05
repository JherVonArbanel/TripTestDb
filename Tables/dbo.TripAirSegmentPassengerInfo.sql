CREATE TABLE [dbo].[TripAirSegmentPassengerInfo]
(
[tripAirSegmentPassengerInfoKey] [int] NOT NULL IDENTITY(1, 1),
[tripAirSegmentkey] [int] NOT NULL,
[tripPassengerInfoKey] [int] NOT NULL,
[airSelectedSeatNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatMapStatus] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirSegmentPassengerInfo] ADD CONSTRAINT [PK_TripAirSegmentPassengerInfo_1] PRIMARY KEY CLUSTERED  ([tripAirSegmentPassengerInfoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SegKey_Incl] ON [dbo].[TripAirSegmentPassengerInfo] ([tripAirSegmentkey]) INCLUDE ([airFareBasisCode], [airSelectedSeatNumber], [seatMapStatus], [tripAirSegmentPassengerInfoKey], [tripPassengerInfoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
