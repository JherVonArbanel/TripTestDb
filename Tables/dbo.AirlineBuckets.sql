CREATE TABLE [dbo].[AirlineBuckets]
(
[airlineCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[airlineSuperSaver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airlineEconSaver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airlineFirstFlex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airlineCorporate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airlineEconFlex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airlineEconUpgrade] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirlineBuckets] ADD CONSTRAINT [PK_AirlineBuckets] PRIMARY KEY CLUSTERED  ([airlineCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary for AirlineBuckets table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBuckets', 'COLUMN', N'airlineCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Airline Corporate name.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBuckets', 'COLUMN', N'airlineCorporate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Econ Flex name.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBuckets', 'COLUMN', N'airlineEconFlex'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Econ saver name.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBuckets', 'COLUMN', N'airlineEconSaver'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Econ Upgrade name.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBuckets', 'COLUMN', N'airlineEconUpgrade'
GO
EXEC sp_addextendedproperty N'MS_Description', 'First Flex name.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBuckets', 'COLUMN', N'airlineFirstFlex'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Super saver name.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineBuckets', 'COLUMN', N'airlineSuperSaver'
GO
