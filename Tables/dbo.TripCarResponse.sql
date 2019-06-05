CREATE TABLE [dbo].[TripCarResponse]
(
[TripCarResponseKey] [int] NOT NULL IDENTITY(1, 1),
[carResponseKey] [uniqueidentifier] NOT NULL,
[tripKey] [int] NULL,
[tripGUIDKey] [uniqueidentifier] NULL,
[carVendorKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[supplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[carCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[carLocationCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[carLocationCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[minRate] [float] NOT NULL,
[minRateTax] [float] NOT NULL CONSTRAINT [DF__TripCarRe__minRa__4E88ABD4] DEFAULT ((0)),
[DailyRate] [float] NULL,
[TotalChargeAmt] [float] NULL,
[NoOfDays] [int] NULL,
[SearchCarPrice] [float] NOT NULL,
[searchCarTax] [float] NULL CONSTRAINT [DF__TripCarRe__searc__4F7CD00D] DEFAULT ((0)),
[actualCarPrice] [float] NULL,
[actualCarTax] [float] NULL CONSTRAINT [DF__TripCarRe__actua__5070F446] DEFAULT ((0)),
[pickUpDate] [datetime] NULL,
[dropOutDate] [datetime] NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmationNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCodeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PolicyReasonCodeID] [int] NULL,
[CarPolicyKey] [int] NULL,
[PolicyResaonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isExpenseAdded] [bit] NULL CONSTRAINT [DF__TripCarRe__isExp__595B4002] DEFAULT ((0)),
[status] [int] NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF_TripCarResponse_isDeleted] DEFAULT ((0)),
[contractCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creationDate] [datetime] NULL,
[TripPassengerInfoKey] [int] NULL,
[rateTypeCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carRules] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationTimeStart] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationTimeEnd] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickupLocationInfo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isOnlineBooking] [bit] NULL CONSTRAINT [DF__tmp_ms_xx__isOnl__71DCD509] DEFAULT ((1)),
[InvoiceNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__Invoi__72D0F942] DEFAULT (NULL),
[MileageAllowance] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tmp_ms_xx__Milea__73C51D7B] DEFAULT (NULL),
[RPH] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TripCarResp__RPH__11207638] DEFAULT (NULL),
[PhoneNumber] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carDropOffLocationCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carDropOffLocationCategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsChangeTripCar] [bit] NULL,
[PickupAddress] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropAddress] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequestType] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripCarResponse] ADD CONSTRAINT [PK__TripCarR__AF1CADA8403A8C7D] PRIMARY KEY CLUSTERED  ([TripCarResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripCarResponse_CarResponseKey] ON [dbo].[TripCarResponse] ([carResponseKey]) INCLUDE ([SearchCarPrice], [searchCarTax]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_isDeleted_1] ON [dbo].[TripCarResponse] ([isDeleted]) INCLUDE ([actualCarPrice], [actualCarTax], [carCategoryCode], [carLocationCategoryCode], [carLocationCode], [carResponseKey], [carVendorKey], [dropOutDate], [NoOfDays], [pickUpDate], [recordLocator], [RPH], [supplierId], [tripGUIDKey], [tripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_isDeleted] ON [dbo].[TripCarResponse] ([isDeleted]) INCLUDE ([actualCarPrice], [actualCarTax], [carCategoryCode], [carLocationCategoryCode], [carLocationCode], [carResponseKey], [carVendorKey], [dropOutDate], [NoOfDays], [pickUpDate], [RPH], [supplierId], [tripGUIDKey], [tripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TripCarResponse_SupplierId_carVendorKey] ON [dbo].[TripCarResponse] ([supplierId], [carVendorKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IND_tripGUIDKey] ON [dbo].[TripCarResponse] ([tripGUIDKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IND_tripCarKey] ON [dbo].[TripCarResponse] ([tripKey]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Actual Tax.  Default is 0.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'actualCarTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Category code.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'carCategoryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Location Category Code.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'carLocationCategoryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Location code.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'carLocationCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car policy key.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'CarPolicyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Response key reference to CarResponse table (carResponseKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'carResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car vendor key reference to CarVendorLookup table (carVendorCode).', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'carVendorKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Confirmation number.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'confirmationNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Currency Code.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'CurrencyCodeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Drop-out date.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'dropOutDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag Indicates Trip amount need to add as Expense.  Default is Not added (0).', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'isExpenseAdded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum Rate.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'minRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum Rate Tax.  Default tax is 0.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'minRateTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Number of Days need a car.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'NoOfDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car pickup date.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'pickUpDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Policy Reason Code ID reference to PolicyReasonCodes table in vault db (PolicyReasonCodeID).', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'PolicyReasonCodeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Policy reason code.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'PolicyResaonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Searched car price.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'SearchCarPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Tax while searching.  Default tax is 0.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'searchCarTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Car Supplier ID.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'supplierId'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Amount.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'TotalChargeAmt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for TripCarResponse table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'TripCarResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'GUID Key for introducing TripSaved/TripPurchased tables which both can store cart data in this table', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'tripGUIDKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trip key reference to Trip table (tripKey).  Foreign Key reference with trip table.', 'SCHEMA', N'dbo', 'TABLE', N'TripCarResponse', 'COLUMN', N'tripKey'
GO
