CREATE TABLE [dbo].[TripCarPreference]
(
[TripCarPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[CarClass] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripCarPreference] ADD CONSTRAINT [PK__TripCarP__713F2EF668DD7AB4] PRIMARY KEY CLUSTERED  ([TripCarPreferenceKey]) ON [PRIMARY]
GO
