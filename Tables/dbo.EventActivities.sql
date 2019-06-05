CREATE TABLE [dbo].[EventActivities]
(
[eventActivityKey] [bigint] NOT NULL IDENTITY(1, 1),
[eventKey] [bigint] NULL,
[activityDate] [datetime] NULL,
[activityDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userKey] [bigint] NULL,
[creationDate] [datetime] NULL CONSTRAINT [DF_EventActivities_creationDate] DEFAULT (getdate()),
[modifiedDate] [datetime] NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF_EventActivities_isDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventActivities] ADD CONSTRAINT [PK_EventActivities] PRIMARY KEY CLUSTERED  ([eventActivityKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventActivities] ADD CONSTRAINT [FK_EventActivities_Events] FOREIGN KEY ([eventKey]) REFERENCES [dbo].[Events] ([eventKey])
GO
