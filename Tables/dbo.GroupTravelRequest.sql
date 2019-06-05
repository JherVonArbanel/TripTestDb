CREATE TABLE [dbo].[GroupTravelRequest]
(
[GroupTravelRequestId] [int] NOT NULL,
[OrganizerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrganizerEmailId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOfTraveler] [int] NULL,
[NoOfHotel] [int] NULL,
[IsFlightSelected] [bit] NULL,
[IsCarSelected] [bit] NULL,
[NoOfDestination] [int] NULL,
[BudgetPerPerson] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequestCreatedBy] [int] NULL,
[RequestCreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
