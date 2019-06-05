CREATE TYPE [dbo].[TVP_NormAirResponseMultiBrand] AS TABLE
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
[airLegBrandName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isReturnFare] [bit] NULL
)
GO
