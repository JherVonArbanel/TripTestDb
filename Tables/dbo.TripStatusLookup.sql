CREATE TABLE [dbo].[TripStatusLookup]
(
[tripStatusKey] [int] NOT NULL,
[tripStatusName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripStatusLookup] ADD CONSTRAINT [pk_TripStatusLookup] PRIMARY KEY CLUSTERED  ([tripStatusKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
