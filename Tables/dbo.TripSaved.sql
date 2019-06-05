CREATE TABLE [dbo].[TripSaved]
(
[tripSavedKey] [uniqueidentifier] NOT NULL,
[userKey] [int] NOT NULL,
[parentSaveTripKey] [uniqueidentifier] NULL,
[SplitFollowersCount] [int] NULL,
[crowdId] [bigint] NULL,
[privacyType] [int] NULL,
[createdDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripSaved] ADD CONSTRAINT [PK_TripSaved_1] PRIMARY KEY CLUSTERED  ([tripSavedKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_tripSavedKey] ON [dbo].[TripSaved] ([tripSavedKey]) INCLUDE ([crowdId], [SplitFollowersCount]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_User_TripSaved] ON [dbo].[TripSaved] ([userKey]) INCLUDE ([tripSavedKey]) ON [PRIMARY]
GO
