CREATE TABLE [dbo].[AirRequest]
(
[airRequestKey] [int] NOT NULL IDENTITY(1, 1),
[airRequestTypeKey] [int] NOT NULL,
[airRequestCreated] [datetime] NOT NULL,
[isInternationalTrip] [bit] NULL CONSTRAINT [DF_AirRequest_isInternationalTrip] DEFAULT ((0)),
[tripRequestKey] [int] NULL,
[airRequestClassKey] [int] NULL,
[airRequestIsNonStop] [bit] NULL,
[airRequestAdults] [int] NULL,
[airRequestSeniors] [int] NULL,
[airRequestChildren] [int] NULL,
[airRequestDepartureAirportAlternate] [bit] NULL,
[airRequestArrivalAirportAlternate] [bit] NULL,
[airRequestRefundable] [bit] NULL,
[RedeemAuthNumber] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[redeemPoints] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isRedeem] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirRequest] ADD CONSTRAINT [PK_AirRequest] PRIMARY KEY CLUSTERED  ([airRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airRequestCreated] ON [dbo].[AirRequest] ([airRequestCreated]) INCLUDE ([airRequestKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airRequestTypeKey] ON [dbo].[AirRequest] ([airRequestTypeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of Passengers', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestAdults'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of Children.', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestChildren'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reference to AirRequestClassLookup table (airRequestClassKey).', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestClassKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air request created date and time field.', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestCreated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag Indicator field for "Is Non-stop?".', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestIsNonStop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for AirRequest table and Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicator for "is Refundable".', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestRefundable'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of Senior passengers.', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestSeniors'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reference to AirRequestTypeLookup table (airRequestTypeKey) and Non-clustered index field.', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'airRequestTypeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicator about "Is International Trip?"', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'isInternationalTrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reference to TripRequest table (tripRequestKey).', 'SCHEMA', N'dbo', 'TABLE', N'AirRequest', 'COLUMN', N'tripRequestKey'
GO
