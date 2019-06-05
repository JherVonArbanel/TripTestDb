CREATE TABLE [dbo].[AwardUpgradeValidatorDetails]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[RecordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValidatorData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SiteKey] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AwardUpgradeValidatorDetails] ADD CONSTRAINT [PK__AwardUpg__3214EC071E3DFCF0] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
