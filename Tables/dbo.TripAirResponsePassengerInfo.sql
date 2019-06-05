CREATE TABLE [dbo].[TripAirResponsePassengerInfo]
(
[TripAirResponsePassengerInfoKey] [int] NOT NULL IDENTITY(1, 1),
[AirResponsekey] [uniqueidentifier] NOT NULL,
[TripPassengerInfoKey] [int] NOT NULL,
[ConfirmationID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PNRID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
