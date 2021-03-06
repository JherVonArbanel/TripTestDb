CREATE TABLE [dbo].[AirRequestTripSavedDeal]
(
[PkId] [int] NOT NULL IDENTITY(1, 1),
[PkGroupId] [int] NULL,
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[AirRequestKey] [int] NULL,
[AirRequestTypeKey] [int] NULL,
[IsInternationalTrip] [bit] NULL,
[ClassLevel] [int] NULL,
[DepartureAirportLeg1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalAirportLeg1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureDateLeg1] [datetime] NULL,
[LegIndex1] [int] NULL,
[DepartureAirportLeg2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalAirportLeg2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureDateLeg2] [datetime] NULL,
[LegIndex2] [int] NULL,
[DepartureAirportLeg3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalAirportLeg3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureDateLeg3] [datetime] NULL,
[LegIndex3] [int] NULL,
[DepartureAirportLeg4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalAirportLeg4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureDateLeg4] [datetime] NULL,
[LegIndex4] [int] NULL,
[DepartureAirportLeg5] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalAirportLeg5] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureDateLeg5] [datetime] NULL,
[LegIndex5] [int] NULL,
[DepartureAirportLeg6] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalAirportLeg6] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureDateLeg6] [datetime] NULL,
[LegIndex6] [int] NULL,
[IsSearched] [bit] NULL CONSTRAINT [DF__AirReques__IsSea__54B68676] DEFAULT ((0)),
[AdultCount] [int] NULL,
[SeniorCount] [int] NULL,
[ChildCount] [int] NULL,
[InfantCount] [int] NULL,
[YouthCount] [int] NULL,
[TotalTraveler] [int] NULL,
[TripSavedKey] [uniqueidentifier] NULL,
[DepartureDateTimeLeg1] [datetime] NULL,
[IsSuccess] [bit] NULL CONSTRAINT [DF__AirReques__IsSuc__49CEE3AF] DEFAULT ((0)),
[UserKey] [int] NULL,
[FromCountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromCountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromStateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToCountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToCountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToStateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromCityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToCityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRestrictedFare] [bit] NULL CONSTRAINT [DF__AirReques__IsRes__2C5E7C59] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirRequestTripSavedDeal] ADD CONSTRAINT [PK__AirReque__A7C03FF852CE3E04] PRIMARY KEY CLUSTERED  ([PkId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PKGroupId] ON [dbo].[AirRequestTripSavedDeal] ([PkGroupId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripKey] ON [dbo].[AirRequestTripSavedDeal] ([TripKey]) ON [PRIMARY]
GO
