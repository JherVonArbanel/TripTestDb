CREATE TABLE [dbo].[NavitaireConnection]
(
[ConnectionID] [int] NOT NULL IDENTITY(1, 1),
[DomainCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgentName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractVersion] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NavitaireConnection] ADD CONSTRAINT [PK_NavitaireConnection] PRIMARY KEY CLUSTERED  ([ConnectionID]) ON [PRIMARY]
GO
