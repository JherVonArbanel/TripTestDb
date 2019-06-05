CREATE TABLE [dbo].[HotelAutoCompleteForZipCodeSearch]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[CityName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [int] NOT NULL,
[CountryCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CityCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[latitude] [real] NULL,
[longitude] [real] NULL,
[County] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
