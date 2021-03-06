CREATE TABLE [dbo].[TripHotelResponse]
(
[TripHotelResponseKey] [int] NOT NULL IDENTITY(1, 1),
[hotelResponseKey] [uniqueidentifier] NOT NULL,
[supplierHotelKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tripKey] [int] NULL,
[tripGUIDKey] [uniqueidentifier] NULL,
[supplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minRate] [float] NOT NULL,
[minRateTax] [float] NOT NULL CONSTRAINT [DF__TripHotel__minRa__5165187F] DEFAULT ((0)),
[hotelDailyPrice] [float] NOT NULL,
[hotelDescription] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hotelRatePlanCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hotelTotalPrice] [float] NULL,
[hotelPriceType] [int] NULL,
[hotelTaxRate] [float] NULL CONSTRAINT [DF__TripHotel__hotel__52593CB8] DEFAULT ((0)),
[rateDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[guaranteeCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SearchHotelPrice] [float] NOT NULL,
[searchHotelTax] [float] NULL CONSTRAINT [DF__TripHotel__searc__534D60F1] DEFAULT ((0)),
[actualHotelPrice] [float] NULL,
[actualHotelTax] [float] NULL CONSTRAINT [DF__TripHotel__actua__5441852A] DEFAULT ((0)),
[checkInDate] [datetime] NULL,
[checkOutDate] [datetime] NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmationNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCodeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PolicyReasonCodeID] [int] NULL,
[HotelPolicyKey] [int] NULL,
[PolicyResaonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isExpenseAdded] [bit] NULL CONSTRAINT [DF__TripHotel__isExp__5A4F643B] DEFAULT ((0)),
[roomAmenities] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cancellationPolicy] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkInInstruction] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hotelCheckInTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hotelCheckOutTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [int] NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF_TripHotelResponse_isDeleted] DEFAULT ((0)),
[vendorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cityCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preferenceOrder] [int] NULL,
[contractCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HotelPolicy] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yieldManagementValueKey] [int] NULL,
[SupplierType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[perPersonDailyBaseCost] [float] NULL,
[perPersonDailyTotal] [float] NULL,
[hotelRoomTypeCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creationDate] [datetime] NULL,
[salesTaxAndHotelOccupancyTax] [float] NULL,
[originalHotelTotalPrice] [float] NULL,
[isOnlineBooking] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__isOnl__0955373E] DEFAULT ((1)),
[InvoiceNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__Invoi__0A495B77] DEFAULT (NULL),
[roomDescriptionShort] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__roomD__0B3D7FB0] DEFAULT (NULL),
[RPH] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx_T__RPH__0C31A3E9] DEFAULT (NULL),
[IsPromoTrue] [bit] NULL,
[PromoDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AverageBaseRate] [float] NULL,
[PromoId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketplaceMarginPercent] [float] NULL,
[DepositAmount] [float] NULL,
[estimatedRefundAmount] [float] NULL,
[HotelId] [bigint] NULL CONSTRAINT [DF__tmp_ms_xx__Hotel__0D25C822] DEFAULT ((0)),
[IsChangeTripHotel] [bit] NULL,
[atMerchant] [bit] NULL,
[rateKey] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripHotelResponse] ADD CONSTRAINT [PK__TripHote__9E5AE6C13C69FB99] PRIMARY KEY CLUSTERED  ([TripHotelResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripHotelResponse_HotelResponseKey] ON [dbo].[TripHotelResponse] ([hotelResponseKey]) INCLUDE ([hotelTotalPrice]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_supplierHotelKey] ON [dbo].[TripHotelResponse] ([supplierHotelKey], [isDeleted], [supplierId], [tripGUIDKey]) INCLUDE ([actualHotelPrice], [actualHotelTax], [checkInDate], [checkOutDate], [hotelResponseKey], [recordLocator], [RPH]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripHotelREsponse_TripGUIDKey] ON [dbo].[TripHotelResponse] ([tripGUIDKey]) INCLUDE ([hotelTotalPrice]) ON [PRIMARY]
GO
