CREATE TABLE [dbo].[TripAirResponse]
(
[tripAirResponseKey] [int] NOT NULL IDENTITY(1, 1),
[airResponseKey] [uniqueidentifier] NOT NULL,
[tripKey] [int] NULL,
[tripGUIDKey] [uniqueidentifier] NULL,
[searchAirPrice] [float] NOT NULL,
[searchAirTax] [float] NULL,
[searchAirPriceBreakupKey] [int] NULL,
[actualAirPrice] [float] NULL,
[actualAirTax] [float] NULL,
[actualAirPriceBreakupKey] [int] NULL,
[CurrencyCodeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PolicyReasonCodeID] [int] NULL,
[PolicyKey] [int] NULL,
[PolicyResaonCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isExpenseAdded] [bit] NULL CONSTRAINT [DF__TripAirRe__isExp__58671BC9] DEFAULT ((0)),
[repricedAirPrice] [float] NULL,
[repricedAirTax] [float] NULL,
[repricedAirPriceBreakupKey] [int] NULL,
[bookingCharges] [float] NULL CONSTRAINT [DF__TripAirRe__booki__0D99FE17] DEFAULT ((0)),
[appliedDiscount] [float] NULL CONSTRAINT [default_tripexpense__appliedDiscount] DEFAULT ((0)),
[ValidatingCarrier] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discountedBaseFare] [float] NULL,
[discountedTax] [float] NULL,
[status] [int] NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF_TripAirResponse_isDeleted] DEFAULT ((0)),
[publishedAirPriceBreakupKey] [int] NULL,
[isOnlineBooking] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__isOnl__6DD739FB] DEFAULT ((1)),
[isSplit] [bit] NULL,
[agentWareQueryID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[agentwareItineraryID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[redeemPoints] [int] NULL,
[redeemAuthNumber] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirResponse] ADD CONSTRAINT [PK__TripAirR__78B637F87F60ED59] PRIMARY KEY CLUSTERED  ([tripAirResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_Get_TripAirResponse_actualAirPriceBreakupKey] ON [dbo].[TripAirResponse] ([actualAirPriceBreakupKey] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_TripAirResponse_Prices] ON [dbo].[TripAirResponse] ([airResponseKey]) INCLUDE ([actualAirPrice], [actualAirTax], [CurrencyCodeKey], [searchAirPrice], [searchAirTax]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TripAirResponse_tripGuidKey] ON [dbo].[TripAirResponse] ([tripGUIDKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripKey] ON [dbo].[TripAirResponse] ([tripKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Actual air Price.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'actualAirPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Actual air tax.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'actualAirTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Air Response key referecen to AirResponse table (airResponseKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'airResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Discount applied on ticket.  Default is 0.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'appliedDiscount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Booking Charges.  Default booking charges is 0.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'bookingCharges'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Currency Code (character).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'CurrencyCodeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicator whether Expense added.  Default is Expense not added (0).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'isExpenseAdded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Policy key reference to Policy table in vault (policyKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'PolicyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Policy Reason Code ID reference to PolicyReasonCodes table in Vault (PolicyReasonCodeID).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'PolicyReasonCodeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Policy Reason Code.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'PolicyResaonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Repriced Air Price.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'repricedAirPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flight Search air price in the flight list.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'searchAirPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flight Search air tax in the flight list.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'searchAirTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for TripAirResponse table.  Clustered Index field.  ', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'tripAirResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'GUID Key for introducing TripSaved/TripPurchased tables which both can store cart data in this table', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'tripGUIDKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trip key reference to Trip table (tripKey).  Mandatory Field.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponse', 'COLUMN', N'tripKey'
GO
