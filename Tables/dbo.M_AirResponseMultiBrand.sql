CREATE TABLE [dbo].[M_AirResponseMultiBrand]
(
[airResponseMultiBrandKey] [uniqueidentifier] NOT NULL,
[airResponseKey] [uniqueidentifier] NOT NULL,
[airSubRequestKey] [int] NOT NULL,
[airPriceBase] [float] NULL,
[airPriceTax] [float] NULL,
[gdsSourceKey] [int] NULL,
[refundable] [bit] NULL,
[airClass] [varbinary] (50) NULL,
[priceClassComments] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airPriceClassSelected] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cabinClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fareType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isGeneratedBundle] [bit] NULL,
[ValidatingCarrier] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contractCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airPriceBaseSenior] [float] NULL,
[airPriceTaxSenior] [float] NULL,
[airPriceBaseChildren] [float] NULL,
[airPriceTaxChildren] [float] NULL,
[airPriceBaseInfant] [float] NULL,
[airPriceTaxInfant] [float] NULL,
[airPriceBaseDisplay] [float] NULL,
[airPriceTaxDisplay] [float] NULL,
[airPriceBaseTotal] [float] NULL,
[airPriceTaxTotal] [float] NULL,
[airPriceBaseYouth] [float] NULL,
[airPriceTaxYouth] [float] NULL,
[airCurrencyCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airPriceBaseInfantWithSeat] [float] NULL,
[airPriceTaxInfantWithSeat] [float] NULL,
[ticketDesignator] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[awardCode] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Points] [int] NULL,
[ITAItineraryId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isAvailable] [bit] NULL,
[isReturnFare] [bit] NULL,
CONSTRAINT [PK_AirSegments_11] PRIMARY KEY NONCLUSTERED  ([airResponseMultiBrandKey])
)
WITH
(
MEMORY_OPTIMIZED = ON,
DURABILITY = SCHEMA_ONLY
)
GO
