CREATE TABLE [dbo].[TimeLine]
(
[timeLineKey] [int] NOT NULL IDENTITY(1, 1),
[userKey] [int] NOT NULL,
[timeLineGroupKey] [int] NOT NULL,
[jsonData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[isRead] [bit] NULL,
[tripKey] [int] NULL,
[createdDate] [datetime] NOT NULL,
[showAlert] [bit] NULL,
[savings] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeLine] ADD CONSTRAINT [PK_TimeLine] PRIMARY KEY CLUSTERED  ([timeLineKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_tripKey] ON [dbo].[TimeLine] ([tripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UserKey] ON [dbo].[TimeLine] ([userKey]) ON [PRIMARY]
GO
