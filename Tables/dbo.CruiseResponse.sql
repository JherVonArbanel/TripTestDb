CREATE TABLE [dbo].[CruiseResponse]
(
[CruiseResponseKey] [uniqueidentifier] NOT NULL,
[CruiseRequestKey] [int] NULL,
[CruiseLineCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SailingDepartureDate] [datetime] NOT NULL,
[SailingDuration] [int] NULL,
[ArrivalPort] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeparturePort] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoofPorts] [int] NULL,
[SailingStatusCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModeOfTransportation] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MOTCity] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyQualifier] [int] NULL,
[CurrencyISOCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CruiseVoyageNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CruiseRequestKey] ON [dbo].[CruiseResponse] ([CruiseRequestKey]) ON [PRIMARY]
GO
