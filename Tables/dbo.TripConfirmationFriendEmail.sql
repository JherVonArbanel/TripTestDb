CREATE TABLE [dbo].[TripConfirmationFriendEmail]
(
[tripFriendKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NOT NULL,
[friendEmailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripConfirmationFriendEmail] ADD CONSTRAINT [PK_TripConfirmationFriendEmail] PRIMARY KEY CLUSTERED  ([tripFriendKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_Get_TripConfirmationFriendEmail_tripKey] ON [dbo].[TripConfirmationFriendEmail] ([tripKey] DESC) ON [PRIMARY]
GO
