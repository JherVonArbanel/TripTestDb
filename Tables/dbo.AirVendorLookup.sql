CREATE TABLE [dbo].[AirVendorLookup]
(
[AirlineCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICAOCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShortName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CategoryType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResPhoneNumber] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Website] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Preference] [int] NULL,
[SabreIMAP] [tinyint] NOT NULL CONSTRAINT [DF_AirVendorLookup_SabreIMap] DEFAULT ((0)),
[FLXSeatMap] [tinyint] NOT NULL CONSTRAINT [DF_AirVendorLookup_FLXSeatMap] DEFAULT ((0)),
[AirlineProgrammes] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirVendorGroupKey] [int] NULL,
[isValidAirline] [bit] NULL,
[IsSeatChooseAvailable] [bit] NOT NULL CONSTRAINT [DF__AirVendor__IsSea__74450BBF] DEFAULT ((1))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirlineCode] ON [dbo].[AirVendorLookup] ([AirlineCode]) INCLUDE ([IsSeatChooseAvailable]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_airlineCode] ON [dbo].[AirVendorLookup] ([AirlineCode]) INCLUDE ([ShortName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_airLinecode] ON [dbo].[AirVendorLookup] ([AirlineCode], [ShortName], [AirlineProgrammes]) INCLUDE ([IsSeatChooseAvailable]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_CategoryType] ON [dbo].[AirVendorLookup] ([CategoryType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_Preference] ON [dbo].[AirVendorLookup] ([Preference]) ON [PRIMARY]
GO
