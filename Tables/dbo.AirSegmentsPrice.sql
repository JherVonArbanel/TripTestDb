CREATE TABLE [dbo].[AirSegmentsPrice]
(
[airSegmentPriceKey] [uniqueidentifier] NOT NULL,
[airSegmentKey] [uniqueidentifier] NOT NULL,
[airResponseKey] [uniqueidentifier] NOT NULL,
[airSegmentPriceLegNumber] [int] NOT NULL,
[airSegmentPriceFlightNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airSegmentPriceTotalFare] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airSegmentPriceBaseFare] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airSegmentPriceFareCategory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airsegmentPricePricingKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirSegmentsPrice] ADD CONSTRAINT [PK_AirSegmentsPrice] PRIMARY KEY CLUSTERED  ([airSegmentPriceKey]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference to AirResponse table (airResponseKey) and non-clustered index field.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegmentsPrice', 'COLUMN', N'airResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Air Leg Number', 'SCHEMA', N'dbo', 'TABLE', N'AirSegmentsPrice', 'COLUMN', N'airSegmentPriceLegNumber'
GO
