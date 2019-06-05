CREATE TABLE [dbo].[TripRequest]
(
[tripRequestKey] [int] NOT NULL IDENTITY(1, 1),
[userKey] [int] NULL,
[tripTypeKey] [int] NOT NULL,
[tripRequestCreated] [datetime] NOT NULL,
[tripAdultsCount] [int] NULL,
[tripSeniorsCount] [int] NULL,
[tripChildrenCount] [int] NULL,
[tripInfantCount] [int] NULL,
[tripYouthCount] [int] NULL,
[tripTotalTravlersCount] [int] NULL,
[tripComponentType] [int] NULL,
[tripFrom1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripTo1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripFromDate1] [datetime] NULL,
[tripToDate1] [datetime] NULL,
[tripToHotelGroupId] [int] NULL,
[cityId] [int] NULL,
[SITEKEY] [int] NULL,
[ParentId] [int] NULL CONSTRAINT [DF__tmp_ms_xx__Paren__15BB0E23] DEFAULT (NULL),
[ArrivalIsParent] [int] NULL CONSTRAINT [DF__tmp_ms_xx__Arriv__16AF325C] DEFAULT ((0)),
[DepartureIsParent] [int] NULL CONSTRAINT [DF__tmp_ms_xx__Depar__17A35695] DEFAULT ((0)),
[ArrivalRegionId] [int] NULL CONSTRAINT [DF__tmp_ms_xx__Arriv__18977ACE] DEFAULT ((0)),
[DepartureRegionId] [int] NULL CONSTRAINT [DF__tmp_ms_xx__Depar__198B9F07] DEFAULT ((0)),
[tripInfantWithSeatCount] [int] NULL,
[SubSitekey] [int] NULL CONSTRAINT [DF__TripReque__SubSi__7B5C1DA2] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripRequest] ADD CONSTRAINT [PK_TripRequest] PRIMARY KEY CLUSTERED  ([tripRequestKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tripRequestKey] ON [dbo].[TripRequest] ([tripRequestKey]) INCLUDE ([DepartureIsParent], [DepartureRegionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_tripRequestCreatedDate] ON [dbo].[TripRequest] ([tripRequestKey] DESC, [tripRequestCreated] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_tripTypeKey] ON [dbo].[TripRequest] ([tripTypeKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_userKey] ON [dbo].[TripRequest] ([userKey]) ON [PRIMARY]
GO
