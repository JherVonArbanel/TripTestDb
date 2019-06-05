CREATE TABLE [dbo].[GroupTravelDestination]
(
[GroupTravelDestinationId] [int] NOT NULL,
[GroupTravelRequestId] [int] NOT NULL,
[DestinationCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArivalDate] [date] NULL,
[DepartureDate] [date] NULL,
[PreferredHotel] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DesiredHotel] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoMeals] [bit] NULL,
[BreakfastRequired] [bit] NULL,
[LunchRequired] [bit] NULL,
[DinnerRequired] [bit] NULL,
[NoTransfer] [bit] NULL,
[TransferIn] [bit] NULL,
[TransferOut] [bit] NULL,
[AdditionalDealsNote] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
