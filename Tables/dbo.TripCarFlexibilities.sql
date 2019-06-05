CREATE TABLE [dbo].[TripCarFlexibilities]
(
[carFlexibilityKey] [int] NOT NULL IDENTITY(1, 1),
[carResponseKey] [uniqueidentifier] NOT NULL,
[carCompanies] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flexibleCarType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carRateTypeOptions] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isOffAirpot] [bit] NULL,
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[NoOfCars] [int] NULL
) ON [PRIMARY]
GO
