CREATE TABLE [dbo].[AmadeusSessionLock]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[AmadeusConnectionKey] [int] NULL,
[Environment] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastQueryTime] [datetime] NULL
) ON [PRIMARY]
GO
