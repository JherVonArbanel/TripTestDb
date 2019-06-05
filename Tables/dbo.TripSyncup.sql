CREATE TABLE [dbo].[TripSyncup]
(
[SyncId] [int] NOT NULL IDENTITY(1, 1),
[SiteKey] [int] NULL,
[UserId] [int] NULL,
[TripId] [int] NULL,
[TripName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefrenceId] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NULL,
[Origin] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destination] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[TripStatus] [int] NULL,
[TripCreatedDate] [datetime] NULL,
[Remarks] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripSyncup] ADD CONSTRAINT [PK_TripSyncup] PRIMARY KEY CLUSTERED  ([SyncId]) ON [PRIMARY]
GO
