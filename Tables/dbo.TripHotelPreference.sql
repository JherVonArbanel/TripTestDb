CREATE TABLE [dbo].[TripHotelPreference]
(
[TripHotelPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[Stars] [float] NULL,
[RegionId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripHotelPreference] ADD CONSTRAINT [PK__TripHote__BC61ED606CAE0B98] PRIMARY KEY CLUSTERED  ([TripHotelPreferenceKey]) ON [PRIMARY]
GO
