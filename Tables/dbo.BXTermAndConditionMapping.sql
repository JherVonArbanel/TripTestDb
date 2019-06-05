CREATE TABLE [dbo].[BXTermAndConditionMapping]
(
[Id] [int] NOT NULL,
[AwardId] [int] NOT NULL,
[AwardCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[siteKey] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BXTermAndConditionMapping] ADD CONSTRAINT [PK_BXTermAndConditionMapping] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
