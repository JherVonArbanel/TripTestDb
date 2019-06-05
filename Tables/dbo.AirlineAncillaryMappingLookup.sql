CREATE TABLE [dbo].[AirlineAncillaryMappingLookup]
(
[AirlineCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirAncillaryId] [int] NULL,
[Fees] [float] NULL,
[Type] [bit] NULL,
[AncillaryText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AirAncillaryId] ON [dbo].[AirlineAncillaryMappingLookup] ([AirAncillaryId]) INCLUDE ([AirlineCode], [AncillaryText], [Fees], [Type]) ON [PRIMARY]
GO
