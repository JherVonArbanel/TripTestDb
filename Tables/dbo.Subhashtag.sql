CREATE TABLE [dbo].[Subhashtag]
(
[SubHashTagId] [int] NOT NULL IDENTITY(1, 1),
[PageInfo] [int] NULL,
[SubHashTagTypeId] [int] NULL,
[JSONData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
