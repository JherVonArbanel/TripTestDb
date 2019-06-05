CREATE TABLE [dbo].[M_AirSubRequest]
(
[airSubRequestKey] [int] NOT NULL,
[airRequestKey] [int] NULL,
[airRequestDateTypeKey] [int] NULL,
[airRequestDepartureAirport] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airRequestArrivalAirport] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airRequestDepartureDate] [datetime] NULL,
[airRequestDepartureDateVariance] [int] NULL,
[airRequestArrivalDate] [datetime] NULL,
[airRequestArrivalDateVariance] [int] NULL,
[airRequestCalendarMonth] [datetime] NULL,
[airRequestCalendarMinDays] [int] NULL,
[airRequestCalendarMaxDays] [int] NULL,
[airSubRequestLegIndex] [int] NULL,
[airSpecificDepartTime] [int] NULL,
[groupKey] [int] NULL,
[CalendarRequest] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSubRequestCompleted] [bit] NULL,
[ThirdPartySessionId] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[M_AirSubRequest] ADD CONSTRAINT [PK1_tempAirSubRequest_1] PRIMARY KEY NONCLUSTERED  ([airSubRequestKey]) ON [PRIMARY]
GO
