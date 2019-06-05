CREATE TABLE [dbo].[HotelIdMappingForSearchType_BCP]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[pkId] [int] NOT NULL,
[type] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SupplierIds] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column3] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column4] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column5] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column6] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column7] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column8] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column9] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column10] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column11] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column12] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column13] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column14] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column15] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChunkedSupplierIds] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HotelIdMappingForSearchType_BCP] ADD CONSTRAINT [PK_HotelIdMappingForSearchType] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
