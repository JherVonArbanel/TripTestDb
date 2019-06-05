CREATE TABLE [dbo].[EventAttendeeStatusLookup]
(
[eventAttendeeStatusKey] [int] NOT NULL IDENTITY(1, 1),
[eventAttendeeStatusDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventAttendeeStatusLookup] ADD CONSTRAINT [PK_EventAttendeeStatusLookup] PRIMARY KEY CLUSTERED  ([eventAttendeeStatusKey]) ON [PRIMARY]
GO
