CREATE TABLE [dbo].[BXRulesOLD_20190102]
(
[Id] [int] NOT NULL,
[FromRegionId] [int] NOT NULL,
[ToRegionId] [int] NOT NULL,
[siteKey] [int] NOT NULL,
[RuleData] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
