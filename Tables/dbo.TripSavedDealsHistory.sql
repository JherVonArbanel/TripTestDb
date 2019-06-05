CREATE TABLE [dbo].[TripSavedDealsHistory]
(
[TripSavedDealKey] [int] NOT NULL,
[tripKey] [int] NULL,
[responseKey] [uniqueidentifier] NULL,
[componentType] [int] NULL,
[currentPerPersonPrice] [float] NULL,
[originalPerPersonPrice] [float] NULL,
[fareCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseDetailKey] [uniqueidentifier] NULL,
[creationDate] [datetime] NULL,
[dealSentDate] [datetime] NULL,
[processedDate] [datetime] NULL,
[isAlternate] [bit] NULL,
[vendorDetails] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currentTotalPrice] [float] NULL,
[originalTotalPrice] [float] NULL,
[Remarks] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currentListPagePrice] [float] NULL,
[isCrowd] [bit] NULL
) ON [PRIMARY]
GO
