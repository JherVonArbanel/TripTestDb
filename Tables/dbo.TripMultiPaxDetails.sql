CREATE TABLE [dbo].[TripMultiPaxDetails]
(
[multiPassengerKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NULL,
[tripAirSegmentKey] [int] NULL,
[userKey] [int] NULL,
[seatNumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripMultiPaxDetails] ADD CONSTRAINT [PK_TripMultiPaxDetails] PRIMARY KEY CLUSTERED  ([multiPassengerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripMultiPaxDetails table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripMultiPaxDetails', 'COLUMN', N'multiPassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seat Number.', 'SCHEMA', N'dbo', 'TABLE', N'TripMultiPaxDetails', 'COLUMN', N'seatNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip air segment key reference to TripAirSegment table (tripAirSegmentKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripMultiPaxDetails', 'COLUMN', N'tripAirSegmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripMultiPaxDetails', 'COLUMN', N'tripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User key reference to User table (userKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripMultiPaxDetails', 'COLUMN', N'userKey'
GO
