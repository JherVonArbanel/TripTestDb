CREATE TABLE [dbo].[AirVendorClassLookup]
(
[AirVendorClassId] [int] NOT NULL IDENTITY(1, 1),
[AirVendorCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BookingClass] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CabinClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirVendorClassLookup] ADD CONSTRAINT [PK_AirVendorClassLookup] PRIMARY KEY CLUSTERED  ([AirVendorClassId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
