CREATE TABLE [dbo].[tblIROP]
(
[pkId] [int] NOT NULL IDENTITY(1, 1),
[SiteKey] [int] NULL,
[AirlineCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlightNumber] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureDate] [date] NULL,
[ScheduledTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IROPAirportCode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IROPAgentName] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IROPReason] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IROPDate] [date] NULL,
[NumberOfPax] [int] NULL,
[isAllowedHotel] [bit] NULL,
[UploadByUserKey] [int] NULL,
[UploadOn] [datetime] NULL,
[IsAllowVoucher] [bit] NULL,
[VoucherLimit] [float] NULL,
[GroupId] [int] NULL,
[carrier] [int] NULL,
[Earliest_Reaccom] [time] NULL,
[PrefArrivalDate] [date] NULL,
[Arrivebytime] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondGroupId] [int] NULL,
[ThirdGroupId] [int] NULL,
[SortOrderBy1] [int] NULL,
[SortOrderBy2] [int] NULL,
[SortOrderBy3] [int] NULL,
[IncludeInstantPurchCarr] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblIROP] ADD CONSTRAINT [PK_tblIROP] PRIMARY KEY CLUSTERED  ([pkId]) ON [PRIMARY]
GO
