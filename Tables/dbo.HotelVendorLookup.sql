CREATE TABLE [dbo].[HotelVendorLookup]
(
[hotelVendorCode] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hotelVendorName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_hotelVendorCode] ON [dbo].[HotelVendorLookup] ([hotelVendorCode], [hotelVendorName]) ON [PRIMARY]
GO
