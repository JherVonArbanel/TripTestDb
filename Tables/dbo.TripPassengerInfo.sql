CREATE TABLE [dbo].[TripPassengerInfo]
(
[TripPassengerInfoKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[PassengerTypeKey] [int] NULL,
[TripRequestKey] [int] NULL,
[IsPrimaryPassenger] [bit] NULL,
[AdditionalRequest] [nvarchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__1332DBDC] DEFAULT ((1)),
[PassengerEmailID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerFirstName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerLastName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerLocale] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerTitle] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerGender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerBirthDate] [datetime] NULL,
[TravelReferenceNo] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerRedressNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerKnownTravellerNo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripHistoryKey] [uniqueidentifier] NULL,
[IsExcludePricingInfo] [bit] NULL,
[ReimbursementAddressId] [int] NULL,
[CellPhone] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrangerEmailCSV] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsArrangerEmailWithWithoutPricing] [bit] NULL,
[IsArrangerEmailWithPricing] [bit] NULL,
[IsArrangerEmailWithoutPricing] [bit] NULL,
[IROPPassengerKey] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerInfo] ADD CONSTRAINT [PK__TripPass__F9F6A91C4222D4EF] PRIMARY KEY CLUSTERED  ([TripPassengerInfoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_Active] ON [dbo].[TripPassengerInfo] ([Active]) INCLUDE ([IsExcludePricingInfo], [IsPrimaryPassenger], [PassengerBirthDate], [PassengerEmailID], [PassengerFirstName], [PassengerGender], [PassengerKey], [PassengerLastName], [PassengerLocale], [PassengerRedressNo], [PassengerTitle], [PassengerTypeKey], [TravelReferenceNo], [TripKey], [TripPassengerInfoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripPassengerInfo_GET_Active_tripKey] ON [dbo].[TripPassengerInfo] ([Active], [TripKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_IsPrimaryPassenger] ON [dbo].[TripPassengerInfo] ([IsPrimaryPassenger], [TripKey]) INCLUDE ([PassengerFirstName], [PassengerLastName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TripPassengerInfo_TripKey] ON [dbo].[TripPassengerInfo] ([TripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TripPassengerInfo_TripKey_IsPrimaryPassenger] ON [dbo].[TripPassengerInfo] ([TripKey], [IsPrimaryPassenger]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates Primary Passenger or not.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'IsPrimaryPassenger'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger email id.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'PassengerEmailID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger first name.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'PassengerFirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger last name.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'PassengerLastName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger type key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'PassengerTypeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip Key reference to trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerInfo table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'TripPassengerInfoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip Request key reference to tripRequest table (tripRequestKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerInfo', 'COLUMN', N'TripRequestKey'
GO
