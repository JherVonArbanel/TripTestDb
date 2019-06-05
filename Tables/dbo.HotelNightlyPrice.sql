CREATE TABLE [dbo].[HotelNightlyPrice]
(
[PkId] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[PassengerEmailId] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMailSent] [bit] NULL CONSTRAINT [DF__HotelNigh__IsMai__76177A41] DEFAULT ((0)),
[HotelResponseDetailKey] [uniqueidentifier] NULL,
[HotelResponseKey] [uniqueidentifier] NULL,
[SupplierId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HotelDailyPrice] [float] NULL,
[CurrentMinimumPrice] [float] NULL,
[BookedPrice] [float] NULL,
[PkGroupId] [int] NULL,
[CreationDate] [datetime] NULL CONSTRAINT [DF__HotelNigh__Creat__770B9E7A] DEFAULT (getdate()),
[FareCategory] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HotelNightlyPrice] ADD CONSTRAINT [PK__HotelNig__A7C03FF8742F31CF] PRIMARY KEY CLUSTERED  ([PkId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SupplierId] ON [dbo].[HotelNightlyPrice] ([SupplierId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripKey] ON [dbo].[HotelNightlyPrice] ([TripKey]) ON [PRIMARY]
GO
