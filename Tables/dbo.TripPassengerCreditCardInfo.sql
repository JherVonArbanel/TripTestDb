CREATE TABLE [dbo].[TripPassengerCreditCardInfo]
(
[TripPassengerCreditCardInfoKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerKey] [int] NULL,
[TripTypeComponent] [int] NULL,
[CreditCardKey] [int] NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripPasse__Activ__10566F31] DEFAULT ((1)),
[creditCardVendorCode] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creditCardDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creditCardLastFourDigit] [int] NULL,
[expiryMonth] [int] NULL,
[expiryYear] [int] NULL,
[creditCardTypeKey] [int] NULL,
[TripPassengerInfoKey] [int] NULL,
[NameOnCard] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripHistoryKey] [uniqueidentifier] NULL,
[UsedforAir] [bit] NULL CONSTRAINT [DF__TripPasse__Usedf__417994D0] DEFAULT ((0)),
[UsedforHotel] [bit] NULL CONSTRAINT [DF__TripPasse__Usedf__426DB909] DEFAULT ((0)),
[UsedforCar] [bit] NULL CONSTRAINT [DF__TripPasse__Usedf__4361DD42] DEFAULT ((0)),
[PTACode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPassengerCreditCardInfo] ADD CONSTRAINT [PK__TripPass__F5F2949E4D94879B] PRIMARY KEY CLUSTERED  ([TripPassengerCreditCardInfoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_Active] ON [dbo].[TripPassengerCreditCardInfo] ([TripKey], [Active]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates whether the record is active or not.  Default is active (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Credit card key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'CreditCardKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Last 4 digits of credit card.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'creditCardLastFourDigit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Credit card type key reference to CreditCardTypeLookup table in vault (creditCardTypeKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'creditCardTypeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Credit card vendor code reference to CreditCardProviderLookup table in vault (CreditCardProviderKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'creditCardVendorCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expiry month of credit card.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'expiryMonth'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expiry year of credit card.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'expiryYear'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Passenger key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'PassengerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripPassengerCreditCardInfo table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'TripPassengerCreditCardInfoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip type component.', 'SCHEMA', N'dbo', 'TABLE', N'TripPassengerCreditCardInfo', 'COLUMN', N'TripTypeComponent'
GO
