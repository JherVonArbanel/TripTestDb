CREATE TABLE [dbo].[SabreSession]
(
[SessionID] [int] NOT NULL IDENTITY(1, 1),
[ConnectionID] [int] NULL,
[Token] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastAccessDate] [datetime] NOT NULL,
[ConversationId] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AAAPCC] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SabreSession] ADD CONSTRAINT [PK_SabreSession] PRIMARY KEY CLUSTERED  ([SessionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ConnectionID] ON [dbo].[SabreSession] ([ConnectionID]) ON [PRIMARY]
GO
