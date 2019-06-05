CREATE TABLE [dbo].[RegionLookup]
(
[Id] [int] NOT NULL,
[RegionName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RegionDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Exclusion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RegionLookup] ADD CONSTRAINT [PK_RegionLookup] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
