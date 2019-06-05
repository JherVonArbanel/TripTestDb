CREATE TABLE [dbo].[TripAirPreference]
(
[TripAirPreferenceKey] [int] NOT NULL IDENTITY(1, 1),
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[Class] [int] NULL,
[FlightStops] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAirPreference] ADD CONSTRAINT [PK__TripAirP__BE9A224B650CE9D0] PRIMARY KEY CLUSTERED  ([TripAirPreferenceKey]) ON [PRIMARY]
GO
