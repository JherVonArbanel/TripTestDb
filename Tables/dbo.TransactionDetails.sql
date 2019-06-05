CREATE TABLE [dbo].[TransactionDetails]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[Amount] [decimal] (10, 2) NOT NULL,
[TransactionId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TripId] [int] NOT NULL,
[PaymentApproved] [bit] NOT NULL,
[ResponseMessage] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDateTime] [datetime] NOT NULL,
[SiteKey] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransactionDetails] ADD CONSTRAINT [PK_TransactionDetails1] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
