CREATE TABLE [dbo].[TripRequest_activity]
(
[tripRequestKey] [int] NOT NULL,
[activityRequestKey] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tripRequestKey] ON [dbo].[TripRequest_activity] ([tripRequestKey], [activityRequestKey]) ON [PRIMARY]
GO
