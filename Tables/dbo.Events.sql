CREATE TABLE [dbo].[Events]
(
[eventKey] [bigint] NOT NULL IDENTITY(1, 1),
[eventName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventDestination] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventHotelGroupId] [int] NULL,
[eventCityId] [int] NULL,
[eventDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userKey] [bigint] NULL,
[eventStartDate] [datetime] NULL,
[eventEndDate] [datetime] NULL,
[eventViewershipType] [int] NULL,
[isInviteFromAttendeeAllowed] [bit] NULL,
[isAttendeeActivityEditAllowed] [bit] NULL,
[eventRecommendedHotelId] [bigint] NULL,
[creationDate] [datetime] NULL CONSTRAINT [DF_Events_creationDate] DEFAULT (getdate()),
[modifiedDate] [datetime] NULL,
[isDeleted] [bit] NULL,
[IsRecommendingHotel] [bit] NULL CONSTRAINT [DF__Events__IsRecomm__5F89E5FB] DEFAULT ((0)),
[eventImageURL] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRecommendingFlight] [bit] NULL,
[AirResponseKey] [uniqueidentifier] NULL,
[HotelResponseKey] [uniqueidentifier] NULL,
[groupKey] [int] NULL CONSTRAINT [DF__Events__groupKey__3513BDEB] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Events] ADD CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED  ([eventKey]) ON [PRIMARY]
GO
