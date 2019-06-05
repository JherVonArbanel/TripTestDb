CREATE TABLE [dbo].[CarPriority]
(
[CarPrioritySequence] [int] NULL,
[CarClass] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarPriority] ADD CONSTRAINT [UQ__CarPrior__C440994263F8CA06] UNIQUE NONCLUSTERED  ([CarPrioritySequence]) ON [PRIMARY]
GO
