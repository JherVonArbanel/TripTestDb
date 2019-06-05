CREATE TABLE [dbo].[TripAirLegs]
(
[tripAirLegsKey] [int] NOT NULL IDENTITY(1, 1),
[airResponseKey] [uniqueidentifier] NOT NULL,
[gdsSourceKey] [int] NULL,
[selectedBrand] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airLegNumber] [int] NULL,
[tripKey] [int] NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF__TripAirLe__isDel__00200768] DEFAULT ((0)),
[ValidatingCarrier] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contractCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isRefundable] [bit] NULL,
[TicketDesignator] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BucketCategory] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirLegs] ADD CONSTRAINT [PK__TripAirL__ED58EE470519C6AF] PRIMARY KEY CLUSTERED  ([tripAirLegsKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripAirLegs_GET_tripAirLegsKey_airLegNumber] ON [dbo].[TripAirLegs] ([tripAirLegsKey] DESC, [airLegNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pair of City trips (Trip Leg Number).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'airLegNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air Response Key.  Reference to TripAirResponse table (airResponseKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'airResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'GDS source key.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'gdsSourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag to indicate whether air leg is deleted.  Defaut is Not deleted.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'isDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Generated PNR value to the trip.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'recordLocator'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Selected airline brand for Trip.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'selectedBrand'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripAirLegs table.  Clustered Index field and Identical.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'tripAirLegsKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key value.  Reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirLegs', 'COLUMN', N'tripKey'
GO
