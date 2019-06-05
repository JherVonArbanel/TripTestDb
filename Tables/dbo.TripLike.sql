CREATE TABLE [dbo].[TripLike]
(
[likeKey] [int] NOT NULL IDENTITY(1, 1),
[tripSavedKey] [uniqueidentifier] NULL,
[userKey] [int] NULL,
[tripLike] [int] NULL,
[createdDate] [datetime] NULL,
[tripKey] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripLike] ADD CONSTRAINT [PK_TripLike] PRIMARY KEY CLUSTERED  ([likeKey]) ON [PRIMARY]
GO
