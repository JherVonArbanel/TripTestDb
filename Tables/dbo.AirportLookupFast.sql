CREATE TABLE [dbo].[AirportLookupFast]
(
[SearchCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirPriority] [bit] NULL,
[CityGroupKey] [int] NULL,
[CountryPriority] [bit] NULL,
[SortOrder] [int] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[StateName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
