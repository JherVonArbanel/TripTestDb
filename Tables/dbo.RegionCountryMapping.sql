CREATE TABLE [dbo].[RegionCountryMapping]
(
[Id] [int] NOT NULL,
[RegionId] [int] NOT NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RegionCountryMapping] ADD CONSTRAINT [PK_RegionCountryMapping] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
