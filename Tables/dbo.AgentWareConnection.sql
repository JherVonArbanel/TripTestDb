CREATE TABLE [dbo].[AgentWareConnection]
(
[ConnectionId] [int] NOT NULL,
[URL] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ConnectionId] ON [dbo].[AgentWareConnection] ([ConnectionId]) INCLUDE ([Environment], [Password], [URL], [UserId]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[AgentWareConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[AgentWareConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[AgentWareConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[AgentWareConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[AgentWareConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[AgentWareConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[AgentWareConnection] TO [dev]
GO
