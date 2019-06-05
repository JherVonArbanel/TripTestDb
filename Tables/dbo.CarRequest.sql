CREATE TABLE [dbo].[CarRequest]
(
[carRequestKey] [int] NOT NULL IDENTITY(1, 1),
[pickupCityCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dropoffCityCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pickupDate] [datetime] NOT NULL,
[dropoffDate] [datetime] NOT NULL,
[carRequestCreated] [datetime] NOT NULL,
[NoofCars] [int] NULL CONSTRAINT [DF__CarReques__NoofC__787EE5A0] DEFAULT ((1)),
[isCacheDataCollected] [bit] NOT NULL CONSTRAINT [DF__CarReques__isCac__5F740C0B] DEFAULT ((0)),
[carAddress] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[latitude] [float] NULL,
[longitude] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarRequest] ADD CONSTRAINT [PK_CarRequest] PRIMARY KEY CLUSTERED  ([carRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
