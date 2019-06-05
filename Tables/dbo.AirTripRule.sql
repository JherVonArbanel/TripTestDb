CREATE TABLE [dbo].[AirTripRule]
(
[airSegmentKey] [uniqueidentifier] NULL,
[airFareBasisCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airTripRulesContent] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
