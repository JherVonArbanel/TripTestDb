CREATE TABLE [dbo].[WeeklyTripReport]
(
[RowNum] [tinyint] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Count] [int] NULL
) ON [PRIMARY]
GO
