CREATE TABLE [dbo].[PricelineConnection]
(
[connectionId] [int] NOT NULL,
[refid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apiKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hostUrl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PricelineConnection] ADD CONSTRAINT [PK_PricelineConnection] PRIMARY KEY CLUSTERED  ([connectionId]) ON [PRIMARY]
GO
