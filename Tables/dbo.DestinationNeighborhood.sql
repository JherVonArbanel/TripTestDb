CREATE TABLE [dbo].[DestinationNeighborhood]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Destination] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Neighborhood] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionId] [int] NULL CONSTRAINT [DF__Destinati__Regio__721CCC2B] DEFAULT (NULL)
) ON [PRIMARY]
GO
