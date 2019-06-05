CREATE TABLE [dbo].[TripTicketInfo]
(
[tripTicketInfoKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NOT NULL,
[recordLocator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isExchanged] [bit] NOT NULL,
[isVoided] [bit] NOT NULL,
[isRefunded] [bit] NOT NULL,
[oldTicketNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[newTicketNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdDate] [datetime] NULL,
[issuedDate] [datetime] NULL,
[currency] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oldFare] [float] NULL,
[newFare] [float] NULL,
[addCollectFare] [float] NULL,
[serviceCharge] [float] NULL,
[residualFare] [float] NULL,
[TotalFare] [float] NULL,
[ExchangeFee] [float] NULL,
[TripHistoryKey] [uniqueidentifier] NULL,
[BaseFare] [float] NULL,
[TaxFare] [float] NULL,
[IsHostStatusTicketed] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripTicketInfo] ADD CONSTRAINT [PK_TripTicketInfo] PRIMARY KEY CLUSTERED  ([tripTicketInfoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_] ON [dbo].[TripTicketInfo] ([isExchanged]) INCLUDE ([ExchangeFee], [TotalFare], [tripTicketInfoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripTicketInfo_TripKey] ON [dbo].[TripTicketInfo] ([tripKey]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Add Collect Fare of Exchanged ticket.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'addCollectFare'
GO
EXEC sp_addextendedproperty N'MS_Description', N'creating date of ticketing', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'createdDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'currency', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'currency'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For Exchanged Ticket.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'isExchanged'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For Refunded Ticket.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'isRefunded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Issued date of Ticketing', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'issuedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For Voided Ticket.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'isVoided'
GO
EXEC sp_addextendedproperty N'MS_Description', N'new Fare found in NF tag from PNR response.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'newFare'
GO
EXEC sp_addextendedproperty N'MS_Description', N'old Fare found in OF tag from PNR response.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'oldFare'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Old Ticket Number (Original Ticket Number)', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'oldTicketNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It is recordlocator of GDS.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'recordLocator'
GO
EXEC sp_addextendedproperty N'MS_Description', N'amount to refund if any money is left over', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'residualFare'
GO
EXEC sp_addextendedproperty N'MS_Description', N'service charge of ticket.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'serviceCharge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trip key reference to Trip table (tripKey).  Mandatory Field.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'tripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for TripTicketInfo table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripTicketInfo', 'COLUMN', N'tripTicketInfoKey'
GO
