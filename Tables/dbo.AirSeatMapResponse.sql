CREATE TABLE [dbo].[AirSeatMapResponse]
(
[airSegmentKey] [uniqueidentifier] NOT NULL,
[airSeatMapResponseJSON] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
