CREATE TABLE [dbo].[CityNeighboringAirportLookup]
(
[cityNeighboringAirportKey] [int] NOT NULL IDENTITY(1, 1),
[cityKey] [int] NULL,
[cityName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[latitude] [float] NULL,
[longitude] [float] NULL,
[distance] [float] NULL,
[airport] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CityNeighboringAirportLookup] ADD CONSTRAINT [PK_CityNeighboringAirportLookup] PRIMARY KEY CLUSTERED  ([cityNeighboringAirportKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CityKey] ON [dbo].[CityNeighboringAirportLookup] ([cityKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CityName] ON [dbo].[CityNeighboringAirportLookup] ([cityName]) ON [PRIMARY]
GO
