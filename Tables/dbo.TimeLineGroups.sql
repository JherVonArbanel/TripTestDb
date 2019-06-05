CREATE TABLE [dbo].[TimeLineGroups]
(
[timeLineGroupKey] [int] NOT NULL IDENTITY(1, 1),
[name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeLineGroups] ADD CONSTRAINT [PK_TimeLineGroups] PRIMARY KEY CLUSTERED  ([timeLineGroupKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
