CREATE TABLE [dbo].[AirResponse]
(
[airResponseKey] [uniqueidentifier] NOT NULL,
[airSubRequestKey] [int] NOT NULL,
[airPriceBase] [float] NULL,
[airPriceTax] [float] NULL CONSTRAINT [DF_AirResponse_airPriceTax_New] DEFAULT ((0)),
[gdsSourceKey] [int] NULL,
[refundable] [bit] NULL,
[airClass] [varbinary] (50) NULL,
[priceClassCommentsSuperSaver] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priceClassCommentsEconSaver] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priceClassCommentsFirstFlex] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priceClassCommentsCorporate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priceClassCommentsEconFlex] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priceClassCommentsEconUpgrade] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSuperSaverPrice] [float] NULL,
[airEconSaverPrice] [float] NULL,
[airFirstFlexPrice] [float] NULL,
[airCorporatePrice] [float] NULL,
[airEconFlexPrice] [float] NULL,
[airEconUpgradePrice] [float] NULL,
[airClassSuperSaver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airClassEconSaver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airClassFirstFlex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airClassCorporate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airClassEconFlex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airClassEconUpgrade] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSuperSaverSeatRemaining] [int] NULL,
[airEconSaverSeatRemaining] [int] NULL,
[airFirstFlexSeatRemaining] [int] NULL,
[airCorporateSeatRemaining] [int] NULL,
[airEconFlexSeatRemaining] [int] NULL,
[airEconUpgradeSeatRemaining] [int] NULL,
[airSuperSaverFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconSaverFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airFirstFlexFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airCorporateFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconFlexFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconUpgradeFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airPriceClassSelected] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSuperSaverTax] [float] NULL,
[airEconSaverTax] [float] NULL,
[airEconFlexTax] [float] NULL,
[airCorporateTax] [float] NULL,
[airEconUpgradetax] [float] NULL,
[airFirstFlexTax] [float] NULL,
[airSuperSaverFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconSaverFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airFirstFlexFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airCorporateFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconFlexFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconUpgradeFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isBrandedFare] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__isBra__009FF5AC] DEFAULT ((0)),
[cabinClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fareType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isGeneratedBundle] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__isGen__019419E5] DEFAULT ((0)),
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
[airResponseId] [bigint] NOT NULL IDENTITY(1, 1),
[airPriceBaseInfantWithSeat] [float] NULL,
[airPriceTaxInfantWithSeat] [float] NULL,
[agentwareQueryID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[agentwareItineraryID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Points] [int] NULL,
[ticketDesignator] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[awardCode] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ITAQueryId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ITAItineraryId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isAvailable] [bit] NULL,
[isReturnFare] [bit] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_AirResponse] ON [dbo].[AirResponse] ([airResponseId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CMP_airResponseKey] ON [dbo].[AirResponse] ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_agentwareQueryID] ON [dbo].[AirResponse] ([airResponseKey]) INCLUDE ([agentwareItineraryID], [agentwareQueryID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_COMP_airResponseKey] ON [dbo].[AirResponse] ([airResponseKey]) INCLUDE ([airClassCorporate], [airClassEconFlex], [airClassEconSaver], [airClassEconUpgrade], [airClassFirstFlex], [airClassSuperSaver], [airCorporatePrice], [airCorporateSeatRemaining], [airEconFlexPrice], [airEconFlexSeatRemaining], [airEconSaverPrice], [airEconSaverSeatRemaining], [airEconUpgradePrice], [airEconUpgradeSeatRemaining], [airFirstFlexPrice], [airFirstFlexSeatRemaining], [airPriceBaseChildren], [airPriceBaseDisplay], [airPriceBaseInfant], [airPriceBaseInfantWithSeat], [airPriceBaseSenior], [airPriceBaseTotal], [airPriceClassSelected], [airPriceTaxChildren], [airPriceTaxDisplay], [airPriceTaxInfant], [airPriceTaxInfantWithSeat], [airPriceTaxSenior], [airPriceTaxTotal], [airSuperSaverPrice], [airSuperSaverSeatRemaining], [fareType], [isBrandedFare], [isGeneratedBundle], [priceClassCommentsCorporate], [priceClassCommentsEconFlex], [priceClassCommentsEconSaver], [priceClassCommentsEconUpgrade], [priceClassCommentsFirstFlex], [priceClassCommentsSuperSaver], [refundable]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airPriceBaseTotal] ON [dbo].[AirResponse] ([airResponseKey]) INCLUDE ([airPriceBaseTotal], [airPriceTaxTotal]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_gdsSourceKey] ON [dbo].[AirResponse] ([airResponseKey]) INCLUDE ([gdsSourceKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airSubRequestKey] ON [dbo].[AirResponse] ([airSubRequestKey]) INCLUDE ([airPriceBase], [airPriceBaseChildren], [airPriceBaseDisplay], [airPriceBaseInfant], [airPriceBaseInfantWithSeat], [airPriceBaseSenior], [airPriceBaseTotal], [airPriceBaseYouth], [airPriceTax], [airPriceTaxChildren], [airPriceTaxDisplay], [airPriceTaxInfant], [airPriceTaxInfantWithSeat], [airPriceTaxSenior], [airPriceTaxTotal], [airPriceTaxYouth], [airResponseKey], [gdsSourceKey], [refundable]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airSubRequestKey_airResponseKeyAndOther] ON [dbo].[AirResponse] ([airSubRequestKey]) INCLUDE ([agentwareItineraryID], [agentwareQueryID], [airPriceBase], [airPriceBaseChildren], [airPriceBaseDisplay], [airPriceBaseInfant], [airPriceBaseInfantWithSeat], [airPriceBaseSenior], [airPriceBaseTotal], [airPriceBaseYouth], [airPriceTax], [airPriceTaxChildren], [airPriceTaxDisplay], [airPriceTaxInfant], [airPriceTaxInfantWithSeat], [airPriceTaxSenior], [airPriceTaxTotal], [airPriceTaxYouth], [airResponseKey], [gdsSourceKey], [refundable]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AirSubrequestKey] ON [dbo].[AirResponse] ([airSubRequestKey]) INCLUDE ([agentwareItineraryID], [agentwareQueryID], [airClass], [airClassCorporate], [airClassEconFlex], [airClassEconSaver], [airClassEconUpgrade], [airClassFirstFlex], [airClassSuperSaver], [airCorporateFareBasisCode], [airCorporateFareReferenceKey], [airCorporatePrice], [airCorporateSeatRemaining], [airCorporateTax], [airCurrencyCode], [airEconFlexFareBasisCode], [airEconFlexFareReferenceKey], [airEconFlexPrice], [airEconFlexSeatRemaining], [airEconFlexTax], [airEconSaverFareBasisCode], [airEconSaverFareReferenceKey], [airEconSaverPrice], [airEconSaverSeatRemaining], [airEconSaverTax], [airEconUpgradeFareBasisCode], [airEconUpgradeFareReferenceKey], [airEconUpgradePrice], [airEconUpgradeSeatRemaining], [airEconUpgradetax], [airFirstFlexFareBasisCode], [airFirstFlexFareReferenceKey], [airFirstFlexPrice], [airFirstFlexSeatRemaining], [airFirstFlexTax], [airPriceBase], [airPriceBaseChildren], [airPriceBaseDisplay], [airPriceBaseInfant], [airPriceBaseInfantWithSeat], [airPriceBaseSenior], [airPriceBaseTotal], [airPriceBaseYouth], [airPriceClassSelected], [airPriceTax], [airPriceTaxChildren], [airPriceTaxDisplay], [airPriceTaxInfant], [airPriceTaxInfantWithSeat], [airPriceTaxSenior], [airPriceTaxTotal], [airPriceTaxYouth], [airResponseId], [airResponseKey], [airSuperSaverFareBasisCode], [airSuperSaverFareReferenceKey], [airSuperSaverPrice], [airSuperSaverSeatRemaining], [airSuperSaverTax], [awardCode], [cabinClass], [contractCode], [fareType], [gdsSourceKey], [isAvailable], [isBrandedFare], [isGeneratedBundle], [isReturnFare], [ITAItineraryId], [ITAQueryId], [Points], [priceClassCommentsCorporate], [priceClassCommentsEconFlex], [priceClassCommentsEconSaver], [priceClassCommentsEconUpgrade], [priceClassCommentsFirstFlex], [priceClassCommentsSuperSaver], [refundable], [ticketDesignator], [ValidatingCarrier]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference to AirSubRequest table(airSubRequestKey).', 'SCHEMA', N'dbo', 'TABLE', N'AirResponse', 'COLUMN', N'airSubRequestKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicator about "Is Refundable?".', 'SCHEMA', N'dbo', 'TABLE', N'AirResponse', 'COLUMN', N'refundable'
GO
