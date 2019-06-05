CREATE TABLE [dbo].[TouricoConnection]
(
[connectionID] [int] NOT NULL,
[userName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[culture] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_connectionID] ON [dbo].[TouricoConnection] ([connectionID]) INCLUDE ([environment], [password], [userName]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[TouricoConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[TouricoConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[TouricoConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[TouricoConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[TouricoConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[TouricoConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[TouricoConnection] TO [dev]
GO
