CREATE TABLE [dbo].[ViatorConnection]
(
[ConnectionId] [int] NOT NULL,
[URL] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[ViatorConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[ViatorConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[ViatorConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[ViatorConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[ViatorConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[ViatorConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[ViatorConnection] TO [dev]
GO
