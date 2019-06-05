CREATE TABLE [dbo].[CruiseRequest]
(
[cruiseRequestKey] [int] NOT NULL IDENTITY(1, 1),
[destinationRegionCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sailingDuration] [int] NULL,
[maxSailingDuration] [int] NULL,
[DepartureDate] [datetime] NOT NULL,
[DepartureCityCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cruiseLineCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cruiseRequestCreated] [datetime] NOT NULL,
[NoofGuests] [int] NULL CONSTRAINT [DF__CruiseReq__NoofG__74CE504D] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CruiseRequest] ADD CONSTRAINT [PK_CruiseRequest] PRIMARY KEY CLUSTERED  ([cruiseRequestKey]) ON [PRIMARY]
GO
