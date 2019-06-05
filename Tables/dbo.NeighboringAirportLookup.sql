CREATE TABLE [dbo].[NeighboringAirportLookup]
(
[airportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[neighborAirportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[distanceInMiles] [float] NULL
) ON [PRIMARY]
GO
