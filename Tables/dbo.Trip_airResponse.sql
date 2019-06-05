CREATE TABLE [dbo].[Trip_airResponse]
(
[tripKey] [int] NOT NULL,
[airResponseKey] [uniqueidentifier] NOT NULL,
[selectedBrand] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airLegNumber] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airResponseKey] ON [dbo].[Trip_airResponse] ([airResponseKey]) ON [PRIMARY]
GO
