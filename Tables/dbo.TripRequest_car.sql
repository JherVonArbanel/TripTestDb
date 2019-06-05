CREATE TABLE [dbo].[TripRequest_car]
(
[tripRequestKey] [int] NOT NULL,
[carRequestKey] [int] NOT NULL,
[carClass] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOFRequestSentToGDS] [int] NULL,
[searchType] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_carRequestKey] ON [dbo].[TripRequest_car] ([carRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_tripRequestKey] ON [dbo].[TripRequest_car] ([tripRequestKey]) ON [PRIMARY]
GO
