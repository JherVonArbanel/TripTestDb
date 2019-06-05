CREATE TABLE [dbo].[AirVendorLookup_20190423]
(
[AirlineCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICAOCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShortName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CategoryType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResPhoneNumber] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Website] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Preference] [int] NULL,
[SabreIMAP] [tinyint] NOT NULL,
[FLXSeatMap] [tinyint] NOT NULL,
[AirlineProgrammes] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirVendorGroupKey] [int] NULL,
[isValidAirline] [bit] NULL,
[IsSeatChooseAvailable] [bit] NOT NULL
) ON [PRIMARY]
GO
