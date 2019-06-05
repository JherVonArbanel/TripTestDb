CREATE TABLE [dbo].[CarNightlyPrice]
(
[PkId] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerEmailId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMailSent] [bit] NULL CONSTRAINT [DF__CarNightl__IsMai__5F3414E9] DEFAULT ((0)),
[IsUpdated] [bit] NULL CONSTRAINT [DF__CarNightl__IsUpd__60283922] DEFAULT ((0)),
[CarResponseDetailKey] [uniqueidentifier] NULL,
[CarResponseKey] [uniqueidentifier] NULL,
[CarVendorKey] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplierId] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarCategoryCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinRate] [float] NULL,
[MinRateTax] [float] NULL,
[CurrentMinimumPrice] [float] NULL,
[BookedPrice] [float] NULL,
[NoOfDays] [int] NULL,
[PkGroupId] [int] NULL,
[CreationDate] [datetime] NULL CONSTRAINT [DF__CarNightl__Creat__611C5D5B] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarNightlyPrice] ADD CONSTRAINT [PK__CarNight__A7C03FF85D4BCC77] PRIMARY KEY CLUSTERED  ([PkId]) ON [PRIMARY]
GO
