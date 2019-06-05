CREATE TABLE [dbo].[sessionLock]
(
[SessionLockID] [int] NOT NULL IDENTITY(1, 1),
[IsSessionLock] [bit] NULL CONSTRAINT [DF__sessionLo__IsSes__7E37BEF6] DEFAULT ((1)),
[ConnectionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sessionLock] ADD CONSTRAINT [PK_SessionLock] PRIMARY KEY CLUSTERED  ([SessionLockID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ConnectionID] ON [dbo].[sessionLock] ([ConnectionID]) ON [PRIMARY]
GO
