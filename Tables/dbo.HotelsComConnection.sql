CREATE TABLE [dbo].[HotelsComConnection]
(
[connectionID] [int] NOT NULL,
[cid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apiKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sig] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[test] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_connectionID] ON [dbo].[HotelsComConnection] ([connectionID]) INCLUDE ([apiKey], [cid], [sig]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_connectionID] ON [dbo].[HotelsComConnection] ([connectionID]) INCLUDE ([apiKey], [cid], [environment], [sig], [test]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[HotelsComConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[HotelsComConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[HotelsComConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[HotelsComConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[HotelsComConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[HotelsComConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[HotelsComConnection] TO [dev]
GO
