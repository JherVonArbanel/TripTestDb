CREATE TABLE [dbo].[TripAirResponseTax]
(
[tripAirResponseTaxKey] [int] NOT NULL IDENTITY(1, 1),
[airResponseKey] [uniqueidentifier] NOT NULL,
[amount] [float] NULL,
[designator] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nature] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL CONSTRAINT [DF__TripAirRe__Activ__038683F8] DEFAULT ((1)),
[tripAirPriceKey] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirResponseTax] ADD CONSTRAINT [PK_TripAirResponseTax] PRIMARY KEY CLUSTERED  ([tripAirResponseTaxKey]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag indicator whether Tax is enable or not.  Default is Enable (1).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponseTax', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Air Response key reference to AirResponse table (airResponseKey).', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponseTax', 'COLUMN', N'airResponseKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tax amount.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponseTax', 'COLUMN', N'amount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Designator.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponseTax', 'COLUMN', N'designator'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key for TripAirResponseTax table.  Clustered Index field.', 'SCHEMA', N'dbo', 'TABLE', N'TripAirResponseTax', 'COLUMN', N'tripAirResponseTaxKey'
GO
