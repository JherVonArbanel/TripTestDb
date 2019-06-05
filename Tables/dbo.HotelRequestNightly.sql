CREATE TABLE [dbo].[HotelRequestNightly]
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
[Rating] [int] NULL,
[RatingType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[StateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSearched] [bit] NULL CONSTRAINT [DF__HotelRequ__IsSea__2220E508] DEFAULT ((0))
) ON [PRIMARY]
GO
