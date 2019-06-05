CREATE TABLE [dbo].[AirlineBaggageLink]
(
[airlineCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airlineBaggageLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkInLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gateLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airlineCode_COMP] ON [dbo].[AirlineBaggageLink] ([airlineCode], [airlineBaggageLink]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirlineCodeCheckInLink] ON [dbo].[AirlineBaggageLink] ([airlineCode], [checkInLink]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AirlineCode] ON [dbo].[AirlineBaggageLink] ([checkInLink], [airlineCode]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Airline Baggage URL', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBaggageLink', 'COLUMN', N'airlineBaggageLink'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Airline code.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBaggageLink', 'COLUMN', N'airlineCode'
GO
