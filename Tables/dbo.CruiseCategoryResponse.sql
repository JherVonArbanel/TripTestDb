CREATE TABLE [dbo].[CruiseCategoryResponse]
(
[CruiseCategoryResponseKey] [uniqueidentifier] NOT NULL,
[CruiseFareResponseKey] [uniqueidentifier] NULL,
[pricedCategory] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[berthedCategory] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipLocation] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[maxCabinOccupancy] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[indicators] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountQualifierCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[breakdownCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[breakdownQualifierCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CruiseCategoryResponse] ADD CONSTRAINT [PK_CruiseCategoryResponse] PRIMARY KEY CLUSTERED  ([CruiseCategoryResponseKey]) ON [PRIMARY]
GO
