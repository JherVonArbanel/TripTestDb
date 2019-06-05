CREATE TABLE [dbo].[TripPassengerAirPreference]
(
[TripPassengerAirPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[ID] [int] NULL,
[OriginAirportCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketDelivery] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirSeatingType] [int] NULL,
[AirRowType] [int] NULL,
[AirMealType] [int] NULL,
[AirSpecialSevicesType] [int] NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__0C85DE4D] DEFAULT ((1)),
[AirsegmentKey] [uniqueidentifier] NULL,
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerAirPreference] ADD CONSTRAINT [PK__TripPass__E6B31A635CD6CB2B] PRIMARY KEY CLUSTERED  ([TripPassengerAirPreferenceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripPassengerAirPreference_GET_tripKey] ON [dbo].[TripPassengerAirPreference] ([TripKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag Indicates AirPreference is Active or not.  Default is Active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirPreference', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air Segment key reference to AirSegments table (airSegmentKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirPreference', 'COLUMN', N'AirsegmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Origin Airport Code.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirPreference', 'COLUMN', N'OriginAirportCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirPreference', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirPreference', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerAirPreference table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirPreference', 'COLUMN', N'TripPassengerAirPreferenceKey'
GO
