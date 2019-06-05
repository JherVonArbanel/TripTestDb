CREATE TABLE [dbo].[EventMapping]
(
[EventMappingKey] [bigint] NOT NULL IDENTITY(1, 1),
[eventKey] [bigint] NULL,
[crowdKey] [bigint] NULL,
[tripKey] [bigint] NULL,
[creationDate] [datetime] NULL CONSTRAINT [DF_EventMapping_creationDate] DEFAULT (getdate()),
[isDeleted] [bit] NULL CONSTRAINT [DF_EventMapping_isDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventMapping] ADD CONSTRAINT [PK_EventMapping] PRIMARY KEY CLUSTERED  ([EventMappingKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventMapping] ADD CONSTRAINT [FK_EventMapping_Events] FOREIGN KEY ([eventKey]) REFERENCES [dbo].[Events] ([eventKey])
GO
