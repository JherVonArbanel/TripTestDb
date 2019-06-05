CREATE TABLE [dbo].[DestinationFinderData]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Origin] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CacheData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilteredCacheData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DestinationFinderData] ADD CONSTRAINT [PK_DestinationFinderData] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Origin_Boost] ON [dbo].[DestinationFinderData] ([Origin]) ON [PRIMARY]
GO
