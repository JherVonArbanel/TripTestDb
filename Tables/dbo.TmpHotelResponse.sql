CREATE TABLE [dbo].[TmpHotelResponse]
(
[HotelResponseKey] [uniqueidentifier] NULL,
[HotelRequestKey] [int] NULL,
[SupplierHotelKey] [int] NULL,
[supplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minRate] [float] NULL,
[minRateTax] [float] NULL,
[HotelsComType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferenceOrder] [int] NULL,
[HotelId] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CorporateCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rating] [float] NULL,
[RatingType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FareCategory] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[IsPromoTrue] [bit] NULL,
[PromoDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AverageBaseRate] [float] NULL,
[PromoId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EanBarRate] [float] NULL,
[TouricoCalculatedBarRate] [float] NULL,
[TouricoNetRate] [float] NULL,
[TouricoCostBasisRate] [float] NULL,
[CrowdRate] [float] NULL,
[RetailCrowdDiscountPrice] [float] NULL,
[MarketPlaceVariableId] [int] NULL,
[TouricoCostBasisCrowdRate] [float] NULL
) ON [PRIMARY]
GO
