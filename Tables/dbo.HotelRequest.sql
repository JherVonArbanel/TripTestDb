CREATE TABLE [dbo].[HotelRequest]
(
[hotelRequestKey] [int] NOT NULL IDENTITY(1, 1),
[hotelCityCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkInDate] [datetime] NOT NULL,
[checkOutDate] [datetime] NOT NULL,
[hotelRequestCreated] [datetime] NOT NULL,
[hotelAddress] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoofRooms] [int] NULL CONSTRAINT [DF__HotelRequ__NoofR__73501C2F] DEFAULT ((1)),
[HotelGroupId] [int] NULL,
[CityId] [int] NULL,
[tripCreationPath] [int] NULL,
[ZipCodeID] [int] NULL,
[latitude] [float] NULL,
[longitude] [float] NULL,
[IsInternationalTrip] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HotelRequest] ADD CONSTRAINT [PK_HotelRequest] PRIMARY KEY CLUSTERED  ([hotelRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
