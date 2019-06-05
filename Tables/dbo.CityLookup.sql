CREATE TABLE [dbo].[CityLookup]
(
[cityKey] [int] NOT NULL IDENTITY(1, 1),
[CityName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Info] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NOT NULL,
[Longitude] [float] NOT NULL,
[IsEnabled] [bit] NOT NULL,
[IataCityCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Preference] [int] NOT NULL,
[RegionID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirportName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CityLookup] ADD CONSTRAINT [PK_CityLookup] PRIMARY KEY CLUSTERED  ([cityKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CityName] ON [dbo].[CityLookup] ([CityName]) ON [PRIMARY]
GO
