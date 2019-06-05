CREATE TABLE [dbo].[HotelAutoCompleteForAddressSearch]
(
[SearchCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityKey] [int] NULL,
[CityName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Info] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortOrder] [int] NULL,
[Population] [int] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[StateName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayTextWithoutAirport] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
