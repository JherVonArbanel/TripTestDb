CREATE TABLE [dbo].[TripPurchased]
(
[tripPurchasedKey] [uniqueidentifier] NOT NULL,
[TripHistoryKey] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPurchased] ADD CONSTRAINT [PK_TripPurchased_1] PRIMARY KEY CLUSTERED  ([tripPurchasedKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
