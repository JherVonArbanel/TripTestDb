CREATE TABLE [dbo].[DuplicatePNRs]
(
[RN] [int] NOT NULL IDENTITY(1, 1),
[MEETING CODE_1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISSUED] [datetime] NULL,
[INVOICE] [float] NULL,
[PNR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TKT #] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEPART] [datetime] NULL,
[TRAVELER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CURRENCY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BASE FARE_1] [money] NULL,
[TAX_1] [money] NULL,
[TTL TKT AMT_1] [money] NULL
) ON [PRIMARY]
GO
