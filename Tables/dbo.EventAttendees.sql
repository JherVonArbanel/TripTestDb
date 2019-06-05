CREATE TABLE [dbo].[EventAttendees]
(
[eventAttendeeKey] [bigint] NOT NULL IDENTITY(1, 1),
[eventKey] [bigint] NULL,
[userKey] [bigint] NULL,
[attendeeEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attendeeFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attendeeLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attendeeImageUrl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isHost] [bit] NULL CONSTRAINT [DF_EventAttendee_isHost] DEFAULT ((0)),
[attendeeStatusKey] [int] NULL,
[creationDate] [datetime] NULL,
[invitorUserKey] [bigint] NULL,
[attendeeActionDate] [datetime] NULL CONSTRAINT [DF_EventAttendees_attendeeActionDate] DEFAULT (getdate()),
[isDeleted] [bit] NULL CONSTRAINT [DF_EventAttendee_isDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventAttendees] ADD CONSTRAINT [PK_EventAttendee] PRIMARY KEY CLUSTERED  ([eventAttendeeKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventAttendees] ADD CONSTRAINT [FK_EventAttendees_Events] FOREIGN KEY ([eventKey]) REFERENCES [dbo].[Events] ([eventKey])
GO
