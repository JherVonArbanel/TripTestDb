CREATE TABLE [dbo].[CruisePriceResponse]
(
[CruisePriceResponseKey] [uniqueidentifier] NOT NULL,
[CruiseCabinResponseKey] [uniqueidentifier] NOT NULL,
[AmountQualifierCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [float] NULL,
[PriceStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CruiseCabinResponseKey] ON [dbo].[CruisePriceResponse] ([CruiseCabinResponseKey]) ON [PRIMARY]
GO
