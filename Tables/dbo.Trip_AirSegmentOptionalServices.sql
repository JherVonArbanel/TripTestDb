CREATE TABLE [dbo].[Trip_AirSegmentOptionalServices]
(
[segmentServiceId] [int] NOT NULL IDENTITY(1, 1),
[serviceKey] [int] NULL,
[tripKey] [int] NULL,
[serviceStatus] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentKey] [uniqueidentifier] NULL,
[seatNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Trip_AirSegmentOptionalServices] ADD CONSTRAINT [PK_Trip_AirSegmentOptionalServices] PRIMARY KEY CLUSTERED  ([segmentServiceId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airSegmentKey] ON [dbo].[Trip_AirSegmentOptionalServices] ([airSegmentKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_tripKey] ON [dbo].[Trip_AirSegmentOptionalServices] ([tripKey]) ON [PRIMARY]
GO
