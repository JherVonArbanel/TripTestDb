CREATE TABLE [dbo].[ServiceFeeVendorLookup]
(
[FeeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Indicator] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorCode] [float] NULL,
[Id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ServiceFeeVendorLookup] ADD CONSTRAINT [PK__ServiceF__3214EC0794900C9B] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
