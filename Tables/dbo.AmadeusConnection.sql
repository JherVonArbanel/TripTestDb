CREATE TABLE [dbo].[AmadeusConnection]
(
[pkID] [int] NOT NULL IDENTITY(1, 1),
[amadeusConnectionKey] [int] NOT NULL,
[Environment] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrganizationID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginatorTypeCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceIdentifier] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceQualifier] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PasswordLength] [int] NULL,
[PasswordDataType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinimumSession] [int] NULL,
[MaximumSession] [int] NULL,
[DefaultSessionTimeOut] [int] NULL,
[ActualSessionTimeOut] [int] NULL,
[NumberOfAttempt] [int] NULL,
[DefaultResponseTimeOut] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActualResponseTimeOut] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinSequenceNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxSequenceNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LockingTimeOut] [int] NULL,
[IsSessionLockEnabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AmadeusConnection] ADD CONSTRAINT [PK__AmadeusC__40A359E311D4A34F] PRIMARY KEY CLUSTERED  ([pkID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AmadeusConnection] ADD CONSTRAINT [UQ__AmadeusC__D21CF11414B10FFA] UNIQUE NONCLUSTERED  ([amadeusConnectionKey]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[AmadeusConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[AmadeusConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[AmadeusConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[AmadeusConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[AmadeusConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[AmadeusConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[AmadeusConnection] TO [dev]
GO
