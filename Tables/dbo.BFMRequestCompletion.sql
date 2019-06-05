CREATE TABLE [dbo].[BFMRequestCompletion]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[AirRequestId] [int] NULL,
[BFMCallIndex] [int] NULL,
[createdate] [datetime] NULL CONSTRAINT [DF__BFMReques__creat__0E7913B7] DEFAULT (getdate()),
[IsSuccessfullBFM] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BFMRequestCompletion] ADD CONSTRAINT [PK_BFMRequestCompletion] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_AirRequestID] ON [dbo].[BFMRequestCompletion] ([AirRequestId]) ON [PRIMARY]
GO
