CREATE TABLE [dbo].[NightlyDealProcess]
(
[NightlyDealProcessKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NULL,
[responseKey] [uniqueidentifier] NULL,
[componentType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currentPrice] [float] NULL,
[originalPrice] [float] NULL,
[fareCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseDetailKey] [uniqueidentifier] NULL,
[creationDate] [datetime] NULL CONSTRAINT [DF__NightlyDe__creat__23150941] DEFAULT (getdate()),
[dealSentDate] [datetime] NULL,
[processedDate] [datetime] NULL,
[isAlternate] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NightlyDealProcess] ADD CONSTRAINT [PK_NightlyDealProcess] PRIMARY KEY CLUSTERED  ([NightlyDealProcessKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NightlyDealProcess] ADD CONSTRAINT [FK_NightlyDealProcess_Trip] FOREIGN KEY ([tripKey]) REFERENCES [dbo].[Trip] ([tripKey])
GO
