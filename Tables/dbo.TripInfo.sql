CREATE TABLE [dbo].[TripInfo]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[ResendEmailWithPrice_ToEmailAddress] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResendEmailWithoutPrice_ToEmailAddress] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResendEmailWithPrice_SentBy] [bigint] NULL,
[ResendEmailWithPrice_SentOn] [datetime] NULL,
[ResendEmailWithOutPrice_SentBy] [bigint] NULL,
[ResendEmailWithOutPrice_SentOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripInfo] ADD CONSTRAINT [PK_TripInfo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
