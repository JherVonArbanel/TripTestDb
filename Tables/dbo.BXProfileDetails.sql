CREATE TABLE [dbo].[BXProfileDetails]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[TravelRequestKey] [bigint] NULL,
[UserKey] [bigint] NULL,
[AirRequestKey] [bigint] NULL,
[ProfileRemarks] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AwardCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BXProfileDetails] ADD CONSTRAINT [PK__BXProfil__3214EC078D55FDE1] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
