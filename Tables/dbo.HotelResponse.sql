CREATE TABLE [dbo].[HotelResponse]
(
[hotelResponseKey] [uniqueidentifier] NOT NULL,
[hotelRequestKey] [int] NOT NULL,
[supplierHotelKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minRate] [float] NOT NULL,
[minRateTax] [float] NULL CONSTRAINT [DF_HotelResponse_minRateTax] DEFAULT ((0)),
[hotelsComType] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preferenceOrder] [int] NULL CONSTRAINT [DF__tmp_ms_xx__prefe__6F95653B] DEFAULT ((1)),
[corporateCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orignalMinRate] [float] NULL,
[tripAdvisorRating] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripAdvisorRatingUrl] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripAdvisorReviewCount] [int] NULL,
[cityCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hotelId] [int] NULL,
[lowRate] [float] NULL,
[highRate] [float] NULL,
[isPromoTrue] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__isPro__70898974] DEFAULT ((0)),
[promoId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promoDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[averageBaseRate] [float] NULL CONSTRAINT [DF__tmp_ms_xx__avera__717DADAD] DEFAULT ((0)),
[eanBarRate] [float] NULL,
[touricoCalculatedBarRate] [float] NULL,
[touricoCostBasisRate] [float] NULL,
[marketPlaceVariableId] [int] NULL,
[touricoNetRate] [float] NULL,
[isNonRefundable] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__isNon__7271D1E6] DEFAULT ((1)),
[proximityDistance] [float] NULL,
[proximityUnit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hasGovRate] [bit] NULL,
[CompanyContractApplied] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChainCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isAvgRateUpdated] [bit] NULL,
[imageUrl] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[atMerchant] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HotelResponse] ADD CONSTRAINT [PK_HotelResponse] PRIMARY KEY CLUSTERED  ([hotelResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HotelID] ON [dbo].[HotelResponse] ([hotelId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_hotelRequestKey] ON [dbo].[HotelResponse] ([hotelRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_HotelResponse_ReqKey_HotelId] ON [dbo].[HotelResponse] ([hotelRequestKey], [hotelId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_hotelRequestKey] ON [dbo].[HotelResponse] ([hotelRequestKey], [hotelId], [supplierId]) INCLUDE ([minRate], [minRateTax]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MinRate] ON [dbo].[HotelResponse] ([hotelRequestKey], [minRate], [hotelId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_hotelRequestKey_bulk] ON [dbo].[HotelResponse] ([hotelRequestKey], [minRate], [isAvgRateUpdated]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_supplierHotelKey] ON [dbo].[HotelResponse] ([hotelRequestKey], [supplierHotelKey], [supplierId]) INCLUDE ([hotelId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SupplierID] ON [dbo].[HotelResponse] ([supplierId], [supplierHotelKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HotelResponse] ON [dbo].[HotelResponse] ([supplierId], [supplierHotelKey], [hotelRequestKey]) ON [PRIMARY]
GO
