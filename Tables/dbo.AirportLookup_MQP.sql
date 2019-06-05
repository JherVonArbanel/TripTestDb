CREATE TABLE [dbo].[AirportLookup_MQP]
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
[CountryPriority] [int] NULL
) ON [PRIMARY]
GO
