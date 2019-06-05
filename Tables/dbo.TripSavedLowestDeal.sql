CREATE TABLE [dbo].[TripSavedLowestDeal]
(
[TripSavedLowestDealKey] [int] NOT NULL IDENTITY(1, 1),
[tripKey] [int] NULL,
[responseKey] [uniqueidentifier] NULL,
[componentType] [int] NULL,
[responseDetailKey] [uniqueidentifier] NULL,
[creationDate] [datetime] NULL,
[isAlternate] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripSavedLowestDeal] ADD CONSTRAINT [PK__TripSave__12E9256A52B92F6B] PRIMARY KEY CLUSTERED  ([TripSavedLowestDealKey]) ON [PRIMARY]
GO
