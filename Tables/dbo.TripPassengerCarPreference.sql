CREATE TABLE [dbo].[TripPassengerCarPreference]
(
[TripPassengerCarPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[ID] [int] NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__0E6E26BF] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerCarPreference] ADD CONSTRAINT [PK__TripPass__3245ABE55535A963] PRIMARY KEY CLUSTERED  ([TripPassengerCarPreferenceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarPreference', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger Key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarPreference', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarPreference', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerCarPreference table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarPreference', 'COLUMN', N'TripPassengerCarPreferenceKey'
GO
