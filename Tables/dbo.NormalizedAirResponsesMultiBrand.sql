CREATE TABLE [dbo].[NormalizedAirResponsesMultiBrand]
(
[airresponseMultiBrandkey] [uniqueidentifier] NULL,
[airresponsekey] [uniqueidentifier] NULL,
[flightNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airlines] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airsubrequestkey] [int] NULL,
[airLegNumber] [int] NULL,
[airLegBookingClasses] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operatingAirlines] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airLegConnections] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cabinclass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Originalcabinclass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[normaizeAirResponseMultiBrandKey] [bigint] NOT NULL IDENTITY(1, 1),
[airLegBrandName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isReturnFare] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airLegNumber_airresponseMultiBrandkey_airresponsekey_airLegBrandName] ON [dbo].[NormalizedAirResponsesMultiBrand] ([airLegNumber]) INCLUDE ([airLegBrandName], [airresponsekey], [airresponseMultiBrandkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airLegNumber] ON [dbo].[NormalizedAirResponsesMultiBrand] ([airLegNumber], [airLegBrandName]) INCLUDE ([airresponseMultiBrandkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airResponseKey] ON [dbo].[NormalizedAirResponsesMultiBrand] ([airresponsekey], [airLegNumber]) INCLUDE ([airLegBrandName], [airresponseMultiBrandkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airresponseMultiBrandkey] ON [dbo].[NormalizedAirResponsesMultiBrand] ([airresponseMultiBrandkey], [airLegNumber]) INCLUDE ([airLegBookingClasses], [airLegBrandName], [airLegConnections], [cabinclass]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airsubrequestkey] ON [dbo].[NormalizedAirResponsesMultiBrand] ([airsubrequestkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NormalizedAirResponsesMultiBrand_INC_airsubrequestkey] ON [dbo].[NormalizedAirResponsesMultiBrand] ([airsubrequestkey]) INCLUDE ([airLegBookingClasses], [airLegBrandName], [airLegConnections], [airLegNumber], [airlines], [airresponsekey], [airresponseMultiBrandkey], [cabinclass], [flightNumber], [isReturnFare], [normaizeAirResponseMultiBrandKey], [operatingAirlines], [Originalcabinclass]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_airSubRequestKey_MultibrandKeyAndOther] ON [dbo].[NormalizedAirResponsesMultiBrand] ([airsubrequestkey]) INCLUDE ([airLegBookingClasses], [airLegBrandName], [airLegConnections], [airLegNumber], [airlines], [airresponsekey], [airresponseMultiBrandkey], [cabinclass], [flightNumber], [normaizeAirResponseMultiBrandKey], [operatingAirlines], [Originalcabinclass]) ON [PRIMARY]
GO
