CREATE TABLE [dbo].[CruiseCabinResponse]
(
[CruiseCabinResponseKey] [uniqueidentifier] NOT NULL,
[CruiseCategoryResponseKey] [uniqueidentifier] NULL,
[cabinNbr] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[remark] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[positionInShip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[maxOccupancy] [int] NULL,
[deckId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bedType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bedConfiguration] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cabinStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
