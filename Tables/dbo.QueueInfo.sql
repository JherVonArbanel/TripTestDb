CREATE TABLE [dbo].[QueueInfo]
(
[QueueKey] [int] NOT NULL IDENTITY(1, 1),
[QueueNumber] [smallint] NOT NULL,
[QueueDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GDSkey] [smallint] NOT NULL,
[PCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL,
[IsTravelFocus] [bit] NULL,
[siteKey] [int] NULL CONSTRAINT [DF__QueueInfo__siteK__4A8DFDBE] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QueueInfo] ADD CONSTRAINT [PK__QueueInf__2906501D48A5B54C] PRIMARY KEY CLUSTERED  ([QueueKey]) ON [PRIMARY]
GO
