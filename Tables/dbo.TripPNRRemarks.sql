CREATE TABLE [dbo].[TripPNRRemarks]
(
[TripKey] [int] NOT NULL,
[RemarkFieldName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RemarkFieldValue] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripTypeKey] [smallint] NULL,
[RemarksDesc] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeneratedType] [smallint] NULL,
[CreatedOn] [datetime] NULL,
[Active] [bit] NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_TripPNRRemarks_GET_tripKey] ON [dbo].[TripPNRRemarks] ([TripKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicates the record is active or not.', 'SCHEMA', N'dbo', 'TABLE', N'TripPNRRemarks', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Created date and time.', 'SCHEMA', N'dbo', 'TABLE', N'TripPNRRemarks', 'COLUMN', N'CreatedOn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Remarks Field Name', 'SCHEMA', N'dbo', 'TABLE', N'TripPNRRemarks', 'COLUMN', N'RemarkFieldName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Remarks field value.', 'SCHEMA', N'dbo', 'TABLE', N'TripPNRRemarks', 'COLUMN', N'RemarkFieldValue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip key reference to Trip table (tripKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripPNRRemarks', 'COLUMN', N'TripKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trip Type Key.', 'SCHEMA', N'dbo', 'TABLE', N'TripPNRRemarks', 'COLUMN', N'TripTypeKey'
GO
