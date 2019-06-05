CREATE TABLE [dbo].[CarPriorityByClass]
(
[CarPriority] [int] NOT NULL,
[CarClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarClassShortName] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarPriorityByClass] ADD CONSTRAINT [PK__CarPrior__E49B43043AE1A5DA] PRIMARY KEY CLUSTERED  ([CarPriority]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarPriorityByClass] ADD CONSTRAINT [UQ__CarPrior__2132D9F33DBE1285] UNIQUE NONCLUSTERED  ([CarClassShortName]) ON [PRIMARY]
GO
