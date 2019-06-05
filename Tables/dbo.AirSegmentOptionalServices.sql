CREATE TABLE [dbo].[AirSegmentOptionalServices]
(
[serviceKey] [int] NOT NULL IDENTITY(1, 1),
[airSegmentKey] [uniqueidentifier] NOT NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[attributes] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirSegmentOptionalServices] ADD CONSTRAINT [PK_AirSegmentOptionalServices] PRIMARY KEY CLUSTERED  ([serviceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airSegmentKey] ON [dbo].[AirSegmentOptionalServices] ([airSegmentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reference to AirSegments table (airSegmentKey) and non-clustered index field.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegmentOptionalServices', 'COLUMN', N'airSegmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description about Optional Service.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegmentOptionalServices', 'COLUMN', N'description'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Service Amount.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegmentOptionalServices', 'COLUMN', N'serviceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for AirSegmentOptionalServices table and clustered index field.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegmentOptionalServices', 'COLUMN', N'serviceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Service Type.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegmentOptionalServices', 'COLUMN', N'serviceType'
GO
