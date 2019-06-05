CREATE TABLE [dbo].[POC_HotelResponse]
(
[ResponseId] [int] NOT NULL IDENTITY(1, 1),
[RequestId] [int] NOT NULL,
[Response] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POC_HotelResponse] ADD CONSTRAINT [PK_POC_HotelResponse] PRIMARY KEY CLUSTERED  ([ResponseId]) ON [PRIMARY]
GO
