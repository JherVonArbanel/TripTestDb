CREATE TABLE [dbo].[AirlineCabin]
(
[AirlineCabinId] [int] NOT NULL IDENTITY(1, 1),
[AirVendorCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BookingClass] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CabinClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
