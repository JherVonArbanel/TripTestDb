CREATE TABLE [dbo].[HotelCacheData]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Origin] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CacheData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilteredCacheData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LowestPriceCacheData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LowestPrice] [float] NULL,
[Month] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AvgSaving] [float] NULL CONSTRAINT [DF__HotelCach__AvgSa__77A09B57] DEFAULT ((0))
) ON [PRIMARY]
GO
