CREATE TABLE [dbo].[AirportLookupNonCommercial]
(
[AirportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CityCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Longitude] [float] NULL,
[Latitude] [float] NULL,
[TimeZoneCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDomestic] [bit] NULL,
[Preference] [int] NULL,
[AirPriority] [tinyint] NULL,
[AirStatus] [bit] NULL,
[GMT_offset] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DST_offset] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Time_zone_id] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zone] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryPriority] [int] NULL
) ON [PRIMARY]
GO
