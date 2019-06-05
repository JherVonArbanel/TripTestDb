CREATE TABLE [dbo].[NormalizedAirResponses]
(
[airresponsekey] [uniqueidentifier] NULL,
[flightNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airlines] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airsubrequestkey] [int] NULL,
[airLegNumber] [int] NULL,
[airLegBookingClasses] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operatingAirlines] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airLegConnections] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cabinClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Originalcabinclass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[normaizeAirResponseKey] [bigint] NOT NULL IDENTITY(1, 1),
[airLegBrandName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isReturnFare] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NormalizedAirResponses] ON [dbo].[NormalizedAirResponses] ([airresponsekey], [airLegNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airLegBrandName] ON [dbo].[NormalizedAirResponses] ([airresponsekey], [airLegNumber], [airLegBrandName]) INCLUDE ([airLegConnections], [airlines], [cabinClass], [flightNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NormalizedAirResponses_INC_airsubrequestkey] ON [dbo].[NormalizedAirResponses] ([airsubrequestkey]) INCLUDE ([airLegBookingClasses], [airLegBrandName], [airLegConnections], [airLegNumber], [airlines], [airresponsekey], [cabinClass], [flightNumber], [isReturnFare], [normaizeAirResponseKey], [operatingAirlines], [Originalcabinclass]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airsubrequestkey] ON [dbo].[NormalizedAirResponses] ([airsubrequestkey], [airLegNumber]) INCLUDE ([airLegBrandName], [airresponsekey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tmpairsubrequestkey] ON [dbo].[NormalizedAirResponses] ([airsubrequestkey], [airLegNumber]) INCLUDE ([airLegBrandName], [airresponsekey]) ON [PRIMARY]
GO
