CREATE TABLE [dbo].[Trip_CruiseResponse]
(
[tripKey] [int] NOT NULL,
[CruiseResponseKey] [uniqueidentifier] NOT NULL,
[confirmationNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripCruiseTotalPrice] [float] NULL,
[CruiseLineCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SailingDepartureDate] [datetime] NOT NULL,
[SailingDuration] [int] NULL,
[ArrivalPort] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeparturePort] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[berthedCategory] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipLocation] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cabinNbr] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deckId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
