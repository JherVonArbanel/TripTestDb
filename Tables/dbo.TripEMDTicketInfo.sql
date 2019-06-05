CREATE TABLE [dbo].[TripEMDTicketInfo]
(
[tripEMDTicketInfoKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NOT NULL,
[recordLocator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalFare] [float] NOT NULL,
[TotalBaseFare] [float] NOT NULL,
[TotalTaxFare] [float] NOT NULL,
[createdDate] [datetime] NOT NULL CONSTRAINT [DF_TripEMDTicketInfo_createdDate] DEFAULT (getdate()),
[FlightNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirlineCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssuedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripEMDTicketInfo] ADD CONSTRAINT [PK_TripEMDTicketInfo] PRIMARY KEY CLUSTERED  ([tripEMDTicketInfoKey]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'creating date of ticketing', 'SCHEMA', N'dbo', 'TABLE', N'TripEMDTicketInfo', 'COLUMN', N'createdDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Old Ticket Number (Original Ticket Number)', 'SCHEMA', N'dbo', 'TABLE', N'TripEMDTicketInfo', 'COLUMN', N'DocumentNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It is recordlocator of GDS.', 'SCHEMA', N'dbo', 'TABLE', N'TripEMDTicketInfo', 'COLUMN', N'recordLocator'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for TripTicketInfo table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripEMDTicketInfo', 'COLUMN', N'tripEMDTicketInfoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trip key reference to Trip table (tripKey).  Mandatory Field.', 'SCHEMA', N'dbo', 'TABLE', N'TripEMDTicketInfo', 'COLUMN', N'tripKey'
GO
