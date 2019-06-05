CREATE TABLE [dbo].[TripAirPricesHistory]
(
[tripAirPriceKey] [int] NOT NULL,
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
[tripInfantWithSeatTax] [float] NULL
) ON [PRIMARY]
GO
