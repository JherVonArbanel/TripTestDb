CREATE TABLE [dbo].[TripTrail]
(
[tripTrailKey] [int] NOT NULL IDENTITY(1, 1),
[tripRequestKey] [int] NULL,
[componentType] [int] NULL,
[page] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [bit] NULL,
[CreatedDate] [datetime] NULL,
[SelectedData] [xml] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripTrail] ADD CONSTRAINT [PK_TripTrail] PRIMARY KEY CLUSTERED  ([tripTrailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
