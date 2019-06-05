CREATE TABLE [dbo].[UserChatMapping]
(
[fromUserKey] [int] NOT NULL,
[toUserKey] [int] NOT NULL,
[chatStreamKey] [uniqueidentifier] NOT NULL,
[createdDate] [datetime] NOT NULL,
[readCount] [int] NULL
) ON [PRIMARY]
GO
