CREATE TABLE [dbo].[BXRules_New]
(
[Id] [int] NOT NULL,
[FromRegionId] [int] NOT NULL,
[ToRegionId] [int] NOT NULL,
[siteKey] [int] NOT NULL,
[RuleData] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BXRules_New] ADD CONSTRAINT [PK_BXRules] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
