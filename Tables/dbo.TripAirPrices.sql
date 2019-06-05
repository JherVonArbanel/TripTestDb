CREATE TABLE [dbo].[TripAirPrices]
(
[tripAirPriceKey] [int] NOT NULL IDENTITY(1, 1),
[tripAdultBase] [float] NULL,
[tripAdultTax] [float] NULL,
[tripSeniorBase] [float] NULL,
[tripSeniorTax] [float] NULL,
[tripYouthBase] [float] NULL,
[tripYouthTax] [float] NULL,
[tripChildBase] [float] NULL,
[tripChildTax] [float] NULL,
[tripInfantBase] [float] NULL,
[tripInfantTax] [float] NULL,
[creationDate] [datetime] NULL,
[tripInfantWithSeatBase] [float] NULL,
[tripInfantWithSeatTax] [float] NULL,
[ValidatingCarriers] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewBookingClasses] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TickettingEntryCount] [int] NULL,
[RepricedEntries] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cabinClass] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isCabinReprice] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirPrices] ADD CONSTRAINT [PK_TripAirPrices] PRIMARY KEY CLUSTERED  ([tripAirPriceKey]) ON [PRIMARY]
GO
