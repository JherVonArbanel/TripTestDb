CREATE TABLE [dbo].[Trip_hotelResponse]
(
[tripKey] [int] NOT NULL,
[hotelResponseDetailKey] [int] NULL,
[hotelResponseKey] [uniqueidentifier] NOT NULL,
[confirmationNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripHotelTotalPrice] [float] NULL,
[tripHotelGuranteeCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripHotelDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_hotelResponseKey] ON [dbo].[Trip_hotelResponse] ([hotelResponseKey]) ON [PRIMARY]
GO
