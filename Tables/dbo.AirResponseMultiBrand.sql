CREATE TABLE [dbo].[AirResponseMultiBrand]
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
[isReturnFare] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airResponseKey] ON [dbo].[AirResponseMultiBrand] ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airResponseMultiBrandKey] ON [dbo].[AirResponseMultiBrand] ([airResponseMultiBrandKey]) INCLUDE ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airSubRequestKey] ON [dbo].[AirResponseMultiBrand] ([airSubRequestKey]) INCLUDE ([airPriceBase], [airPriceBaseChildren], [airPriceBaseDisplay], [airPriceBaseInfant], [airPriceBaseInfantWithSeat], [airPriceBaseSenior], [airPriceBaseTotal], [airPriceBaseYouth], [airPriceTax], [airPriceTaxChildren], [airPriceTaxDisplay], [airPriceTaxInfant], [airPriceTaxInfantWithSeat], [airPriceTaxSenior], [airPriceTaxTotal], [airPriceTaxYouth], [airResponseKey], [airResponseMultiBrandKey], [gdsSourceKey], [refundable]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AirSubRequestKey] ON [dbo].[AirResponseMultiBrand] ([airSubRequestKey]) INCLUDE ([airClass], [airCurrencyCode], [airPriceBase], [airPriceBaseChildren], [airPriceBaseDisplay], [airPriceBaseInfant], [airPriceBaseInfantWithSeat], [airPriceBaseSenior], [airPriceBaseTotal], [airPriceBaseYouth], [airPriceClassSelected], [airPriceTax], [airPriceTaxChildren], [airPriceTaxDisplay], [airPriceTaxInfant], [airPriceTaxInfantWithSeat], [airPriceTaxSenior], [airPriceTaxTotal], [airPriceTaxYouth], [airResponseKey], [airResponseMultiBrandKey], [awardCode], [cabinClass], [contractCode], [fareType], [gdsSourceKey], [isAvailable], [isGeneratedBundle], [isReturnFare], [ITAItineraryId], [Points], [priceClassComments], [refundable], [ticketDesignator], [ValidatingCarrier]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airSubRequestKey_refundable_ResponseMultiBrandKeyAndOther] ON [dbo].[AirResponseMultiBrand] ([airSubRequestKey], [refundable]) INCLUDE ([airPriceBase], [airPriceBaseChildren], [airPriceBaseDisplay], [airPriceBaseInfant], [airPriceBaseInfantWithSeat], [airPriceBaseSenior], [airPriceBaseTotal], [airPriceBaseYouth], [airPriceTax], [airPriceTaxChildren], [airPriceTaxDisplay], [airPriceTaxInfant], [airPriceTaxInfantWithSeat], [airPriceTaxSenior], [airPriceTaxTotal], [airPriceTaxYouth], [airResponseKey], [airResponseMultiBrandKey], [gdsSourceKey]) ON [PRIMARY]
GO
