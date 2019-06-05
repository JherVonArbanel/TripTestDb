CREATE TABLE [dbo].[AirBookingClassAvailInfo]
(
[airBookingClassAvailInfoId] [bigint] NOT NULL IDENTITY(1, 1),
[airSegmentKey] [uniqueidentifier] NULL,
[resBookDesignCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[noOfSeatsRemaining] [int] NULL,
[airSubRequestKey] [int] NULL
) ON [PRIMARY]
GO
