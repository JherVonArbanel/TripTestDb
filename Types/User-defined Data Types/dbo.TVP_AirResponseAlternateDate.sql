CREATE TYPE [dbo].[TVP_AirResponseAlternateDate] AS TABLE
(
[airSubRequestKey] [int] NOT NULL,
[airResponseAlternateDateKey] [uniqueidentifier] NOT NULL,
[airResponseAlternateDateOriginDate] [datetime] NOT NULL,
[airResponseAlternateDateReturnDate] [datetime] NULL,
[airResponseAlternateDateAirlineCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airResponseAlternateDatePriceTotal] [float] NULL
)
GO
