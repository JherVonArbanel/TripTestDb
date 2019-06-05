CREATE TABLE [dbo].[TripHotelPolicyException]
(
[TripHotelPolicyException] [int] NOT NULL IDENTITY(1, 1),
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
[Active] [bit] NULL CONSTRAINT [DF__TripHotel__Activ__4440F2E2] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
