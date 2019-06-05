CREATE TABLE [dbo].[AirRequest_AirSubrequest]
(
[airRequestSubRequestkey] [bigint] NOT NULL IDENTITY(1, 1),
[airRequestKey] [bigint] NULL,
[airSubrequestKey] [bigint] NULL,
[airSubRequestLegIndex] [int] NULL
) ON [PRIMARY]
GO
