CREATE TABLE [dbo].[AirportLookup]
(
[AirportKey] [int] NOT NULL IDENTITY(1, 1),
[AirportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AirportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CityCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Longitude] [float] NOT NULL,
[Latitude] [float] NOT NULL,
[TimeZoneCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDomestic] [bit] NOT NULL,
[Preference] [int] NOT NULL,
[AirPriority] [tinyint] NULL,
[AirStatus] [bit] NULL,
[GMT_offset] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DST_offset] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Time_zone_id] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zone] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryPriority] [int] NULL,
[IsUSDomestic] [bit] NULL,
[IsVisible] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__IsVis__6BC4D457] DEFAULT ((1)),
[CityId] [int] NULL,
[CityCenterLatitude] [float] NULL,
[CityCenterLongitude] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirportLookup] ADD CONSTRAINT [PK_AirportLookup] PRIMARY KEY NONCLUSTERED  ([AirportKey]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_AirportLookup_AirportCode] ON [dbo].[AirportLookup] ([AirportCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AirportCode] ON [dbo].[AirportLookup] ([AirportCode], [CityName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_COMP_AirportCode] ON [dbo].[AirportLookup] ([AirportCode], [CityName], [StateCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirportName] ON [dbo].[AirportLookup] ([AirportName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirStatus] ON [dbo].[AirportLookup] ([AirStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CityName] ON [dbo].[AirportLookup] ([CityName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_] ON [dbo].[AirportLookup] ([CountryCode]) INCLUDE ([AirportCode]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Airport Code.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'AirportCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Airport Name.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'AirportName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'City Code.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'CityCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'City Name.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'CityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Country Code.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'CountryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to indicate whether an airport is domestic or not.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'IsDomestic'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Latitude of Airport.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'Latitude'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Longitude of Airport.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'Longitude'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'Preference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'State Code.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'StateCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Time Zone of an airport.', 'SCHEMA', N'dbo', 'TABLE', N'AirportLookup', 'COLUMN', N'TimeZoneCode'
GO
