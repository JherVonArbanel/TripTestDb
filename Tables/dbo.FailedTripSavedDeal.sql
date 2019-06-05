CREATE TABLE [dbo].[FailedTripSavedDeal]
(
[FailedTripSavedDealkey] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[ComponentType] [int] NULL,
[TripSavedKey] [uniqueidentifier] NULL,
[FailedDate] [datetime] NULL CONSTRAINT [DF__FailedTri__Faile__0F6D37F0] DEFAULT (getdate())
) ON [PRIMARY]
GO
