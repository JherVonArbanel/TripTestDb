CREATE TABLE [dbo].[AmadeusSession]
(
[pkID] [int] NOT NULL IDENTITY(1, 1),
[SessionID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecurityToken] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNumber] [int] NULL,
[CreationTime] [datetime] NULL,
[LastQueryTime] [datetime] NULL,
[SessionStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Environment] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedFrom] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNoOfTransactions] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amadeusConnectionKey] [int] NULL
) ON [PRIMARY]
GO
