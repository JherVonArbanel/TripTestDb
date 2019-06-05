CREATE TABLE [dbo].[TripPassengerCarVendorPreference]
(
[TripPassengerCarVendorPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[ID] [int] NULL,
[CarVendorCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarVendorName] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferenceNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__0F624AF8] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerCarVendorPreference] ADD CONSTRAINT [PK__TripPass__7696E28D5165187F] PRIMARY KEY CLUSTERED  ([TripPassengerCarVendorPreferenceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarVendorPreference', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Car Vendor Code.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarVendorPreference', 'COLUMN', N'CarVendorCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Car Vendor Name.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarVendorPreference', 'COLUMN', N'CarVendorName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger Key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarVendorPreference', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarVendorPreference', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerCarVendorPreference table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCarVendorPreference', 'COLUMN', N'TripPassengerCarVendorPreferenceKey'
GO
