CREATE TABLE [dbo].[InsuranceConnection]
(
[ConnectionID] [int] NOT NULL IDENTITY(1, 1),
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accam] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfferRequestPassword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PurchaseRequestPassword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InsuranceConnection] ADD CONSTRAINT [PK_InsuranceConnection] PRIMARY KEY CLUSTERED  ([ConnectionID]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[InsuranceConnection] TO [dev]
GO
DENY INSERT ON  [dbo].[InsuranceConnection] TO [dev]
GO
DENY ALTER ON  [dbo].[InsuranceConnection] TO [dev]
GO
DENY CONTROL ON  [dbo].[InsuranceConnection] TO [dev]
GO
GRANT SELECT ON  [dbo].[InsuranceConnection] TO [dev]
GO
DENY TAKE OWNERSHIP ON  [dbo].[InsuranceConnection] TO [dev]
GO
DENY UPDATE ON  [dbo].[InsuranceConnection] TO [dev]
GO
