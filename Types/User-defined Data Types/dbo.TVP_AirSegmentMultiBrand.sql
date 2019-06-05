CREATE TYPE [dbo].[TVP_AirSegmentMultiBrand] AS TABLE
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
)
GO
