CREATE TABLE [dbo].[AwardUpgradeRules]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[FromRegionId] [int] NOT NULL,
[ToRegionId] [int] NOT NULL,
[siteKey] [int] NOT NULL,
[RuleData] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AwardUpgradeRules] ADD CONSTRAINT [PK_AwardUpgradeRules] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
