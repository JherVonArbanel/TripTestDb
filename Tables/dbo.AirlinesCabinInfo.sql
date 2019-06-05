CREATE TABLE [dbo].[AirlinesCabinInfo]
(
[BookingClass] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirlineCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CabinClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirlineCode] ON [dbo].[AirlinesCabinInfo] ([AirlineCode]) ON [PRIMARY]
GO
