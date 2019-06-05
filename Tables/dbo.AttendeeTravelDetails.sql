CREATE TABLE [dbo].[AttendeeTravelDetails]
(
[attendeeTravelKey] [bigint] NOT NULL IDENTITY(1, 1),
[eventAttendeekey] [bigint] NULL,
[isPurchased] [bit] NULL,
[attendeeTripKey] [bigint] NULL,
[creationDate] [datetime] NULL CONSTRAINT [DF_AttendeeTravelDetails_creationDate] DEFAULT (getdate()),
[isDeleted] [bit] NULL CONSTRAINT [DF_AttendeeTravelDetails_isDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AttendeeTravelDetails] ADD CONSTRAINT [PK_AttendeeTravelDetails] PRIMARY KEY CLUSTERED  ([attendeeTravelKey]) ON [PRIMARY]
GO
