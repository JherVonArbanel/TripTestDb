CREATE TABLE [dbo].[Trip_carResponse]
(
[tripKey] [int] NOT NULL,
[carResponseKey] [uniqueidentifier] NOT NULL,
[confirmationNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripCarTotalPrice] [float] NULL,
[tripCarCategoryCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripCarLocationCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripCarMinRate] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_carResponseKey] ON [dbo].[Trip_carResponse] ([carResponseKey]) ON [PRIMARY]
GO
