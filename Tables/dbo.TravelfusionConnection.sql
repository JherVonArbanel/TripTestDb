CREATE TABLE [dbo].[TravelfusionConnection]
(
[ConnectionId] [int] NOT NULL IDENTITY(1, 1),
[URL] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[XMLloginID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TravelfusionConnection] ADD CONSTRAINT [PK_TravelfusionConnection] PRIMARY KEY CLUSTERED  ([ConnectionId]) ON [PRIMARY]
GO
