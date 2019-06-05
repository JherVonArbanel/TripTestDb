CREATE TABLE [dbo].[AirRedeemCalendarResponse]
(
[AirRedeemCalendarResponseId] [int] NOT NULL IDENTITY(1, 1),
[AirRequestKey] [int] NOT NULL,
[AirSubRequestKey] [int] NULL,
[LegIndex] [int] NULL,
[WeekIndex] [int] NULL,
[DayDate] [datetime] NULL,
[DayText] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AwardTypeName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainsAvailableNonStop] [bit] NULL,
[ContainsAvailable] [bit] NULL,
[RedeemPoints] [int] NULL,
[SessionId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirRedeemCalendarResponse] ADD CONSTRAINT [PK__AirRedee__5A42318A2752721D] PRIMARY KEY CLUSTERED  ([AirRedeemCalendarResponseId]) ON [PRIMARY]
GO
