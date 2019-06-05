CREATE TABLE [dbo].[BrandNameLookup]
(
[brandNameLookupKey] [int] NOT NULL IDENTITY(1, 1),
[brandName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[derivedBrandName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BrandNameLookup] ADD CONSTRAINT [PK_NewBrandNameLookup] PRIMARY KEY NONCLUSTERED  ([brandNameLookupKey]) ON [PRIMARY]
GO
