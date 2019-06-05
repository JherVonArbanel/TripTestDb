CREATE TABLE [dbo].[CarResponseDetail]
(
[carResponseDetailKey] [uniqueidentifier] NOT NULL,
[carResponseKey] [uniqueidentifier] NULL,
[carVendorKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carLocationCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carLocationCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minRate] [float] NULL,
[minRateTax] [float] NULL,
[NoOfDays] [int] NULL,
[RateQualifier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceDateTime] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MileageAllowance] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RatePlan] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GuaranteeCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellGuaranteeReq] [bit] NULL,
[contractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CarRespon__contr__5E94F66B] DEFAULT (NULL),
[rateTypeCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carRules] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inTerminal] [bit] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [Idx_carResponseDetailKey] ON [dbo].[CarResponseDetail] ([carResponseDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_carResponseKey] ON [dbo].[CarResponseDetail] ([carResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_carResponseKey] ON [dbo].[CarResponseDetail] ([carResponseKey]) INCLUDE ([carVendorKey], [minRate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SupplierID] ON [dbo].[CarResponseDetail] ([supplierId]) ON [PRIMARY]
GO
