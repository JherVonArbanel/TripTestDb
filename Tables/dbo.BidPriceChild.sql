CREATE TABLE [dbo].[BidPriceChild]
(
[PkIdChild] [int] NOT NULL IDENTITY(1, 1),
[FkId] [int] NULL,
[AirResponseKey] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price] [float] NULL,
[ComponentType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BidPriceChild] ADD CONSTRAINT [PK__BidPrice__9D41E7635887175A] PRIMARY KEY CLUSTERED  ([PkIdChild]) ON [PRIMARY]
GO
