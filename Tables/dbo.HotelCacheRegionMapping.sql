CREATE TABLE [dbo].[HotelCacheRegionMapping]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[HotelId] [int] NULL,
[RegionId] [int] NULL,
[RegionName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
