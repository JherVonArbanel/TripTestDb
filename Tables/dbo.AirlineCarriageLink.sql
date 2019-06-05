CREATE TABLE [dbo].[AirlineCarriageLink]
(
[airline] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[conditionOfCarriageLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_PK_AirLine] ON [dbo].[AirlineCarriageLink] ([airline], [conditionOfCarriageLink]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Airline Code', 'SCHEMA', N'dbo', 'TABLE', N'AirlineCarriageLink', 'COLUMN', N'airline'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Condition page URL of Carriage Link.', 'SCHEMA', N'dbo', 'TABLE', N'AirlineCarriageLink', 'COLUMN', N'conditionOfCarriageLink'
GO
