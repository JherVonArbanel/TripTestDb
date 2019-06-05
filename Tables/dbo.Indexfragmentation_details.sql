CREATE TABLE [dbo].[Indexfragmentation_details]
(
[uniqueValue] [uniqueidentifier] NOT NULL,
[DatabaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[indexName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg_fragmentation_percent] [float] NULL,
[page_count] [float] NULL,
[Command_For_Rebuild] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Indexfrag__Comma__7148A383] DEFAULT ('NA'),
[CreatedDate] [datetime] NULL,
[NumberOfSearch] [int] NULL
) ON [PRIMARY]
GO
