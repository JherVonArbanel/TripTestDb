CREATE TABLE [dbo].[TripAirSegmentOptionalServices]
(
[TripAirSegmentOptionalServicesKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NOT NULL,
[serviceStatus] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentKey] [uniqueidentifier] NOT NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[descriptionDetail] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[icon] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceAmount] [float] NULL,
[method] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReasonCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bookingInstructions] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attributes] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF__TripAirSe__isDel__02084FDA] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirSegmentOptionalServices] ADD CONSTRAINT [PK_TripAirSegmentOptionalServicesKey] PRIMARY KEY CLUSTERED  ([TripAirSegmentOptionalServicesKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tripKey] ON [dbo].[TripAirSegmentOptionalServices] ([tripKey], [isDeleted]) INCLUDE ([airSegmentKey], [attributes], [bookingInstructions], [description], [descriptionDetail], [icon], [method], [ReasonCode], [serviceAmount], [serviceCode], [serviceStatus], [serviceType], [subcode], [TripAirSegmentOptionalServicesKey], [type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirSegmentOptionalServices] ADD CONSTRAINT [FK__TripAirSe__tripK__5535A963] FOREIGN KEY ([tripKey]) REFERENCES [dbo].[Trip] ([tripKey])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air Segment Key.  Foriegn key reference to AirSegments table (airSegmentKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'airSegmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag Indicator whether optional service is deleted or not.  Default is not deleted (0).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'isDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reason Code.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Service Amount.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'serviceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Service code.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'serviceCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Optional Service status.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'serviceStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Service Type.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'serviceType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripAirSegmentOptionalServices.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'TripAirSegmentOptionalServicesKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key foriegn key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'tripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type whether Surcharge or Included.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegmentOptionalServices', 'COLUMN', N'type'
GO
