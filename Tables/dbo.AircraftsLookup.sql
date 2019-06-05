CREATE TABLE [dbo].[AircraftsLookup]
(
[AircraftCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubTypeCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AircraftName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AirSpeed] [int] NULL,
[AircraftType] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WideBody] [bit] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AircraftCode] ON [dbo].[AircraftsLookup] ([AircraftCode], [AircraftName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_SubTypeCode] ON [dbo].[AircraftsLookup] ([SubTypeCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_AircraftsLookup_GET_SubTypeCode_AircraftCode] ON [dbo].[AircraftsLookup] ([SubTypeCode], [AircraftCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_AircraftCode] ON [dbo].[AircraftsLookup] ([SubTypeCode], [AircraftCode]) INCLUDE ([AircraftName]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Aircraft Code.', 'SCHEMA', N'dbo', 'TABLE', N'AircraftsLookup', 'COLUMN', N'AircraftCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Aircraft Name.', 'SCHEMA', N'dbo', 'TABLE', N'AircraftsLookup', 'COLUMN', N'AircraftName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Aircraft Type.', 'SCHEMA', N'dbo', 'TABLE', N'AircraftsLookup', 'COLUMN', N'AircraftType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Speed of aircraft.', 'SCHEMA', N'dbo', 'TABLE', N'AircraftsLookup', 'COLUMN', N'AirSpeed'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Aircraft Subtype Code.  Non-Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'AircraftsLookup', 'COLUMN', N'SubTypeCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag to indicate aircraft having widebody.', 'SCHEMA', N'dbo', 'TABLE', N'AircraftsLookup', 'COLUMN', N'WideBody'
GO
