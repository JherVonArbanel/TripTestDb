CREATE TABLE [dbo].[TripStatusHistory]
(
[tripStatusHistoryKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NULL,
[tripStatusKey] [int] NULL,
[createdDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripStatusHistory] ADD CONSTRAINT [PK__tmp_ms_x__9DF0A551E8691C4C] PRIMARY KEY CLUSTERED  ([tripStatusHistoryKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
