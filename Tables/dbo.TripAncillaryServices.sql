CREATE TABLE [dbo].[TripAncillaryServices]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[TypeOfAncillary] [int] NULL,
[ServiceFeeVendorCode] [float] NULL,
[InvoiceNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalAmountCharged] [float] NULL,
[MaskedCardNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[TripKey] [int] NULL,
[DocumentNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsXAC] [bit] NULL,
[InvoiceDateTime] [datetime] NULL,
[NameOnCard] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAncillaryServices] ADD CONSTRAINT [PK__TripAnci__3214EC07690F0687] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
