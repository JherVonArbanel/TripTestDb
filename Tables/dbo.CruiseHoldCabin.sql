CREATE TABLE [dbo].[CruiseHoldCabin]
(
[CruiseHoldCabinKey] [uniqueidentifier] NOT NULL,
[CruiseCabinResponseKey] [uniqueidentifier] NOT NULL,
[DiningLabel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiningStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsuranceCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CruiseCabreResponseKey] ON [dbo].[CruiseHoldCabin] ([CruiseCabinResponseKey]) ON [PRIMARY]
GO
