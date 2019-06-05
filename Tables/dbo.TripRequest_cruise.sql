CREATE TABLE [dbo].[TripRequest_cruise]
(
[tripRequestKey] [int] NOT NULL,
[cruiseRequestKey] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripRequest_cruise] ON [dbo].[TripRequest_cruise] ([tripRequestKey], [cruiseRequestKey]) ON [PRIMARY]
GO
