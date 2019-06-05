CREATE TABLE [dbo].[QueuePNRHistory]
(
[QueuePNRHistoryKey] [int] NOT NULL IDENTITY(1, 1),
[LastAccessDatetime] [datetime] NULL,
[FirstRecordLocator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstRecordLocatorPosition] [smallint] NOT NULL,
[LastRecordLocator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastRecordLocatorPosition] [smallint] NOT NULL,
[QueueKey] [int] NOT NULL,
[Active] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QueuePNRHistory] ADD CONSTRAINT [PK__QueuePNR__BADC222D43E1002F] PRIMARY KEY CLUSTERED  ([QueuePNRHistoryKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QueuePNRHistory] WITH NOCHECK ADD CONSTRAINT [FK__QueuePNRH__Queue__7FF5EA36] FOREIGN KEY ([QueueKey]) REFERENCES [dbo].[QueueInfo] ([QueueKey])
GO
