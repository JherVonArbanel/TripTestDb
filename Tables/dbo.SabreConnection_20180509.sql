CREATE TABLE [dbo].[SabreConnection_20180509]
(
[ConnectionID] [int] NOT NULL IDENTITY(1, 1),
[UserName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPCC] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Domain] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromPartyID] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToPartyID] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageID] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinimumSession] [int] NULL,
[MaximumSession] [int] NULL,
[DefaultSessionTimeOut] [int] NULL,
[ActulSessionTimeOut] [int] NULL,
[DefaultConnection] [bit] NULL,
[restAPIUserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[restAPISecret] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[restAPIbase64String] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
