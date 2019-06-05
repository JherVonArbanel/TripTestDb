CREATE TABLE [dbo].[AirSubRequestGroup]
(
[airSubRequestGroupKey] [int] NOT NULL IDENTITY(1, 1),
[name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isSNAPIncluded] [bit] NULL,
[includeParticipatingAirlines] [bit] NULL
) ON [PRIMARY]
GO
