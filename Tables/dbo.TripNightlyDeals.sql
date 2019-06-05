CREATE TABLE [dbo].[TripNightlyDeals]
(
[tripNightlyDealKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[ResponseKey] [uniqueidentifier] NULL,
[Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripNightlyDeals] ADD CONSTRAINT [PK__TripNigh__6681D85C1590259A] PRIMARY KEY CLUSTERED  ([tripNightlyDealKey]) ON [PRIMARY]
GO
