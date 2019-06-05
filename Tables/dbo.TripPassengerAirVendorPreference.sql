CREATE TABLE [dbo].[TripPassengerAirVendorPreference]
(
[TripPassengerAirVendorPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[ID] [int] NULL,
[AirLineCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirLineName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferenceNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__0D7A0286] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerAirVendorPreference] ADD CONSTRAINT [PK__TripPass__C8E1468D59063A47] PRIMARY KEY CLUSTERED  ([TripPassengerAirVendorPreferenceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripPassengerAirVendorPreference_GET_tripKey] ON [dbo].[TripPassengerAirVendorPreference] ([TripKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag Indicates the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirVendorPreference', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Airline Code.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirVendorPreference', 'COLUMN', N'AirLineCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Airline Name.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirVendorPreference', 'COLUMN', N'AirLineName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger Key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirVendorPreference', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirVendorPreference', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerAirVendorPreference table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerAirVendorPreference', 'COLUMN', N'TripPassengerAirVendorPreferenceKey'
GO
