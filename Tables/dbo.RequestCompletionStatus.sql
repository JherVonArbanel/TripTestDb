CREATE TABLE [dbo].[RequestCompletionStatus]
(
[requestCompletionKey] [int] NOT NULL IDENTITY(1, 1),
[requestKey] [int] NULL,
[GDScallIndex] [int] NULL,
[componentType] [int] NULL,
[createdDate] [datetime] NULL CONSTRAINT [DF__RequestCo__creat__744F2D60] DEFAULT (getdate()),
[isSuccessfullBFM] [bit] NULL,
[searchType] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RequestCompletionStatus] ADD CONSTRAINT [PK__RequestC__27922A6E613C58EC] PRIMARY KEY CLUSTERED  ([requestCompletionKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CompTypeReq] ON [dbo].[RequestCompletionStatus] ([componentType], [requestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
