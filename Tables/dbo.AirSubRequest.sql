CREATE TABLE [dbo].[AirSubRequest]
(
[airSubRequestKey] [int] NOT NULL IDENTITY(1, 1),
[airRequestKey] [int] NOT NULL,
[airRequestDateTypeKey] [int] NOT NULL,
[airRequestDepartureAirport] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airRequestArrivalAirport] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airRequestDepartureDate] [datetime] NOT NULL,
[airRequestDepartureDateVariance] [int] NULL,
[airRequestArrivalDate] [datetime] NOT NULL,
[airRequestArrivalDateVariance] [int] NULL,
[airRequestCalendarMonth] [datetime] NULL,
[airRequestCalendarMinDays] [int] NULL,
[airRequestCalendarMaxDays] [int] NULL,
[airSubRequestLegIndex] [int] NULL,
[airSpecificDepartTime] [int] NULL,
[groupKey] [int] NULL CONSTRAINT [DF__tmp_ms_xx__group__12DEA178] DEFAULT ((1)),
[CalendarRequest] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSubRequestCompleted] [bit] NULL,
[ThirdPartySessionId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirSubRequest] ADD CONSTRAINT [PK_AirSubRequest] PRIMARY KEY CLUSTERED  ([airSubRequestKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airRequestKey] ON [dbo].[AirSubRequest] ([airRequestKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airrequestKey] ON [dbo].[AirSubRequest] ([airRequestKey], [airSubRequestKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_airRequestKey_airSubRequestLegIndex] ON [dbo].[AirSubRequest] ([airRequestKey] DESC, [airSubRequestLegIndex]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airRequestArrivalAirport] ON [dbo].[AirSubRequest] ([airRequestKey], [airSubRequestLegIndex]) INCLUDE ([airRequestArrivalAirport], [airRequestArrivalDate], [airRequestArrivalDateVariance], [airRequestCalendarMaxDays], [airRequestCalendarMinDays], [airRequestCalendarMonth], [airRequestDateTypeKey], [airRequestDepartureAirport], [airRequestDepartureDate], [airRequestDepartureDateVariance], [airSpecificDepartTime], [airSubRequestKey], [CalendarRequest], [groupKey], [IsSubRequestCompleted], [ThirdPartySessionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Req_LegIndex_Group] ON [dbo].[AirSubRequest] ([airRequestKey] DESC, [airSubRequestLegIndex], [groupKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Req_Group] ON [dbo].[AirSubRequest] ([airRequestKey] DESC, [groupKey] DESC) INCLUDE ([airSubRequestKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AirSubRequest_airSubRequestKey_airRequestKey] ON [dbo].[AirSubRequest] ([airSubRequestKey]) INCLUDE ([airRequestKey]) ON [PRIMARY]
GO
