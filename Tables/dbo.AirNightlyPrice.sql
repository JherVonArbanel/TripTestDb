CREATE TABLE [dbo].[AirNightlyPrice]
(
[PkId] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[AirSubRequestKey] [int] NULL,
[AirRequestTypeKey] [int] NULL,
[BookedPrice] [float] NULL,
[PassengerEmailId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirResponseKey] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentMinimumPrice] [float] NULL,
[IsMailSent] [bit] NULL,
[CreateDate] [datetime] NULL,
[GroupId] [int] NULL,
[IsUpdated] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirNightlyPrice] ADD CONSTRAINT [PK__AirNight__A7C03FF84EFDAD20] PRIMARY KEY CLUSTERED  ([PkId]) ON [PRIMARY]
GO
