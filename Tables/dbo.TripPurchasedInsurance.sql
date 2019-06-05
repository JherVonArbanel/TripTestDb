CREATE TABLE [dbo].[TripPurchasedInsurance]
(
[tripPurchasedInsuranceKey] [int] NOT NULL IDENTITY(1, 1),
[OrderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripKey] [int] NULL,
[Amount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isDeleted] [bit] NULL CONSTRAINT [DF__TripPurch__isDel__1C0818FF] DEFAULT ((0)),
[isOnlineBooking] [bit] NULL CONSTRAINT [DF__TripPurch__isOnl__002AF460] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripPurchasedInsurance] ADD CONSTRAINT [PK_PurchasedInsurance] PRIMARY KEY CLUSTERED  ([tripPurchasedInsuranceKey]) ON [PRIMARY]
GO
