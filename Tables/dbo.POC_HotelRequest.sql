CREATE TABLE [dbo].[POC_HotelRequest]
(
[RequestId] [int] NOT NULL IDENTITY(100, 1),
[HotelId] [int] NOT NULL,
[StartDateTime] [datetime] NOT NULL,
[EndDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POC_HotelRequest] ADD CONSTRAINT [PK_POC_HotelRequest] PRIMARY KEY CLUSTERED  ([RequestId]) ON [PRIMARY]
GO
