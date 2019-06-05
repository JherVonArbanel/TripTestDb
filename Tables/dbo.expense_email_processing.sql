CREATE TABLE [dbo].[expense_email_processing]
(
[tripkey] [int] NULL,
[expense_resource_id] [int] NULL,
[trip_status] [int] NULL,
[is_sent] [bit] NULL,
[create_date] [datetime] NULL,
[last_modified_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [i1] ON [dbo].[expense_email_processing] ([tripkey], [trip_status], [last_modified_date]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[expense_email_processing] TO [public]
GO
