CREATE TABLE [dbo].[BXTranscon]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[DepartureCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ArrivalCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[siteKey] [int] NOT NULL
) ON [PRIMARY]
GO
