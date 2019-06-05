CREATE TABLE [dbo].[TripAirLegPassengerInfo]
(
[tripAirLegPassengerInfoKey] [int] NOT NULL IDENTITY(1, 1),
[tripAirLegKey] [int] NOT NULL,
[tripPassengerInfoKey] [int] NOT NULL,
[ticketNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirLegPassengerInfo] ADD CONSTRAINT [PK_TripAirLegPassengerInfo] PRIMARY KEY CLUSTERED  ([tripAirLegPassengerInfoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripAirLegPassengerInfo_GET_tripAirLegKey] ON [dbo].[TripAirLegPassengerInfo] ([tripAirLegKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
