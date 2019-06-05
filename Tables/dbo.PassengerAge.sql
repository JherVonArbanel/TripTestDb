CREATE TABLE [dbo].[PassengerAge]
(
[PassengerAgeKey] [int] NOT NULL IDENTITY(1, 1),
[TripRequestKey] [int] NOT NULL,
[PassengerTypeKey] [int] NULL,
[PassengerAge] [int] NULL,
[TripKey] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripRequestKey] ON [dbo].[PassengerAge] ([TripRequestKey]) INCLUDE ([PassengerAge], [PassengerTypeKey]) ON [PRIMARY]
GO
