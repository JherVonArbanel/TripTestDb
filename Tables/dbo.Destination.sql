CREATE TABLE [dbo].[Destination]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Origin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destination] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
