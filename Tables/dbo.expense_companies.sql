CREATE TABLE [dbo].[expense_companies]
(
[expenseSourceId] [int] NOT NULL IDENTITY(1, 1),
[company_name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[expense_companies] ADD CONSTRAINT [PK_dbo.expense_companies] PRIMARY KEY CLUSTERED  ([expenseSourceId]) ON [PRIMARY]
GO
