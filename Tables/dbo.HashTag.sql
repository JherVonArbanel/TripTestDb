CREATE TABLE [dbo].[HashTag]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[HashTag] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CategoryKey] [int] NULL
) ON [PRIMARY]
GO
