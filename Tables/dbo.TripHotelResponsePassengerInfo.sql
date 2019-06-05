CREATE TABLE [dbo].[TripHotelResponsePassengerInfo]
(
[TripHotelResponsePassengerInfoKey] [int] NOT NULL IDENTITY(1, 1),
[hotelResponsekey] [uniqueidentifier] NOT NULL,
[TripPassengerInfoKey] [int] NOT NULL,
[confirmationNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItineraryNumber] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_HotelRes_Incl] ON [dbo].[TripHotelResponsePassengerInfo] ([hotelResponsekey]) INCLUDE ([confirmationNumber], [ItineraryNumber], [Status], [TripHotelResponsePassengerInfoKey], [TripPassengerInfoKey]) ON [PRIMARY]
GO
