CREATE TABLE [dbo].[AirAncillaryLookup]
(
[AirAncillaryId] [int] NULL,
[ServiceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_AirAncillaryId] ON [dbo].[AirAncillaryLookup] ([AirAncillaryId], [ServiceType]) ON [PRIMARY]
GO
