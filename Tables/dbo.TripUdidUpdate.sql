CREATE TABLE [dbo].[TripUdidUpdate]
(
[tripKey] [int] NULL,
[recordLocator] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassengerUDIDValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[siteCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isUpdate] [bit] NULL CONSTRAINT [DF__TripUdidU__isUpd__22EA20B8] DEFAULT ((0))
) ON [PRIMARY]
GO
