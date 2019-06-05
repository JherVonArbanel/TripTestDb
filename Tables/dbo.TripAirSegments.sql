CREATE TABLE [dbo].[TripAirSegments]
(
[tripAirSegmentKey] [int] NOT NULL IDENTITY(1, 1),
[airSegmentKey] [uniqueidentifier] NOT NULL,
[tripAirLegsKey] [int] NULL,
[airResponseKey] [uniqueidentifier] NOT NULL,
[airLegNumber] [int] NOT NULL,
[airSegmentMarketingAirlineCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airSegmentOperatingAirlineCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentFlightNumber] [int] NOT NULL,
[airSegmentDuration] [time] NULL,
[airSegmentEquipment] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentMiles] [int] NULL,
[airSegmentDepartureDate] [datetime] NOT NULL,
[airSegmentArrivalDate] [datetime] NOT NULL,
[airSegmentDepartureAirport] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airSegmentArrivalAirport] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airSegmentResBookDesigCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentDepartureOffset] [float] NULL,
[airSegmentArrivalOffset] [float] NULL,
[airSegmentSeatRemaining] [int] NULL,
[airSegmentMarriageGrp] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airFareReferenceKey] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSelectedSeatNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticketNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airsegmentcabin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF__TripAirSe__isDel__02FC7413] DEFAULT ((0)),
[RecordLocator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentOperatingFlightNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatMapStatus] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentOperatingAirlineCompanyShortName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RPH] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TripAirSegm__RPH__102C51FF] DEFAULT (NULL),
[DepartureTerminal] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalTerminal] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PNRNo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentFareCategory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBrandName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsChangeTripSeg] [bit] NULL,
[upgradeStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[authNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[originalBookingCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[originalCabin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[originalBrandName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirSegments] ADD CONSTRAINT [PK__TripAirS__9A9AEC5F70DDC3D8] PRIMARY KEY CLUSTERED  ([tripAirSegmentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirResponseKey] ON [dbo].[TripAirSegments] ([airResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripAirSegments_GET_airSegmentarrivalAirport] ON [dbo].[TripAirSegments] ([airSegmentArrivalAirport]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripAirSegments_GET_airSegmentdepartureAirport] ON [dbo].[TripAirSegments] ([airSegmentDepartureAirport]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripAirSegments_GET_airSegmentEquipment] ON [dbo].[TripAirSegments] ([airSegmentEquipment]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripAirSegments_GET_airSegmentMarketingAirlineCode] ON [dbo].[TripAirSegments] ([airSegmentMarketingAirlineCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripAirSegments_GET_airSegmentOperatingAirlineCode] ON [dbo].[TripAirSegments] ([airSegmentOperatingAirlineCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsDeleted] ON [dbo].[TripAirSegments] ([isDeleted]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsDeleted_SegKey_ResKey] ON [dbo].[TripAirSegments] ([isDeleted]) INCLUDE ([airResponseKey], [tripAirSegmentKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirLeg] ON [dbo].[TripAirSegments] ([tripAirLegsKey], [airLegNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirSegments] ADD CONSTRAINT [FK__TripAirSe__tripA__245D67DE] FOREIGN KEY ([tripAirLegsKey]) REFERENCES [dbo].[TripAirLegs] ([tripAirLegsKey])
GO
ALTER TABLE [dbo].[TripAirSegments] ADD CONSTRAINT [FK__TripAirSe__tripA__52AE4273] FOREIGN KEY ([tripAirLegsKey]) REFERENCES [dbo].[TripAirLegs] ([tripAirLegsKey])
GO
ALTER TABLE [dbo].[TripAirSegments] ADD CONSTRAINT [FK__TripAirSe__tripA__53A266AC] FOREIGN KEY ([tripAirLegsKey]) REFERENCES [dbo].[TripAirLegs] ([tripAirLegsKey])
GO
ALTER TABLE [dbo].[TripAirSegments] ADD CONSTRAINT [FK__TripAirSe__tripA__54968AE5] FOREIGN KEY ([tripAirLegsKey]) REFERENCES [dbo].[TripAirLegs] ([tripAirLegsKey])
GO
ALTER TABLE [dbo].[TripAirSegments] ADD CONSTRAINT [FK__TripAirSe__tripA__5629CD9C] FOREIGN KEY ([tripAirLegsKey]) REFERENCES [dbo].[TripAirLegs] ([tripAirLegsKey])
GO
ALTER TABLE [dbo].[TripAirSegments] ADD CONSTRAINT [FK__TripAirSe__tripA__2BAA4F42] FOREIGN KEY ([tripAirLegsKey]) REFERENCES [dbo].[TripAirLegs] ([tripAirLegsKey])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of pair of trip.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airLegNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air Response key reference to AirResponse table (airResponseKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Arrival airport.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentArrivalAirport'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Arrival Date.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentArrivalDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Departure Airport.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentDepartureAirport'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Departure Date.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentDepartureDate'
GO
EXEC sp_addextendedproperty N'MS_Description', '', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentEquipment'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flight Number.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentFlightNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air segment key reference to AirSegments table (airSegmentKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Marketing airline code.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentMarketingAirlineCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Distance in Miles', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentMiles'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Operating airline code.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentOperatingAirlineCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seat Remaining.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSegmentSeatRemaining'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Selected Seat Number', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'airSelectedSeatNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates whether segment is deleted or not.  Default is not deleted (0).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'isDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PNR number.  ', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'RecordLocator'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air ticket number.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'ticketNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip Air Leg key reference to TripAirLegs table (tripAirLegsKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'tripAirLegsKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripAirSegments table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirSegments', 'COLUMN', N'tripAirSegmentKey'
GO
