CREATE TABLE [dbo].[RegionAirportGroup]
(
[AirportCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Grouping] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupNumber] [int] NULL,
[AvgSaving] [float] NULL CONSTRAINT [DF__RegionAir__AvgSa__0BA79404] DEFAULT ((0)),
[CrowdCount] [int] NULL CONSTRAINT [DF__RegionAir__Crowd__0C9BB83D] DEFAULT ((0)),
[ImageUrl] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__RegionAir__Image__0D8FDC76] DEFAULT (NULL)
) ON [PRIMARY]
GO
