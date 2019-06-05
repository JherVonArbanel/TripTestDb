CREATE TABLE [dbo].[TripErrorDetails]
(
[RequestKey] [int] NOT NULL,
[tripComponentType] [smallint] NULL,
[ErrorDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
