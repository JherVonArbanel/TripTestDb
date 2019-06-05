CREATE TABLE [dbo].[TripHotelFlexibilities]
(
[hotelFlexibilityKey] [int] NOT NULL IDENTITY(1, 1),
[hotelResponseKey] [uniqueidentifier] NOT NULL,
[altHotelRating] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flexibleDistance] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HotelChain] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HotelName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[RegionID] [int] NULL,
[NoOfRooms] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripKey] ON [dbo].[TripHotelFlexibilities] ([TripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripRequestKey] ON [dbo].[TripHotelFlexibilities] ([TripRequestKey]) ON [PRIMARY]
GO
