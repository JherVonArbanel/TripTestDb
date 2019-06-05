CREATE TABLE [dbo].[SubHashTagRule]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[PageNo] [int] NOT NULL,
[HashTagType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HashTagCategoryKey] [int] NOT NULL,
[HashTagOrder] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
