CREATE TABLE [dbo].[TripAirLegsHistory]
(
[tripAirLegsKey] [int] NOT NULL,
[airResponseKey] [uniqueidentifier] NOT NULL,
[gdsSourceKey] [int] NULL,
[selectedBrand] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airLegNumber] [int] NULL,
[tripKey] [int] NULL,
[isDeleted] [bit] NULL,
[ValidatingCarrier] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contractCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isRefundable] [bit] NULL
) ON [PRIMARY]
GO
