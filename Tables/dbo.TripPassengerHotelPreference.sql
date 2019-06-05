CREATE TABLE [dbo].[TripPassengerHotelPreference]
(
[TripPassengerHotelPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[ID] [int] NULL,
[SmokingType] [int] NULL,
[BedType] [int] NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__114A936A] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerHotelPreference] ADD CONSTRAINT [PK__TripPass__0B999B2E49C3F6B7] PRIMARY KEY CLUSTERED  ([TripPassengerHotelPreferenceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelPreference', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger Key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelPreference', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelPreference', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerHotelPreference table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelPreference', 'COLUMN', N'TripPassengerHotelPreferenceKey'
GO
