CREATE TABLE [dbo].[NeighboringCountries]
(
[CountryRegID] [int] NOT NULL IDENTITY(1, 1),
[HomeCountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NeighborRegionCode] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NeighboringCountries] ADD CONSTRAINT [PK_NeighboringCountries] PRIMARY KEY CLUSTERED  ([CountryRegID]) ON [PRIMARY]
GO
