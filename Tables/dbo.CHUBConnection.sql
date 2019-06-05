CREATE TABLE [dbo].[CHUBConnection]
(
[ConnectionID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FunctionalID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CertificatePath] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CHUBConnection] ADD CONSTRAINT [PK_CHUBConnection] PRIMARY KEY CLUSTERED  ([ConnectionID]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[CHUBConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[CHUBConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[CHUBConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[CHUBConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[CHUBConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[CHUBConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[CHUBConnection] TO [dev]
GO
