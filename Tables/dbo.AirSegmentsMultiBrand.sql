CREATE TABLE [dbo].[AirSegmentsMultiBrand]
(
[airSegmentMultiBrandKey] [uniqueidentifier] NOT NULL,
[airSegmentKey] [uniqueidentifier] NOT NULL,
[airResponseMultiBrandKey] [uniqueidentifier] NOT NULL,
[airResponseKey] [uniqueidentifier] NOT NULL,
[airLegNumber] [int] NOT NULL,
[airSegmentResBookDesigCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentSeatRemaining] [int] NULL,
[airSegmentFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentFareReferenceKey] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentCabin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segmentOrder] [int] NULL,
[airSegmentPricingKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBrandName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBrandID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBaggage] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentMealCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isReturnFare] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airResponseKey_segmentMultiBrandKeyAndOther] ON [dbo].[AirSegmentsMultiBrand] ([airResponseKey]) INCLUDE ([airLegNumber], [airResponseMultiBrandKey], [airSegmentBaggage], [airSegmentBrandID], [airSegmentBrandName], [airSegmentCabin], [airSegmentFareBasisCode], [airSegmentFareReferenceKey], [airSegmentKey], [airSegmentMealCode], [airSegmentMultiBrandKey], [airSegmentPricingKey], [airSegmentResBookDesigCode], [airSegmentSeatRemaining], [isReturnFare], [segmentOrder]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airResponseKey_SegmentOrder_airLegNumber] ON [dbo].[AirSegmentsMultiBrand] ([airResponseKey]) INCLUDE ([airLegNumber], [segmentOrder]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airResponseMultiBrandKey] ON [dbo].[AirSegmentsMultiBrand] ([airResponseMultiBrandKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airSegmentKey] ON [dbo].[AirSegmentsMultiBrand] ([airSegmentKey], [airResponseMultiBrandKey]) INCLUDE ([airLegNumber], [airResponseKey], [airSegmentBrandName], [airSegmentCabin], [airSegmentFareBasisCode], [airSegmentPricingKey], [airSegmentResBookDesigCode], [airSegmentSeatRemaining], [segmentOrder]) ON [PRIMARY]
GO
