CREATE TABLE [dbo].[AllAirportCodeLookup]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[AirportCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllAirportCode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
