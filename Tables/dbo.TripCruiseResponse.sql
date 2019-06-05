CREATE TABLE [dbo].[TripCruiseResponse]
(
[CruiseResponseKey] [uniqueidentifier] NOT NULL,
[tripKey] [int] NOT NULL,
[tripGUIDKey] [uniqueidentifier] NULL,
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
[deckId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [int] NULL
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'GUID Key for introducing TripSaved/TripPurchased tables which both can store cart data in this table', 'SCHEMA', N'dbo', 'TABLE', N'TripCruiseResponse', 'COLUMN', N'tripGUIDKey'
GO
