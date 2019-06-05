CREATE TABLE [dbo].[TripNotes]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[AttendeeNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrganizerNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttendeeNotesLastModifiedOn] [datetime] NULL,
[AttendeeNotesLastModifiedBy] [int] NULL,
[OrganizerNotesLastModifiedOn] [datetime] NULL,
[OrganizerNotesLastModifiedBy] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripNotes] ADD CONSTRAINT [PK_TripNotes] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
