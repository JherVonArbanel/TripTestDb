CREATE TABLE [dbo].[AirLineBaggageLink_20190423]
(
[airlineCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airlineBaggageLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkInLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gateLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
