CREATE TABLE [dbo].[TripSavedDealLog]
(
[TripSavedDealLogKey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[GroupId] [int] NULL,
[ComponentType] [int] NULL,
[ErrorMessage] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorStack] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remarks] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDate] [datetime] NULL CONSTRAINT [DF__TripSaved__Error__7A3D10E0] DEFAULT (getdate()),
[Request] [xml] NULL,
[Response] [xml] NULL,
[InitiatedFrom] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripSavedDealLog] ADD CONSTRAINT [PK__TripSave__8ADF85C87854C86E] PRIMARY KEY CLUSTERED  ([TripSavedDealLogKey]) ON [PRIMARY]
GO
