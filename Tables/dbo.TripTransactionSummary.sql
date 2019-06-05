CREATE TABLE [dbo].[TripTransactionSummary]
(
[TripTransactionSummaryKey] [int] NOT NULL IDENTITY(1, 1),
[tripRequestKey] [int] NOT NULL,
[tripKey] [int] NULL,
[tripCreated] [datetime] NOT NULL CONSTRAINT [default_tripCreated] DEFAULT (getdate()),
[tripStatus] [bit] NULL CONSTRAINT [DF__TripTrans__tripS__72F0F4D3] DEFAULT ('0'),
[ReasonforFailure] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
