CREATE TABLE [dbo].[BasicEconomyPopupData]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[AirlineCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComponentIcon] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComponentText] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BasicText] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MainText] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BasicEconomyPopupData] ADD CONSTRAINT [PK_BasicEconomyPopupData] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
