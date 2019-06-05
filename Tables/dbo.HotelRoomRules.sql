CREATE TABLE [dbo].[HotelRoomRules]
(
[hotelRoomRuleKey] [uniqueidentifier] NULL,
[hotelResponseDetailKey] [uniqueidentifier] NULL,
[ruleCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[roomRules] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
