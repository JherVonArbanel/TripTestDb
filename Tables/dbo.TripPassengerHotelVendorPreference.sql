CREATE TABLE [dbo].[TripPassengerHotelVendorPreference]
(
[TripPassengerHotelVendorPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[ID] [int] NULL,
[HotelChainCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HotelChainName] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferenceNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__123EB7A3] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerHotelVendorPreference] ADD CONSTRAINT [PK__TripPass__0C52FF0D45F365D3] PRIMARY KEY CLUSTERED  ([TripPassengerHotelVendorPreferenceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not. Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelVendorPreference', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Hotel Chain code reference to HotelChains table in HotelContent (ChainCode).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelVendorPreference', 'COLUMN', N'HotelChainCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Hotel chain name.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelVendorPreference', 'COLUMN', N'HotelChainName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelVendorPreference', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip Key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelVendorPreference', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary Key for TripPassengerHotelVendorPreference table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerHotelVendorPreference', 'COLUMN', N'TripPassengerHotelVendorPreferenceKey'
GO
