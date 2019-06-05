CREATE TABLE [dbo].[HotelCacheAirportLookup]
(
[AirportKey] [int] NOT NULL IDENTITY(1, 1),
[AirportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AirportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDomestic] [bit] NOT NULL,
[CityPriority] [int] NULL,
[Day] [int] NULL
) ON [PRIMARY]
GO
