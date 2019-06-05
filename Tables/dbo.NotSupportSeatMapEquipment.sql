CREATE TABLE [dbo].[NotSupportSeatMapEquipment]
(
[equipmentKey] [int] NOT NULL IDENTITY(1, 1),
[equipmentCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NotSupportSeatMapEquipment] ADD CONSTRAINT [pk_NotSupportSeatMapEquipment] PRIMARY KEY CLUSTERED  ([equipmentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EquipmentCode] ON [dbo].[NotSupportSeatMapEquipment] ([equipmentCode]) ON [PRIMARY]
GO
