CREATE TABLE [dbo].[DealsThresholdSettings]
(
[ThresholdKey] [int] NOT NULL IDENTITY(1, 1),
[ComponentTypeKey] [int] NULL,
[ComponentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThresholdPricePerDay] [float] NULL,
[ThresholdPriceHourly] [float] NULL,
[ThresholdPriceTrip] [float] NULL,
[StarRatingConsideration] [float] NULL,
[PriceCap] [float] NULL,
[RepetitionInterval] [float] NULL,
[StarRatingStep1_1] [float] NULL,
[StarRatingStep1_2] [float] NULL,
[StarRatingStep2_1] [float] NULL,
[MilesIteration] [int] NULL,
[MilesIncrement] [int] NULL,
[MilesStart] [int] NULL,
[MinRepetitionInterval] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DealsThresholdSettings] ADD CONSTRAINT [PK__tmp_ms_x__BDDEBFCC4E9398CC] PRIMARY KEY CLUSTERED  ([ThresholdKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DealsThresholdSettings] ADD CONSTRAINT [UQ__tmp_ms_x__AD02B10E51700577] UNIQUE NONCLUSTERED  ([ComponentTypeKey]) ON [PRIMARY]
GO
