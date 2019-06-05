CREATE TABLE [dbo].[TripHashTagMapping]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NOT NULL,
[HashTag] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventKey] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripHashTagMapping] ADD CONSTRAINT [PK_TripHashTagMapping] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripHashTagMapping_TripKey] ON [dbo].[TripHashTagMapping] ([TripKey]) ON [PRIMARY]
GO
