CREATE TABLE [dbo].[CarRequestTripSavedDeal]
(
[PkId] [int] NOT NULL IDENTITY(1, 1),
[PkGroupId] [int] NULL,
[TripKey] [int] NULL,
[TripRequestKey] [int] NULL,
[NoOfDays] [int] NULL,
[NoOfCars] [int] NULL,
[PickupCityCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropOffCityCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickupDate] [datetime] NULL,
[DropOffDate] [datetime] NULL,
[IsSearched] [bit] NULL CONSTRAINT [DF__CarReques__IsSea__69B1A35C] DEFAULT ((0)),
[TripSavedKey] [uniqueidentifier] NULL,
[CarCategoryCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActualCarPrice] [float] NULL,
[ActualCarTax] [float] NULL,
[MinRate] [float] NULL,
[MinRateTax] [float] NULL,
[IsSuccess] [bit] NULL CONSTRAINT [DF__CarReques__IsSuc__4BB72C21] DEFAULT ((0)),
[UserKey] [int] NULL,
[FromCountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromCountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromStateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToCountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToCountryName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToStateCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromCityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToCityName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarRequestTripSavedDeal] ADD CONSTRAINT [PK__CarReque__A7C03FF867C95AEA] PRIMARY KEY CLUSTERED  ([PkId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripRequestKey] ON [dbo].[CarRequestTripSavedDeal] ([TripRequestKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripSavedKey] ON [dbo].[CarRequestTripSavedDeal] ([TripSavedKey]) ON [PRIMARY]
GO
