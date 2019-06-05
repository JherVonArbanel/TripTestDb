CREATE TABLE [dbo].[HotelRequestTripSavedDeal]
(
[PkId] [int] NOT NULL IDENTITY(1, 1),
[PkGroupId] [int] NULL,
[TripKey] [int] NULL,
[TripRequestKey] [int] NULL,
[NoOfDays] [int] NULL,
[NoOfRooms] [int] NULL,
[HotelCityCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckInDate] [datetime] NULL,
[CheckOutDate] [datetime] NULL,
[TripStatusKey] [int] NULL,
[UserKey] [int] NULL,
[Rating] [float] NULL,
[RatingType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSearched] [bit] NULL CONSTRAINT [DF__HotelRequ__IsSea__78F3E6EC] DEFAULT ((0)),
[TripSavedKey] [uniqueidentifier] NULL,
[TripAdultsCount] [int] NULL,
[TripSeniorsCount] [int] NULL,
[TripChildCount] [int] NULL,
[TripInfantCount] [int] NULL,
[TripYouthCount] [int] NULL,
[NoOfTotalTraveler] [int] NULL,
[OriginalSearchToCity] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSuccess] [bit] NULL CONSTRAINT [DF__HotelRequ__IsSuc__53584DE9] DEFAULT ((0)),
[CountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripKey] ON [dbo].[HotelRequestTripSavedDeal] ([TripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripRequestKey] ON [dbo].[HotelRequestTripSavedDeal] ([TripRequestKey]) ON [PRIMARY]
GO
