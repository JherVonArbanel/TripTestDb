CREATE TABLE [dbo].[CarVendorPreference]
(
[CarVendorPreferenceKey] [int] NOT NULL,
[CarVendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarVendorCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarVendorPreference] ADD CONSTRAINT [PK__CarVendo__23BB8FD6455F344D] PRIMARY KEY CLUSTERED  ([CarVendorPreferenceKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarVendorPreference] ADD CONSTRAINT [UQ__CarVendo__4BD4A7C34B180DA3] UNIQUE NONCLUSTERED  ([CarVendor]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarVendorPreference] ADD CONSTRAINT [UQ__CarVendo__DD840D58483BA0F8] UNIQUE NONCLUSTERED  ([CarVendorCode]) ON [PRIMARY]
GO
