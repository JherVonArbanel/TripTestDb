CREATE TABLE [dbo].[TripPolicyException]
(
[TripPolicyException] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[TripRequestKey] [int] NULL,
[TimeBandTotalThresholdAmt] [float] NULL,
[AlternateAirportTotalThresholdAmt] [float] NULL,
[AdvancePurchaseAirportTotalThresholdAmt] [float] NULL,
[penaltyFareTotalThresholdAmt] [float] NULL,
[xConnectionsPolicyTotalThresholdAmt] [float] NULL,
[lowestPriceOfTrip] [float] NULL,
[ReasonCode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PolicyKey] [int] NULL,
[ReasonDescription] [nvarchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[thresholdamt] [float] NULL,
[LowFarePolicyAmt] [float] NULL,
[LowestAmtFromAllPolicy] [float] NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPolic__Activ__151B244E] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPolicyException] ADD CONSTRAINT [PK__TripPoli__2ADAA2C6398D8EEE] PRIMARY KEY CLUSTERED  ([TripPolicyException]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripPolicyException_GET_tripKey] ON [dbo].[TripPolicyException] ([TripKey] DESC) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPolicyException', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Policy key reference to Policy table in vault (policyKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPolicyException', 'COLUMN', N'PolicyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPolicyException', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPolicyException table.  Clustered index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPolicyException', 'COLUMN', N'TripPolicyException'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip Request Key reference to TripRequest table (tripRequestKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPolicyException', 'COLUMN', N'TripRequestKey'
GO
