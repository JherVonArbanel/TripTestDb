CREATE TABLE [dbo].[CarCacheData]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Origin] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CacheData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
