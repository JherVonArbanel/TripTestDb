CREATE TABLE [dbo].[Comments]
(
[commentKey] [int] NOT NULL IDENTITY(1, 1),
[userKey] [int] NOT NULL,
[tripKey] [int] NULL,
[eventKey] [int] NULL,
[commentText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comments] ADD CONSTRAINT [PK_Comments] PRIMARY KEY CLUSTERED  ([commentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
