CREATE TABLE [dbo].[AirSegments]
(
[airSegmentKey] [uniqueidentifier] NOT NULL,
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
[airSegmentOperatingFlightNumber] [int] NULL,
[airsegmentCabin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segmentOrder] [int] NULL CONSTRAINT [DF__tmp_ms_xx__segme__04708690] DEFAULT ((1)),
[amadeusSNDIndicator] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentOperatingAirlineCompanyShortName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalairsegmentCabin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentId] [bigint] NOT NULL IDENTITY(1, 1),
[airSuperSaverFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconSaverFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airFirstFlexFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airCorporateFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconFlexFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconUpgradeFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSuperSaverFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconSaverFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airFirstFlexFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airCorporateFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconFlexFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airEconUpgradeFareReferenceKey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentClassSuperSaver] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__airSe__0564AAC9] DEFAULT (NULL),
[airSegmentClassEconSaver] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__airSe__0658CF02] DEFAULT (NULL),
[airSegmentClassFirstFlex] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__airSe__074CF33B] DEFAULT (NULL),
[airSegmentClassEconFlex] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__airSe__08411774] DEFAULT (NULL),
[airsegmentPricingKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airsegmentFareCategory] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBrandName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBrandID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentBaggage] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentMealCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airSegmentStops] [int] NULL,
[ProgramCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isReturnFare] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_segmentOrder] ON [dbo].[AirSegments] ([airLegNumber], [airSegmentDepartureAirport], [airSegmentDepartureOffset]) INCLUDE ([airResponseKey], [segmentOrder]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airLegNumber_SegmentOrder_DepartureAirport] ON [dbo].[AirSegments] ([airLegNumber], [segmentOrder], [airSegmentDepartureAirport]) INCLUDE ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airResponseKey] ON [dbo].[AirSegments] ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AirSegments_Airresponse] ON [dbo].[AirSegments] ([airResponseKey], [airLegNumber], [segmentOrder]) INCLUDE ([airCorporateFareBasisCode], [airCorporateFareReferenceKey], [airEconFlexFareBasisCode], [airEconFlexFareReferenceKey], [airEconSaverFareBasisCode], [airEconSaverFareReferenceKey], [airEconUpgradeFareBasisCode], [airEconUpgradeFareReferenceKey], [airFareBasisCode], [airFareReferenceKey], [airFirstFlexFareBasisCode], [airFirstFlexFareReferenceKey], [airSegmentArrivalAirport], [airSegmentArrivalDate], [airSegmentArrivalOffset], [airSegmentBaggage], [airSegmentBrandID], [airSegmentBrandName], [airsegmentCabin], [airSegmentClassEconFlex], [airSegmentClassEconSaver], [airSegmentClassFirstFlex], [airSegmentClassSuperSaver], [airSegmentDepartureAirport], [airSegmentDepartureDate], [airSegmentDepartureOffset], [airSegmentDuration], [airSegmentEquipment], [airsegmentFareCategory], [airSegmentFlightNumber], [airSegmentId], [airSegmentKey], [airSegmentMarketingAirlineCode], [airSegmentMarriageGrp], [airSegmentMealCode], [airSegmentMiles], [airSegmentOperatingAirlineCode], [airSegmentOperatingAirlineCompanyShortName], [airSegmentOperatingFlightNumber], [airsegmentPricingKey], [airSegmentResBookDesigCode], [airSegmentSeatRemaining], [airSegmentStops], [airSuperSaverFareBasisCode], [airSuperSaverFareReferenceKey], [amadeusSNDIndicator], [isReturnFare], [OriginalairsegmentCabin], [ProgramCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_COMP_airResponseKey] ON [dbo].[AirSegments] ([airSegmentArrivalAirport], [airSegmentArrivalOffset]) INCLUDE ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_COMP_airResponseKey] ON [dbo].[AirSegments] ([airSegmentDepartureAirport], [airSegmentDepartureOffset]) INCLUDE ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airSegmentKey] ON [dbo].[AirSegments] ([airSegmentKey]) INCLUDE ([airCorporateFareBasisCode], [airCorporateFareReferenceKey], [airEconFlexFareBasisCode], [airEconFlexFareReferenceKey], [airEconSaverFareBasisCode], [airEconSaverFareReferenceKey], [airEconUpgradeFareBasisCode], [airEconUpgradeFareReferenceKey], [airFareReferenceKey], [airFirstFlexFareBasisCode], [airFirstFlexFareReferenceKey], [airSegmentArrivalAirport], [airSegmentArrivalDate], [airSegmentArrivalOffset], [airSegmentClassEconFlex], [airSegmentClassEconSaver], [airSegmentClassFirstFlex], [airSegmentClassSuperSaver], [airSegmentDepartureAirport], [airSegmentDepartureDate], [airSegmentDepartureOffset], [airSegmentDuration], [airSegmentEquipment], [airSegmentFlightNumber], [airSegmentMarketingAirlineCode], [airSegmentMarriageGrp], [airSegmentMiles], [airSegmentOperatingAirlineCode], [airSegmentOperatingAirlineCompanyShortName], [airSegmentOperatingFlightNumber], [airSuperSaverFareBasisCode], [airSuperSaverFareReferenceKey], [amadeusSNDIndicator]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airResponseKey] ON [dbo].[AirSegments] ([airSegmentMarketingAirlineCode]) INCLUDE ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airSegmentOperatingAirlineCode] ON [dbo].[AirSegments] ([airSegmentOperatingAirlineCode]) INCLUDE ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airSegmentDepartureDate] ON [dbo].[AirSegments] ([segmentOrder], [airSegmentDepartureDate]) INCLUDE ([airResponseKey]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Air Leg Number', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airLegNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference to AirResponse table (airResponseKey) and non-clustered index field.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Arrival Airport.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentArrivalAirport'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Arrival Date and Time.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentArrivalDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Departure Airport.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentDepartureAirport'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Departure Date and Time.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentDepartureDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentDuration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flight Number.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentFlightNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Marketing Airline Code.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentMarketingAirlineCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of Miles', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentMiles'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Optional Airline Code.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentOperatingAirlineCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Operating Flight  Number.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentOperatingFlightNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of Seats remaining.', 'SCHEMA', N'dbo', 'TABLE', N'AirSegments', 'COLUMN', N'airSegmentSeatRemaining'
GO
