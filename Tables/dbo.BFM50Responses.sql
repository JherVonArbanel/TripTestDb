CREATE TABLE [dbo].[BFM50Responses]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[RequestId] [int] NULL,
[AirResponses] [xml] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BFM50Responses] ADD CONSTRAINT [PK_BFM50Responses] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
