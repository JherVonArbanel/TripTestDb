CREATE TABLE [dbo].[HotelBedsConnection]
(
[connectionId] [int] NULL,
[apiKey] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[secret] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hostUrl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[environment] [nchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[secureUrl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
