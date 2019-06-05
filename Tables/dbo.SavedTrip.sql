CREATE TABLE [dbo].[SavedTrip]
(
[savedTripKey] [int] NOT NULL IDENTITY(1, 1),
[airResponseKey] [uniqueidentifier] NULL,
[carResponseKey] [uniqueidentifier] NULL,
[hotelResponseKey] [uniqueidentifier] NULL,
[userKey] [int] NULL,
[startDate] [datetime] NULL,
[endDate] [datetime] NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedTrip] ADD CONSTRAINT [PK_SavedTrip] PRIMARY KEY CLUSTERED  ([savedTripKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_airResponseKey] ON [dbo].[SavedTrip] ([airResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_carResponseKey] ON [dbo].[SavedTrip] ([carResponseKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_hotelResponseKey] ON [dbo].[SavedTrip] ([hotelResponseKey]) ON [PRIMARY]
GO
