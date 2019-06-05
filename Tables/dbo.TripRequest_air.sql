CREATE TABLE [dbo].[TripRequest_air]
(
[tripRequestKey] [int] NOT NULL,
[airRequestKey] [int] NOT NULL,
[airRequestClassKey] [int] NULL,
[airRequestIsNonStop] [bit] NULL,
[airRequestDepartureAirportAlternate] [bit] NULL,
[airRequestArrivalAirportAlternate] [bit] NULL,
[airRequestRefundable] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__airRe__02133CD2] DEFAULT ((0)),
[airRequestAdults] [int] NULL,
[airRequestSeniors] [int] NULL,
[airRequestChildren] [int] NULL,
[NoOFRequestSentToGDS] [int] NULL CONSTRAINT [DF__TripReque__NoOFR__70B3A6A6] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airRequestClassKey] ON [dbo].[TripRequest_air] ([airRequestClassKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airRequestIsNonStop] ON [dbo].[TripRequest_air] ([airRequestIsNonStop]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airRequestKey] ON [dbo].[TripRequest_air] ([airRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_NoOFRequestSentToGDS] ON [dbo].[TripRequest_air] ([airRequestKey], [NoOFRequestSentToGDS]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tripRequestKey] ON [dbo].[TripRequest_air] ([airRequestKey], [tripRequestKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripRequestKey] ON [dbo].[TripRequest_air] ([tripRequestKey]) ON [PRIMARY]
GO
