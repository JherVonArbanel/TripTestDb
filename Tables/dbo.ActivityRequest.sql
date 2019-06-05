CREATE TABLE [dbo].[ActivityRequest]
(
[activityRequestKey] [int] NOT NULL IDENTITY(1, 1),
[locationId] [bigint] NULL,
[activityType] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[activityFromDate] [datetime] NULL,
[activityToDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivityRequest] ADD CONSTRAINT [PK_ActivityRequest] PRIMARY KEY CLUSTERED  ([activityRequestKey]) ON [PRIMARY]
GO
