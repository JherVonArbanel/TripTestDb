CREATE TABLE [dbo].[TripComponentLookUp]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ComponentTypeKey] [int] NOT NULL,
[TripComponentVal] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Component] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
