CREATE TABLE [dbo].[M_AirSegmentsMultiBrand]
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
[airSegmentPricingKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBrandName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBrandID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBaggage] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentMealCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isReturnFare] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airResponseKey_SegmentOrder_airLegNumber] ON [dbo].[M_AirSegmentsMultiBrand] ([airResponseKey]) INCLUDE ([airLegNumber], [segmentOrder]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airResponseMultiBrandKey] ON [dbo].[M_AirSegmentsMultiBrand] ([airResponseMultiBrandKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MultiBrand_airLegNumber] ON [dbo].[M_AirSegmentsMultiBrand] ([airResponseMultiBrandKey], [airLegNumber]) INCLUDE ([airResponseKey], [airSegmentBaggage], [airSegmentBrandID], [airSegmentBrandName], [airSegmentCabin], [airSegmentKey], [airSegmentMealCode], [airSegmentResBookDesigCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airSegmentMultiBrandKey] ON [dbo].[M_AirSegmentsMultiBrand] ([airSegmentMultiBrandKey]) ON [PRIMARY]
GO
