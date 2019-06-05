CREATE TABLE [dbo].[AAPartnerConnection]
(
[ConnectionID] [int] NOT NULL IDENTITY(1, 1),
[UserName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPCC] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Domain] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromPartyID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToPartyID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Organization] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Environment] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CertificatePath] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConversationID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthorizationHeaderUserName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthorizationHeaderPassword] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_UserName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_Password] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_ClientID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_CertificatePath] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_sabreHostPartition] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_EncryptionKeyName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentCertificatePath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_InterfaceID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Book_sabreHostPartition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AAPartnerConnection] ADD CONSTRAINT [PK__AAPartne__404A64F33A6DDDED] PRIMARY KEY CLUSTERED  ([ConnectionID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[AAPartnerConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[AAPartnerConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[AAPartnerConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[AAPartnerConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[AAPartnerConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[AAPartnerConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[AAPartnerConnection] TO [dev]
GO
