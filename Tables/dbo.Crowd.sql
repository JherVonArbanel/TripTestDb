CREATE TABLE [dbo].[Crowd]
(
[crowdId] [bigint] NOT NULL IDENTITY(1, 1),
[crowdDestination] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crowdCreationDate] [datetime] NULL CONSTRAINT [DF__Crowd__crowdCrea__4A04B930] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Crowd] ADD CONSTRAINT [PK_Crowd] PRIMARY KEY CLUSTERED  ([crowdId]) ON [PRIMARY]
GO
