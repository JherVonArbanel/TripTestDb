CREATE TABLE [dbo].[TripAirResponse_UADomesticFarePercentanges]
(
[tripKey] [int] NOT NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startDate] [datetime] NULL,
[endDate] [datetime] NULL,
[CreatedDate] [datetime] NOT NULL,
[airResponseKey] [uniqueidentifier] NOT NULL,
[Discount] [int] NULL,
[DBDiscount] [float] NULL
) ON [PRIMARY]
GO
