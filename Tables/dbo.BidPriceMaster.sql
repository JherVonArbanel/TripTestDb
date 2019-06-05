CREATE TABLE [dbo].[BidPriceMaster]
(
[PkId] [int] NOT NULL IDENTITY(1, 1),
[TripKey] [int] NULL,
[AirRequestTypeKey] [int] NULL,
[BookedPrice] [float] NULL,
[EmailId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AirResponseKey1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentPrice1] [float] NULL,
[AirResponseKey2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentPrice2] [float] NULL,
[AirResponseKey3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentPrice3] [float] NULL,
[IsMailSent] [bit] NULL CONSTRAINT [DF__BidPriceM__IsMai__6A50C1DA] DEFAULT ((0)),
[CreateDate] [datetime] NULL CONSTRAINT [DF__BidPriceM__Creat__6B44E613] DEFAULT (getdate()),
[AirSubRequestKey] [int] NULL,
[GroupId] [int] NULL,
[IsUpdated] [smallint] NULL CONSTRAINT [DF__BidPriceM__IsUpd__5A6F5FCC] DEFAULT ((0))
) ON [PRIMARY]
GO
