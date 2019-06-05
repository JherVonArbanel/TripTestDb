CREATE TABLE [dbo].[SabreRestSession]
(
[SessionID] [int] NOT NULL IDENTITY(1, 1),
[SessionToken] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SessionDate] [datetime] NOT NULL CONSTRAINT [DF_SabreRestSession_SessionDate] DEFAULT (getdate()),
[SessionExpDate] [datetime] NOT NULL CONSTRAINT [DF_SabreRestSession_SessionExpDate] DEFAULT (getdate()+(7)),
[UserUsing] [int] NOT NULL CONSTRAINT [DF_SabreRestSession_UsingNo] DEFAULT ((0)),
[isCert] [bit] NULL CONSTRAINT [DF_isCert] DEFAULT (N'0'),
[ConnectionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SabreRestSession] ADD CONSTRAINT [PK_SabreRestSession] PRIMARY KEY CLUSTERED  ([SessionID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_isCert] ON [dbo].[SabreRestSession] ([isCert], [SessionExpDate]) INCLUDE ([SessionToken]) ON [PRIMARY]
GO
