CREATE TABLE [dbo].[tblIROP_Manifest]
(
[pkId] [int] NOT NULL IDENTITY(1, 1),
[fk_IROPId] [int] NULL,
[IROPRecordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [date] NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPhoneNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureCity] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalCity] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAXConxInfo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSRCode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSRComments] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassOfService] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorityCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblIROP_Manifest] ADD CONSTRAINT [PK_tblIROP_Manifest] PRIMARY KEY CLUSTERED  ([pkId]) ON [PRIMARY]
GO
