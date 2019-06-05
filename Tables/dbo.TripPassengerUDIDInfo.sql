CREATE TABLE [dbo].[TripPassengerUDIDInfo]
(
[TripPassengerUDIDInfoKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[CompanyUDIDKey] [int] NULL,
[CompanyUDIDDescription] [nvarchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyUDIDNumber] [int] NULL,
[CompanyUDIDOptionID] [int] NULL,
[CompanyUDIDOptionCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyUDIDOptionText] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPrintInvoice] [bit] NULL,
[ReportFieldType] [int] NULL,
[TextEntryType] [int] NULL,
[UserID] [int] NULL,
[PassengerUDIDValue] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__14270015] DEFAULT ((1)),
[TripPassengerInfoKey] [int] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerUDIDInfo] ADD CONSTRAINT [PK__TripPass__C919D9843E52440B] PRIMARY KEY CLUSTERED  ([TripPassengerUDIDInfoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripPassengerUDIDInfo_GET_tripKey] ON [dbo].[TripPassengerUDIDInfo] ([TripKey] DESC) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerUDIDInfo', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Company UDID key reference to CompanyUDID table in vault (companyUDIDKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerUDIDInfo', 'COLUMN', N'CompanyUDIDKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates Print Invoice or not.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerUDIDInfo', 'COLUMN', N'IsPrintInvoice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerUDIDInfo', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerUDIDInfo table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerUDIDInfo', 'COLUMN', N'TripPassengerUDIDInfoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User id reference to User table in vault (userKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerUDIDInfo', 'COLUMN', N'UserID'
GO
