CREATE TABLE [dbo].[TripCoworker]
(
[CoworkerKey] [int] NOT NULL IDENTITY(1, 1),
[TripPassengerInfoKey] [int] NULL,
[FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSendMail] [bit] NULL,
[UserKey] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripCoworker] ADD CONSTRAINT [PK__TripCowo__D3D6822291E124FE] PRIMARY KEY CLUSTERED  ([CoworkerKey]) ON [PRIMARY]
GO
