CREATE TABLE [dbo].[SeatMapConfiguration]
(
[seatMapKey] [int] NOT NULL IDENTITY(1, 1),
[gdsSourceKey] [int] NOT NULL,
[AirlinesForSelection] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirlinesForView] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primaryGDSSourceKey] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SeatMapConfiguration] ADD CONSTRAINT [PK_SeatMapConfiguration] PRIMARY KEY CLUSTERED  ([seatMapKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_primaryGDSSourceKey] ON [dbo].[SeatMapConfiguration] ([primaryGDSSourceKey]) INCLUDE ([AirlinesForSelection], [AirlinesForView], [gdsSourceKey]) ON [PRIMARY]
GO
