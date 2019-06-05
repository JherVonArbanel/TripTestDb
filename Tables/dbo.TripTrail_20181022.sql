CREATE TABLE [dbo].[TripTrail_20181022]
(
[tripTrailKey] [int] NOT NULL IDENTITY(1, 1),
[tripRequestKey] [int] NULL,
[componentType] [int] NULL,
[page] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [bit] NULL,
[CreatedDate] [datetime] NULL,
[SelectedData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
