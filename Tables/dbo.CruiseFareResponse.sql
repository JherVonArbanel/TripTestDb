CREATE TABLE [dbo].[CruiseFareResponse]
(
[CruiseFareResponseKey] [uniqueidentifier] NOT NULL,
[CruiseResponseKey] [uniqueidentifier] NULL,
[FareCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FareDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remark] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModeOfTransportation] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MOTCity] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiningLabel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiningStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyQualifier] [int] NULL,
[CurrencyISOCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CruiseResponseKey] ON [dbo].[CruiseFareResponse] ([CruiseResponseKey]) ON [PRIMARY]
GO
