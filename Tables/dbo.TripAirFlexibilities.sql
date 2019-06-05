CREATE TABLE [dbo].[TripAirFlexibilities]
(
[airFlexibilityKey] [int] NOT NULL IDENTITY(1, 1),
[airResponseKey] [uniqueidentifier] NOT NULL,
[airCarrierOption] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flexibleTime] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[noofStops] [int] NULL,
[isAltAirpot] [bit] NULL,
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[TripType] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripKey] ON [dbo].[TripAirFlexibilities] ([TripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripRequestKey] ON [dbo].[TripAirFlexibilities] ([TripRequestKey]) ON [PRIMARY]
GO
