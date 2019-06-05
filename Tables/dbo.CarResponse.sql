CREATE TABLE [dbo].[CarResponse]
(
[carResponseKey] [uniqueidentifier] NOT NULL,
[carRequestKey] [int] NOT NULL,
[carVendorKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[supplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[carCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[carLocationCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[carLocationCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[minRate] [float] NOT NULL,
[minRateTax] [float] NOT NULL CONSTRAINT [DF_CarResponse_minRateTax] DEFAULT ((0)),
[DailyRate] [float] NULL,
[TotalChargeAmt] [float] NULL,
[NoOfDays] [int] NULL,
[RateQualifier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceDateTime] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MileageAllowance] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RatePlan] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationTimeStart] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationTimeEnd] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickupLocationInfo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickupLocInfoCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carDropOffLocationCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carDropOffLocationCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickupDistance] [float] NULL,
[DropDistance] [float] NULL,
[PickupDistanceUnit] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropDistanceUnit] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickupAddress] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropAddress] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequestType] [int] NULL,
[PickUpLatLong] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropOffLatLong] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inTerminal] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_carRequestKey] ON [dbo].[CarResponse] ([carRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_carResponseKey] ON [dbo].[CarResponse] ([carRequestKey], [carResponseKey], [carCategoryCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CarResponseKey] ON [dbo].[CarResponse] ([carResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
