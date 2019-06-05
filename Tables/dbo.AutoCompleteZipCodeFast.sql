CREATE TABLE [dbo].[AutoCompleteZipCodeFast]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SearchCode] [int] NOT NULL,
[ZipCodeComponents] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__AutoCompl__ZipCo__630F92C5] DEFAULT (NULL)
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AutoComplete_BySearchCode] ON [dbo].[AutoCompleteZipCodeFast] ([SearchCode]) ON [PRIMARY]
GO
