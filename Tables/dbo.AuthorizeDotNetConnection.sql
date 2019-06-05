CREATE TABLE [dbo].[AuthorizeDotNetConnection]
(
[ConnectionId] [int] NOT NULL,
[UserId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[AuthorizeDotNetConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[AuthorizeDotNetConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[AuthorizeDotNetConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[AuthorizeDotNetConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[AuthorizeDotNetConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[AuthorizeDotNetConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[AuthorizeDotNetConnection] TO [dev]
GO
