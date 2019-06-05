CREATE TABLE [dbo].[HotelResponseSabreAvgRateCall]
(
[hotelResponseKey] [uniqueidentifier] NOT NULL,
[hotelRequestKey] [int] NOT NULL,
[supplierHotelKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minRate] [float] NOT NULL,
[minRateTax] [float] NULL CONSTRAINT [DF_HotelResponseSabreAvgRateCall_minRateTax] DEFAULT ((0)),
[hotelsComType] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preferenceOrder] [int] NULL CONSTRAINT [DF__HotelResponseSabreAvgRateCall__prefe__703EA55A] DEFAULT ((1)),
[corporateCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orignalMinRate] [float] NULL,
[tripAdvisorRating] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripAdvisorRatingUrl] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripAdvisorReviewCount] [int] NULL,
[cityCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hotelId] [int] NULL,
[lowRate] [float] NULL,
[highRate] [float] NULL,
[isPromoTrue] [bit] NULL CONSTRAINT [DF__HotelResponseSabreAvgRateCall__isPro__57B3BA09] DEFAULT ((0)),
[promoDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[averageBaseRate] [float] NULL CONSTRAINT [DF__HotelResponseSabreAvgRateCall__avera__58A7DE42] DEFAULT ((0)),
[promoId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eanBarRate] [float] NULL,
[touricoCalculatedBarRate] [float] NULL,
[touricoNetRate] [float] NULL,
[touricoCostBasisRate] [float] NULL,
[marketPlaceVariableId] [int] NULL,
[isNonRefundable] [bit] NULL CONSTRAINT [DF__HotelResponseSabreAvgRateCall__isRef__361DBC14] DEFAULT ((1)),
[proximityDistance] [float] NULL,
[proximityUnit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hasGovRate] [bit] NULL,
[CompanyContractApplied] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChainCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HotelResponseSabreAvgRateCall] ADD CONSTRAINT [PK_HotelResponseAvgRateCall] PRIMARY KEY CLUSTERED  ([hotelResponseKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
