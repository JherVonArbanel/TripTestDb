CREATE TABLE [dbo].[CrowdMemberDetails]
(
[crowdMemberDetailsKey] [int] NOT NULL IDENTITY(1, 1),
[crowdId] [bigint] NULL,
[userKey] [int] NULL,
[destination] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userFirstName] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userLastName] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userImageUrl] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdDateTime] [datetime] NULL,
[CrowdCount] [int] NULL CONSTRAINT [DF__CrowdMemb__Crowd__3F27380A] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CrowdMemberDetails] ADD CONSTRAINT [PK_CrowdMemberDetails] PRIMARY KEY CLUSTERED  ([crowdMemberDetailsKey]) ON [PRIMARY]
GO
